"""Evidence for retiring the installed flat API; prior receipts are historical."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = HERE / 'private-oracle'
PREFIX = ['flock', '/home/wayne/devel/jane/.protemu-build.lock',
          'opam', 'exec', '--switch=5.2.0+ox', '--']
OWNERS = ['mechanisms', 'mechanisms_staging', 'controller', 'core', 'core_legacy',
          'host_link', 'system', 'asic_bringup']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2) + '\n')


def run(name, args, *, cwd=ROOT, env=None, expected=0):
    start = time.monotonic()
    result = subprocess.run(PREFIX + args, cwd=cwd, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (OUT / (name + '.log')).write_text(result.stdout)
    with (OUT / 'commands.jsonl').open('a') as stream:
        stream.write(json.dumps(dict(name=name, argv=PREFIX + args, cwd=str(cwd),
                                     exit=result.returncode, seconds=round(time.monotonic()-start, 3))) + '\n')
    print(f'{name}: exit {result.returncode}', flush=True)
    if expected == 'failure':
        assert result.returncode != 0, result.stdout
    else:
        assert result.returncode == expected, result.stdout
    return result.stdout


def capture():
    OUT.mkdir(exist_ok=True)
    assert not (OUT / 'before.json').exists()
    frozen = ROOT / 'ip/host_link/verif/archived'
    paths = [frozen / '.ocamlformat-ignore', *sorted((frozen / 'hl4a').iterdir())]
    assert len(paths) == 8
    hardware = json.loads((HERE / 'before.json').read_text())['sources']
    save('before.json', dict(frozen={str(p.relative_to(ROOT)):sha(p) for p in paths},
         hardware={row['destination']:sha(ROOT / row['destination']) for row in hardware}))
    print('Captured eight frozen files and 26 current RTL hashes')


def checks():
    run('install-lint', ['dune', 'build', '@install', '@lint',
        '@ip/host_link/verif/archived/support/fmt', '-j5'])
    run('frozen-and-relevant-forced', ['dune', 'build', '--force', '-j5',
        '@ip/host_link/verif/archived/hl4a/runtest', '@ip/host_link/verif/endpoint/runtest',
        '@ip/host_link/verif/command_dispatch/runtest',
        '@ip/emulator_core/verif/core_engine/runtest',
        '@software/simulator/test/runtest'])


def installed():
    attempt = OUT / (sys.argv[2] if len(sys.argv) > 2 else 'installed-check')
    attempt.mkdir()
    install = attempt / 'install'
    assert not install.exists(), 'Fresh isolated install required'
    run('fresh-install', ['dune', 'install', '--prefix', str(install), 'hardcaml_protemu'])
    lib = install / 'lib'
    # Do not let findlib search an ambient old project installation or _build.
    opam_lib = Path(run('opam-lib', ['opam', 'var', 'lib']).strip())
    stdlib = run('ocaml-stdlib', ['ocamlc', '-where']).strip()
    deps = attempt / 'external-deps'
    deps.mkdir()
    excluded = []
    for path in opam_lib.iterdir():
        if path.name.startswith(('hardcaml_protemu', 'protemu')):
            excluded.append(str(path))
            continue
        if path.is_dir() and (path / 'META').exists():
            (deps / path.name).symlink_to(path, target_is_directory=True)
    for path in Path(stdlib).iterdir():
        if path.is_dir() and (path / 'META').exists() and not (deps / path.name).exists():
            (deps / path.name).symlink_to(path, target_is_directory=True)
    config = attempt / 'findlib.conf'
    config.write_text(f'path = "{lib}:{deps}"\nstdlib = "{stdlib}"\ndestdir = "{lib}"\n')
    env = dict(os.environ, OCAMLFIND_CONF=str(config), OCAMLPATH='')
    consumers = attempt / 'consumers'
    consumers.mkdir()
    rows = json.loads((HERE / 'before.json').read_text())['sources']
    packages = ['hardcaml_protemu.' + owner for owner in OWNERS]
    for owner, package in zip(OWNERS, packages):
        matching = [r for r in rows if r['namespace'].split('.')[0].lower() == 'protemu_' + owner]
        assert matching, owner
        source = consumers / (owner + '_consumer.ml')
        source.write_text('\n'.join(f'module Check_{n} = {r["namespace"]}' for n,r in enumerate(matching)) + '\nlet () = ()\n')
        resolved = run('resolve-' + owner, ['ocamlfind', 'query', package], cwd=consumers, env=env).strip()
        assert resolved.startswith(str(lib) + '/'), resolved
        run('consumer-' + owner, ['ocamlfind', 'ocamlopt', '-package', package, '-linkpkg',
                                  str(source), '-o', str(consumers / (owner + '.exe'))], cwd=consumers, env=env)
    negative = consumers / 'reject_flat.ml'
    negative.write_text('module Forbidden = Hardcaml_protemu.Emulator_core\n')
    rejected = run('reject-flat-module', ['ocamlfind', 'ocamlc', '-package', ','.join(packages),
                   '-c', str(negative)], cwd=consumers, env=env, expected='failure')
    assert re.search(r'Unbound module "?Hardcaml_protemu', rejected), rejected
    # A root findlib namespace container is valid; it must expose no flat module.
    root_probe = run('reject-flat-root-package-module', ['ocamlfind', 'ocamlc', '-package',
                    'hardcaml_protemu', '-c', str(negative)], cwd=consumers, env=env, expected='failure')
    assert re.search(r'Unbound module "?Hardcaml_protemu', root_probe) or 'not found' in root_probe
    closure = run('canonical-installed-closure', ['ocamlfind', 'query', '-recursive', '-format', '%p', *packages], cwd=consumers, env=env).splitlines()
    assert 'hardcaml_protemu' not in closure
    dune_package = lib / 'hardcaml_protemu/dune-package'
    text = dune_package.read_text()
    libraries = re.split(r'\n\(library\n', text)[1:]
    names = [re.search(r'\(name ([^\s)]+)\)', section)[1] for section in libraries]
    assert 'hardcaml_protemu' not in names
    for section in libraries:
        requires = re.search(r'\(requires\s+([^)]*)\)', section, re.S)
        assert not requires or 'hardcaml_protemu' not in requires[1].split()
    forbidden = [str(p.relative_to(install)) for p in install.rglob('*')
                 if p.name in ['hardcaml_protemu.ml', 'hardcaml_protemu.cmi',
                               'hardcaml_protemu.cma', 'hardcaml_protemu.cmxa']]
    assert not forbidden
    save('installed-proof.json', dict(canonical_consumers=packages, installed_libraries=names,
         canonical_closure=closure, excluded_ambient_project_paths=excluded,
         isolated_findlib_config=str(config), consumer_cwd=str(consumers),
         root_module_rejected=True, root_package_module_rejected=True,
         installed_flat_library=False, installed_flat_artifacts=forbidden,
         public_dependencies_on_private_shim=False))


def audit():
    before = json.loads((OUT / 'before.json').read_text())
    for collection in before.values():
        assert all(sha(ROOT / path) == digest for path,digest in collection.items())
    assert not (ROOT / 'software/compatibility/hardware').exists()
    references = {}
    for owner in ['asic', 'firmware', 'ip', 'software', 'spec', 'verif']:
        for path in (ROOT / owner).rglob('*'):
            if not path.is_file() or (path.name != 'dune' and path.suffix not in ['.ml', '.mli']):
                continue
            text = path.read_text()
            # Exact flat library token, not canonical subpackages or package metadata.
            if re.search(r'Hardcaml_protemu|(?<![\w.])hardcaml_protemu(?=[\s)])', text):
                references[str(path.relative_to(ROOT))] = True
    allowed = set(before['frozen']) | {'ip/host_link/verif/archived/support/dune'}
    # The remaining adapter's comment may explicitly spell its historical module.
    allowed.add('ip/host_link/verif/archived/support/hardcaml_protemu.ml')
    assert set(references) <= allowed, references
    save('source-proof.json', dict(frozen_files_unchanged=len(before['frozen']),
         rtl_files_unchanged=len(before['hardware']), remaining_flat_references=sorted(references),
         public_hardware_compatibility_tree_removed=True,
         old_installed_identity_receipts='historical only; superseded by installed-proof.json'))
    print('Frozen 8/8 and RTL 26/26 unchanged; only oracle-local flat references remain')


def dune_installed():
    proof = json.loads((OUT / 'installed-proof.json').read_text())
    config = Path(proof['isolated_findlib_config'])
    attempt = config.parent
    env = dict(os.environ, OCAMLFIND_CONF=str(config),
               OCAMLPATH=str(attempt / 'install/lib') + ':' + str(attempt / 'external-deps'),
               DUNE_CACHE='disabled')
    project = attempt / 'dune-canonical'
    project.mkdir()
    (project / 'dune-project').write_text('(lang dune 3.17)\n(name installed_owner_consumers)\n')
    for owner in OWNERS:
        directory = project / owner
        directory.mkdir()
        source = (attempt / 'consumers' / (owner + '_consumer.ml')).read_text()
        (directory / 'consumer.ml').write_text(source)
        (directory / 'dune').write_text(f'(executable (name consumer) (libraries hardcaml_protemu.{owner}))\n')
    run('dune-canonical-installed-consumers', ['dune', 'build', '--root', str(project), '@all', '-j5'], cwd=project, env=env)
    negative = attempt / 'dune-reject-flat'
    negative.mkdir()
    (negative / 'dune-project').write_text('(lang dune 3.17)\n(name reject_flat_library)\n')
    (negative / 'dune').write_text('(executable (name consumer) (libraries hardcaml_protemu))\n')
    (negative / 'consumer.ml').write_text('let () = ()\n')
    error = run('dune-reject-flat-installed-library', ['dune', 'build', '--root', str(negative), '@all', '-j5'], cwd=negative, env=env, expected='failure')
    assert re.search(r'Library ["\']hardcaml_protemu["\'] not found', error), error
    save('dune-installed-proof.json', dict(canonical_installed_consumers=8,
         canonical_consumer_root=str(project), root_library_consumer=str(negative),
         root_library_rejected=True, namespace_container_without_main_library_valid=True))


if __name__ == '__main__':
    {'capture':capture, 'checks':checks, 'installed':installed, 'audit':audit,
     'dune-installed':dune_installed}[sys.argv[1]]()
