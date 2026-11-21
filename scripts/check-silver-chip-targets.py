#!/usr/bin/env python3
"""Opt-in Silver integration: run on a temporary source copy, without PDK or EDA."""
import json
from pathlib import Path
import selectors
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent / 'simulation'))
from fs2_wire import parse, sexp


ROOT = Path(__file__).resolve().parents[1]
GATEWAY = 'asic/cli/project.exe'


def run(*argv, cwd):
    result = subprocess.run(argv, cwd=cwd, text=True, capture_output=True, timeout=240)
    assert result.returncode == 0, (argv, result.stdout, result.stderr)
    return result.stdout


def exercise(project, endpoint):
    gateway = project / '_build/default' / GATEWAY

    def build():
        targets = json.loads((project / 'hardcaml-asic-targets.json').read_text())['targets']
        run('dune', 'build', '-j4', GATEWAY, *(t['executable'] for t in targets), cwd=project)

    def api(operation):
        value = parse(run('silver', '--api', '--connect', endpoint, '--project-root', project,
                          '--environment', 'inherited', '--asic-operation', operation, '--wait',
                          cwd=project))
        assert value[0] == 'Ok', value
        return dict(value[1])

    def flows(snapshot):
        assert dict(snapshot['catalog_default'][0]) == {'flow': 'flops', 'profile': 'balanced'}
        return {dict(flow)['id']: dict(flow) for flow in snapshot['flows']}

    def select(chip):
        return api(sexp(['Select_chip', [['chip', chip], ['variant', 'default']]]))

    def author(*args):
        return run('silver-author', *args, '--endpoint', endpoint, '--root', project, cwd=project)

    build()
    discovered = api('Discover')
    assert {dict(chip)['id'] for chip in discovered['chips']} == {'loader', 'memory', 'observable'}
    assert dict(discovered['chip_target'][0]) == {'chip': 'loader', 'variant': 'default'}
    assert set(flows(discovered)) == {'flops', 'stock_sram'}
    assert set(flows(select('memory'))) == {'flops', 'stock_sram_synthesis'}
    assert set(flows(select('observable'))) == {'flops'}

    authored = project / 'asics/memory/flows/flow_trial.ml'
    new_flow = ('new-flow', 'trial', '--chip', 'memory', '--endpoint-stage', 'synthesis')
    author(*new_flow)
    assert not authored.exists(), 'preview wrote source'
    author(*new_flow, '--apply')
    assert authored.is_file()
    author('duplicate-profile', 'buffered', '--chip', 'memory', '--flow', 'flops',
           '--from', 'balanced', '--set', 'SYNTH_ABC_BUFFERING=true', '--apply')
    build()
    memory = flows(select('memory'))
    assert set(memory) == {'flops', 'stock_sram_synthesis', 'trial'}
    assert set(memory['flops']['profiles']) == {'balanced', 'buffered'}
    assert set(flows(select('loader'))) == {'flops', 'stock_sram'}
    memory_plan_args = ('flow', 'plan', '--chip', 'memory', '--flow', 'trial',
                        '--endpoint', 'synthesis', '--json')
    memory_plan = json.loads(run(gateway, *memory_plan_args, cwd=project))
    assert memory_plan['project_name'] == 'electrum_memory'
    assert 'asics/memory/flows/flow_trial.ml' in memory_plan['bundle_manifest']
    buffered = json.loads(run(gateway, 'flow', 'plan', '--chip', 'memory', '--flow', 'flops',
                              '--profile', 'buffered', '--endpoint', 'synthesis', '--json',
                              cwd=project))
    assert json.loads(buffered['configuration_bytes'])['SYNTH_ABC_BUFFERING'] is True

    author('new-ip', 'invert', '--template', 'sample', '--apply')
    author('new-chip', 'added', '--from-ip', 'ip/invert', '--mapping', 'ui_in:uo_out:comb8',
           '--apply')
    build()
    refreshed = api('Discover')
    assert 'added' in {dict(chip)['id'] for chip in refreshed['chips']}
    assert {dict(flow)['id'] for flow in select('added')['flows']} == {'standard'}
    plan = json.loads(run(gateway, 'flow', 'plan', '--chip', 'added', '--flow', 'standard',
                          '--endpoint', 'synthesis', '--json', cwd=project))
    assert plan['project_name'] == 'added'
    manifest_path = project / 'hardcaml-asic-targets.json'
    manifest = json.loads(manifest_path.read_text())
    manifest['default_target'] = 'added'
    manifest_path.write_text(json.dumps(manifest))
    implicit = run(gateway, 'flow', 'list', '--json', cwd=project)
    assert implicit == run(gateway, 'flow', 'list', '--chip', 'added', '--json', cwd=project)
    assert json.loads(run(gateway, *memory_plan_args, cwd=project)) == memory_plan
    assert not (project / '_flow_results').exists(), 'discovery/preview published results'

    select('memory')
    selection = [['flow', 'trial'], ['profile', 'balanced'], ['endpoint', 'synthesis'],
                 ['assignments', []], ['chip_target', [[['chip', 'memory'], ['variant', 'default']]]]]
    staged = api(sexp(['Stage_fresh', ['selection', selection], ['elaboration_only', 'true'],
                       ['expected_plan_identity', []]]))
    intent = dict(staged['fresh_intent'][0])
    launched = api(sexp(['Launch_fresh', ['key', 'electrum-memory-source-only'],
                         ['intent_id', intent['id']]]))
    workflow, = (dict(w) for w in launched['workflows']
                 if dict(w)['key'] == 'electrum-memory-source-only')
    assert workflow['phase'] == 'Completed' and workflow['run'] == [], workflow
    prepared = dict(workflow['prepared'][0])
    bundle = json.loads((Path(prepared['bundle_directory']) / 'manifest.json').read_text())
    assert bundle['project'] == 'electrum_memory'


def main():
    provider = shutil.which('hardcaml-asic-flow')
    assert provider, 'Activate current project-local ASIC and Silver tools first'
    with tempfile.TemporaryDirectory(prefix='electrum-silver-') as tmp:
        tmp = Path(tmp).resolve()
        project = tmp / 'project'
        project.mkdir()
        for name in ('dune', 'dune-project', 'electrum.opam', 'tools-source.lock.json',
                     'hardcaml-asic-targets.json'):
            shutil.copy2(ROOT / name, project / name)
        for name in ('asic', 'asics', 'ip', 'spec', 'software', 'verif', 'scripts', 'firmware'):
            shutil.copytree(ROOT / name, project / name, ignore=shutil.ignore_patterns('__pycache__'))
        # Bundle provenance needs a real HEAD. Clone locally, without a checkout
        # or new commit, so the test never writes to the caller's Git metadata.
        git_root = tmp / 'provenance'
        run('git', 'clone', '--quiet', '--no-checkout', ROOT, git_root, cwd=tmp)
        shutil.move(git_root / '.git', project / '.git')
        companions = project / '.workbench'
        companions.mkdir()
        (companions / 'hardcaml-workbench-asic.sexp').write_text(sexp([
            ['schema_version', 1], ['project_executable', project / '_build/default' / GATEWAY],
            ['provider_executable', provider], ['results_root', project / '_flow_results'],
            ['toolchain', project / '_flow_tools'], ['python', []],
            ['support_tools', []], ['pdk_root', []], ['stage_timeout_seconds', []],
        ]))
        (companions / 'hardcaml-workbench-preparation.sexp').write_text(sexp([
            ['schema_version', 1], ['build_target', GATEWAY],
            ['results_root', project / '_flow_results/preparation'], ['timeout_seconds', 120],
        ]))
        with subprocess.Popen(['silver-daemon', '--port', '0', '--authoring-root', project,
                               '--state-dir', tmp / 'state'], cwd=project, text=True,
                              stdout=subprocess.PIPE) as daemon:
            try:
                with selectors.DefaultSelector() as selector:
                    selector.register(daemon.stdout, selectors.EVENT_READ)
                    assert selector.select(30), 'Silver daemon did not announce its endpoint'
                line = daemon.stdout.readline()
                assert line.startswith('silver-daemon listening on '), line
                exercise(project, line.split()[-1])
            finally:
                daemon.terminate()
    print('Silver chip discovery, selection, authoring, and source-only preparation passed')


if __name__ == '__main__':
    main()
