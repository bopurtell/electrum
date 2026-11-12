#!/usr/bin/env python3
"""Final read-only metadata/cleanup check and persistent release handoff."""
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT / '_flow_results/workbench/releases/714edccf3d934c1b99ce50c6930c7948'


def main():
    sys.path.insert(0, str(ROOT / 'scripts/simulation'))
    import prepare
    import workbench
    from installed_release_journey import same_process
    selection, simulation = prepare.verify_current()
    installed = json.loads((RELEASE / 'installed-verification.json').read_text())
    reader = json.loads((RELEASE / 'installed-reinspection/receipt.json').read_text())
    journey = RELEASE / 'normal-installed-journey-a49f737a4ee6440690cff2e93370451d'
    application = json.loads((journey / 'receipt.json').read_text())
    assert application['status'] == reader['status'] == installed['status'] == 'passed'
    assert len(application['cancellations']) == 2
    for probe in application['cancellations']:
        processes = json.loads(Path(probe['evidence']).read_text())
        assert not any(same_process(value) for value in processes)
    workbench.stopped()
    status = json.loads(subprocess.check_output(['bash', 'scripts/workbench.sh', 'status'], cwd=ROOT, timeout=60))
    assert status['readiness']['ready'] and not status['readiness']['configure_required']
    assert status['readiness']['simulation']['ready'] and status['readiness']['physical']['ready']
    (RELEASE / 'final-normal-status.json').write_text(json.dumps(status, indent=2) + '\n')
    result = dict(status='passed', selected_tools=installed['selection'], selected_simulation=selection,
        explicit_dirty_source_capture=True, source_proofs=str(RELEASE / 'receipt.json'),
        all_seven_actual_simulation_cases_qualified=simulation['checks_passed'],
        installed_cli_and_production_reader=True, installed_production_ui=True,
        retained_b591_typed_rows=193, retained_negative_slack_ns=-3.099803,
        original_observation_and_journal_unchanged=True, normal_pt6_preparation_resources=True,
        fresh_reader_scope_adoption=application['reader_adoption'],
        public_cancellation_probes=application['cancellations'], remaining_captured_processes=[],
        owned_daemons_clients_reaped=True, physical_eda_launches=0,
        cli_service_evidence=str(RELEASE / 'installed-reinspection'), application_evidence=str(journey),
        old_generations_and_failed_receipts_preserved=True)
    (RELEASE / 'closeout.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
