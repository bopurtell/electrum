"""Pure adapter/state-machine tests. Producer and readers below are unit doubles.

No HDL, native emitter, build, install or real qualification is run here.
"""
import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import event_adapter as adapter
import pt3b_provider as provider
from fs2_wire import parse, record, sexp
from test_provider import Fixture, VCD


class EventFixture(Fixture):
    def __init__(self, root):
        super().__init__(root)
        for name in ('producer.py', 'bench.v', 'emitter', 'reference'):
            (self.generation / name).write_text('explicit unit fixture ' + name)
        self.install['event'] = dict(source_directory='source', producer='producer.py', bench='bench.v',
            emitter='emitter', reference='reference', pdk_directory='models', results_root=str(root / 'retained'))
        for name in ('producer.py', 'bench.v', 'emitter', 'reference'):
            self.install['files'][name] = provider.sha(self.generation / name)
        self.save()
        self.inspections, self.comparisons = [], []

    def inspect(self, path):
        self.inspections.append(path)
        raw = json.loads(Path(path).read_text())
        return dict(source_digest=provider.sha(path), result=raw,
                    measurements={'fixture': 'measurements'} if raw['status'] == 'completed' else None)

    def compare(self, left, right):
        self.comparisons.append((left, right))
        return dict(schema='protemu.event-response-comparison', version=1,
                    left_digest=provider.sha(left), right_digest=provider.sha(right),
                    status='comparable', physical_area_speed_delta=None)

    def event_command(self, argv, cwd, name, timeout, watch_tree):
        self.calls.append((list(map(str, argv)), cwd, timeout))
        if self.mode == 'missing-emitter':
            raise FileNotFoundError('unit prebuilt emitter missing')
        output = Path(argv[argv.index('--output') + 1])
        self.assert_new = not output.exists()
        output.mkdir()
        raw = dict(schema='protemu.event-response-result', version=1, status='completed',
            selection=argv[argv.index('--selection') + 1], source_role=argv[argv.index('--mode') + 1],
            asic_workload_result=False, hardware_assignment={'explicit_unit_fixture': True}, tools={})
        for tool in ('emitter', 'reference'):
            raw['tools'][tool] = dict(sha256=provider.sha(self.generation / tool))
        for tool in ('iverilog', 'vvp'):
            raw['tools'][tool] = self.install['tools'][tool]
        for name in ('capture.json', 'reference.json', 'workload.json'):
            (output / name).write_text('{}')
        (output / 'commands.json').write_text('[]')
        for phase in range(10):
            directory = output / ('phase-' + str(phase))
            directory.mkdir()
            (directory / 'waveform.vcd').write_text(VCD)
            (directory / 'raw.trace').write_text('explicit unit fixture trace')
        code = 0
        if self.mode in ('design-failure', 'tool-error'):
            raw['status'] = 'failed'
            code = 1
            text = ('FATAL: ' + str(output / 'sources/asic/verif/workloads/event_response_tb.v') + ':55: assertion\n'
                    if self.mode == 'design-failure' else 'missing simulator plugin')
            (output / 'command-000.stdout').write_text(text)
            (output / 'command-000.stderr').write_text('')
            (output / 'commands.json').write_text(json.dumps([dict(exit_code=1)]))
        (output / 'result.json').write_text(json.dumps(raw))
        (cwd / 'producer.stdout').write_text('unit producer output')
        (cwd / 'producer.stderr').write_text('')
        return dict(argv=list(map(str, argv)), cwd=str(cwd), exit_code=code), 'unit producer output'

    def runner(self, install, case, attempt, directory):
        return adapter.run_case(install, case, attempt, directory,
                                run_command=self.event_command, evidence_readers=self)

    def event_run(self, cases):
        request = self.root / 'request.sexp'
        request.write_text(sexp(self.request(cases, suite=provider.EVENT_SUITE)))
        events = self.root / 'events.sexp'
        events.touch()
        artifacts = self.root / 'artifacts'
        artifacts.mkdir()
        with patch.object(provider, 'event_adapter', return_value=adapter), patch.object(adapter, 'readers', return_value=self):
            code = provider.run_request(self.manifest, request, events, artifacts, runner=self.runner)
        parsed = [record(parse(line), ('protocol_version', 'attempt_id', 'sequence', 'payload'))
                  for line in events.read_text().splitlines()]
        return code, parsed, artifacts


class EventIntegration(unittest.TestCase):
    def test_catalog_preserves_four_serial_and_adds_three_fixed_event_cases(self):
        discovery = dict(parse(sexp(provider.catalog())))
        suites = {dict(s)['id']: dict(s) for s in discovery['suites']}
        self.assertEqual(len(suites[provider.SUITE]['cases']), 4)
        self.assertEqual([dict(c)['id'] for c in suites[provider.EVENT_SUITE]['cases']], ['behavioral', 'flops', 'exact'])
        self.assertEqual(suites[provider.EVENT_SUITE]['parameters'], [])

    def test_each_case_binds_actual_selection_role_ten_named_phases_and_fresh_attempt(self):
        for case, (selection, role) in provider.EVENT_CASES.items():
            with self.subTest(case=case), tempfile.TemporaryDirectory() as tmp:
                f = EventFixture(Path(tmp))
                code, events, artifacts = f.event_run([case])
                self.assertEqual(code, 0)
                self.assertEqual(events[-1]['payload'], ['Finished', 'Passed'])
                self.assertEqual(len(f.calls), 1)
                argv = f.calls[0][0]
                self.assertEqual(argv[argv.index('--selection') + 1], selection)
                self.assertEqual(argv[argv.index('--mode') + 1], role)
                self.assertNotIn('dune', argv)
                self.assertTrue(f.assert_new)
                result = json.loads((artifacts / case / 'result.json').read_text())
                self.assertEqual((result['attempt_id'], result['case_id'], result['source_fence']),
                                 ('unit-attempt', case, 'verified'))
                self.assertFalse(result['asic_workload_result'])
                self.assertNotIn('bundle_identity', result)
                self.assertNotIn('hardware_variant', result)
                self.assertTrue(Path(result['retained_result']).is_file())
                wave_events = [dict(e['payload'][1]) for e in events if isinstance(e['payload'], list) and
                               e['payload'][0] == 'Artifact' and dict(e['payload'][1])['kind'] == 'waveform']
                self.assertEqual({w['path'] for w in wave_events},
                    {case + '/evidence/phase-' + str(p) + '/waveform.vcd' for p in range(10)})
                self.assertFalse(f.comparisons)

    def test_only_same_attempt_selected_implementations_get_generic_verified_comparison(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = EventFixture(Path(tmp))
            code, events, artifacts = f.event_run(['behavioral', 'flops', 'exact'])
            self.assertEqual(code, 0)
            self.assertEqual(len(f.comparisons), 1)
            value = json.loads((artifacts / 'event-comparison.json').read_text())
            self.assertEqual(value['attempt_id'], 'unit-attempt')
            self.assertFalse(value['asic_workload_result'])
            self.assertEqual(value['comparison']['physical_area_speed_delta'], None)
            exported = [dict(e['payload'][1]) for e in events if isinstance(e['payload'], list) and
                        e['payload'][0] == 'Artifact' and dict(e['payload'][1])['path'] == 'event-comparison.json']
            self.assertEqual(len(exported), 1)
            self.assertEqual(exported[0]['case_id'], [])
            self.assertEqual(exported[0]['media_type'], 'application/json')

    def test_uncompiled_producer_and_tool_failures_are_incomplete_not_passes(self):
        for mode in ('missing-emitter', 'tool-error'):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as tmp:
                f = EventFixture(Path(tmp))
                f.mode = mode
                with contextlib.redirect_stderr(io.StringIO()):
                    code, events, artifacts = f.event_run(['flops'])
                self.assertEqual(code, 2)
                self.assertFalse(any(isinstance(e['payload'], list) and e['payload'][0] == 'Finished' for e in events))
                self.assertEqual(json.loads((artifacts / 'flops/result.json').read_text())['status'], 'tool_error')

    def test_actual_bench_fatal_is_failed_with_verified_failure_artifacts(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = EventFixture(Path(tmp))
            f.mode = 'design-failure'
            code, events, artifacts = f.event_run(['exact'])
            self.assertEqual(code, 0)
            self.assertEqual(events[-1]['payload'], ['Finished', 'Failed'])
            self.assertTrue((artifacts / 'exact/evidence/failed-command.stdout').is_file())
            self.assertEqual(json.loads((artifacts / 'exact/inspection.json').read_text())['measurements'], None)

    def test_refresh_skips_current_source_drift_but_not_unknown_installed_edits(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = EventFixture(Path(tmp))
            source = f.root / 'observed.py'
            source.write_text('before')
            f.install['source_sha256']['observed.py'] = provider.sha(source)
            f.save()
            source.write_text('authored edit')
            with self.assertRaisesRegex(provider.InfrastructureError, 'stale simulation source'):
                provider.validate_install(f.manifest)
            provider.validate_install(f.manifest, check_sources=False)
            (f.generation / 'producer.py').write_text('unknown installed edit')
            with self.assertRaisesRegex(provider.InfrastructureError, 'input changed'):
                provider.validate_install(f.manifest, check_sources=False)

    def test_serial_only_qualification_cannot_advertise_event_suite(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = EventFixture(Path(tmp))
            proof = f.generation / 'qualification.json'
            proof.write_text(json.dumps(dict(status='passed', suites={provider.SUITE: list(provider.CASES)}, sha256={})))
            f.install['qualification_sha256'] = provider.sha(proof)
            f.save()
            with self.assertRaisesRegex(provider.InfrastructureError, 'complete serial and event'):
                provider.validate_install(f.manifest)

    def test_comparison_cannot_substitute_a_different_retained_result(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = EventFixture(Path(tmp))
            original = f.compare
            def rebound(left, right):
                result = original(left, right)
                result['left_digest'] = '0' * 64
                return result
            f.compare = rebound
            with self.assertRaisesRegex(provider.InfrastructureError, 'exact attempt result'):
                f.event_run(['flops', 'exact'])
            self.assertFalse((f.root / 'artifacts/event-comparison.json').exists())
            events = [dict(parse(line))['payload'] for line in (f.root / 'events.sexp').read_text().splitlines()]
            self.assertFalse(any(isinstance(e, list) and e[0] == 'Finished' for e in events))


if __name__ == '__main__':
    unittest.main()
