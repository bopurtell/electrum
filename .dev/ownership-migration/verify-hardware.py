"""Hardware-owner preservation checks; never writes the frozen baseline."""

import hashlib
import json
import pathlib
import re
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
BASE = ROOT / '.dev/ownership-migration/20261111-b3a4cb6-baseline'
OUT = ROOT / '.dev/ownership-migration/20261111-hardware-owner'
OUT.mkdir(exist_ok=True)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


snapshot = json.loads((BASE / 'source-snapshot.json').read_text())
old_sources = {pathlib.Path(x['path']).name: x for x in snapshot
               if x['path'].startswith('lib/') and x['path'].endswith('.ml')}
copies = re.findall(r'^\(copy_files (.*?)\)$', (ROOT / 'lib/dune').read_text(), re.M)
assert len(copies) == len(old_sources) == 26
moves = []
for source in copies:
    destination = (ROOT / 'lib' / source).resolve()
    old = old_sources[destination.name]
    digest = sha(destination)
    assert digest == old['sha256'], destination
    assert not (ROOT / old['path']).exists(), old['path']
    moves.append({'old': old['path'], 'new': str(destination.relative_to(ROOT)),
                  'sha256': digest, 'same': True})
(OUT / 'source-map.json').write_text(json.dumps(moves, indent=2) + '\n')
print('PASS: all 26 source SHA-256 hashes match; old authored paths absent', flush=True)

frozen = []
for entry in snapshot:
    path = entry['path']
    if path == 'loader_core.v' or (path.startswith('tinytapeout/src/') and path.endswith('.v')):
        assert sha(ROOT / path) == entry['sha256'], path
        frozen.append(entry)
(OUT / 'frozen-hardware.json').write_text(json.dumps(frozen, indent=2) + '\n')
print(f'PASS: {len(frozen)} tracked frozen hardware outputs unchanged', flush=True)

results = []
commands = [json.loads(line) for line in (BASE / 'commands.jsonl').read_text().splitlines()]
for command in commands:
    if not command['label'].startswith(('generate-observable', 'generate-core-', 'generate-p2-')):
        continue
    argv = [arg.replace(str(BASE), str(OUT)) for arg in command['argv']]
    output = next(pathlib.Path(arg) for arg in argv if arg.endswith('.v'))
    # Baseline output directory is deliberately replaced, never reused.
    output.parent.mkdir(exist_ok=True)
    locked = ['flock', '/home/wayne/devel/jane/.protemu-build.lock'] + argv
    run = subprocess.run(locked, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (OUT / (command['label'] + '.log')).write_bytes(run.stdout)
    result = {'label': command['label'], 'argv': locked, 'exit_code': run.returncode}
    if run.returncode == 0:
        baseline = BASE / 'generated' / output.name
        result.update(sha256=sha(output), baseline_sha256=sha(baseline))
        result['same'] = result['sha256'] == result['baseline_sha256']
    results.append(result)
    print(json.dumps(result), flush=True)
(OUT / 'generated-comparison.json').write_text(json.dumps(results, indent=2) + '\n')
assert len(results) == 15
assert all(r['exit_code'] == 0 and r['same'] for r in results)
print('PASS: all 15 plain observable/core/P2 outputs byte-identical to baseline', flush=True)
