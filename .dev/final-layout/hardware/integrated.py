"""Final landed-tree verification; only writes local execution receipts."""
import importlib.util
import json
from pathlib import Path
import re
import sys

OUT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('hardware_verify', OUT / 'verify.py')
verify = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verify)

if __name__ == '__main__':
    if sys.argv[1] == 'checks':
        verify.run('integrated-install-lint', ['dune', 'build', '@install', '@lint', '-j5'])
        verify.run('integrated-verification-forced', ['dune', 'build', '@verification', '--force', '-j5'])
    elif sys.argv[1] == 'optional':
        verify.run('integrated-long', ['dune', 'build', '@verification-long', '--force', '-j5'])
        verify.run('integrated-four-state', ['dune', 'build', '@verification-four-state', '--force', '-j5'])
    elif sys.argv[1] == 'postformat':
        verify.run('integrated-postformat-install-lint', ['dune', 'build', '@install', '@lint', '-j5'])
    elif sys.argv[1] == 'format':
        try:
            verify.run('integrated-format-check', ['dune', 'build', '@fmt', '-j5'], show_failure=False)
        except AssertionError:
            pass
        log = (OUT / 'integrated-format-check.log').read_text()
        failed = sorted(set(re.findall(r'^------ (.+)$', log, re.M)))
        baseline = json.loads((verify.BASE / 'format-classification.json').read_text())
        relocations = {'f_model/': 'verif/reference/model/', 'isa/': 'spec/isa/',
                       'rtl/protemu_top.ml': 'ip/protemu_system/rtl/protemu_top.ml',
                       'test/backend_conformance/': 'verif/backends/conformance/'}
        previous = {}
        for row in baseline['failures']:
            old = row['path']
            new = old
            for prefix, destination in relocations.items():
                if old.startswith(prefix):
                    new = destination + old[len(prefix):]
                    break
            previous[new] = old
        result = dict(baseline_count=len(previous), current_count=len(failed),
                      introduced_files=[p for p in failed if p not in previous],
                      retained_baseline_files=[dict(path=p, baseline=previous[p]) for p in failed if p in previous],
                      resolved_baseline_files=[p for p in previous if p not in failed])
        oldlog = (verify.BASE / 'logs/global-format.log').read_text()
        def edits(text, path):
            section = text.split('------ ' + path + '\n', 1)[1].split('\n------ ', 1)[0]
            return re.findall(r'^[-+]\|.*$', section, re.M)
        result['baseline_edit_comparison'] = [
            dict(path=p, formatter_edits_identical=edits(log, p) == edits(oldlog, previous[p]),
                 old_edits=edits(oldlog, previous[p]), current_edits=edits(log, p))
            for p in failed if p in previous]
        verify.save('integrated-format-classification.json', result)
        print(json.dumps({k:v for k,v in result.items() if k != 'baseline_edit_comparison'}, indent=2))
        print('Baseline formatter edit differences:', [r['path'] for r in result['baseline_edit_comparison'] if not r['formatter_edits_identical']])
    elif sys.argv[1] == 'audit':
        root = verify.ROOT
        retired = ['lib', 'bin', 'test', 'host', 'f_model', 'rtl', 'chip_top', 'isa',
                   'host_link_protocol', 'host_link_wire', 'tinytapeout', 'examples', 'flow_results']
        missing = {path: not (root / path).exists() for path in retired}
        dune_files = []
        source_files = []
        for owner in ['asic', 'firmware', 'ip', 'software', 'spec', 'verif', 'scripts']:
            for path in (root / owner).rglob('*'):
                if not path.is_file() or any(p.startswith(('.', '_')) for p in path.relative_to(root).parts):
                    continue
                if path.name == 'dune':
                    dune_files.append(path)
                if path.suffix in ['.ml', '.mli']:
                    source_files.append(path)
        dune_files.append(root / 'dune')
        unqualified, copied_ocaml, unwrapped, copied = [], [], [], []
        for path in dune_files:
            text = path.read_text()
            relative = str(path.relative_to(root))
            # Strip Dune line comments before looking for active stanzas.
            active = re.sub(r';[^\n]*', '', text)
            if re.search(r'\(include_subdirs\s+unqualified\)', active):
                unqualified.append(relative)
            for rule in re.findall(r'\(copy_files#?\s+([^)]*)\)', active, re.S):
                copied.append(dict(path=relative, source=rule.strip()))
                if re.search(r'\.mli?(?:\s|$)|\.ml\*|\*\.\{?ml', rule):
                    copied_ocaml.append(dict(path=relative, source=rule.strip()))
            count = len(re.findall(r'\(wrapped\s+false\)', active))
            if count:
                unwrapped.append(dict(path=relative, stanzas=count))
        registrations = {str(path.relative_to(root)): len(re.findall(r'^\s*let%(?:expect_test|test_unit|test)\b[^\n]*', path.read_text(), re.M)) for path in source_files}
        registrations = {p:n for p,n in registrations.items() if n}
        bundle_counts = {}
        bundle_copied_inputs = {}
        bundle_folder = OUT / 'bundles-final'
        for kind in ['observable', 'memory', 'loader']:
            manifest = json.loads((bundle_folder / kind / 'manifest.json').read_text())
            bundle_counts[kind] = len(manifest['source_inputs'])
            for row in manifest['source_inputs']:
                source = root / row['path']
                copied_path = bundle_folder / kind / row['copy']
                assert verify.sha(source) == verify.sha(copied_path) == row['sha256'], row['path']
            bundle_copied_inputs[kind] = True
        historical = json.loads((OUT / 'before.json').read_text())['am3_outputs']
        assert all(verify.sha(root / path) == sha for path, sha in historical.items())
        log = (OUT / 'integrated-verification-forced.log').read_text()
        result = dict(retired_roots_absent=missing, active_dune_files=len(dune_files),
                      active_source_files=len(source_files), include_subdirs_unqualified=unqualified,
                      copied_ocaml_rules=copied_ocaml, copy_rules=copied,
                      intentional_unwrapped_libraries=unwrapped,
                      unwrapped_stanzas=sum(row['stanzas'] for row in unwrapped),
                      unwrapped_dune_files=len(unwrapped),
                      total_registrations=sum(registrations.values()), registrations=registrations,
                      bundle_source_counts=bundle_counts,
                      bundle_copied_inputs_match_current_sources=bundle_copied_inputs,
                      preserved_am3_files=len(historical),
                      loader_peer_passes=log.count('PASS p3.5 serial loader repair:'))
        verify.save('integrated-layout-audit.json', result)
        assert all(missing.values()) and not unqualified and not copied_ocaml
        assert sum(registrations.values()) == 481 and result['loader_peer_passes'] == 3
        assert bundle_counts == dict(observable=55, memory=55, loader=55)
        print(json.dumps({k:v for k,v in result.items() if k not in ['registrations', 'copy_rules', 'intentional_unwrapped_libraries']}, indent=2))
