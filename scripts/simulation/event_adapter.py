"""FS2 adapter over the workload owner's producer and verified project readers.

This publishes generic JSON/trace artifacts, never ASIC Workload_result records.
The event design is core+RAM, not the loader package; no loader bundle identity
or hardware-variant association is invented for this independent producer.
"""
import importlib
import json
from pathlib import Path
import shutil
import sys
import uuid

import pt3b_provider as provider


def readers(install):
    source = Path(install['generation']) / install['event']['source_directory']
    sys.path.insert(0, str(source / 'asic/verif/workloads'))
    # Each adapter process owns one captured source generation. Cached modules
    # from another generation must not be silently used during qualification.
    for name in ('event_evidence', 'produce_event_response', 'event_response'):
        loaded = sys.modules.get(name)
        if loaded is not None and Path(loaded.__file__).parent != source / 'asic/verif/workloads':
            del sys.modules[name]
    return importlib.import_module('event_evidence')


def run_case(install, case, attempt, directory, *, run_command=None, evidence_readers=None):
    run_command = run_command or provider.command
    generation = Path(install['generation'])
    event = install['event']
    selection, role = provider.EVENT_CASES[case]
    directory.mkdir(exist_ok=False)
    retained = Path(event['results_root'])
    retained.mkdir(parents=True, exist_ok=True)
    output = retained / (attempt + '-' + case + '-' + uuid.uuid4().hex)
    result = dict(contract='electrum.fs2-event-attempt', schema_version=1,
                  attempt_id=attempt, case_id=case, seed='0', selection=selection, source_role=role,
                  status='running', source_fence='pending', retained_result=str(output / 'result.json'),
                  asic_workload_result=False, association='producer-owned hardware_assignment; no loader bundle association',
                  scope='digital functional event response; not package, physical, Fmax or analog timing evidence')
    try:
        producer = provider.local(generation, event['producer'])
        provider.local(generation, event['bench'])
        args = [sys.executable, '-B', producer, '--selection', selection, '--mode', role,
                '--output', output, '--pdk', generation / event['pdk_directory'],
                '--emitter', provider.local(generation, event['emitter']),
                '--reference', provider.local(generation, event['reference']), '--timeout', '120']
        execution, stdout = run_command(args, directory, 'producer', timeout=1800, watch_tree=output)
        result['command'] = execution
        raw_path = output / 'result.json'
        api = evidence_readers or readers(install)
        if raw_path.exists():
            result['producer_result_sha256'] = provider.sha(raw_path)
        if execution['exit_code'] != 0:
            # The producer's generic failed status also covers compilation and
            # reader errors. Only an actual HDL bench FATAL is a DUT/test failure.
            logs = [p for p in output.glob('command-*.stdout') if p.is_file()] if output.exists() else []
            design_failure = any(provider.bench_failed(provider.read(p, provider.LOG_LIMIT).decode('utf-8', 'replace'),
                                                      execution['exit_code'], output / 'sources/asic/verif/workloads/event_response_tb.v')
                                 for p in logs)
            if raw_path.exists():
                inspected = api.inspect(raw_path)
                provider.require(inspected['measurements'] is None,
                                 'failed producer exposed verified measurements')
                result['producer_result_sha256'] = inspected['source_digest']
                result['hardware_assignment'] = inspected['result']['hardware_assignment']
                (directory / 'inspection.json').write_text(json.dumps(inspected, indent=2) + '\n')
                exported = directory / 'evidence'
                exported.mkdir()
                shutil.copyfile(raw_path, exported / 'result.json')
                commands = output / 'commands.json'
                if commands.exists():
                    shutil.copyfile(commands, exported / 'commands.json')
                    entries = json.loads(provider.read(commands, 2 * provider.LIMIT))
                    failed = [i for i, entry in enumerate(entries) if entry.get('exit_code') not in (None, 0)]
                    if failed:
                        for suffix in ('stdout', 'stderr'):
                            path = provider.local(output, f'command-{failed[-1]:03d}.' + suffix)
                            shutil.copyfile(path, exported / ('failed-command.' + suffix))
            if design_failure:
                result.update(status='design_failed', diagnostic='event-response HDL bench assertion failed; inspect retained producer evidence')
            else:
                result.update(status='tool_error', diagnostic='event producer failed before verified completion; inspect producer logs')
            return result
        inspected = api.inspect(raw_path)
        raw = inspected['result']
        provider.require(raw['status'] == 'completed' and inspected['measurements'] is not None,
                         'producer exited successfully without verified measurements')
        provider.require(raw['selection'] == selection and raw['source_role'] == role and
                         raw.get('asic_workload_result') is False, 'producer result selection/contract differs')
        for key in ('emitter', 'reference'):
            provider.require(raw['tools'][key]['sha256'] == provider.sha(generation / event[key]),
                             'producer used a different captured ' + key)
        for key in ('iverilog', 'vvp'):
            provider.require(raw['tools'][key]['sha256'] == install['tools'][key]['sha256'],
                             'producer used a different simulator tool')
        provider.require(inspected['source_digest'] == provider.sha(raw_path), 'inspected producer result changed')
        (directory / 'inspection.json').write_text(json.dumps(inspected, indent=2) + '\n')
        exported = directory / 'evidence'
        exported.mkdir()
        for name in ('result.json', 'capture.json', 'reference.json', 'workload.json', 'commands.json'):
            source = provider.local(output, name)
            shutil.copyfile(source, exported / name)
        phases = []
        for phase in range(10):
            name = 'phase-' + str(phase)
            (exported / name).mkdir()
            for filename in ('waveform.vcd', 'raw.trace'):
                source = provider.local(output, name + '/' + filename)
                shutil.copyfile(source, exported / name / filename)
                provider.require(provider.sha(source) == provider.sha(exported / name / filename), 'phase artifact changed during copy')
            phases.append(dict(phase=phase, artifact_path=case + '/evidence/' + name + '/waveform.vcd',
                               sha256=provider.sha(exported / name / 'waveform.vcd')))
        # Recheck the original result through its public reader after copying.
        provider.require(api.inspect(raw_path)['source_digest'] == inspected['source_digest'],
                         'event evidence changed during export')
        result.update(status='passed', producer_result_sha256=inspected['source_digest'],
                      hardware_assignment=raw['hardware_assignment'], phase_waveforms=phases,
                      measurements=inspected['measurements'])
        return result
    except (OSError, ValueError, KeyError, RuntimeError) as error:
        result.update(status='tool_error', diagnostic=str(error))
        return result
    finally:
        (directory / 'result.json').write_text(json.dumps(result, indent=2) + '\n')


def artifacts(events, case, directory, artifact_root, result):
    paths = [p for p in sorted(directory.rglob('*')) if p.is_file() and
             p.suffix in ('.json', '.stdout', '.stderr', '.trace', '.vcd')]
    count = getattr(events, '_event_exports', 0) + len(paths)
    size = getattr(events, '_event_export_bytes', 0) + sum(p.stat().st_size for p in paths)
    provider.require(count <= 127 and size <= 255 * provider.LIMIT, 'event attempt export budget exceeded')
    events._event_exports, events._event_export_bytes = count, size
    for path in paths:
        provider.require(path.stat().st_size <= 32 * provider.LIMIT, 'event export file bound exceeded')
        relative = str(path.relative_to(artifact_root))
        if path.suffix == '.vcd':
            provider.waveform(path)
            events.artifact(case, relative, 'waveform', 'text/vcd')
        else:
            events.artifact(case, relative, 'report', 'application/json' if path.suffix == '.json' else 'text/plain')


def comparison(events, install, attempt, completed, artifact_root, *, evidence_readers=None):
    api = evidence_readers or readers(install)
    left, right = (Path(completed[c]['retained_result']) for c in ('flops', 'exact'))
    compared = api.compare(left, right)
    provider.require(compared['left_digest'] == completed['flops']['producer_result_sha256'] and
                     compared['right_digest'] == completed['exact']['producer_result_sha256'],
                     'comparison replaced an exact attempt result')
    value = dict(contract='electrum.fs2-event-comparison', schema_version=1, attempt_id=attempt,
                 left_case='flops', right_case='exact', left_result=str(left), right_result=str(right),
                 asic_workload_result=False, comparison=compared)
    path = artifact_root / 'event-comparison.json'
    with path.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')
    provider.require(path.stat().st_size <= provider.LIMIT, 'comparison export too large')
    events.emit(['Artifact', [('id', path.name), ('case_id', []), ('label', 'Verified project-owned Flops / Exact comparison'),
                             ('kind', 'report'), ('media_type', 'application/json'), ('path', path.name)]])
