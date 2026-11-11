"""Independent read-only layout/ownership/inventory review; no build actions."""
from collections import Counter
import hashlib
import io
import json
import os
from pathlib import Path
import re
import subprocess
import tarfile

OUT=Path(__file__).resolve().parent
ROOT=OUT.parents[2]
ENV=dict(os.environ,GIT_OPTIONAL_LOCKS='0',PYTHONDONTWRITEBYTECODE='1')


def sha(data):return hashlib.sha256(data).hexdigest()
def save(name,obj):(OUT/name).write_text(obj if isinstance(obj,str) else json.dumps(obj,indent=2)+'\n')
def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT,env=ENV)
def parse(text):
    tokens=re.findall(r'"(?:[^"\\]|\\.)*"|;[^\n]*|\(|\)|[^\s();]+',text)
    stack=[[]]
    for token in tokens:
        if token.startswith(';'):continue
        if token=='(':stack.append([])
        elif token==')':
            node=stack.pop();stack[-1].append(node)
        else:stack[-1].append(token)
    assert len(stack)==1
    return stack[0]
def field(stanza,key,default=None):return next((x[1:] for x in stanza[1:] if isinstance(x,list) and x and x[0]==key),default)
def strip_comments(text):return re.sub(r'\(\*.*?\*\)','',text,flags=re.S)


def main():
    index_before=sha((ROOT/'.git/index').read_bytes())
    revision=git('rev-parse','HEAD').decode().strip()
    with tarfile.open(fileobj=io.BytesIO(git('archive','HEAD'))) as archive:
        old={m.name:archive.extractfile(m).read() for m in archive if m.isfile()}
    graph={};locations={};stanzas={};public={}
    for tree in ('ip','asic','software','verif','firmware','spec'):
        for p in (ROOT/tree).rglob('dune'):
            for node in parse(p.read_text()):
                if node and node[0] in ('library','executable','executables'):
                    names=field(node,'name') or field(node,'names')
                    for name in names:
                        assert name not in graph,('duplicate library/executable',name)
                        graph[name]=field(node,'libraries',[])
                        locations[name]=str(p.relative_to(ROOT));stanzas[name]=node
                        pkg=field(node,'public_name')
                        if pkg:public[name]=pkg[0]
    def closure(name,seen=None):
        seen=set() if seen is None else seen
        for dep in graph.get(name,[]):
            assert isinstance(dep,str),(name,dep)
            if dep not in seen:seen.add(dep);closure(dep,seen)
        return seen
    owners=['protemu_mechanisms','protemu_mechanisms_staging','protemu_controller','protemu_core',
        'protemu_core_legacy','protemu_host_link','protemu_system','protemu_asic_bringup']
    for owner in owners:
        assert owner in graph
        assert field(stanzas[owner],'wrapped',['true'])==['true'],owner
        assert 'hardcaml_protemu' not in closure(owner),owner
        assert 'hardcaml_asic' not in closure(owner),owner
        assert 'protemu_host_link_wire' not in closure(owner),owner
    assert set(graph['hardcaml_protemu'])==set(owners)
    assert graph['protemu_chip_project']==['core','hardcaml','hardcaml_asic','protemu_asic_rtl']
    for name in ('protemu_chip_project','protemu_asic_rtl'):
        assert 'hardcaml_protemu' not in closure(name)
        assert 'protemu_core_legacy' not in closure(name)
        assert 'protemu_mechanisms_staging' not in closure(name)
    pure=['protemu_f_model','protemu_firmware_examples','protemu_isa','protemu_host','host_link_protocol','protemu_host_link_wire']
    for name in pure:
        assert not set(owners+['hardcaml','hardcaml_asic','hardcaml_protemu']) & closure(name),(name,closure(name))
    assert graph['protemu_firmware_examples']==['core','protemu_isa']
    assert 'protemu_firmware_examples' in graph['protemu_f_model']
    source_trees=('ip','asic','software','verif','firmware','spec')
    sourcefiles=[p for tree in source_trees for p in (ROOT/tree).rglob('*') if p.is_file() and (p.suffix in ('.ml','.mli') or p.name=='dune')]
    legacy_trace=[]
    for p in sourcefiles:
        text=p.read_text()
        if p.name=='dune':assert not re.search(r'include_subdirs\s+unqualified',text),p
        if re.search(r'\bHardcaml_protemu\b|\bProtemu_host_link_wire\b',strip_comments(text)):
            legacy_trace.append(str(p.relative_to(ROOT)))
    for name in graph:
        if name!='hardcaml_protemu' and '/archived/' not in locations[name]:assert 'hardcaml_protemu' not in closure(name),name
    save('graph.json',dict(owners={n:dict(path=locations[n],public=public[n],direct=graph[n],closure=sorted(closure(n))) for n in owners},
        asic_project_closure=sorted(closure('protemu_chip_project')),pure={n:sorted(closure(n)) for n in pure},legacy_namespace_sources=legacy_trace))
    hardware=json.loads((ROOT/'.dev/final-layout/hardware/before.json').read_text())['sources']
    aliases={}
    for row in hardware:
        before=old[row['source']]
        assert sha(before)==row['sha256'],row['source']
        current=(ROOT/row['destination']).read_text()
        restored=re.sub(r'^module \w+ = Protemu_(?:controller|core|host_link|mechanisms)\.\w+\n','',current,flags=re.M)
        assert restored.encode()==before,row['destination']
        aliases[row['old_namespace'].split('.')[-1]]=row['namespace']
        candidates=[p for p in sourcefiles if p.name==Path(row['destination']).name and '/rtl/' in str(p)]
        assert len(candidates)==1,(row['destination'],candidates)
    facade=strip_comments((ROOT/'software/compatibility/hardware/hardcaml_protemu.ml').read_text())
    assert dict(re.findall(r'^module (\w+) = ([\w.]+)$',facade,re.M))==aliases
    assert not re.search(r'\b(let|type|include|open)\b',facade)
    save('hardware.json',dict(sources=26,source_bodies_preserved=True,unique_authored_owner=True,alias_exports=aliases))
    data=json.loads((ROOT/'.dev/final-layout-b/baseline.json').read_text())
    moves=data['moves']
    regs=lambda text:re.findall(r'let%(?:expect_test|test_unit|test)\b[^=\n]*',text)
    expected=Counter((moves.get(p,p).replace('chip_top/','asic/',1) if p.startswith('chip_top/') else moves.get(p,p),r)
        for p,b in old.items() if p.endswith('.ml') for r in regs(b.decode()))
    actual=Counter((str(p.relative_to(ROOT)),r) for p in sourcefiles if p.suffix=='.ml' for r in regs(p.read_text()))
    assert expected==actual and sum(actual.values())==481
    frozen=data['frozen']
    assert len(frozen)==8
    for p,digest in frozen.items():assert sha((ROOT/p).read_bytes())==digest==sha(old[p]),p
    whitelist={
        'ip/emulator_core/verif/execution/control_execution_property_tests.ml',
        'ip/program_memory_controller/verif/controller/protocol_core_property_tests.ml',
        'ip/mechanisms/verif/staging/uart_slice/uart_slice_property_tests.ml',
        'ip/mechanisms/verif/blocks/input_events/input_events_timing_tests.ml',
        'ip/mechanisms/verif/blocks/input_events/input_events_four_state_tests.ml',
        'verif/common/test/replay_expect_tests.ml'}
    replacements={'test/core/control_execution':'ip/emulator_core/verif/execution','test/core/protocol_core':'ip/program_memory_controller/verif/controller',
        'test/integration/uart_slice':'ip/mechanisms/verif/staging/uart_slice','test/primitives/input_events':'ip/mechanisms/verif/blocks/input_events','test/common':'verif/common/test'}
    ep=r'\[%expect(?:_exact)?\s+(\{\|.*?\|\}|"(?:[^"\\]|\\.)*")\s*\]'
    changed=[]
    for p,b in old.items():
        if not p.endswith('.ml'):continue
        new=moves.get(p,p)
        if new.startswith('chip_top/'):new=new.replace('chip_top/','asic/',1)
        if not (ROOT/new).exists():continue
        a=re.findall(ep,b.decode(),re.S);z=re.findall(ep,(ROOT/new).read_text(),re.S)
        if a!=z:
            assert new in whitelist,new
            for source,target in replacements.items():a=[x.replace(source,target) for x in a]
            assert a==z,new
            changed.append(new)
    assert set(changed)==whitelist,changed
    examples=goldens=0
    for before,after in moves.items():
        if before.startswith('examples/') or before.endswith('.expected') or before=='f_model/example_programs.ml':
            assert (ROOT/after).read_bytes()==old[before],before
            examples+=before.startswith('examples/');goldens+=before.endswith('.expected')
    assert (examples,goldens)==(6,7)
    assert not (ROOT/'verif/reference/model/example_programs.ml').exists()
    assert 'module Example_programs = Protemu_firmware_examples.Example_programs' in (ROOT/'verif/reference/model/protemu_f_model.ml').read_text()
    for p in ('test','f_model','host','host_link_protocol','host_link_wire','isa','examples','lib','rtl','chip_top','bin','tinytapeout','flow_results'):
        assert not (ROOT/p).exists(),p
    save('preservation.json',dict(registrations=481,frozen=8,path_only_expectation_changes=changed,cli_examples=examples,cli_goldens=goldens,firmware_example_bytes_preserved=True))
    archive=json.loads((ROOT/'.dev/final-layout-c/archive-receipt.json').read_text())
    archive_rows=[]
    for move in archive['moves']:
        assert move['before']==move['after']
        for relative,row in move['before'].items():
            src=move['old'] if relative=='.' else move['old']+'/'+relative
            dest=move['new'] if relative=='.' else move['new']+'/'+relative
            p=ROOT/dest
            assert p.read_bytes()==old[src] and sha(p.read_bytes())==row['sha256'],src
            assert oct(p.stat().st_mode & 0o777)==row['mode'],src
            assert row['sha256'] in (ROOT/'archive/INDEX.md').read_text(),src
            archive_rows.append(dict(old=src,new=dest,sha256=row['sha256'],mode=row['mode']))
    assert len(archive_rows)==42 and sum(x['new'].endswith('.tar.gz') for x in archive_rows)==5
    assert '(data_only_dirs :standard)' in (ROOT/'archive/dune').read_text()
    save('archives.json',archive_rows)
    save('loader-provenance.txt',git('log','--follow','--format=fuller','--','loader_core.v').decode())
    paths=re.findall(r'"([^"\n]+)"',(ROOT/'asic/project/chip_project.ml').read_text().split('let input_paths kind =',1)[1])
    inputs=[p for p in paths if (ROOT/p).is_file()]
    assert len(inputs)==len(set(inputs))==55
    ds=parse((ROOT/'asic/tinytapeout/src/dune').read_text())
    rule=next(s for s in ds if s and s[0]=='rule' and 'loader_wrapper.simulation.generated.v' in (field(s,'targets') or []))
    base=ROOT/'asic/tinytapeout/src'
    depfiles=[];trees=[]
    for dep in field(rule,'deps'):
        if isinstance(dep,str):depfiles.append((base/dep).resolve())
        elif dep[0]=='source_tree':trees.append((base/dep[1]).resolve())
    for p in inputs:
        absolute=(ROOT/p).resolve()
        assert absolute in depfiles or any(absolute.is_relative_to(t) for t in trees),('not sandbox dependency',p)
    bundles={}
    am3=ROOT/'.dev/am3/integrated-final-20261111'
    for kind in ('observable','memory','loader'):
        folder=ROOT/'.dev/final-layout-c/bundles'/kind
        manifest=json.loads((folder/'manifest.json').read_text())
        assert {x['path'] for x in manifest['source_inputs']}==set(inputs)
        for entry in manifest['source_inputs']:
            content=(ROOT/entry['path']).read_bytes()
            assert content==(folder/'inputs'/entry['path']).read_bytes() and sha(content)==entry['sha256']
        for entry in manifest['files']:assert sha((folder/entry['path']).read_bytes())==entry['sha256']
        previous=json.loads((am3/'bundles'/kind/'manifest.json').read_text())
        for key in ('simulation_sources','synthesis_sources'):
            assert (folder/manifest[key][0]).read_bytes()==(am3/'bundles'/kind/previous[key][0]).read_bytes()
        bundles[kind]=manifest['identity']
    save('source-inventories.json',dict(inputs=inputs,all_55_sandbox_covered=True,bundle_identities=bundles))
    package=parse((ROOT/'_build/default/hardcaml_protemu.dune-package').read_text())
    compiled={field(x,'name')[0]:field(x,'requires',[]) for x in package if x and x[0]=='library'}
    for name in owners:
        deps=compiled[public[name]]
        assert 'hardcaml_protemu' not in deps and 'hardcaml_asic' not in deps,(name,deps)
    save('compiled-dependencies.json',{public[n]:compiled[public[n]] for n in owners})
    index_after=sha((ROOT/'.git/index').read_bytes())
    assert index_before==index_after and not git('diff','--cached','--name-only')
    save('review-state.json',dict(revision=revision,index_before=index_before,index_after=index_after,index_unchanged=True))
    print('PASS: eight wrapped owners/closures, alias26, pure firmware/model, 481 tests/frozen8, 6 examples/7 goldens/six path-only deltas, archives42/tar5, manifest55 sandbox coverage, compiled metadata, index.')


if __name__=='__main__':main()
