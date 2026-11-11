#!/usr/bin/env python3
"""Derive comparison inventories from retained baseline bytes."""
import fcntl
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import hashlib

sys.path.insert(0, str(Path(__file__).resolve().parent))
import capture as c


def main():
    assert (c.OUT/'complete.txt').exists(), 'Baseline runner must finish first'
    with open('/home/wayne/devel/jane/.protemu-build.lock', 'a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        for mode, top in [('access','protocol_core'),('executable','executable_core'),
                          ('integrated','integrated_core'),('loader','loader_core')]:
            source = c.OUT/'generated'/(mode+'.v')
            stats = c.OUT/('synth-core-'+mode+'.json')
            c.run('synth-core-'+mode, ['yosys','-p',f'read_verilog {source}; hierarchy -check -top {top}; synth -top {top}; tee -o {stats} stat -json'])
    inventories = []
    for source in sorted(list((c.OUT/'generated').glob('*.v')) + list((c.OUT/'bundles').glob('*/src/*.v')) + list((c.OUT/'bundles').glob('*/simulation/*.v'))):
        text = source.read_text()
        modules = []
        for match in re.finditer(r'\bmodule\s+(\w+)\s*\((.*?)\);(.*?)\bendmodule', text, re.S):
            name, ordered_names, body = match.groups()
            ports = []
            for port in re.finditer(r'^\s*(input|output|inout)\s+(?:reg\s+|wire\s+)?(?:\[(\d+):(\d+)\]\s+)?(\w+)\s*;', body, re.M):
                direction, hi, lo, signal = port.groups()
                ports.append(dict(name=signal,direction=direction,width=abs(int(hi)-int(lo))+1 if hi else 1))
            modules.append(dict(name=name, ordered_port_names=[x.strip() for x in ordered_names.split(',')], ports=ports,
                                reg_declarations=len(re.findall(r'^\s*reg\s',body,re.M)),
                                always_blocks=len(re.findall(r'\balways\b',body))))
        inventories.append(dict(path=str(source.relative_to(c.OUT)), sha256=c.digest(source), modules=modules))
    c.write('rtl-interface-inventory.json', inventories)
    stats = {}
    for path in sorted(c.OUT.glob('synth-*.json')):
        try:
            stats[path.stem] = json.loads(path.read_text())
        except json.JSONDecodeError:
            stats[path.stem] = {'unparseable':str(path)}
    c.write('synthesis-inventory.json', stats)
    pairs = []
    for role, emitted in [('simulation','simulation'),('synthesis','src')]:
        fresh = c.OUT/'bundles/loader'/emitted/'tt_um_leemperor_hardcaml_protemu_loader.v'
        tested = c.ROOT/'_build/default/tinytapeout/src'/('loader_wrapper.'+role+'.generated.v')
        pairs.append(dict(role=role, fresh=str(fresh), tested=str(tested),
                          fresh_sha256=c.digest(fresh), tested_sha256=c.digest(tested), identical=fresh.read_bytes()==tested.read_bytes()))
    c.write('loader-tested-bundle-comparison.json', pairs)
    c.write('root-loader-history.txt', c.git('log','--follow','--format=fuller','--','loader_core.v'))
    snapshot = json.loads((c.OUT/'source-snapshot.json').read_text())
    references = []
    for record in snapshot:
        path = c.ROOT/record['path']
        if path.suffix in {'.gz','.png','.pdf'}:
            continue
        try:
            for number,line in enumerate(path.read_text().splitlines(),1):
                if 'loader_core.v' in line:
                    references.append(dict(path=record['path'],line=number,text=line))
        except UnicodeError:
            pass
    c.write('root-loader-references.json', references)
    before = json.loads((c.OUT/'source-snapshot.json').read_text())
    changes = [x['path'] for x in before if not (c.ROOT/x['path']).exists() or c.digest(c.ROOT/x['path']) != x['sha256']]
    c.write('final-source-comparison.json', dict(changed_tracked_paths=changes,
        non_documentation_changes=[x for x in changes if not x.startswith('docs/')],
        index_unchanged=c.digest(c.ROOT/'.git/index') == (c.OUT/'initial-index.sha256').read_text().strip()))
    commands = [json.loads(line) for line in (c.OUT/'commands.jsonl').read_text().splitlines()]
    c.write('result-summary.json',dict(commands=len(commands),failures=[x for x in commands if x['exit_code']!=0],
        tracked_files=len(snapshot),test_registrations=len(json.loads((c.OUT/'test-registrations.json').read_text())),
        generated_rtl=len(list((c.OUT/'generated').glob('*.v'))),bundle_roles=6))
    rows = ['| Check | Exit | Seconds |', '| --- | ---: | ---: |']
    for command in commands:
        if command['label'] in {'build-install-lint','ordinary-runtest','rtl'} or command['label'].startswith(('bundle-check-','simulate-','lint-','synth-','retained-metadata-')):
            rows.append('| '+command['label']+' | '+str(command['exit_code'])+' | '+str(command['elapsed_seconds'])+' |')
    failures = [x for x in commands if x['exit_code'] != 0]
    rows += ['', 'Failures: '+(', '.join(x['label'] for x in failures) if failures else 'none; all recorded commands exited zero')+'.',
             '', 'Tracked non-documentation changes: '+str([x for x in changes if not x.startswith('docs/')])+'.',
             'Persistent/tested loader RTL role comparisons: '+str([x['identical'] for x in pairs])+'.',
             '', 'Baseline capture and comparison inventories are complete; ready for ownership-migration agents.']
    receipt = c.OUT/'RECEIPT.md'
    receipt.write_text(receipt.read_text().replace('Pending completion of the running baseline capture and final inventories.', '\n'.join(rows)))
    c.write('final-status.txt',c.git('status','--short','--untracked-files=all'))
    c.write('evidence-sha256.json',[dict(path=str(p.relative_to(c.OUT)),sha256=c.digest(p),size=p.stat().st_size)
        for p in sorted(c.OUT.rglob('*')) if p.is_file() and p.name not in {'evidence-sha256.json','running.json'}])
    print((c.OUT/'result-summary.json').read_text())


if __name__ == '__main__':
    if '--seal' in sys.argv:
        records = json.loads((c.OUT/'source-snapshot.json').read_text())
        with tarfile.open(c.OUT/'source-snapshot.tar.gz') as archive:
            for record in records:
                assert hashlib.sha256(archive.extractfile(record['path']).read()).hexdigest() == record['sha256'], record['path']
        inventory = json.loads((c.OUT/'rtl-interface-inventory.json').read_text())
        assert len(inventory) == 23
        assert all(record['modules'] and all(module['ports'] for module in record['modules']) for record in inventory)
        stats = json.loads((c.OUT/'synthesis-inventory.json').read_text())
        assert len(stats) == 10 and all('unparseable' not in item for item in stats.values())
        c.write('capture-integrity.json', dict(source_archive_hashes_verified=len(records),
            rtl_inventories_verified=len(inventory), synthesis_json_verified=len(stats)))
        c.write('final-status.txt',c.git('status','--short','--untracked-files=all'))
        c.write('evidence-sha256.json',[dict(path=str(p.relative_to(c.OUT)),sha256=c.digest(p),size=p.stat().st_size)
            for p in sorted(c.OUT.rglob('*')) if p.is_file() and p.name not in {'evidence-sha256.json','running.json'}])
        print('Verified source archive, all RTL interfaces, synthesis JSON; sealed evidence checksums.')
    else:
        main()
