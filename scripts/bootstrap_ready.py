"""Cheap invalidation for the last successful bootstrap, not a toolchain audit."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
STAMP = '.dev/bootstrap-ready.json'
SOURCES = (
    'bootstrap.sh', 'dune', 'dune-project', 'electrum.opam', 'tools-source.lock.json',
    'hardcaml-asic-targets.json', 'asics', 'asic_support', 'ip', 'spec', 'scripts',
    'software', 'verif', 'firmware',
)


def fingerprint(root, no_container):
    selected = json.loads((root / '.dev/tools/current.json').read_bytes())
    receipt = json.loads(Path(selected['receipt']).read_bytes())
    config = json.loads((root / '.dev/workbench/configuration.json').read_bytes())
    prefix, switch = Path(selected['prefix']), Path(receipt['switch_prefix'])
    if (not receipt['checks_passed'] or config['prefix'] != str(prefix)
            or config['receipt'] != selected['receipt']
            or switch.name != os.environ.get('OPAM_SWITCH', '5.2.0+ox')):
        raise ValueError('different selected tools')
    for command in ('opam', 'dune', 'silver'):
        if shutil.which(command) is None:
            raise ValueError(f'{command} not on PATH')
    digest = hashlib.sha256()

    def add(data):
        digest.update(len(data).to_bytes(8, 'big'))
        digest.update(data)

    def observe(path, *, required=True):
        add(os.fsencode(path))
        try:
            stat = path.stat()
        except FileNotFoundError:
            if required:
                raise
            add(b'missing')
        else:
            add(str((stat.st_mode, stat.st_size, stat.st_mtime_ns, stat.st_ctime_ns,
                     stat.st_dev, stat.st_ino)).encode())

    add(str((no_container, os.environ.get('DOCKER_HOST'), os.environ.get('DOCKER_CONTEXT'))).encode())
    for relative in (
        '.dev/tools/current.json', '.dev/workbench/configuration.json', 'dune-workspace',
        '.workbench/hardcaml-workbench-asic.sexp',
        '.workbench/hardcaml-workbench-preparation.sexp',
        '_flow_tools/toolchain-env.sh', '_flow_tools/tt/.git/HEAD',
        '_flow_tools/pdk/.git/HEAD', '_flow_tools/.venv/bin/python',
        '_flow_tools/.venv-precheck/bin/python', '_flow_tools/.venv/pyvenv.cfg',
        '_flow_tools/.venv-precheck/pyvenv.cfg',
        '_flow_tools/.venv/lib/python3.11/site-packages/librelane/flows/classic.py',
        '_build/default/' + config['build_target'],
    ):
        observe(root / relative)
    for path in (Path(selected['receipt']), prefix / 'bin/hardcaml-asic-flow',
                 prefix / 'bin/hardcaml-asic-starter', switch / 'bin/dune',
                 switch / '.opam-switch/switch-state'):
        observe(path)
    for repo in ('tt', 'pdk'):
        git = root / '_flow_tools' / repo / '.git'
        observe(git / 'index', required=False)
        head = (git / 'HEAD').read_text().strip()
        if head.startswith('ref: '):
            observe(git / head[5:], required=False)
            observe(git / 'packed-refs', required=False)
    for entry in json.loads((root / 'hardcaml-asic-targets.json').read_bytes())['targets']:
        observe(root / '_build/default' / entry['executable'])
    # Include local edits and new flow declarations, not generated outputs.
    paths = subprocess.check_output(
        ['git', 'ls-files', '-c', '-o', '--exclude-standard', '-z', '--', *SOURCES],
        cwd=root, env={**os.environ, 'GIT_OPTIONAL_LOCKS': '0'})
    for path in sorted(set(paths.split(b'\0')) - {b''}):
        observe(root / os.fsdecode(path), required=False)
    return digest.hexdigest()


def main():
    action, no_container = sys.argv[1:]
    stamp = ROOT / STAMP
    try:
        if action == 'check':
            return 0 if json.loads(stamp.read_bytes()) == fingerprint(ROOT, no_container) else 1
        value = fingerprint(ROOT, no_container)
        with tempfile.NamedTemporaryFile(dir=stamp.parent, delete=False) as pending:
            pending.write((json.dumps(value) + '\n').encode())
        os.replace(pending.name, stamp)
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError):
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
