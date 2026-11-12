#!/usr/bin/env python3
"""Install captured ASIC + Workbench sources locally; never modify an opam switch.

Usage: python3 scripts/install-tools.py [--asic-source PATH] [--workbench-source PATH]
Then source scripts/env.sh. Failed generations and previous selections are retained.
"""
import argparse
import contextlib
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import stat
import subprocess
import sys
import uuid

ROOT = Path(__file__).resolve().parents[1]
STORE = ROOT / '.dev/tools'
SOURCE_LOCK = ROOT / 'tools-source.lock.json'


def source_policy():
    value = json.loads(SOURCE_LOCK.read_text())
    if value['schema_version'] != 1 or value['scope'] != 'normal-project-local-tools':
        raise ValueError('unsupported normal tools source policy')
    for key in ('pinned_revision', 'compatibility_base_revision'):
        if not re.fullmatch(r'[0-9a-f]{40}', value['asic'][key]):
            raise ValueError('normal tools policy needs full ASIC revisions')
    return value


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(source, *args):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env['GIT_OPTIONAL_LOCKS'] = '0'
    return subprocess.check_output(['git', '-C', str(source), *args], env=env)


def capture(source):
    if Path(os.fsdecode(git(source, 'rev-parse', '--show-toplevel')).strip()).resolve() != source:
        raise ValueError('source must be a Git checkout root: ' + str(source))
    entries = {}
    for raw in sorted(set(git(source, 'ls-files', '-z', '--cached', '--others', '--exclude-standard').split(b'\0')) - {b''}):
        name = os.fsdecode(raw)
        if any(part in ('.git', '.dev', '__pycache__') or part.startswith('_build') for part in Path(name).parts):
            continue
        path = source / name
        if path.parent.resolve() != path.parent:
            raise ValueError('symlinked source parent: ' + str(path))
        try:
            info = path.lstat()
        except FileNotFoundError:
            continue
        if stat.S_ISLNK(info.st_mode):
            entries[name] = ('link', os.fsencode(os.readlink(path)))
        elif stat.S_ISREG(info.st_mode):
            entries[name] = ('executable' if info.st_mode & 0o111 else 'file', path.read_bytes())
        else:
            raise ValueError('unsupported source: ' + str(path))
    return entries


def source_record(source, entries):
    files = {name: dict(kind=kind, sha256=digest(data)) for name, (kind, data) in entries.items()}
    status = git(source, 'status', '--porcelain', '--untracked-files=all').decode()
    return dict(path=str(source), revision=git(source, 'rev-parse', 'HEAD').decode().strip(),
                dirty=bool(status), status=status, files=files,
                tree_sha256=digest(json.dumps(files, sort_keys=True).encode()))


def committed(source, revision):
    entries = {}
    revision = git(source, 'rev-parse', revision + '^{commit}').decode().strip()
    for item in git(source, 'ls-tree', '-rz', revision).split(b'\0'):
        if not item:
            continue
        header, raw = item.split(b'\t', 1)
        mode, kind, oid = header.decode().split()
        if kind != 'blob' or mode not in ('100644', '100755', '120000'):
            raise ValueError('unsupported committed source: ' + os.fsdecode(raw))
        entries[os.fsdecode(raw)] = (dict({'100644': 'file', '100755': 'executable', '120000': 'link'})[mode],
                                     git(source, 'cat-file', 'blob', oid))
    return revision, entries


def materialize(destination, entries):
    destination.mkdir(parents=True)
    for name, (kind, data) in entries.items():
        path = destination / name
        path.parent.mkdir(parents=True, exist_ok=True)
        if kind == 'link':
            # Repository-relative links remain relative in the captured checkout.
            target = os.fsdecode(data)
            if Path(target).is_absolute() or not (path.parent / target).resolve().is_relative_to(destination):
                raise ValueError('source link escapes capture: ' + name)
            path.symlink_to(target)
        else:
            path.write_bytes(data)
            path.chmod(0o755 if kind == 'executable' else 0o644)


def inventory(prefix):
    result = {}
    for path in sorted(prefix.rglob('*')):
        if path.is_symlink():
            raise ValueError('installed symlink: ' + str(path))
        if path.is_file():
            result[str(path.relative_to(prefix))] = digest(path.read_bytes())
    return result


def environment(switch, prefix=None):
    env = {key: value for key, value in os.environ.items() if not key.startswith('GIT_')}
    env['GIT_OPTIONAL_LOCKS'] = '0'
    for key in ('DUNE_BUILD_DIR', 'DUNE_WORKSPACE', 'DUNE_PROFILE', 'OCAMLFIND_CONF',
                'OCAMLFIND_DESTDIR', 'OCAMLFIND_TOOLCHAIN'):
        env.pop(key, None)
    env.update(PATH=f'{switch}/bin:/usr/local/bin:/usr/bin:/bin',
               OCAMLPATH=f'{prefix}/lib:{switch}/lib' if prefix else str(switch / 'lib'),
               CAML_LD_LIBRARY_PATH=f'{switch}/lib/stublibs',
               OPAM_SWITCH_PREFIX=str(switch), OCAMLLIB=str(switch / 'lib/ocaml'),
               CAMLLIB=str(switch / 'lib/ocaml'), DUNEJOBS='10', OPAMJOBS='10',
               OMP_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', MKL_NUM_THREADS='1',
               HARDCAML_ASIC_TEST_WORKERS='12', PYTHONDONTWRITEBYTECODE='1')
    return env


def run(argv, cwd, env, log):
    if Path(argv[0]).name == 'dune':
        argv = [argv[0], argv[1], '--root', str(cwd), *argv[2:]]
    print('+ ' + shlex.join(map(str, argv)), flush=True)
    with log.open('ab') as stream:
        subprocess.run(list(map(str, argv)), cwd=cwd, env=env, stdout=stream,
                       stderr=subprocess.STDOUT, check=True)


@contextlib.contextmanager
def build_lock(root):
    path = root.parent / ('.' + root.name.removeprefix('hardcaml_') + '-build.lock')
    with path.open('a') as stream:
        fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        yield


def install(args):
    if args.resume and not re.fullmatch(r'[0-9a-f]{32}', args.resume):
        raise ValueError('--resume requires a generation ID')
    sources = dict(asic=args.asic_source.resolve(strict=True),
                   workbench=args.workbench_source.resolve(strict=True))
    switch = Path(subprocess.check_output(['opam', 'var', '--switch=' + args.switch, 'prefix'], text=True).strip()).resolve(strict=True)
    STORE.mkdir(parents=True, exist_ok=True)
    with (STORE / 'install.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        if (STORE / 'current.json').exists():
            verify_selection()
        generation = STORE / 'generations' / (args.resume or uuid.uuid4().hex)
        if args.resume:
            if (generation / 'receipt.json').exists():
                raise ValueError('completed generations cannot be resumed')
        else:
            generation.mkdir(parents=True)
        receipt = dict(schema_version=1, generation=str(generation), switch_prefix=str(switch),
                       checks_passed=False, sources={})
        if args.resume:
            prior_capture = json.loads((generation / 'capture.json').read_text())
            if prior_capture['generation'] != str(generation) or prior_capture['switch_prefix'] != str(switch):
                raise ValueError('resume selection differs from captured generation')
            if 'source_policy' in prior_capture:
                receipt['source_policy'] = prior_capture['source_policy']
                verify_captured_policy(generation, receipt)
        else:
            policy = source_policy()
            receipt['source_policy'] = dict(lock=str(SOURCE_LOCK), lock_sha256=digest(SOURCE_LOCK.read_bytes()),
                captured_lock='tools-source.lock.json', policy=policy,
                identity_scope='captured compiler/library source inventory; not a CLI revision stamp')
            (generation / 'tools-source.lock.json').write_bytes(SOURCE_LOCK.read_bytes())
        prefix = generation / 'prefix'
        log = generation / 'build.log'
        for name, source in sources.items():
            captured = generation / 'source' / name
            with build_lock(source):
                prior = json.loads((generation / 'capture.json').read_text()) if args.resume else None
                if captured.exists():
                    record = prior['sources'][name]
                    entries = {p: (v['kind'], os.fsencode(os.readlink(captured / p)) if v['kind'] == 'link'
                               else (captured / p).read_bytes()) for p, v in record['files'].items()}
                    if any(digest(data) != record['files'][p]['sha256'] for p, (_, data) in entries.items()):
                        raise ValueError('captured source changed')
                    receipt['sources'][name] = record
                else:
                    capture_source(name, source, captured, generation, receipt, args)
            packages = 'hardcaml_asic' if name == 'asic' else 'hardcaml_workbench,hardcaml_workbench_provider'
            env = environment(switch, prefix)
            run([switch / 'bin/dune', 'build', '-j10', '--only-packages', packages, '@install'], captured, env, log)
            if name == 'asic':
                run([switch / 'bin/dune', 'runtest', '-j1'], captured, env, log)
            else:
                run([switch / 'bin/dune', 'runtest', '-j2', 'backend/test/asic'], captured, env, log)
            run([switch / 'bin/dune', 'install', '--prefix', prefix, *packages.split(',')], captured, env, log)
        finish(generation, receipt, prefix, switch)


def capture_source(name, source, captured, generation, receipt, args):
    mode = args.asic_source_mode if name == 'asic' else 'working-tree'
    revision, entries = committed(source, args.asic_revision) if mode == 'committed' else (None, capture(source))
    receipt['sources'][name] = source_record(source, entries)
    record = receipt['sources'][name]
    record.update(mode=mode, base_revision=revision or record['revision'], source_artifact_revision_stamped=False)
    if mode == 'committed':
        receipt['sources'][name].update(revision=revision, dirty=False, status='', mode='committed')
        record['revision_semantics'] = 'exact committed source capture; installed CLI source stamp remains independent'
    else:
        record['revision_semantics'] = 'checkout HEAD provenance only; tree_sha256/files identify actual captured working bytes'
    if name == 'asic':
        policy = receipt['source_policy']['policy'] if 'source_policy' in receipt else source_policy()
        record['compatibility_base_revision'] = policy['asic']['compatibility_base_revision']
    if mode == 'working-tree' and capture(source) != entries:
        raise ValueError('source changed during capture; retry: ' + str(source))
    materialize(captured, entries)
    # A few upstream source tests discover their root with Git.
    # This read-only metadata pointer needs no init, index or commit.
    gitdir = git(source, 'rev-parse', '--absolute-git-dir').decode().strip()
    (captured / '.git').write_text('gitdir: ' + gitdir + '\n')
    (generation / 'capture.json').write_text(json.dumps(receipt, indent=2) + '\n')


def finish(generation, receipt, prefix, switch):
    receipt.update(checks_passed=True, prefix=str(prefix), installed_sha256=inventory(prefix),
                   checks=['ASIC standard dune runtest -j1 (12 internal workers)',
                           'Workbench backend/test/asic -j2'], build_jobs=10)
    (generation / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    selection = dict(schema_version=1, generation=str(generation), prefix=str(prefix),
                     receipt=str(generation / 'receipt.json'))
    pending = STORE / ('selection-' + uuid.uuid4().hex + '.json')
    pending.write_text(json.dumps(selection, indent=2) + '\n')
    os.replace(pending, STORE / 'current.json')
    # Selection is data; env.sh asks this script to verify before activation.
    print(json.dumps(selection, indent=2))


def verify_captured_policy(generation, receipt):
    if 'source_policy' not in receipt:
        return
    policy = receipt['source_policy']
    if policy['captured_lock'] != 'tools-source.lock.json':
        raise ValueError('foreign captured tools source policy')
    data = (generation / policy['captured_lock']).read_bytes()
    if digest(data) != policy['lock_sha256'] or json.loads(data) != policy['policy']:
        raise ValueError('captured tools source policy changed')


def verify_selection():
    if (STORE / 'current.json').is_symlink():
        raise ValueError('symlinked tools selection')
    value = json.loads((STORE / 'current.json').read_text())
    generation = Path(value['generation'])
    if generation.parent != STORE / 'generations' or generation.resolve() != generation:
        raise ValueError('foreign tools generation')
    receipt = json.loads((generation / 'receipt.json').read_text())
    if (receipt['checks_passed'] is not True or receipt['prefix'] != value['prefix']
            or Path(value['prefix']) != generation / 'prefix'
            or value['receipt'] != str(generation / 'receipt.json')):
        raise ValueError('invalid tools receipt')
    verify_captured_policy(generation, receipt)
    if inventory(Path(value['prefix'])) != receipt['installed_sha256']:
        raise ValueError('installed tools inventory changed')
    return value, receipt


def activation():
    value, receipt = verify_selection()
    generation = Path(value['generation'])
    prefix, switch = Path(value['prefix']), Path(receipt['switch_prefix'])
    # Generate from validated metadata, never evaluate a mutable activation file.
    print(f'export PROTEMU_TOOLS_RECEIPT={shlex.quote(str(generation / "receipt.json"))}')
    print(f'export PROTEMU_TOOLS_PREFIX={shlex.quote(str(prefix))}')
    print(f'export OCAMLPATH={shlex.quote(str(prefix / "lib") + ":" + str(switch / "lib"))}')
    for key, path in dict(OPAM_SWITCH_PREFIX=switch, OCAMLLIB=switch / 'lib/ocaml',
                          CAMLLIB=switch / 'lib/ocaml',
                          CAML_LD_LIBRARY_PATH=switch / 'lib/stublibs').items():
        print(f'export {key}={shlex.quote(str(path))}')
    print('unset OCAMLFIND_CONF OCAMLFIND_DESTDIR OCAMLFIND_TOOLCHAIN DUNE_BUILD_DIR DUNE_WORKSPACE DUNE_PROFILE')
    # Re-sourcing replaces this project's old selection rather than stacking it.
    paths = [p for p in os.environ.get('PATH', '').split(os.pathsep)
             if not p.startswith(str(STORE / 'generations') + '/') and p != str(switch / 'bin')]
    print(f'export PATH={shlex.quote(os.pathsep.join([str(prefix / "bin"), str(switch / "bin"), *paths]))}')


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--asic-source', type=Path, default=ROOT.parent / 'hardcaml_asic')
    parser.add_argument('--workbench-source', type=Path, default=ROOT.parent / 'hardcaml_workbench')
    parser.add_argument('--switch', default='5.2.0+ox')
    parser.add_argument('--asic-revision',
                        help='Exact committed ASIC source (default tools-source.lock.json pinned_revision)')
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--asic-source-mode', choices=('committed', 'working-tree'), default='committed',
                       help='committed: pinned release; working-tree: explicit full dirty/hash capture')
    modes.add_argument('--development', dest='asic_source_mode', action='store_const', const='working-tree',
                       help='alias for --asic-source-mode working-tree; no Git commit required')
    parser.add_argument('--activation', action='store_true')
    parser.add_argument('--resume', help='Resume an interrupted unpublished generation, verifying its captured sources')
    args = parser.parse_args(argv)
    if args.asic_source_mode == 'working-tree' and args.asic_revision is not None:
        parser.error('--asic-revision is a committed selection; working-tree records its actual HEAD as provenance')
    if args.asic_source_mode == 'committed' and args.asic_revision is None and not args.activation:
        args.asic_revision = source_policy()['asic']['pinned_revision']
    return args


def main():
    args = parse_args()
    if args.activation:
        activation()
    else:
        install(args)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        print('install-tools: ' + str(error), file=sys.stderr)
        sys.exit(2)
