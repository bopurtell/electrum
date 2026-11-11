"""Read-only final boundary/format closure. No compilation, build or EDA."""
import json
from pathlib import Path
import re
import review as r

P=r.ROOT/'.dev/final-layout/hardware/private-oracle'
C=r.ROOT/'.dev/final-layout-c/format-review'


def main():
    original=json.loads((r.OUT/'review-state.json').read_text())
    index_before=r.sha((r.ROOT/'.git/index').read_bytes())
    assert index_before==original['index_before']
    assert r.git('rev-parse','HEAD').decode().strip()==original['revision']
    assert not (r.ROOT/'software/compatibility/hardware').exists()
    private=r.ROOT/'ip/host_link/verif/archived/support'
    stanza=r.parse((private/'dune').read_text())[0]
    assert r.field(stanza,'name')==['hardcaml_protemu'] and r.field(stanza,'public_name') is None
    assert r.field(stanza,'install') is None
    aliases=json.loads((r.OUT/'hardware.json').read_text())['alias_exports']
    source=r.strip_comments((private/'hardcaml_protemu.ml').read_text())
    assert dict(re.findall(r'^module (\w+) = ([\w.]+)$',source,re.M))==aliases
    assert not re.search(r'\b(let|type|include|open)\b',source)
    before=json.loads((P/'before.json').read_text())
    assert len(before['frozen'])==8 and len(before['hardware'])==26
    for entries in before.values():
        for path,digest in entries.items():assert r.sha((r.ROOT/path).read_bytes())==digest,path
    graph={};where={};refs=[];public={}
    for tree in ('ip','asic','software','verif','firmware','spec'):
        for path in (r.ROOT/tree).rglob('*'):
            if not path.is_file() or not (path.suffix in ('.ml','.mli') or path.name=='dune'):continue
            text=path.read_text()
            if re.search(r'Hardcaml_protemu|(?<![\w.])hardcaml_protemu(?=[\s)])',text):refs.append(str(path.relative_to(r.ROOT)))
            if path.name=='dune':
                for node in r.parse(text):
                    if node and node[0] in ('library','executable','executables'):
                        for name in r.field(node,'name') or r.field(node,'names'):
                            assert name not in graph,name
                            graph[name]=r.field(node,'libraries',[]);where[name]=str(path.relative_to(r.ROOT))
                            pkg=r.field(node,'public_name')
                            if pkg:public[name]=pkg[0]
    allowed=set(before['frozen'])|{'ip/host_link/verif/archived/support/dune','ip/host_link/verif/archived/support/hardcaml_protemu.ml'}
    assert set(refs)<=allowed,refs
    def closure(name,seen=None):
        seen=set() if seen is None else seen
        for dep in graph.get(name,[]):
            if dep not in seen:seen.add(dep);closure(dep,seen)
        return seen
    for name,path in where.items():
        if name!='hardcaml_protemu' and '/archived/hl4a/' not in path:assert 'hardcaml_protemu' not in closure(name),name
    assert 'hardcaml_protemu' not in public
    proof=json.loads((P/'installed-proof.json').read_text())
    duneproof=json.loads((P/'dune-installed-proof.json').read_text())
    install=Path(proof['isolated_findlib_config']).parent/'install/lib/hardcaml_protemu'
    standard=r.ROOT/'_build/install/default/lib/hardcaml_protemu'
    expected=set(proof['installed_libraries'])
    assert len(expected)==13 and 'hardcaml_protemu' not in expected
    forbidden=[]
    for folder in (install,standard):
        pkg=r.parse((folder/'dune-package').read_text())
        libs={r.field(n,'name')[0]:n for n in pkg if n and n[0]=='library'}
        assert set(libs)==expected
        for name,node in libs.items():assert 'hardcaml_protemu' not in r.field(node,'requires',[]),(name,node)
        for path in folder.rglob('*'):
            if path.is_file() and (path.stem=='hardcaml_protemu' or path.name.startswith('hardcaml_protemu__')):forbidden.append(str(path))
        for row in json.loads((r.ROOT/'.dev/final-layout/hardware/before.json').read_text())['sources']:
            owner=row['namespace'].split('.')[0].removeprefix('Protemu_')
            assert (folder/owner/Path(row['destination']).name).read_bytes()==(r.ROOT/row['destination']).read_bytes(),row['destination']
    assert not forbidden,forbidden
    config=Path(proof['isolated_findlib_config']).read_text()
    assert '_build/' not in config and 'installed-check-final/install/lib' in config
    external=Path(proof['isolated_findlib_config']).parent/'external-deps'
    assert all(not p.name.startswith(('hardcaml_protemu','protemu')) for p in external.iterdir())
    assert len(proof['canonical_consumers'])==8 and duneproof['canonical_installed_consumers']==8
    assert proof['root_module_rejected'] and proof['root_package_module_rejected'] and duneproof['root_library_rejected']
    for path in ('reject-flat-module.log','reject-flat-root-package-module.log'):
        assert re.search(r'Unbound module "?Hardcaml_protemu',(P/path).read_text()),path
    assert 'Library "hardcaml_protemu" not found' in (P/'dune-reject-flat-installed-library.log').read_text()
    commands=[json.loads(x) for x in (P/'commands.jsonl').read_text().splitlines()]
    latest={x['name']:x for x in commands}
    for owner in ('mechanisms','mechanisms_staging','controller','core','core_legacy','host_link','system','asic_bringup'):
        assert latest['consumer-'+owner]['exit']==0,owner
        assert 'installed-check-final/consumers' in latest['consumer-'+owner]['cwd']
    for name in ('install-lint','frozen-and-relevant-forced','dune-canonical-installed-consumers'):assert latest[name]['exit']==0,name
    for name in ('reject-flat-module','reject-flat-root-package-module','dune-reject-flat-installed-library'):assert latest[name]['exit']!=0,name
    b=json.loads((r.ROOT/'.dev/final-layout-b/format-closure.json').read_text())
    c=json.loads((C/'format-and-archive-checks.json').read_text())
    assert len(b['files'])==11 and len(c['files'])==7
    for row in b['files']:
        assert row['formatter_pass'] and r.sha((r.ROOT/row['path']).read_bytes())==row['after_sha256'],row['path']
    for path,row in c['files'].items():
        assert row['format_clean'] and row['matches_formatter_of_original']
        assert r.sha((r.ROOT/path).read_bytes())==row['after_sha256'],path
    assert c['archive_index_sha256']==r.sha((r.ROOT/'archive/INDEX.md').read_bytes())
    previous=json.loads((r.OUT/'archives.json').read_text())
    for row in previous:
        path=r.ROOT/row['new']
        assert r.sha(path.read_bytes())==row['sha256'] and oct(path.stat().st_mode&0o777)==row['mode'],row['new']
    assert len(previous)==42
    inventory=set(json.loads((r.OUT/'source-inventories.json').read_text())['inputs'])
    assert len(inventory)==55
    for name in inventory:
        assert not name.startswith(('software/','verif/','archive/'))
        if Path(name).suffix in ('.ml','.mli'):
            assert not re.search(r'\bHardcaml_protemu\b',(r.ROOT/name).read_text()),name
        if Path(name).name=='dune':
            for node in r.parse((r.ROOT/name).read_text()):
                assert 'hardcaml_protemu' not in r.field(node,'libraries',[]),name
    identities={}
    am3=r.ROOT/'.dev/am3/integrated-final-20261111'
    for kind in ('observable','memory','loader'):
        folder=C/'bundles'/kind
        manifest=json.loads((folder/'manifest.json').read_text())
        assert {x['path'] for x in manifest['source_inputs']}==inventory
        for row in manifest['source_inputs']:
            content=(r.ROOT/row['path']).read_bytes()
            assert content==(folder/'inputs'/row['path']).read_bytes() and r.sha(content)==row['sha256'],row['path']
        for row in manifest['files']:assert r.sha((folder/row['path']).read_bytes())==row['sha256']
        old=json.loads((am3/'bundles'/kind/'manifest.json').read_text())
        for key in ('simulation_sources','synthesis_sources'):assert (folder/manifest[key][0]).read_bytes()==(am3/'bundles'/kind/old[key][0]).read_bytes()
        for key in ('resources','simulation_resources','requested_tools','top_module','project'):assert manifest[key]==old[key]
        identities[kind]=manifest['identity']
    regs=[]
    for tree in ('ip','asic','software','verif','firmware','spec'):
        for path in (r.ROOT/tree).rglob('*.ml'):regs+=re.findall(r'let%(?:test_unit|expect_test|test)\b[^=\n]*',path.read_text())
    assert len(regs)==481
    assert r.sha((r.ROOT/'.git/index').read_bytes())==index_before and not r.git('diff','--cached','--name-only')
    r.save('CLOSEOUT-validation.json',dict(public_flat_api_absent=True,private_adapter_only_frozen_consumers=True,
        private_adapter_aliases=26,installed_libraries=sorted(expected),canonical_installed_consumers=8,
        installed_dune_consumers=8,negative_module_and_dune_logs_valid=True,installed_flat_artifacts=forbidden,
        frozen_unchanged=8,rtl_unchanged=26,registrations=481,formatting_findings_closed=18,
        fresh_bundle_roles_identical=6,canonical_inputs_per_bundle=55,current_bundle_identities=identities,
        archives_unchanged=42,remaining_flat_references=refs,index_sha256=index_before,index_unchanged=True,
        builds_compilation_or_eda_run=False))
    print('PASS: no installed flat API; private oracle adapter only; 13 installed sublibraries/eight positive consumers/negative boundaries; 18 format fixes; 481 tests, frozen8/RTL26, 55 inputs/six roles, archive42 and index unchanged.')


if __name__=='__main__':main()
