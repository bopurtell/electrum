import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('workbench', Path(__file__).with_name('workbench.py'))
wb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(wb)


OWNERS = {'electrum': 'asics/electrum/cli/chip.exe'}
BUILD = ['dune', 'build', '-j10', *('./' + t for t in (wb.TARGET, *OWNERS.values()))]


def catalog_fixture(root):
    catalog = dict(schema_version=1, default_target='electrum',
                   targets=[dict(id=chip, executable=target) for chip, target in OWNERS.items()])
    (root / wb.CHIP_CATALOG).write_text(json.dumps(catalog))
    return catalog


def executable_fixtures(root, prefix):
    for path in (prefix / 'bin/hardcaml-asic-flow',
                 *(root / '_build/default' / target for target in (wb.TARGET, *OWNERS.values()))):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b'availability fixture only; never executed')
        path.chmod(0o755)


class Configuration(unittest.TestCase):
    def test_configure_refuses_to_overwrite_user_workspace(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            workspace = root / 'dune-workspace'
            workspace.write_text('(lang dune 3.22)\n')
            args = type('Args', (), dict(toolchain=None, simulation_config=None))()
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', root / '.dev/workbench'), \
                 patch.object(wb, 'stopped'), \
                 patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb, 'build') as build:
                with self.assertRaisesRegex(ValueError, 'not owned'):
                    wb.configure(args)
                build.assert_not_called()
            self.assertEqual(workspace.read_text(), '(lang dune 3.22)\n')

    def test_resource_prepare_routes_chip_and_deferred_flow_validation(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            argv = ['workbench.py', 'resource-prepare', '--chip', 'electrum', '--flow', 'trial']
            with patch.object(wb, 'ROOT', root), \
                 patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb.sys, 'argv', argv), patch.object(wb.subprocess, 'run') as run:
                wb.main()
                self.assertEqual(run.call_args.args[0][-4:], argv[-4:])
                self.assertEqual(run.call_args.args[0][:2],
                                 [str(root / '_build/default' / wb.TARGET), 'prepare'])

    def test_build_loads_current_catalog_without_touching_companions(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            catalog = catalog_fixture(root)
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', root / '.dev/workbench'), \
                 patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb.sys, 'argv', ['workbench.py', 'build']), \
                 patch.object(wb.subprocess, 'run') as run:
                wb.main()
                run.assert_called_once_with(BUILD, cwd=root, check=True)
                catalog['targets'].append(dict(id='trial', executable='asics/trial/cli/chip.exe'))
                (root / wb.CHIP_CATALOG).write_text(json.dumps(catalog))
                wb.main()
                run.assert_called_with([*BUILD, './asics/trial/cli/chip.exe'], cwd=root, check=True)
                self.assertFalse((root / '.workbench').exists())

    def test_catalog_failure_is_reported_and_prevents_build(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            catalog = catalog_fixture(root)
            catalog['targets'][0]['executable'] = '../foreign.exe'
            (root / wb.CHIP_CATALOG).write_text(json.dumps(catalog))
            with patch.object(wb, 'ROOT', root), patch.object(wb.subprocess, 'run') as run:
                with self.assertRaisesRegex(ValueError, r'hardcaml-asic-targets\.json: .*electrum'):
                    wb.build()
                run.assert_not_called()
                source = wb.readiness(root / 'prefix', None)['source_operations']
                self.assertFalse(source['ready'])
                self.assertIn('electrum', source['chip_catalog']['diagnostic'])

    def test_explicit_toolchain_metadata_selects_venv_and_survives_later_configure(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, tools = Path(tmp), Path(tmp) / 'existing-toolchain'
            catalog_fixture(root)
            executable_fixtures(root, root / 'prefix')
            args = type('Args', (), dict(toolchain=tools, simulation_config=None))()
            metadata = dict(root=str(tools), validation='pinned_metadata_only_no_EDA',
                            python=dict(path=str(tools / '.venv/bin/python')))
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', root / '.dev/workbench'), \
                 patch.object(wb, 'stopped'), patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb.subprocess, 'run') as run, \
                 patch.object(wb, 'validate_toolchain', return_value=metadata) as validate, \
                 patch.dict(wb.os.environ, ELECTRUM_TOOLS_RECEIPT=str(root / 'receipt.json')):
                wb.configure(args)
                argv = run.call_args.args[0]
                self.assertEqual(argv[:4], [*BUILD[:3], '--workspace'])
                self.assertEqual(argv[5:], BUILD[3:])
                self.assertIn(str(root / 'prefix/lib'), (root / 'dune-workspace').read_text())
                self.assertIn(str(root / 'prefix/bin'), (root / 'dune-workspace').read_text())
                config = (root / '.workbench/hardcaml-workbench-asic.sexp').read_text()
                self.assertIn(str(tools / '.venv/bin/python'), config)
                self.assertIn(str(root / '_build/default' / wb.TARGET), config)
                self.assertIn(wb.TARGET, (root / '.workbench/hardcaml-workbench-preparation.sexp').read_text())
                with patch.object(wb, 'write', side_effect=AssertionError('warm configure rewrote state')):
                    wb.configure(args)
                run.assert_called_with(BUILD, cwd=root, check=True)
                args.toolchain = None
                wb.configure(args)
                self.assertEqual((root / '.workbench/hardcaml-workbench-asic.sexp').read_text(), config)
                state = json.loads((root / '.dev/workbench/configuration.json').read_text())
                self.assertEqual(state['physical_toolchain'], metadata)
                self.assertEqual(state['build_target'], wb.TARGET)
                self.assertIn('asic_support/cli/project.exe', config)
                status = wb.readiness(root / 'prefix', state)
                self.assertTrue(status['physical']['ready'])
                self.assertTrue(status['physical']['requires_explicit_preflight'])
                self.assertEqual(status['physical']['readiness_scope'], 'metadata_only_no_EDA')
                self.assertEqual(validate.call_count, 4)
                args.source_only = True
                wb.configure(args)
                refreshed = json.loads((root / '.dev/workbench/configuration.json').read_text())
                self.assertEqual(refreshed['toolchain'], str(root / '_flow_tools'))
                self.assertIsNone(refreshed['physical_toolchain'])
                self.assertEqual(validate.call_count, 4)

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

    def test_configure_uses_managed_local_tools_instead_of_missing_old_toolchain(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            store = root / '.dev/workbench'
            local = root / '_flow_tools'
            catalog_fixture(root)
            python = local / '.venv/bin/python'
            python.parent.mkdir(parents=True)
            python.touch()
            store.mkdir(parents=True)
            state = store / 'configuration.json'
            state.write_text(json.dumps(dict(sha256={}, toolchain=str(root / 'missing'),
                                             physical_toolchain={'old': True})))
            args = type('Args', (), dict(toolchain=None, simulation_config=None))()
            with patch.object(wb, 'ROOT', root), patch.object(wb, 'STORE', store), \
                 patch.object(wb, 'stopped'), patch.object(wb, 'selected', return_value=({}, root / 'prefix')), \
                 patch.object(wb, 'build'), patch.dict(wb.os.environ, ELECTRUM_TOOLS_RECEIPT='receipt'), \
                 patch.object(wb, 'validate_toolchain', return_value={'python': {'path': str(python)}}) as validate:
                wb.configure(args)
                validate.assert_called_once_with(local, root, root / 'prefix/bin/hardcaml-asic-flow')
            self.assertEqual(json.loads(state.read_text())['toolchain'], str(local))

    def test_source_readiness_is_independent_of_absent_physical_collateral(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, prefix = Path(tmp), Path(tmp) / 'prefix'
            catalog_fixture(root)
            executable_fixtures(root, prefix)
            hashes = {}
            for kind in ('asic', 'preparation'):
                path = root / '.workbench' / ('hardcaml-workbench-' + kind + '.sexp')
                path.parent.mkdir(exist_ok=True)
                data = ('owned unit ' + kind).encode()
                path.write_bytes(data)
                hashes[kind] = wb.sha(data)
            with patch.object(wb, 'ROOT', root):
                workspace = wb.dune_workspace(prefix)
                (root / 'dune-workspace').write_bytes(workspace)
                configuration = {'sha256': hashes, 'prefix': str(prefix), 'build_target': wb.TARGET,
                                 'dune_workspace_sha256': wb.sha(workspace)}
                status = wb.readiness(prefix, configuration)
                old_gateway = wb.readiness(prefix, dict(configuration, build_target='asic/cli/project.exe'))
                old_receipt = wb.readiness(prefix, {'sha256': hashes, 'prefix': str(prefix)})
                owner = root / '_build/default' / OWNERS['electrum']
                owner.chmod(0o644)
                not_executable = wb.readiness(prefix, configuration)
                owner.unlink()
                missing = wb.readiness(prefix, configuration)
            self.assertTrue(status['ready'])
            self.assertTrue(status['source_operations']['ready'])
            for stale in (old_gateway, old_receipt):
                self.assertTrue(stale['configure_required'])
                self.assertTrue(stale['source_operations']['selection_matches'])
                self.assertFalse(stale['source_operations']['target_matches'])
            self.assertFalse(status['source_operations']['requires_pdk'])
            self.assertEqual(status['preparation']['project_root'], str(root))
            self.assertEqual(status['preparation']['configuration_path'],
                str(root / '.workbench/hardcaml-workbench-preparation.sexp'))
            self.assertFalse(status['physical']['ready'])
            self.assertEqual(status['physical']['status'], 'missing_collateral')
            self.assertFalse(missing['ready'])
            self.assertFalse(not_executable['ready'])
            self.assertFalse(missing['configure_required'])
            self.assertEqual(missing['status'], 'not_ready')
            chips = missing['source_operations']['chip_catalog']
            self.assertFalse(chips['ready'])
            self.assertEqual(chips['default_target'], 'electrum')
            self.assertEqual({t['id']: t['ready'] for t in chips['targets']},
                             dict(electrum=False))

    def test_status_requires_configure_after_selected_prefix_changes(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, prefix = Path(tmp), Path(tmp) / 'new-prefix'
            catalog_fixture(root)
            executable_fixtures(root, prefix)
            hashes = {}
            for kind in ('asic', 'preparation'):
                path = root / '.workbench' / ('hardcaml-workbench-' + kind + '.sexp')
                path.parent.mkdir(exist_ok=True)
                path.write_text('known owned companion from prior prefix')
                hashes[kind] = wb.sha(path.read_bytes())
            config = dict(prefix=str(root / 'old-prefix'), sha256=hashes, build_target=wb.TARGET,
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
            catalog_fixture(root)
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
            catalog_fixture(root)
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
            catalog_fixture(root)
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
