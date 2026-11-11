"""Fresh AM3 integration receipts; historical ownership evidence is read-only."""
import datetime
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import time

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
OWN = ROOT / '.dev/ownership-migration'
BASE = OWN / 'package-tooling-format-post'
ORIGINAL = OWN / '20261111-b3a4cb6-baseline'
REV = '0bb9abc742b3eefbcaa83c39189b08d4f99cea8a'
PREFIX = ['flock', '/home/wayne/devel/jane/.protemu-build.lock',
          'opam', 'exec', '--switch=5.2.0+ox', '--']
ENV = dict(os.environ, GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')

def sha(data):
    return hashlib.sha256(data).hexdigest()

def save(name, obj):
    path = OUT / name
    assert not path.exists(), f'refusing to overwrite receipt {path}'
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + '\n')

def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT, env=ENV)

def run(name, args, *, heavy=True, allow_failure=False):
    (OUT / 'logs').mkdir(exist_ok=True)
    logfile = OUT / 'logs' / (name + '.log')
    assert not logfile.exists(), f'refusing to overwrite {logfile}'
    argv = PREFIX + args if heavy else args
    start = time.monotonic()
    stamp = datetime.datetime.now(datetime.timezone.utc).isoformat()
    with logfile.open('x') as log:
        result = subprocess.run(argv, cwd=ROOT, env=ENV, stdout=log, stderr=subprocess.STDOUT)
    record = dict(name=name, argv=argv, cwd=str(ROOT), started_utc=stamp,
                  seconds=round(time.monotonic()-start, 3), exit=result.returncode)
    with (OUT / 'timing_commands.jsonl').open('a') as stream:
        stream.write(json.dumps(record) + '\n')
    print(json.dumps(record), flush=True)
    if not allow_failure:
        assert result.returncode == 0, (name, result.returncode)
    return result.returncode

def source_state():
    paths = git('ls-files', '--cached', '--others', '--exclude-standard', '-z').decode().split('\0')
    return {p: sha((ROOT/p).read_bytes()) for p in paths
            if p and not p.startswith(('.dev/', '_build/')) and (ROOT/p).is_file()}

def baseline():
    assert git('rev-parse', 'HEAD').decode().strip() == REV
    if not (OUT/'initial-state.json').exists():
        save('initial-source-hashes.json', source_state())
        save('initial-state.json', dict(revision=REV,
            status=git('status', '--short').decode(),
            index_sha256=sha((ROOT/'.git/index').read_bytes()),
            git_config_sha256=sha((ROOT/'.git/config').read_bytes())))
        (OUT/'starting-tracked.patch').write_bytes(git('diff', '--', '.', ':!.dev'))
    else:
        assert source_state() == json.loads((OUT/'initial-source-hashes.json').read_text())
    verified = {}
    # Exact saved copied bundle inputs are the complete package elaboration closure.
    for kind in ['observable', 'memory', 'loader']:
        manifest = json.loads((BASE/'bundles'/kind/'manifest.json').read_text())
        for row in manifest['source_inputs']:
            p = row['path']
            copied = (BASE/'bundles'/kind/'inputs'/p).read_bytes()
            assert sha(copied) == row['sha256'], p
            assert copied == git('show', f'{REV}:{p}'), p
            verified[p] = sha(copied)
    for p, digest in json.loads((BASE/'source-hashes.json').read_text()).items():
        assert sha(git('show', f'{REV}:{p}')) == digest, p
        verified[p] = digest
    # Cover the remaining standalone generator hardware and ISA, with relocation map.
    mapping = {r['old']: r['new'] for r in json.loads(
        (OWN/'20261111-hardware-owner/source-map.json').read_text())}
    snapshot = json.loads((ORIGINAL/'source-snapshot.json').read_text())
    with tarfile.open(ORIGINAL/'source-snapshot.tar.gz') as archive:
        for row in snapshot:
            p = row['path']
            if p.endswith(('.ml', '.mli')) and p.startswith(('lib/', 'isa/', 'bin/generate')):
                current = mapping.get(p, p)
                if current in verified:
                    continue
                data = archive.extractfile(p).read()
                assert sha(data) == row['sha256'], p
                assert data == git('show', f'{REV}:{current}'), (p, current)
                verified[current] = sha(data)
    # Format-post re-emitted all outputs and proved them equal to the original run.
    generated = json.loads((BASE/'generated-comparison.json').read_text())
    assert len(generated) == 17 and all(r['byte_equal'] for r in generated.values())
    for name, row in generated.items():
        assert sha((BASE/'generated'/name).read_bytes()) == row['after_sha256']
    bundles = json.loads((BASE/'bundle-comparison.json').read_text())
    for kind, record in bundles.items():
        assert all(r['byte_equal'] for r in record['rtl'].values())
        before = json.loads((ORIGINAL/'bundles'/kind/'manifest.json').read_text())
        after = json.loads((BASE/'bundles'/kind/'manifest.json').read_text())
        for role, key in [('simulation','simulation_sources'),('synthesis','synthesis_sources')]:
            assert (ORIGINAL/'bundles'/kind/before[key][0]).read_bytes() == (BASE/'bundles'/kind/after[key][0]).read_bytes()
            oldstats = json.loads((ORIGINAL/f'synth-{kind}-{role}.json').read_text())
            poststats = json.loads((OWN/'package-tooling-post'/f'synth-{kind}-{role}.json').read_text())
            assert oldstats['creator'] == poststats['creator']
            assert oldstats['design'] == poststats['design']
    save('baseline-correspondence.json', dict(revision=REV, verified_source_hashes=verified,
        verified_source_count=len(verified), generated=17, bundle_roles=6,
        rtl_baseline=str(BASE), synthesis_baseline=str(OWN/'package-tooling-post'),
        result='saved format-post input bytes match starting revision; historical RTL/statistics chain verified'))

def regression():
    run('install-lint', ['dune','build','@install','@lint','-j5'])
    run('ordinary-forced', ['dune','runtest','--force','-j5'])
    run('rtl-forced', ['dune','build','@rtl','--force','-j5'])

def generate():
    (OUT/'generated').mkdir(exist_ok=True)
    records = [json.loads(s) for s in (BASE/'commands.jsonl').read_text().splitlines()]
    commands = [r for r in records if r['name'].startswith('generate-')]
    assert len(commands) == 17
    for row in commands:
        args = [s.replace(str(BASE), str(OUT)) for s in row['argv']]
        assert args[:4] == ['opam','exec','--switch=5.2.0+ox','--']
        args = args[4:]
        assert args[0] == 'dune' and '-j5' in args
        run(row['name'], args)
    result = {p.name: dict(byte_equal=p.read_bytes()==(OUT/'generated'/p.name).read_bytes(),
                          baseline_sha256=sha(p.read_bytes()),
                          current_sha256=sha((OUT/'generated'/p.name).read_bytes()))
              for p in (BASE/'generated').glob('*.v')}
    save('generated-comparison.json', result)
    assert len(result) == 17 and all(r['byte_equal'] for r in result.values())

def bundle(kind):
    (OUT/'bundles').mkdir(exist_ok=True)
    run('bundle-'+kind, ['dune','exec','-j5','bin/asic_bundle.exe','--',kind,
                        str(OUT/'bundles'/kind),str(ROOT)])
    run('check-bundle-'+kind, ['python3','-B','tinytapeout/scripts/check-adopted-bundle.py',
                              '--kind',kind,'--metadata-only'])
    # Local audit imports the production checker unchanged, using canonical closure.
    spec = importlib.util.spec_from_file_location('checker', ROOT/'tinytapeout/scripts/check-adopted-bundle.py')
    checker = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(checker)
    before, after = BASE/'bundles'/kind, OUT/'bundles'/kind
    checker.check_bundle(ROOT, after, kind)
    old, new = [json.loads((p/'manifest.json').read_text()) for p in [before, after]]
    fields = ['top_module','project','requested_tools','synthesis_sources','simulation_sources','resources','simulation_resources']
    result = dict(manifest_fields_equal={k:old[k]==new[k] for k in fields}, rtl={})
    for role, key in [('simulation','simulation_sources'),('synthesis','synthesis_sources')]:
        a,b = before/old[key][0], after/new[key][0]
        result['rtl'][role] = dict(byte_equal=a.read_bytes()==b.read_bytes(),
            baseline_sha256=sha(a.read_bytes()), current_sha256=sha(b.read_bytes()))
    collateral = [p for folder in ['constraints','src'] for p in (before/folder).rglob('*')
                  if p.is_file() and p.suffix != '.v'] + [before/'info.yaml']
    result['pins_constraints_config_equal'] = {str(p.relative_to(before)):
        p.read_bytes()==(after/p.relative_to(before)).read_bytes() for p in collateral}
    a,b = [{r['path']:r for r in m['source_inputs']} for m in [old,new]]
    result['inventory'] = dict(before_count=len(a),after_count=len(b),
        removed=sorted(a.keys()-b.keys()), added=sorted(b.keys()-a.keys()),
        changed=[dict(path=p,before=a[p],after=b[p]) for p in sorted(a.keys()&b.keys()) if a[p]!=b[p]],
        identity_before=old['identity'],identity_after=new['identity'])
    for row in new['source_inputs']:
        assert (ROOT/row['path']).read_bytes() == (after/'inputs'/row['path']).read_bytes()
    if kind == 'loader':
        assert len(b)==47
        assert {f'host_link_protocol/{p}' for p in ['dune','definitions.ml','codec.ml','host_link_protocol.ml','host_link_protocol.mli']} <= b.keys()
        assert not any(p.startswith('host_link_wire/') for p in b)
    save('bundle-comparison-'+kind+'.json',result)
    assert all(result['manifest_fields_equal'].values())
    assert all(r['byte_equal'] for r in result['rtl'].values())
    assert all(result['pins_constraints_config_equal'].values())

def synth(kind, role):
    manifest = json.loads((OUT/'bundles'/kind/'manifest.json').read_text())
    path = OUT/'bundles'/kind/manifest[role+'_sources'][0]
    stats = OUT/f'synth-{kind}-{role}.json'
    top = manifest['top_module']
    run(f'synth-{kind}-{role}', ['yosys','-p',
        f'read_verilog {path}; hierarchy -check -top {top}; synth -top {top}; tee -o {stats} stat -json'])
    a = json.loads((OWN/'package-tooling-post'/stats.name).read_text())
    b = json.loads(stats.read_text())
    result = dict(same_tool=a['creator']==b['creator'], creator=b['creator'],
                  design_statistics_equal=a['design']==b['design'],
                  before=a['design'],after=b['design'])
    save(f'synth-comparison-{kind}-{role}.json',result)
    assert result['same_tool'] and result['design_statistics_equal']

def formatting():
    scopes = ['host_link_protocol','host_link_wire','test/host_link_protocol',
              'test/host_link_protocol_compatibility','ip/host_link/verif/serial_host',
              'ip/host_link/verif/endpoint','ip/host_link/verif/frame_tx',
              'ip/host_link/verif/command_dispatch','lib','chip_top/project','tinytapeout/src']
    run('scoped-format', ['dune','build',*[f'@{p}/fmt' for p in scopes],'-j5'])
    run('global-format', ['dune','build','@fmt','-j5'],allow_failure=True)
    failed = sorted(set(re.findall(r'^------ (.+)$', (OUT/'logs/global-format.log').read_text(), re.M)))
    previous = {r['path'] for r in json.loads((BASE/'format-backlog.json').read_text())['failures']}
    rows = [dict(path=p, present_before=p in previous,
                 bytes_equal_to_starting_revision=(ROOT/p).read_bytes()==git('show',f'{REV}:{p}')) for p in failed]
    save('format-backlog.json',dict(before_count=len(previous),current_count=len(failed),
        resolved=sorted(previous-set(failed)),failures=rows))
    assert all(r['present_before'] and r['bytes_equal_to_starting_revision'] for r in rows)

def classify_format():
    current = (OUT/'logs/global-format.log').read_text()
    old = (BASE/'logs/fmt-backlog.log').read_text()
    backlog = json.loads((OUT/'format-backlog.json').read_text())
    def edits(log, path):
        section = log.split('------ '+path+'\n',1)[1]
        section = section.split('\nFile "',1)[1]
        # A file may contain multiple hunks; stop only at the next file's diff header.
        section = re.split(r'\n------ ', section, maxsplit=1)[0]
        return re.findall(r'^[-+]\|.*$',section,re.M)
    rows = []
    for r in backlog['failures']:
        p = r['path']
        before = git('show',f'{REV}:{p}')
        after = (ROOT/p).read_bytes()
        if not r['bytes_equal_to_starting_revision']:
            assert p == 'ip/host_link/rtl/command_dispatch.ml'
            assert before.replace(b'Protemu_host_link_wire.Wire', b'Host_link_protocol') == after
        assert r['present_before']
        a,b = edits(old,p),edits(current,p)
        assert a and a == b, p
        rows.append(dict(path=p, formatter_edits_identical=True,
                         source_byte_identical=before==after,
                         canonical_alias_only_change=before!=after))
    save('format-classification.json',dict(baseline_count=23,current_count=len(rows),
        introduced_format_failures=0, failures=rows))

def final(run_checks=True):
    install = ROOT/'_build/install/default/lib'
    if run_checks:
        run('consumer-preservation-audit-fresh-bundle', ['python3','-B',
            '.dev/am3/integrated-final-20261111/consumer-audit-adapter.py','--summary'],heavy=False)
        run('installed-shim-consumer', ['env',f'OCAMLPATH={install}','dune','exec',
            '--root','/tmp/opencode/protemu-am3-installed-consumer','./consumer.exe','-j5'])
        run('installed-canonical-findlib-closure',['env',f'OCAMLPATH={install}',
            'ocamlfind','query','-recursive','-format','%p','hardcaml_protemu.host_link_protocol'])
        run('diff-check',['git','diff','--check'],heavy=False)
        run('index-diff-check',['git','diff','--cached','--exit-code'],heavy=False)
    sources = source_state()
    assert sources == json.loads((OUT/'initial-source-hashes.json').read_text()), 'authored source changed during verification'
    initial = json.loads((OUT/'initial-state.json').read_text())
    assert sha((ROOT/'.git/index').read_bytes()) == initial['index_sha256']
    assert sha((ROOT/'.git/config').read_bytes()) == initial['git_config_sha256']
    assert git('rev-parse','HEAD').decode().strip() == REV
    installed_files = json.loads((ORIGINAL/'installed-hardcaml-files.json').read_text())
    assert all(sha(Path(r['path']).read_bytes())==r['sha256'] for r in installed_files)
    regs = lambda data: re.findall(rb'^\s*let%(?:expect_test|test_unit|test)\b[^\n]*',data,re.M)
    counts = {p:len(regs((ROOT/p).read_bytes())) for p in sources if p.endswith('.ml')}
    counts = {p:n for p,n in counts.items() if n}
    assert sum(counts.values()) == 481, sum(counts.values())
    assert sum(n for p,n in counts.items() if p.startswith('test/host_link_protocol/')) == 31
    assert sum(n for p,n in counts.items() if p.startswith('test/host_link_protocol_compatibility/')) == 1
    assert len(regs(git('show',f'{REV}:test/host_link_wire/wire_tests.ml'))) == 26
    # No authored active source/Dune dependencies refer to the compatibility library.
    references = {}
    for p in sources:
        if p.endswith(('.ml','.mli')) or Path(p).name=='dune':
            lines = [(i,line) for i,line in enumerate((ROOT/p).read_text().splitlines(),1)
                     if re.search(r'Protemu_host_link_wire|protemu_host_link_wire',line)]
            if lines:
                references[p] = lines
    allowed = {'host_link_wire/dune',
        'ip/host_link/verif/archived/hl4a/dune',
        'ip/host_link/verif/archived/hl4a/hardware_loader_testbench.ml',
        'test/host_link_protocol_compatibility/dune',
        'test/host_link_protocol_compatibility/compatibility_tests.ml'}
    assert set(references) == allowed, references.keys()
    package = (install/'hardcaml_protemu/dune-package').read_text()
    libraries = re.split(r'\n\(library\n',package)[1:]
    requirements = {}
    for library in libraries:
        name = re.search(r'\(name ([^\s)]+)\)',library)[1]
        requires = re.search(r'\(requires\s+([^)]*)\)',library,re.S)[1].split()
        requirements[name] = requires
    assert 'hardcaml_protemu.host_link_protocol' in requirements['hardcaml_protemu']
    assert 'hardcaml_protemu.host_link_wire' not in requirements['hardcaml_protemu']
    assert 'hardcaml_protemu.host_link_protocol' in requirements['hardcaml_protemu.host_link_wire']
    closure = (OUT/'logs/installed-canonical-findlib-closure.log').read_text().splitlines()
    assert not any('hardcaml' in name and name!='hardcaml_protemu.host_link_protocol' for name in closure)
    rtl_log = (OUT/'logs/rtl-forced-retry.log').read_text()
    assert rtl_log.count('PASS p3.5 serial loader repair:') == 3
    inventory = {}
    for kind in ['observable','memory','loader']:
        row = json.loads((OUT/f'bundle-comparison-{kind}.json').read_text())['inventory']
        changes = [r['path'] for r in row['changed'] if r['before']['sha256']!=r['after']['sha256']]
        expected = ['chip_top/project/chip_project.ml','lib/dune']
        if kind=='loader':
            expected += [f'ip/host_link/rtl/{m}.ml' for m in ['command_dispatch','frame_rx','frame_tx','wire_crc','wire_layout']]
        assert set(changes)==set(expected), (kind,changes)
        inventory[kind] = dict(source_hash_changes=changes, count=row['after_count'],
            metadata_only_status_changes=[r['path'] for r in row['changed'] if r['before']['sha256']==r['after']['sha256']],
            added=row['added'],removed=row['removed'],identity=row['identity_after'])
    save('inventory-classification.json',inventory)
    save('final-audit.json',dict(total_registrations=481,pure_original=26,pure_canonical=31,
        pure_compatibility=1,pure_total=32,counts_by_file=counts,remaining_shim_references=references,
        installed_requirements=requirements,canonical_findlib_closure=closure,
        authored_sources_unchanged=True,git_index_config_revision_unchanged=True,
        installed_dependency_files_unchanged=len(installed_files),independent_loader_tiers_pass=3))

def summary():
    assert source_state() == json.loads((OUT/'initial-source-hashes.json').read_text())
    records = [json.loads(s) for s in (OUT/'timing_commands.jsonl').read_text().splitlines()]
    assert {r['name'] for r in records if r['exit']} == {'global-format','consumer-preservation-audit'}
    roles = {}
    for kind in ['observable','memory','loader']:
        for role in ['simulation','synthesis']:
            name = f'synth-{kind}-{role}.json'
            a = json.loads((OWN/'package-tooling-post'/name).read_text())
            b = json.loads((OUT/name).read_text())
            assert a['modules'] == b['modules'], (kind,role)
            assert a['design'] == b['design'] and a['creator'] == b['creator']
            roles[kind+'-'+role] = dict(cells=b['design']['num_cells'],
                tool=b['creator'],all_module_statistics_equal=True,design_statistics_equal=True)
    save('result-summary.json',dict(status='PASS with unchanged baseline formatting backlog',
        completed_commands=len(records), commands=records,
        failed_completed_commands=[r for r in records if r['exit']],
        interrupted_command='rtl-forced: harness timeout, partial log retained; completed forced retry PASS',
        helper_failed_attempts=['baseline-attempt-1-failure.txt','format-classification-attempt-1.txt','final-helper-attempts.txt'],
        pure_tests=32,original_pure_tests=26,registrations=481,independent_loader_tiers=3,
        generated_byte_equal=17,bundle_roles_byte_equal=6,synthesis=roles,
        introduced_format_failures=0,baseline_format_failures=23,
        source_mutation=False,dependency_mutation=False,git_mutation=False,physical_flow=False))
    print(json.dumps(dict(result='PASS',pure=32,registrations=481,generated=17,bundle_roles=6,
                         same_tool_synthesis_roles=6,baseline_format_failures=23,introduced_format_failures=0)))

if __name__ == '__main__':
    phase = sys.argv[1]
    if phase == 'baseline': baseline()
    elif phase == 'regression': regression()
    elif phase == 'rtl-retry': run('rtl-forced-retry', ['dune','build','@rtl','--force','-j5'])
    elif phase == 'generate': generate()
    elif phase == 'bundle': bundle(sys.argv[2])
    elif phase == 'synth': synth(*sys.argv[2:4])
    elif phase == 'format': formatting()
    elif phase == 'classify-format': classify_format()
    elif phase == 'final': final()
    elif phase == 'final-audit-only': final(run_checks=False)
    elif phase == 'summary': summary()
