"""Read-only Electrum evidence replay and controlled resource-policy comparison.

Not an ASIC Workload_result adapter. No subprocesses, discovery or publication.
Caller owns stable local parent directories; hashes are consistency checks, not
authenticated execution or proof that observed sources produced installed binaries.
"""

import hashlib
import json
from pathlib import Path, PurePosixPath
import re

import event_response as oracle


def decode_json(data):
    def object_(pairs):
        result = {}
        for key, value in pairs:
            oracle.require(key not in result, f"duplicate JSON field: {key}")
            result[key] = value
        return result
    return json.loads(data, object_pairs_hook=object_)


def check_waveform(text, raw):
    """Replay bounded real VCD values against each raw sample and stimulus time."""
    oracle.require(len(text) <= 8*1024*1024, "VCD too large")
    tokens = text.split()
    names, values, changes, timescale = {}, {}, [], None
    time, i = 0, 0
    while i < len(tokens):
        token = tokens[i]
        if token.startswith("$"):
            if token in ("$dumpvars", "$dumpon", "$dumpoff", "$end"):
                i += 1
                continue
            end = tokens.index("$end", i+1)
            if token == "$timescale":
                timescale = "".join(tokens[i+1:end])
            if token == "$var":
                oracle.require(end-i >= 5, "invalid VCD declaration")
                code, name = tokens[i+3:i+5]
                oracle.require(name not in names or names[name] == code, "ambiguous VCD signal")
                names[name] = code
            i = end+1
            continue
        if token.startswith("#"):
            new_time = int(token[1:])
            oracle.require(time <= new_time <= 500000, "invalid VCD time")
            time = new_time
        elif token[0] in "bB":
            i += 1
            oracle.require(i < len(tokens), "truncated VCD value")
            changes.append((time, tokens[i], token[1:].lower()))
        elif token[0] in "01xXzZ":
            changes.append((time, token[1:], token[0].lower()))
        else:
            raise ValueError("unsupported VCD value")
        i += 1
    oracle.require(timescale == "1ps", "VCD timescale must be 1ps")
    required = ("clock_i", "pin_async_i", "timing_busy_o", "rising_o", "pins_o", "pin_oe_o",
                "normal_halt_o", "execution_fault_o", "fetch_fault_o", "mechanism_kind_o",
                "mechanism_completion_valid_o", "mechanism_request_valid_o", "mechanism_accepted_o",
                "prog_mem_enable_o", "prog_mem_write_enable_o", "prog_mem_address_o", "prog_mem_write_data_o",
                "fetch_cycles_o", "instruction_count_o", "extension_fetches_o")
    oracle.require(all(name in names for name in required), "missing VCD signal")
    rows = raw.splitlines()
    oracle.require(len(rows) == 97, "incomplete raw trace")
    queries = []
    for edge in range(48):
        pre, post = rows[2*edge].split(), rows[2*edge+1].split()
        if edge > 0:
            queries.append((int(pre[2])-1, "pre", pre))
        queries.append((int(post[2]), "post", post))
    cursor, seen_decision = 0, False
    for at, kind, row in queries:
        while cursor < len(changes) and changes[cursor][0] <= at:
            _, code, value = changes[cursor]
            values[code] = value
            cursor += 1

        def value(name):
            bits = values.get(names[name], "x")
            oracle.require(re.fullmatch("[01]+", bits) is not None, f"undefined checked VCD {name}")
            return int(bits, 2)

        if kind == "pre":
            decision = bool(value("mechanism_completion_valid_o") and value("mechanism_kind_o") == 9)
            seen_decision |= decision
            request = bool(seen_decision and value("mechanism_request_valid_o") and
                           value("mechanism_kind_o") == 4 and value("mechanism_accepted_o"))
            oracle.require([int(decision), int(request)] == list(map(int, row[3:5])),
                           "VCD/pre-edge decision mismatch")
            oracle.require(value("clock_i") == 0, "VCD pre-edge clock mismatch")
            enabled = value("prog_mem_enable_o")
            oracle.require(enabled == int(row[5]), "VCD RAM enable mismatch")
            if enabled:
                write = value("prog_mem_write_enable_o")
                oracle.require(write == int(row[6]) and value("prog_mem_address_o") == int(row[7]),
                               "VCD RAM operation/address mismatch")
                if write:
                    oracle.require(value("prog_mem_write_data_o") == int(row[8]), "VCD RAM write data mismatch")
        else:
            actual = [value("timing_busy_o"), (value("rising_o") >> 3) & 1,
                      value("pins_o"), value("pin_oe_o"), value("normal_halt_o"),
                      value("execution_fault_o") | value("fetch_fault_o")]
            oracle.require(actual == list(map(int, row[3:9])), "VCD/post-settle sample mismatch")
            oracle.require(value("clock_i") == 1, "VCD post-edge clock mismatch")
            oracle.require([value(name) for name in ("fetch_cycles_o", "instruction_count_o", "extension_fetches_o")]
                           == list(map(int, row[9:12])), "VCD execution counter mismatch")
    done = rows[-1].split()
    external = int(done[2])
    raw_input_changes = [(at, bits) for at, code, bits in changes if code == names["pin_async_i"]]
    oracle.require(all(re.fullmatch("[01]+", bits) for _, bits in raw_input_changes),
                   "undefined VCD external stimulus")
    input_changes = [(at, int(bits, 2)) for at, bits in raw_input_changes]
    oracle.require(input_changes == ([(0, 0)] if external < 0 else [(0, 0), (external*1000, 8)]),
                   "VCD external stimulus differs")
    return {"scope": "raw sample/value and external-stimulus replay", "samples": 48,
            "timescale": "1ps"}


def inspect(path):
    from produce_event_response import ASSIGNMENT, COMPOSITION, CONTROLS, SYSTEM_BOUNDARY, MACRO, MODELS, check_reference, parse_trace
    path = Path(path)
    oracle.require(not path.is_symlink() and path.is_file(), "invalid result file")
    root = path.parent.resolve()
    raw_result = path.read_bytes()
    oracle.require(len(raw_result) <= 2*1024*1024, "result too large")
    result = decode_json(raw_result)
    oracle.require(result["schema"] == "electrum.event-response-result" and
                   type(result["version"]) is int and result["version"] == 1, "unsupported result")
    oracle.require(result["status"] in ("running", "completed", "failed", "interrupted"), "invalid result status")
    oracle.require(oracle.canonical(result["hardware_assignment"]) == oracle.canonical(ASSIGNMENT)
                   and oracle.canonical(result["controls"]) == oracle.canonical(CONTROLS),
                    "unsupported hardware/measurement contract")
    oracle.require(result["system_boundary"] == SYSTEM_BOUNDARY
                   and oracle.canonical(result["composition"]) == oracle.canonical(COMPOSITION),
                   "unsupported system boundary/composition")
    oracle.require(result["hardware_assignment_identity"] == hashlib.sha256(oracle.canonical(ASSIGNMENT)).hexdigest()
                   and result["loader_project_variant_identity"] is None,
                   "verification assignment is not the loader project variant")
    entries = result["artifacts"]
    oracle.require(type(entries) is list and len(entries) <= 4096, "artifact count limit")
    admitted, total = {}, 0
    for entry in entries:
        relative = entry["path"]
        parts = PurePosixPath(relative)
        oracle.require(relative and str(parts) == relative and not parts.is_absolute() and
                       ".." not in parts.parts and relative not in admitted and relative != "result.json",
                       "unsafe/duplicate artifact path")
        target = root / relative
        oracle.require(all(not p.is_symlink() for p in [target, *target.parents] if p != root.parent),
                       "symlink in evidence")
        oracle.require(target.is_file() and target.stat().st_size <= 64*1024*1024, "invalid artifact size/type")
        data = target.read_bytes()
        total += len(data)
        oracle.require(total <= 256*1024*1024 and len(data) == entry["bytes"] and
                       hashlib.sha256(data).hexdigest() == entry["sha256"], "artifact digest/length mismatch")
        admitted[relative] = data

    def read(relative):
        oracle.require(relative in admitted, f"unbound artifact: {relative}")
        return admitted[relative].decode()

    if result["status"] != "completed":
        oracle.require(result["measurements"] is None, "incomplete result exposes measurements")
        return {"source_digest": hashlib.sha256(raw_result).hexdigest(), "result": result,
                "measurements": None}
    oracle.require(result["functional_verification"] == "passed", "functional verification absent")
    oracle.require(result["selection"] in ("flops", "exact") and
                   result["source_role"] in ("behavioral", "implementation"), "invalid selection/role")
    for tool in ("emitter", "reference", "iverilog", "vvp"):
        data = admitted.get("tools/" + tool)
        oracle.require(data is not None and hashlib.sha256(data).hexdigest() ==
                       result["tools"][tool]["sha256"], "unbound tool identity")
    read("emitted/elaboration.sexp")
    emitted_composition = decode_json(read("emitted/composition.json"))
    oracle.require(oracle.canonical(emitted_composition) == oracle.canonical(COMPOSITION),
                   "emitted composition mismatch")
    rtl = read("emitted/top.v")
    exact = result["selection"] == "exact" and result["source_role"] == "implementation"
    instances = re.findall(rf"\b{MACRO}\s+hc_resource_7_program\s*\(", rtl)
    oracle.require(len(instances) == (1 if exact else 0), "RAM linkage/role mismatch")
    if exact:
        for name, expected in MODELS.items():
            oracle.require(hashlib.sha256(admitted.get("models/"+name, b"")).hexdigest() == expected,
                           "vendor functional model mismatch")
    oracle.require(decode_json(read("workload.json")) == oracle.workload(), "workload artifact differs")
    oracle.require(result["reference_check"] == check_reference(decode_json(read("reference.json"))),
                   "reference check projection differs")
    capture = decode_json(read("capture.json"))
    traffic, calibration_armed = [], None
    for phase in range(-1, 10):
        directory = "calibration" if phase < 0 else f"phase-{phase}"
        raw = read(directory + "/raw.trace")
        parsed, counts = parse_trace(raw, phase)
        armed = next(i for i, row in enumerate(parsed["samples"]) if row["armed"])
        if phase < 0:
            calibration_armed = armed
        else:
            oracle.require(armed == calibration_armed, "armed edge differs from calibration")
        check_waveform(read(directory + "/waveform.vcd"), raw)
        if phase >= 0:
            oracle.require(parsed == capture["phases"][phase], "raw trace/capture mismatch")
            traffic.append({"phase": phase, **counts})
    measurements = oracle.check_capture(capture)
    oracle.require(result["measurements"] == measurements and result["traffic"] == traffic,
                   "stored measurement/traffic mismatch")
    # Final byte fence: no replay after it. Stable local evidence, not atomic/ABA authentication.
    oracle.require(path.read_bytes() == raw_result and all((root/p).read_bytes() == data
                   for p, data in admitted.items()), "evidence changed during inspection")
    return {"source_digest": hashlib.sha256(raw_result).hexdigest(), "result": result,
            "measurements": measurements}


def compare(left, right):
    """Two explicit retained results; resource policy is the sole admitted axis."""
    a, b = inspect(left), inspect(right)
    reasons = []
    if a["measurements"] is None or b["measurements"] is None:
        reasons.append("one or both executions lack verified measurements")
    for key in ("hardware_assignment", "controls", "source_role", "reference_check"):
        if a["result"].get(key) != b["result"].get(key):
            reasons.append(f"different {key}")
    for tool in ("emitter", "reference", "iverilog", "vvp"):
        if a["result"].get("tools", {}).get(tool, {}).get("sha256") != b["result"].get("tools", {}).get(tool, {}).get("sha256"):
            reasons.append(f"different {tool} artifact")
    def sources(side):
        return {e["path"]: e["sha256"] for e in side["result"]["artifacts"] if e["path"].startswith("sources/")}
    if sources(a) != sources(b) or not sources(a):
        reasons.append("source/checker snapshots differ or are absent")
    if a["result"]["source_role"] != "implementation" or b["result"]["source_role"] != "implementation":
        reasons.append("behavioral baseline is not an implementation A/B")
    # Recheck first side after the second; do not substitute newer evidence.
    oracle.require(inspect(left)["source_digest"] == a["source_digest"] and
                   inspect(right)["source_digest"] == b["source_digest"], "comparison source changed")
    return {"schema": "electrum.event-response-comparison", "version": 1, "axis": "resource_policy",
            "system_boundary": a["result"]["system_boundary"],
            "hardware_assignment_identity": a["result"]["hardware_assignment_identity"],
            "left": {"result_path": str(Path(left).absolute()), "selection": a["result"]["selection"],
                     "source_role": a["result"]["source_role"], "status": a["result"]["status"]},
            "right": {"result_path": str(Path(right).absolute()), "selection": b["result"]["selection"],
                      "source_role": b["result"]["source_role"], "status": b["result"]["status"]},
            "left_digest": a["source_digest"], "right_digest": b["source_digest"],
            "status": "confounded_or_unavailable" if reasons else "comparable", "reasons": reasons,
            "right_minus_left_response_ticks": None if reasons else [
                r["external_to_bank_ticks"]-l["external_to_bank_ticks"] for l, r in
                zip(a["measurements"]["phases"], b["measurements"]["phases"])],
            "physical_area_speed_delta": None}
