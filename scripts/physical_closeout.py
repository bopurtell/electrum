#!/usr/bin/env python3
"""Consolidate retained physical, read-only viewer and final simulation evidence."""
import argparse
import json
import os
from pathlib import Path
import sys

sys.dont_write_bytecode = True
from physical_workbench import ROOT, sha, save, docker_ids
import workbench
sys.path.insert(0, str(ROOT / 'scripts/simulation'))
import prepare


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('journey', type=Path)
    parser.add_argument('--review', required=True, type=Path)
    args = parser.parse_args()
    journey, review = args.journey.resolve(strict=True), args.review.resolve(strict=True)
    original = json.loads((journey / 'receipt.json').read_text())
    evidence = json.loads((review / 'receipt.json').read_text())
    summary = json.loads((review / 'physical-summary.json').read_text())
    assert original['physical_launch_count'] == 1
    assert all(item['status'] == 'completed' and item['exit_code'] == 0 for item in summary['stages'])
    assert evidence['status'] == 'passed' and not evidence['physical_run_retried']
    freeze = json.loads((journey / 'source-freeze.json').read_text())
    assert all(sha(Path(path)) == digest for path, digest in freeze.items()), 'source/binary freeze changed'
    config_changes = {}
    for path, digest in original['normal_configs_sha256'].items():
        actual = sha(Path(path))
        if actual != digest:
            assert Path(path).name == 'hardcaml-workbench-simulation.sexp'
            config_changes[path] = dict(before=digest, after=actual,
                reason='explicit final seven-case simulation requalification after physical completion')
    selection, simulation = prepare.verify_current()
    workbench.stopped()
    running = docker_ids()
    assert not running.intersection(original['owned_containers']), 'owned EDA container remains'
    execution = Path(original['execution_file'])
    remaining_tools = []
    for process in Path('/proc').iterdir():
        if not process.name.isdecimal() or int(process.name) == os.getpid():
            continue
        try:
            argv = (process / 'cmdline').read_bytes().decode().rstrip('\0').split('\0')
        except (FileNotFoundError, ProcessLookupError, PermissionError, UnicodeError):
            continue
        if (argv and Path(argv[0]).name.startswith('hardcaml-') and
                any(str(execution.parent) in arg or str(journey / 'state') in arg for arg in argv)):
            remaining_tools.append(dict(pid=process.name, argv=argv))
    assert not remaining_tools, 'selected-run native process remains'
    transports = []
    for path in sorted(execution.parent.glob('*-transport.json')):
        value = json.loads(path.read_text())
        assert '--cpus=6' in value['argv']
        transports.append(dict(path=str(path), sha256=sha(path), docker_cpus=6))
    timing_config = next((execution.parent / 'project/src/runs').glob('timing-*/11-openroad-stapostpnr/config.json'))
    config = json.loads(timing_config.read_text())
    assert config['STA_THREADS'] == 1
    result = dict(status='completed_with_retained_setup_timing_failure', physical_launch_count=1,
        execution_file=str(execution), execution_sha256=sha(execution),
        plan_identity=original['plan_identity'], bundle_identity=original['bundle_identity'],
        physical_all_six_stages_completed=True, timing_goal_passed=False,
        acceptance='not_evaluated; no Signoff or coarse fallback',
        production_pty_launch=True, source_freeze_unchanged=True,
        normal_config_changes=config_changes, normal_user_history_store_used=False,
        original_harness_receipt=str(journey / 'receipt.json'),
        original_harness_post_terminal_issue=original.get('error'),
        read_only_reopen_receipt=str(review / 'receipt.json'),
        physical_summary=str(review / 'physical-summary.json'),
        typed_timing_paths_available=evidence['typed_timing_paths_available'],
        timing_index_diagnostics=evidence['timing_index_diagnostics'],
        final_simulation_selection=selection, final_simulation_all_seven_qualified=simulation['checks_passed'],
        container_transports=transports, sta_threads=1, sta_config=str(timing_config),
        stage_timeout_seconds=original['stage_timeout_seconds'], whole_owner_seconds=original['whole_owner_seconds'],
        remaining_owned_containers=[], remaining_selected_run_native_processes=remaining_tools,
        all_owned_daemons_clients_reaped=True, eda_lane_released=True)
    save(journey / 'closeout.json', result)
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
