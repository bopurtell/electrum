import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('install_tools', Path(__file__).with_name('install-tools.py'))
tools = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tools)


class Receipt(unittest.TestCase):
    def test_dynamic_import_does_not_require_scripts_on_sys_path(self):
        script = Path(tools.__file__).resolve()
        result = subprocess.run([sys.executable, '-I', '-B', '-c',
            'import importlib.util,sys; '
            'spec=importlib.util.spec_from_file_location("external_tools",sys.argv[1]); '
            'module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module); '
            'assert module.parse_args(["--activation"]).activation', str(script)],
            capture_output=True, timeout=5)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, b'')

    def test_minimal_sandbox_supports_helper_and_source_policy(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            scripts = root / 'scripts'
            scripts.mkdir()
            for name in ('install-tools.py', 'install_progress.py'):
                (scripts / name).write_bytes(Path(tools.__file__).with_name(name).read_bytes())
            (root / 'tools-source.lock.json').write_bytes(tools.SOURCE_LOCK.read_bytes())
            result = subprocess.run([sys.executable, '-I', '-B', '-c',
                'import importlib.util,sys; '
                'spec=importlib.util.spec_from_file_location("sandbox_tools",sys.argv[1]); '
                'module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module); '
                'assert module.parse_args([]).asic_revision == module.source_policy()["asic"]["pinned_revision"]',
                str(scripts / 'install-tools.py')], cwd=root, capture_output=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, b'')

    def test_pinned_default_and_explicit_development_modes_are_distinct(self):
        args = tools.parse_args([])
        self.assertEqual(args.asic_source_mode, 'committed')
        self.assertEqual(args.asic_revision, tools.source_policy()['asic']['pinned_revision'])
        policy = tools.source_policy()
        policy['asic']['pinned_revision'] = 'a' * 40
        with patch.object(tools, 'source_policy', return_value=policy):
            self.assertEqual(tools.parse_args([]).asic_revision, 'a' * 40)
        for option in (['--development'], ['--asic-source-mode', 'working-tree']):
            args = tools.parse_args(option)
            self.assertEqual(args.asic_source_mode, 'working-tree')
            self.assertIsNone(args.asic_revision)
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            tools.parse_args(['--development', '--asic-revision', 'a' * 40])
        # Activation trusts the selected receipt, not a new checkout's default pin.
        with patch.object(tools, 'source_policy', side_effect=AssertionError('not an activation selector')):
            self.assertTrue(tools.parse_args(['--activation']).activation)

    def test_development_capture_records_actual_dirty_bytes_not_a_clean_revision_stamp(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            generation, source = root / 'generation', root / 'source-owner'
            generation.mkdir()
            source.mkdir()
            entries = {'lib/api.ml': ('file', b'working tree fix\n'),
                       'flow/physical_runtime.py': ('executable', b'updated helper digest\n')}
            def git(owner, *args):
                if args == ('rev-parse', 'HEAD'):
                    return b'3335f47cf8ac0ae065aa161705e57305389ef396\n'
                if args == ('status', '--porcelain', '--untracked-files=all'):
                    return b' M lib/api.ml\n M flow/physical_runtime.py\n'
                if args == ('rev-parse', '--absolute-git-dir'):
                    return b'/read-only/owner-metadata\n'
                self.fail('unexpected Git call: ' + repr(args))
            receipt = dict(sources={})
            args = SimpleNamespace(asic_source_mode='working-tree', asic_revision=None)
            with patch.object(tools, 'capture', return_value=entries) as capture, patch.object(tools, 'git', side_effect=git):
                tools.capture_source('asic', source, generation / 'captured', generation, receipt, args)
            record = receipt['sources']['asic']
            self.assertTrue(record['dirty'])
            self.assertEqual(record['mode'], 'working-tree')
            self.assertFalse(record['source_artifact_revision_stamped'])
            self.assertEqual(record['revision'], record['base_revision'])
            self.assertEqual(record['files']['lib/api.ml']['sha256'], tools.digest(entries['lib/api.ml'][1]))
            self.assertEqual((generation / 'captured/lib/api.ml').read_bytes(), entries['lib/api.ml'][1])
            self.assertEqual(capture.call_count, 2, 'mutable owner must be fenced before capture publication')
            saved = json.loads((generation / 'capture.json').read_text())
            self.assertEqual(saved['sources']['asic']['tree_sha256'], record['tree_sha256'])

    def test_source_edit_during_development_capture_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            entries = {'api.ml': ('file', b'before')}
            with patch.object(tools, 'capture', side_effect=[entries, {'api.ml': ('file', b'after')}]), \
                 patch.object(tools, 'source_record', return_value=dict(revision='a' * 40, dirty=True, status=' M api.ml')):
                with self.assertRaisesRegex(ValueError, 'changed during capture'):
                    tools.capture_source('asic', root, root / 'captured', root, dict(sources={}),
                        SimpleNamespace(asic_source_mode='working-tree', asic_revision=None))
            self.assertFalse((root / 'captured').exists())

    def test_committed_capture_remains_explicit_and_excludes_working_fixes(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / 'owner'
            source.mkdir()
            generation = root / 'generation'
            generation.mkdir()
            pinned = tools.source_policy()['asic']['pinned_revision']
            receipt = dict(sources={})
            entries = {'api.ml': ('file', b'committed source only')}
            with patch.object(tools, 'committed', return_value=(pinned, entries)) as committed, \
                 patch.object(tools, 'capture') as working, \
                 patch.object(tools, 'source_record', return_value=dict(revision='b' * 40, dirty=True, status=' M api.ml')), \
                 patch.object(tools, 'git', return_value=b'/read-only/gitdir\n'):
                tools.capture_source('asic', source, generation / 'captured', generation, receipt,
                    SimpleNamespace(asic_source_mode='committed', asic_revision=pinned))
            committed.assert_called_once_with(source, pinned)
            working.assert_not_called()
            self.assertFalse(receipt['sources']['asic']['dirty'])
            self.assertEqual(receipt['sources']['asic']['revision'], pinned)
            self.assertEqual((generation / 'captured/api.ml').read_bytes(), entries['api.ml'][1])

    def test_archived_source_policy_is_checked_without_rewriting_history(self):
        with tempfile.TemporaryDirectory() as tmp:
            generation = Path(tmp)
            data = tools.SOURCE_LOCK.read_bytes()
            policy = dict(captured_lock='tools-source.lock.json', lock_sha256=tools.digest(data), policy=json.loads(data))
            (generation / 'tools-source.lock.json').write_bytes(data)
            tools.verify_captured_policy(generation, {'source_policy': policy})
            (generation / 'tools-source.lock.json').write_bytes(data + b'unknown edit')
            with self.assertRaisesRegex(ValueError, 'source policy changed'):
                tools.verify_captured_policy(generation, {'source_policy': policy})

    def test_inventory_fences_activation_and_deduplicates_path(self):
        with tempfile.TemporaryDirectory() as tmp:
            store = Path(tmp) / 'tools'
            gen = store / 'generations' / ('a' * 32)
            prefix = gen / 'prefix'
            (prefix / 'bin').mkdir(parents=True)
            app = prefix / 'bin/hardcaml-asic-flow'
            app.write_bytes(b'checked binary')
            receipt = dict(checks_passed=True, prefix=str(prefix), switch_prefix='/switch',
                           installed_sha256=tools.inventory(prefix))
            (gen / 'receipt.json').write_text(json.dumps(receipt))
            (store / 'current.json').write_text(json.dumps(dict(generation=str(gen), prefix=str(prefix),
                receipt=str(gen / 'receipt.json'))))
            with patch.object(tools, 'STORE', store), patch.dict(os.environ, PATH=f'{prefix}/bin:/usr/bin'):
                output = io.StringIO()
                with contextlib.redirect_stdout(output):
                    tools.activation()
                self.assertEqual(output.getvalue().split('export PATH=')[1].count(str(prefix / 'bin')), 1)
                app.write_bytes(b'changed binary')
                with self.assertRaisesRegex(ValueError, 'inventory changed'):
                    tools.activation()

    def test_source_links_cannot_escape_capture(self):
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, 'escapes capture'):
                tools.materialize(Path(tmp) / 'source', {'link': ('link', b'../outside')})

    def test_interrupted_materialization_does_not_publish_partial_capture(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            captured = root / 'source/asic'
            entries = {'api.ml': ('file', b'complete bytes')}
            receipt = dict(sources={})
            record = dict(revision='a' * 40, files={'api.ml': dict(kind='file',
                          sha256=tools.digest(b'complete bytes'))})
            args = SimpleNamespace(asic_source_mode='working-tree')
            materialize = tools.materialize

            def interrupted(destination, entries):
                destination.mkdir(parents=True)
                (destination / 'api.ml').write_bytes(b'partial')
                raise KeyboardInterrupt()

            with patch.object(tools, 'capture', return_value=entries), \
                 patch.object(tools, 'source_record', return_value=record), \
                 patch.object(tools, 'git', return_value=b'/gitdir\n'), \
                 patch.object(tools, 'materialize', side_effect=interrupted) as publish:
                with self.assertRaises(KeyboardInterrupt):
                    tools.capture_source('asic', root, captured, root, receipt, args)
                self.assertFalse(captured.exists())
                self.assertFalse((root / 'capture.json').exists())
                publish.side_effect = materialize
                tools.capture_source('asic', root, captured, root, receipt, args)
            self.assertEqual((captured / 'api.ml').read_bytes(), b'complete bytes')
            tools.verify_capture(captured, receipt['sources']['asic'])


class InstallStages(unittest.TestCase):
    """Exercise real orchestration/receipts, replacing all external commands."""
    def setUp(self):
        self.stack = contextlib.ExitStack()
        self.addCleanup(self.stack.close)
        self.root = Path(self.stack.enter_context(tempfile.TemporaryDirectory()))
        self.store = self.root / 'tools'
        self.switch = self.root / 'switch'
        self.switch.mkdir()
        self.asic, self.workbench = self.root / 'asic', self.root / 'workbench'
        self.asic.mkdir()
        self.workbench.mkdir()
        self.stack.enter_context(patch.object(tools, 'STORE', self.store))
        self.stack.enter_context(patch.object(tools.subprocess, 'check_output', return_value=str(self.switch)))
        self.capture = self.stack.enter_context(patch.object(tools, 'capture_source', side_effect=self.fake_capture))
        self.command = self.stack.enter_context(patch.object(tools, 'run_logged', side_effect=self.fake_command))
        self.stdout, self.stderr = io.StringIO(), io.StringIO()
        self.stack.enter_context(contextlib.redirect_stdout(self.stdout))
        self.stack.enter_context(contextlib.redirect_stderr(self.stderr))
        self.upstream = False
        self.fail_command = None
        self.commands = []

    def args(self, *extra):
        return tools.parse_args(['--asic-source', str(self.asic), '--workbench-source',
                                 str(self.workbench), *extra])

    def fake_capture(self, name, source, captured, generation, receipt, args):
        entries = {'api.ml': ('file', b'captured bytes')}
        if name == 'asic' and self.upstream:
            entries['scripts/install.py'] = ('file', b'# fake upstream installer')
        tools.materialize(captured, entries)
        receipt['sources'][name] = dict(path=str(source), files={
            p: dict(kind=kind, sha256=tools.digest(data)) for p, (kind, data) in entries.items()})
        tools.save_capture(generation, receipt)

    def fake_command(self, argv, cwd, env, log):
        argv = list(map(str, argv))
        self.commands.append((argv, cwd, env, log))
        tools.report('LIVE fake subprocess output')
        if self.fail_command and self.fail_command(argv, cwd):
            raise subprocess.CalledProcessError(9, argv)
        # Model installed artifacts; inventory/publication remain real.
        if 'install' in argv or (len(argv) > 2 and argv[2].endswith('scripts/install.py')):
            prefix = Path(argv[argv.index('--prefix') + 1])
            (prefix / 'bin').mkdir(parents=True, exist_ok=True)
            (prefix / 'bin' / cwd.name).write_bytes(b'checked binary')

    def generation(self):
        return sorted((self.store / 'generations').iterdir())[-1]

    def test_old_pin_fallback_stages_verbose_and_machine_stdout(self):
        tools.install(self.args('--verbose'))
        self.assertEqual(len(self.commands), 6)
        for argv, cwd, env, log in self.commands:
            self.assertEqual(argv[2:4], ['--root', str(cwd)])
            self.assertEqual(env['PYTHONDONTWRITEBYTECODE'], '1')
            self.assertEqual(log.name, 'build.log')
            if argv[1] in ('build', 'runtest'):
                self.assertIn('verbose', argv)
            if argv[1] == 'runtest':
                self.assertIn('--no-buffer', argv)
        asic_test, workbench_test = self.commands[1][0], self.commands[4][0]
        self.assertIn('-j1', asic_test)
        self.assertEqual(workbench_test[-2:], ['-j2', 'backend/test/asic'])
        selection = json.loads(self.stdout.getvalue())
        self.assertEqual(selection, json.loads((self.store / 'current.json').read_text()))
        for label in ('asic: capture/verify sources', 'asic: build', 'asic: test', 'asic: install',
                      'workbench: capture/verify sources', 'workbench: build', 'workbench: test',
                      'workbench: install', 'Inventory installed files'):
            self.assertIn('[START] ' + label, self.stderr.getvalue())
            self.assertIn('[DONE] ' + label, self.stderr.getvalue())
        self.assertIn('LIVE fake subprocess output', self.stderr.getvalue())
        tools.verify_selection()

    def test_optional_captured_asic_installer_receives_explicit_options(self):
        self.upstream = True
        tools.install(self.args('--verbose'))
        self.assertEqual(len(self.commands), 4)
        argv, cwd, env, log = self.commands[0]
        self.assertEqual(argv[:3], [sys.executable, '-B', str(cwd / 'scripts/install.py')])
        self.assertEqual(argv[argv.index('--dune') + 1], str(self.switch / 'bin/dune'))
        self.assertIn('--verbose', argv)
        self.assertIn('[DONE] ASIC: upstream installer', self.stderr.getvalue())
        tools.verify_selection()

    def test_upstream_failure_does_not_publish_or_start_workbench(self):
        self.upstream = True
        self.fail_command = lambda argv, cwd: True
        with self.assertRaises(subprocess.CalledProcessError):
            tools.install(self.args())
        self.assertEqual(len(self.commands), 1)
        self.assertNotIn('--verbose', self.commands[0][0])
        self.assertIn('[FAILED] ASIC: upstream installer', self.stderr.getvalue())
        self.assertEqual(self.stdout.getvalue(), '')
        self.assertFalse((self.store / 'current.json').exists())
        self.assertFalse((self.generation() / 'receipt.json').exists())

    def test_failed_test_keeps_selection_and_resumes_verified_capture(self):
        tools.install(self.args())
        selected = (self.store / 'current.json').read_bytes()
        self.stdout.seek(0)
        self.stdout.truncate()
        self.stderr.seek(0)
        self.stderr.truncate()
        self.fail_command = lambda argv, cwd: argv[1] == 'runtest' and cwd.name == 'workbench'
        with self.assertRaises(subprocess.CalledProcessError):
            tools.install(self.args())
        self.assertEqual((self.store / 'current.json').read_bytes(), selected)
        self.assertEqual(self.stdout.getvalue(), '')
        self.assertIn('[FAILED] workbench: test', self.stderr.getvalue())
        self.assertNotIn('[DONE] workbench: test', self.stderr.getvalue())
        unfinished = [g for g in (self.store / 'generations').iterdir() if not (g / 'receipt.json').exists()]
        self.assertEqual(len(unfinished), 1)
        generation = unfinished[0]
        self.fail_command = None
        self.capture.reset_mock()
        tools.install(self.args('--resume', generation.name))
        self.capture.assert_not_called()
        self.assertEqual(json.loads(self.stdout.getvalue())['generation'], str(generation))
        tools.verify_selection()

    def test_capture_failure_can_resume_before_first_capture_is_published(self):
        self.capture.side_effect = ValueError('capture failed')
        with self.assertRaisesRegex(ValueError, 'capture failed'):
            tools.install(self.args())
        generation = self.generation()
        self.assertEqual(json.loads((generation / 'capture.json').read_text())['sources'], {})
        self.assertFalse((self.store / 'current.json').exists())
        self.capture.side_effect = self.fake_capture
        tools.install(self.args('--resume', generation.name))
        tools.verify_selection()

    def test_changed_capture_rejects_resume_before_commands(self):
        self.fail_command = lambda argv, cwd: True
        with self.assertRaises(subprocess.CalledProcessError):
            tools.install(self.args())
        generation = self.generation()
        (generation / 'source/asic/api.ml').write_bytes(b'changed bytes')
        self.commands.clear()
        with self.assertRaisesRegex(ValueError, 'captured source changed'):
            tools.install(self.args('--resume', generation.name))
        self.assertEqual(self.commands, [])
        self.assertFalse((generation / 'receipt.json').exists())

    def test_pending_capture_after_inventory_publication_is_recovered_on_resume(self):
        self.fail_command = lambda argv, cwd: True
        with self.assertRaises(subprocess.CalledProcessError):
            tools.install(self.args())
        generation = self.generation()
        captured = generation / 'source/asic'
        captured.rename(captured.with_name('asic.pending'))
        self.fail_command = None
        self.capture.reset_mock()
        tools.install(self.args('--resume', generation.name))
        # ASIC came from its verified pending snapshot, Workbench was not yet captured.
        self.assertEqual([call.args[0] for call in self.capture.call_args_list], ['workbench'])
        self.assertTrue(captured.is_dir())
        tools.verify_selection()

    def test_changed_capture_file_kind_rejects_resume(self):
        self.fail_command = lambda argv, cwd: True
        with self.assertRaises(subprocess.CalledProcessError):
            tools.install(self.args())
        generation = self.generation()
        (generation / 'source/asic/api.ml').chmod(0o755)
        self.commands.clear()
        with self.assertRaisesRegex(ValueError, 'captured source changed'):
            tools.install(self.args('--resume', generation.name))
        self.assertEqual(self.commands, [])

    def test_completed_generation_cannot_resume(self):
        tools.install(self.args())
        self.commands.clear()
        with self.assertRaisesRegex(ValueError, 'completed generations'):
            tools.install(self.args('--resume', self.generation().name))
        self.assertEqual(self.commands, [])

    def test_failed_selection_publication_leaves_generation_resumable(self):
        replace = os.replace

        def fail_selection(source, destination):
            if Path(destination) == self.store / 'current.json':
                raise OSError('selection publication failed')
            return replace(source, destination)

        with patch.object(tools.os, 'replace', side_effect=fail_selection):
            with self.assertRaisesRegex(OSError, 'selection publication failed'):
                tools.install(self.args())
        generation = self.generation()
        self.assertFalse((generation / 'receipt.json').exists())
        self.assertFalse((self.store / 'current.json').exists())
        self.assertEqual(self.stdout.getvalue(), '')
        self.assertIn('[FAILED] Inventory installed files', self.stderr.getvalue())
        tools.install(self.args('--resume', generation.name))
        tools.verify_selection()


if __name__ == '__main__':
    unittest.main()
