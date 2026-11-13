import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('workbench', Path(__file__).with_name('workbench.py'))
wb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(wb)


class Configuration(unittest.TestCase):
    def test_explicit_toolchain_metadata_selects_venv_and_survives_later_configure(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, tools = Path(tmp), Path(tmp) / 'existing-toolchain'
            for path in (root / '_build/default' / wb.TARGET, root / 'prefix/bin/hardcaml-asic-flow'):
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b'availability fixture only; never executed')
                path.chmod(0o755)
            args = type('Args', (), dict(toolchain=tools, simulation_config=None))()
            metadata = dict(root=str(tools), validation='pinned_metadata_only_no_EDA',
                            python=dict(path=str(tools / '.venv/bin/python')))
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', root / '.dev/workbench'), \
                 patch.object(wb, 'stopped'), patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb.subprocess, 'run'), patch.object(wb, 'validate_toolchain', return_value=metadata) as validate, \
                 patch.dict(wb.os.environ, ELECTRUM_TOOLS_RECEIPT=str(root / 'receipt.json')):
                wb.configure(args)
                config = (root / '.workbench/hardcaml-workbench-asic.sexp').read_text()
                self.assertIn(str(tools / '.venv/bin/python'), config)
                args.toolchain = None
                wb.configure(args)
                self.assertEqual((root / '.workbench/hardcaml-workbench-asic.sexp').read_text(), config)
                state = json.loads((root / '.dev/workbench/configuration.json').read_text())
                self.assertEqual(state['physical_toolchain'], metadata)
                status = wb.readiness(root / 'prefix', state)
                self.assertTrue(status['physical']['ready'])
                self.assertTrue(status['physical']['requires_explicit_preflight'])
                self.assertEqual(status['physical']['readiness_scope'], 'metadata_only_no_EDA')
                self.assertEqual(validate.call_count, 3)

    def test_invalid_toolchain_cannot_build_or_publish(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            args = type('Args', (), dict(toolchain=root / 'bad-tools', simulation_config=None))()
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', root / '.dev/workbench'), \
                 patch.object(wb, 'stopped'), patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb, 'validate_toolchain', side_effect=ValueError('pin mismatch')), \
                 patch.object(wb.subprocess, 'run') as run:
                with self.assertRaisesRegex(ValueError, 'pin mismatch'):
                    wb.configure(args)
                run.assert_not_called()
                self.assertFalse((root / '.workbench').exists())

    def test_source_readiness_is_independent_of_absent_physical_collateral(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, prefix = Path(tmp), Path(tmp) / 'prefix'
            for path in (root / '_build/default' / wb.TARGET, prefix / 'bin/hardcaml-asic-flow'):
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b'unit availability fixture; never executed')
                path.chmod(0o755)
            hashes = {}
            for kind in ('asic', 'preparation'):
                path = root / '.workbench' / ('hardcaml-workbench-' + kind + '.sexp')
                path.parent.mkdir(exist_ok=True)
                data = ('owned unit ' + kind).encode()
                path.write_bytes(data)
                hashes[kind] = wb.sha(data)
            with patch.object(wb, 'ROOT', root):
                status = wb.readiness(prefix, {'sha256': hashes, 'prefix': str(prefix)})
            self.assertTrue(status['ready'])
            self.assertTrue(status['source_operations']['ready'])
            self.assertFalse(status['source_operations']['requires_pdk'])
            self.assertEqual(status['preparation']['project_root'], str(root))
            self.assertEqual(status['preparation']['configuration_path'],
                str(root / '.workbench/hardcaml-workbench-preparation.sexp'))
            self.assertFalse(status['physical']['ready'])
            self.assertEqual(status['physical']['status'], 'missing_collateral')

    def test_status_requires_configure_after_selected_prefix_changes(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, prefix = Path(tmp), Path(tmp) / 'new-prefix'
            for path in (root / '_build/default' / wb.TARGET, prefix / 'bin/hardcaml-asic-flow'):
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b'unit availability fixture')
                path.chmod(0o755)
            hashes = {}
            for kind in ('asic', 'preparation'):
                path = root / '.workbench' / ('hardcaml-workbench-' + kind + '.sexp')
                path.parent.mkdir(exist_ok=True)
                path.write_text('known owned companion from prior prefix')
                hashes[kind] = wb.sha(path.read_bytes())
            config = dict(prefix=str(root / 'old-prefix'), sha256=hashes,
                          physical_toolchain={'previous': 'validated'}, simulation_configured=True)
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'validate_toolchain') as physical, \
                 patch.object(wb, 'simulation_configuration') as simulation:
                status = wb.readiness(prefix, config)
            self.assertTrue(status['configure_required'])
            self.assertEqual(status['status'], 'configure_required')
            self.assertTrue(status['source_operations']['companions_match'])
            self.assertFalse(status['source_operations']['selection_matches'])
            for component in ('source_operations', 'physical', 'simulation'):
                self.assertFalse(status[component]['ready'])
            physical.assert_not_called()
            simulation.assert_not_called()

    def test_preparation_inspection_routes_installed_cli_and_refuses_another_project(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            prefix = root / 'prefix'
            attempt = root / '_flow_results/workbench/preparation/attempt'
            attempt.mkdir(parents=True)
            other = root / 'foreign-project-attempt'
            other.mkdir()
            with patch.object(wb, 'ROOT', root), patch.object(wb.subprocess, 'run') as run:
                wb.inspect_preparation(prefix, attempt)
                self.assertEqual(run.call_args.args[0], [str(prefix / 'bin/hardcaml-asic-flow'),
                    'preparation-inspect', str(attempt), '--json'])
                with self.assertRaisesRegex(ValueError, 'this Electrum'):
                    wb.inspect_preparation(prefix, other)
                self.assertEqual(run.call_count, 1)

    def test_unqualified_simulation_cannot_publish_a_companion(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            args = type('Args', (), dict(toolchain=None, simulation_config=None, simulation=True))()
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', root / '.dev/workbench'), \
                 patch.object(wb, 'stopped'), patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb.subprocess, 'run'), \
                 patch.object(wb, 'simulation_configuration', side_effect=ValueError('not qualified')):
                with self.assertRaisesRegex(ValueError, 'not qualified'):
                    wb.configure(args)
                self.assertFalse((root / '.workbench').exists())

    def test_explicit_simulation_publication_is_preserved_on_asic_only_update(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            args = type('Args', (), dict(toolchain=None, simulation_config=None, simulation=True))()
            data = b'unit-test configuration, not an actual provider installation'
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', root / '.dev/workbench'), \
                 patch.object(wb, 'stopped'), patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb.subprocess, 'run'), patch.object(wb, 'simulation_configuration', return_value=data), \
                 patch.dict(wb.os.environ, ELECTRUM_TOOLS_RECEIPT=str(root / 'receipt.json')):
                wb.configure(args)
                args.simulation = False
                wb.configure(args)
                self.assertEqual((root / '.workbench/hardcaml-workbench-simulation.sexp').read_bytes(), data)
                state = json.loads((root / '.dev/workbench/configuration.json').read_text())
                self.assertTrue(state['simulation_configured'])
                self.assertEqual(state['sha256']['simulation'], wb.sha(data))

    def test_unknown_edit_is_preserved_and_owned_update_retained(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            store = root / '.dev/workbench'
            prefix = root / 'prefix'
            args = type('Args', (), dict(toolchain=None, simulation_config=None))()
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', store), \
                 patch.object(wb, 'stopped'), patch.object(wb, 'selected', return_value=({}, prefix)), \
                 patch.object(wb.subprocess, 'run'), \
                 patch.object(wb, 'validate_toolchain', return_value={'python': {'path': str(root / 'different-tools/.venv/bin/python')}}), \
                 patch.dict(wb.os.environ, ELECTRUM_TOOLS_RECEIPT=str(root / 'receipt.json')):
                wb.configure(args)
                path = root / '.workbench/hardcaml-workbench-asic.sexp'
                owned = path.read_bytes()
                path.write_bytes(b'unknown user edits\n')
                with self.assertRaisesRegex(ValueError, 'unknown user'):
                    wb.configure(args)
                self.assertEqual(path.read_bytes(), b'unknown user edits\n')
                path.write_bytes(owned)
                args.toolchain = root / 'different-tools'
                wb.configure(args)
                self.assertEqual(next((store / 'history').glob('asic-*')).read_bytes(), owned)
                self.assertFalse(json.loads((store / 'configuration.json').read_text())['simulation_configured'])


if __name__ == '__main__':
    unittest.main()
