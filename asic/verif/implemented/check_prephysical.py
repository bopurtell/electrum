#!/usr/bin/env python3
"""Allocated PT3c bench smoke replay against a fresh, passed PT3b Exact bundle.

This is emitted-RTL functional evidence, never implemented-netlist acceptance.
Optional cell review exercises the independent reviewer on supplied real collateral;
the final Protemu used-cell set must still be reviewed after implementation.
"""
import argparse
import hashlib
from pathlib import Path
import re

import check_implemented as gate


def review_cells(netlist, vendor, functional):
    used = sorted(set(re.findall(r"\b(sg13cmos5l_\w+)\s+(?:\\\S+|\w+)\s*\(", gate.clean(netlist.read_text()))))
    gate.require(used, "no actual mapped cells in supplied review netlist")
    text = vendor.read_text()
    transformed = [text[:text.index("// type:")] if "// type:" in text else "",
                   "`timescale 1ns/1ps\n// Reviewed zero-delay functional view; not SDF/timing evidence.\n"]
    review = {}
    for name in used:
        modules = re.findall(r"\bmodule\s+" + re.escape(name) + r"\s*\(.*?\bendmodule", text, re.S)
        gate.require(len(modules) == 1, "unknown/nonunique supplied cell: " + name)
        delayed = gate.reviewed_cell(name, modules[0])
        body = re.sub(r"\bspecify\b.*?\bendspecify\b", "", modules[0], flags=re.S)
        bypass = "\n".join("assign delayed_" + pin + " = " + pin + ";" for pin in delayed)
        transformed.append(body.replace("endmodule", bypass + "\nendmodule"))
        review[name] = {"module_sha256": hashlib.sha256(modules[0].encode()).hexdigest(), "delayed_pins": delayed}
    gate.require(functional.read_text() == "\n".join(transformed), "supplied cell derivation differs")
    return review


def execute(pt3b, output, cells=None):
    gate.require(not output.exists(), "fresh output directory required")
    output.mkdir(parents=True)
    try:
        harness = gate.load_harness()
        receipt = gate.load(pt3b / "receipt.json")
        gate.require(receipt["status"] == "passed" and len(receipt["replays"]) == 9
                     and all(r["status"] == "passed" for r in receipt["replays"]), "passed full PT3b gate required")
        gate.require(harness.inventory(pt3b) == {**receipt["sha256"], "receipt.json": gate.sha(pt3b / "receipt.json")},
                     "PT3b evidence inventory changed")
        exact = [r for r in receipt["replays"] if r["name"] == "loader-exact-synthesis_sources"]
        gate.require(len(exact) == 1 and exact[0]["vendor_functional"], "unique Exact vendor replay required")
        source = exact[0]
        bundle = pt3b / "loader-exact-0"
        manifest = gate.load(bundle / "manifest.json")
        gate.require(manifest["identity"] == source["bundle_identity"] and manifest["operation"] == "Synthesis"
                     and manifest["top_module"] == gate.TOP, "fresh Exact synthesis bundle association")
        rtl = harness.safe_path(bundle, manifest["synthesis_sources"][0])
        macros = manifest["macro_contract"]["macros"]
        gate.require(len(macros) == 1 and macros[0]["module"] == gate.MACRO, "one declared program macro required")
        instance = macros[0]["instance"]
        gate.require(re.findall(r"\b" + gate.MACRO + r"\s+(\w+)\s*\(", gate.clean(rtl.read_text())) == [instance],
                     "unique emitted macro binding required")
        gate.prepare(output / "prepared", instance)
        prepared = output / "prepared/testbench.v"
        # The Exact replay closure contains synthesis RTL, two unchanged vendor
        # models, then authored bench. Reuse those exact snapshotted files.
        inputs = {}
        for item in source["sources"]:
            path = Path(item["path"]).resolve(strict=True)
            gate.require(path.is_relative_to(pt3b) and gate.sha(path) == item["sha256"], "Exact input changed")
            inputs[str(path)] = item["sha256"]
        sources = [str(Path(item["path"]).resolve()) for item in source["sources"][:-1]]
        gate.require(len(sources) == 3 and sources[0] == str(rtl), "unexpected emitted replay closure")
        gate.require({Path(p).name: gate.sha(p) for p in sources[1:]} ==
                     {Path(ref).name: digest for ref, digest in harness.MODEL_HASHES.items()}, "vendor model drift")
        for path in [pt3b / "receipt.json", bundle / "manifest.json", Path(__file__),
                     Path(gate.__file__), gate.HERE.parent / "functional/check_functional.py",
                     gate.BENCH, prepared, output / "prepared/prepare.json"]:
            inputs[str(path.resolve())] = gate.sha(path)
        cell_review = None
        if cells:
            cell_review = review_cells(*cells)
            for path in cells:
                inputs[str(path.resolve())] = gate.sha(path)
        record = {"schema_version": 1, "scope": "prepared_48MHz_bench_emitted_Exact_RTL_vendor_functional_only",
                  "stage": "prephysical", "physical_signoff": "not_assessed", "implemented_netlist": False,
                  "clock_period_ns": gate.PERIOD, "bundle_identity": manifest["identity"],
                  "pt3b_receipt": str(pt3b / "receipt.json"), "instance": instance,
                  "sources": [*sources, str(prepared.resolve())], "inputs": inputs,
                  "supplied_cell_review": cell_review,
                  "cell_review_scope": "supplied specimen only; final Protemu used-cell review pending"}
        gate.write(output / "prephysical.json", record)
        gate.replay(record, output / "replay")
        gate.write(output / "result.json", {"status": "passed", "scope": record["scope"],
                   "prepared_directory": str((output / "prepared").resolve()),
                   "replay_receipt": str((output / "replay/receipt.json").resolve()),
                   "supplied_cell_count": len(cell_review) if cell_review else None})
    except BaseException as error:
        gate.write(output / "result.json", {"status": "failed", "stage": "prephysical",
                   "error": f"{type(error).__name__}: {error}"})
        raise


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pt3b", required=True, type=Path)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument("--cell-netlist", type=Path)
    parser.add_argument("--cell-vendor", type=Path)
    parser.add_argument("--cell-functional", type=Path)
    args = parser.parse_args()
    cells = (args.cell_netlist, args.cell_vendor, args.cell_functional)
    gate.require(all(cells) or not any(cells), "supply all three cell review inputs")
    execute(args.pt3b.resolve(), args.output_dir.resolve(), tuple(p.resolve() for p in cells) if all(cells) else None)
    print(f"PASS PT3c prephysical smoke: {args.output_dir}")
