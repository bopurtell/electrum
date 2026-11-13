#!/usr/bin/env python3
"""Explicit serial producer; requires prebuilt emitters and host Icarus.

Interface for the FS2 owner (no builds, provisioning, Docker or discovery):
  python3 -B asic/verif/workloads/produce_event_response.py \
    --selection flops|exact --output NEWDIR --pdk PDK_ROOT
Optional --mode behavioral is a separate baseline, never Exact implementation.
Artifacts: result.json (Electrum schema), capture.json, reference.json, per-phase
raw.trace + waveform.vcd, emitted top.v/inventory, source/tool/model snapshots.
All execution is opt-in via main(); importing pure readers launches nothing.
"""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys

import event_response as oracle

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MACRO = "RM_IHPSG13_1P_256x16_c2_bm_bist"
MODELS = {
    MACRO + ".v": "645c475787b077da4dbd15856c68bbae46aa9846a155239eb895ed2de7511053",
    "RM_IHPSG13_1P_core_behavioral_bm_bist.v":
        "d0a6258f8e9c93d1d5b1f78c0a1d66f30d28b1ad8037e5e07f53d1a4e3670b12",
}
SYSTEM_BOUNDARY = "core+Program_memory"
COMPOSITION = {"system_boundary": SYSTEM_BOUNDARY, "top_module": "electrum_event_response",
               "core": "Electrum_core.Emulator_core", "memory": "Electrum_asic_rtl.Program_memory",
               "host_transport": "direct-control-port", "host_link": False,
               "package_wrapper": False, "program_depth": 256, "program_width": 16,
               "read_latency_edges": 1}
# This is NOT the installer's electrum-loader/fixed-loader-v1 Hardware_variant.
# It identifies this verification composition, separately from resource policy.
ASSIGNMENT = {"design": "electrum-event-response-core-program-memory-v1",
              "system_boundary": SYSTEM_BOUNDARY, "host_transport": "direct-control-port",
              "host_link": False, "package_wrapper": False, "program_depth": 256,
              "program_width": 16, "read_latency_edges": 1, "isa": "current-word16",
              "cores": 1, "shift_lanes": 1}
CONTROLS = {"adapter": "electrum.event-response-emitted-v1", "clock_period_ns": 10,
            "sampling": oracle.CONTRACT["sampling"], "capture_edges": 48,
            "model_semantics": "digital-functional-latency1-no-initial-RAM-assumptions"}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, allow_nan=False) + "\n")


def number(text):
    oracle.require(re.fullmatch(r"[0-9]+", text) is not None, "unknown/noninteger trace value")
    return int(text)


def bit(text):
    oracle.require(text in ("0", "1"), "unknown/nonboolean trace value")
    return text == "1"


def parse_trace(text, phase):
    """Strict raw pre/post replay, including real RAM traffic and setup witness.

    Pre-edge reset-0 events and disabled memory operands are undefined and not
    compared. Their original four-state text remains in the retained raw trace.
    The bench asserts live acceptance, readback values and final image validity.
    """
    lines = text.splitlines()
    oracle.require(len(lines) == 97, "incomplete or extra raw trace rows")
    rows, accesses, counters = [], [], None
    for edge in range(48):
        pre, post = lines[2*edge].split(), lines[2*edge+1].split()
        oracle.require(len(pre) == 10 and pre[0] == "PRE" and number(pre[1]) == edge,
                       "invalid PRE order/shape")
        oracle.require(len(post) == 20 and post[0] == "POST" and number(post[1]) == edge,
                       "invalid POST order/shape")
        oracle.require(number(pre[2]) == (5+10*edge)*1000 and
                       number(post[2]) == (6+10*edge)*1000, "raw sample timestamp changed")
        decision, request = (False, False) if edge == 0 else (bit(pre[3]), bit(pre[4]))
        expected_acceptance = (32 if edge == 1 else 16 if edge == 2 else
            8 if 3 <= edge <= 8 else 4 if edge in range(9, 20, 2) else
            2 if edge == 21 else 1 if edge == 22 else 0)
        oracle.require(re.fullmatch(r"[01]{6}", pre[9]) is not None and
                       int(pre[9], 2) == expected_acceptance, "control-port acceptance differs")
        response = bit(post[12])
        oracle.require(response == (edge in range(10, 21, 2)), "readback response timing differs")
        if response:
            oracle.require(number(post[13]) == oracle.CONTRACT["image_words"][(edge-10)//2]
                           and bit(post[14]), "verified readback differs")
        if edge >= 21:
            oracle.require(bit(post[15]) and list(map(number, post[16:19])) == [6, 6, 6],
                           "completed image validity/counts differ")
        oracle.require(number(post[19]) == (0 if edge == 0 else 1), "software claim differs")
        if edge > 0 and bit(pre[5]):
            write, address = bit(pre[6]), number(pre[7])
            oracle.require(address < 256, "RAM address out of bounds")
            accesses.append({"edge": edge, "write": write, "address": address,
                             "data": number(pre[8]) if write else None})
        rows.append({"edge": edge, "armed": bit(post[3]), "synchronized": bit(post[4]),
                     "decision": decision, "bank_request": request,
                     "pins": number(post[5]), "oe": number(post[6]),
                     "normal_halt": bit(post[7]), "fault": bit(post[8])})
        counters = dict(zip(("fetch_cycles", "instructions", "extension_fetches"),
                            map(number, post[9:12])))
    done = lines[-1].split()
    oracle.require(len(done) == 3 and done[:2] == ["DONE", str(phase)], "missing phase completion")
    external = int(done[2])
    writes = [a for a in accesses if a["write"]]
    oracle.require([(a["edge"], a["address"], a["data"]) for a in writes] ==
                   [(3+i, i, word) for i, word in enumerate(oracle.CONTRACT["image_words"])],
                   "RAM load traffic differs from exact image")
    reads = [a for a in accesses if not a["write"]]
    oracle.require([(a["edge"], a["address"]) for a in reads[:6]] ==
                   [(9+2*i, i) for i in range(6)], "verification RAM traffic differs")
    if phase >= 0:
        oracle.require(all(a["edge"] > 22 for a in reads[6:]), "execution read before accepted RUN")
        oracle.require([a["address"] for a in reads[6:]] == list(range(6)),
                       "instruction/extension fetch address sequence differs")
        oracle.require(counters["instructions"] == 4 and counters["extension_fetches"] == 2,
                       "program did not retire four instructions/two extensions")
        # Execution_unit counts accepted fetches; the controller maps each to
        # this RAM read port. Retain both observations, never assume a counter.
        oracle.require(counters["fetch_cycles"] == len(reads[6:]),
                       "execution fetch counter disagrees with observed RAM reads")
    else:
        oracle.require(external == -1 and not any(r["pins"] or r["normal_halt"] for r in rows),
                       "calibration unexpectedly completed")
        oracle.require(any(r["armed"] for r in rows) and rows[-1]["armed"], "calibration wait not armed")
    return {"phase": phase, "external_tick": external, "samples": rows}, {
        "ram_reads": len(reads), "ram_writes": len(writes), "counters": counters,
        "execution_reads": reads[6:],
        "execution_read_observation": "pre-edge prog_mem_enable_o && !prog_mem_write_enable_o after RUN"}


def check_reference(value):
    oracle.require(value == {"schema": "electrum.event-response-reference", "version": 1,
        "halted": True, "image_words": oracle.CONTRACT["image_words"],
        "pin0_wave": "zz00000000111", "cycles": 13, "fetch_cycles": 6,
        "instructions": 4, "extension_fetches": 2}, "independent model scenario differs")
    return {"functional_equivalence": "same assembled image; driven low then high; normal halt",
            "schedule_comparison": "not compared: independent model has its own stimulus schedule"}


class Producer:
    def __init__(self, output, timeout):
        self.output, self.timeout, self.commands = output, timeout, []

    def run(self, argv, cwd):
        index = len(self.commands)
        entry = {"argv": [str(x) for x in argv], "cwd": str(cwd),
                 "timeout_seconds": self.timeout, "status": "running"}
        self.commands.append(entry)
        write_json(self.output / "commands.json", self.commands)
        with (self.output / f"command-{index:03d}.stdout").open("wb") as out, \
             (self.output / f"command-{index:03d}.stderr").open("wb") as err:
            process = subprocess.Popen(entry["argv"], cwd=cwd, stdout=out, stderr=err,
                                       start_new_session=True)
            try:
                code = process.wait(timeout=self.timeout)
            except BaseException:
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.wait()
                entry.update(status="interrupted", exit_code=process.returncode)
                write_json(self.output / "commands.json", self.commands)
                raise
        entry.update(status="completed", exit_code=code)
        write_json(self.output / "commands.json", self.commands)
        oracle.require(code == 0, f"command {index} failed; see retained logs")
        return (self.output / f"command-{index:03d}.stdout").read_text()


def source_paths():
    # Excludes concurrently owned CLI/project/install/docs files. These are
    # observed source bytes, not a compiled-source/P6 attestation.
    roots = [ROOT / p for p in ("ip", "spec/isa", "firmware/examples", "asic/rtl",
                               "asic/verif/workloads", "verif/reference/model")]
    return sorted(p for root in roots for p in root.rglob("*")
                  if p.is_file() and (p.suffix in (".ml", ".mli", ".py", ".v") or p.name == "dune"))


def artifact_inventory(output):
    return [{"path": str(p.relative_to(output)), "bytes": p.stat().st_size,
             "sha256": sha(p.read_bytes())} for p in sorted(output.rglob("*"))
            if p.is_file() and p.name != "result.json"]


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--selection", required=True, choices=("flops", "exact"))
    parser.add_argument("--mode", choices=("behavioral", "implementation"), default="implementation")
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--pdk", required=True, type=Path, help="PDK checkout parent containing ihp-sg13cmos5l")
    parser.add_argument("--emitter", type=Path, default=ROOT / "_build/default/asic/verif/workloads/emit_event_response.exe")
    parser.add_argument("--reference", type=Path, default=ROOT / "_build/default/asic/verif/workloads/reference_event_response.exe")
    parser.add_argument("--timeout", type=int, default=120, help="per serial child, seconds (1..300)")
    args = parser.parse_args(argv)
    oracle.require(1 <= args.timeout <= 300, "timeout must be 1..300")
    output = args.output.resolve()
    oracle.require(not any(output.is_relative_to(ROOT / relative) for relative in
                           ("ip", "spec", "firmware", "asic/rtl", "asic/verif/workloads", "verif/reference")),
                   "output must be outside the observed source directories")
    output.mkdir(exist_ok=False)  # Parent must exist. Never reuse/overwrite evidence.
    producer = Producer(output, args.timeout)
    result = {"schema": "electrum.event-response-result", "version": 1, "status": "running",
              "created_utc": datetime.now(timezone.utc).isoformat(), "selection": args.selection,
              "source_role": args.mode, "hardware_assignment": ASSIGNMENT,
              "system_boundary": SYSTEM_BOUNDARY, "composition": COMPOSITION,
              "hardware_assignment_identity": sha(oracle.canonical(ASSIGNMENT)),
              "loader_project_variant_identity": None,
              "controls": CONTROLS, "measurements": None, "asic_workload_result": False,
              "scope": "verification-only production core+RAM; not TT package or physical evidence"}
    write_json(output / "result.json", result)
    def interrupted(_signum, _frame):
        raise KeyboardInterrupt("producer terminated")
    previous_term = signal.signal(signal.SIGTERM, interrupted)
    try:
        sources = {str(p.relative_to(ROOT)): p.read_bytes() for p in source_paths()}
        for relative, data in sources.items():
            dest = output / "sources" / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(data)
        tools = {}
        for name, path in (("emitter", args.emitter), ("reference", args.reference),
                           ("iverilog", Path(shutil.which("iverilog") or "/missing-iverilog")),
                           ("vvp", Path(shutil.which("vvp") or "/missing-vvp"))):
            resolved = path.resolve(strict=True)
            dest = output / "tools" / name
            dest.parent.mkdir(exist_ok=True)
            shutil.copyfile(resolved, dest)
            tools[name] = {"path": str(resolved), "sha256": sha(resolved.read_bytes())}
        result["tools"] = tools
        result["compiled_source_consistency"] = "not established; retained source observations only"
        emitted = output / "emitted"
        emitted.mkdir()
        producer.run([tools["emitter"]["path"], args.selection, args.mode, emitted], output)
        oracle.require(json.loads((emitted / "composition.json").read_text()) == COMPOSITION,
                       "emitted verification composition differs")
        rtl = emitted / "top.v"
        has_macro = re.search(rf"\b{MACRO}\s+hc_resource_7_program\s*\(", rtl.read_text()) is not None
        exact = args.selection == "exact" and args.mode == "implementation"
        oracle.require(has_macro == exact, "emitted RAM linkage disagrees with actual role")
        models = []
        if exact:
            pdk = args.pdk.resolve(strict=True)
            for name, expected in MODELS.items():
                path = (pdk / "ihp-sg13cmos5l/libs.ref/sg13cmos5l_sram/verilog" / name).resolve(strict=True)
                oracle.require(path.is_relative_to(pdk), "model escapes PDK checkout")
                data = path.read_bytes()
                oracle.require(sha(data) == expected, f"vendor functional model drift: {name}")
                dest = output / "models" / name
                dest.parent.mkdir(exist_ok=True)
                dest.write_bytes(data)
                models.append(dest)
        write_json(output / "workload.json", oracle.workload())
        bench = output / "sources/asic/verif/workloads/event_response_tb.v"
        executable = output / "simulation.vvp"
        producer.run([tools["iverilog"]["path"], "-g2012", "-s", "event_response_tb",
                      *( ["-DFUNCTIONAL"] if exact else []), "-o", executable, rtl, bench, *models], output)
        reference_text = producer.run([tools["reference"]["path"]], output)
        reference = json.loads(reference_text)
        result["reference_check"] = check_reference(reference)
        write_json(output / "reference.json", reference)
        phases, traffic, calibration_armed = [], [], None
        for phase in range(-1, 10):
            directory = output / ("calibration" if phase < 0 else f"phase-{phase}")
            directory.mkdir()
            stdout = producer.run([tools["vvp"]["path"], executable, f"+PHASE={phase}",
                f"+TRACE={directory / 'raw.trace'}", f"+VCD={directory / 'waveform.vcd'}"], directory)
            oracle.require(re.findall(r"^EVENT_RESPONSE PASS phase=(-?[0-9]+)$", stdout, re.M) == [str(phase)],
                           "missing unique simulation completion")
            run, counts = parse_trace((directory / "raw.trace").read_text(), phase)
            armed = next(i for i, row in enumerate(run["samples"]) if row["armed"])
            if phase < 0:
                calibration_armed = armed
            else:
                oracle.require(armed == calibration_armed, "armed edge differs from calibration")
            wave = directory / "waveform.vcd"
            oracle.require(wave.stat().st_size > 0 and "$enddefinitions" in wave.read_text(), "missing actual VCD")
            from event_evidence import check_waveform
            check_waveform(wave.read_text(), (directory / "raw.trace").read_text())
            if phase >= 0:
                phases.append(run)
                traffic.append({"phase": phase, **counts})
        capture = {"schema": "electrum.event-response-capture", "version": 1,
                   "status": "completed", "workload": oracle.workload(), "phases": phases}
        write_json(output / "capture.json", capture)
        measurements = oracle.check_capture(capture)
        for relative, before in sources.items():
            oracle.require((ROOT / relative).read_bytes() == before, f"source changed during run: {relative}")
        for tool in tools.values():
            oracle.require(sha(Path(tool["path"]).read_bytes()) == tool["sha256"], "tool changed during run")
        result.update(status="completed", functional_verification="passed",
                      measurements=measurements, traffic=traffic)
    except BaseException as error:
        result.update(status="interrupted" if isinstance(error, (KeyboardInterrupt, SystemExit)) else "failed",
                      diagnostic=str(error), measurements=None, functional_verification="not_passed")
        raise
    finally:
        try:
            result["artifacts"] = artifact_inventory(output)
            write_json(output / "result.json", result)
        finally:
            signal.signal(signal.SIGTERM, previous_term)
    print(str(output / "result.json"))


if __name__ == "__main__":
    main()
