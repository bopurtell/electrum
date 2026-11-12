#!/usr/bin/env python3
"""Installed daemon/UI reader adoption, source Resources, and live FS2 cancellation.

No physical Run/Launch_fresh/Finalize operation exists in this harness. The old
private physical store and its scope remain untouched. A new test-owned store
adopts the public historical observation via Register at the real project root.
"""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import struct
import subprocess
import sys
import termios
import time
import uuid

sys.dont_write_bytecode = True
from physical_workbench import ROOT, Terminal, field, parse, sexp, sha, save, module
from physical_review import EvidenceClient
import workbench
sys.path.insert(0, str(ROOT / 'scripts/simulation'))
import prepare
from support.screen import terminal_screen
import support.terminal as terminal_module

RELEASE = ROOT / '_flow_results/workbench/releases/714edccf3d934c1b99ce50c6930c7948'
EXECUTION = ROOT / '_flow_results/workbench/asic/fresh-7fc1c6b0da7db33c659e59f722960f04142f0f7e5245c4b1fadab25422b46802/execution-b591d335b32a49b8a019739ef7044e4e.json'


class WideTerminal(Terminal):
    def __init__(self, session):
        super().__init__(session)
        fcntl.ioctl(self.master, termios.TIOCSWINSZ, struct.pack('HHHH', 60, 320, 0, 0))
        self.process.send_signal(signal.SIGWINCH)

    def drain(self, seconds=.3):
        original = terminal_module.terminal_screen
        terminal_module.terminal_screen = lambda data: terminal_screen(data, width=320, height=60)
        try:
            return super().drain(seconds)
        finally:
            terminal_module.terminal_screen = original


def process(pid):
    try:
        path = Path('/proc') / str(pid)
        stat = (path / 'stat').read_text().rsplit(')', 1)[1].split()
        return dict(pid=int(pid), start_ticks=stat[19], state=stat[0],
                    argv=(path / 'cmdline').read_bytes().decode().rstrip('\0').split('\0'))
    except (FileNotFoundError, ProcessLookupError, PermissionError, UnicodeError):
        return None


def descendants(pid):
    result = []
    pending = [pid]
    seen = {pid}
    while pending:
        parent = pending.pop()
        try:
            tasks = list((Path('/proc') / str(parent) / 'task').iterdir())
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            continue
        children = set()
        for task in tasks:
            try:
                children.update((task / 'children').read_text().split())
            except (FileNotFoundError, ProcessLookupError, PermissionError):
                continue
        for child in children:
            if int(child) in seen:
                continue
            seen.add(int(child))
            value = process(int(child))
            if value is not None:
                result.append(value)
                pending.append(value['pid'])
    return result


def same_process(saved):
    current = process(saved['pid'])
    return current is not None and current['start_ticks'] == saved['start_ticks']


def main():
    output = RELEASE / ('normal-installed-journey-' + uuid.uuid4().hex)
    output.mkdir()
    print('Installed journey: ' + str(output), flush=True)
    tools = module(ROOT / 'scripts/install-tools.py', 'journey_tools')
    selection, installed = tools.verify_selection()
    sim_selection, sim_install = prepare.verify_current()
    prefix = Path(selection['prefix'])
    assert installed['sources']['asic']['tree_sha256'].startswith('53b2bdaf')
    assert installed['sources']['workbench']['tree_sha256'].startswith('a8e87a38')
    before = json.loads((RELEASE / 'installed-reinspection/receipt.json').read_text())['protected_sha256']
    config_before = {str(p): sha(p) for p in (ROOT / '.workbench').glob('*.sexp')}
    proof = dict(status='starting', evidence=str(output), tools=selection, simulation=sim_selection,
                 reader_adoption='public Register of retained observation into a fresh normal-project scope',
                 old_private_store_mutated=False, physical_eda_launches=0, cancellations=[])
    save(output / 'receipt.json', proof)
    daemon = terminal = http = None
    env = tools.environment(Path(installed['switch_prefix']), prefix)
    env.update(TERM='xterm-256color')
    for name in ('state', 'discovery', 'config', 'cache'):
        (output / name).mkdir(mode=0o700)
    env.update(XDG_CONFIG_HOME=str(output / 'config'), XDG_CACHE_HOME=str(output / 'cache'))
    count = 0
    def rpc(domain='asic', operation='Get', label=None):
        value = http.rpc(operation if isinstance(operation, str) else sexp(operation), domain=domain, wait=False)
        if label:
            save(output / (label + '.json'), value)
            save(output / (label + '-wire.json'), http.history)
        http.history.clear()
        return value
    def until(action, predicate, label, timeout=120):
        deadline = time.monotonic() + timeout
        while True:
            value = action()
            if predicate(value):
                save(output / (label + '.json'), value)
                return value
            if time.monotonic() >= deadline:
                save(output / (label + '-timeout.json'), value)
                raise TimeoutError(label)
            time.sleep(.1)
    try:
        workbench.stopped()
        with (output / 'daemon.stdout').open('xb') as out, (output / 'daemon.stderr').open('xb') as err:
            daemon = subprocess.Popen([str(prefix / 'bin/hardcaml-workbench-daemon'), '--port', '0',
                '--state-dir', str(output / 'state'), '--discovery-dir', str(output / 'discovery')],
                cwd=ROOT, env=env, stdout=out, stderr=err, start_new_session=True)
        deadline = time.monotonic() + 30
        while not (output / 'discovery/daemon.sexp').exists():
            assert daemon.poll() is None and time.monotonic() < deadline
            time.sleep(.05)
        metadata = dict(parse((output / 'discovery/daemon.sexp').read_text()))
        assert int(metadata['pid']) == daemon.pid
        save(output / 'daemon.json', metadata)
        http = EvidenceClient(metadata['endpoint'], ROOT)
        execution = json.loads(EXECUTION.read_text())
        attempt = execution['attempt_id']
        observation = str(Path(execution['methodology']['snapshot_path']).parent)
        rpc(operation=['Register', [('attempt', observation), ('stream_id', attempt)]], label='public-reader-adoption')
        snapshot = until(lambda: rpc(), lambda s: any(field(r, 'run') and field(field(r, 'run'), 'id') == attempt
            for r in field(s, 'runs')), 'registered-retained-run')
        registered = next(r for r in field(snapshot, 'runs') if field(field(r, 'run'), 'id') == attempt)
        run = field(registered, 'run')
        rpc(operation=['Load_summary', run], label='historical-summary-query')
        snapshot = until(lambda: rpc(), lambda s: any(field(v, 'run') == run for v in field(s, 'summaries')),
                         'historical-summary')
        summary = next(v for v in field(snapshot, 'summaries') if field(v, 'run') == run)
        original = field(summary, 'timing_analysis')[0]
        assert field(original, 'status') == 'Unavailable' and field(original, 'timing_goal') == 'Unknown'
        target = field(original, 'target')
        rpc(operation=['Inspect_analysis', ['run', run], ['target', target], ['refresh', 'true']], label='refresh-query')
        snapshot = until(lambda: rpc(), lambda s: any(len(field(i, 'rows')) == 193 for i in field(s, 'inspections')),
                         'reinspection-index')
        index = next(i for i in field(snapshot, 'inspections') if len(field(i, 'rows')) == 193)
        assert any('original unavailable/unknown unchanged' in d and 'recomputed completed/fail' in d
                   for d in field(index, 'diagnostics'))
        row = next(r for r in field(index, 'rows') if field(r, 'corner') == ['nom_slow_1p08V_125C'] and
                   field(r, 'value') and abs(float(field(r, 'value')[0]) + 3.099803) < 1e-8)
        recomputed_target = field(index, 'analysis')[0]
        assert field(recomputed_target, 'source_digest') != field(target, 'source_digest')
        rpc(operation=['Inspect_analysis_detail', ['run', run], ['target', recomputed_target],
            ['source_digest', field(index, 'source_digest')], ['row_id', field(row, 'id')]], label='negative-detail-query')
        snapshot = until(lambda: rpc(), lambda s: any(field(d, 'row_id') == field(row, 'id') for d in field(s, 'inspection_details')),
                         'negative-detail')
        detail = next(d for d in field(snapshot, 'inspection_details') if field(d, 'row_id') == field(row, 'id'))
        assert not field(detail, 'error') and '-3.099803' in field(detail, 'text')
        assert field(next(v for v in field(snapshot, 'summaries') if field(v, 'run') == run), 'timing_analysis')[0] == original
        # Public context selection, not a synthetic run or cache injection.
        workspace = rpc('workspace')
        overview = next(w for w in field(workspace, 'workspaces') if field(w, 'name') == 'Overview')
        context = next(c for c in field(workspace, 'contexts') if field(c, 'id') == field(overview, 'context'))
        mutation = ['Select_run', ['workspace', field(overview, 'id')], ['context', field(context, 'id')],
                    ['expected_selection_revision', field(context, 'selection_revision')], ['run', [run]]]
        http.mutate(workspace, sexp(mutation))
        save(output / 'context-selection-wire.json', http.history)
        http.history.clear()
        session = type('Session', (), dict(args=type('Args', (), dict(client=prefix / 'bin/hardcaml-workbench'))(),
            url=metadata['endpoint'], root=ROOT, env=env, evidence=output))()
        terminal = WideTerminal(session)
        terminal.capture('ui-installed-startup', ['Overview', 'Timing'])
        terminal.palette('Inspect timing paths')
        terminal.palette('Timing: Truncate to 6 decimal places')
        terminal.capture('ui-timing-lineage', ['recomputed completed/fail', 'original unavailable/unknown', '-3.099803'], timeout=60)
        os.write(terminal.master, b'\r')
        terminal.capture('ui-negative-path-detail', ['-3.099803'], timeout=30)
        proof.update(installed_ui_reader=True, typed_rows=193, negative_path_detail=True,
                     visible_original_unknown_and_recomputed_fail=True)
        save(output / 'receipt.json', proof)
        # Source-only PT6 preparation via the real configured application.
        prepared = rpc('preparation', ['Prepare', ['submission_key', 'source-' + uuid.uuid4().hex],
            ['selection', [('flow', 'stock_sram'), ('profile', 'balanced'), ('endpoint', 'timing'), ('assignments', [])]],
            ['expected_plan_identity', []]], label='preparation-request')
        prepared = until(lambda: rpc('preparation'), lambda s: field(s, 'latest') and
            field(field(s, 'latest')[0], 'outcome') not in ('Building', 'Emitting'), 'normal-source-preparation', timeout=180)
        latest = field(prepared, 'latest')[0]
        assert field(latest, 'outcome') == 'Completed'
        assert field(latest, 'source_root') == str(ROOT)
        bundle = field(field(latest, 'bundle')[0], 'output_dir')
        rpc(operation=['Resources', ['Load', ['target', ['Bundle', bundle]], ['refresh', 'true']]], label='resource-bundle-query')
        snapshot = until(lambda: rpc(), lambda s: field(s, 'resources') and any(field(row, 'id') == 'program'
            for i in field(field(s, 'resources')[0], 'indexes') for row in field(i, 'rows')), 'source-resources')
        os.write(terminal.master, b'\x1b')
        terminal.drain(.3)
        terminal.palette('Inspect resources (open Resources workspace)')
        terminal.palette('Resources: Import emitted bundle')
        os.write(terminal.master, bundle.encode() + b'\r')
        terminal.capture('ui-source-resources', ['Emitted bundle', 'program', 'RM_IHPSG13_1P_256x16_c2_bm_bist'], timeout=60)
        proof.update(pt6_normal_preparation=True, pt6_source_bundle=bundle, pt6_installed_ui_resources=True)
        terminal.close()
        terminal = None
        # Two bounded real cancel probes, each tied to a provider request under
        # this daemon. Never signal a discovered PID; Cancel is the public API.
        rpc('simulation', 'Discover', label='simulation-discover')
        discovered = until(lambda: rpc('simulation'), lambda s: field(s, 'discovery_digest') and
            not field(s, 'discovery_error'), 'simulation-catalog')
        digest = field(discovered, 'discovery_digest')[0]
        for suite, case, label in (('pt3b-serial-loader', 'exact-implementation', 'serial-vvp'),
                                    ('protemu-event-response', 'exact', 'nested-event-producer')):
            launched = rpc('simulation', ['Launch', ['submission_key', 'cancel-' + uuid.uuid4().hex],
                ['discovery_digest', digest], ['selection', [('suite', suite), ('cases', [case]), ('seed', '0'),
                    ('parameters', []), ('asic_inputs', [])]]], label=label + '-launch')
            sim_attempt = field(field(launched, 'detail')[0], 'id')
            deadline = time.monotonic() + 30
            captured = None
            while time.monotonic() < deadline:
                for candidate in descendants(daemon.pid):
                    if not any(arg.endswith('/pt3b_provider.py') for arg in candidate['argv']) or '--request' not in candidate['argv']:
                        continue
                    request = Path(candidate['argv'][candidate['argv'].index('--request') + 1])
                    try:
                        if dict(parse(request.read_text()))['attempt_id'] != sim_attempt:
                            continue
                    except (OSError, ValueError):
                        continue
                    tree = descendants(candidate['pid'])
                    if label == 'serial-vvp':
                        found = any(p['argv'] and Path(p['argv'][0]).name == 'vvp' and '+PT3B_EXPECT_MISMATCH' not in p['argv'] for p in tree)
                    else:
                        producers = [p for p in tree if any(a.endswith('/produce_event_response.py') for a in p['argv'])]
                        found = any(descendants(p['pid']) for p in producers)
                    if found:
                        captured = [candidate, *tree]
                        break
                if captured:
                    break
                time.sleep(.002)
            assert captured, label + ': no active requested child observed; refusing a manufactured cancellation proof'
            save(output / (label + '-live-processes.json'), captured)
            rpc('simulation', ['Cancel', sim_attempt], label=label + '-cancel')
            observed = until(lambda: rpc('simulation', ['Observe', sim_attempt]),
                lambda s: field(field(s, 'detail')[0], 'lifecycle') not in ('Queued', 'Running'), label + '-terminal', timeout=30)
            cancelled = field(observed, 'detail')[0]
            assert field(cancelled, 'lifecycle') == 'Cancelled' and field(cancelled, 'outcome') == 'Incomplete'
            deadline = time.monotonic() + 10
            while any(same_process(p) for p in captured) and time.monotonic() < deadline:
                time.sleep(.05)
            assert not any(same_process(p) for p in captured), label + ': captured descendant survives cancellation'
            proof['cancellations'].append(dict(case=case, suite=suite, attempt=sim_attempt, observed_native_child=True,
                lifecycle='Cancelled', outcome='Incomplete', captured_processes_reaped=True,
                evidence=str(output / (label + '-live-processes.json'))))
            save(output / 'receipt.json', proof)
        assert all(sha(Path(path)) == digest for path, digest in before.items()), 'retained journal changed'
        assert {str(p): sha(p) for p in (ROOT / '.workbench').glob('*.sexp')} == config_before
        proof.update(status='passed', journal_and_original_unchanged=True, normal_configs_unchanged=True)
    except BaseException as error:
        proof.update(status='failed', error=type(error).__name__ + ': ' + str(error))
        raise
    finally:
        if terminal is not None:
            terminal.close()
        if http is not None:
            save(output / 'final-http.json', http.history)
        if daemon is not None and daemon.poll() is None:
            daemon.terminate()
            try:
                daemon.wait(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(daemon.pid, signal.SIGKILL)
                daemon.wait(timeout=10)
        proof['daemon_reaped'] = daemon is None or daemon.poll() is not None
        save(output / 'receipt.json', proof)
        print(json.dumps(proof, indent=2), flush=True)


if __name__ == '__main__':
    main()
