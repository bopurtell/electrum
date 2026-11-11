#!/usr/bin/env python3
"""Baseline-only evidence capture; never edits sources or the Git index."""
import datetime
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import time

ROOT = Path('/home/wayne/devel/jane/hardcaml_protemu')
OUT = Path(__file__).resolve().parent
SWITCH = '5.2.0+ox'
PREFIX = ['opam', 'exec', '--switch=' + SWITCH, '--', 'dune']
ENV = dict(os.environ, GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1', OMP_NUM_THREADS='1')


def write(name, value):
    path = OUT / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT, env=ENV).decode()


def run(label, args, cwd=ROOT):
    start = time.time()
    log = OUT / 'logs' / (label + '.log')
    log.parent.mkdir(exist_ok=True)
    command = dict(label=label, argv=[str(x) for x in args], cwd=str(cwd),
                   started=datetime.datetime.now(datetime.timezone.utc).isoformat())
    write('running.json', command)
    with log.open('w') as stream:
        try:
            result = subprocess.run(command['argv'], cwd=cwd, env=ENV,
                                    stdout=stream, stderr=subprocess.STDOUT)
            code = result.returncode
        except FileNotFoundError as error:
            stream.write(str(error) + '\n')
            code = 127
    command.update(exit_code=code, elapsed_seconds=round(time.time()-start, 3), log=str(log))
    with (OUT / 'commands.jsonl').open('a') as stream:
        stream.write(json.dumps(command) + '\n')
    print(label, code, command['elapsed_seconds'], flush=True)
    return code


def archive(name, paths, base):
    records = []
    with tarfile.open(OUT / (name + '.tar.gz'), 'w:gz') as tar:
        for path in sorted(paths):
            if path.is_file():
                rel = str(path.relative_to(base))
                records.append(dict(path=rel, sha256=digest(path), size=path.stat().st_size))
                tar.add(path, arcname=rel, recursive=False)
    write(name + '.json', records)
    return records


def build_outputs(name):
    base = ROOT / '_build'
    wanted = {'.v', '.sv', '.trace', '.json', '.sexp', '.sdc', '.yaml', '.yml', '.log', '.output', '.corrected'}
    paths = []
    for directory, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d not in {'.sandbox', '.git', 'node_modules'}]
        for filename in files:
            path = Path(directory) / filename
            if path.suffix in wanted or filename in {'log', 'dune', 'dune-project'}:
                paths.append(path)
    archive(name, paths, base)


def snapshot():
    assert git('rev-parse', 'HEAD').strip() == 'b3a4cb6a420613465f635a616bedba967c4ab307'
    write('initial-status.txt', git('status', '--short', '--untracked-files=all'))
    write('initial-diff.patch', git('diff', '--binary', 'HEAD'))
    write('initial-index.sha256', digest(ROOT / '.git/index') + '\n')
    paths = [ROOT / x for x in git('ls-files', '-z').split('\0') if x]
    records = archive('source-snapshot', paths, ROOT)
    write('frozen-oracle.json', [x for x in records if x['path'].startswith('test/host_link/archived/')])
    registration_paths = [p for p in paths if p.name in {'dune', 'dune-project'} or p.suffix in {'.opam', '.lock'} or '.github/' in str(p.relative_to(ROOT))]
    archive('registrations', registration_paths, ROOT)
    tests = []
    for path in paths:
        if path.suffix == '.ml':
            for number, line in enumerate(path.read_text().splitlines(), 1):
                if re.search(r'let%(test_unit|expect_test|test)\b', line):
                    tests.append(dict(path=str(path.relative_to(ROOT)), line=number, registration=line.strip()))
    write('test-registrations.json', tests)
    build_outputs('existing-build-outputs')
    run('initial-processes', ['ps', '-eo', 'pid,ppid,pcpu,pmem,args'])
    run('opam-packages', ['opam', 'list', '--switch='+SWITCH, '--installed', '--columns=name,version', '--color=never'])
    run('opam-switch', ['opam', 'var', '--switch='+SWITCH, 'prefix'])
    for label, cmd in [('ocaml', ['opam','exec','--switch='+SWITCH,'--','ocamlc','-version']),
                       ('dune', PREFIX+['--version']), ('iverilog', ['iverilog','-V']),
                       ('vvp', ['vvp','-V']), ('verilator', ['verilator','--version']),
                       ('yosys', ['yosys','-V']), ('cxx', ['c++','--version']),
                       ('python', ['python3','--version'])]:
        run('version-'+label, cmd)
    lib = Path.home() / '.opam' / SWITCH / 'lib'
    apis = []
    installed = []
    for package in lib.glob('hardcaml*'):
        if package.is_dir():
            for p in package.rglob('*'):
                if p.is_file():
                    installed.append(dict(path=str(p), sha256=digest(p), size=p.stat().st_size))
                    if p.suffix in {'.ml', '.mli'} or p.name in {'META', 'dune-package', 'opam'}:
                        apis.append(p)
    archive('installed-apis', apis, lib)
    write('installed-hardcaml-files.json', installed)
    bundle_api = lib / 'hardcaml_asic/bundle.mli'
    text = bundle_api.read_text()
    write('tool-compatibility.json', dict(bundle_mli=str(bundle_api), sha256=digest(bundle_api),
        simulation_build_parameter='simulation_build' in text,
        host_tools={x:shutil.which(x) for x in ['iverilog','vvp','verilator','yosys','c++','flock']},
        switch=SWITCH, source_revision=git('rev-parse','HEAD').strip()))
    write('snapshot-complete.txt', datetime.datetime.now(datetime.timezone.utc).isoformat()+'\n')


def checks():
    with open('/home/wayne/devel/jane/.protemu-build.lock', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        run('locked-processes', ['ps', '-eo', 'pid,ppid,pcpu,pmem,args'])
        run('build-install-lint', PREFIX + ['build', '@install', '@lint', '-j5'])
        run('ordinary-runtest', PREFIX + ['runtest', '--force', '-j5'])
        if all(shutil.which(x) for x in ['iverilog', 'vvp', 'verilator', 'yosys']):
            run('rtl', PREFIX + ['build', '@rtl', '--force', '-j5'])
        else:
            write('rtl-unavailable.txt', 'Missing host HDL tool; @rtl not run.\n')
        generated = OUT / 'generated'
        generated.mkdir(exist_ok=True)
        run('generate-observable', PREFIX + ['exec', '-j5', 'bin/generate.exe', '--', '-output', str(generated/'p0_observable.v'), '-module-name', 'p0_observable'])
        for mode in ['access', 'executable', 'integrated', 'loader']:
            run('generate-core-'+mode, PREFIX + ['exec', '-j5', 'bin/generate_core.exe', '--', mode, str(generated/(mode+'.v'))])
        for mode in ['pin_bank','input_events','timing','byte_fifo_8','shift_lane','observed_transfer','observed_transfer_bank','primitive_demo','uart_tx','uart_slice']:
            run('generate-p2-'+mode, PREFIX + ['exec', '-j5', 'bin/generate_p2.exe', '--', mode, str(generated/(mode+'.v'))])
        for role in ['simulation','implementation']:
            run('generate-backend-'+role, PREFIX + ['exec', '-j5', 'test/integration/program_memory_backend/emit_program_memory_backend.exe', '--', role, str(generated/('program_memory_backend.'+role+'.v'))])
        bundles = OUT / 'bundles'
        bundles.mkdir(exist_ok=True)
        for kind in ['observable','memory','loader']:
            run('bundle-'+kind, PREFIX + ['exec', '-j5', 'bin/asic_bundle.exe', '--', kind, str(bundles/kind), str(ROOT)])
            run('bundle-check-'+kind, ['python3', '-B', 'tinytapeout/scripts/check-adopted-bundle.py', '--kind', kind, '--metadata-only'])
            bundle = bundles / kind
            if not (bundle/'manifest.json').exists():
                continue
            # Reuse the existing checker on the retained bundle, in a separately logged process.
            run('retained-metadata-'+kind, ['python3', str(__file__), 'metadata', kind])
            manifest = json.loads((bundle/'manifest.json').read_text())
            top = manifest['top_module']
            for role, key in [('synthesis','synthesis_sources'),('simulation','simulation_sources')]:
                source = bundle / manifest[key][0]
                if kind != 'loader':
                    tb = ROOT / 'tinytapeout/test' / ('tb.v' if kind=='observable' else 'p0_memory_tb.v')
                    exe = OUT / ('wrapper-'+kind+'-'+role)
                    code = run('compile-'+kind+'-'+role, ['iverilog','-g2012','-Wall','-Wno-timescale','-s','tb','-o',str(exe),str(source),str(tb)])
                    if code == 0:
                        run('simulate-'+kind+'-'+role, ['vvp',str(exe)])
                run('lint-'+kind+'-'+role, ['verilator','--lint-only','--top-module',top,'-Wno-DECLFILENAME','-Wno-COMBDLY',str(source)])
                # Both role resource costs are retained as exact same-tool JSON stats.
                stats = OUT / ('synth-'+kind+'-'+role+'.json')
                run('synth-'+kind+'-'+role, ['yosys','-p',f'read_verilog {source}; hierarchy -check -top {top}; synth -top {top}; tee -o {stats} stat -json'])
        build_outputs('baseline-build-outputs')
        archive('generated-outputs', [p for p in generated.rglob('*') if p.is_file()], OUT)
        archive('bundle-outputs', [p for p in bundles.rglob('*') if p.is_file()], OUT)
        before = json.loads((OUT/'source-snapshot.json').read_text())
        changes = [x['path'] for x in before if not (ROOT/x['path']).exists() or digest(ROOT/x['path']) != x['sha256']]
        write('final-source-comparison.json', dict(changed_tracked_paths=changes,
              non_documentation_changes=[x for x in changes if not x.startswith('docs/')],
              index_unchanged=digest(ROOT/'.git/index') == (OUT/'initial-index.sha256').read_text().strip()))
        write('final-status.txt', git('status','--short','--untracked-files=all'))
        write('final-diff.patch', git('diff','--binary','HEAD'))
        write('complete.txt', datetime.datetime.now(datetime.timezone.utc).isoformat()+'\n')


if __name__ == '__main__':
    if sys.argv[1] == 'snapshot':
        snapshot()
    elif sys.argv[1] == 'launch':
        with (OUT/'runner.log').open('w') as stream:
            process = subprocess.Popen([sys.executable, '-B', str(__file__), 'checks'],
                cwd=ROOT, env=ENV, stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
        write('runner.pid', str(process.pid)+'\n')
        print(process.pid)
    elif sys.argv[1] == 'metadata':
        spec = importlib.util.spec_from_file_location('checker', ROOT/'tinytapeout/scripts/check-adopted-bundle.py')
        checker = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(checker)
        kind = sys.argv[2]
        print(checker.check_bundle(ROOT, OUT/'bundles'/kind, kind))
    elif sys.argv[1] == 'checks':
        checks()
