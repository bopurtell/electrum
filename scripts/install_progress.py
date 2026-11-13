"""Terminal diagnostics and lossless subprocess logs for local installation."""
import codecs
import contextlib
import os
import selectors
import shlex
import signal
import subprocess
import sys
import threading
import time


# Captured ASIC installers supervise a separate Dune session and allow five
# seconds for its shutdown. They must survive long enough to escalate/reap that
# session themselves: killing ASIC cannot reach its detached Dune descendants.
# Keep a scheduling/polling margin above ASIC's CANCEL_GRACE_SECONDS (5).
CLEANUP_GRACE_SECONDS = 10


class Cancelled(KeyboardInterrupt):
    def __init__(self, signum):
        self.signum = signum
        super().__init__(signal.Signals(signum).name)


class Cancellation:
    def __init__(self):
        self.signum = None

    def check(self):
        if self.signum is not None:
            raise Cancelled(self.signum)


@contextlib.contextmanager
def cancellation_signals(deferred=False):
    """Defer signals only inside subprocess ownership; otherwise unwind immediately."""
    previous = {}
    cancellation = Cancellation()

    def cancel(signum, frame):
        # Record the first request; repeated signals cannot interrupt cleanup.
        # Raising inside Popen can lose the child before its handle is returned.
        if cancellation.signum is None:
            cancellation.signum = signum
            if not deferred:
                cancellation.check()

    try:
        for sig in (signal.SIGINT, signal.SIGTERM):
            previous[sig] = signal.signal(sig, cancel)
        yield cancellation
        if deferred:
            cancellation.check()
    finally:
        for sig, handler in previous.items():
            signal.signal(sig, handler)


def report(message):
    print(message, file=sys.stderr, flush=True)


@contextlib.contextmanager
def stage(label, interval=15):
    started = time.monotonic()
    stopped = threading.Event()
    report(f'[START] {label}')

    def heartbeat():
        while not stopped.wait(interval):
            report(f'[WORKING] {label} ({time.monotonic() - started:.0f}s elapsed)')

    worker = threading.Thread(target=heartbeat, daemon=True)
    worker.start()
    outcome = 'DONE'
    try:
        yield
    except BaseException:
        outcome = 'INTERRUPTED' if isinstance(sys.exc_info()[1], KeyboardInterrupt) else 'FAILED'
        raise
    finally:
        stopped.set()
        worker.join()
        report(f'[{outcome}] {label} ({time.monotonic() - started:.1f}s)')


def run_logged(argv, cwd, env, log, cleanup_timeout=CLEANUP_GRACE_SECONDS):
    """Tee merged bytes immediately, including output without a trailing newline."""
    argv = list(map(str, argv))
    report('+ ' + shlex.join(argv))
    with cancellation_signals(deferred=True) as cancellation, log.open('ab') as stream:
        stream.write(('\n+ ' + shlex.join(argv) + '\n').encode())
        stream.flush()
        process = None
        decoder = codecs.getincrementaldecoder('utf-8')(errors='replace')

        def tee(data):
            stream.write(data)
            stream.flush()
            # Text-only stderr (e.g. embedded callers) still gets live output;
            # the log always retains the exact original bytes.
            binary = getattr(sys.stderr, 'buffer', None)
            if binary is not None:
                binary.write(data)
                binary.flush()
            else:
                sys.stderr.write(decoder.decode(data, final=not data))
                sys.stderr.flush()

        def pump(selector, timeout):
            for key, _ in selector.select(timeout=timeout):
                data = os.read(key.fileobj.fileno(), 65536)
                tee(data)
                if not data:
                    selector.unregister(key.fileobj)

        def send(sig):
            try:
                os.killpg(process.pid, sig)
            except ProcessLookupError:
                pass

        try:
            cancellation.check()
            process = subprocess.Popen(argv, cwd=cwd, env=env, stdout=subprocess.PIPE,
                                       stderr=subprocess.STDOUT, start_new_session=True)
            # Ownership is established before observing a spawn-time signal.
            cancellation.check()
            with selectors.DefaultSelector() as selector:
                selector.register(process.stdout, selectors.EVENT_READ)
                while selector.get_map():
                    cancellation.check()
                    pump(selector, 0.2)
            # A child may close its pipes before exiting; keep cancellation
            # responsive even when there is no remaining output to select on.
            while True:
                cancellation.check()
                try:
                    code = process.wait(timeout=0.2)
                    break
                except subprocess.TimeoutExpired:
                    pass
            cancellation.check()
            if code:
                report(f'Command exited {code}; full log: {log}')
                raise subprocess.CalledProcessError(code, argv)
        except BaseException:
            if process is None:
                raise
            # Kill the whole build/test group, including Dune's workers, before
            # releasing the installation lock or allowing a resume.
            send(signal.SIGTERM)
            # Drain shutdown output while giving *all* group members a grace
            # period. Waiting only for the leader leaves stubborn workers alive.
            try:
                with selectors.DefaultSelector() as selector:
                    selector.register(process.stdout, selectors.EVENT_READ)
                    deadline = time.monotonic() + cleanup_timeout
                    try:
                        while time.monotonic() < deadline:
                            pump(selector, min(0.05, max(0, deadline - time.monotonic())))
                            process.poll()
                            try:
                                os.killpg(process.pid, 0)
                            except ProcessLookupError:
                                break
                    finally:
                        # Even a failed log/terminal write must reap the child.
                        send(signal.SIGKILL)
                        process.wait()
                    deadline = time.monotonic() + 1
                    while selector.get_map() and time.monotonic() < deadline:
                        pump(selector, 0.05)
            except OSError:
                # Preserve the original failure if the logging sink broke.
                pass
            report(f'Command stopped; full log: {log}')
            raise
        finally:
            if process is not None:
                process.stdout.close()
