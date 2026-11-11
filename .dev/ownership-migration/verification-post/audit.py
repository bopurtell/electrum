"""Read-only verification relocation audit against the persistent source baseline.

Print the complete per-file path/hash/mode and inline-registration comparison as JSON.
Use --summary for the owner-group counts and aggregate digests used in the handoff.
"""

import collections
import hashlib
import json
from pathlib import Path
import re
import sys
import tarfile

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / '.dev/ownership-migration/20261111-b3a4cb6-baseline'
GROUPS = {
    **{f'test/primitives/{name}/': f'ip/mechanisms/verif/blocks/{name}/'
       for name in ('byte_fifo', 'input_events', 'pin_bank', 'shift_lane', 'timing')},
    **{f'test/primitives/{name}/': f'ip/mechanisms/verif/staging/{name}/'
       for name in ('observed_transfer', 'uart_tx')},
    **{f'test/integration/{name}/': f'ip/mechanisms/verif/staging/{name}/'
       for name in ('observed_transfer_bank', 'primitive_demo', 'uart_slice')},
    'test/core/protocol_core/': 'ip/program_memory_controller/verif/controller/',
    'test/integration/program_memory_backend/':
        'ip/program_memory_controller/verif/backend_integration/',
    'test/core/control_execution/': 'ip/emulator_core/verif/execution/',
    'test/core/control_port/': 'ip/emulator_core/verif/control_port/',
    'test/integration/core_engine/': 'ip/emulator_core/verif/core_engine/',
    'test/host_link/': 'ip/host_link/verif/',
    'test/integration/wrapper/': 'chip_top/verif/observable/core/',
    'test/integration/host_simulator/': 'test/host_simulator/',
}
COMMON = {
    'observation.ml': 'verif/common/observation.ml',
    'replay.ml': 'verif/common/replay.ml',
    'env.ml': 'verif/common/env.ml',
    'dune': 'verif/common/dune',
    'checker_expect_tests.ml': 'test/verification_support/checker_expect_tests.ml',
    'replay_expect_tests.ml': 'test/verification_support/replay_expect_tests.ml',
    **{name: 'test/backend_conformance/' + name for name in (
        'backend_conformance.ml', 'backend_conformance_expect_tests.ml',
        'backend_conformance_bench.ml')},
}


def destination(path):
    for old, new in GROUPS.items():
        if path.startswith(old):
            return new + path[len(old):], old
    if path.startswith('test/common/'):
        return COMMON[path.removeprefix('test/common/')], 'test/common/'
    if path in ('test/dune', 'test/verification_sweep.ml'):
        return 'verif/regression/' + path.removeprefix('test/'), 'test/ sweep'
    return path, 'retained'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def registrations(data):
    return re.findall(r'^\s*(let%(?:expect_test|test_unit|test)\b[^\n]*)',
                      data.decode(), re.MULTILINE)


def expects(data):
    # Compare entire expectation forms, including whitespace and delimiters.
    return re.findall(rb'\[%expect(?:_exact)?\s+\{\|.*?\|\}\]', data, re.DOTALL)


def main():
    source = json.loads((BASE / 'source-snapshot.json').read_text())
    baseline_regs = json.loads((BASE / 'test-registrations.json').read_text())
    files = []
    groups = collections.defaultdict(lambda: {'files': 0, 'byte_identical': 0,
                                             'registrations': 0})
    expected_regs = []
    with tarfile.open(BASE / 'source-snapshot.tar.gz') as archive:
        members = {m.name.removeprefix('./'): m for m in archive.getmembers()}
        for entry in source:
            old = entry['path']
            new, group = destination(old)
            if new == old:
                continue
            data = (ROOT / new).read_bytes()
            member = members[old]
            before = archive.extractfile(member).read()
            assert sha(before) == entry['sha256'], old
            mode = (ROOT / new).stat().st_mode & 0o777
            assert mode == member.mode & 0o777, (old, 'mode changed')
            assert registrations(before) == registrations(data), (old, 'registrations')
            assert expects(before) == expects(data), (old, 'expect bytes')
            row = {'old': old, 'new': new, 'baseline_sha256': sha(before),
                   'sha256': sha(data), 'byte_identical': before == data,
                   'mode': oct(mode), 'registrations': len(registrations(data))}
            files.append(row)
            groups[group]['files'] += 1
            groups[group]['byte_identical'] += before == data
            groups[group]['registrations'] += row['registrations']

    for reg in baseline_regs:
        new, _ = destination(reg['path'])
        expected_regs.append((new, reg['registration']))
        assert reg['registration'] in (ROOT / new).read_text(), reg
    actual_regs = []
    for tree in ('test', 'ip', 'verif', 'chip_top'):
        for path in (ROOT / tree).rglob('*.ml'):
            actual_regs.extend((str(path.relative_to(ROOT)), reg)
                               for reg in registrations(path.read_bytes()))
    assert collections.Counter(expected_regs) == collections.Counter(actual_regs)
    frozen = []
    for entry in json.loads((BASE / 'frozen-oracle.json').read_text()):
        new, _ = destination(entry['path'])
        digest = sha((ROOT / new).read_bytes())
        assert digest == entry['sha256'], new
        frozen.append({'path': new, 'sha256': digest})
    # Pure model/software/codec trees and existing workflow execute bit stay intact.
    for entry in source:
        if entry['path'].startswith(('f_model/', 'isa/', 'host_link_wire/',
                                      'test/f_model/', 'test/host/', 'test/host_link_wire/')):
            assert sha((ROOT / entry['path']).read_bytes()) == entry['sha256']
    script_mode = (ROOT / 'scripts/p3.4-cli-workflow.sh').stat().st_mode & 0o777
    assert script_mode & 0o111
    summary = {
        'baseline': 'b3a4cb6a420613465f635a616bedba967c4ab307',
        'moved_files': len(files),
        'byte_identical_moved_files': sum(f['byte_identical'] for f in files),
        'moved_inline_registrations': sum(f['registrations'] for f in files),
        'total_inline_registrations': len(actual_regs),
        'registration_map_sha256': sha(json.dumps(sorted(expected_regs)).encode()),
        'file_map_sha256': sha(json.dumps(files, sort_keys=True).encode()),
        'all_registration_text_and_expect_bytes_preserved': True,
        'all_moved_modes_preserved': True,
        'workflow_mode': oct(script_mode),
        'groups': dict(groups),
        'changed_moved_files': [f['new'] for f in files if not f['byte_identical']],
        'frozen': frozen,
    }
    print(json.dumps(summary if '--summary' in sys.argv else
                     {'summary': summary, 'files': files,
                      'registrations': expected_regs}, indent=2))


if __name__ == '__main__':
    main()
