#!/usr/bin/env python3
"""Exercise the actual Silver gateway and each registered chip executable without EDA."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile

root, gateway, bundle_cli, registry_cli, *executables = map(
    lambda arg: Path(arg).resolve(), sys.argv[1:])


def command(exe, *args, cwd=root, rejects=None):
    result = subprocess.run([str(exe), *map(str, args)], cwd=cwd,
                            text=True, capture_output=True)
    if rejects is not None:
        assert result.returncode != 0 and rejects in result.stderr, (args, result)
        return
    assert result.returncode == 0, (args, result.stdout, result.stderr)
    return result.stdout


def query(exe, *args, **kwargs):
    return json.loads(command(exe, *args, '--json', **kwargs))


manifest = json.loads((root / 'hardcaml-asic-targets.json').read_text())
lookup = dict(zip(('loader', 'memory', 'observable'), executables, strict=True))
expected = {
    'loader': ('stock_sram', 'electrum_loader', 1),
    'memory': ('stock_sram_synthesis', 'electrum_memory', 1),
    'observable': (None, 'electrum_observable', 0),
}

assert json.loads(command(registry_cli, 'list')) == manifest
listing = query(gateway, 'chip', 'list', cwd=root / 'ip')
assert listing['default_chip'] == manifest['default_target'] == 'loader'
assert {chip['id'] for chip in listing['chips']} == {t['id'] for t in manifest['targets']}
assert query(gateway, 'flow', 'list') == query(lookup['loader'], 'flow', 'list')

with tempfile.TemporaryDirectory(prefix='electrum-chips-') as tmp:
    tmp = Path(tmp)
    plans = {}
    for chip, (exact_flow, design, resources) in expected.items():
        owner = lookup[chip]
        route = ('--chip', chip, '--variant', 'default')
        local = query(owner, 'chip', 'list')
        assert local['default_chip'] == chip
        assert [item['id'] for item in local['chips']] == [chip]
        flows = query(gateway, 'flow', 'list', *route)
        assert flows == query(owner, 'flow', 'list', *route)
        entries = {e['methodology']['id']: e for e in flows['declaration']['entries']}
        assert 'flops' in entries
        for other_flow in {'stock_sram', 'stock_sram_synthesis'} - {exact_flow}:
            assert other_flow not in entries
            command(gateway, 'flow', 'describe', *route, '--flow', other_flow,
                    rejects='Unknown flow ID')
        request = ('--endpoint', 'synthesis', '--source-root', root)
        plan = query(gateway, 'flow', 'plan', *route, *request)
        plans[chip] = plan['plan_identity']
        assert plan == query(owner, 'flow', 'plan', *request)
        assert plan['project_name'] == design
        emitted = query(gateway, 'flow', 'emit', *route, *request, '--results-root', tmp / chip,
                        '--expected-plan-identity', plans[chip])
        assert emitted['plan_identity'] == plans[chip]
        path = Path(emitted['output_dir'])
        bundle = json.loads((path / 'manifest.json').read_text())
        assert len(bundle['resources']) == resources and bundle.get('macro_contract') is None
        inputs = {item['path'] for item in bundle['source_inputs']}
        assert f'asics/{chip}/flows/flow_flops.ml' in inputs
        assert not any(p.startswith('asics/') and not p.startswith(f'asics/{chip}/') for p in inputs)
        legacy = tmp / f'legacy-{chip}'
        command(bundle_cli, chip, legacy, root)
        for relative in ('constraints/top.sdc', f'src/{bundle["top_module"]}.v',
                         f'simulation/{bundle["top_module"]}.v'):
            assert (path / relative).read_bytes() == (legacy / relative).read_bytes(), relative
        if exact_flow:
            exact = query(gateway, 'flow', 'plan', *route, '--flow', exact_flow, *request)
            macro = json.loads(exact['bundle_manifest'])['macro_contract']
            assert macro['schema_version'] == (2 if chip == 'loader' else 1)
    assert len(set(plans.values())) == len(expected)
    rejected = tmp / 'stale'
    command(gateway, 'flow', 'emit', '--chip', 'memory', '--endpoint', 'synthesis',
            '--results-root', rejected, '--expected-plan-identity', plans['loader'],
            rejects='identity')
    assert not rejected.exists()
    command(gateway, 'flow', 'list', '--chip', 'missing', rejects='missing')
    command(gateway, 'flow', 'list', '--chip', 'memory', '--variant', 'missing',
            rejects='Unknown variant')
    command(lookup['memory'], 'flow', 'list', '--chip', 'loader', rejects='not owned')
    command(gateway, 'flow', 'plan', '--chip', 'memory', '--flow', 'stock_sram_synthesis',
            '--endpoint', 'floorplan', rejects='floorplan')
    typed = ('--chip', 'observable', '--flow', 'flops', '--endpoint', 'synthesis',
             '--set', 'SYNTH_ABC_BUFFERING=false')
    planned = query(gateway, 'flow', 'plan', *typed)
    assert planned['plan_identity'] != plans['observable']
    assert query(gateway, 'flow', 'emit', *typed, '--results-root', tmp / 'typed',
                 '--expected-plan-identity', planned['plan_identity'])['plan'] == planned
    preparation = command(gateway, 'prepare', '--chip', 'memory', '--variant', 'default',
                          '--flow', 'stock_sram_synthesis', '--results-root', tmp / 'prepare',
                          '--json')
    terminal = json.loads(preparation.splitlines()[-1])
    assert terminal['event'] == 'terminal' and terminal['record']['status'] == 'completed'
    assert terminal['record']['request'] == {
        'project': 'electrum_memory', 'flow': 'stock_sram_synthesis',
        'variant': 'default', 'source_root': str(root),
    }

print('Electrum chip registration, scoped flows, plan/emit and legacy RTL parity passed')
