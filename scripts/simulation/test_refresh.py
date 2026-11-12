"""Pure stored-generation/catalog migration tests; no producer/build/install calls."""
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import prepare
import pt3b_provider as provider
from test_provider import Fixture


class Refresh(unittest.TestCase):
    def fixture(self, root, *, version=1, matrix=None):
        store = root / 'simulation-store'
        (store / 'generations').mkdir(parents=True)
        f = Fixture(store / 'generations')
        proof = f.generation / 'qualification.json'
        qualified = json.loads(proof.read_text())
        if matrix is not None:
            qualified['suites'] = matrix
        if version == 2:
            qualified['schema_version'] = 2
            f.install.update(schema_version=2, catalog_schema_version=1,
                             catalog=provider.catalog(), catalog_sha256=provider.catalog_digest(provider.catalog()))
        proof.write_text(json.dumps(qualified))
        f.install['qualification_sha256'] = provider.sha(proof)
        f.save()
        self.select(store, f)
        return store, f

    def select(self, store, fixture):
        (store / 'current.json').write_text(json.dumps(dict(schema_version=1,
            manifest=str(fixture.manifest), manifest_sha256=provider.sha(fixture.manifest))))

    def test_legacy_serial_catalog_can_refresh_to_new_schema_but_cannot_advertise_it(self):
        with tempfile.TemporaryDirectory() as tmp:
            store, f = self.fixture(Path(tmp), matrix={provider.SUITE: list(provider.CASES)})
            with patch.object(prepare, 'STORE', store):
                old_selection, previous = prepare.verify_previous()
                self.assertEqual(previous['schema_version'], 1)
                with self.assertRaisesRegex(provider.InfrastructureError, 'complete serial and event'):
                    prepare.verify_current(check_sources=False)
                f.install.update(schema_version=2, checks_passed=False, catalog_schema_version=1,
                    catalog=provider.catalog(), catalog_sha256=provider.catalog_digest(provider.catalog()))
                f.save()
                self.select(store, f)
                with self.assertRaisesRegex(provider.InfrastructureError, 'not qualified'):
                    prepare.verify_current()

    def test_stored_schema2_catalog_is_independent_of_a_new_case_matrix(self):
        with tempfile.TemporaryDirectory() as tmp:
            store, f = self.fixture(Path(tmp), version=2)
            future = {suite: list(cases) for suite, cases in provider.SUITES.items()}
            future[provider.EVENT_SUITE].append('new-directed-case')
            with patch.object(prepare, 'STORE', store), patch.object(provider, 'SUITES', future):
                selection, previous = prepare.verify_previous()
                self.assertEqual(previous['schema_version'], 2)
                self.assertNotIn('new-directed-case', provider.catalog_matrix(previous['catalog'])[provider.EVENT_SUITE])
                with self.assertRaisesRegex(provider.InfrastructureError, 'complete serial and event'):
                    prepare.verify_current()

    def test_current_qualified_catalog_still_validates(self):
        with tempfile.TemporaryDirectory() as tmp:
            store, f = self.fixture(Path(tmp), version=2)
            with patch.object(prepare, 'STORE', store):
                self.assertEqual(prepare.verify_current()[1]['catalog_sha256'], provider.catalog_digest(provider.catalog()))

    def test_previous_generation_corrupt_installed_bytes_are_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            store, f = self.fixture(Path(tmp), matrix={provider.SUITE: ['historical-case']})
            (f.generation / 'serial_trace.v').write_text('unknown user edit')
            with patch.object(prepare, 'STORE', store), self.assertRaisesRegex(provider.InfrastructureError, 'input changed'):
                prepare.verify_previous()

    def test_previous_qualification_artifact_corruption_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            store, f = self.fixture(Path(tmp), version=2)
            artifact = f.generation / 'qualified-result.json'
            artifact.write_text('retained unit evidence')
            proof = f.generation / 'qualification.json'
            qualification = json.loads(proof.read_text())
            qualification['sha256'] = {artifact.name: provider.sha(artifact)}
            proof.write_text(json.dumps(qualification))
            f.install['qualification_sha256'] = provider.sha(proof)
            f.save()
            self.select(store, f)
            artifact.write_text('changed unit evidence')
            with patch.object(prepare, 'STORE', store), self.assertRaisesRegex(provider.InfrastructureError, 'qualification input/result changed'):
                prepare.verify_previous()

    def test_pointer_and_catalog_hashes_reject_unknown_metadata_edits(self):
        with tempfile.TemporaryDirectory() as tmp:
            store, f = self.fixture(Path(tmp), version=2)
            f.install['catalog'][1][1][0][1] = 'changed label or catalog structure'
            f.save()
            with patch.object(prepare, 'STORE', store), self.assertRaisesRegex(provider.InfrastructureError, 'manifest changed'):
                prepare.verify_previous()
            self.select(store, f)  # Inner catalog digest must still reject the edit.
            with patch.object(prepare, 'STORE', store), self.assertRaisesRegex(provider.InfrastructureError, 'stored catalog changed'):
                prepare.verify_previous()


if __name__ == '__main__':
    unittest.main()
