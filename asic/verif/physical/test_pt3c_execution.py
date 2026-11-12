"""Pure execution-owner fixtures: no tool, build, Docker or EDA launches.

Run directly with Python's unittest runner; this suite needs no Dune build.
Unmocked subprocess execution is forbidden, including on regression paths.
"""

import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import signal
import tempfile
import unittest
from unittest.mock import Mock, patch

PATH = Path(__file__).resolve().with_name("pt3c_execution.py")
spec = importlib.util.spec_from_file_location("pt3c_execution_owner", PATH)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class OwnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="pt3c-execution-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in ("run", "Popen"):
            guard = patch.object(m.subprocess, name, side_effect=AssertionError("unmocked subprocess forbidden"))
            guard.start()
            self.addCleanup(guard.stop)

    def put(self, relative, value):
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value))
        return path

    def bundle(self):
        b = self.root / "bundle"
        b.mkdir()
        source = self.root / "config.ml"
        source.write_text("frozen hardware")
        (b / "inputs").mkdir()
        (b / "inputs/config.ml").write_text(source.read_text())
        (b / "physical").mkdir()
        plan = {"profile": "fixture"}
        (b / "physical/macro-plan.json").write_text(json.dumps(plan))
        manifest = {
            "top_module": m.TOP, "project": "protemu_loader", "operation": "Hardening",
            "identity": "a" * 64,
            "macro_contract": {"schema_version": 2, "execution": "fresh_full",
                "physical_plan": plan, "macros": [{"resource": "program", "module": m.STOCK,
                "instance": "hc_resource_7_program", "physical_intent": {
                    "location_um": [40., 480.], "halo_um": 2., "orientation": "R0",
                    "power": {"VDD!": "VPWR", "VDDARRAY!": "VPWR", "VSS!": "VGND"}}}]},
            "files": [{"path": "inputs/config.ml", "sha256": m.sha(source)},
                      {"path": "physical/macro-plan.json", "sha256": m.sha(b / "physical/macro-plan.json")}],
            "source_inputs": [{"path": "config.ml", "copy": "inputs/config.ml", "sha256": m.sha(source)}]}
        (b / "manifest.json").write_text(json.dumps(manifest))
        return b, source, manifest

    def test_no_args_is_only_help(self):
        with patch("sys.argv", [str(PATH)]), patch.object(m, "readiness") as ready, \
                patch.object(m.subprocess, "Popen") as launch, contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(m.main(), 0)
            ready.assert_not_called()
            launch.assert_not_called()

    def test_run_requires_allocation_before_launch(self):
        with patch("sys.argv", [str(PATH), "run"]), patch.object(m.subprocess, "Popen") as launch, \
                contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            m.main()
        launch.assert_not_called()

    def test_source_freeze_and_placement_rejection(self):
        b, source, manifest = self.bundle()
        with patch.object(m, "ROOT", self.root), patch.object(m, "query", return_value="fixture"):
            frozen = m.bundle_snapshot(b)
            source.write_text("owner still editing")
            with self.assertRaisesRegex(ValueError, "source not frozen"):
                m.bundle_snapshot(b)
            source.write_text("frozen hardware")
            manifest["macro_contract"]["macros"][0]["physical_intent"]["location_um"] = [40, 81]
            (b / "manifest.json").write_text(json.dumps(manifest))
            with self.assertRaisesRegex(ValueError, "40,480"):
                m.bundle_snapshot(b)
            self.assertEqual(frozen["macro_instance"], "hc_resource_7_program")

    def test_stub_synthesis_bundle_rejected(self):
        b, _, manifest = self.bundle()
        manifest["operation"] = "Synthesis"
        (b / "manifest.json").write_text(json.dumps(manifest))
        with self.assertRaisesRegex(ValueError, "Hardening"):
            m.bundle_snapshot(b)

    def test_freeze_ignores_unrelated_edits_but_not_source_or_provider(self):
        base = {"bundle": "/b", "identity": "x", "manifest_sha256": "m",
                "sources_sha256": {"config": "s"}, "head": "h", "macro_instance": "i",
                "git_status": "before"}
        frozen = {"schema": 1, "bundle": base, "readiness": {"provider": "p"}}
        with patch.object(m, "bundle_snapshot", return_value={**base, "git_status": "other owner edit"}), \
                patch.object(m, "readiness", return_value={"provider": "p"}):
            m.verify_freeze(frozen)
        with patch.object(m, "bundle_snapshot", return_value={**base, "sources_sha256": {}}), \
                patch.object(m, "readiness", return_value={"provider": "p"}), \
                self.assertRaisesRegex(ValueError, "sources_sha256"):
            m.verify_freeze(frozen)
        with patch.object(m, "bundle_snapshot", return_value=base), \
                patch.object(m, "readiness", return_value={"provider": "changed"}), \
                self.assertRaisesRegex(ValueError, "readiness changed"):
            m.verify_freeze(frozen)

    def test_outcome_binds_exact_run_not_newest(self):
        path = self.put("runs/exact/run.json", {"run_id": "r", "build_identity": "b",
                        "requested_stage": "full", "status": "failed"})
        value = {"run_dir": str(path.parent), "run_record": str(path), "run_id": "r", "status": "failed"}
        run, _ = m.checked_outcome(value, self.root / "runs", "b")
        self.assertEqual(run, path.parent)
        with self.assertRaisesRegex(ValueError, "identity mismatch"):
            m.checked_outcome(value, self.root / "runs", "other")
        with self.assertRaisesRegex(ValueError, "escaped"):
            m.checked_outcome(value, self.root / "different", "b")

    def test_failed_evidence_is_not_overwritten(self):
        path = self.put("failed.json", {"status": "failed"})
        with self.assertRaises(FileExistsError):
            m.save(path, {"status": "completed"}, exclusive=True)
        self.assertEqual(m.load(path)["status"], "failed")

    def supervisor(self):
        self.put("request.json", {"freeze": {"bundle": {"identity": "b"}}, "max_seconds": 1000})
        self.put("receipt.json", {"status": "running"})
        (self.root / "owner.lock").touch()
        return m.Supervisor(self.root)

    def test_publication_error_drains_provider_before_returning(self):
        s = self.supervisor()
        process = Mock(pid=os.getpid())
        process.poll.return_value = None
        process.wait.return_value = 143
        with patch.object(m.subprocess, "Popen", return_value=process), \
                patch.object(s, "publish", side_effect=[None, OSError("disk error")]), \
                self.assertRaisesRegex(OSError, "disk error"):
            s.phase("full", ["run", "/b", "--stage", "full"])
        process.terminate.assert_called_once()
        process.wait.assert_called_once()
        self.assertIsNone(s.provider)

    def test_cancel_targets_only_current_provider(self):
        s = self.supervisor()
        process = Mock()
        process.poll.return_value = None
        s.provider = process
        s.signal(signal.SIGTERM, None)
        process.send_signal.assert_called_once_with(signal.SIGTERM)
        self.assertTrue(s.cancelled)

    def test_writer_loss_is_explicit_and_read_only(self):
        self.put("receipt.json", {"status": "running", "supervisor": {"pid": 999999999}})
        (self.root / "owner.lock").touch()
        result = m.inspect_attempt(self.root)
        self.assertFalse(result["owner_alive"])
        self.assertIn("writer absent", result["monitor_warning"])
        self.assertNotIn("monitor_warning", m.load(self.root / "receipt.json"))

    def test_live_owner_identity(self):
        identity = m.process_identity(os.getpid())
        self.assertEqual(identity["pid"], os.getpid())
        self.assertEqual(identity["pgid"], os.getpgid(os.getpid()))
        self.assertIsNone(m.process_identity(999999999))

    def test_existing_attempt_refuses_even_with_valid_freeze(self):
        freeze = self.put("freeze.json", {"schema": 1})
        args = Mock(freeze=freeze, evidence=self.root, command="run")
        with patch.object(m, "verify_freeze"), patch.object(m.subprocess, "Popen") as launch, \
                self.assertRaises(FileExistsError):
            m.launch(args)
        launch.assert_not_called()

    def run_fixture(self, operation="run", full_code=0, report_code=1, preflight_code=0):
        s = self.supervisor()
        s.request.update(operation=operation, allocation="serial6", coordinator="fixture-slot",
                         min_available_gib=8, script_sha256=m.sha(PATH))
        s.request["freeze"]["bundle"]["bundle"] = "/frozen/bundle"
        lock = self.root / "shared.lock"
        lock.touch()
        phases = []

        def phase(name, args):
            phases.append(name)
            if name == "preflight":
                self.put("preflight.json", {"ready": preflight_code == 0})
                return preflight_code
            if name == "full":
                state = "completed" if full_code == 0 else "failed"
                path = self.put("runs/exact/run.json", {
                    "run_id": "r", "build_identity": "b", "requested_stage": "full",
                    "completed_stage": "full" if not full_code else None, "status": state,
                    "resource_limits": m.LIMITS})
                self.put("full.stdout", {"run_dir": str(path.parent), "run_record": str(path),
                                         "run_id": "r", "status": state, "exit_code": full_code})
                return full_code
            if name == "report":
                self.put("report.stdout", {"acceptance": "not_evaluated"})
                return report_code
            return 0

        with patch.object(m, "LOCK", lock), patch.object(m, "verify_freeze"), \
                patch.object(m, "resource_gate", return_value={"available_memory_kib": 30 * 1024**2}), \
                patch.object(s, "phase", side_effect=phase), patch.object(m.signal, "signal"):
            code = s.run()
        return s, code, phases

    def test_success_report_nonzero_is_not_physical_failure(self):
        _, code, phases = self.run_fixture()
        self.assertEqual(code, 0)
        self.assertEqual(phases, ["preflight", "full", "collect", "report"])
        outcome = m.load(self.root / "outcome.json")
        self.assertEqual(outcome["status"], "completed")
        self.assertEqual(outcome["report_exit_code"], 1)
        self.assertEqual(outcome["run_record"], str(self.root / "runs/exact/run.json"))
        self.assertEqual(outcome["report_json"], str(self.root / "report.stdout"))
        self.assertEqual(outcome["acceptance"], "not_evaluated_replay_owned_separately")
        self.assertTrue((self.root / "monitor.jsonl").exists())

    def test_physical_failure_retains_outcome_and_report(self):
        _, code, phases = self.run_fixture(full_code=1)
        self.assertEqual(code, 1)
        self.assertEqual(phases, ["preflight", "full", "collect", "report"])
        outcome = m.load(self.root / "outcome.json")
        self.assertEqual(outcome["status"], "failed")
        self.assertEqual(outcome["provider_outcome"]["status"], "failed")
        self.assertEqual(m.load(self.root / "runs/exact/run.json")["status"], "failed")

    def test_preflight_failure_never_starts_full(self):
        _, code, phases = self.run_fixture(preflight_code=1)
        self.assertEqual(code, 1)
        self.assertEqual(phases, ["preflight"])
        self.assertEqual(m.load(self.root / "outcome.json")["status"], "failed")

    def test_metadata_only_command_never_starts_full(self):
        _, code, phases = self.run_fixture(operation="preflight")
        self.assertEqual(code, 0)
        self.assertEqual(phases, ["preflight"])

    def test_resource_gate_refuses_low_memory(self):
        with patch.object(m, "host_resources", return_value={
                "available_memory_kib": 7 * 1024**2, "free_disk_bytes": 100 * 1024**3}), \
                self.assertRaisesRegex(ValueError, "memory"):
            m.resource_gate(8)

    def test_detached_launch_no_implicit_build_or_flow(self):
        freeze = self.put("freeze.json", {"schema": 1, "readiness": {"tracked_sha256": {}}})
        args = Mock(freeze=freeze, evidence=self.root / "new", command="run",
                    max_seconds=86400, min_available_gib=8, coordinator="fixture-slot")
        process = Mock(pid=os.getpid())
        with patch.object(m, "verify_freeze"), patch.object(m.subprocess, "Popen", return_value=process) as popen, \
                contextlib.redirect_stdout(io.StringIO()):
            m.launch(args)
        argv = popen.call_args.args[0]
        self.assertEqual(argv[2:], [str(PATH), "_supervise", str(args.evidence)])
        self.assertTrue(popen.call_args.kwargs["start_new_session"])
        self.assertTrue(popen.call_args.kwargs["close_fds"])
        self.assertEqual(popen.call_args.kwargs["stdin"], m.subprocess.DEVNULL)
        self.assertEqual(m.load(args.evidence / "receipt.json")["status"], "starting")


if __name__ == "__main__":
    unittest.main()
