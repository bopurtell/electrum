#!/usr/bin/env python3
"""Public opt-in profile differential and retained candidate emission. No EDA."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project', required=True, type=Path)
    parser.add_argument('--source-root', required=True, type=Path)
    parser.add_argument('--output-root', type=Path, help='new persistent evidence directory')
    parser.add_argument('--retained-baseline-config', type=Path)
    args = parser.parse_args()
    root = args.source_root.resolve(strict=True)
    project = args.project.resolve(strict=True)
    temporary = tempfile.TemporaryDirectory(prefix='protemu-profile-') if args.output_root is None else None
    output = Path(temporary.name) if temporary else args.output_root.absolute()
    if not temporary:
        output.mkdir(parents=True, exist_ok=False)
    def command(*argv, success=True):
        result = subprocess.run([str(project), *map(str, argv)], cwd=root,
                                capture_output=True, text=True, timeout=120)
        assert (result.returncode == 0) == success, (argv, result.stdout, result.stderr)
        return json.loads(result.stdout) if success else result
    listing = command('flow', 'list', '--json')
    entries = {e['methodology']['id']: e for e in listing['declaration']['entries']}
    assert entries['stock_sram']['default_profile'] == 'balanced'
    assert [p['id'] for p in entries['stock_sram']['profiles']] == ['balanced', 'timing_repair']
    assert [p['id'] for p in entries['flops']['profiles']] == ['balanced']
    emitted = {}
    for profile in ('balanced', 'timing_repair'):
        options = ['--flow', 'stock_sram', '--profile', profile, '--endpoint', 'timing',
                   '--project-root', str(root), '--json']
        plan = command('flow', 'plan', *options)
        (output / (profile + '.plan.json')).write_text(json.dumps(plan, indent=2) + '\n')
        publication = command('flow', 'emit', *options, '--results-root', output / 'results',
                              '--expected-plan-identity', plan['plan_identity'])
        directory = Path(publication['output_dir'])
        emitted[profile] = dict(plan=plan, publication=publication, directory=directory,
                               manifest=json.loads((directory / 'manifest.json').read_text()),
                               config=json.loads((directory / 'src/config.json').read_text()))
    baseline, candidate = emitted['balanced'], emitted['timing_repair']
    default = command('flow', 'plan', '--flow', 'stock_sram', '--endpoint', 'timing', '--json')
    assert default['plan_identity'] == baseline['plan']['plan_identity'], 'default changed'
    changed = {key for key in baseline['config'].keys() | candidate['config'].keys()
               if baseline['config'].get(key) != candidate['config'].get(key)}
    assert changed == {'RUN_POST_GRT_RESIZER_TIMING'}, changed
    assert candidate['config']['RUN_POST_GRT_RESIZER_TIMING'] is True
    assert baseline['config'].get('RUN_POST_GRT_RESIZER_TIMING', False) is False
    if args.retained_baseline_config:
        assert baseline['config'] == json.loads(args.retained_baseline_config.read_text()), 'retained baseline config drift'
    assert baseline['config']['RSZ_CORNERS'] == candidate['config']['RSZ_CORNERS'] == [
        'nom_fast_1p32V_m40C', 'nom_slow_1p08V_125C', 'nom_typ_1p20V_25C']
    assert baseline['config'].get('SYNTH_STRATEGY', 'AREA 0') == 'AREA 0'
    assert abs(baseline['config']['CLOCK_PERIOD'] - 1000 / 48) < 1e-12
    assert candidate['config']['FP_MACRO_HORIZONTAL_HALO'] == candidate['config']['FP_MACRO_VERTICAL_HALO'] == 2
    macro = candidate['config']['MACROS']['RM_IHPSG13_1P_256x16_c2_bm_bist']
    assert macro['instances']['hc_resource_7_program'] == {'location': [40.0, 480.0], 'orientation': 'R0'}
    for field in ('hardware_variant', 'resource_snapshot', 'simulation_resources', 'macro_contract'):
        assert baseline['manifest'][field] == candidate['manifest'][field], field
    same = []
    for relative in ['constraints/top.sdc', *baseline['manifest']['synthesis_sources'],
                     *baseline['manifest']['simulation_sources']]:
        assert (baseline['directory'] / relative).read_bytes() == (candidate['directory'] / relative).read_bytes(), relative
        same.append(relative)
    assert baseline['plan']['plan_identity'] != candidate['plan']['plan_identity']
    assert baseline['publication']['bundle_identity'] != candidate['publication']['bundle_identity']
    command('flow', 'plan', '--flow', 'flops', '--profile', 'timing_repair', '--endpoint', 'timing', '--json', success=False)
    command('flow', 'plan', '--flow', 'stock_sram', '--profile', 'timing_repair', '--endpoint', 'timing',
            '--set', 'RUN_POST_GRT_RESIZER_TIMING=true', '--json', success=False)
    receipt = dict(status='passed', eda_run=False, source_root=str(root),
        effective_config_only_difference={'RUN_POST_GRT_RESIZER_TIMING': {'baseline': 'absent; pinned backend default false', 'candidate': True}},
        identical_rtl_sdc=same, hardware_variant_identity=baseline['manifest']['hardware_variant']['identity'],
        baseline=dict(bundle=str(baseline['directory']), plan=str(output / 'balanced.plan.json'),
                      plan_identity=baseline['plan']['plan_identity']),
        timing_repair=dict(bundle=str(candidate['directory']), plan=str(output / 'timing_repair.plan.json'),
                           plan_identity=candidate['plan']['plan_identity']))
    (output / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt, indent=2))
    if temporary:
        temporary.cleanup()


if __name__ == '__main__':
    main()
