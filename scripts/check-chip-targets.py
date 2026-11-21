#!/usr/bin/env python3
"""Exercise the Electrum Silver gateway, owner CLI, and legacy bundles without EDA."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile

root, gateway, bundle_cli, registry_cli, owner = map(
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


def read_manifest(directory):
    return json.loads((directory / 'manifest.json').read_text())


def source_paths(bundle):
    return {item['path'] for item in bundle['source_inputs']}


manifest = json.loads((root / 'hardcaml-asic-targets.json').read_text())
assert manifest['default_target'] == 'electrum'
assert manifest['targets'] == [{'id': 'electrum', 'executable': 'asics/electrum/cli/chip.exe'}]

assert json.loads(command(registry_cli, 'list')) == manifest
listing = query(gateway, 'chip', 'list', cwd=root / 'ip')
assert listing['default_chip'] == 'electrum'
assert [chip['id'] for chip in listing['chips']] == ['electrum']
assert listing == query(owner, 'chip', 'list')

route = ('--chip', 'electrum', '--variant', 'default')
flows = query(gateway, 'flow', 'list')
assert flows == query(gateway, 'flow', 'list', *route) == query(owner, 'flow', 'list', *route)
entries = {e['methodology']['id']: e for e in flows['declaration']['entries']}
assert {'flops', 'stock_sram'} <= entries.keys()
assert 'balanced' in {p['id'] for p in entries['flops']['profiles']}
assert {'balanced', 'timing_repair'} <= {p['id'] for p in entries['stock_sram']['profiles']}
assert entries['stock_sram']['default_profile'] == 'balanced'
command(gateway, 'flow', 'describe', *route, '--flow', 'stock_sram_synthesis',
        rejects='Unknown flow ID')
for legacy_kind in ('loader', 'memory', 'observable'):
    command(gateway, 'flow', 'list', '--chip', legacy_kind, rejects='Unknown chip target')
    command(owner, 'flow', 'list', '--chip', legacy_kind, rejects='not owned')
command(gateway, 'flow', 'list', '--chip', 'missing', rejects='Unknown chip target')
command(gateway, 'flow', 'list', '--chip', 'electrum', '--variant', 'missing',
        rejects='Unknown variant')

with tempfile.TemporaryDirectory(prefix='electrum-chips-') as tmp:
    tmp = Path(tmp)
    plans = {}
    for flow, selection in (('flops', 'flops'), ('stock_sram', 'exact')):
        request = ('--flow', flow, '--endpoint', 'synthesis', '--source-root', root)
        plan = query(gateway, 'flow', 'plan', *route, *request)
        plans[flow] = plan['plan_identity']
        assert plan == query(owner, 'flow', 'plan', *request)
        assert plan['project_name'] == 'electrum_loader'
        emitted = query(gateway, 'flow', 'emit', *route, *request, '--results-root', tmp / flow,
                        '--expected-plan-identity', plans[flow])
        assert emitted['plan_identity'] == plans[flow]
        path = Path(emitted['output_dir'])
        bundle = read_manifest(path)
        assert bundle['top_module'] == 'tt_um_leemperor_electrum_loader'
        assert len(bundle['resources']) == 1
        if selection == 'exact':
            assert bundle['macro_contract']['schema_version'] == 2
        else:
            assert bundle.get('macro_contract') is None
        inputs = source_paths(bundle)
        assert f'asics/electrum/flows/flow_{flow}.ml' in inputs
        assert not any(p.startswith('asics/') and not p.startswith('asics/electrum/') for p in inputs)
        assert not any(p.startswith(('asic_support/verif/memory/rtl/', 'asic_support/verif/observable/rtl/'))
                       for p in inputs)

        legacy = tmp / f'legacy-loader-{flow}'
        command(bundle_cli, '--selection', selection, '--operation', 'hardening', 'loader', legacy, root)
        old_route = read_manifest(legacy)
        for field in ('top_module', 'hardware_variant', 'resource_snapshot', 'simulation_resources',
                      'synthesis_sources', 'simulation_sources', 'macro_contract'):
            assert bundle.get(field) == old_route.get(field), field
        for relative in ('constraints/top.sdc', *bundle['synthesis_sources'], *bundle['simulation_sources']):
            assert (path / relative).read_bytes() == (legacy / relative).read_bytes(), relative

    for kind, top, resources in (('memory', 'tt_um_leemperor_electrum_memory', 1),
                                 ('observable', 'tt_um_leemperor_electrum', 0)):
        legacy = tmp / f'legacy-{kind}'
        command(bundle_cli, kind, legacy, root)
        bundle = read_manifest(legacy)
        assert bundle['top_module'] == top and len(bundle['resources']) == resources
        assert bundle.get('macro_contract') is None
        assert f'asic_support/verif/{kind}/rtl/{kind}_design.ml' in source_paths(bundle)
        assert (legacy / f'src/{top}.v').is_file() and (legacy / f'simulation/{top}.v').is_file()

    rejected = tmp / 'stale'
    command(gateway, 'flow', 'emit', *route, '--flow', 'flops', '--endpoint', 'synthesis',
            '--results-root', rejected, '--expected-plan-identity', plans['stock_sram'],
            rejects='identity')
    assert not rejected.exists()
    typed = (*route, '--flow', 'flops', '--endpoint', 'synthesis', '--set', 'SYNTH_ABC_BUFFERING=false')
    planned = query(gateway, 'flow', 'plan', *typed)
    assert planned['plan_identity'] != plans['flops']
    assert query(gateway, 'flow', 'emit', *typed, '--results-root', tmp / 'typed',
                 '--expected-plan-identity', planned['plan_identity'])['plan'] == planned
    preparation = command(gateway, 'prepare', *route, '--flow', 'stock_sram',
                          '--results-root', tmp / 'prepare', '--json')
    terminal = json.loads(preparation.splitlines()[-1])
    assert terminal['event'] == 'terminal' and terminal['record']['status'] == 'completed'
    assert terminal['record']['request'] == {
        'project': 'electrum_loader', 'flow': 'stock_sram',
        'variant': 'default', 'source_root': str(root),
    }

print('Electrum-only registration, named-flow plan/emit, legacy bundles, and CLI-route RTL parity passed')
