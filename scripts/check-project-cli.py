#!/usr/bin/env python3
"""Public source/plan/emit/preparation contracts; no EDA or workload runs."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

project = Path(sys.argv[1]).resolve()
root = Path(sys.argv[2]).resolve()


def run(*args, success=True):
    result = subprocess.run([str(project), *map(str, args)], cwd=root,
                            text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert (result.returncode == 0) == success, (args, result.stdout, result.stderr)
    if not success:
        return result
    if args[0] == 'prepare':
        return [json.loads(line) for line in result.stdout.splitlines()]
    return json.loads(result.stdout)


listing = run('flow', 'list', '--json')
entries = {e['methodology']['id']: e for e in listing['declaration']['entries']}
assert set(entries) == {'flops', 'stock_sram'}
assert entries['stock_sram']['methodology']['endpoints'] == [
    'synthesis', 'floorplan', 'placement', 'cts', 'routing', 'timing']
run('flow', 'describe', '--flow', 'stock_sram', '--json')
with tempfile.TemporaryDirectory(prefix='electrum-public-') as tmp:
    variants = []
    for flow in ('flops', 'stock_sram'):
        results = Path(tmp) / flow
        selection = ['--flow', flow, '--endpoint', 'timing', '--project-root', str(root), '--json']
        plan = run('flow', 'plan', *selection)
        again = run('flow', 'plan', *selection)
        assert plan == again
        assert not results.exists(), 'preview published output'
        emitted = run('flow', 'emit', *selection, '--results-root', results,
                      '--expected-plan-identity', plan['plan_identity'])
        manifest = json.loads((Path(emitted['output_dir']) / 'manifest.json').read_text())
        variant = manifest['hardware_variant']
        assert variant['design_id'] == 'electrum-loader' and variant['schema_id'] == 'fixed-loader-v1'
        assert [p['key'] for p in variant['parameters']] == ['package'], 'no shape controls are supported'
        variants.append(variant)
        assert emitted['plan_identity'] == plan['plan_identity']
        assert emitted['bundle_identity'] == plan['bundle_identity']
        macros = manifest.get('macro_contract')
        if flow == 'stock_sram':
            assert macros['schema_version'] == 2 and len(macros['macros']) == 1
        else:
            assert macros is None
        reused = run('flow', 'emit', *selection, '--results-root', results)
        assert reused['reused'] is True
        rejected = Path(tmp) / ('rejected-' + flow)
        run('flow', 'emit', *selection, '--results-root', rejected,
            '--expected-plan-identity', '0' * 64, success=False)
        assert not rejected.exists(), 'stale identity published output'
    assert variants[0] == variants[1], 'resource policy must not change fixed hardware association'
    run('flow', 'plan', '--flow', 'stock_sram', '--endpoint', 'signoff', '--json', success=False)
    run('flow', 'plan', '--flow', 'flops', '--endpoint', 'timing',
        '--set', 'CLOCK_PERIOD=1', '--json', success=False)
    run('flow', 'plan', '--flow', 'flops', '--flow', 'stock_sram', '--json', success=False)
    run('flow', 'run', '--flow', 'stock_sram', '--endpoint', 'timing',
        '--results-root', Path(tmp) / 'never-launched', '--json', success=False)
    preparation = run('prepare', '--flow', 'stock_sram', '--project-root', root,
                      '--results-root', Path(tmp) / 'preparation', '--json')
    assert preparation
    run('resources', '--flow', 'stock_sram', '--json')
print('Public Electrum: both catalogs, deterministic Timing plans, exact macro/flop emission, reuse, stale/no-write rejection and durable preparation passed')
