#!/usr/bin/env python3
"""Actual installed CLI and production reader-consumer checks over retained b591."""
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT / '_flow_results/workbench/releases/714edccf3d934c1b99ce50c6930c7948'
EXECUTION = ROOT / '_flow_results/workbench/asic/fresh-7fc1c6b0da7db33c659e59f722960f04142f0f7e5245c4b1fadab25422b46802/execution-b591d335b32a49b8a019739ef7044e4e.json'


def main():
    output = RELEASE / 'installed-reinspection'
    output.mkdir(exist_ok=False)
    spec = importlib.util.spec_from_file_location('checked_tools', ROOT / 'scripts/install-tools.py')
    tools = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(tools)
    selection, receipt = tools.verify_selection()
    provider = Path(selection['prefix']) / 'bin/hardcaml-asic-flow'
    execution = json.loads(EXECUTION.read_text())
    observation = Path(execution['methodology']['snapshot_path']).parent
    protected = [EXECUTION, Path(str(EXECUTION) + '.timing-source'), Path(str(EXECUTION) + '.timing-source.timing-analysis.json')]
    protected += [p for p in observation.iterdir() if p.is_file()]
    before = {str(p): tools.digest(p.read_bytes()) for p in protected}
    args = [str(provider), 'inspect', str(EXECUTION), '--domain', 'timing', '--stage', 'timing', '--refresh-timing', '--json']
    result = subprocess.run(args, capture_output=True, check=True, timeout=120)
    (output / 'index.json').write_bytes(result.stdout)
    (output / 'index.stderr').write_bytes(result.stderr)
    index = json.loads(result.stdout)
    assert len(index['rows']) == 193
    row = next(r for r in index['rows'] if r.get('category') == 'timing_path' and
               r.get('corner') == 'nom_slow_1p08V_125C' and r.get('unit') == 'ns' and r.get('value') == -3.099803)
    result = subprocess.run(args + ['--row-id', row['id'], '--expected-digest', index['source_digest']],
                            capture_output=True, check=True, timeout=120)
    (output / 'detail.json').write_bytes(result.stdout)
    (output / 'detail.stderr').write_bytes(result.stderr)
    detail = json.loads(result.stdout)
    assert '-3.099803' in json.dumps(detail)
    consumer = ROOT.parent / 'hardcaml_workbench/_build/default/backend/test/inspection/test_timing_analysis.exe'
    result = subprocess.run([str(consumer), '--retained-refresh', str(EXECUTION), str(provider)],
                            cwd=ROOT.parent / 'hardcaml_workbench', capture_output=True, check=True, timeout=180)
    (output / 'production-service-consumer.stdout').write_bytes(result.stdout)
    (output / 'production-service-consumer.stderr').write_bytes(result.stderr)
    native_evidence = Path(re.search(r'Evidence: (\S+)', result.stdout.decode())[1])
    shutil.copytree(native_evidence, output / 'production-service-evidence')
    after = {str(p): tools.digest(p.read_bytes()) for p in protected}
    assert before == after, 'retained execution/observation/journal changed'
    proof = dict(status='passed', actual_installed_provider=str(provider), execution=str(EXECUTION),
        rows=193, negative_row_id=row['id'], negative_ns=row['value'], journal_and_original_unchanged=True,
        protected_sha256=before, production_service_consumer=str(consumer),
        consumer_source_tree_sha256=receipt['sources']['workbench']['tree_sha256'],
        acceptance_scope='installed CLI plus actual production Service consumer; production installed UI checked separately')
    (output / 'receipt.json').write_text(json.dumps(proof, indent=2) + '\n')
    print(json.dumps(proof, indent=2))


if __name__ == '__main__':
    main()
