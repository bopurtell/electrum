#!/usr/bin/env python3
"""Bounded PT.3a emission/resource checks. No builds, HDL tools, PDK or EDA."""

import argparse
import contextlib
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile


def run(*args, code=0):
    result = subprocess.run([str(arg) for arg in args], capture_output=True,
                            text=True, timeout=120)
    assert result.returncode == code, (args, result.returncode, result.stdout, result.stderr)
    return result


def check_snapshot(manifest, selection):
    snapshot = manifest["resource_snapshot"]
    assert snapshot["schema_version"] == 1
    assert snapshot["scope"] == "resolved"
    assert snapshot["mode"] == "implementation"
    assert snapshot["project"] == manifest["project"]
    assert snapshot["top"] == manifest["top_module"]
    assert len(snapshot["resources"]) == 1
    resource = snapshot["resources"][0]
    assert resource["id"] == {"path": [], "name": "program", "display": "program"}
    assert resource["policy"] == {"kind": "instance", "resource": "program"}
    assert resource["requirement"] == selection
    assert resource["elaborated_as"] == "selected_implementation"
    assert resource["request"]["kind"] == "single_port_ram"
    assert resource["request"]["contract"] == {"list": [
        {"list": [{"atom": key}, {"atom": value}]} for key, value in (
            ("width", "16"), ("depth", "256"), ("read_latency", "1"),
            ("port", "1rw"), ("disabled_output", "hold"),
            ("write_output", "unspecified"))]}
    if selection == "flops":
        assert resource["selection"] == {
            "implementation": {"kind": "flops"}, "reason": {"kind": "explicit_flops"}}
        assert resource["sources"] == [{"kind": "generated_synthesis_rtl"}]
        assert resource["collateral"] == []
        assert resource["actual_instances"] == {"status": "not_applicable"}
    else:
        macro = "RM_IHPSG13_1P_256x16_c2_bm_bist"
        assert resource["selection"] == {
            "implementation": {"kind": "macro", "name": macro},
            "reason": {"kind": "exact_mapping", "technology": "ihp-sg13cmos5l"}}
        assert resource["actual_instances"] == {
            "status": "rtl_verified", "instances": [
                {"module": macro, "instance": "hc_resource_7_program"}]}
        collateral = resource["collateral"]
        assert len(collateral) == 11
        assert resource["sources"] == [
            {"kind": "collateral", "collateral": item} for item in collateral]
        assert all(item["verification"] == "unresolved_reference" for item in collateral)
        roles = sorted(item["role"] for item in collateral)
        assert roles == sorted([
            "black_box", "simulation_model", "simulation_model",
            "timed_simulation_model", "timed_simulation_model",
            "timing_model", "timing_model", "timing_model",
            "physical_abstract", "physical_layout", "spice_netlist"])
    assert resource["physical_intent"] == {"status": "unavailable"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", type=Path, required=True)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--evidence-dir", default="",
                        help="retain bundles in a new directory instead of temporary storage")
    args = parser.parse_args()
    cli = args.cli.resolve()
    root = Path(run("git", "-C", args.source_root, "rev-parse", "--show-toplevel").stdout.strip())
    spec = importlib.util.spec_from_file_location(
        "adopted_bundle_checks", root / "asic/tinytapeout/scripts/check-adopted-bundle.py")
    checks = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(checks)
    identities = {}
    if args.evidence_dir:
        evidence = Path(args.evidence_dir).resolve()
        evidence.mkdir(parents=True, exist_ok=False)
        storage = contextlib.nullcontext(str(evidence))
    else:
        storage = tempfile.TemporaryDirectory(prefix="protemu-pt3a-")
    with storage as temporary:
        scratch = Path(temporary)
        for kind in ("memory", "loader"):
            run(cli, "--check-conflicts", kind)
            for selection in ("flops", "exact"):
                outputs = [scratch / f"{kind}-{selection}-{repeat}" for repeat in range(2)]
                for output in outputs:
                    receipt = run(cli, "--selection", selection, kind, output, root).stdout.strip()
                    checks.check_bundle(root, output, kind, selection)
                    emitted = json.loads((output / "manifest.json").read_text())
                    assert receipt == f"{output} {emitted['identity']}", "emission receipt"
                    check_snapshot(emitted, selection)
                assert checks.tree(outputs[0]) == checks.tree(outputs[1]), "complete byte repeat"
                manifest = json.loads((outputs[0] / "manifest.json").read_text())
                identities[kind, selection] = manifest["identity"]
                saved = checks.tree(outputs[0])
                run(cli, "--selection", selection, kind, outputs[0], root, code=2)
                assert checks.tree(outputs[0]) == saved, "nonempty refusal changed bytes"
                if selection == "flops":
                    legacy = scratch / f"{kind}-legacy"
                    run(cli, kind, legacy, root)
                    assert checks.tree(legacy) == saved, "legacy default differs from explicit Flops"
                print(f"PASS PT.3a {kind} {selection}: repeat bytes, hashes, sources, resource identity")
            assert identities[kind, "flops"] != identities[kind, "exact"]
        # Preserve both legacy observable invocation forms, including its zero-resource inventory.
        observable = scratch / "observable"
        explicit = scratch / "observable-explicit"
        run(cli, observable, root)
        run(cli, "--selection", "flops", "observable", explicit, root)
        checks.check_bundle(root, observable, "observable")
        assert checks.tree(observable) == checks.tree(explicit)
        rejected = scratch / "observable-exact-rejected"
        run(cli, "--selection", "exact", "observable", rejected, root, code=2)
        assert not rejected.exists(), "unsupported observable Exact emitted output"
        for kind in ("memory", "loader"):
            rejected = scratch / f"{kind}-hardening-rejected"
            result = run(cli, "--selection", "exact", "--operation", "hardening",
                         kind, rejected, root, code=2)
            assert "physical" in result.stderr.lower()
            assert not rejected.exists(), "Exact Hardening emitted without physical intent"
        for options in (("--selection", "auto"), ("--selection",),
                        ("--selection", "flops", "--selection", "exact")):
            run(cli, *options, code=2)
        receipt = {"schema_version": 1, "status": "passed", "scope": "PT.3a; no EDA",
                   "source_revision": run("git", "-C", root, "rev-parse", "HEAD").stdout.strip(),
                   "cli": str(cli), "bundles": [
                       {"kind": kind, "selection": selection, "identity": identity,
                        "repeats": [f"{kind}-{selection}-{repeat}" for repeat in range(2)]}
                       for (kind, selection), identity in identities.items()]}
        (scratch / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
        if args.evidence_dir:
            print(f"PT.3a retained evidence: {scratch / 'receipt.json'}")
    print("PASS PT.3a legacy defaults, observable zero resources and Exact rejection; no EDA")


if __name__ == "__main__":
    main()
