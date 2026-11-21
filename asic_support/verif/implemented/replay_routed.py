#!/usr/bin/env python3
"""Separate functional replay of routed artifacts, including a failed physical run.

Never edits the run, provider, PDK or bench. Does not fabricate a public postcheck.
The installed hash-bound replay_models function only derives simulation collateral
into a fresh owned directory; no physical checker/tool entry point is called.
"""
import argparse
import importlib.util
from pathlib import Path

import check_implemented as gate


def public_attempt(runroot, prepared, toolchain, output):
    harness = gate.load_harness()
    evidence = harness.Evidence(output, gate.ROOT)
    watched = {str(p): gate.sha(p) for p in (runroot / "run.json", prepared / "testbench.v")}
    evidence.record = {"schema_version": 1, "scope": "public_postcheck_attempt_only",
                       "run_status_before": gate.load(runroot / "run.json")["status"],
                       "status": "running", "inputs": watched, "commands": [],
                       "budget": "serial supported6 provider allocation; no concurrent tool"}
    evidence.save()
    try:
        code, text = evidence.run(["bash", "scripts/with-private-asic.sh", "hardcaml-asic-flow", "postcheck", runroot,
                                  "--toolchain", toolchain, "--testbench", prepared / "testbench.v",
                                  "--testbench-top", "p3_loader_tb", "--timeout", "1800", "--json"],
                                 timeout=2100, success=False)
        evidence.record.update(status="returned", exit=code, public_acceptance="not_inferred_from_exit")
        if code != 0:
            gate.require("completed" in text or "physical-checks" in text or "physical checks" in text,
                         "unexpected postcheck failure; inspect retained logs")
            evidence.record["status"] = "refused"
        gate.require(all(gate.sha(p) == digest for p, digest in watched.items()), "public attempt changed run or bench")
    except BaseException as error:
        evidence.record.update(status="failed", error=f"{type(error).__name__}: {error}")
        raise
    finally:
        evidence.record["sha256"] = {k: v for k, v in harness.inventory(output).items() if k != "receipt.json"}
        evidence.save()


def snapshot_replay(bundle, runroot, prepared, freeze_path, closeout_path, provider_receipt, expected_netlist, output):
    gate.require(not output.exists(), "fresh routed replay directory required")
    output.mkdir(parents=True)
    try:
        watched, track, manifest, run, preflight, netlist, gds, instance, used = gate.audit_run_inputs(
            bundle, runroot, allow_failed=True)
        track(Path(__file__))
        gate.require(gate.sha(netlist) == expected_netlist, "coordinator final netlist hash mismatch")
        freeze = gate.load(track(freeze_path))
        closeout = gate.load(track(closeout_path))
        gate.require(freeze["bundle"]["identity"] == manifest["identity"]
                     and freeze["bundle"]["manifest_sha256"] == gate.sha(bundle / "manifest.json"), "freeze/bundle mismatch")
        gate.require(closeout["run_id"] == run["run_id"] and closeout["bundle_identity"] == manifest["identity"]
                     and closeout["status"] == run["status"], "closeout/run association mismatch")
        for path in (runroot / "run.json", netlist, gds):
            entries = [e for e in closeout["artifact_inventory"] if e["path"] == str(path)]
            gate.require(len(entries) == 1 and entries[0]["sha256"] == gate.sha(path), "closeout artifact association")
        prep = gate.load(track(prepared / "prepare.json"))
        bench = track(prepared / "testbench.v")
        track(gate.BENCH)
        gate.require(prep["instance"] == instance and prep["clock_period_ns"] == gate.PERIOD
                     and prep["testbench_sha256"] == gate.sha(bench)
                     and prep["authored_bench_sha256"] == gate.sha(gate.BENCH)
                     and bench.read_text() == gate.gate_bench(gate.BENCH.read_text(), instance), "prepared oracle changed")
        provider = gate.load(track(provider_receipt))
        gate.require(provider["checks_passed"] is True and freeze["readiness"]["tracked_sha256"].get(str(provider_receipt))
                     == gate.sha(provider_receipt), "provider receipt differs from physical freeze")
        prefix = Path(provider["prefix"])
        relative = "lib/hardcaml_asic/flow/hardcaml_asic_flow/physical_runtime.py"
        helper = track(prefix / relative)
        gate.require(gate.sha(helper) == provider["installed_sha256"][relative] == run["physical_checker_sha256"]
                     == gate.sha(track(runroot / "project/physical-runtime.py")), "installed/staged/run helper mismatch")
        # Model derivation is deliberately separate from a provider postcheck.
        # No physical checker or EDA function is invoked.
        spec = importlib.util.spec_from_file_location("pt3c_bound_model_derivation", helper)
        runtime = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(runtime)
        models_dir = output / "models"
        models_dir.mkdir()
        runtime.replay_models(runroot / "project", Path(preflight["pdk_root"]), netlist, models_dir)
        models, review = gate.verify_models(models_dir, manifest, preflight, used, track)
        for name in ("physical-checks.log", "execution.log", "results.json"):
            path = runroot / name
            if path.is_file():
                track(path)
        metrics_path = track(runroot / "project/runs/asic/final/metrics.json")
        metrics = gate.load(metrics_path)
        outcomes = {key: value for key, value in metrics.items()
                    if key.startswith(("timing__setup", "timing__hold", "magic__", "klayout__", "design__lvs"))}
        record = {"schema_version": 1, "status": "audited", "scope": gate.SCOPE,
                  "evidence_kind": "independent_routed_artifact_functional_replay",
                  "public_postcheck_acceptance": False, "physical_signoff": "failed" if run["status"] == "failed" else "not_assessed",
                  "original_run_status": run["status"], "original_completed_stage": run["completed_stage"],
                  "original_run_error": run.get("error"), "run_id": run["run_id"], "bundle_identity": manifest["identity"],
                  "netlist_sha256": expected_netlist, "instance": instance, "clock_period_ns": gate.PERIOD,
                  "timing_constraints": "provisional inherited 48MHz; observed timing failures remain failures",
                  "retained_outcomes": outcomes, "cell_review": review,
                  "model_derivation": {"helper_sha256": gate.sha(helper), "entry_point": "replay_models",
                                       "provider_postcheck": False},
                  "inputs": watched, "sources": [str(p.resolve()) for p in [*models, netlist, bench]]}
        gate.require(all(gate.sha(p) == digest for p, digest in watched.items()), "input changed during association/model review")
        gate.write(output / "association.json", record)
        gate.replay(record, output / "replay")
        gate.write(output / "result.json", {"status": "passed", "scope": gate.SCOPE,
                   "evidence_kind": record["evidence_kind"], "original_run_status": run["status"],
                   "physical_signoff": record["physical_signoff"], "public_postcheck_acceptance": False,
                   "netlist_sha256": expected_netlist, "used_standard_cell_types": len(used),
                   "replay_receipt": str(output / "replay/receipt.json")})
    except BaseException as error:
        gate.write(output / "result.json", {"status": "failed", "scope": "independent_routed_artifact_functional_replay",
                   "error": f"{type(error).__name__}: {error}", "public_postcheck_acceptance": False})
        raise


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    for name in ("public-attempt", "snapshot-replay"):
        cmd = sub.add_parser(name)
        for arg in ("run-root", "prepared", "output-dir"):
            cmd.add_argument("--" + arg, type=Path, required=True)
        if name == "public-attempt":
            cmd.add_argument("--toolchain", type=Path, required=True)
        else:
            for arg in ("bundle", "freeze", "closeout", "provider-receipt"):
                cmd.add_argument("--" + arg, type=Path, required=True)
            cmd.add_argument("--expected-netlist-sha256", required=True)
    args = parser.parse_args()
    if args.action == "public-attempt":
        public_attempt(args.run_root.resolve(), args.prepared.resolve(), args.toolchain.resolve(), args.output_dir.resolve())
    else:
        snapshot_replay(args.bundle.resolve(), args.run_root.resolve(), args.prepared.resolve(), args.freeze.resolve(),
                        args.closeout.resolve(), args.provider_receipt.resolve(), args.expected_netlist_sha256, args.output_dir.resolve())
    print(f"PT3c {args.action}: {args.output_dir}")
