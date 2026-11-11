"""Hardware-owner receipts: source-only deltas, installed identity, exact RTL."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
BASE = ROOT / '.dev/am3/integrated-final-20261111'
PREFIX = ['flock', '/home/wayne/devel/jane/.protemu-build.lock',
          'opam', 'exec', '--switch=5.2.0+ox', '--']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2) + '\n')


def run(name, args, env=None, show_failure=True):
    start = time.monotonic()
    result = subprocess.run(PREFIX + args, cwd=ROOT, env=env,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (OUT / (name + '.log')).write_text(result.stdout)
    with (OUT / 'commands.jsonl').open('a') as stream:
        stream.write(json.dumps(dict(name=name, argv=PREFIX + args, exit=result.returncode,
                                     seconds=round(time.monotonic() - start, 3))) + '\n')
    print(f'{name}: exit {result.returncode}', flush=True)
    if result.returncode and show_failure:
        print(result.stdout)
    assert result.returncode == 0


def sources():
    before = json.loads((OUT / 'before.json').read_text())
    rows = []
    # Only these new cross-owner aliases are permitted changes to authored RTL.
    aliases = re.compile(r'^module \w+ = Protemu_(?:controller|core|host_link|mechanisms)\.\w+\n', re.M)
    for row in before['sources']:
        path = ROOT / row['destination']
        normalized = aliases.sub('', path.read_text()).encode()
        identity = hashlib.sha256(normalized).hexdigest() == row['sha256']
        rows.append(dict(**row, after_sha256=sha(path),
                         unchanged_except_owner_aliases=identity))
        assert identity, row['destination']
    facade = (ROOT / 'software/compatibility/hardware/hardcaml_protemu.ml').read_text()
    expected = {r['old_namespace'].split('.')[-1]: r['namespace'] for r in before['sources']}
    actual = dict(re.findall(r'^module (\w+) = ([\w.]+)$', facade, re.M))
    assert expected == actual
    save('source-comparison.json', dict(sources=rows, exports=actual,
                                      exports_exactly_match_old_26=True))
    print('sources: 26/26 unchanged except owner aliases; exact 26-export facade')


def identity():
    run('build-install', ['dune', 'build', '@install', '-j5'])
    install = OUT / 'install'
    run('install', ['dune', 'install', '--prefix', str(install), 'hardcaml_protemu'])
    rows = json.loads((OUT / 'before.json').read_text())['sources']
    text = ['(* Compiled solely against the installed findlib packages. *)']
    for index, row in enumerate(rows):
        old, new = row['old_namespace'], row['namespace']
        text.append(f'module Check_{index} : module type of {new} = {old}')
        if old.endswith(('.Wire_crc', '.Wire_layout')):
            continue
        components = ['Request', 'Decision', 'Status'] if old.endswith('.Control_port') else ['I', 'O']
        for component in components:
            text.append(f'let old_to_new_{index}_{component.lower()} (x : Hardcaml.Signal.t {old}.{component}.t) : Hardcaml.Signal.t {new}.{component}.t = x')
            text.append(f'let new_to_old_{index}_{component.lower()} (x : Hardcaml.Signal.t {new}.{component}.t) : Hardcaml.Signal.t {old}.{component}.t = x')
    text.append('let () = print_endline "installed facade: 26 module signatures and 98 bidirectional record coercions passed"')
    source = OUT / 'installed_identity.ml'
    source.write_text('\n'.join(text) + '\n')
    # Local installed prefix first; remaining Jane Street packages come from opam.
    env = dict(os.environ, OCAMLPATH=str(install / 'lib') + (':' + os.environ['OCAMLPATH'] if os.environ.get('OCAMLPATH') else ''))
    run('installed-identity-compile', ['ocamlfind', 'ocamlopt', '-package', 'hardcaml_protemu',
                                     '-linkpkg', str(source), '-o', str(OUT / 'installed_identity.exe')], env)
    run('installed-identity-run', [str(OUT / 'installed_identity.exe')], env)
    run('installed-findlib', ['ocamlfind', 'query', 'hardcaml_protemu'], env)


def generate():
    generated = OUT / 'generated'
    generated.mkdir(exist_ok=True)
    records = [json.loads(line) for line in (ROOT / '.dev/ownership-migration/package-tooling-format-post/commands.jsonl').read_text().splitlines()]
    moves = {'bin/generate.exe': 'asic/verif/observable/emit/generate.exe',
             'bin/generate_core.exe': 'verif/system/emit/generate_core.exe',
             'bin/generate_p2.exe': 'ip/mechanisms/verif/emit/generate_p2.exe'}
    for row in records:
        if not row['name'].startswith('generate-'):
            continue
        args = [moves.get(arg, arg.replace(str(ROOT / '.dev/ownership-migration/package-tooling-format-post'), str(OUT))) for arg in row['argv'][4:]]
        run(row['name'], args)
    comparison = {path.name: dict(baseline_sha256=sha(path), current_sha256=sha(generated / path.name),
                                 byte_equal=path.read_bytes() == (generated / path.name).read_bytes())
                  for path in sorted((BASE / 'generated').glob('*.v'))}
    save('generated-comparison.json', comparison)
    assert len(comparison) == 17 and all(row['byte_equal'] for row in comparison.values())
    print('generated: 17/17 byte-identical to AM3 final17')


def scoped():
    owners = ['ip/mechanisms/rtl', 'ip/program_memory_controller/rtl',
              'ip/emulator_core/rtl', 'ip/host_link/rtl', 'ip/protemu_system/rtl',
              'asic/rtl/bringup', 'software/compatibility/hardware']
    run('owner-lint-and-frozen-hl4a', ['dune', 'build', '-j5',
        *['@' + owner + '/lint' for owner in owners],
        '@ip/host_link/verif/archived/hl4a/runtest'])


def bundles(directory='bundles'):
    folder = OUT / directory
    folder.mkdir(exist_ok=True)
    comparison = {}
    for kind in ['observable', 'memory', 'loader']:
        current = folder / kind
        run('bundle-' + kind, ['dune', 'exec', '-j5', 'asic/cli/asic_bundle.exe',
                              '--', kind, str(current), str(ROOT)])
        old = json.loads((BASE / 'bundles' / kind / 'manifest.json').read_text())
        new = json.loads((current / 'manifest.json').read_text())
        for role in ['simulation', 'synthesis']:
            oldpaths = [BASE / 'bundles' / kind / path for path in old[role + '_sources']]
            newpaths = [current / path for path in new[role + '_sources']]
            assert len(oldpaths) == len(newpaths) == 1
            a, b = oldpaths[0], newpaths[0]
            comparison[kind + '-' + role] = dict(baseline_sha256=sha(a), current_sha256=sha(b),
                                                byte_equal=a.read_bytes() == b.read_bytes())
    save('bundle-comparison.json' if directory == 'bundles' else directory + '-comparison.json', comparison)
    assert all(row['byte_equal'] for row in comparison.values())
    print('bundles: 6/6 roles byte-identical to AM3')


if __name__ == '__main__':
    {'sources': sources, 'identity': identity, 'generate': generate,
     'scoped': scoped, 'bundles': lambda: bundles(sys.argv[2] if len(sys.argv) > 2 else 'bundles')}[sys.argv[1]]()
