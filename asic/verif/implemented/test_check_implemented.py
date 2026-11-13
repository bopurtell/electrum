#!/usr/bin/env python3
"""Pure fixtures only: no HDL compilation, simulation, builds, or provider tools."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
import sys
from unittest.mock import patch

import check_implemented as gate


def put(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    return path


def netlist(instance="hc_resource_7_program"):
    return f"""module {gate.TOP} (clk);
input clk;
wire a;
sg13cmos5l_buf_1 b (.A(clk), .X(a));
{gate.MACRO} {instance} (.A_CLK(a), .A_MEN(a), .A_WEN(a), .A_REN(a),
 .A_ADDR(a), .A_DIN(a), .A_DOUT(a), .A_BM(a), .A_DLY(a), .A_BIST_EN(a));
endmodule
"""


def transcript():
    harness = gate.load_harness()
    scenarios = harness.LOADER_SCENARIOS + harness.PENDING_SCENARIOS
    output = "\n".join("PT3B OBS " + s for s in scenarios)
    for fetch, reset in ((0, 0), (0, 1), (1, 0), (1, 1)):
        output += f"\nPT3B PHASE pending-cancel fetch={fetch} reset={reset} read_edges=1"
    return output + "\nPT3B COUNTERS refusals=6 cancellations=4 reads=100 writes=20\nPT3B PASS loader observations=18\n"


class Fixture(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="pt3c-fixture-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.bundle = self.root / "bundle"
        self.run = self.root / "run"
        self.post = self.run / "checks/post-1"
        self.prepared = self.root / "prepared"
        gate.prepare(self.prepared, "hc_resource_7_program")
        self.harness = gate.load_harness()
        self.addCleanup(patch.stopall)
        patch.object(gate, "load_harness", return_value=self.harness).start()
        wrapper = put(self.root / "pdk/wrapper.v", "fixture wrapper")
        core = put(self.root / "pdk/core.v", "fixture core")
        udp = put(self.root / "pdk/sg13cmos5l_udp.v", "fixture udp")
        vendor = put(self.root / "pdk/sg13cmos5l_stdcell.v",
                     "// type: buf\nmodule sg13cmos5l_buf_1 (X, A);\noutput X; input A; buf (X, A);\nendmodule")
        refs = ["pdk_dir::wrapper.v", "pdk_dir::core.v"]
        self.harness.MODEL_HASHES = dict(zip(refs, (gate.sha(wrapper), gate.sha(core))))
        self.manifest = {"project": "electrum_loader", "top_module": gate.TOP, "operation": "Hardening",
                         "target": {"technology": "ihp-sg13cmos5l"},
                         "source_inputs": [{"path": "source.ml", "copy": "inputs/source.ml", "sha256": ""}],
                         "synthesis_sources": ["src/top.v"], "simulation_sources": ["simulation/top.v"],
                         "macro_contract": {"macros": [{"resource": "program", "module": gate.MACRO,
                                                        "instance": "hc_resource_7_program"}],
                                            "implementation_simulation": {"defines": ["FUNCTIONAL"], "models": refs}}}
        for name, text in (("src/top.v", "fixture emitted macro RTL"), ("simulation/top.v", "fixture behavioral RTL"),
                           ("inputs/source.ml", "fixture authored hardware")):
            put(self.bundle / name, text)
        self.manifest["source_inputs"][0]["sha256"] = gate.sha(self.bundle / "inputs/source.ml")
        self.manifest["files"] = [{"path": str(p.relative_to(self.bundle)), "sha256": gate.sha(p)}
                                  for p in sorted(self.bundle.rglob("*")) if p.is_file()]
        self.seal_manifest()
        for item in self.manifest["files"]:
            put(self.run / "project" / item["path"], (self.bundle / item["path"]).read_text())
        self.final = put(self.run / "project/runs/asic/final/nl" / (gate.TOP + ".nl.v"), netlist())
        gds = put(self.run / "project/runs/asic/final/gds" / (gate.TOP + ".gds"), "fixture GDS")
        helper = put(self.run / "project/physical-runtime.py", "fixture helper; never imported")
        self.run_record = {"run_id": "run-1", "build_identity": self.manifest["identity"],
                           "manifest_sha256": gate.sha(self.bundle / "manifest.json"),
                           "status": "completed", "requested_stage": "full", "completed_stage": "full",
                           "physical_checker_sha256": gate.sha(helper)}
        gate.write(self.run / "run.json", self.run_record)
        self.preflight = {"ready": True, "issues": [], "references": [
            {"reference": ref, "path": str(p), "sha256": gate.sha(p),
             "role": "macro:Simulation_model" if ref in refs else "physical:checking_collateral"}
            for ref, p in zip(refs + ["cells", "udp"], [wrapper, core, vendor, udp])]}
        gate.write(self.run / "preflight.json", self.preflight)
        put(self.post / "testbench.v", (self.prepared / "testbench.v").read_text())
        put(self.post / "physical-runtime.py", helper.read_text())
        for name, source in (("model-0.v", wrapper), ("model-1.v", core), ("model-2.v", udp),
                             ("stdcell-vendor.v", vendor)):
            put(self.post / name, source.read_text())
        functional = "\n`timescale 1ns/1ps\n// Reviewed zero-delay functional view; not SDF/timing evidence.\n\n" + vendor.read_text().split("\n", 1)[1].replace("endmodule", "\nendmodule")
        put(self.post / "stdcell-functional.v", functional)
        retained = {p.name: gate.sha(p) for p in self.post.iterdir() if p.name.startswith(("model-", "stdcell-"))}
        self.models = {"scope": "zero_delay_gate_functional",
                       "models": [str(self.post / p) for p in ("model-0.v", "model-1.v", "model-2.v", "stdcell-functional.v")],
                       "source_hashes": {str(p): gate.sha(p) for p in (wrapper, core, udp, vendor)},
                       "retained_hashes": retained, "vendor_sha256": gate.sha(vendor),
                       "functional_sha256": gate.sha(self.post / "stdcell-functional.v"),
                       "adaptations": {"sg13cmos5l_buf_1": []}}
        gate.write(self.post / "replay-models.json", self.models)
        executable = str(self.post / "gate.out")
        compile_cmd = ["iverilog", "-g2012", "-DFUNCTIONAL", "-DSIM", "-s", "p3_loader_tb", "-o", executable,
                       *self.models["models"], str(self.final), str(self.post / "testbench.v")]
        self.post_record = {"status": "completed", "checks": {"precheck": "pass", "gate_level": "pass"},
                            "run_id": "run-1", "build_identity": self.manifest["identity"],
                            "tools": {"replay_scope": gate.SCOPE},
                            "inputs": {"netlist_sha256": gate.sha(self.final), "gds_sha256": gate.sha(gds),
                                       "testbench_sha256": gate.sha(self.post / "testbench.v"),
                                       "testbench_top": "p3_loader_tb", "physical_runtime_sha256": gate.sha(helper)},
                            "artifacts": {p.name: gate.sha(p) for p in self.post.iterdir()
                                          if p.name != "testbench.v"},
                            "processes": [{"argv": compile_cmd, "stdout": "compile.out", "stderr": "compile.err"},
                                          {"argv": ["vvp", executable], "stdout": "sim.out", "stderr": "sim.err"}],
                            "process_results": [{"outcome": "exited", "code_or_ocaml_signal": 0, "succeeded": True}] * 2,
                            "logs": ["sim.out"], "reports": []}
        for name in ("compile.out", "compile.err", "sim.err"):
            put(self.post / name, "")
        put(self.post / "sim.out", transcript())
        gate.write(self.post / "postcheck.json", self.post_record)

    def seal_manifest(self):
        self.manifest.pop("identity", None)
        self.manifest["identity"] = hashlib.sha256(json.dumps(self.manifest, separators=(",", ":")).encode()).hexdigest()
        gate.write(self.bundle / "manifest.json", self.manifest)
        put(self.run / "project/manifest.json", json.dumps(self.manifest, indent=2) + "\n")

    def audit(self):
        return gate.audit(self.bundle, self.run, self.post, self.prepared)

    def reseal_models(self):
        for name in self.models["retained_hashes"]:
            self.models["retained_hashes"][name] = gate.sha(self.post / name)
        self.models["functional_sha256"] = gate.sha(self.post / "stdcell-functional.v")
        gate.write(self.post / "replay-models.json", self.models)
        for name in self.post_record["artifacts"]:
            self.post_record["artifacts"][name] = gate.sha(self.post / name)
        gate.write(self.post / "postcheck.json", self.post_record)

    def test_complete_association_audit_no_subprocess(self):
        with patch("subprocess.Popen", side_effect=AssertionError("no processes")):
            record = self.audit()
        self.assertEqual(record["status"], "audited")
        self.assertEqual(record["physical_signoff"], "not_assessed")
        self.assertEqual(record["provider_positive"]["counters"]["cancellations"], 4)
        self.assertEqual(record["instance"], "hc_resource_7_program")
        self.assertEqual(len(record["sources"]), 6)

    def test_replay_same_compiled_artifact_and_retained_failure(self):
        record = self.audit()
        commands = []

        def run(evidence, argv, **kwargs):
            argv = list(map(str, argv))
            commands.append(argv)
            if "-o" in argv:
                put(Path(argv[argv.index("-o") + 1]), "fixture compiled artifact")
            if argv[0] == "fixture-vvp" and "-V" not in argv:
                if "+PT3B_EXPECT_MISMATCH" in argv:
                    return 1, "PT3B EXPECTED_MISMATCH\nFATAL: testbench.v:440: response word got=1234 expected=1235\n"
                return 0, transcript()
            return 0, "fixture tool"

        output = self.root / "replay"
        with patch.object(self.harness.Evidence, "run", run), \
                patch.object(gate.shutil, "which", side_effect=lambda tool: "fixture-" + tool), \
                patch.object(gate.os, "sched_setaffinity"):
            gate.replay(record, output)
        receipt = gate.load(output / "receipt.json")
        self.assertEqual(receipt["status"], "passed")
        simulations = [c for c in commands if c[0] == "fixture-vvp" and "-N" in c]
        self.assertEqual(simulations[1][:-1], simulations[0])
        self.assertEqual(simulations[1][-1], "+PT3B_EXPECT_MISMATCH")
        self.assertEqual(len(receipt["portable_sources"]), 6)
        with patch.object(self.harness.Evidence, "run", side_effect=RuntimeError("compile fixture")), \
                patch.object(gate.shutil, "which", return_value="fixture-tool"), \
                patch.object(gate.os, "sched_setaffinity"):
            with self.assertRaisesRegex(RuntimeError, "compile fixture"):
                gate.replay(record, self.root / "failed-replay")
        self.assertEqual(gate.load(self.root / "failed-replay/receipt.json")["status"], "failed")

    def test_final_netlist_hash_association(self):
        self.final.write_text(netlist() + "\n// later edit")
        with self.assertRaisesRegex(ValueError, "netlist_sha256"):
            self.audit()

    def test_staged_source_independently_checked(self):
        (self.run / "project/src/top.v").write_text("different emitted source")
        with self.assertRaisesRegex(ValueError, "staged input"):
            self.audit()

    def test_bundle_identity_checked(self):
        self.manifest["project"] = "other"
        gate.write(self.bundle / "manifest.json", self.manifest)
        with self.assertRaisesRegex(ValueError, "identity"):
            self.audit()

    def test_failed_run_and_wrong_postcheck(self):
        for section, key, value in ((self.run_record, "status", "failed"),
                                     (self.post_record, "run_id", "other")):
            old = section[key]
            section[key] = value
            path = self.run / "run.json" if section is self.run_record else self.post / "postcheck.json"
            gate.write(path, section)
            with self.assertRaises(ValueError):
                self.audit()
            section[key] = old
            gate.write(path, section)

    def test_explicit_failed_run_snapshot_does_not_grant_public_acceptance(self):
        self.run_record.update(status="failed", completed_stage=None, error="physical evidence validation failed")
        gate.write(self.run / "run.json", self.run_record)
        watched, _, _, run, _, _, _, _, _ = gate.audit_run_inputs(self.bundle, self.run, allow_failed=True)
        self.assertEqual(run["status"], "failed")
        self.assertIsNone(run["completed_stage"])
        self.assertEqual(gate.sha(self.run / "run.json"), watched[str(self.run / "run.json")])
        with self.assertRaisesRegex(ValueError, "completed public full run"):
            self.audit()

    def test_weaker_package_bench_rejected(self):
        put(self.post / "testbench.v", gate.BENCH.read_text())
        self.post_record["inputs"]["testbench_sha256"] = gate.sha(self.post / "testbench.v")
        gate.write(self.post / "postcheck.json", self.post_record)
        with self.assertRaisesRegex(ValueError, "gate bench"):
            self.audit()

    def test_provider_compile_actual_closure(self):
        self.post_record["processes"][0]["argv"].insert(-1, "stub.v")
        gate.write(self.post / "postcheck.json", self.post_record)
        with self.assertRaisesRegex(ValueError, "compile closure"):
            self.audit()

    def test_timeout_not_success(self):
        self.post_record["process_results"][0] = {"outcome": "timeout", "code_or_ocaml_signal": 0, "succeeded": True}
        gate.write(self.post / "postcheck.json", self.post_record)
        with self.assertRaisesRegex(ValueError, "process failure"):
            self.audit()

    def test_source_preflight_binding(self):
        self.preflight["references"][-1]["sha256"] = "0" * 64
        gate.write(self.run / "preflight.json", self.preflight)
        with self.assertRaisesRegex(ValueError, "preflight"):
            self.audit()

    def test_shared_functional_timed_collateral_identity(self):
        timed = dict(self.preflight["references"][0], role="macro:Timed_simulation_model")
        self.preflight["references"].append(timed)
        gate.write(self.run / "preflight.json", self.preflight)
        self.assertEqual(self.audit()["status"], "audited")
        timed["sha256"] = "0" * 64
        gate.write(self.run / "preflight.json", self.preflight)
        with self.assertRaisesRegex(ValueError, "conflicting preflight"):
            self.audit()

    def test_resealed_derived_logic_corruption_rejected(self):
        p = self.post / "stdcell-functional.v"
        p.write_text(p.read_text().replace("buf (X, A)", "not (X, A)"))
        self.reseal_models()
        with self.assertRaisesRegex(ValueError, "derivation"):
            self.audit()

    def test_used_cell_set_not_receipt_label(self):
        self.models["adaptations"]["sg13cmos5l_inv_1"] = []
        self.reseal_models()
        with self.assertRaisesRegex(ValueError, "used-cell set"):
            self.audit()

    def test_provider_missing_scenario_rejected(self):
        p = self.post / "sim.out"
        p.write_text(p.read_text().replace("PT3B OBS pending-fetch-reset\n", ""))
        with self.assertRaisesRegex(ValueError, "scenario transcript"):
            self.audit()


class Contracts(unittest.TestCase):
    def test_flat_final_unique_macro_and_supported_syntax(self):
        self.assertEqual(gate.final_instances(netlist())[0], "hc_resource_7_program")
        self.assertEqual(gate.final_instances(netlist("\\program.mem "))[0], "\\program.mem")
        with_fill = netlist().replace("endmodule", "sg13cmos5l_decap_8 FILLER_0_1 (); endmodule")
        self.assertIn("sg13cmos5l_decap_8", gate.final_instances(with_fill)[1])
        synthesized = netlist().replace("wire a;", "wire a; wire \\core$execution$reg_word[0] ;")
        self.assertEqual(gate.final_instances(synthesized)[0], "hc_resource_7_program")
        for bad in (netlist().replace("endmodule", f"{gate.MACRO} second (.A_CLK(clk)); endmodule"),
                    netlist().replace(gate.MACRO, "other_macro"), netlist() + "module extra; endmodule",
                    netlist().replace("sg13cmos5l_buf_1 b", "sg13cmos5l_buf_1 #(1) b"),
                    netlist().replace(".A_CLK(a)", ".A_CLK(a), .A_CLK(a)"),
                    netlist().replace(".A_CLK(a),", ""),
                    netlist().replace("endmodule", "sg13cmos5l_buf_1 disconnected (); endmodule"),
                    netlist().replace("endmodule", 'initial $display("unacceptable"); endmodule'),
                    netlist().replace(".A(clk), .X(a)", "clk, a")):
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                gate.final_instances(bad)

    def test_prepare_selfcontained_default_and_fresh_directory(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "new"
            with patch("subprocess.Popen", side_effect=AssertionError("no process")):
                gate.prepare(output, "hc_resource_7_program")
            text = (output / "testbench.v").read_text()
            self.assertIn("`define PT3_CLOCK_PERIOD_NS 20.833333", text)
            self.assertIn("`define PT3B_EXACT 1", text)
            self.assertNotIn('`include', text)
            with self.assertRaises(FileExistsError):
                gate.prepare(output, "hc_resource_7_program")
        bench = gate.BENCH.read_text()
        self.assertIn("`define PT3_CLOCK_PERIOD_NS 10.0", bench)
        self.assertIn("always @(posedge pt3b_memory_clock)", bench)
        self.assertIn("`PT3_PROGRAM_INSTANCE.A_CLK", bench)

    def test_audit_failure_receipt_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            args = ["check_implemented.py", "audit", "--bundle", str(root / "missing"),
                    "--run-root", str(root / "run"), "--postcheck", str(root / "post"),
                    "--prepared", str(root / "prepared"), "--output-dir", str(root / "failed")]
            with patch.object(sys, "argv", args), patch("subprocess.Popen", side_effect=AssertionError("no process")):
                with self.assertRaises(FileNotFoundError):
                    gate.main()
                receipt = gate.load(root / "failed/receipt.json")
                self.assertEqual(receipt["status"], "failed")
                self.assertEqual(receipt["phase"], "association_audit")
                before = gate.sha(root / "failed/receipt.json")
                with self.assertRaisesRegex(ValueError, "fresh output"):
                    gate.main()
                self.assertEqual(before, gate.sha(root / "failed/receipt.json"))

    def test_prepared_final_binding_rejects_wrong_instance(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            final = put(root / "final.v", netlist())
            with self.assertRaisesRegex(ValueError, "unique final instance"):
                gate.prepare(root / "new", "other", final)
            self.assertFalse((root / "new").exists())

    def test_negative_failure_classification(self):
        good = "PT3B EXPECTED_MISMATCH\nFATAL: testbench.v:440: response word got=1234 expected=1235\n"
        gate.check_negative(good, 1)
        for output, code in ((good, 0), (good, -9), (good, 2),
                             ("PT3B EXPECTED_MISMATCH\nFATAL: watchdog", 1),
                             (good + "PT3B PASS loader observations=18\n", 1)):
            with self.subTest(output=output, code=code), self.assertRaises(ValueError):
                gate.check_negative(output, code)

    def test_runtime_witnesses_required(self):
        gate.check_positive(transcript())
        with self.assertRaisesRegex(ValueError, "witnesses"):
            gate.check_positive(transcript().replace("read_edges=1", "read_edges=0"))

    def test_review_rejects_procedural_or_delayed_cells(self):
        for body in ("reg q;", "wire delayed_CLK;", "initial begin end", "always @* q=1;"):
            with self.subTest(body=body), self.assertRaisesRegex(ValueError, "unreviewed"):
                gate.reviewed_cell("sg13cmos5l_custom", "module sg13cmos5l_custom ();" + body + "endmodule")
        self.assertEqual(gate.reviewed_cell("sg13cmos5l_buf_1",
                         "module sg13cmos5l_buf_1 (X,A); output X; input A; buf (X,A); endmodule"), [])

    def test_all_four_supplied_reset_flop_forms_and_corruption(self):
        for name in ("sg13cmos5l_dfrbpq_1", "sg13cmos5l_dfrbpq_2", "sg13cmos5l_dfrbp_1", "sg13cmos5l_dfrbp_2"):
            dual = "dfrbp_" in name
            module = f"""module {name} ({'Q, Q_N' if dual else 'Q'}, CLK, D, RESET_B);
output {'Q, Q_N' if dual else 'Q'}; input CLK, D, RESET_B;
reg notifier; wire delayed_D, delayed_RESET_B, delayed_CLK;
{'wire int_fwire_IQ, int_fwire_IQN, int_fwire_r; wire xcr_0;' if dual else 'wire int_fwire_IQ, int_fwire_r, xcr_0;'}
not (int_fwire_r, delayed_RESET_B); buf (xcr_0, 0);
ihp_dff_r (int_fwire_IQ, notifier, delayed_CLK, delayed_D, int_fwire_r, xcr_0);
buf (Q, int_fwire_IQ);
{'not (int_fwire_IQN, int_fwire_IQ); buf (Q_N, int_fwire_IQN);' if dual else ''}
specify (CLK => Q) = (1, 1); endspecify
endmodule"""
            with self.subTest(name=name):
                self.assertEqual(gate.reviewed_cell(name, module), ["CLK", "D", "RESET_B"])
                with self.assertRaisesRegex(ValueError, "flop body"):
                    gate.reviewed_cell(name, module.replace("buf (Q, int_fwire_IQ)", "not (Q, int_fwire_IQ)"))

    def test_supplied_mux2_udp_forms_and_corruption(self):
        for name in ("sg13cmos5l_mux2_1", "sg13cmos5l_mux2_2"):
            module = f"module {name} (X, A0, A1, S); output X; input A0, A1, S; ihp_mux2 (X, A0, A1, S); endmodule"
            with self.subTest(name=name):
                self.assertEqual(gate.reviewed_cell(name, module), [])
                with self.assertRaisesRegex(ValueError, "mux2 body"):
                    gate.reviewed_cell(name, module.replace("ihp_mux2 (X, A0, A1, S)", "ihp_mux2 (X, A1, A0, S)"))
        with self.assertRaisesRegex(ValueError, "unreviewed"):
            gate.reviewed_cell("sg13cmos5l_custom", "module sg13cmos5l_custom (); ihp_mux2 (X,A,B,S); endmodule")

    def test_supplied_mux4_udp_form_and_corruption(self):
        name = "sg13cmos5l_mux4_1"
        module = f"module {name} (X, A0, A1, A2, A3, S0, S1); output X; input A0, A1, A2, A3, S0, S1; ihp_mux4 (X, A0, A1, A2, A3, S0, S1); endmodule"
        self.assertEqual(gate.reviewed_cell(name, module), [])
        with self.assertRaisesRegex(ValueError, "mux4 body"):
            gate.reviewed_cell(name, module.replace("ihp_mux4 (X, A0, A1, A2, A3, S0, S1)",
                                                  "ihp_mux4 (X, A0, A1, A2, A3, S1, S0)"))

    def test_path_escape(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name in ("../outside", "/etc/passwd", ""):
                with self.assertRaises(ValueError):
                    gate.inside(root, name)


if __name__ == "__main__":
    unittest.main()
