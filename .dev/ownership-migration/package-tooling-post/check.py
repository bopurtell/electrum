"""Bounded migration evidence; uses the installed ASIC API and shared build lock."""
import datetime
import fcntl
import hashlib
import importlib.util
import json
import pathlib
import subprocess
import sys
import time

OUT = pathlib.Path(__file__).resolve().parent
ROOT = OUT.parents[2]
BASE = OUT.parent / "20261111-b3a4cb6-baseline"
DUNE = ["opam", "exec", "--switch=5.2.0+ox", "--", "dune"]


def write(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(name, argv):
    start = time.monotonic()
    with (OUT / "logs" / (name + ".log")).open("w") as log:
        result = subprocess.run(argv, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
    record = dict(name=name, argv=argv, exit=result.returncode,
                  seconds=round(time.monotonic() - start, 3))
    with (OUT / "commands.jsonl").open("a") as stream:
        stream.write(json.dumps(record) + "\n")
    print(name, result.returncode, flush=True)
    return result.returncode


def compare_bundle(kind, *, run_tools=True):
    before = BASE / "bundles" / kind
    after = OUT / "bundles" / kind
    old = json.loads((before / "manifest.json").read_text())
    new = json.loads((after / "manifest.json").read_text())
    spec = importlib.util.spec_from_file_location(
        "checker", ROOT / "tinytapeout/scripts/check-adopted-bundle.py")
    checker = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(checker)
    checker.check_bundle(ROOT, after, kind)
    fields = ["top_module", "project", "requested_tools", "synthesis_sources",
              "simulation_sources", "resources", "simulation_resources"]
    result = dict(identity_before=old["identity"], identity_after=new["identity"],
                  manifest_fields_equal={k: old[k] == new[k] for k in fields},
                  input_paths_before=[x["path"] for x in old["source_inputs"]],
                  input_paths_after=[x["path"] for x in new["source_inputs"]])
    result["rtl"] = {}
    for role, key in [("synthesis", "synthesis_sources"), ("simulation", "simulation_sources")]:
        a, b = before / old[key][0], after / new[key][0]
        result["rtl"][role] = dict(byte_equal=a.read_bytes() == b.read_bytes(),
                                    before_sha256=digest(a), after_sha256=digest(b))
        if not run_tools:
            continue
        top = new["top_module"]
        stats = OUT / ("synth-" + kind + "-" + role + ".json")
        run("synth-" + kind + "-" + role,
            ["yosys", "-p", f"read_verilog {b}; hierarchy -check -top {top}; synth -top {top}; tee -o {stats} stat -json"])
        baseline_stats = json.loads((BASE / stats.name).read_text())
        current_stats = json.loads(stats.read_text())
        result["rtl"][role]["design_statistics_equal"] = (
            baseline_stats["design"] == current_stats["design"])
        if kind != "loader":
            bench = ROOT / "chip_top/verif" / kind / "emitted" / (
                "tb.v" if kind == "observable" else "p0_memory_tb.v")
            exe = OUT / (kind + "-" + role)
            if run("compile-" + kind + "-" + role,
                   ["iverilog", "-g2012", "-Wall", "-Wno-timescale", "-s", "tb",
                    "-o", str(exe), str(b), str(bench)]) == 0:
                run("simulate-" + kind + "-" + role, ["vvp", str(exe)])
    result["collateral_byte_equal"] = {
        str(p.relative_to(before)): p.read_bytes() == (after / p.relative_to(before)).read_bytes()
        for folder in ["constraints", "src"] for p in (before / folder).rglob("*")
        if p.is_file() and p.suffix != ".v"}
    result["collateral_byte_equal"]["info.yaml"] = (
        (before / "info.yaml").read_bytes() == (after / "info.yaml").read_bytes())
    return result


def checks():
    for directory in ["logs", "generated", "bundles"]:
        (OUT / directory).mkdir(exist_ok=True)
    with open("/home/wayne/devel/jane/.protemu-build.lock", "a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        run("build-install-lint", DUNE + ["build", "@install", "@lint", "-j5"])
        run("ordinary-runtest", DUNE + ["runtest", "--force", "-j5"])
        generated = OUT / "generated"
        run("generate-observable", DUNE + ["exec", "-j5", "bin/generate.exe", "--",
            "-output", str(generated / "p0_observable.v"), "-module-name", "p0_observable"])
        for mode in ["access", "executable", "integrated", "loader"]:
            run("generate-core-" + mode, DUNE + ["exec", "-j5", "bin/generate_core.exe",
                "--", mode, str(generated / (mode + ".v"))])
        for mode in ["pin_bank", "input_events", "timing", "byte_fifo_8", "shift_lane",
                     "observed_transfer", "observed_transfer_bank", "primitive_demo", "uart_tx", "uart_slice"]:
            run("generate-p2-" + mode, DUNE + ["exec", "-j5", "bin/generate_p2.exe",
                "--", mode, str(generated / (mode + ".v"))])
        for role in ["simulation", "implementation"]:
            run("generate-backend-" + role, DUNE + ["exec", "-j5",
                "ip/program_memory_controller/verif/backend_integration/emit_program_memory_backend.exe",
                "--", role, str(generated / ("program_memory_backend." + role + ".v"))])
        write("generated-comparison.json", {
            p.name: dict(byte_equal=p.read_bytes() == (generated / p.name).read_bytes(),
                         before_sha256=digest(p), after_sha256=digest(generated / p.name))
            for p in (BASE / "generated").iterdir()})
        bundles = {}
        for kind in ["observable", "memory", "loader"]:
            run("bundle-" + kind, DUNE + ["exec", "-j5", "bin/asic_bundle.exe", "--",
                kind, str(OUT / "bundles" / kind), str(ROOT)])
            run("check-bundle-" + kind, ["python3", "-B",
                "tinytapeout/scripts/check-adopted-bundle.py", "--kind", kind, "--metadata-only"])
            bundles[kind] = compare_bundle(kind)
        write("bundle-comparison.json", bundles)
        benches = {
            "p2_uart_tb.v": "ip/mechanisms/verif/staging/emitted",
            "p2_uart_slice_tb.v": "ip/mechanisms/verif/staging/emitted",
            "p3_control_tb.v": "ip/emulator_core/verif/emitted",
            "p3_integration_tb.v": "ip/emulator_core/verif/emitted",
            "p3_memory_backend_tb.v": "ip/program_memory_controller/verif/backend_integration/emitted",
            "tb.v": "chip_top/verif/observable/emitted",
            "p0_memory_tb.v": "chip_top/verif/memory/emitted",
            "p3_loader_tb.v": "verif/system/emitted",
        }
        snapshot = {x["path"]: x for x in json.loads((BASE / "source-snapshot.json").read_text())}
        write("bench-path-map.json", {
            "tinytapeout/test/" + name: dict(destination=dest + "/" + name,
                byte_equal=snapshot["tinytapeout/test/" + name]["sha256"] == digest(ROOT / dest / name))
            for name, dest in benches.items()})
        run("rtl", DUNE + ["build", "@rtl", "--force", "-j5"])
    records = [json.loads(x) for x in (OUT / "commands.jsonl").read_text().splitlines()]
    write("result-summary.json", dict(commands=records, failures=[x for x in records if x["exit"]]))
    (OUT / "complete.txt").write_text(datetime.datetime.now(datetime.timezone.utc).isoformat() + "\n")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "launch":
        with (OUT / "runner.log").open("w") as stream:
            p = subprocess.Popen([sys.executable, "-B", str(__file__)], cwd=ROOT,
                                 stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
        print(p.pid)
    else:
        checks()
