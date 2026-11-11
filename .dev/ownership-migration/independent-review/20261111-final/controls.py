"""Small review controls: formatting status and extraction identity; no EDA."""
import difflib
import fcntl
import json
import re
import subprocess
import tarfile
import review as r


with tarfile.open(r.BASE/'source-snapshot.tar.gz') as archive:
    original=archive.extractfile('bin/asic_bundle.ml').read().decode()
project=(r.ROOT/'chip_top/project/chip_project.ml').read_text()
old_declaration=original[original.index('let observable_pinout'):original.index('let input_paths')]
new_declaration=project[project.index('let observable_pinout'):project.index('let input_paths')]
assert old_declaration.replace('Loader_design','Package_top')==new_declaration
with tarfile.open(r.BASE/'source-snapshot.tar.gz') as archive:
    old_observable=archive.extractfile('bin/asic_bundle.ml').read().decode()
start=old_observable.index('  let create context')
end=old_observable.index('\nend',start)
new_observable=(r.ROOT/'chip_top/rtl/observable_design.ml').read_text()
normalize=lambda text:re.sub(r'\s+','',text)
assert normalize(old_observable[start:end])==normalize(new_observable[new_observable.index('let create context'):])
r.save('extraction-controls.json',dict(project_pinout_timing_resource_policy_declaration_exact=True,
    observable_constructor_exact_ignoring_indentation=True,
    package_memory_constructor_review='Program_memory.create is the same width/depth/latency/name Single_port_ram binding factored out of Memory_design and Loader_design; call sites preserve construction order, clock, enables, address and data.',
    package_top_review='Reset synchronizer, host pin mapping, external memory feedback, occupied zero, output gating and pin enables preserve the original Loader_design expressions.'))
formats=[]
with open('/home/wayne/devel/jane/.protemu-build.lock','a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX)
    for path in ['bin/asic_bundle.ml','chip_top/project/chip_project.ml','chip_top/rtl/observable_design.ml',
                 'chip_top/rtl/memory_design.ml','chip_top/rtl/package_top.ml','chip_top/rtl/program_memory.ml']:
        args=['opam','exec','--switch=5.2.0+ox','--','ocamlformat','--check',path]
        result=subprocess.run(args,cwd=r.ROOT,env=r.ENV,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        r.save('format-'+path.replace('/','__')+'.log',result.stdout)
        formats.append(dict(path=path,exit=result.returncode))
        if result.returncode:
            formatted=subprocess.run(['opam','exec','--switch=5.2.0+ox','--','ocamlformat',path],
                cwd=r.ROOT,env=r.ENV,text=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            assert formatted.returncode==0,(path,formatted.stderr)
            r.save('format-'+path.replace('/','__')+'.diff',''.join(difflib.unified_diff(
                (r.ROOT/path).read_text().splitlines(True),formatted.stdout.splitlines(True),fromfile=path,tofile='formatted')))
    for path in ['lib/dune','chip_top/project/dune','bin/dune','tinytapeout/test/dune','tinytapeout/src/dune',
                 'test/core/protocol_core/dune','test/core/control_execution/dune','test/integration/uart_slice/dune']:
        result=subprocess.run(['opam','exec','--switch=5.2.0+ox','--','dune','format-dune-file',path],
            cwd=r.ROOT,env=r.ENV,text=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        assert result.returncode==0,(path,result.stderr)
        source=(r.ROOT/path).read_text()
        equal=source==result.stdout
        formats.append(dict(path=path,format_equal=equal))
        if not equal:
            r.save('format-'+path.replace('/','__')+'.diff',''.join(difflib.unified_diff(source.splitlines(True),result.stdout.splitlines(True),fromfile=path,tofile='formatted')))
r.save('targeted-formatting.json',formats)
print(json.dumps(formats,indent=2))
