#!/usr/bin/env python3
"""Installed-byte/CLI verification before normal configure. No builds or EDA."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / '_flow_results/workbench/releases/714edccf3d934c1b99ce50c6930c7948'


def main():
    spec = importlib.util.spec_from_file_location('release_tools', ROOT / 'scripts/install-tools.py')
    tools = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(tools)
    selected, receipt = tools.verify_selection()
    prefix = Path(selected['prefix'])
    assert receipt['sources']['asic']['tree_sha256'] == '53b2bdaf02ee12fe43269cc0a9c1059e89720084ce0614003347ea57c8aa255e'
    assert receipt['sources']['workbench']['tree_sha256'] == 'a8e87a3885720f227c5d5d153ccb684492ccc7eb9d6e7534c24fa7ad522f5b2d'
    for value in receipt['sources'].values():
        assert value['mode'] == 'working-tree' and value['dirty'] and not value['source_artifact_revision_stamped']
    runtime = prefix / 'lib/hardcaml_asic/flow/hardcaml_asic_flow'
    assert tools.digest((runtime / 'physical_runtime.py').read_bytes()) == '82139f81dceb2a24398f7834cacfe8c85ac26823f643f8124db65925cf42a0c5'
    assert tools.digest((runtime / 'librelane_bridge.py').read_bytes()) == '84014826e59384e8977e6249186aafe956af39894470ee39f44a6d348f8959f3'
    metadata = json.loads(subprocess.check_output([str(prefix / 'bin/hardcaml-asic-flow'), '--version', '--json'], timeout=10))
    assert metadata['cli_contract']['capabilities']['timing_reinspection1']
    (EVIDENCE / 'installed-provider-version.json').write_text(json.dumps(metadata, indent=2) + '\n')
    for name in ('hardcaml-asic-flow', 'hardcaml-workbench', 'hardcaml-workbench-daemon'):
        result = subprocess.run([str(prefix / 'bin' / name), '--help'], capture_output=True, timeout=10)
        assert result.returncode == 0
        (EVIDENCE / (name + '-help.stdout')).write_bytes(result.stdout)
        (EVIDENCE / (name + '-help.stderr')).write_bytes(result.stderr)
    status = json.loads(subprocess.check_output(['bash', 'scripts/workbench.sh', 'status'], cwd=ROOT, timeout=30))
    assert status['readiness']['configure_required'] and not status['readiness']['ready']
    (EVIDENCE / 'before-configure-status.json').write_text(json.dumps(status, indent=2) + '\n')
    result = dict(status='passed', selection=selected, source_snapshots_match=True, dirty_receipts_explicit=True,
                  runtime_bridge_pins_match=True, installed_cli_help=True, stale_configuration_correctly_not_ready=True)
    (EVIDENCE / 'installed-verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
