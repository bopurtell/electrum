#!/usr/bin/env python3
"""Read-only review/reopen of the one retained physical journey; never launches EDA."""
import argparse
import json
import os
import re
from pathlib import Path
import signal
import subprocess
import sys
import time
import uuid
import urllib.request

sys.dont_write_bytecode = True
from physical_workbench import ROOT, Terminal, Client, field, parse, sexp, save, sha, module
from http_client import sexp as http_sexp


class EvidenceClient(Client):
    def raw(self, path, data=None):
        request = urllib.request.Request(self.url + path,
            data=None if data is None else http_sexp(data).encode(),
            headers={'Content-Type': 'application/sexp', 'X-Workbench-Protocol': '1',
                     'X-Workbench-Asic-Evidence-Metadata': '1', 'X-Workbench-Asic-Timing-Analysis': '2'})
        with urllib.request.urlopen(request, timeout=30) as response:
            text = response.read().decode()
        value = parse(text)
        self.history.append(dict(path=path, request=None if data is None else http_sexp(data), response=text))
        if path == '/api/hello':
            return value
        assert value[0] == 'Ok', text[:2000]
        return value[1]


def metrics(path):
    value = json.loads(path.read_text())
    return {key: number for key, number in value.items() if
            key.startswith(('timing__setup', 'timing__hold', 'design__max_cap', 'design__max_slew'))}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('journey', type=Path)
    args = parser.parse_args()
    journey = args.journey.resolve(strict=True)
    original = json.loads((journey / 'receipt.json').read_text())
    execution_file = Path(original['execution_file'])
    execution = json.loads(execution_file.read_text())
    workspace = execution_file.parent
    output = journey / ('review-' + uuid.uuid4().hex)
    output.mkdir()
    print('Read-only review: ' + str(output), flush=True)
    candidates = list((workspace / 'project/src/runs').glob('timing-*/final/metrics.json'))
    assert len(candidates) == 1
    candidate = metrics(candidates[0])
    baseline_path = ROOT / '_flow_results/pt3c/physical-20261112T033732Z/execution-01/runs/20261112T033931965658Z_0d5ed7ff/project/runs/asic/final/metrics.json'
    baseline = metrics(baseline_path)
    repairs = list((workspace / 'project/src/runs').glob('routing-*/**/openroad-resizertimingpostgrt.log'))
    assert len(repairs) == 1
    repair_text = repairs[0].read_text()
    corners = re.findall(r'^Reading timing models for corner ([A-Za-z0-9_]+)', repair_text, re.M)
    estimated = {'setup': {}, 'hold': {}}
    mode = None
    for line in repair_text.splitlines():
        if line.startswith('+ repair_timing '):
            mode = 'hold' if ' -hold ' in line else 'setup'
        if mode is not None and '|' in line:
            columns = [s.strip() for s in line.split('|')]
            if columns[0] in ('0', 'final'):
                estimated[mode][columns[0]] = float(columns[5 if mode == 'hold' else 7])
    def count(pattern):
        found = re.findall(pattern, repair_text)
        assert len(found) == 1, pattern
        return int(found[0])
    report = json.loads((journey / 'report.json').read_text())
    save(output / 'report-top-level.json', {k: v for k, v in report.items() if k != 'checkpoints'})
    summary = dict(physical_status=execution['status'], physical_exit_code=execution['exit_code'],
        stages=[dict(stage=o['action_key'], status=o['status'], exit_code=o['exit_code'],
                     duration_seconds=o['duration_seconds']) for o in execution['occurrences']],
        timing_goal_passed=candidate['timing__setup__ws'] >= 0 and candidate['timing__hold__ws'] >= 0,
        candidate=dict(path=str(candidates[0]), sha256=sha(candidates[0]), metrics=candidate),
        baseline_separate_historical_run=dict(path=str(baseline_path), sha256=sha(baseline_path), metrics=baseline),
        comparison_scope='separate retained runs, not within-run before/after; baseline coarse full flow had failed physical validation',
        repair_log=dict(path=str(repairs[0]), sha256=sha(repairs[0]),
            corners=corners, within_step_estimated_slack_ns=estimated,
            setup_buffers=count(r'Inserted ([0-9]+) buffers\.'),
            resized_instances=count(r'Resized ([0-9]+) instances:'),
            pin_swaps=count(r'Swapped pins on ([0-9]+) instances\.'),
            hold_buffers=count(r'Inserted ([0-9]+) hold buffers\.'),
            qualification='actual logged repair; estimated routing slack is not final extracted STA'))
    save(output / 'physical-summary.json', summary)
    print(json.dumps({k: summary[k] for k in ('physical_status', 'physical_exit_code', 'stages', 'timing_goal_passed')}, indent=2))
    for label, key in [('setup_ws', 'timing__setup__ws'), ('hold_ws', 'timing__hold__ws'),
                       ('setup_tns', 'timing__setup__tns'), ('setup_violations', 'timing__setup_vio__count')]:
        print(label + ': baseline=' + str(baseline[key]) + ' candidate=' + str(candidate[key]))
    tools = module(ROOT / 'scripts/install-tools.py', 'review_installed_tools')
    selection, installed = tools.verify_selection()
    prefix = Path(selection['prefix'])
    env = tools.environment(Path(installed['switch_prefix']), prefix)
    env.update(TERM='xterm-256color', XDG_CONFIG_HOME=str(journey / 'config'),
               XDG_CACHE_HOME=str(journey / 'cache'), XDG_STATE_HOME=str(journey / 'user-state'),
               DUNEJOBS='2', OPAMJOBS='2', MAKEFLAGS='-j2')
    daemon = terminal = http = None
    proof = dict(status='starting', physical_run_retried=False, physical_summary=str(output / 'physical-summary.json'))
    try:
        with (output / 'daemon.stdout').open('xb') as out, (output / 'daemon.stderr').open('xb') as err:
            daemon = subprocess.Popen([str(prefix / 'bin/hardcaml-workbench-daemon'), '--port', '0',
                '--state-dir', str(journey / 'state'), '--discovery-dir', str(journey / 'discovery')],
                cwd=ROOT, env=env, stdout=out, stderr=err)
        deadline = time.monotonic() + 30
        while True:
            meta = dict(parse((journey / 'discovery/daemon.sexp').read_text()))
            if int(meta['pid']) == daemon.pid:
                break
            assert daemon.poll() is None and time.monotonic() < deadline
            time.sleep(.1)
        http = EvidenceClient(meta['endpoint'], ROOT)
        def rpc(op='Get', label=None):
            value = http.rpc(op if isinstance(op, str) else sexp(op), domain='asic', wait=False)
            if label:
                save(output / (label + '.json'), value)
                save(output / (label + '-wire.json'), http.history)
            http.history.clear()
            return value
        def wait_for(predicate, label, timeout=120):
            deadline = time.monotonic() + timeout
            while True:
                value = rpc()
                if predicate(value):
                    save(output / (label + '.json'), value)
                    return value
                if time.monotonic() >= deadline:
                    save(output / (label + '-timeout.json'), value)
                    raise TimeoutError(label)
                time.sleep(.5)
        run = original['run']
        reopened = rpc('Get', 'reopened-store')
        assert any(field(r, 'run') == run for r in field(reopened, 'runs')), 'same-store physical run missing'
        rpc(['Load_summary', run], 'load-summary')
        snapshot = wait_for(lambda s: any(field(v, 'run') == run for v in field(s, 'summaries')), 'summary-reopened')
        native_summary = next(v for v in field(snapshot, 'summaries') if field(v, 'run') == run)
        save(output / 'selected-summary.json', native_summary)
        rpc(['Resources', ['Load', ['target', ['Run', run]], ['refresh', 'true']]], 'resources-query')
        snapshot = wait_for(lambda s: field(s, 'resources') and field(field(s, 'resources')[0], 'indexes'), 'resources-reopened')
        resource = field(snapshot, 'resources')[0]
        assert any(field(row, 'id') == 'program' for index in field(resource, 'indexes') for row in field(index, 'rows'))
        analysis = field(native_summary, 'timing_analysis')
        assert analysis, 'exact retained Timing analysis association unavailable'
        target = field(analysis[0], 'target')
        rpc(['Inspect_analysis', ['run', run], ['target', target], ['refresh', 'false']], 'timing-query')
        snapshot = wait_for(lambda s: any(dict(i).get('analysis') == [target] for i in field(s, 'inspections')), 'timing-reopened')
        timing_index = next(i for i in field(snapshot, 'inspections') if dict(i).get('analysis') == [target])
        timing_diagnostics = field(timing_index, 'diagnostics')
        has_paths = bool(field(timing_index, 'rows'))
        if not has_paths:
            assert any('log line bound exceeded' in text for text in timing_diagnostics)
        save(output / 'public-operations.json', field(snapshot, 'operations'))
        session = type('Session', (), dict(args=type('Args', (), dict(client=prefix / 'bin/hardcaml-workbench'))(),
            url=meta['endpoint'], root=ROOT, env=env, evidence=output))()
        terminal = Terminal(session)
        terminal.capture('ui-reopened-overview', ['Overview'])
        terminal.palette('Switch to Resources')
        resource_screen = terminal.capture('ui-reopened-resources', ['Resources', 'program'])
        terminal.palette('Switch to Timing')
        terminal.palette('Inspect timing paths')
        if has_paths:
            terminal.capture('ui-reopened-timing', ['Timing', 'paths'], absent=['No loaded index', '0 paths'], timeout=60)
        else:
            terminal.capture('ui-reopened-timing', ['timing', 'No timing paths'], timeout=60)
        proof.update(status='passed', same_store_reopened=True, public_resource_timing_reads=True,
                     production_pty_resource_timing_reopen=True, timing_goal_passed=summary['timing_goal_passed'],
                     typed_timing_paths_available=has_paths, timing_index_diagnostics=timing_diagnostics,
                     resource_ui_cached_unverified='CACHED UNVERIFIED' in resource_screen)
    except BaseException as error:
        proof.update(status='viewer_read_failed', error=type(error).__name__ + ': ' + str(error))
        raise
    finally:
        if terminal is not None:
            terminal.close()
        if daemon is not None and daemon.poll() is None:
            daemon.terminate()
            daemon.wait(timeout=10)
        proof['daemon_reaped'] = daemon is None or daemon.poll() is not None
        save(output / 'receipt.json', proof)
        print(json.dumps(proof, indent=2), flush=True)


if __name__ == '__main__':
    main()
