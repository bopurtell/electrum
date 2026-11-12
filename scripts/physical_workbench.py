#!/usr/bin/env python3
"""One owned stock_sram/timing_repair through-Timing Workbench journey.

Default is UI/source validation only. --launch allows exactly one production PTY
launch. Normal root companions are read unchanged; daemon/client state is private.
The whole owner is externally bounded to 5400 seconds including 120s escalation.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
import uuid

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/simulation'))
from fs2_wire import parse, sexp
from acceptance import Terminal, Client, field
import workbench


class StopOwned(BaseException):
    pass


def sha(path):
    hasher = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            hasher.update(block)
    return hasher.hexdigest()


def save(path, value):
    pending = path.with_name(path.name + '.pending')
    pending.write_text(json.dumps(value, indent=2) + '\n')
    os.replace(pending, path)


def module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


def docker_ids():
    return set(subprocess.check_output(['docker', 'ps', '--no-trunc', '-q'], text=True, timeout=10).split())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--launch', action='store_true')
    args = parser.parse_args()
    started = time.monotonic()
    output = ROOT / '_flow_results/workbench/physical-timing-repair' / uuid.uuid4().hex
    output.mkdir(parents=True)
    print('Owned journey: ' + str(output), flush=True)
    receipt = dict(status='starting', evidence=str(output), physical_launch_enabled=args.launch,
        physical_launch_count=0, launch_path='production terminal PTY palette -> Launch timing and view',
        whole_owner_seconds=5400, cancellation_grace_seconds=120, workers=6, sta_threads=1)
    save(output / 'receipt.json', receipt)
    daemon = terminal = http = None
    workflow = run_ref = execution = None
    owned_containers, baseline_containers = set(), docker_ids()
    freeze, config_hashes = {}, {}
    snapshots = 0
    def rpc(operation='Get', label=None):
        nonlocal snapshots
        value = http.rpc(operation if isinstance(operation, str) else sexp(operation), domain='asic', wait=False)
        if label:
            save(output / (label + '.json'), value)
            save(output / (label + '-wire.json'), http.history)
        http.history.clear()
        return value
    def poll(predicate, timeout=30, operation='Get'):
        deadline = time.monotonic() + timeout
        while True:
            value = rpc(operation)
            if predicate(value):
                return value
            if time.monotonic() >= deadline:
                raise TimeoutError('bounded public query: ' + sexp(value)[:2000])
            time.sleep(.15)
    def frozen():
        for path, digest in freeze.items():
            if sha(Path(path)) != digest:
                raise RuntimeError('source or selected executable changed during owned journey: ' + path)
        for path, digest in config_hashes.items():
            if sha(Path(path)) != digest:
                raise RuntimeError('normal root companion changed during owned journey: ' + path)
    def observe_containers():
        current = docker_ids()
        rows = []
        for identity in current - baseline_containers:
            info = json.loads(subprocess.check_output(['docker', 'inspect', identity], text=True, timeout=10))[0]
            mounts = [m.get('Source', '') for m in info.get('Mounts', [])]
            if not any(str(ROOT / '_flow_results/workbench/asic') in p for p in mounts):
                continue
            owned_containers.add(identity)
            cpus = info['HostConfig'].get('NanoCpus', 0)
            assert cpus == 6000000000, ('unexpected EDA CPU allocation', identity, cpus)
            rows.append(dict(id=identity, image=info['Config']['Image'], nano_cpus=cpus,
                             environment=info['Config'].get('Env', []), mounts=mounts))
        return rows
    try:
        workbench.stopped()
        tools = module(ROOT / 'scripts/install-tools.py', 'physical_selected_tools')
        selection, installed = tools.verify_selection()
        assert installed['sources']['asic']['revision'] == '3335f47cf8ac0ae065aa161705e57305389ef396'
        prefix = Path(selection['prefix'])
        config_paths = list((ROOT / '.workbench').glob('*.sexp'))
        config_hashes = {str(p): sha(p) for p in config_paths}
        config = dict(parse((ROOT / '.workbench/hardcaml-workbench-asic.sexp').read_text()))
        timeout = int(config['stage_timeout_seconds'][0])
        assert 1800 <= timeout <= 3600
        receipt['stage_timeout_seconds'] = dict(existing=timeout, selected=timeout, changed=False)
        receipt['normal_configs_sha256'] = config_hashes
        receipt['tool_selection'] = selection
        env = tools.environment(Path(installed['switch_prefix']), prefix)
        for key in list(env):
            if key.startswith(('PT3A_', 'PT8_', 'HARDCAML_WORKBENCH_')) or key == 'HARDCAML_ASIC_SYNTHESIS_TASK_LIMIT':
                env.pop(key)
        env.update(TERM='xterm-256color', DUNEJOBS='2', OPAMJOBS='2', MAKEFLAGS='-j2')
        with (output / 'source-build.stdout').open('xb') as out, (output / 'source-build.stderr').open('xb') as err:
            subprocess.run(['dune', 'build', '-j2', 'asic/cli/project.exe'], cwd=ROOT, env=env,
                           stdout=out, stderr=err, check=True, timeout=300)
        check = subprocess.run([sys.executable, '-B', str(ROOT / 'scripts/check-timing-profile.py'),
            '--project', str(ROOT / '_build/default/asic/cli/project.exe'), '--source-root', str(ROOT),
            '--output-root', str(output / 'source-validation'), '--retained-baseline-config',
            str(ROOT / '_flow_results/workbench/preparation/bundles/fcbd86b040f4be42404dbabc7cb182adb2f41ef42ba9a3a4f2cd4fa07396f43d/src/config.json')],
            cwd=ROOT, env=env, capture_output=True, check=True, timeout=120)
        (output / 'source-validation.stdout').write_bytes(check.stdout)
        (output / 'source-validation.stderr').write_bytes(check.stderr)
        validated = json.loads((output / 'source-validation/receipt.json').read_text())
        plan_identity = validated['timing_repair']['plan_identity']
        manifest = json.loads((Path(validated['timing_repair']['bundle']) / 'manifest.json').read_text())
        freeze = {str(ROOT / item['path']): item['sha256'] for item in manifest['source_inputs']}
        for path in (ROOT / '_build/default/asic/cli/project.exe', prefix / 'bin/hardcaml-asic-flow',
                     prefix / 'bin/hardcaml-workbench-daemon', prefix / 'bin/hardcaml-workbench'):
            freeze[str(path)] = sha(path)
        save(output / 'source-freeze.json', freeze)
        receipt.update(plan_identity=plan_identity, bundle_identity=manifest['identity'])
        save(output / 'receipt.json', receipt)
        for name in ('state', 'discovery', 'config', 'cache', 'user-state'):
            (output / name).mkdir(mode=0o700)
        env.update(XDG_CONFIG_HOME=str(output / 'config'), XDG_CACHE_HOME=str(output / 'cache'),
                   XDG_STATE_HOME=str(output / 'user-state'))
        with (output / 'daemon.stdout').open('xb') as out, (output / 'daemon.stderr').open('xb') as err:
            daemon = subprocess.Popen([str(prefix / 'bin/hardcaml-workbench-daemon'), '--port', '0',
                '--state-dir', str(output / 'state'), '--discovery-dir', str(output / 'discovery')],
                cwd=ROOT, env=env, stdout=out, stderr=err, start_new_session=True)
        deadline = time.monotonic() + 30
        while not (output / 'discovery/daemon.sexp').exists():
            assert daemon.poll() is None and time.monotonic() < deadline
            time.sleep(.05)
        metadata = dict(parse((output / 'discovery/daemon.sexp').read_text()))
        assert int(metadata['pid']) == daemon.pid
        save(output / 'daemon.json', metadata)
        http = Client(metadata['endpoint'], ROOT)
        rpc('Discover', 'discover-request')
        discovered = poll(lambda s: field(s, 'flows') and not any(field(o, 'state') in ('pending', 'executing') for o in field(s, 'operations')))
        stock = next(f for f in field(discovered, 'flows') if field(f, 'id') == 'stock_sram')
        assert 'timing_repair' in field(stock, 'profiles') and 'timing' in field(stock, 'fresh_stage_endpoints')
        selected = [('flow', 'stock_sram'), ('profile', 'timing_repair'), ('endpoint', 'timing'), ('assignments', [])]
        rpc(['Plan', selected], 'plan-request')
        planned = poll(lambda s: field(s, 'preview') and field(field(s, 'preview')[0], 'plan_identity') == plan_identity)
        save(output / 'public-plan.json', planned)
        session = type('Session', (), dict(args=type('Args', (), dict(client=prefix / 'bin/hardcaml-workbench'))(),
            url=metadata['endpoint'], root=ROOT, env=env, evidence=output))()
        terminal = Terminal(session)
        terminal.capture('ui-startup', ['Overview', 'Testing'])
        terminal.palette('Preparation inputs: stock_sram / timing_repair')
        terminal.capture('ui-profile-input', ['ENDPOINT'])
        os.write(terminal.master, b'\x15timing\r')
        terminal.drain(.5)
        terminal.palette('Plan PREPARATION inputs for manual launch')
        staged = poll(lambda s: field(s, 'fresh_intent') and
            field(field(s, 'fresh_intent')[0], 'selection') == [[k, v] for k, v in selected])
        intent = field(staged, 'fresh_intent')[0]
        assert field(intent, 'elaboration_only') == 'true'
        save(output / 'ui-staged-profile.json', staged)
        terminal.capture('ui-staged-profile', ['stock_sram', 'profile: timing_r'])
        frozen()
        if not args.launch:
            for key in (b' ', b'c', b'c'):
                os.write(terminal.master, key)
                terminal.drain(.12)
            os.write(terminal.master, b'Launch timing and view')
            terminal.drain(.2)
            terminal.capture('ui-launch-command-validated', ['Launch timing and view'], absent=['No matching commands'])
            os.write(terminal.master, b'\x1b')
            terminal.drain(.2)
            receipt.update(status='ui_source_validation_passed', physical_launch_count=0)
            return
        assert not field(staged, 'workflows'), 'unexpected preexisting workflow in private state'
        print('Submitting sole physical candidate through production PTY', flush=True)
        receipt.update(status='launching', physical_launch_count=1)
        save(output / 'receipt.json', receipt)
        terminal.palette('Launch timing and view')
        allocated = poll(lambda s: bool(field(s, 'workflows')), timeout=30)
        workflow = field(field(allocated, 'workflows')[0], 'id')
        assert len(field(allocated, 'workflows')) == 1
        save(output / 'allocated.json', allocated)
        last, heartbeat = None, 0
        terminal_snapshot = None
        while True:
            snapshot = rpc()
            current = next(w for w in field(snapshot, 'workflows') if field(w, 'id') == workflow)
            assert field(field(current, 'intent'), 'selection') == [[k, v] for k, v in selected]
            prepared = field(current, 'prepared')
            if prepared:
                assert field(prepared[0], 'plan_identity') == plan_identity
            if field(current, 'run'):
                run_ref = field(current, 'run')[0]
                matching = [r for r in field(snapshot, 'runs') if field(r, 'run') == run_ref]
                if matching and field(matching[0], 'execution_file'):
                    execution = field(matching[0], 'execution_file')[0]
            phase = field(current, 'phase')
            stages = [dict(id=field(st, 'id'), status=field(st, 'status'))
                      for r in field(snapshot, 'runs') for st in field(r, 'stages')]
            mark = (phase, json.dumps(stages, sort_keys=True))
            if mark != last:
                snapshots += 1
                save(output / f'transition-{snapshots:03d}.json', snapshot)
                terminal.save(f'ui-transition-{snapshots:03d}', terminal.drain(.15))
                last = mark
            if time.monotonic() - heartbeat >= 30:
                frozen()
                containers = observe_containers()
                pulse = dict(elapsed_seconds=time.monotonic() - started, phase=phase,
                             workflow=workflow, run=run_ref, execution_file=execution, stages=stages,
                             owned_containers=containers)
                with (output / 'heartbeat.jsonl').open('a') as stream:
                    stream.write(json.dumps(pulse) + '\n')
                print('Heartbeat: ' + json.dumps({k: pulse[k] for k in ('elapsed_seconds', 'phase', 'stages')}), flush=True)
                heartbeat = time.monotonic()
            if phase in ('Completed', 'Failed', 'Cancelled', 'Interrupted'):
                terminal_snapshot = snapshot
                break
            if time.monotonic() - started >= 5160:
                raise TimeoutError('owned whole-run budget reached; cancelling exact workflow')
            terminal.drain(.15)
            time.sleep(2)
        save(output / 'terminal-snapshot.json', terminal_snapshot)
        receipt.update(workflow=workflow, run=run_ref, execution_file=execution,
                       workflow_phase=phase, workflow_error=field(current, 'error'))
        assert execution, 'terminal workflow has no execution source record'
        native = json.loads(Path(execution).read_text())
        save(output / 'execution.json', native)
        report = subprocess.run([str(prefix / 'bin/hardcaml-asic-flow'), 'report', execution, '--json'],
                                cwd=ROOT, env=env, capture_output=True, timeout=60)
        (output / 'report.json').write_bytes(report.stdout)
        (output / 'report.stderr').write_bytes(report.stderr)
        receipt['report_exit_code'] = report.returncode
        rpc(['Refresh', run_ref], 'viewer-refresh')
        refreshed = poll(lambda s: not any(field(o, 'state') in ('pending', 'executing') for o in field(s, 'operations')))
        save(output / 'viewer-refreshed.json', refreshed)
        rpc(['Resources', ['Load', ['target', ['Run', run_ref]], ['refresh', 'true']]], 'resources-request')
        resource_view = poll(lambda s: not any(field(o, 'state') in ('pending', 'executing') for o in field(s, 'operations')))
        save(output / 'viewer-resources.json', resource_view)
        terminal.capture('ui-terminal', ['Overview'])
        terminal.palette('Switch to Resources')
        terminal.capture('ui-resources-reopen', ['Resources'])
        terminal.palette('Switch to Timing')
        terminal.capture('ui-timing-reopen', ['Timing'])
        frozen()
        receipt.update(status='terminal_evidence_retained', normal_configs_unchanged=True,
                       source_freeze_unchanged=True, public_resource_timing_reopen=True)
    except BaseException as error:
        receipt.update(status='owner_failed', error=type(error).__name__ + ': ' + str(error),
                       workflow=workflow, run=run_ref, execution_file=execution)
        raise
    finally:
        if http is not None and workflow is not None:
            try:
                snapshot = rpc()
                current = next((w for w in field(snapshot, 'workflows') if field(w, 'id') == workflow), None)
                if current and field(current, 'phase') not in ('Completed', 'Failed', 'Cancelled', 'Interrupted'):
                    rpc(['Cancel_workflow', workflow], 'owned-cancel')
                    poll(lambda s: any(field(w, 'id') == workflow and field(w, 'phase') in
                        ('Completed', 'Failed', 'Cancelled', 'Interrupted') for w in field(s, 'workflows')), timeout=120)
            except Exception as error:
                receipt['cancellation_error'] = str(error)
        if terminal is not None:
            terminal.close()
        try:
            observe_containers()
        except Exception as error:
            receipt['final_container_observation'] = str(error)
        if daemon is not None and daemon.poll() is None:
            daemon.terminate()
            try:
                daemon.wait(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(daemon.pid, signal.SIGKILL)
                daemon.wait(timeout=10)
        remaining = docker_ids() & owned_containers
        if remaining:
            for identity in sorted(remaining):
                subprocess.run(['docker', 'stop', '-t', '10', identity], capture_output=True, timeout=30)
        receipt.update(owned_containers=sorted(owned_containers),
                       remaining_owned_containers=sorted(docker_ids() & owned_containers),
                       daemon_reaped=daemon is None or daemon.poll() is not None,
                       elapsed_owner_seconds=time.monotonic() - started)
        save(output / 'receipt.json', receipt)
        print(json.dumps(receipt, indent=2), flush=True)


if __name__ == '__main__':
    def interrupted(signum, frame):
        signal.signal(signal.SIGTERM, signal.SIG_IGN)
        raise StopOwned('supervisor signal ' + str(signum))
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGINT, interrupted)
    main()
