"""Syntax and dry-run path checks only; never sources environment or runs flow steps."""
import ast
import json
import subprocess
import review as r

scripts=sorted((r.ROOT/'scripts').glob('*.sh'))+[r.ROOT/'asic/flow.sh']+sorted((r.ROOT/'asic/tinytapeout/scripts').glob('*.sh'))+[r.ROOT/'software/cli/scripts/p3.4-cli-workflow.sh']
for p in scripts:
    result=subprocess.run(['bash','-n',str(p)],env=r.ENV,capture_output=True,text=True)
    assert result.returncode==0,(p,result.stderr)
for p in (r.ROOT/'asic/tinytapeout/scripts').glob('*.py'):ast.parse(p.read_text())
result=subprocess.run(['make','-n','rtl'],cwd=r.ROOT/'asic/tinytapeout/test',env=r.ENV,capture_output=True,text=True)
assert result.returncode==0,result.stderr
assert '../../../_flow_results/legacy/rtl-test' in result.stdout
assert '../../verif/observable/emitted/tb.v' in result.stdout
r.save('make-dry-run.log',result.stdout)
flow=(r.ROOT/'asic/tinytapeout/scripts/adopted-flow.sh').read_text()
assert flow.index('for step in "$@"')<flow.index('mkdir -p "$repo_root/_flow_results"')
assert 'repo_root=$(cd "$script_dir/../../.." && pwd)' in flow
assert 'if [[ -n $value && $value != /* ]]; then printf -v "$name"' in flow
assert 'tool_python=${PROTEMU_FLOW_PY:-$repo_root/_flow_tools/venv/bin/python}' in flow
assert 'local results=${PROTEMU_FLOW_RESULTS:-$repo_root/_flow_results/archives}' in flow
stage=(r.ROOT/'asic/tinytapeout/scripts/stage-project.sh').read_text()
assert stage.index('acquire_stage_lock "$repo_root"')<stage.index('rm -rf "$stage_dir"')
assert stage.index('"$repo_root"/_flow_results/legacy/p0-staged) ;;')<stage.index('rm -rf "$stage_dir"')
bootstrap=(r.ROOT/'asic/tinytapeout/scripts/bootstrap-toolchain.sh').read_text()
guard=bootstrap[bootstrap.index('assert_writable_path()'):bootstrap.index('# Portable helpers')]
for name in ('venv_dir','precheck_venv_dir','pdk_dir','managed_tt_dir','env_file','stage_dir'):assert '$'+name in guard
assert 'mutating() { [[ $check_only -eq 0 ]]; }' in bootstrap
current=(r.ROOT/'software/compatibility/hardware/hardcaml_protemu.ml').read_bytes()
assert current==(r.ROOT/'_build/install/default/lib/hardcaml_protemu/hardcaml_protemu.ml').read_bytes()
assert current==(r.ROOT/'.dev/final-layout/hardware/install/lib/hardcaml_protemu/hardcaml_protemu.ml').read_bytes()
model=(r.ROOT/'verif/reference/model/protemu_f_model.ml').read_text()
assert 'module Example_programs = Protemu_firmware_examples.Example_programs' in model
r.save('script-controls.json',dict(shell_syntax=len(scripts),python_syntax=4,make_paths_resolve=True,
    flow_validation_before_output_creation=True,flow_caller_relative_overrides_normalized=True,
    staging_guard_and_lock_preserved=True,bootstrap_check_mutation_gate_present=True,
    tool_and_output_defaults_separated=True,installed_hardware_facade_matches_authored=True,
    activation_or_provisioning_executed=False,flow_or_eda_executed=False))
print('PASS syntax/dry-run paths, static flow/stage/bootstrap guards, installed facade correspondence; no activation/build/flow actions.')
