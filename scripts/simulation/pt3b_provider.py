#!/usr/bin/env python3
"""Installed, build-free FS2v1 serial and event-response suite adapter.

Serial cases run one source-role replay and its existing negative oracle self-check.
Event cases delegate to the captured project producer and public verified readers.
Only benchmark assertion failures are semantic Failed. Infrastructure/protocol/
timeout/source-drift failures leave an incomplete stream and exit nonzero.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import signal
import stat
import subprocess
import sys
import time

sys.dont_write_bytecode = True
from fs2_wire import Events, parse, record, sexp

SUITE = 'pt3b-serial-loader'
CASES = {
    'flops-behavioral': ('flops', 'simulation_sources'),
    'flops-implementation': ('flops', 'synthesis_sources'),
    'exact-behavioral': ('exact', 'simulation_sources'),
    'exact-implementation': ('exact', 'synthesis_sources'),
}
EVENT_SUITE = 'protemu-event-response'
EVENT_CASES = {
    'behavioral': ('flops', 'behavioral'),
    'flops': ('flops', 'implementation'),
    'exact': ('exact', 'implementation'),
}
SUITES = {SUITE: CASES, EVENT_SUITE: EVENT_CASES}
LIMIT = 1024 * 1024
FILE_LIMIT = 32 * LIMIT
LOG_LIMIT = 2 * LIMIT


class InfrastructureError(RuntimeError):
    pass


class Cancelled(BaseException):
    pass


def require(condition, message):
    if not condition:
        raise InfrastructureError(message)


def regular(path):
    path = Path(path)
    require(path.parent.resolve() == path.parent and stat.S_ISREG(path.lstat().st_mode),
            'expected independent regular file: ' + str(path))
    return path


def read(path, limit=LIMIT):
    with regular(path).open('rb') as stream:
        data = stream.read(limit + 1)
    require(len(data) <= limit, 'input byte bound exceeded: ' + str(path))
    return data


def sha(path):
    hasher = hashlib.sha256()
    with regular(path).open('rb') as stream:
        for block in iter(lambda: stream.read(LIMIT), b''):
            hasher.update(block)
    return hasher.hexdigest()


def local(root, relative):
    path = Path(relative)
    require(not path.is_absolute() and path.parts and
            all(p not in ('.', '..') for p in path.parts) and str(path) == relative,
            'unsafe installation member')
    return regular(root / path)


def catalog_digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode()).hexdigest()


def catalog_matrix(value):
    fields = record(parse(sexp(value)), ('protocol_version', 'suites'))
    require(fields['protocol_version'] == '1' and isinstance(fields['suites'], list), 'unsupported stored FS2 catalog schema')
    result = {}
    for raw in fields['suites']:
        suite = record(raw, ('id', 'label', 'cases', 'parameters', 'default_seed'))
        name = suite['id']
        require(isinstance(name, str) and re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]{0,127}', name) and name not in result,
                'invalid/duplicate stored suite')
        cases = [record(case, ('id', 'label'))['id'] for case in suite['cases']]
        require(cases and all(isinstance(case, str) and re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]{0,127}', case) for case in cases)
                and len(set(cases)) == len(cases), 'invalid/duplicate stored cases')
        result[name] = cases
    require(result, 'empty stored catalog cannot establish qualification')
    return result


def frozen_generation(path, *, qualified=True):
    """Validate frozen bytes and THEIR schema/catalog, without current source/tools.

    Used for explicit refresh across catalog revisions. It never executes an old
    provider. Schema-1 receipts without a catalog retain their qualified matrix in
    qualification.json; schema 2 seals the complete public discovery declaration.
    """
    path = regular(Path(path).absolute())
    value = json.loads(read(path, 8 * LIMIT))
    require(value['contract'] == 'protemu.fs2-pt3b-install' and type(value['schema_version']) is int
            and value['schema_version'] in (1, 2),
            'unsupported simulation installation')
    require(Path(value['generation']) == path.parent, 'installation moved')
    require(not qualified or value['checks_passed'] is True,
            'simulation installation is not qualified; obtain a test slot and prepare it')
    matrix = None
    if value['schema_version'] == 2:
        require(value['catalog_schema_version'] == 1 and
                catalog_digest(value['catalog']) == value['catalog_sha256'], 'stored catalog changed')
        matrix = catalog_matrix(value['catalog'])
    if qualified:
        proof = local(path.parent, 'qualification.json')
        require(sha(proof) == value['qualification_sha256'], 'qualification receipt changed')
        qualification = json.loads(read(proof, 8 * LIMIT))
        require(type(qualification.get('schema_version', 1)) is int and
                qualification.get('schema_version', 1) in (1, 2), 'unsupported qualification schema')
        stored = qualification.get('suites')
        if stored is None and value['schema_version'] == 1 and isinstance(qualification.get('cases'), list):
            stored = {'pt3b-serial-loader': qualification['cases']}
        require(isinstance(stored, dict) and stored and all(isinstance(cases, list) and cases and
                len(cases) == len(set(cases)) and all(isinstance(case, str) for case in cases)
                for cases in stored.values()), 'invalid stored qualified catalog')
        require(qualification['status'] == 'passed' and (matrix is None or stored == matrix),
                'qualification differs from its stored catalog')
        for member, digest in qualification['sha256'].items():
            require(sha(local(path.parent, member)) == digest, 'retained qualification input/result changed')
        matrix = stored
    for name, expected in value['files'].items():
        require(sha(local(path.parent, name)) == expected, 'installed simulation input changed: ' + name)
    return value, matrix


def validate_install(path, *, qualified=True, check_sources=True):
    value, matrix = frozen_generation(path, qualified=qualified)
    if qualified:
        require(matrix == {suite: list(cases) for suite, cases in SUITES.items()},
                'complete serial and event-response real qualification required')
        if value['schema_version'] == 2:
            require(catalog_digest(catalog()) == value['catalog_sha256'], 'current provider catalog differs from qualified catalog')
    require(set(value['bundles']) == {'flops', 'exact'}, 'wrong PT3b bundle matrix')
    require(isinstance(value['fixed_variant_identity'], str) and
            re.fullmatch(r'[0-9a-f]{64}', value['fixed_variant_identity']),
            'missing actual fixed-loader association')
    if check_sources:
        for name, expected in value['source_sha256'].items():
            require(sha(local(Path(value['project_root']), name)) == expected,
                    'stale simulation source; explicitly prepare again: ' + name)
        if 'event_source_sha256' in value:
            require(event_source_inventory(Path(value['project_root'])) == value['event_source_sha256'],
                    'event source inventory changed; explicitly prepare again')
    for name, tool in value['tools'].items():
        require(sha(Path(tool['path'])) == tool['sha256'], 'simulator tool changed: ' + name)
    return value


def event_source_inventory(root):
    paths = ('ip', 'spec/isa', 'firmware/examples', 'asic/rtl', 'asic/verif/workloads', 'verif/reference/model')
    return {str(p.relative_to(root)): sha(p) for name in paths for p in sorted((root / name).rglob('*'))
            if p.is_file() and (p.suffix in ('.ml', '.mli', '.py', '.v') or p.name == 'dune')}


def catalog():
    labels = {SUITE: 'PT3b serial loader / fixed unchanged loader-v1',
              EVENT_SUITE: 'Event response / fixed production core + RAM / project-owned evidence'}
    return [('protocol_version', 1), ('suites', [[
        ('id', suite), ('label', labels[suite]),
        ('cases', [[('id', case), ('label', case.replace('-', ' / '))] for case in cases]),
        ('parameters', []), ('default_seed', 0)] for suite, cases in SUITES.items()])]


def validate_request(value):
    req = record(value, ('protocol_version', 'attempt_id', 'selection'))
    require(req['protocol_version'] == '1' and isinstance(req['attempt_id'], str) and
            re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,127}', req['attempt_id']),
            'invalid request identity/version')
    selection = record(req['selection'], ('suite', 'cases', 'seed', 'parameters', 'asic_inputs'))
    cases = selection['cases']
    supported = SUITES.get(selection['suite']) if isinstance(selection['suite'], str) else None
    require(supported is not None and isinstance(cases, list) and cases and
            all(isinstance(c, str) and c in supported for c in cases) and len(set(cases)) == len(cases),
            'select unique declared cases from one supported suite')
    require(selection['seed'] == '0', 'directed PT3b stimulus supports only declarative seed 0')
    require(selection['parameters'] == [] and selection['asic_inputs'] == [],
            'serial replay has no shape controls, runtime parameters or ASIC evidence inputs')
    return req, selection


def command(argv, cwd, name, *, timeout, env=None, watch_tree=None):
    """One owned subprocess group, bounded wall time/output, always reaped.

    This runs tools only; it cannot invoke Dune, provisioning or a nested installer.
    The provider's signal handler unwinds this block and kills the owned group.
    """
    output, error = cwd / (name + '.stdout'), cwd / (name + '.stderr')
    started = time.monotonic()
    with output.open('xb') as out, error.open('xb') as err:
        process = subprocess.Popen(list(map(str, argv)), cwd=cwd, stdout=out, stderr=err,
                                   start_new_session=True, env=env)
        try:
            while process.poll() is None:
                require(time.monotonic() - started < timeout, name + ' wall timeout')
                for path in (output, error, cwd / 'waveform.vcd'):
                    if path.exists():
                        require(path.stat().st_size <= (FILE_LIMIT if path.suffix == '.vcd' else LOG_LIMIT),
                                name + ' output byte bound exceeded')
                if watch_tree is not None:
                    check_tree(watch_tree)
                time.sleep(.05)
        finally:
            if process.poll() is None:
                try:
                    os.killpg(process.pid, signal.SIGTERM)
                    try:
                        process.wait(timeout=3)
                    except subprocess.TimeoutExpired:
                        os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            process.wait()
    if watch_tree is not None:
        check_tree(watch_tree)
    for path in (output, error, cwd / 'waveform.vcd'):
        if path.exists():
            require(path.stat().st_size <= (FILE_LIMIT if path.suffix == '.vcd' else LOG_LIMIT),
                    name + ' output byte bound exceeded')
    stdout, stderr = read(output, LOG_LIMIT).decode('utf-8', 'replace'), read(error, LOG_LIMIT).decode('utf-8', 'replace')
    return dict(argv=list(map(str, argv)), cwd=str(cwd), exit_code=process.returncode,
                elapsed_host_seconds=time.monotonic() - started,
                stdout=output.name, stderr=error.name), stdout + stderr


def check_tree(root):
    total, count = 0, 0
    if not root.exists():
        return
    for path in root.rglob('*'):
        require(not path.is_symlink(), 'producer evidence contains a symlink')
        if path.is_file():
            count += 1
            size = path.stat().st_size
            require(count <= 4096 and size <= 64 * LIMIT, 'producer evidence file/count bound exceeded')
            total += size
            require(total <= 256 * LIMIT, 'producer evidence aggregate bound exceeded')


def event_adapter(install):
    path = local(Path(install['generation']), 'event_adapter.py')
    spec = importlib.util.spec_from_file_location('protemu_installed_event_adapter', path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def oracle_module(generation):
    spec = importlib.util.spec_from_file_location('pt3b_installed_oracle', generation / 'pt3b_oracle.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def waveform(path):
    regular(path)
    size = path.stat().st_size
    require(0 < size <= FILE_LIMIT, 'waveform missing/oversized')
    with path.open('rb') as stream:
        header = stream.read(65536)
        require(b'$enddefinitions' in header and b'$var' in header and b'$timescale' in header,
                'simulator did not produce a VCD header')
        timestamps = b'#' in header
        while not timestamps:
            block = stream.read(65536)
            if not block:
                break
            timestamps = b'#' in block
    require(timestamps, 'VCD contains no simulation timestamps')
    return dict(path=str(path), bytes=size, sha256=sha(path),
                scope='public package clock/reset/enable, serial and pin interface; functional, not timed')


def bench_failed(output, code, bench):
    # A vvp crash, missing plugin or loader error is not a failed DUT assertion.
    return code > 0 and re.search(r'^FATAL: ' + re.escape(str(bench)) + r':[0-9]+:', output, re.M) is not None


def serial_waveforms(directory, *, window_ps=100000000):
    original = directory / 'waveform.vcd'
    full = directory / 'waveform-full.vcd'
    require(not full.exists(), 'full waveform destination already exists')
    original.rename(full)
    full_record = waveform(full)
    full_record['scope'] = 'full positive replay public-interface VCD; may exceed embedded viewer change budget'
    last = None
    with full.open('rb') as source, original.open('xb') as destination:
        for line in source:
            if line.startswith(b'#'):
                timestamp = int(line[1:].strip())
                if timestamp > window_ps:
                    break
                last = timestamp
            destination.write(line)
    preview = waveform(original)
    preview.update(scope='initial public-interface VCD window only; full original retained separately',
        derivation=dict(kind='exact_byte_prefix', source_sha256=full_record['sha256'],
                        source_bytes=full_record['bytes'], retained_bytes=preview['bytes'],
                        limit_ps=window_ps, last_timestamp_ps=last, resampled=False))
    return preview, full_record


def run_case(install, case, attempt, directory, *, run_command=command):
    generation = Path(install['generation'])
    selection, role = CASES[case]
    bundle = install['bundles'][selection]
    manifest = json.loads(read(local(generation, bundle['manifest']), 8 * LIMIT))
    require(manifest['identity'] == bundle['identity'] and
            manifest['hardware_variant']['identity'] == install['fixed_variant_identity'],
            'bundle/hardware association differs from prepared installation')
    oracle = oracle_module(generation)
    models = [local(generation, p) for p in install['models']] if selection == 'exact' else []
    root = generation / bundle['directory']
    exact, defines, sources = oracle.replay_inputs(manifest, root, selection, role, models, ['LOADER_WRAPPER'])
    bench = local(generation, 'p3_loader_tb.v')
    trace = local(generation, 'serial_trace.v')
    directory.mkdir(exist_ok=False)
    result = dict(contract='protemu.pt3b-serial-result', schema_version=1, attempt_id=attempt,
                  case_id=case, selection=selection, source_role=role,
                  bundle_identity=manifest['identity'], hardware_variant=manifest['hardware_variant'],
                  bundle_manifest_sha256=sha(local(generation, bundle['manifest'])),
                  source_fence='pending',
                  vendor_functional=exact, seed='0', status='running', commands=[],
                  inputs=[dict(path=str(p), sha256=sha(p)) for p in [*sources, bench, trace]],
                  tools=install['tools'], scope='PT3b serial functional replay; no physical/timed acceptance')
    result['waveform_window'] = dict(start_ps=0, end_ps=100000000,
        coverage='initial 100 us only, or earlier bench termination; full-suite assertions/transcript still run')
    try:
        program = directory / 'replay.vvp'
        compile_result, output = run_command([install['tools']['iverilog']['path'], '-g2012', '-Wall',
            '-s', 'pt3b_trace', '-o', program, *['-D' + d for d in defines], *sources, bench, trace],
            directory, 'compile', timeout=120)
        result['commands'].append(compile_result)
        require(compile_result['exit_code'] == 0, 'Icarus compilation failed; inspect compile logs')
        positive = directory / 'positive'
        positive.mkdir()
        execution, output = run_command([install['tools']['vvp']['path'], '-N', program],
                                        positive, 'replay', timeout=300)
        result['commands'].append(execution)
        if bench_failed(output, execution['exit_code'], bench):
            result.update(status='design_failed', diagnostic='existing PT3b bench assertion failed')
            if (positive / 'waveform.vcd').exists():
                result['waveform'], result['full_waveform'] = serial_waveforms(positive)
            return result
        require(execution['exit_code'] == 0, 'vvp execution failed outside the PT3b assertion contract')
        try:
            observations = oracle.check_oracle(output, execution['exit_code'], 'loader')
            acceptance = oracle.check_loader(output, observations, 'exact' if exact else 'package')
        except ValueError as error:
            raise InfrastructureError('PT3b completion transcript invalid: ' + str(error)) from error
        preview, full = serial_waveforms(positive)
        result.update(observations=observations, acceptance=acceptance, waveform=preview, full_waveform=full)
        negative = directory / 'oracle-selfcheck'
        negative.mkdir()
        checked, output = run_command([install['tools']['vvp']['path'], '-N', program,
            '+PT3B_EXPECT_MISMATCH'], negative, 'replay', timeout=300)
        result['commands'].append(checked)
        require(bench_failed(output, checked['exit_code'], bench), 'negative oracle did not reach its bench assertion')
        try:
            oracle.check_oracle(output, checked['exit_code'], 'loader', negative=True)
        except ValueError as error:
            raise InfrastructureError('PT3b negative oracle self-check failed: ' + str(error)) from error
        result.update(status='passed', negative_oracle='expected comparison flip observed; no DUT fault injection')
        return result
    except (OSError, ValueError, InfrastructureError) as error:
        result.update(status='tool_error', diagnostic=str(error))
        return result
    finally:
        # Source bytes are checked by the outer install fence before terminal events.
        (directory / 'result.json').write_text(json.dumps(result, indent=2) + '\n')


def artifacts(events, case, directory, artifact_root):
    # Closed files only; the provider never changes an announced file afterwards.
    for path in sorted(directory.rglob('*')):
        if path.is_file() and path.suffix in ('.json', '.stdout', '.stderr'):
            events.artifact(case, str(path.relative_to(artifact_root)), 'report',
                            'application/json' if path.suffix == '.json' else 'text/plain')
    wave = directory / 'positive/waveform.vcd'
    if wave.exists():
        waveform(wave)
        events.artifact(case, str(wave.relative_to(artifact_root)), 'waveform', 'text/vcd')
    full = directory / 'positive/waveform-full.vcd'
    if full.exists():
        waveform(full)
        events.artifact(case, str(full.relative_to(artifact_root)), 'waveform', 'text/vcd')


def run_request(manifest_path, request, event_path, artifact_root, *, qualified=True, runner=None):
    install = validate_install(manifest_path, qualified=qualified)
    req, selection = validate_request(parse(read(request).decode()))
    artifact_root = Path(artifact_root).resolve(strict=True)
    require(artifact_root.is_dir() and not any(artifact_root.iterdir()), 'artifact directory must be empty')
    regular(event_path)
    require(event_path.stat().st_size == 0, 'events file must initially be empty')
    with event_path.open('a') as stream:
        events = Events(stream, req['attempt_id'])
        events.emit('Started')
        failed = False
        event = event_adapter(install) if selection['suite'] == EVENT_SUITE else None
        execute = runner or (event.run_case if event is not None else run_case)
        completed = {}
        for case in selection['cases']:
            events.emit(['Case_started', case])
            directory = artifact_root / case
            result = execute(install, case, req['attempt_id'], directory)
            if 'waveform' in result:
                result['waveform']['artifact_path'] = case + '/positive/waveform.vcd'
            if 'full_waveform' in result:
                result['full_waveform']['artifact_path'] = case + '/positive/waveform-full.vcd'
            if result['status'] != 'tool_error':
                try:
                    validate_install(manifest_path, qualified=qualified)
                    result['source_fence'] = 'verified'
                except (OSError, ValueError, KeyError, InfrastructureError) as error:
                    result.update(status='tool_error', source_fence='failed', diagnostic=str(error))
            (directory / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
            if event is None:
                artifacts(events, case, directory, artifact_root)
            else:
                event.artifacts(events, case, directory, artifact_root, result)
            if result['status'] == 'tool_error':
                print(case + ': ' + result['diagnostic'], file=sys.stderr, flush=True)
                return 2
            require(result['status'] in ('passed', 'design_failed'), 'runner returned no valid semantic outcome')
            failed |= result['status'] == 'design_failed'
            completed[case] = result
            events.emit(['Case_finished', [('case_id', case),
                ('status', 'Failed' if result['status'] == 'design_failed' else 'Passed'),
                ('message', [result['diagnostic']] if result['status'] == 'design_failed' else [])]])
        if event is not None and all(completed.get(case, {}).get('status') == 'passed' for case in ('flops', 'exact')):
            event.comparison(events, install, req['attempt_id'], completed, artifact_root)
        events.emit(['Finished', 'Failed' if failed else 'Passed'])
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
    parser.add_argument('--manifest', required=True, type=Path)
    parser.add_argument('operation', choices=('discover', 'run'))
    parser.add_argument('--protocol-version', choices=('1',), required=True)
    for name in ('request', 'events', 'artifact-dir'):
        parser.add_argument('--' + name, type=Path)
    args = parser.parse_args(argv)
    validate_install(args.manifest)
    if args.operation == 'discover':
        print(sexp(catalog()), flush=True)
        return 0
    require(all((args.request, args.events, args.artifact_dir)), 'run requires request/events/artifact-dir')
    return run_request(args.manifest, args.request, args.events, args.artifact_dir)


if __name__ == '__main__':
    def interrupt(signum, frame):
        raise Cancelled()
    signal.signal(signal.SIGTERM, interrupt)
    signal.signal(signal.SIGINT, interrupt)
    try:
        sys.exit(main())
    except Cancelled:
        sys.exit(130)
    except (OSError, ValueError, KeyError, RuntimeError) as error:
        print('PT3b provider: ' + str(error), file=sys.stderr)
        sys.exit(2)
