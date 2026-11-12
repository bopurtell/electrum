"""Pure harness fixtures: no compiler, simulator, emitter or build subprocesses."""

import copy
import json
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

import check_functional as harness


class OracleTests(unittest.TestCase):
    def test_positive_observation_count(self):
        self.assertEqual(harness.check_oracle("PT3B PASS loader observations=42\n", 0, "loader"), 42)

    def test_positive_rejects_vacuous_or_failed_completion(self):
        cases = (("", 0), ("PT3B PASS loader observations=0\n", 0),
                 ("PT3B PASS memory observations=4\n", 0),
                 ("PT3B PASS loader observations=4\n", 1),
                 ("PT3B PASS loader observations=4\n" * 2, 0),
                 ("PT3B EXPECTED_MISMATCH\nPT3B PASS loader observations=4\n", 0))
        for output, code in cases:
            with self.subTest(output=output, code=code), self.assertRaises(ValueError):
                harness.check_oracle(output, code, "loader")

    def test_negative_requires_deliberate_mismatch(self):
        harness.check_oracle("PT3B EXPECTED_MISMATCH\n", 1, "memory", negative=True)
        for output, code in (("arbitrary fatal", 1), ("PT3B EXPECTED_MISMATCH", 0),
                             ("FAIL missing PT3B EXPECTED_MISMATCH", 1),
                             ("PT3B EXPECTED_MISMATCH", -9),
                             ("PT3B EXPECTED_MISMATCH\nPT3B PASS memory observations=3\n", 1)):
            with self.subTest(output=output, code=code), self.assertRaises(ValueError):
                harness.check_oracle(output, code, "memory", negative=True)


def loader_output(profile):
    boundary = profile != "package"
    rounds = 3 if profile == "external_contract" else 1
    scenarios = (harness.LOADER_SCENARIOS + (harness.PENDING_SCENARIOS if boundary else [])) * rounds
    lines = ["PT3B OBS " + scenario for scenario in scenarios]
    if rounds == 3:
        lines += [f"PT3B ORACLE poison={p} architectural_digest=1234abcd" for p in range(3)]
    lines += [f"PT3B COUNTERS refusals={6 * rounds} cancellations={(4 if boundary else 0) * rounds} "
              f"reads={100 if boundary else 0} writes={20 if boundary else 0}",
              f"PT3B PASS loader observations={len(scenarios)}"]
    return "\n".join(lines) + "\n"


class LoaderAcceptanceTests(unittest.TestCase):
    def test_three_required_profiles(self):
        for profile, count, refusals, cancellations in (("package", 14, 6, 0),
                                                        ("exact", 18, 6, 4),
                                                        ("external_contract", 54, 18, 12)):
            with self.subTest(profile=profile):
                output = loader_output(profile)
                self.assertEqual(harness.check_oracle(output, 0, "loader"), count)
                acceptance = harness.check_loader(output, count, profile)
                self.assertEqual(acceptance["counters"]["refusals"], refusals)
                self.assertEqual(acceptance["counters"]["cancellations"], cancellations)
                self.assertEqual(acceptance["macro_runtime_evidence"], profile == "exact")

    def test_count_alone_does_not_prove_scenarios_or_macro_runtime(self):
        output = loader_output("exact")
        cases = ["PT3B PASS loader observations=18\n",
                 output.replace("PT3B OBS pending-fetch-reset\n", ""),
                 output.replace("reads=100", "reads=0"),
                 output.replace("writes=20", "writes=0"),
                 output.replace("cancellations=4", "cancellations=0"),
                 output.replace("refusals=6", "refusals=5"),
                 output + "PT3B COUNTERS refusals=6 cancellations=4 reads=100 writes=20\n"]
        for changed in cases:
            with self.subTest(output=changed), self.assertRaises(ValueError):
                harness.check_loader(changed, 18, "exact")
        with self.assertRaises(ValueError):
            harness.check_loader(loader_output("package"), 18, "exact")

    def test_external_requires_all_poison_rounds_and_matching_digests(self):
        output = loader_output("external_contract")
        cases = [output.replace("poison=2", "poison=1"),
                 output.replace("poison=2 architectural_digest=1234abcd",
                                "poison=2 architectural_digest=5678abcd"),
                 output.replace("PT3B ORACLE poison=1 architectural_digest=1234abcd\n", ""),
                 output.replace("cancellations=12", "cancellations=4"),
                 output.replace("PT3B OBS initial-image-invalid\n", "", 1)]
        for changed in cases:
            with self.subTest(output=changed), self.assertRaises(ValueError):
                harness.check_loader(changed, 54, "external_contract")
        with self.assertRaises(ValueError):
            harness.check_loader(output, 53, "external_contract")


class SourceTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="pt3b-fixture-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)

    def test_unsafe_paths_and_symlink_escape(self):
        (self.root / "ok.v").write_text("module ok; endmodule\n")
        self.assertEqual(harness.safe_path(self.root, "ok.v"), self.root / "ok.v")
        for path in ("../outside", "/etc/passwd", "./ok.v", "a//b", ""):
            with self.subTest(path=path), self.assertRaises(ValueError):
                harness.safe_path(self.root, path)
        (self.root / "escape").symlink_to("/etc/passwd")
        with self.assertRaises(ValueError):
            harness.safe_path(self.root, "escape")

    def test_four_roles_never_mix_behavioral_and_vendor_or_stub(self):
        for name in ("behavioral.v", "implementation.v", "stub.v"):
            (self.root / name).write_text(name)
        manifest = {"simulation_sources": ["behavioral.v"],
                    "synthesis_sources": ["implementation.v"],
                    "macro_contract": {"blackbox_sources": ["stub.v"]}}
        models = [Path("vendor-wrapper.v"), Path("vendor-core.v")]
        for selection in ("flops", "exact"):
            for role in ("simulation_sources", "synthesis_sources"):
                exact, defines, sources = harness.replay_inputs(
                    manifest, self.root, selection, role, models, ["LOADER_WRAPPER"])
                self.assertEqual(exact, selection == "exact" and role == "synthesis_sources")
                self.assertEqual("FUNCTIONAL" in defines, exact)
                self.assertEqual("PT3B_EXACT" in defines, exact)
                self.assertEqual(sources, [self.root / manifest[role][0]] + (models if exact else []))
                self.assertIn("PT3B", defines)
                self.assertIn("LOADER_WRAPPER", defines)
        manifest["synthesis_sources"] = ["stub.v"]
        with self.assertRaisesRegex(ValueError, "stub"):
            harness.replay_inputs(manifest, self.root, "exact", "synthesis_sources", models, [])

    def model_fixture(self):
        models = self.root / "ihp-sg13cmos5l/libs.ref/sg13cmos5l_sram/verilog"
        models.mkdir(parents=True)
        hashes = {}
        for reference in harness.MODEL_HASHES:
            data = reference.encode()
            (models / Path(reference).name).write_bytes(data)
            hashes[reference] = harness.digest(data)
        manifest = {"target": {"technology": "ihp-sg13cmos5l"},
                    "macro_contract": {"implementation_simulation": {
                        "defines": ["FUNCTIONAL"], "models": list(hashes)}},
                    "resource_snapshot": {"resources": [{"collateral": [
                        {"role": "simulation_model", "reference": ref} for ref in hashes]}]}}
        return manifest, hashes

    def test_manifest_models_resolve_and_hash(self):
        manifest, hashes = self.model_fixture()
        with patch.object(harness, "MODEL_HASHES", hashes):
            resolved = harness.resolve_models(manifest, self.root)
            self.assertEqual([ref for ref, _ in resolved], list(hashes))
            resolved[0][1].write_text("changed")
            with self.assertRaisesRegex(ValueError, "drift"):
                harness.resolve_models(manifest, self.root)

    def test_locked_pdk_internal_shared_model_symlinks(self):
        manifest, hashes = self.model_fixture()
        original = self.root / "ihp-sg13cmos5l/libs.ref/sg13cmos5l_sram/verilog"
        shared = self.root / "ihp-sg13g2/shared-models"
        shared.mkdir(parents=True)
        for source in original.iterdir():
            target = shared / source.name
            source.rename(target)
            source.symlink_to(target)
        with patch.object(harness, "MODEL_HASHES", hashes):
            paths = harness.resolve_models(manifest, self.root)
            self.assertTrue(all(path.parent == shared for _, path in paths))
            # The same hash at an outside target must still be rejected.
            with tempfile.TemporaryDirectory(prefix="pt3b-outside-") as tmp:
                reference = next(iter(hashes))
                outside = Path(tmp) / "model.v"
                outside.write_bytes(reference.encode())
                source = original / Path(reference).name
                source.unlink()
                source.symlink_to(outside)
                with self.assertRaisesRegex(ValueError, "escapes"):
                    harness.resolve_models(manifest, self.root)

    def test_model_closure_and_roles_must_agree(self):
        manifest, hashes = self.model_fixture()
        cases = []
        wrong = copy.deepcopy(manifest)
        wrong["macro_contract"]["implementation_simulation"]["defines"] = ["SYNTHESIS"]
        cases.append(wrong)
        wrong = copy.deepcopy(manifest)
        wrong["macro_contract"]["implementation_simulation"]["models"][0] = "generated:stub.v"
        cases.append(wrong)
        wrong = copy.deepcopy(manifest)
        wrong["resource_snapshot"]["resources"][0]["collateral"][0]["role"] = "timed_simulation_model"
        cases.append(wrong)
        with patch.object(harness, "MODEL_HASHES", hashes):
            for wrong in cases:
                with self.subTest(manifest=wrong), self.assertRaises(ValueError):
                    harness.resolve_models(wrong, self.root)


class EvidenceTests(unittest.TestCase):
    def test_failed_run_keeps_receipt_and_logs(self):
        with tempfile.TemporaryDirectory(prefix="pt3b-fixture-") as tmp:
            root = Path(tmp)
            (root / ".git").mkdir()
            cli = root / "fixture-emitter"
            cli.write_text("fixture")
            directory = root / "evidence"
            argv = ["check_functional.py", "--source-root", str(root), "--cli", str(cli),
                    "--core-emitter", str(cli),
                    "--evidence-dir", str(directory)]
            with patch.object(sys, "argv", argv), \
                 patch.object(harness, "execute", side_effect=ValueError("fixture failure")), \
                 patch.dict(harness.os.environ), patch("builtins.print"):
                with self.assertRaisesRegex(ValueError, "fixture failure"):
                    harness.main()
            receipt = json.loads((directory / "receipt.json").read_text())
            self.assertEqual(receipt["status"], "failed")
            self.assertEqual(receipt["error"], "ValueError: fixture failure")
            self.assertEqual(receipt["sha256"], {})

    def test_replay_records_same_run_macro_evidence_and_truthful_selfcheck(self):
        with tempfile.TemporaryDirectory(prefix="pt3b-fixture-") as tmp:
            root = Path(tmp)
            evidence = harness.Evidence(root / "evidence", root)
            source, bench = root / "macro.v", root / "bench.v"
            source.write_text("fixture macro RTL")
            bench.write_text("fixture bench")
            results = [(0, ""), (0, loader_output("exact")), (1, "PT3B EXPECTED_MISMATCH\n")]

            def run(argv, **kwargs):
                evidence.record["commands"].append({"argv": [str(x) for x in argv]})
                return results.pop(0)

            with patch.object(evidence, "run", side_effect=run):
                harness.replay(evidence, {"iverilog": "fixture-iverilog", "vvp": "fixture-vvp"},
                               "exact", [source], bench, "p3_loader_tb",
                               ["PT3B", "LOADER_WRAPPER", "PT3B_EXACT", "FUNCTIONAL"],
                               "loader", profile="exact", identity="bundle-fixture", role="synthesis_sources")
            receipt = json.loads((evidence.directory / "receipt.json").read_text())
            replay = receipt["replays"][0]
            self.assertEqual(replay["positive_command"], 1)
            self.assertEqual(replay["negative_command"], 2)
            self.assertTrue(replay["acceptance"]["macro_runtime_evidence"])
            self.assertEqual(replay["acceptance"]["counters"]["reads"], 100)
            self.assertIn("no DUT fault injection", replay["negative_oracle_selfcheck"])
            self.assertIn("not DUT fault injection", receipt["negative_check"])
            self.assertEqual(replay["status"], "passed")

    def test_new_directory_only_and_exact_byte_snapshot(self):
        with tempfile.TemporaryDirectory(prefix="pt3b-fixture-") as tmp:
            root = Path(tmp)
            evidence = harness.Evidence(root / "evidence", root)
            with self.assertRaises(FileExistsError):
                harness.Evidence(root / "evidence", root)
            original = root / "vendor.v"
            original.write_bytes(b"vendor\x00bytes\n")
            snapshot, sha = evidence.snapshot(original, "models/vendor.v")
            self.assertEqual(snapshot.read_bytes(), original.read_bytes())
            self.assertEqual(sha, harness.digest(original.read_bytes()))

    def test_timeout_kills_only_owned_group_and_records_outcome(self):
        with tempfile.TemporaryDirectory(prefix="pt3b-fixture-") as tmp:
            root = Path(tmp)
            evidence = harness.Evidence(root / "evidence", root)
            process = Mock(pid=43210, returncode=-9)
            process.wait.side_effect = [subprocess.TimeoutExpired(["fixture"], 2), -9]
            with patch.object(harness.subprocess, "Popen", return_value=process) as launch, \
                 patch.object(harness.os, "killpg") as kill:
                with self.assertRaises(subprocess.TimeoutExpired):
                    evidence.run(["fixture"], timeout=2)
            self.assertTrue(launch.call_args.kwargs["start_new_session"])
            kill.assert_called_once_with(43210, signal.SIGKILL)
            receipt = json.loads((evidence.directory / "receipt.json").read_text())
            self.assertTrue(receipt["commands"][0]["timed_out"])
            self.assertEqual(receipt["commands"][0]["exit"], -9)


if __name__ == "__main__":
    unittest.main()
