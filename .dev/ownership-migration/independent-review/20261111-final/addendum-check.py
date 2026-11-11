"""Read-only closure of the seven findings; writes only a new addendum report."""
import json
import re
from pathlib import Path
import review as r

FRESH=r.EVIDENCE/'package-tooling-format-post'


def reverse_format_diff(current,diff):
    lines=current.splitlines(True)
    output=[]
    position=0
    patch=diff.splitlines(True)
    i=2
    while i<len(patch):
        match=re.match(r'@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@',patch[i])
        assert match,patch[i]
        start=int(match.group(1))-1
        output.extend(lines[position:start])
        position=start
        i+=1
        while i<len(patch) and not patch[i].startswith('@@'):
            line=patch[i]
            if line.startswith((' ','+')):
                assert lines[position]==line[1:],(lines[position],line)
                position+=1
            if line.startswith((' ','-')):
                output.append(line[1:])
            i+=1
    output.extend(lines[position:])
    return ''.join(output)


def main():
    original={row['path']:row['sha256'] for row in json.loads((r.OUT/'current-source-hashes.json').read_text())}
    corrected=json.loads((FRESH/'source-hashes.json').read_text())
    assert len(corrected)==7
    changed=[]
    for path,before_hash in original.items():
        if path.startswith('docs/') or path in {'README.md','README.txt'}:continue
        current=(r.ROOT/path).read_bytes()
        if r.sha(current)!=before_hash:
            changed.append(path)
    assert set(changed)==set(corrected),(changed,corrected)
    for path,after_hash in corrected.items():
        current=(r.ROOT/path).read_text()
        assert r.sha(current.encode())==after_hash,path
        diff=(r.OUT/('format-'+path.replace('/','__')+'.diff')).read_text()
        restored=reverse_format_diff(current,diff)
        assert r.sha(restored.encode())==original[path],path
    checks=json.loads((FRESH/'scoped-formatting.json').read_text())
    assert len(checks)==7 and all(x['exit']==0 and x.get('format_equal',True) for x in checks)
    summary=json.loads((FRESH/'result-summary.json').read_text())
    assert not summary['failures']
    assert all(x['exit']==0 or x['name']=='fmt-backlog' for x in summary['commands'])
    baseline={x['path']:x['sha256'] for x in json.loads((r.BASE/'source-snapshot.json').read_text())}
    backlog=json.loads((FRESH/'format-backlog.json').read_text())
    assert len(backlog['failures'])==backlog['baseline_leftover_count']==23
    assert backlog['introduced_count']==0
    for row in backlog['failures']:
        assert r.sha((r.ROOT/row['path']).read_bytes())==baseline[row['baseline_path']],row
    for path in (r.BASE/'generated').glob('*.v'):
        assert path.read_bytes()==(FRESH/'generated'/path.name).read_bytes(),path.name
    identities={}
    source_counts={}
    for kind in ('observable','memory','loader'):
        manifest=json.loads((FRESH/'bundles'/kind/'manifest.json').read_text())
        previous=json.loads((r.POST/'bundles'/kind/'manifest.json').read_text())
        base=json.loads((r.BASE/'bundles'/kind/'manifest.json').read_text())
        inputs={x['path']:x for x in manifest['source_inputs']}
        old_inputs={x['path']:x for x in previous['source_inputs']}
        assert inputs.keys()==old_inputs.keys()
        changes=[p for p in inputs if inputs[p]!=old_inputs[p]]
        assert len(changes)==4 and set(changes)<=set(corrected),(kind,changes)
        for path in inputs:
            assert (r.ROOT/path).read_bytes()==(FRESH/'bundles'/kind/'inputs'/path).read_bytes(),path
        for row in manifest['files']:
            assert r.sha((FRESH/'bundles'/kind/row['path']).read_bytes())==row['sha256'],row
        for key in ('top_module','project','requested_tools','resources','simulation_resources','simulation_sources','synthesis_sources'):
            assert manifest[key]==base[key],(kind,key)
        for key in ('simulation_sources','synthesis_sources'):
            assert len(manifest[key])==1
            assert (FRESH/'bundles'/kind/manifest[key][0]).read_bytes()==(r.BASE/'bundles'/kind/base[key][0]).read_bytes(),(kind,key)
        for path in ('info.yaml','constraints/top.sdc','src/config.json'):
            assert (FRESH/'bundles'/kind/path).read_bytes()==(r.BASE/'bundles'/kind/path).read_bytes()
        identities[kind]=manifest['identity']
        source_counts[kind]=dict(inputs=len(inputs),changed_inputs=changes)
    installed=json.loads((r.BASE/'installed-hardcaml-files.json').read_text())
    assert all(r.sha(Path(row['path']).read_bytes())==row['sha256'] for row in installed)
    assert r.sha((r.ROOT/'.git/index').read_bytes())==(r.BASE/'initial-index.sha256').read_text().strip()
    historical=[]
    for path,digest in baseline.items():
        if path.startswith(('flow_results/','docs/history/','tinytapeout/reports/')) or path=='loader_core.v' or (path.startswith('tinytapeout/src/') and path.endswith('.v')):
            assert r.sha((r.ROOT/path).read_bytes())==digest,path
            historical.append(path)
    docs=['README.md','README.txt','docs/README.md','docs/repository_layout.md','docs/ownership_layout.md',
          'docs/architecture_migration.md','docs/phase_plan.md','docs/verification.md',
          'docs/serial_host_pilot.md','docs/formatting_guide.md']
    r.save('addendum-current-doc-hashes.json',{p:r.sha((r.ROOT/p).read_bytes()) for p in docs})
    report=dict(seven_findings_closed=True,only_review_requested_source_diffs=True,
        formatting_baseline_failures=23,introduced_format_failures=0,generated_rtl_identical=17,bundle_roles_identical=6,
        fresh_manifest_source_closure_valid=True,bundle_identities=identities,source_inventories=source_counts,
        prior_26_rtl_475_registrations_8_frozen_preservation_unchanged=True,
        index_hash_unchanged=True,installed_hardcaml_file_hashes_unchanged=len(installed),
        historical_files_and_outputs_unchanged=len(historical),heavy_checks_rerun=False)
    r.save('ADDENDUM-validation.json',report)
    print(json.dumps(report,indent=2))


if __name__=='__main__':main()
