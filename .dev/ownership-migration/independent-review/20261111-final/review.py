"""Independent read-only source/evidence review; writes only this receipt directory."""
from collections import Counter
import difflib
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tarfile

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[3]
EVIDENCE = ROOT/'.dev/ownership-migration'
BASE = EVIDENCE/'20261111-b3a4cb6-baseline'
POST = EVIDENCE/'package-tooling-post'
ENV = dict(os.environ, GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def save(name, value):
    (OUT/name).write_text(value if isinstance(value,str) else json.dumps(value,indent=2)+'\n')


def run(name, args, cwd=ROOT):
    result = subprocess.run(args, cwd=cwd, env=ENV, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    save(name+'.log',result.stdout)
    assert result.returncode == 0, (name,result.returncode)
    return result.stdout


def sexps(text):
    tokens = re.findall(r'"(?:\\.|[^"\\])*"|[()]|[^\s()]+', re.sub(r';[^\n]*','',text))
    root, stack = [], []
    current = root
    for token in tokens:
        if token == '(':
            child = []
            current.append(child)
            stack.append(current)
            current = child
        elif token == ')':
            current = stack.pop()
        else:
            current.append(token)
    return root


def main():
    snapshot = json.loads((BASE/'source-snapshot.json').read_text())
    with tarfile.open(BASE/'source-snapshot.tar.gz') as archive:
        old = {r['path']:archive.extractfile(r['path']).read() for r in snapshot}
    assert all(sha(old[r['path']])==r['sha256'] for r in snapshot)
    source_paths = [p for p in run('source-paths',['git','ls-files','--cached','--others','--exclude-standard','-z']).split('\0')
                    if p and not p.startswith('.dev/') and (ROOT/p).is_file()]
    save('current-source-hashes.json',[dict(path=p,sha256=sha((ROOT/p).read_bytes())) for p in source_paths if not p.startswith('docs/')])
    save('tracked-diff.patch',run('tracked-diff',['git','diff','--','.\u0020',':!.dev']) if False else run('tracked-diff',['git','diff','--','.',':!.dev',':!docs']))
    mapping = {}
    hw = []
    for relative in re.findall(r'^\(copy_files (.*?)\)$',(ROOT/'lib/dune').read_text(),re.M):
        new = str((ROOT/'lib'/relative).resolve().relative_to(ROOT))
        previous = next(p for p in old if p.startswith('lib/') and Path(p).name==Path(new).name)
        assert old[previous] == (ROOT/new).read_bytes(), new
        assert not (ROOT/previous).exists(), previous
        assert sum(Path(p).name==Path(new).name for p in source_paths
                   if p.endswith('.ml') and ('/rtl/' in p or p.startswith(('rtl/','lib/')))) == 1,new
        mapping[previous] = new
        hw.append(dict(old=previous,new=new,sha256=sha(old[previous])))
    assert len(hw)==26
    save('hardware.json',hw)
    audit=json.loads((EVIDENCE/'verification-post/audit.json').read_text())
    changed=[]
    for row in audit['files']:
        before,after=old[row['old']],(ROOT/row['new']).read_bytes()
        mapping[row['old']]=row['new']
        if before != after:
            changed.append(row['new'])
            save(row['new'].replace('/','__')+'.diff',''.join(difflib.unified_diff(before.decode().splitlines(True),after.decode().splitlines(True),fromfile=row['old'],tofile=row['new'])))
    regs=lambda data:re.findall(r'^\s*(let%(?:expect_test|test_unit|test)\b[^\n]*)',data.decode(),re.M)
    expected=Counter((mapping.get(p,p),r) for p,data in old.items() if p.endswith('.ml') for r in regs(data))
    actual=Counter((p,r) for p in source_paths if p.endswith('.ml') for r in regs((ROOT/p).read_bytes()))
    assert expected==actual and sum(actual.values())==475
    for p,data in old.items():
        if p.endswith('.ml') and regs(data):
            assert data==(ROOT/mapping.get(p,p)).read_bytes(),p
    frozen=json.loads((BASE/'frozen-oracle.json').read_text())
    assert len(frozen)==8
    assert all(sha((ROOT/mapping.get(r['path'],r['path'])).read_bytes())==r['sha256'] for r in frozen)
    baseline_libs=[]
    current_libs=[]
    for p,data in old.items():
        if p.startswith('test/') and Path(p).name=='dune':
            baseline_libs += [s for s in sexps(data.decode()) if s and s[0]=='library']
    for p in source_paths:
        if Path(p).name=='dune' and p.startswith(('test/','ip/','verif/','chip_top/verif/')):
            current_libs += [s for s in sexps((ROOT/p).read_text()) if s and s[0]=='library']
    assert Counter(map(str,baseline_libs))==Counter(map(str,current_libs))
    save('registration-summary.json',dict(total=475,test_libraries=len(current_libs),all_registration_bodies_byte_equal=True,
        frozen_files=8,changed_support_files=changed))
    for p,data in old.items():
        if p.startswith(('f_model/','isa/','host_link_wire/','test/f_model/','test/host/','test/host_link_wire/','flow_results/','docs/history/')):
            assert (ROOT/p).read_bytes()==data,p
    historical_changed=[p for p in old if p.startswith('docs/') and p not in {'docs/README.md','docs/architecture_migration.md','docs/verification.md'} and (ROOT/p).read_bytes()!=old[p]]
    assert not historical_changed,historical_changed
    install=ROOT/'_build/install/default/lib/hardcaml_protemu'
    aliases=(install/'hardcaml_protemu.ml').read_text()
    for row in hw:
        name=Path(row['new']).stem
        module=name[0].upper()+name[1:]
        assert (install/(name+'.ml')).read_bytes()==old[row['old']],name
        assert (install/('hardcaml_protemu__'+module+'.cmi')).is_file(),name
        assert re.search(r'\bmodule\s+'+module+r'\s*=',aliases),module
    baseline_mli=[p for p in old if p.startswith('lib/') and p.endswith('.mli')]
    assert not baseline_mli
    reusable=(ROOT/'lib/dune').read_text()
    assert 'hardcaml_asic' not in reusable and 'protemu_chip_project' not in reusable
    assert '(libraries core protemu_isa)' in (ROOT/'f_model/dune').read_text()
    save('package-api.json',dict(public_flat_modules=26,source_and_cmi_install_verified=True,baseline_explicit_mli=baseline_mli,
        reusable_asic_dependency=False,model_dependencies=['core','protemu_isa'],chip_project_private_separate_library=True))
    installed=json.loads((BASE/'installed-hardcaml-files.json').read_text())
    assert all(Path(r['path']).is_file() and sha(Path(r['path']).read_bytes())==r['sha256'] for r in installed)
    assert sha((ROOT/'.git/index').read_bytes())==(BASE/'initial-index.sha256').read_text().strip()
    save('unchanged-environment.json',dict(installed_hardcaml_files=len(installed),all_installed_hashes_unchanged=True,index_unchanged=True,historical_files_unchanged=True))
    generated=[]
    for path in sorted((BASE/'generated').glob('*.v')):
        after=POST/'generated'/path.name
        assert path.read_bytes()==after.read_bytes(),path.name
        generated.append(dict(name=path.name,sha256=sha(path.read_bytes())))
    assert len(generated)==17
    save('generated-rtl.json',generated)
    bundles={}
    for kind in ('observable','memory','loader'):
        before=json.loads((BASE/'bundles'/kind/'manifest.json').read_text())
        after=json.loads((POST/'bundles'/kind/'manifest.json').read_text())
        for key in ('project','top_module','requested_tools','resources','simulation_resources','synthesis_sources','simulation_sources'):
            assert before[key]==after[key],(kind,key)
        for row in after['source_inputs']:
            assert (ROOT/row['path']).read_bytes()==(POST/'bundles'/kind/'inputs'/row['path']).read_bytes(),row['path']
        for row in after['files']:
            assert sha((POST/'bundles'/kind/row['path']).read_bytes())==row['sha256'],row['path']
        for path in ('constraints/top.sdc','info.yaml','src/config.json'):
            assert (BASE/'bundles'/kind/path).read_bytes()==(POST/'bundles'/kind/path).read_bytes(),(kind,path)
        roles={}
        for role,key in [('simulation','simulation_sources'),('synthesis','synthesis_sources')]:
            a,b=BASE/'bundles'/kind/before[key][0],POST/'bundles'/kind/after[key][0]
            assert a.read_bytes()==b.read_bytes(),(kind,role)
            statfile='synth-'+kind+'-'+role+'.json'
            a_stats=json.loads((BASE/statfile).read_text())
            b_stats=json.loads((POST/statfile).read_text())
            assert a_stats['creator']==b_stats['creator'],(kind,role,'tool')
            assert a_stats['design']==b_stats['design'],(kind,role,'counts')
            roles[role]=dict(sha256=sha(b.read_bytes()),same_tool=a_stats['creator'],counts_equal=True,cells=b_stats['design']['num_cells'])
        bundles[kind]=roles
    save('bundle-roles.json',bundles)
    benchmap=json.loads((POST/'bench-path-map.json').read_text())
    assert len(benchmap)==8
    for previous,row in benchmap.items():
        mapping[previous]=row['destination']
        assert old[previous]==(ROOT/row['destination']).read_bytes(),previous
    for p,data in old.items():
        if p=='loader_core.v' or (p.startswith('tinytapeout/src/') and p.endswith('.v')):
            assert (ROOT/p).read_bytes()==data,p
    save('emitted-benches.json',benchmap)
    dune=(ROOT/'tinytapeout/test/dune').read_text()
    assert '(alias loader-core-rtl)' in dune and '(alias loader-wrapper-rtl)' in dune and '(alias loader-production-rtl)' in dune
    install_checks=run('make-dry-run',['make','-n','rtl'],ROOT/'tinytapeout/test')
    assert '../../chip_top/verif/observable/emitted/tb.v' in install_checks
    run('shell-parse',['bash','-n','flow.sh','tinytapeout/scripts/adopted-flow.sh','tinytapeout/scripts/stage-project.sh','scripts/p3.4-cli-workflow.sh'])
    sources=[str(ROOT/row['new']) for row in hw]+[str(p) for p in (ROOT/'chip_top/rtl').glob('*.ml')]+[str(p) for p in (ROOT/'isa').glob('*.ml')]+[str(ROOT/'host_link_wire/wire.ml')]
    dependencies=run('ocaml-source-dependencies',['opam','exec','--switch=5.2.0+ox','--','ocamldep','-modules',*sources])
    deps={}
    modules={}
    for line in dependencies.splitlines():
        if ': ' in line:
            filename,mods=line.split(': ',1)
            path=Path(filename)
            name=path.stem[0].upper()+path.stem[1:]
            modules[name]=str(path.relative_to(ROOT))
            deps[name]=mods.split()
    closures={}
    for kind,start in [('observable','Observable_design'),('memory','Memory_design'),('loader','Package_top')]:
        visited=set()
        def visit(module):
            if module in visited or module not in modules:return
            visited.add(module)
            for dependency in deps[module]:visit(dependency)
        visit(start)
        manifest=json.loads((POST/'bundles'/kind/'manifest.json').read_text())
        paths={r['path'] for r in manifest['source_inputs']}
        missing=sorted(modules[m] for m in visited if modules[m] not in paths)
        closures[kind]=dict(selected_modules=sorted(visited),missing_selected_source_inputs=missing)
    save('manifest-closure.json',closures)
    print(json.dumps(dict(hardware=26,registrations=475,frozen=8,generated=17,bundle_roles=6,test_libraries=len(current_libs),manifest_closures=closures),indent=2))


if __name__=='__main__':main()
