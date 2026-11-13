#!/usr/bin/env python3
"""Explicit build, qualification and local install of the serial/event FS2 provider.

Requires a granted build/simulation slot. Discovery/run never call this helper.
No shared switch mutations, PDK provisioning, EDA or implicit daemon startup.
"""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import uuid

sys.dont_write_bytecode = True
from fs2_wire import sexp
import pt3b_provider as provider

ROOT = Path(__file__).resolve().parents[2]
STORE = ROOT / '.dev/workbench/simulation'
TARGET = 'asic/cli/asic_bundle.exe'
EVENT_TARGETS = ('asic/verif/workloads/emit_event_response.exe',
                 'asic/verif/workloads/reference_event_response.exe')
SOURCES = ('scripts/simulation/fs2_wire.py', 'scripts/simulation/pt3b_provider.py',
           'scripts/simulation/serial_trace.v', 'scripts/simulation/prepare.py',
           'scripts/simulation/event_adapter.py',
           'asic/verif/functional/check_functional.py', 'asic/verif/bundle/check_bundle.py',
           'verif/system/emitted/p3_loader_tb.v')


def module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def write_json(path, value):
    pending = path.with_suffix('.pending')
    with pending.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')
    os.replace(pending, path)


def selected_generation():
    selection_path = STORE / 'current.json'
    selection = json.loads(provider.read(selection_path))
    provider.require(selection['schema_version'] == 1, 'unsupported simulation selection schema')
    manifest = Path(selection['manifest'])
    provider.require(manifest.parent.parent == STORE / 'generations' and
                     manifest.name == 'manifest.json', 'foreign simulation selection')
    provider.require(provider.sha(manifest) == selection['manifest_sha256'],
                     'simulation manifest changed after qualification')
    return selection, manifest


def verify_previous():
    """Refresh preflight: immutable prior bytes/schema/catalog, not today's matrix."""
    selection, manifest = selected_generation()
    value, matrix = provider.frozen_generation(manifest)
    return selection, value


def verify_current(*, check_sources=True):
    selection, manifest = selected_generation()
    value = provider.validate_install(manifest, check_sources=check_sources)
    qualification = json.loads(provider.read(manifest.parent / 'qualification.json'))
    provider.require(qualification['status'] == 'passed' and qualification['suites'] ==
                     {suite: list(cases) for suite, cases in provider.SUITES.items()},
                     'missing complete serial/event real qualification')
    for relative, digest in qualification['sha256'].items():
        provider.require(provider.sha(provider.local(manifest.parent, relative)) == digest,
                         'qualification evidence changed')
    return selection, value


def prepare(args):
    STORE.mkdir(parents=True, exist_ok=True)
    with (STORE / 'prepare.lock').open('a') as lock, \
         (ROOT.parent / '.electrum-build.lock').open('a') as build_lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        fcntl.flock(build_lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        if (STORE / 'current.json').exists():
            # Intentional refresh admits current authored source edits. Prior
            # installed bytes and qualification evidence must still be intact.
            verify_previous()
        previous = provider.read(STORE / 'current.json') if (STORE / 'current.json').exists() else None
        generation = STORE / 'generations' / uuid.uuid4().hex
        generation.mkdir(parents=True)
        # The same normal local tool receipt used by env.sh, independently checked.
        tools = module(ROOT / 'scripts/install-tools.py', 'electrum_installed_tools')
        selection, tools_receipt = tools.verify_selection()
        oracle = module(ROOT / 'asic/verif/functional/check_functional.py', 'pt3b_source_oracle')
        snapshot_check = module(ROOT / 'asic/verif/bundle/check_bundle.py', 'pt3b_source_bundle')
        env = tools.environment(Path(tools_receipt['switch_prefix']), Path(selection['prefix']))
        sys.path.insert(0, str(ROOT / 'asic/verif/workloads'))
        producer = module(ROOT / 'asic/verif/workloads/produce_event_response.py', 'source_event_producer')
        event_sources = {str(p.relative_to(ROOT)): provider.read(p, 64 * provider.LIMIT)
                         for p in producer.source_paths()}
        built, output = provider.command(['dune', 'build', '--root', str(ROOT), '-j2', TARGET,
                                         'asic/cli/project.exe', *EVENT_TARGETS],
                                        generation, 'build', timeout=1800, env=env)
        provider.require(built['exit_code'] == 0, 'source build failed; inspect retained build logs')
        after = {str(p.relative_to(ROOT)): provider.read(p, 64 * provider.LIMIT)
                 for p in producer.source_paths()}
        provider.require(after == event_sources, 'event producer source changed during build')
        emitter = ROOT / '_build/default' / TARGET
        source_revision = subprocess.check_output(['git', '-C', str(ROOT), 'rev-parse', 'HEAD'], text=True).strip()
        value = dict(contract='electrum.fs2-pt3b-install', schema_version=2, checks_passed=False,
                     catalog_schema_version=1, catalog=provider.catalog(), catalog_sha256=provider.catalog_digest(provider.catalog()),
                     generation=str(generation), project_root=str(ROOT), bundles={}, tools={}, models=[],
                     source_sha256={}, files={}, fixed_variant_identity=None,
                     tools_receipt=selection['receipt'], tools_receipt_sha256=provider.sha(Path(selection['receipt'])))
        for tool in ('iverilog', 'vvp'):
            located = shutil.which(tool)
            provider.require(located is not None, 'missing simulator: ' + tool)
            path = Path(located).resolve(strict=True)
            version = subprocess.run([str(path), '-V'], text=True, capture_output=True, timeout=10, check=True)
            value['tools'][tool] = dict(path=str(path), sha256=provider.sha(path),
                                       version=version.stdout + version.stderr)
        installed_sources = {
            'scripts/simulation/fs2_wire.py': 'fs2_wire.py',
            'scripts/simulation/pt3b_provider.py': 'pt3b_provider.py',
            'scripts/simulation/event_adapter.py': 'event_adapter.py',
            'scripts/simulation/serial_trace.v': 'serial_trace.v',
            'asic/verif/functional/check_functional.py': 'pt3b_oracle.py',
            'verif/system/emitted/p3_loader_tb.v': 'p3_loader_tb.v',
        }
        for relative, installed in installed_sources.items():
            shutil.copyfile(ROOT / relative, generation / installed)
        shutil.copyfile(emitter, generation / 'asic_bundle.exe')
        shutil.copyfile(selection['receipt'], generation / 'tools-receipt.json')
        for relative, data in event_sources.items():
            path = generation / 'source' / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        binaries = generation / 'bin'
        binaries.mkdir()
        for target in EVENT_TARGETS:
            destination = binaries / Path(target).name
            shutil.copyfile(ROOT / '_build/default' / target, destination)
            destination.chmod(0o555)
        value['event'] = dict(source_directory='source',
            producer='source/asic/verif/workloads/produce_event_response.py',
            bench='source/asic/verif/workloads/event_response_tb.v',
            emitter='bin/emit_event_response.exe', reference='bin/reference_event_response.exe',
            pdk_directory='model-pdk', results_root=str(ROOT / '_flow_results/workbench/event-response'))
        value['event_source_sha256'] = {p: hashlib.sha256(data).hexdigest() for p, data in event_sources.items()}
        expected_variant = None
        sources = set(SOURCES) | set(event_sources)
        for choice in ('flops', 'exact'):
            bundle = generation / ('bundle-' + choice)
            command = [str(emitter), '--selection', choice, 'loader', str(bundle), str(ROOT)]
            emitted, output = provider.command(command, generation, 'emit-' + choice, timeout=120, env=env)
            provider.require(emitted['exit_code'] == 0, 'bundle emission failed; inspect retained emitter logs')
            evidence = type('Evidence', (), {'record': {'source_revision': source_revision}})()
            manifest = oracle.validate_bundle(bundle, ROOT, choice, 'loader', evidence, snapshot_check.check_snapshot)
            variant = manifest.get('hardware_variant')
            provider.require(variant is not None and variant['design_id'] == 'electrum-loader' and
                             variant['schema_id'] == 'fixed-loader-v1', 'missing fixed loader variant')
            if expected_variant is None:
                expected_variant = variant
            provider.require(variant == expected_variant, 'resource policy changed hardware variant association')
            value['bundles'][choice] = dict(directory=bundle.name, manifest=bundle.name + '/manifest.json',
                                           identity=manifest['identity'])
            sources.update(item['path'] for item in manifest['source_inputs'])
            if choice == 'exact':
                pdk = args.pdk_root.resolve(strict=True)
                for reference, path in oracle.resolve_models(manifest, pdk):
                    destination = generation / 'models' / path.name
                    destination.parent.mkdir(exist_ok=True)
                    shutil.copyfile(path, destination)
                    provider.require(provider.sha(destination) == oracle.MODEL_HASHES[reference], 'copied model drift')
                    value['models'].append(str(destination.relative_to(generation)))
                    model = generation / 'model-pdk/ihp-sg13cmos5l/libs.ref/sg13cmos5l_sram/verilog' / path.name
                    model.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(destination, model)
        value['fixed_variant_identity'] = expected_variant['identity']
        value['source_sha256'] = {p: provider.sha(ROOT / p) for p in sorted(sources)}
        for source, installed in installed_sources.items():
            provider.require(value['source_sha256'][source] == provider.sha(generation / installed),
                             'provider/oracle source changed while capturing installation')
        for bundle in value['bundles'].values():
            emitted = json.loads(provider.read(generation / bundle['manifest'], 8 * provider.LIMIT))
            for source in emitted['source_inputs']:
                provider.require(value['source_sha256'][source['path']] == source['sha256'],
                                 'source changed between resource-policy emissions')
        value['files'] = {str(p.relative_to(generation)): provider.sha(p)
                          for p in sorted(generation.rglob('*')) if p.is_file()}
        manifest_path = generation / 'manifest.json'
        write_json(manifest_path, value)
        # Real suite qualification precedes selection/config publication. This is
        # the only unqualified call path, owned by this explicit preparation step.
        evidence = generation / 'qualification'
        evidence.mkdir()
        installed_provider = module(generation / 'pt3b_provider.py', 'qualified_installed_pt3b_provider')
        suites = {}
        for suite, cases in provider.SUITES.items():
            run = evidence / suite
            run.mkdir()
            artifacts = run / 'artifacts'
            artifacts.mkdir()
            events = run / 'events.sexp'
            events.touch(exist_ok=False)
            request = run / 'request.sexp'
            request.write_text(sexp([('protocol_version', 1), ('attempt_id', 'qualification-' + generation.name + '-' + suite),
                ('selection', [('suite', suite), ('cases', list(cases)), ('seed', 0),
                               ('parameters', []), ('asic_inputs', [])])]) + '\n')
            code = installed_provider.run_request(manifest_path, request, events, artifacts, qualified=False)
            results = {case: json.loads(provider.read(artifacts / case / 'result.json', 8 * provider.LIMIT))
                       for case in cases if (artifacts / case / 'result.json').exists()}
            provider.require(code == 0 and set(results) == set(cases) and
                             all(r['status'] == 'passed' for r in results.values()),
                             'real ' + suite + ' qualification failed; installation/config remain unpublished')
            suites[suite] = list(results)
        provider.validate_install(manifest_path, qualified=False)
        qualification = dict(schema_version=2, status='passed', suites=suites,
            sha256={str(p.relative_to(generation)): provider.sha(p)
                    for p in sorted(evidence.rglob('*')) if p.is_file()})
        write_json(generation / 'qualification.json', qualification)
        value['checks_passed'] = True
        value['qualification_sha256'] = provider.sha(generation / 'qualification.json')
        write_json(manifest_path, value)
        selected = dict(schema_version=1, manifest=str(manifest_path), manifest_sha256=provider.sha(manifest_path))
        current = provider.read(STORE / 'current.json') if (STORE / 'current.json').exists() else None
        provider.require(current == previous, 'simulation selection changed during qualification; refusing overwrite')
        write_json(STORE / 'current.json', selected)
        verify_current()
        print(json.dumps(selected, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pdk-root', required=True, type=Path,
                        help='existing PDK checkout; pinned unmodified functional models are copied, never provisioned')
    args = parser.parse_args()
    prepare(args)


if __name__ == '__main__':
    def interrupt(signum, frame):
        raise provider.Cancelled()
    signal.signal(signal.SIGTERM, interrupt)
    signal.signal(signal.SIGINT, interrupt)
    try:
        main()
    except provider.Cancelled:
        sys.exit(130)
    except (OSError, ValueError, KeyError, provider.InfrastructureError, subprocess.SubprocessError) as error:
        sys.exit('prepare-simulation: ' + str(error))
