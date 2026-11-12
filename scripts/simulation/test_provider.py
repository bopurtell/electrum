"""Pure FS2/oracle tests with explicit synthetic tool responses. Never builds/runs HDL.

These unit fixtures are not an install qualification and are never published.
"""
import contextlib
import io
import json
import re
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest.mock import MagicMock, patch

import pt3b_provider as provider
from fs2_wire import parse, record, sexp

ROOT = Path(__file__).resolve().parents[2]
VCD = '$timescale 1ps $end\n$scope module bench $end\n$var wire 1 ! serial $end\n$upscope $end\n$enddefinitions $end\n#0\n0!\n#10\n1!\n'


class Fixture:
    def __init__(self, root):
        self.root = root
        self.generation = root / 'generation'
        self.generation.mkdir()
        for name in ('p3_loader_tb.v', 'serial_trace.v', 'iverilog', 'vvp', 'model0.v', 'model1.v'):
            (self.generation / name).write_text('pure fixture ' + name)
        shutil.copyfile(ROOT / 'asic/verif/functional/check_functional.py', self.generation / 'pt3b_oracle.py')
        self.oracle = provider.oracle_module(self.generation)
        self.install = dict(contract='protemu.fs2-pt3b-install', schema_version=1,
            generation=str(self.generation), project_root=str(root), checks_passed=True,
            fixed_variant_identity='a' * 64, source_sha256={}, tools={},
            bundles={}, models=['model0.v', 'model1.v'])
        for name in ('iverilog', 'vvp'):
            path = self.generation / name
            self.install['tools'][name] = dict(path=str(path), sha256=provider.sha(path))
        for selection in ('flops', 'exact'):
            bundle = self.generation / selection
            bundle.mkdir()
            for name in ('sim.v', 'rtl.v'):
                (bundle / name).write_text('unit fixture source')
            manifest = dict(identity=('b' if selection == 'flops' else 'c') * 64,
                hardware_variant=dict(identity='a' * 64), simulation_sources=['sim.v'],
                synthesis_sources=['rtl.v'])
            (bundle / 'manifest.json').write_text(json.dumps(manifest))
            self.install['bundles'][selection] = dict(identity=manifest['identity'],
                directory=selection, manifest=selection + '/manifest.json')
        self.install['files'] = {str(p.relative_to(self.generation)): provider.sha(p)
                                 for p in self.generation.rglob('*') if p.is_file()}
        proof = self.generation / 'qualification.json'
        proof.write_text(json.dumps(dict(status='passed',
            suites={suite: list(cases) for suite, cases in provider.SUITES.items()}, sha256={})))
        self.install['qualification_sha256'] = provider.sha(proof)
        self.manifest = self.generation / 'manifest.json'
        self.save()
        self.calls = []
        self.mode = 'passed'

    def save(self):
        self.manifest.write_text(json.dumps(self.install))

    def command(self, argv, cwd, name, timeout):
        self.calls.append((list(map(str, argv)), cwd, timeout))
        exit_code, output = 0, ''
        if name == 'compile':
            self.exact = '-DPT3B_EXACT' in argv
            if self.mode == 'compile-error':
                exit_code, output = 1, 'syntax error in unit tool fixture'
        else:
            (cwd / 'waveform.vcd').write_text(VCD)
            fatal = f'FATAL: {self.generation}/p3_loader_tb.v:442: checked mismatch\n'
            if '+PT3B_EXPECT_MISMATCH' in argv:
                exit_code, output = 1, 'PT3B EXPECTED_MISMATCH\n' + fatal
                if self.mode == 'selfcheck-error':
                    exit_code, output = 0, 'wrong synthetic checker response'
            elif self.mode == 'design-failure':
                exit_code, output = 1, fatal
            elif self.mode == 'tool-error':
                exit_code, output = 1, 'vvp: plugin missing'
            elif self.mode == 'malformed-transcript':
                output = 'exited without a PT3B result'
            else:
                scenarios = self.oracle.LOADER_SCENARIOS + (self.oracle.PENDING_SCENARIOS if self.exact else [])
                output = ''.join('PT3B OBS ' + s + '\n' for s in scenarios)
                output += 'PT3B COUNTERS refusals=6 cancellations=' + ('4 reads=1 writes=1' if self.exact else '0 reads=0 writes=0') + '\n'
                output += f'PT3B PASS loader observations={len(scenarios)}\n'
        (cwd / (name + '.stdout')).write_text(output)
        (cwd / (name + '.stderr')).write_text('')
        return dict(argv=list(map(str, argv)), cwd=str(cwd), exit_code=exit_code,
                    stdout=name + '.stdout', stderr=name + '.stderr'), output

    def runner(self, install, case, attempt, directory):
        return provider.run_case(install, case, attempt, directory, run_command=self.command)

    def request(self, cases, **overrides):
        selection = dict(suite=provider.SUITE, cases=cases, seed='0', parameters=[], asic_inputs=[])
        selection.update(overrides)
        return [('protocol_version', 1), ('attempt_id', 'unit-attempt'),
                ('selection', list(selection.items()))]

    def run(self, cases):
        request = self.root / 'request.sexp'
        request.write_text(sexp(self.request(cases)))
        events = self.root / 'events.sexp'
        events.touch()
        artifacts = self.root / 'artifacts'
        artifacts.mkdir()
        code = provider.run_request(self.manifest, request, events, artifacts, runner=self.runner)
        parsed = [record(parse(line), ('protocol_version', 'attempt_id', 'sequence', 'payload'))
                  for line in events.read_text().splitlines()]
        return code, parsed, artifacts


class Protocol(unittest.TestCase):
    def test_output_limit_is_checked_even_when_tool_exits_before_first_poll(self):
        with tempfile.TemporaryDirectory() as tmp:
            directory = Path(tmp)
            with (directory / 'waveform.vcd').open('wb') as stream:
                stream.truncate(provider.FILE_LIMIT + 1)
            process = MagicMock()
            process.poll.return_value = 0
            process.returncode = 0
            with patch.object(provider.subprocess, 'Popen', return_value=process):
                with self.assertRaisesRegex(provider.InfrastructureError, 'byte bound'):
                    provider.command(['never-executed-unit-tool'], directory, 'unit', timeout=1)
            process.wait.assert_called_once()

    def test_cancelled_command_kills_and_reaps_owned_group_without_spawning_a_tool(self):
        with tempfile.TemporaryDirectory() as tmp:
            process = MagicMock(pid=12345)
            process.poll.return_value = None
            with patch.object(provider.subprocess, 'Popen', return_value=process), \
                 patch.object(provider.time, 'sleep', side_effect=provider.Cancelled()), \
                 patch.object(provider.os, 'killpg') as kill:
                with self.assertRaises(provider.Cancelled):
                    provider.command(['never-executed-unit-tool'], Path(tmp), 'unit', timeout=1)
            kill.assert_called_once_with(12345, provider.signal.SIGTERM)
            self.assertEqual(process.wait.call_count, 2)

    def test_real_catalog_exposes_only_fixed_serial_replay_matrix(self):
        discovery = record(parse(sexp(provider.catalog())), ('protocol_version', 'suites'))
        self.assertEqual(discovery['protocol_version'], '1')
        suite = record(discovery['suites'][0], ('id', 'label', 'cases', 'parameters', 'default_seed'))
        self.assertEqual(suite['id'], provider.SUITE)
        self.assertEqual(suite['parameters'], [])
        self.assertEqual(len(suite['cases']), 4)

    def test_case_selection_rejects_shape_seed_and_asic_memory_inputs(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Fixture(Path(tmp))
            for overrides in (dict(seed='1'), dict(parameters=[['depth', '512']]),
                              dict(asic_inputs=['unsupported-memory-protocol'])):
                with self.assertRaises(provider.InfrastructureError):
                    provider.validate_request(parse(sexp(f.request(['exact-implementation'], **overrides))))
            with self.assertRaises(provider.InfrastructureError):
                provider.validate_request(parse(sexp(f.request(['exact-implementation'] * 2))))

    def test_one_case_does_not_execute_matrix_and_uses_correct_source_models(self):
        for case in provider.CASES:
            with self.subTest(case=case), tempfile.TemporaryDirectory() as tmp:
                f = Fixture(Path(tmp))
                code, events, artifacts = f.run([case])
                self.assertEqual(code, 0)
                self.assertEqual(events[-1]['payload'], ['Finished', 'Passed'])
                self.assertEqual(len(f.calls), 3, 'one compile, positive replay, negative selfcheck only')
                self.assertEqual([e['sequence'] for e in events], list(map(str, range(len(events)))))
                compile_args = f.calls[0][0]
                exact = case == 'exact-implementation'
                self.assertEqual('-DFUNCTIONAL' in compile_args, exact)
                self.assertEqual('-DPT3B_EXACT' in compile_args, exact)
                self.assertEqual(str(f.generation / 'model0.v') in compile_args, exact)
                result = json.loads((artifacts / case / 'result.json').read_text())
                self.assertEqual(result['attempt_id'], 'unit-attempt')
                self.assertEqual(result['waveform']['sha256'], provider.sha(artifacts / case / 'positive/waveform.vcd'))
                self.assertNotEqual(f.calls[1][1], f.calls[2][1], 'selfcheck cannot overwrite the positive VCD')
                announced = [e['payload'][1] for e in events if isinstance(e['payload'], list) and e['payload'][0] == 'Artifact']
                self.assertTrue(all(re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]{0,127}', dict(a)['id']) for a in announced))
                self.assertEqual(len({dict(a)['id'] for a in announced}), len(announced))
                waves = [dict(a) for a in announced if dict(a)['kind'] == 'waveform']
                self.assertEqual([w['path'] for w in waves], [case + '/positive/waveform.vcd', case + '/positive/waveform-full.vcd'])

    def test_design_failure_is_semantic_failed_with_zero_provider_exit(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Fixture(Path(tmp))
            f.mode = 'design-failure'
            code, events, artifacts = f.run(['exact-implementation'])
            self.assertEqual(code, 0)
            self.assertEqual(events[-1]['payload'], ['Finished', 'Failed'])
            self.assertEqual(json.loads((artifacts / 'exact-implementation/result.json').read_text())['status'], 'design_failed')

    def test_viewer_prefix_retains_full_actual_bytes_and_never_invents_values(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            original = VCD.encode()
            (root / 'waveform.vcd').write_bytes(original)
            preview, full = provider.serial_waveforms(root, window_ps=5)
            self.assertEqual((root / 'waveform-full.vcd').read_bytes(), original)
            self.assertTrue(original.startswith((root / 'waveform.vcd').read_bytes()))
            self.assertEqual(preview['derivation']['source_sha256'], full['sha256'])
            self.assertEqual(preview['derivation']['last_timestamp_ps'], 0)
            self.assertNotIn(b'#10', (root / 'waveform.vcd').read_bytes())

    def test_tool_checker_and_transcript_errors_remain_incomplete(self):
        for mode in ('compile-error', 'tool-error', 'malformed-transcript', 'selfcheck-error'):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as tmp:
                f = Fixture(Path(tmp))
                f.mode = mode
                with contextlib.redirect_stderr(io.StringIO()):
                    code, events, artifacts = f.run(['flops-implementation'])
                self.assertEqual(code, 2)
                self.assertFalse(any(isinstance(e['payload'], list) and e['payload'][0] in
                                     ('Finished', 'Case_finished') for e in events))
                self.assertEqual(json.loads((artifacts / 'flops-implementation/result.json').read_text())['status'], 'tool_error')

    def test_unqualified_or_mutated_install_cannot_discover_or_run(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Fixture(Path(tmp))
            provider.validate_install(f.manifest)
            f.install['checks_passed'] = False
            f.save()
            with self.assertRaisesRegex(provider.InfrastructureError, 'not qualified'):
                provider.validate_install(f.manifest)
            f.install['checks_passed'] = True
            f.save()
            (f.generation / 'model0.v').write_text('changed')
            with self.assertRaisesRegex(provider.InfrastructureError, 'input changed'):
                provider.validate_install(f.manifest)

    def test_cancellation_preserves_incomplete_prefix_without_fake_failure(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Fixture(Path(tmp))
            request = f.root / 'request.sexp'
            request.write_text(sexp(f.request(['flops-implementation'])))
            events = f.root / 'events.sexp'
            events.touch()
            artifacts = f.root / 'artifacts'
            artifacts.mkdir()
            def cancelled(*args):
                raise provider.Cancelled()
            with self.assertRaises(provider.Cancelled):
                provider.run_request(f.manifest, request, events, artifacts, runner=cancelled)
            self.assertEqual([dict(parse(line))['payload'] for line in events.read_text().splitlines()],
                             ['Started', ['Case_started', 'flops-implementation']])

    def test_source_mutation_after_replay_is_tool_error_not_committed_pass(self):
        with tempfile.TemporaryDirectory() as tmp:
            f = Fixture(Path(tmp))
            original = f.runner
            def mutate(*args):
                result = original(*args)
                (f.generation / 'serial_trace.v').write_text('changed after simulated replay')
                return result
            f.runner = mutate
            with contextlib.redirect_stderr(io.StringIO()):
                code, events, artifacts = f.run(['flops-implementation'])
            self.assertEqual(code, 2)
            self.assertFalse(any(isinstance(e['payload'], list) and e['payload'][0] == 'Finished' for e in events))
            result = json.loads((artifacts / 'flops-implementation/result.json').read_text())
            self.assertEqual((result['status'], result['source_fence']), ('tool_error', 'failed'))

    def test_codec_preserves_unicode_and_rejects_duplicate_fields_and_trailing_data(self):
        value = [['label', 'serial λ'], ['message', 'quoted " and newline\n']]
        self.assertEqual(parse(sexp(value)), value)
        with self.assertRaises(ValueError):
            record(parse('((seed 0)(seed 1))'), ('seed',))
        with self.assertRaises(ValueError):
            parse('() ()')


if __name__ == '__main__':
    unittest.main()
