"""Independent read-only AM3 extraction, consumer and evidence validation."""
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

OUT=Path(__file__).resolve().parent
ROOT=OUT.parents[3]
BASE=ROOT/'.dev/am3/20261111-0bb9abc-wire-baseline'
FINAL=ROOT/'.dev/am3/integrated-final-20261111'
REV='0bb9abc742b3eefbcaa83c39189b08d4f99cea8a'
ENV=dict(os.environ,GIT_OPTIONAL_LOCKS='0',PYTHONDONTWRITEBYTECODE='1')


def sha(data):return hashlib.sha256(data).hexdigest()
def save(name,obj):(OUT/name).write_text(obj if isinstance(obj,str) else json.dumps(obj,indent=2)+'\n')
def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT,env=ENV)


def normalized(text):
    # Ignore whitespace/comments, but preserve every byte of every string literal.
    output=[]
    i=0
    while i<len(text):
        if text.startswith('(*',i):
            depth=1;i+=2
            while depth:
                if text.startswith('(*',i):depth+=1;i+=2
                elif text.startswith('*)',i):depth-=1;i+=2
                else:i+=1
        elif text[i]=='"':
            start=i;i+=1
            while text[i]!='"':i+=2 if text[i]=='\\' else 1
            i+=1;output.append(text[start:i])
        elif text[i].isspace():i+=1
        else:output.append(text[i]);i+=1
    return ''.join(output)


def uncomment(text):return re.sub(r'\(\*.*?\*\)','',text,flags=re.S)
def module(text,name):return re.search(rf'^module {name} = struct\n(.*?)^end',text,re.S|re.M)[1]
def function(text,name):return re.search(rf'^  let {name}\b.*?(?=^  (?:let |module |type )|\Z)',uncomment(text),re.S|re.M)[0]


def main():
    assert git('rev-parse','HEAD').decode().strip()==REV
    old=(BASE/'wire.ml').read_text()
    assert sha(old.encode())=='23b46d8a57f5bd7ee7e36ce15221f7bbcf1d1c297f18b256bc2e8d6c515dcb9f'
    assert git('show',REV+':host_link_wire/wire.ml')==old.encode()
    moved={'Crc':['update','compute'],'U16':['to_bytes','get'],
        'Request':['payload_fields','encode'],
        'Response':['invalid_field','decode_bits','decode_enum','decode_info','decode_status','decode','decode_correlated']}
    codec=(ROOT/'host_link_protocol/codec.ml').read_text()
    extracted=[]
    definitions=uncomment(old)
    for owner,names in moved.items():
        original=module(definitions,owner)
        body=original
        for name in names:
            before=function(module(old,owner),name)
            after=function(module(codec,owner),name).replace('Definitions.Crc.length','Crc.length').replace('Definitions.U16.max','U16.max')
            assert normalized(before)==normalized(after),(owner,name)
            body=body.replace(function(original,name),'')
            extracted.append(owner+'.'+name)
        for error in ('Encode_error','Decode_error'):
            pattern=rf'^  module {error} = struct\n.*?^  end\n'
            match=re.search(pattern,original,re.S|re.M)
            if match:
                assert normalized(match[0])==normalized(re.search(pattern,module(codec,owner),re.S|re.M)[0])
                body=body.replace(match[0],'')
        definitions=definitions.replace(original,body)
    assert normalized(definitions)==normalized((ROOT/'host_link_protocol/definitions.ml').read_text())
    assert len(extracted)==13
    shim=uncomment((ROOT/'host_link_wire/wire.ml').read_text())
    assert not re.search(r'\b(let|type|match|function)\b',shim)
    assert normalized((ROOT/'host_link_protocol/host_link_protocol.ml').read_text())=='includeDefinitionsmoduleCodec=Codec'
    for path in ('host_link_protocol/dune','host_link_wire/dune'):
        text=(ROOT/path).read_text()
        assert re.search(r'\(libraries core(?: host_link_protocol)?\)',text),path
    installed=ROOT/'_build/install/default/lib/hardcaml_protemu/host_link_protocol'
    for path in ('codec.ml','definitions.ml','host_link_protocol.ml','host_link_protocol.mli'):
        assert (installed/path).read_bytes()==(ROOT/'host_link_protocol'/path).read_bytes(),path
    save('extraction.json',dict(original_sha256=sha(old.encode()),unchanged_functions=extracted,
        definitions_types_derivers_and_errors_preserved=True,shim_implementation_free=True,installed_sources_match=True))
    paths=git('ls-tree','-r','--name-only',REV).decode().splitlines()
    frozen=[p for p in paths if p.startswith('ip/host_link/verif/archived/')]
    for p in frozen:assert (ROOT/p).read_bytes()==git('show',REV+':'+p),p
    assert len(frozen)==8
    hardware=[f'ip/host_link/rtl/{name}.ml' for name in ('wire_crc','wire_layout','frame_rx','frame_tx','command_dispatch')]
    consumers=[]
    pattern=r'Wire\.(Request\.(?:Encode_error|payload_fields|encode)|Response\.(?:Decode_error|invalid_field|decode\w*)|Crc\.(?:compute|update)|U16\.(?:get|to_bytes))'
    for p in paths:
        if not (p.startswith('ip/host_link/') and p.endswith('.ml')):continue
        original=git('show',REV+':'+p).decode()
        current=(ROOT/p).read_text()
        expected=original.replace('Protemu_host_link_wire.Wire','Host_link_protocol') if p not in frozen else original
        if p not in hardware and p not in frozen:expected=re.sub(pattern,r'Wire.Codec.\1',expected)
        assert normalized(current)==normalized(expected),p
        if p in hardware:assert 'Codec' not in current,p
        if 'Protemu_host_link_wire.Wire' in original and p not in frozen:consumers.append(p)
    fixed=git('show',REV+':test/host_link_wire/wire_tests.ml').decode()
    migrated=(ROOT/'test/host_link_protocol/wire_tests.ml').read_text()
    restored=migrated.replace('module Wire = Host_link_protocol\nmodule Codec = Wire.Codec','module Wire = Protemu_host_link_wire.Wire')
    restored=restored.replace('Codec.Request.','Request.').replace('Codec.Response.','Response.').replace('Codec.Crc.','Wire.Crc.')
    restored=restored.replace('module Decode_error = Response.Decode_error','module Decode_error = Wire.Response.Decode_error')
    assert normalized(restored)==normalized(fixed)
    registrations=[]
    for tree in ('test','ip','verif','chip_top'):
        for p in (ROOT/tree).rglob('*.ml'):
            for line in re.findall(r'^\s*(let%(?:test_unit|expect_test|test)\b[^\n]*)',p.read_text(),re.M):
                registrations.append((str(p.relative_to(ROOT)),line))
    assert len(registrations)==481
    counts=Counter(p for p,_ in registrations)
    assert counts['test/host_link_protocol/wire_tests.ml']==26
    assert counts['test/host_link_protocol/boundary_tests.ml']==5
    assert counts['test/host_link_protocol_compatibility/compatibility_tests.ml']==1
    save('consumers-tests.json',dict(frozen_files=8,mechanical_consumers=consumers,
        original_26_tests_preserved=True,registration_count=481,pure_tests=32))
    initial=json.loads((FINAL/'initial-source-hashes.json').read_text())
    checked=0
    for p,digest in initial.items():
        if p.startswith('docs/') or p in ('README.md','README.txt'):continue
        assert sha((ROOT/p).read_bytes())==digest,('source changed after final integration',p)
        checked+=1
    state=json.loads((FINAL/'initial-state.json').read_text())
    assert sha((ROOT/'.git/index').read_bytes())==state['index_sha256']
    assert sha((ROOT/'.git/config').read_bytes())==state['git_config_sha256']
    baseline=json.loads((FINAL/'baseline-correspondence.json').read_text())
    for p,digest in baseline['verified_source_hashes'].items():assert sha(git('show',REV+':'+p))==digest,p
    rtlbase=Path(baseline['rtl_baseline'])
    statsbase=Path(baseline['synthesis_baseline'])
    for p in (FINAL/'generated').glob('*.v'):assert p.read_bytes()==(rtlbase/'generated'/p.name).read_bytes(),p.name
    assert len(list((FINAL/'generated').glob('*.v')))==17
    roles={}
    for kind in ('observable','memory','loader'):
        a=json.loads((rtlbase/'bundles'/kind/'manifest.json').read_text())
        b=json.loads((FINAL/'bundles'/kind/'manifest.json').read_text())
        for key in ('top_module','project','requested_tools','resources','simulation_resources','simulation_sources','synthesis_sources'):assert a[key]==b[key],(kind,key)
        for row in b['source_inputs']:
            data=(ROOT/row['path']).read_bytes()
            assert data==(FINAL/'bundles'/kind/'inputs'/row['path']).read_bytes()
            assert sha(data)==row['sha256']
        for row in b['files']:assert sha((FINAL/'bundles'/kind/row['path']).read_bytes())==row['sha256']
        source_paths={row['path'] for row in b['source_inputs']}
        if kind=='loader':
            assert {f'host_link_protocol/{n}' for n in ('dune','definitions.ml','codec.ml','host_link_protocol.ml','host_link_protocol.mli')}<=source_paths
            assert not any(p.startswith('host_link_wire/') for p in source_paths)
        for path in ('info.yaml','constraints/top.sdc','src/config.json'):assert (rtlbase/'bundles'/kind/path).read_bytes()==(FINAL/'bundles'/kind/path).read_bytes()
        for role,key in (('simulation','simulation_sources'),('synthesis','synthesis_sources')):
            assert (rtlbase/'bundles'/kind/a[key][0]).read_bytes()==(FINAL/'bundles'/kind/b[key][0]).read_bytes()
            stat='synth-'+kind+'-'+role+'.json'
            before=json.loads((statsbase/stat).read_text());after=json.loads((FINAL/stat).read_text())
            assert before['creator']==after['creator'] and before['design']==after['design']
            roles[kind+'-'+role]=dict(cells=after['design']['num_cells'],creator=after['creator'])
    summary=json.loads((FINAL/'result-summary.json').read_text())
    save('evidence-validation.json',dict(current_nondoc_sources_checked=checked,baseline_source_correspondence=len(baseline['verified_source_hashes']),
        generated_rtl=17,bundle_roles=6,synthesis=roles,index_unchanged=True,git_config_unchanged=True))
    names={x['name']:x for x in summary['commands']}
    for name in ('install-lint','ordinary-forced','rtl-forced-retry'):assert names[name]['exit']==0,name
    rtl=(FINAL/'logs/rtl-forced-retry.log').read_text()
    assert rtl.count('PASS p3.5 serial loader repair')==3
    namespaces=[]
    for tree in ('ip','rtl','lib','chip_top','test','host','bin','host_link_wire'):
        for p in (ROOT/tree).rglob('*'):
            if p.is_file() and (p.suffix in ('.ml','.mli') or p.name=='dune'):
                if re.search(r'Protemu_host_link_wire|protemu_host_link_wire',p.read_text()):namespaces.append(str(p.relative_to(ROOT)))
    save('remaining-legacy-references.json',namespaces)
    print('PASS: extraction, ordering-preserving bodies, consumers, 481 registrations, frozen 8, current integrated inputs, 17 RTL, 6 roles/stats, index/config.')


if __name__=='__main__':main()
