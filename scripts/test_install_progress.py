"""Small real subprocesses exercise pipe streaming and process-group teardown."""
import contextlib
import io
import os
from pathlib import Path
import selectors
import signal
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from unittest.mock import patch

import install_progress as progress


class Progress(unittest.TestCase):
    def test_spawn_boundary_signal_is_deferred_until_child_is_owned_and_reaped(self):
        popen = subprocess.Popen
        for sig in (signal.SIGINT, signal.SIGTERM):
            with self.subTest(signal=sig), tempfile.TemporaryDirectory() as tmp:
                children = []
                handlers = {s: signal.getsignal(s) for s in (signal.SIGINT, signal.SIGTERM)}

                def spawn(*args, **kwargs):
                    child = popen(*args, **kwargs)
                    children.append(child)
                    # Deterministic reproduction: the OS child exists but
                    # run_logged has not received/assigned its Popen handle.
                    os.kill(os.getpid(), sig)
                    return child

                try:
                    with contextlib.redirect_stderr(io.StringIO()), \
                         patch.object(progress.subprocess, 'Popen', side_effect=spawn), \
                         progress.cancellation_signals(), \
                         self.assertRaises(progress.Cancelled) as caught:
                        progress.run_logged([sys.executable, '-c', 'import time; time.sleep(60)'],
                                            tmp, os.environ, Path(tmp) / 'log', cleanup_timeout=.1)
                    self.assertEqual(caught.exception.signum, sig)
                    self.assertEqual(len(children), 1)
                    self.assertIsNotNone(children[0].returncode, 'spawned child was not reaped')
                    self.assertTrue(children[0].stdout.closed)
                    for s, handler in handlers.items():
                        self.assertEqual(signal.getsignal(s), handler)
                finally:
                    for child in children:
                        if child.poll() is None:
                            os.killpg(child.pid, signal.SIGKILL)
                        child.wait(timeout=3)
                        child.stdout.close()

    def test_capture_and_inventory_still_interrupt_immediately(self):
        for label in ('capture', 'inventory'):
            for sig in (signal.SIGINT, signal.SIGTERM):
                with self.subTest(stage=label, signal=sig):
                    stderr = io.StringIO()
                    with contextlib.redirect_stderr(stderr), self.assertRaises(progress.Cancelled) as caught:
                        with progress.cancellation_signals(), progress.stage(label):
                            os.kill(os.getpid(), sig)
                            self.fail('capture/inventory cancellation was deferred')
                    self.assertEqual(caught.exception.signum, sig)
                    self.assertIn('[INTERRUPTED] ' + label, stderr.getvalue())

    def test_nested_supervisor_gets_its_full_five_second_cleanup_grace(self):
        """ASIC-shaped fixture owns a detached Dune group; no sibling repo needed."""
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            # This is the stubborn grandchild of run_logged's caller. Like
            # Dune, it belongs to a separate session owned by the supervisor.
            worker = ('import os,signal,time; from pathlib import Path; '
                      'signal.signal(signal.SIGTERM,signal.SIG_IGN); '
                      'signal.signal(signal.SIGINT,signal.SIG_IGN); '
                      f'Path({str(root / "ready")!r}).touch(); time.sleep(60)')
            # Mirror ASIC's deferred signals, detached child, five-second wait,
            # group escalation, and reaping. Its completion marker proves the
            # outer helper did not kill it before detached cleanup completed.
            supervisor = (
                'import os,signal,subprocess,sys,time\nfrom pathlib import Path\n'
                f'root=Path({str(root)!r})\n'
                'requested=[]\n'
                'def cancel(sig,frame):\n'
                '    if not requested: requested.append(sig)\n'
                'signal.signal(signal.SIGINT,cancel)\n'
                'signal.signal(signal.SIGTERM,cancel)\n'
                f'child=subprocess.Popen([sys.executable,"-c",{worker!r}],start_new_session=True)\n'
                '(root/"worker-pid").write_text(str(child.pid))\n'
                'while not requested: time.sleep(.01)\n'
                'os.killpg(child.pid,signal.SIGTERM)\n'
                'try:\n'
                '    child.wait(timeout=5)\n'
                'except subprocess.TimeoutExpired:\n'
                '    os.killpg(child.pid,signal.SIGKILL)\n'
                '    child.wait()\n'
                '(root/"reaped").touch()\n'
                'print("NESTED-CLEANUP-COMPLETE",flush=True)\n'
                'sys.exit(128+requested[0])\n')
            popen = subprocess.Popen
            children = []

            def spawn(*args, **kwargs):
                child = popen(*args, **kwargs)
                children.append(child)
                deadline = time.monotonic() + 3
                while not (root / 'ready').exists():
                    if child.poll() is not None or time.monotonic() >= deadline:
                        self.fail('nested fixture did not become ready')
                    time.sleep(.01)
                os.kill(os.getpid(), signal.SIGTERM)
                return child

            try:
                stderr = io.StringIO()
                with contextlib.redirect_stderr(stderr), \
                     patch.object(progress.subprocess, 'Popen', side_effect=spawn), \
                     self.assertRaises(progress.Cancelled) as caught:
                    # Use the production default, so regressing to five seconds
                    # reproduces the detached-worker leak without a sibling repo.
                    progress.run_logged([sys.executable, '-c', supervisor], root, os.environ, root / 'log')
                self.assertEqual(caught.exception.signum, signal.SIGTERM)
                self.assertTrue((root / 'reaped').exists(), 'nested supervisor was killed before reaping Dune')
                self.assertEqual(children[0].returncode, 128 + signal.SIGTERM)
                self.assertIn('NESTED-CLEANUP-COMPLETE', stderr.getvalue())
                self.assertTrue((root / 'log').read_bytes().endswith(b'NESTED-CLEANUP-COMPLETE\n'))
                pid = int((root / 'worker-pid').read_text())
                with self.assertRaises(ProcessLookupError):
                    os.kill(pid, 0)
            finally:
                # Also clean up detached children when exercising a regression.
                if (root / 'worker-pid').exists():
                    pid = int((root / 'worker-pid').read_text())
                    try:
                        os.killpg(pid, signal.SIGKILL)
                    except ProcessLookupError:
                        pass
                for child in children:
                    if child.poll() is None:
                        os.killpg(child.pid, signal.SIGKILL)
                    child.wait(timeout=3)
                    child.stdout.close()

    def test_binary_output_and_partial_lines_are_lossless_and_stderr_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            log = Path(tmp) / 'build.log'
            log.write_bytes(b'previous attempt\n')
            binary = io.BytesIO()
            stderr = io.TextIOWrapper(binary, encoding='utf-8', write_through=True)
            stdout = io.StringIO()
            argv = [sys.executable, '-c',
                    'import os; os.write(1,b"partial\\xff"); os.write(2,b"stderr\\x00")']
            with contextlib.redirect_stderr(stderr), contextlib.redirect_stdout(stdout):
                progress.run_logged(argv, tmp, os.environ, log)
            self.assertEqual(stdout.getvalue(), '')
            self.assertTrue(log.read_bytes().startswith(b'previous attempt\n'))
            self.assertTrue(log.read_bytes().endswith(b'partial\xffstderr\x00'))
            self.assertTrue(binary.getvalue().endswith(b'partial\xffstderr\x00'))

    def test_nonzero_status_preserves_output_and_reports_log(self):
        with tempfile.TemporaryDirectory() as tmp:
            log = Path(tmp) / 'build.log'
            stderr = io.StringIO()
            with contextlib.redirect_stderr(stderr), self.assertRaises(subprocess.CalledProcessError) as caught:
                progress.run_logged([sys.executable, '-c', 'print("failure"); exit(7)'],
                                    tmp, os.environ, log, cleanup_timeout=0.1)
            self.assertEqual(caught.exception.returncode, 7)
            self.assertIn(b'failure\n', log.read_bytes())
            self.assertIn(str(log), stderr.getvalue())

    def test_stages_heartbeat_and_terminal_outcomes(self):
        heartbeat = threading.Event()
        messages = []

        def report(message):
            messages.append(message)
            if '[WORKING]' in message:
                heartbeat.set()

        with patch.object(progress, 'report', side_effect=report):
            with progress.stage('capture', interval=0.01):
                self.assertTrue(heartbeat.wait(2))
            with self.assertRaises(ValueError), progress.stage('build'):
                raise ValueError('failed')
            with self.assertRaises(KeyboardInterrupt), progress.stage('test'):
                raise KeyboardInterrupt()
        for message in ('[START] capture', '[WORKING] capture', '[DONE] capture',
                        '[FAILED] build', '[INTERRUPTED] test'):
            self.assertTrue(any(m.startswith(message) for m in messages), messages)
        self.assertFalse(any(m.startswith('[DONE] build') for m in messages))

    def driver(self, root, code):
        helper = str(Path(progress.__file__).resolve().parent)
        script = (f'import sys; sys.path.insert(0, {helper!r})\n'
                  'from install_progress import *\nfrom pathlib import Path\n'
                  f'root = Path({str(root)!r})\n' + code)
        return subprocess.Popen([sys.executable, '-B', '-c', script],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def read_until(self, process, token):
        data = b''
        deadline = time.monotonic() + 5
        with selectors.DefaultSelector() as selector:
            selector.register(process.stderr, selectors.EVENT_READ)
            while token not in data and time.monotonic() < deadline:
                if selector.select(0.1):
                    chunk = os.read(process.stderr.fileno(), 65536)
                    if not chunk:
                        break
                    data += chunk
        self.assertIn(token, data)
        return data

    def test_partial_line_is_visible_before_child_can_finish(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            child = ('import os,time; from pathlib import Path; os.write(1,b"LIVE-PARTIAL"); '
                     f'gate=Path({str(root / "gate")!r})\n'
                     'while not gate.exists(): time.sleep(.01)\n')
            process = self.driver(root,
                f'run_logged([sys.executable, "-c", {child!r}], root, os.environ, root/"log")\n')
            try:
                self.read_until(process, b'\nLIVE-PARTIAL')
                self.assertIsNone(process.poll())
                self.assertTrue((root / 'log').read_bytes().endswith(b'LIVE-PARTIAL'))
                (root / 'gate').touch()
                stdout, stderr = process.communicate(timeout=5)
                self.assertEqual((process.returncode, stdout), (0, b''), stderr)
            finally:
                (root / 'gate').touch()
                if process.poll() is None:
                    process.kill()
                process.communicate(timeout=5)

    @unittest.skipUnless(sys.platform == 'linux', 'process state check uses /proc')
    def test_both_signals_kill_stubborn_grandchild_even_after_leader_exits(self):
        for sig in (signal.SIGINT, signal.SIGTERM):
            with self.subTest(signal=sig), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                # The leader exits on TERM; its worker ignores it. Cleanup must
                # escalate against the group even once wait() reaps the leader.
                grandchild = ('import os,signal,time; '
                              'signal.signal(signal.SIGTERM, signal.SIG_IGN); '
                              'print("READY",os.getpid(),flush=True); time.sleep(60)')
                child = ('import os,signal,subprocess,sys,time\n'
                         'def stop(sig,frame):\n'
                         '    os.write(2,b"SHUTDOWN-PARTIAL"); sys.exit(0)\n'
                         'signal.signal(signal.SIGTERM,stop)\n'
                         f'subprocess.Popen([sys.executable,"-c",{grandchild!r}])\n'
                         'time.sleep(60)')
                process = self.driver(root,
                    'try:\n'
                    '    with stage("test"):\n'
                    f'        run_logged([sys.executable,"-c",{child!r}], root, os.environ, root/"log", cleanup_timeout=.15)\n'
                    'except Cancelled as error:\n    sys.exit(128 + error.signum)\n')
                pid = None
                try:
                    output = self.read_until(process, b'READY ')
                    # Read the PID from the log, not command diagnostics (which
                    # also contain the literal child program).
                    deadline = time.monotonic() + 5
                    while time.monotonic() < deadline:
                        lines = (root / 'log').read_text().splitlines()
                        ready = [line for line in lines if line.startswith('READY ')]
                        if ready:
                            pid = int(ready[-1].split()[1])
                            break
                        time.sleep(.01)
                    self.assertIsNotNone(pid)
                    os.kill(process.pid, sig)
                    # Repeated cancellation cannot cut cleanup short.
                    time.sleep(.03)
                    if process.poll() is None:
                        os.kill(process.pid, sig)
                    stdout, stderr = process.communicate(timeout=5)
                    self.assertEqual(process.returncode, 128 + sig, output + stderr)
                    self.assertEqual(stdout, b'')
                    self.assertIn(b'[INTERRUPTED] test', stderr)
                    self.assertTrue((root / 'log').read_bytes().endswith(b'SHUTDOWN-PARTIAL'))
                    deadline = time.monotonic() + 2
                    while time.monotonic() < deadline:
                        state = Path(f'/proc/{pid}/stat')
                        if not state.exists() or state.read_text().split()[2] == 'Z':
                            break
                        time.sleep(.01)
                    else:
                        self.fail('grandchild survived cancellation')
                finally:
                    if process.poll() is None:
                        process.kill()
                    process.communicate(timeout=5)
                    if pid is not None:
                        try:
                            os.kill(pid, signal.SIGKILL)
                        except ProcessLookupError:
                            pass


if __name__ == '__main__':
    unittest.main()
