#!/usr/bin/env python3
"""Preserve qualified source snapshots and prove live owners match before install."""
import importlib.util
import json
from pathlib import Path
import shutil
import uuid

ROOT = Path(__file__).resolve().parents[1]


def main():
    spec = importlib.util.spec_from_file_location('source_installer', ROOT / 'scripts/install-tools.py')
    tools = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(tools)
    output = ROOT / '_flow_results/workbench/releases' / uuid.uuid4().hex
    output.mkdir(parents=True)
    result = dict(status='capturing', evidence=str(output), sources={})
    for kind, snapshot, expected in (
        ('asic', '/tmp/opencode/asic-timing-release-53b2bdaf02ee12fe',
         '53b2bdaf02ee12fe43269cc0a9c1059e89720084ce0614003347ea57c8aa255e'),
        ('workbench', '/tmp/opencode/workbench-timing-reinspection-a8e87a3885720f22',
         'a8e87a3885720f227c5d5d153ccb684492ccc7eb9d6e7534c24fa7ad522f5b2d')):
        snapshot = Path(snapshot)
        capture = json.loads((snapshot / 'capture.json').read_text())
        passed = json.loads((snapshot / 'testpass.json').read_text())
        owner = Path(capture['path'])
        entries = tools.capture(owner)
        current = tools.source_record(owner, entries)
        assert current['tree_sha256'] == capture['tree_sha256'] == passed['source_tree_sha256'] == expected
        assert current['dirty'] and passed['checks_passed']
        destination = output / kind
        destination.mkdir()
        for path in snapshot.iterdir():
            if path.is_file():
                shutil.copyfile(path, destination / path.name)
        # Authored source only, not the source owner's build cache/products.
        tools.materialize(destination / 'source', entries)
        assert {name: dict(kind=kind_, sha256=tools.digest(data)) for name, (kind_, data) in entries.items()} == capture['files']
        result['sources'][kind] = dict(owner=str(owner), base_revision=current['revision'],
            dirty=current['dirty'], tree_sha256=expected, persistent_snapshot=str(destination),
            testpass_sha256=tools.digest((destination / 'testpass.json').read_bytes()))
    result['status'] = 'frozen_sources_match_qualified_snapshots'
    (output / 'receipt.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
