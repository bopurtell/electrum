import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('install_tools', Path(__file__).with_name('install-tools.py'))
tools = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tools)


class Receipt(unittest.TestCase):
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


if __name__ == '__main__':
    unittest.main()
