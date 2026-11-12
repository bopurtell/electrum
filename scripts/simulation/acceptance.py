#!/usr/bin/env python3
"""Real installed-provider, public HTTP and production PTY acceptance. No EDA.

Starts/stops only its foreground normal Workbench daemon and attached client.
Requires a granted source/simulation slot and already qualified installation.
The two direct negative probes are explicit comparison-flip/tool-launch controls,
not advertised catalog cases or claims of hardware fault injection.
"""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
import uuid

sys.dont_write_bytecode = True
import prepare
import pt3b_provider as provider
from fs2_wire import parse, sexp

ROOT = Path(__file__).resolve().parents[2]
WB = ROOT.parent / 'hardcaml_workbench'
sys.path.insert(0, str(WB / 'demo/synthetic_flow'))
from http_client import Client, field
sys.path.insert(0, str(WB / 'test'))
from support.terminal import Terminal as SharedTerminal


class Terminal(SharedTerminal):
    def palette(self, title):
        for key in (b' ', b'c', b'c'):
            os.write(self.master, key)
            self.drain(.12)
        os.write(self.master, title.encode())
        self.drain(.2)
        self.capture('palette-' + str(time.time_ns()), ['COMMAND PALETTE'], absent=['No matching commands'])
        os.write(self.master, b'\r')
        self.drain(.5)

    def testing_catalog(self):
        self.palette('Switch to Testing')
        for _ in range(12):
            screen = self.drain(.15)
            if 'simulation catalog' in screen.splitlines()[-1]:
                self.save('ui-testing-catalog-focus', screen)
                return
            os.write(self.master, b'\t')
        raise AssertionError('could not focus actual Testing catalog')


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def until(action, predicate, timeout=180):
    deadline = time.monotonic() + timeout
    while True:
        value = action()
        if predicate(value):
            return value
        if time.monotonic() >= deadline:
            raise TimeoutError('acceptance polling deadline: ' + sexp(value)[:3000])
        time.sleep(.1)


def loaded(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def direct_controls(selection, install, output):
    installed = loaded(Path(install['generation']) / 'pt3b_provider.py', 'accepted_installed_provider')
    prefix = [sys.executable, '-B', str(Path(install['generation']) / 'pt3b_provider.py'),
              '--manifest', selection['manifest']]
    discovery = subprocess.check_output(prefix + ['discover', '--protocol-version', '1'], cwd=ROOT, timeout=30)
    (output / 'installed-discovery.sexp').write_bytes(discovery)
    assert [dict(s)['id'] for s in dict(parse(discovery.decode()))['suites']] == list(provider.SUITES)
    for label in ('semantic-comparison-flip', 'tool-launch-error'):
        directory = output / label
        directory.mkdir()
        artifacts = directory / 'artifacts'
        artifacts.mkdir()
        request, events = directory / 'request.sexp', directory / 'events.sexp'
        events.touch()
        request.write_text(sexp([('protocol_version', 1), ('attempt_id', label), ('selection', [
            ('suite', provider.SUITE), ('cases', ['exact-implementation']), ('seed', 0),
            ('parameters', []), ('asic_inputs', [])])]) + '\n')
        def command(argv, cwd, name, **kwargs):
            args = list(argv)
            if label == 'semantic-comparison-flip' and cwd.name == 'positive':
                args.append('+PT3B_EXPECT_MISMATCH')
            elif label == 'tool-launch-error' and name == 'compile':
                args[0] = str(directory / 'deliberately-absent-iverilog')
            return installed.command(args, cwd, name, **kwargs)
        def runner(value, case, attempt, path):
            return installed.run_case(value, case, attempt, path, run_command=command)
        code = installed.run_request(Path(selection['manifest']), request, events, artifacts, runner=runner)
        payloads = [dict(parse(line))['payload'] for line in events.read_text().splitlines()]
        expected = 0 if label == 'semantic-comparison-flip' else 2
        assert code == expected
        if code == 0:
            assert payloads[-1] == ['Finished', 'Failed']
        else:
            assert not any(isinstance(p, list) and p[0] in ('Finished', 'Case_finished') for p in payloads)
        write(directory / 'control.json', dict(exit_code=code, actual_native_execution=code == 0,
            scope='explicit adapter control; no bench/source edits; not a public catalog case'))


def main():
    selection, install = prepare.verify_current()
    output = ROOT / '_flow_results/workbench/acceptance' / uuid.uuid4().hex
    output.mkdir(parents=True)
    print('Acceptance evidence: ' + str(output), flush=True)
    receipt = dict(status='running', evidence=str(output), installation=selection,
                   source_and_simulation_only=True, physical_eda=False)
    write(output / 'receipt.json', receipt)
    http, terminal, daemon = None, None, None
    try:
        direct_controls(selection, install, output)
        tools = json.loads(Path(os.environ['PROTEMU_TOOLS_RECEIPT']).read_text())
        prefix = Path(tools['prefix'])
        environment = dict(os.environ, TERM='xterm-256color', OMP_NUM_THREADS='1',
                           OPENBLAS_NUM_THREADS='1', PYTHONDONTWRITEBYTECODE='1')
        # Normal project wrapper and persistent normal state, not a cloned project.
        discovery_path = ROOT / '.dev/workbench/discovery/daemon.sexp'
        started = time.time_ns()
        with (output / 'daemon.stdout').open('xb') as out, (output / 'daemon.stderr').open('xb') as err:
            daemon = subprocess.Popen(['bash', str(ROOT / 'scripts/workbench.sh'), 'daemon'], cwd=ROOT,
                                      env=environment, stdout=out, stderr=err)
        deadline = time.monotonic() + 30
        while True:
            if discovery_path.exists() and discovery_path.stat().st_mtime_ns >= started:
                metadata = dict(parse(discovery_path.read_text()))
                if int(metadata['pid']) == daemon.pid:
                    break
            assert daemon.poll() is None, 'normal daemon failed; inspect retained logs'
            assert time.monotonic() < deadline, 'normal daemon readiness timeout'
            time.sleep(.05)
        write(output / 'normal-daemon.json', metadata)
        http = Client(metadata['endpoint'], ROOT)
        def rpc(domain='simulation', operation='Get', wait=False):
            return http.rpc(operation if isinstance(operation, str) else sexp(operation), domain=domain, wait=wait)
        rpc(operation='Discover')
        discovered = until(lambda: rpc(), lambda s: bool(field(s, 'discovery_digest')) and not field(s, 'discovery_job'))
        assert not field(discovered, 'discovery_error')
        write(output / 'discovery.json', discovered)
        digest = field(discovered, 'discovery_digest')[0]
        def launch(suite, cases):
            snap = rpc(operation=['Launch', ['submission_key', 'acceptance-' + uuid.uuid4().hex],
                ['discovery_digest', digest], ['selection', [('suite', suite), ('cases', cases),
                    ('seed', '0'), ('parameters', []), ('asic_inputs', [])]]])
            attempt = field(field(snap, 'detail')[0], 'id')
            result = until(lambda: rpc(operation=['Observe', attempt]),
                lambda s: field(field(s, 'detail')[0], 'lifecycle') in ('Finished', 'Cancelled', 'Interrupted'), timeout=600)
            detail = field(result, 'detail')[0]
            write(output / (suite + '-detail.json'), detail)
            assert field(detail, 'outcome') == 'Passed', sexp(detail)[:5000]
            return detail
        serial = launch(provider.SUITE, ['exact-implementation'])
        event = launch(provider.EVENT_SUITE, ['flops', 'exact'])
        def export(detail, artifact):
            assert field(artifact, 'availability') == 'Available', sexp(artifact)
            attempt = field(detail, 'id')
            digest = field(artifact, 'sha256')[0]
            result = bytearray()
            while True:
                snap = rpc(operation=['Read_artifact_bytes', ['attempt_id', attempt], ['artifact_id', field(artifact, 'id')],
                    ['sha256', digest], ['offset', len(result)], ['limit', 65536]])
                page = field(snap, 'byte_page')[0]
                result.extend(bytes.fromhex(field(page, 'bytes_hex')))
                if field(page, 'eof') == 'true':
                    break
            assert hashlib.sha256(result).hexdigest() == digest
            return bytes(result)
        transported = output / 'transported'
        transported.mkdir()
        counts = {}
        for detail in (serial, event):
            case_dir = transported / field(detail, 'id')
            case_dir.mkdir()
            count = 0
            for index, artifact in enumerate(field(detail, 'artifacts')):
                label = field(artifact, 'label')
                is_comparison = label == 'Verified project-owned Flops / Exact comparison'
                if is_comparison or label.endswith(('.vcd', 'result.json', 'inspection.json')):
                    data = export(detail, artifact)
                    suffix = '.vcd' if label.endswith('.vcd') else '.json'
                    (case_dir / (str(index) + suffix)).write_bytes(data)
                    if suffix == '.vcd':
                        assert b'$enddefinitions' in data
                        count += 1
                    if is_comparison:
                        comparison = json.loads(data)
                        assert comparison['attempt_id'] == field(detail, 'id')
                        assert comparison['comparison']['status'] == 'comparable'
                        assert comparison['comparison']['right_minus_left_response_ticks'] == [0] * 10
                        write(output / 'verified-event-comparison.json', comparison)
            counts[field(detail, 'id')] = count
        assert (output / 'verified-event-comparison.json').is_file()
        assert sorted(counts.values()) == [2, 20], counts
        # Native public client, same root/endpoint/environment as the RPC probes.
        plain = subprocess.run([str(prefix / 'bin/hardcaml-workbench'), '--connect', metadata['endpoint'],
            '--project-root', str(ROOT), '--plain'], cwd=ROOT, env=environment, capture_output=True, timeout=30)
        (output / 'client-plain.stdout').write_bytes(plain.stdout)
        (output / 'client-plain.stderr').write_bytes(plain.stderr)
        assert plain.returncode == 0
        # Integrated source bundle preparation: app builds its declared target at
        # the installed adapter's bounded -j6, then emits the stock SRAM plan.
        prepared = rpc('preparation', ['Prepare', ['submission_key', 'source-' + uuid.uuid4().hex],
            ['selection', [('flow', 'stock_sram'), ('profile', 'balanced'), ('endpoint', 'timing'), ('assignments', [])]],
            ['expected_plan_identity', []]])
        prepared = until(lambda: rpc('preparation'), lambda s: field(s, 'latest') and
            field(field(s, 'latest')[0], 'outcome') not in ('Building', 'Emitting'), timeout=180)
        write(output / 'normal-preparation.json', prepared)
        actual = field(prepared, 'latest')[0]
        assert field(actual, 'outcome') == 'Completed', sexp(actual)[:5000]
        bundle = field(field(actual, 'bundle')[0], 'output_dir')
        resources = rpc('asic', ['Resources', ['Load', ['target', ['Bundle', bundle]], ['refresh', 'true']]], wait=True)
        write(output / 'normal-resources.json', resources)
        resource_view = field(resources, 'resources')[0]
        assert field(field(resource_view, 'sources')[0], 'freshness') == 'Validated'
        rows = field(field(resource_view, 'indexes')[0], 'rows')
        program = next(row for row in rows if field(row, 'id') == 'program')
        assert field(program, 'requirement') == 'exact'
        assert field(program, 'implementation') == 'RM_IHPSG13_1P_256x16_c2_bm_bist'
        assert field(program, 'synthesis') == field(program, 'final') == 'unavailable'
        # Actual durable Resource_preparation + installed preparation-inspect.
        resource = subprocess.run(['bash', str(ROOT / 'scripts/workbench.sh'), 'resource-prepare', '--flow', 'stock_sram'],
                                  cwd=ROOT, env=environment, capture_output=True, check=True, timeout=120)
        (output / 'resource-prepare.jsonl').write_bytes(resource.stdout)
        records = [json.loads(line) for line in resource.stdout.decode().splitlines()]
        exact_attempt = records[-1]['attempt']
        inspected = subprocess.run(['bash', str(ROOT / 'scripts/workbench.sh'), 'preparation-inspect', exact_attempt],
                                   cwd=ROOT, env=environment, capture_output=True, check=True, timeout=30)
        (output / 'preparation-inspect.json').write_bytes(inspected.stdout)
        inspection = json.loads(inspected.stdout)
        assert inspection['operation']['status'] == 'completed'
        assert inspection['operation']['request']['source_root'] == str(ROOT)
        assert inspection['operation']['request']['flow'] == 'stock_sram'
        receipt.update(public_rpc=True, normal_native_client=True, serial_attempt=field(serial, 'id'),
            event_attempt=field(event, 'id'), hash_verified_vcd_counts=counts,
            source_bundle=bundle, resource_preparation_attempt=exact_attempt,
            installed_preparation_inspect=True, generic_event_comparison=True)
        write(output / 'receipt.json', receipt)
        session = type('Session', (), dict(args=type('Args', (), dict(client=prefix / 'bin/hardcaml-workbench'))(),
            url=metadata['endpoint'], root=ROOT, env=environment, evidence=output))()
        terminal = Terminal(session)
        terminal.capture('ui-startup', ['Overview', 'Testing'])
        terminal.testing_catalog()
        terminal.capture('ui-testing', ['Testing'])
        terminal.palette('Reopen ' + field(serial, 'id'))
        terminal.palette('Simulation: Select case exact-implementation')
        wave = next(a for a in field(serial, 'artifacts') if field(a, 'label').endswith('positive/waveform.vcd'))
        terminal.palette('Simulation: Open embedded waveform ' + field(wave, 'label'))
        terminal.capture('ui-serial-waveform', ['Waveform', 'Cursor 0 ticks', 'clock_i'])
        os.write(terminal.master, b'\x1b')
        terminal.drain(.3)
        terminal.testing_catalog()
        terminal.palette('Reopen ' + field(event, 'id'))
        terminal.palette('Simulation: Select case exact')
        wave = next(a for a in field(event, 'artifacts') if field(a, 'case_id') == ['exact'] and
                    field(a, 'label').endswith('phase-0/waveform.vcd'))
        terminal.palette('Simulation: Open embedded waveform ' + field(wave, 'label'))
        terminal.capture('ui-event-waveform', ['Waveform', 'Cursor 0 ticks', 'clock_i'])
        receipt.update(status='passed', production_pty=True, embedded_serial_and_event_vcd=True)
    except BaseException as error:
        receipt.update(status='failed', error=type(error).__name__ + ': ' + str(error))
        raise
    finally:
        if terminal is not None:
            terminal.close()
        if http is not None:
            write(output / 'http.json', http.history)
        if daemon is not None and daemon.poll() is None:
            daemon.terminate()
            try:
                daemon.wait(timeout=10)
            except subprocess.TimeoutExpired:
                daemon.kill()
                daemon.wait(timeout=10)
        write(output / 'receipt.json', receipt)
        print(json.dumps(receipt, indent=2), flush=True)


def readback(previous):
    """Read exact persisted attempts after daemon restart. No builds/case launches."""
    receipt = json.loads((previous / 'receipt.json').read_text())
    assert receipt['status'] == 'passed' and receipt['public_rpc'] and receipt['production_pty']
    output = previous / 'readbacks' / uuid.uuid4().hex
    output.mkdir(parents=True)
    http, daemon = None, None
    proof = dict(status='running', source_acceptance=str(previous), read_only_no_case_launch=True)
    try:
        discovery = ROOT / '.dev/workbench/discovery/daemon.sexp'
        started = time.time_ns()
        with (output / 'daemon.stdout').open('xb') as out, (output / 'daemon.stderr').open('xb') as err:
            daemon = subprocess.Popen(['bash', str(ROOT / 'scripts/workbench.sh'), 'daemon'],
                                      cwd=ROOT, stdout=out, stderr=err)
        deadline = time.monotonic() + 30
        while True:
            if discovery.exists() and discovery.stat().st_mtime_ns >= started:
                metadata = dict(parse(discovery.read_text()))
                if int(metadata['pid']) == daemon.pid:
                    break
            assert daemon.poll() is None and time.monotonic() < deadline
            time.sleep(.05)
        http = Client(metadata['endpoint'], ROOT)
        def rpc(operation):
            return http.rpc(sexp(operation), domain='simulation', wait=False)
        for key in ('serial_attempt', 'event_attempt'):
            detail = field(rpc(['Observe', receipt[key]]), 'detail')[0]
            assert field(detail, 'outcome') == 'Passed'
            write(output / (key + '.json'), detail)
            if key == 'event_attempt':
                artifact = next(a for a in field(detail, 'artifacts') if
                    field(a, 'label') == 'Verified project-owned Flops / Exact comparison')
                assert field(artifact, 'availability') == 'Available'
                digest = field(artifact, 'sha256')[0]
                data = bytearray()
                while True:
                    page = field(rpc(['Read_artifact_bytes', ['attempt_id', receipt[key]],
                        ['artifact_id', field(artifact, 'id')], ['sha256', digest], ['offset', len(data)],
                        ['limit', 65536]]), 'byte_page')[0]
                    data.extend(bytes.fromhex(field(page, 'bytes_hex')))
                    if field(page, 'eof') == 'true':
                        break
                assert hashlib.sha256(data).hexdigest() == digest
                compared = json.loads(data)
                assert compared['attempt_id'] == receipt[key]
                assert compared['comparison']['status'] == 'comparable'
                assert compared['comparison']['right_minus_left_response_ticks'] == [0] * 10
                assert compared['comparison']['physical_area_speed_delta'] is None
                (output / 'verified-event-comparison.json').write_bytes(data)
                proof.update(event_attempt=receipt[key], comparison_artifact_sha256=digest,
                             ten_zero_response_tick_deltas=True)
        proof.update(status='passed', durable_simulation_history_reopened=True)
    except BaseException as error:
        proof.update(status='failed', error=str(error))
        raise
    finally:
        if http is not None:
            write(output / 'http.json', http.history)
        if daemon is not None and daemon.poll() is None:
            daemon.terminate()
            daemon.wait(timeout=10)
        write(output / 'receipt.json', proof)
        print(str(output), flush=True)


if __name__ == '__main__':
    if len(sys.argv) == 3 and sys.argv[1] == '--readback':
        readback(Path(sys.argv[2]).resolve(strict=True))
    else:
        main()
