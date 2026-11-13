#!/usr/bin/env python3
"""PT3c: prepare a public-postcheck bench, audit retained closure, explicitly replay.

prepare/audit launch no subprocesses. replay is a separately allocated host-Icarus
operation. Supported netlists are flat, named-port, unparameterized provider final
netlists with one program macro. Unsupported syntax fails closed.
"""

import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BENCH = ROOT / "verif/system/emitted/p3_loader_tb.v"
TOP = "tt_um_leemperor_electrum_loader"
MACRO = "RM_IHPSG13_1P_256x16_c2_bm_bist"
PERIOD = "20.833333"
SCOPE = "zero_delay_gate_functional_not_timing_conformance"


def require(ok, message):
    if not ok:
        raise ValueError(message)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load(path):
    return json.loads(Path(path).read_text())


def write(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + "\n")


def inside(root, relative):
    require(isinstance(relative, str) and relative and not Path(relative).is_absolute()
            and ".." not in Path(relative).parts, "unsafe artifact path")
    path = (root / relative).resolve(strict=True)
    require(path.is_relative_to(root.resolve()) and path.is_file(), "artifact escapes root")
    return path


def clean(text):
    return re.sub(r"/\*.*?\*/|//[^\n]*", "", text, flags=re.S)


def final_instances(text):
    """Small recognizer for the one supported flat provider output format."""
    text = clean(text)
    require(re.findall(r"\bmodule\s+(\w+)", text) == [TOP]
            and len(re.findall(r"\bendmodule\b", text)) == 1, "expected one flat loader top")
    # Synthesized escaped identifiers legitimately contain '$' and hierarchy
    # punctuation. They are names, not system tasks or executable HDL syntax.
    syntax = re.sub(r"\\[^\s]+\s", "__escaped_identifier__ ", text)
    require(not re.search(r"[`#$\"]|\b(?:always|initial|generate|defparam|function|task)\b", syntax),
            "unsupported final-netlist syntax")
    # Statements after the module header must be declarations, assignments, or
    # one unparameterized cell with named ports. Reject hidden hierarchy/cells.
    statements = text[:text.rindex("endmodule")].split(";")
    instances = []
    for statement in statements[1:]:
        statement = statement.strip()
        if not statement or re.match(r"(?:input|output|inout|wire|assign)\b", statement):
            continue
        match = re.fullmatch(r"(\w+)\s+(\\[^\s]+\s+|[A-Za-z_]\w*)\s*\((.*)\)", statement, re.S)
        require(match is not None, "unsupported cell statement: " + statement[:100])
        cell, name, ports = match.groups()
        require(cell == MACRO or re.fullmatch(r"sg13cmos5l_\w+", cell), "unexpected cell type: " + cell)
        connections = list(re.finditer(r"\.(\w+)\s*\(([^()]*)\)", ports))
        physical_empty = not ports.strip() and re.fullmatch(r"sg13cmos5l_(?:fill|decap)_\d+", cell)
        require(physical_empty or (connections and not re.sub(r"\.(\w+)\s*\(([^()]*)\)", "", ports).strip(" \t\r\n,")),
                "simple named ports required")
        names = [p[1] for p in connections]
        require(len(names) == len(set(names)), "duplicate cell port")
        if cell == MACRO:
            require({"A_CLK", "A_MEN", "A_WEN", "A_REN", "A_ADDR", "A_DIN", "A_DOUT",
                     "A_BM", "A_DLY", "A_BIST_EN"}.issubset(names), "missing public macro probe ports")
        instances.append((cell, name.strip()))
    require(len({name for _, name in instances}) == len(instances), "duplicate instance name")
    macros = [name for cell, name in instances if cell == MACRO]
    require(len(macros) == 1, "unique final program macro required")
    require(any(cell.startswith("sg13cmos5l_") for cell, _ in instances), "mapped cells required")
    return macros[0], sorted({cell for cell, _ in instances if cell != MACRO})


def instance_expression(name):
    require(re.fullmatch(r"[A-Za-z_]\w*|\\[^\s]+", name) is not None, "unsupported macro identifier")
    return "dut." + name + (" " if name.startswith("\\") else "")


def gate_bench(bench, instance, period=PERIOD):
    require(period in ("10.0", PERIOD), "unsupported replay period")
    require("`PT3_PROGRAM_INSTANCE.A_CLK" in bench and "`PT3_CLOCK_PERIOD_NS" in bench,
            "bench lacks macro-clock/period indirection")
    prefix = "// PT3c retained self-contained gate bench; functional only, no SDF.\n"
    for name, value in (("PT3B", "1"), ("LOADER_WRAPPER", "1"), ("PT3B_EXACT", "1"),
                        ("PT3_PROGRAM_INSTANCE", instance_expression(instance)),
                        ("PT3_CLOCK_PERIOD_NS", period)):
        prefix += f"`undef {name}\n`define {name} {value}\n"
    return prefix + bench


def prepare(output, instance, netlist=None):
    if netlist is not None:
        actual, _ = final_instances(netlist.read_text())
        require(actual == instance, "requested probe differs from unique final instance")
    text = gate_bench(BENCH.read_text(), instance)
    output.mkdir(parents=True, exist_ok=False)
    (output / "testbench.v").write_text(text)
    write(output / "prepare.json", {
        "scope": SCOPE, "clock_period_ns": PERIOD, "instance": instance,
        "instance_validation": "final_netlist" if netlist else "deferred_until_audit",
        "netlist_sha256": sha(netlist) if netlist else None,
        "authored_bench_sha256": sha(BENCH), "testbench_sha256": sha(output / "testbench.v"),
        "testbench_top": "p3_loader_tb"})


def reviewed_cell(name, module):
    """Independent functional-body review, including all four reset-flop forms.

    The mux2/mux4 forms use the stock combinational UDPs. Other used cells must
    be structural. No arbitrary delayed-wire bypasses or procedural bodies are
    admitted. The retained model is compared byte-for-byte
    with the provider's derivation separately below.
    """
    text = clean(module)
    require(len(re.findall(r"\bspecify\b", text)) == len(re.findall(r"\bendspecify\b", text)) <= 1,
            "unsupported specify structure: " + name)
    body = re.sub(r"\bspecify\b.*?\bendspecify\b", "", text, flags=re.S)
    delayed = sorted(set(re.findall(r"\bdelayed_(\w+)\b", body)))
    flops = {"sg13cmos5l_dfrbpq_1", "sg13cmos5l_dfrbpq_2", "sg13cmos5l_dfrbp_1", "sg13cmos5l_dfrbp_2"}
    if name in flops:
        dual = name in {"sg13cmos5l_dfrbp_1", "sg13cmos5l_dfrbp_2"}
        ports = "Q, Q_N, CLK, D, RESET_B" if dual else "Q, CLK, D, RESET_B"
        wires = "wire int_fwire_IQ, int_fwire_IQN, int_fwire_r; wire xcr_0;" if dual else "wire int_fwire_IQ, int_fwire_r, xcr_0;"
        expected = f"""module {name} ({ports});
          output {"Q, Q_N" if dual else "Q"}; input CLK, D, RESET_B;
          reg notifier; wire delayed_D, delayed_RESET_B, delayed_CLK;
          {wires}
          not (int_fwire_r, delayed_RESET_B); buf (xcr_0, 0);
          ihp_dff_r (int_fwire_IQ, notifier, delayed_CLK, delayed_D, int_fwire_r, xcr_0);
          buf (Q, int_fwire_IQ);
          {"not (int_fwire_IQN, int_fwire_IQ); buf (Q_N, int_fwire_IQN);" if dual else ""}
          endmodule"""
        require(re.sub(r"\s+", "", body) == re.sub(r"\s+", "", expected), "unreviewed flop body: " + name)
        require(delayed == ["CLK", "D", "RESET_B"], "unreviewed flop references")
    elif name in {"sg13cmos5l_mux2_1", "sg13cmos5l_mux2_2"}:
        expected = f"module {name} (X, A0, A1, S); output X; input A0, A1, S; ihp_mux2 (X, A0, A1, S); endmodule"
        require(not delayed and re.sub(r"\s+", "", body) == re.sub(r"\s+", "", expected),
                "unreviewed mux2 body: " + name)
    elif name == "sg13cmos5l_mux4_1":
        expected = f"module {name} (X, A0, A1, A2, A3, S0, S1); output X; input A0, A1, A2, A3, S0, S1; ihp_mux4 (X, A0, A1, A2, A3, S0, S1); endmodule"
        require(not delayed and re.sub(r"\s+", "", body) == re.sub(r"\s+", "", expected),
                "unreviewed mux4 body: " + name)
    else:
        require(not delayed and not re.search(r"\b(?:reg|always|initial|notifier|ihp_\w+)\b|[$#`\"]", body),
                "unreviewed procedural/delayed cell: " + name)
    return delayed


def verify_models(postdir, manifest, preflight, used, track):
    models = load(track(postdir / "replay-models.json"))
    require(models["scope"] == "zero_delay_gate_functional", "unsupported model scope")
    retained = models["retained_hashes"]
    require(set(retained) == {"model-0.v", "model-1.v", "model-2.v", "stdcell-vendor.v", "stdcell-functional.v"},
            "unexpected retained model closure")
    for name, digest in retained.items():
        require(sha(track(inside(postdir, name))) == digest, "retained model changed: " + name)
    expected_models = [str((postdir / name).resolve()) for name in
                       ("model-0.v", "model-1.v", "model-2.v", "stdcell-functional.v")]
    require(models["models"] == expected_models, "provider executable model closure differs")
    refs = preflight["references"]
    recorded = {}
    for reference in refs:
        if "path" in reference:
            path = str(Path(reference["path"]).resolve())
            require(path not in recorded or recorded[path] == reference["sha256"], "conflicting preflight source identity")
            recorded[path] = reference["sha256"]
    sources = models["source_hashes"]
    require(len(sources) == 4, "four original model sources required")
    contract = manifest["macro_contract"]["implementation_simulation"]
    require(contract["defines"] == ["FUNCTIONAL"] and len(contract["models"]) == 2,
            "vendor functional contract required")
    vendor_refs = []
    for ref in contract["models"]:
        matches = [r for r in refs if r.get("reference") == ref]
        # Functional and timed collateral legitimately reference the same stock
        # file. Require one physical identity and an explicit functional role.
        identities = {(str(Path(r["path"]).resolve()), r["sha256"]) for r in matches}
        functional_refs = [r for r in matches if r.get("role") == "macro:Simulation_model"]
        require(len(identities) == 1 and len(functional_refs) == 1, "unique functional preflight model identity required")
        vendor_refs.append(functional_refs[0])
    for i, reference in enumerate(vendor_refs):
        require(sources.get(str(Path(reference["path"]).resolve())) == reference["sha256"] == retained[f"model-{i}.v"],
                "macro source/reference/snapshot mismatch")
    # Existing PT3b locked vendor wrapper/core identities, independently of receipt sealing.
    harness = load_harness()
    require({ref: retained[f"model-{i}.v"] for i, ref in enumerate(contract["models"])} == harness.MODEL_HASHES,
            "vendor macro model drift")
    for source, digest in sources.items():
        require(recorded.get(str(Path(source).resolve())) == digest == sha(track(Path(source))),
                "original model not bound by preflight")
    vendor_paths = [p for p in sources if Path(p).name == "sg13cmos5l_stdcell.v"]
    udp_paths = [p for p in sources if Path(p).name == "sg13cmos5l_udp.v"]
    require(len(vendor_paths) == len(udp_paths) == 1, "stock cell/UDP source required")
    require(sources[vendor_paths[0]] == models["vendor_sha256"] == retained["stdcell-vendor.v"]
            and sources[udp_paths[0]] == retained["model-2.v"], "cell/UDP source snapshots differ")
    vendor = (postdir / "stdcell-vendor.v").read_text()
    transformed = [vendor[:vendor.index("// type:")] if "// type:" in vendor else "",
                   "`timescale 1ns/1ps\n// Reviewed zero-delay functional view; not SDF/timing evidence.\n"]
    require(sorted(models["adaptations"]) == used, "not the exact final-used-cell set")
    review = {}
    for name in used:
        matches = re.findall(r"\bmodule\s+" + re.escape(name) + r"\s*\(.*?\bendmodule", vendor, re.S)
        require(len(matches) == 1, "unknown/nonunique vendor cell: " + name)
        module = matches[0]
        delayed = reviewed_cell(name, module)
        require(models["adaptations"][name] == delayed, "adaptation receipt differs: " + name)
        # Mirror the macro provider's canonical derivation, after independent body review.
        body = re.sub(r"\bspecify\b.*?\bendspecify\b", "", module, flags=re.S)
        bypass = "\n".join("assign delayed_" + pin + " = " + pin + ";" for pin in delayed)
        transformed.append(body.replace("endmodule", bypass + "\nendmodule"))
        review[name] = {"module_sha256": hashlib.sha256(module.encode()).hexdigest(), "delayed_pins": delayed}
    require((postdir / "stdcell-functional.v").read_text() == "\n".join(transformed)
            and sha(postdir / "stdcell-functional.v") == models["functional_sha256"],
            "noncanonical/unreviewed standard-cell derivation")
    return [postdir / Path(p).name for p in expected_models], review


def load_harness():
    spec = importlib.util.spec_from_file_location("pt3b_replay", HERE.parent / "functional/check_functional.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def audit_run_inputs(bundle, runroot, *, allow_failed=False):
    """Read-only input binding; allowing a failed run never grants acceptance."""
    watched = {}

    def track(path):
        path = Path(path).resolve(strict=True)
        digest = sha(path)
        require(str(path) not in watched or watched[str(path)] == digest, "input changed during audit")
        watched[str(path)] = digest
        return path

    track(Path(__file__))
    track(HERE.parent / "functional/check_functional.py")
    manifest = load(track(bundle / "manifest.json"))
    payload = {k: v for k, v in manifest.items() if k != "identity"}
    require(hashlib.sha256(json.dumps(payload, separators=(",", ":"), ensure_ascii=False).encode()).hexdigest()
            == manifest["identity"], "bundle identity mismatch")
    require(manifest["top_module"] == TOP and manifest["project"] == "electrum_loader"
            and manifest["operation"] == "Hardening" and manifest["target"]["technology"] == "ihp-sg13cmos5l",
            "implemented macro loader bundle required")
    files = manifest["files"]
    require(len({f["path"] for f in files}) == len(files), "duplicate bundle inventory")
    for item in files:
        source = track(inside(bundle, item["path"]))
        require(sha(source) == item["sha256"], "bundle input changed")
        staged = track(inside(runroot / "project", item["path"]))
        require(sha(staged) == item["sha256"], "staged input differs from bundle")
    for item in manifest["source_inputs"]:
        require(sha(track(inside(bundle, item.get("copy", "inputs/" + item["path"])))) == item["sha256"],
                "source snapshot differs")
    require(len(manifest["synthesis_sources"]) == 1 and len(manifest["simulation_sources"]) == 1
            and not set(manifest["synthesis_sources"]) & set(manifest["simulation_sources"]), "source roles overlap")
    require(not set(manifest["synthesis_sources"]) & set(manifest["macro_contract"].get("blackbox_sources", [])),
            "stub selected as emitted implementation")
    macros = manifest["macro_contract"]["macros"]
    require(len(macros) == 1 and macros[0]["resource"] == "program" and macros[0]["module"] == MACRO,
            "one declared program macro required")
    run = load(track(runroot / "run.json"))
    staged_manifest = track(runroot / "project/manifest.json")
    require(sha(staged_manifest) == sha(bundle / "manifest.json") == run["manifest_sha256"]
            and run["build_identity"] == manifest["identity"], "run/staged/bundle association differs")
    completed = run["status"] == "completed" and run["requested_stage"] == run["completed_stage"] == "full"
    failed = run["status"] == "failed" and run["requested_stage"] == "full" and run["completed_stage"] is None
    require(completed or (allow_failed and failed), "completed public full run required (or explicit failed-run snapshot scope)")
    preflight = load(track(runroot / "preflight.json"))
    require(preflight["ready"] is True and not preflight["issues"], "preflight not ready")
    final = runroot / "project/runs/asic/final"
    netlist, gds = track(final / "nl" / (TOP + ".nl.v")), track(final / "gds" / (TOP + ".gds"))
    instance, used = final_instances(netlist.read_text())
    require(instance == macros[0]["instance"], "final macro differs from declared program instance")
    return watched, track, manifest, run, preflight, netlist, gds, instance, used


def audit(bundle, runroot, postdir, prepared):
    """Public-success audit; failed-run snapshots have a separate entry point."""
    watched, track, manifest, run, preflight, netlist, gds, instance, used = audit_run_inputs(bundle, runroot)
    final = runroot / "project/runs/asic/final"
    postdir = postdir.resolve(strict=True)
    require(postdir.parent == (runroot / "checks").resolve(), "postcheck outside selected run")
    post = load(track(postdir / "postcheck.json"))
    require(post["status"] == "completed" and post["checks"] == {"precheck": "pass", "gate_level": "pass"}
            and post["run_id"] == run["run_id"] and post["build_identity"] == manifest["identity"],
            "postcheck failed/stale/wrong run")
    require(post["tools"]["replay_scope"] == SCOPE, "unsupported postcheck scope")
    for name, digest in post["artifacts"].items():
        require(sha(track(inside(postdir, name))) == digest, "postcheck artifact changed: " + name)
    for key, path in (("netlist_sha256", netlist), ("gds_sha256", gds),
                      ("testbench_sha256", track(postdir / "testbench.v"))):
        require(post["inputs"][key] == sha(path), "postcheck input association: " + key)
    require(post["inputs"]["testbench_top"] == "p3_loader_tb", "wrong postcheck top")
    helper = track(postdir / "physical-runtime.py")
    require(sha(helper) == post["inputs"]["physical_runtime_sha256"]
            == sha(track(runroot / "project/physical-runtime.py")) == run["physical_checker_sha256"],
            "postcheck/run runtime association differs")
    prep = load(track(prepared / "prepare.json"))
    original_bench = track(BENCH)
    testbench = track(prepared / "testbench.v")
    require(prep["clock_period_ns"] == PERIOD and prep["instance"] == instance
            and prep["authored_bench_sha256"] == sha(original_bench)
            and prep["testbench_sha256"] == sha(testbench) == post["inputs"]["testbench_sha256"]
            and testbench.read_text() == gate_bench(original_bench.read_text(), instance),
            "retained gate bench differs from prepared exact system oracle")
    require(prep["netlist_sha256"] in (None, sha(netlist)), "prepared against another netlist")
    models, review = verify_models(postdir, manifest, preflight, used, track)
    # Verify what actually appeared on the provider compile command, not merely
    # that suitable model files happen to be retained alongside it.
    commands = [p["argv"] for p in post["processes"]]
    compiles = [c[c.index("iverilog") + 1:] for c in commands if "iverilog" in c and "-o" in c]
    require(len(compiles) == 1, "unique provider compile required")
    compile_args = compiles[0]
    expected_sources = [str(p.resolve()) for p in [*models, netlist, postdir / "testbench.v"]]
    require(compile_args[:4] == ["-g2012", "-DFUNCTIONAL", "-DSIM", "-s"]
            and compile_args[4:6] == ["p3_loader_tb", "-o"]
            and compile_args[7:] == expected_sources, "provider compile closure/flags differ")
    executable = compile_args[6]
    require(Path(executable).resolve() == postdir / "gate.out", "provider executable outside postcheck")
    require(any(c[c.index("vvp") + 1:] == [executable] for c in commands if "vvp" in c),
            "provider did not replay compiled artifact")
    results = post["process_results"]
    require(len(results) == len(commands) and results and all(
        r["outcome"] == "exited" and r["code_or_ocaml_signal"] == 0 and r["succeeded"] is True for r in results),
        "provider process failure/timeout")
    logs = set(post["logs"])
    for process in post["processes"]:
        logs.update((process["stdout"], process["stderr"]))
    for name in logs | set(post["reports"]):
        track(inside(postdir, name))
    # Select simulation stdout only: do not duplicate a shared stdout/stderr log.
    sim = [p for p in post["processes"] if "vvp" in p["argv"] and p["argv"][p["argv"].index("vvp") + 1:] == [executable]]
    require(len(sim) == 1, "unique provider simulation required")
    output = inside(postdir, sim[0]["stdout"]).read_text()
    acceptance = check_positive(output)
    # Retain available outcomes verbatim; functional acceptance does not turn
    # these into a physical/timing signoff decision.
    outcomes = {}
    for name, path in (("metrics", final / "metrics.json"),
                       ("physical_checks", runroot / "physical-checks.json")):
        outcomes[name] = {"path": str(track(path)), "sha256": sha(path)} if path.is_file() else "not_supplied"
    require(all(sha(p) == digest for p, digest in watched.items()), "input changed during audit")
    return {"schema_version": 1, "status": "audited", "scope": SCOPE,
            "physical_signoff": "not_assessed", "timing_constraints": "provisional; separately reviewed",
            "run_id": run["run_id"], "bundle_identity": manifest["identity"], "instance": instance,
            "retained_outcomes": outcomes,
            "clock_precision_note": "20.833333 ns requested; bench 1 ps precision rounds each half-cycle",
            "clock_period_ns": PERIOD, "cell_review": review, "provider_positive": acceptance,
            "inputs": watched, "sources": [str(p.resolve()) for p in [*models, netlist, testbench]],
            "negative_oracle": "pending separate replay allocation"}


def check_positive(output):
    harness = load_harness()
    observations = harness.check_oracle(output, 0, "loader")
    result = harness.check_loader(output, observations, "exact")
    phases = re.findall(r"^PT3B PHASE pending-cancel fetch=([01]) reset=([01]) read_edges=1$", output, re.M)
    require(phases == [("0", "0"), ("0", "1"), ("1", "0"), ("1", "1")], "pending-read witnesses missing")
    return result


def check_negative(output, code):
    load_harness().check_oracle(output, code, "loader", negative=True)
    require(code == 1 and len(re.findall(r"^FATAL:", output, re.M)) == 1
            and len(re.findall(r"^FATAL: .*response word got=1234 expected=1235$", output, re.M)) == 1,
            "unrelated negative failure")


def replay(record, output):
    """Allocated action only: serial host Icarus, one CPU, same binary +/- oracle."""
    require(all(sha(p) == digest for p, digest in record["inputs"].items()), "audited input changed")
    if hasattr(os, "sched_getaffinity"):
        os.sched_setaffinity(0, [min(os.sched_getaffinity(0))])
    for key in ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "NUMEXPR_NUM_THREADS"):
        os.environ[key] = "1"
    harness = load_harness()
    evidence = harness.Evidence(output, ROOT)
    evidence.record = {**record, "status": "running", "commands": [], "budget": "bounded1; serial children",
                       "phase": "snapshot",
                       "negative_check": "expected comparison flip; not DUT fault injection"}
    evidence.save()
    try:
        # Retain all bound association evidence as well as portable executable inputs.
        snapshots = {}
        for i, (path, digest) in enumerate(record["inputs"].items()):
            snapshot, actual = evidence.snapshot(Path(path), f"inputs/{i:04d}-{Path(path).name}")
            require(actual == digest, "input changed while snapshotting")
            snapshots[path] = str(snapshot)
        sources = [snapshots[p] for p in record["sources"]]
        evidence.record["portable_sources"] = [str(Path(p).relative_to(output)) for p in sources]
        tools = {tool: shutil.which(tool) for tool in ("iverilog", "vvp")}
        require(all(tools.values()), "host Icarus tools missing")
        evidence.record["phase"] = "tool_versions"
        for tool, executable in tools.items():
            evidence.run([executable, "-V"])
        executable = output / "loader.vvp"
        evidence.record["phase"] = "compile"
        evidence.run([tools["iverilog"], "-g2012", "-Wall", "-DFUNCTIONAL", "-DSIM", "-s", "p3_loader_tb",
                      "-o", executable, *sources])
        binary_hash = sha(executable)
        evidence.record["phase"] = "positive_oracle"
        code, positive = evidence.run([tools["vvp"], "-N", executable], timeout=300, success=False)
        harness.check_oracle(positive, code, "loader")
        evidence.record["acceptance"] = check_positive(positive)
        evidence.record["phase"] = "negative_oracle"
        code, negative = evidence.run([tools["vvp"], "-N", executable, "+PT3B_EXPECT_MISMATCH"],
                                      timeout=300, success=False)
        # The checked readback is the only accepted negative failure class.
        check_negative(negative, code)
        evidence.record["phase"] = "input_stability"
        require(sha(executable) == binary_hash, "compiled artifact changed between oracle runs")
        require(all(sha(p) == digest for p, digest in record["inputs"].items()), "input changed during replay")
        require(all(sha(snapshot) == record["inputs"][original] for original, snapshot in snapshots.items()),
                "retained snapshot changed during replay")
        evidence.record.update(status="passed", executable_sha256=binary_hash,
                               phase="complete",
                               negative_oracle="passed; same compiled artifact, expected comparison flip")
    except BaseException as error:
        evidence.record.update(status="failed", error=f"{type(error).__name__}: {error}")
        raise
    finally:
        evidence.record["sha256"] = {k: v for k, v in harness.inventory(output).items() if k != "receipt.json"}
        evidence.save()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    prep = sub.add_parser("prepare", help="no tools; retain a standalone public --testbench")
    prep.add_argument("--output-dir", type=Path, required=True)
    prep.add_argument("--instance", default="hc_resource_7_program")
    prep.add_argument("--netlist", type=Path)
    for name in ("audit", "replay"):
        command = sub.add_parser(name)
        for arg in ("bundle", "run-root", "postcheck", "prepared"):
            command.add_argument("--" + arg, type=Path, required=True)
        command.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    if args.action == "prepare":
        prepare(args.output_dir.resolve(), args.instance, args.netlist)
    else:
        require(not args.output_dir.exists(), "fresh output directory required")
        try:
            record = audit(args.bundle.resolve(), args.run_root.resolve(), args.postcheck.resolve(), args.prepared.resolve())
            if args.action == "replay":
                replay(record, args.output_dir.resolve())
            else:
                args.output_dir.mkdir(parents=True, exist_ok=False)
                write(args.output_dir / "audit.json", record)
        except BaseException as error:
            if not args.output_dir.exists():
                args.output_dir.mkdir(parents=True)
                write(args.output_dir / "receipt.json", {"status": "failed", "scope": SCOPE,
                      "phase": "association_audit", "error": f"{type(error).__name__}: {error}"})
            raise
    print(f"PT3c {args.action}: {args.output_dir}")


if __name__ == "__main__":
    main()
