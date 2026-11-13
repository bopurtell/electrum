"""Pure retained-trace oracle for the existing P2.6b loaded-core workload.

This is a consumer oracle, not an ASIC Workload_result codec or a simulator.
The producer must load/verify through DUT ports and capture the real core's
signals. No successful execution, bundle association or source use is established
by this module alone. Fixture traces are not performance evidence.

Sampling follows core_engine_timing_tests.ml: event decisions are sampled before
the rising edge; synchronized state, bank pins and halt are sampled after settle.
Both carry the *edge label* (5 + 10*edge), not the post-settle observation time.
Thus equal bank-request/commit labels do not mean combinational propagation.
"""

from copy import deepcopy
from fractions import Fraction
import hashlib
import json


CONTRACT = {
    "name": "wait_start_then_drive",
    "version": 1,
    "image_words": [0x7804, 0x0000, 0xA300, 0x7804, 0x0001, 0x0000],
    "memory": {"layout": "m16", "depth_words": 256, "read_latency_edges": 1},
    "initial_software_claim": 1,
    "input_pin": 3,
    "output_pin": 0,
    "clock_period_ticks": 10,
    "first_rising_tick": 5,
    "capture_edges": 48,
    "phases": list(range(10)),
    "sampling": "pre-edge-decisions/post-settle-state-edge-label-v1",
    "completion": "normal-halt-and-pin0-high-within-capture",
    "measurement": "external-transition-to-first-bank-high-edge-label",
}

# Current canonical sources, not the archived pre-layout paths in old reports.
SOURCES = {
    "independent_model": "verif/reference/model/control_core.ml",
    "model_scenario": "verif/reference/model/test/test_isa.ml",
    "loaded_core_scenario": "ip/emulator_core/verif/core_engine/core_engine_tests.ml",
    "phase_sweep": "ip/emulator_core/verif/core_engine/core_engine_timing_tests.ml",
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), allow_nan=False).encode()


def workload():
    """Producer-facing logical contract; independent of Flops/Exact source bytes."""
    return deepcopy(CONTRACT)


def integer(value, name, low, high):
    require(type(value) is int and low <= value <= high, f"invalid {name}")
    return value


def fields(value, expected, name):
    require(type(value) is dict and set(value) == set(expected), f"invalid {name} fields")


def check_capture(capture):
    """Check all ten phases; return local digital measurements only on full pass.

    Each phase supplies 48 consecutive edge samples, not just summary timestamps.
    'decision' is Wait_edge completion; 'bank_request' is the subsequent accepted
    Write_pins_imm(mask=1,value=1), not the initial low write. The producer owns
    those decoded filters, initial claim/load verification and signal association.
    Capture status is checked, but is producer-reported, not authenticated.
    No host seconds, Fmax, analog CDC claim, fetch count or physical delta is inferred.
    """
    fields(capture, ("schema", "version", "status", "workload", "phases"), "capture")
    require(capture["schema"] == "electrum.event-response-capture", "unsupported capture schema")
    require(type(capture["version"]) is int and capture["version"] == 1,
            "unsupported capture version")
    require(capture["status"] == "completed", "capture is not completed")
    require(canonical(capture["workload"]) == canonical(CONTRACT), "workload contract differs")
    phases = capture["phases"]
    require(type(phases) is list and len(phases) == 10, "all ten phases are required")
    measurements = []
    for phase, run in enumerate(phases):
        fields(run, ("phase", "external_tick", "samples"), "phase")
        require(type(run["phase"]) is int and run["phase"] == phase,
                "phases must appear exactly once in order")
        external = integer(run["external_tick"], "external tick", 0, 485)
        rows = run["samples"]
        require(type(rows) is list and len(rows) == CONTRACT["capture_edges"],
                "incomplete edge capture")
        for edge, row in enumerate(rows):
            fields(row, ("edge", "armed", "synchronized", "decision", "bank_request",
                         "pins", "oe", "normal_halt", "fault"), "sample")
            require(type(row["edge"]) is int and row["edge"] == edge,
                    "missing, duplicate or reordered edge")
            for flag in ("armed", "synchronized", "decision", "bank_request", "normal_halt", "fault"):
                require(type(row[flag]) is bool, f"invalid sample {flag}")
            integer(row["pins"], "pins", 0, 255)
            integer(row["oe"], "oe", 0, 255)
            require(not row["fault"], "core fault during capture")
            require(row["oe"] in (0, 1) and row["pins"] in (0, 1),
                    "unexpected pin drive outside workload")

        def tick(index):
            return CONTRACT["first_rising_tick"] + CONTRACT["clock_period_ticks"] * index

        def first(flag):
            indices = [i for i, row in enumerate(rows) if row[flag]]
            require(indices, f"missing {flag} observation")
            return indices[0]

        armed = tick(first("armed"))
        require(external == armed + 10 + phase, "external phase not relative to armed wait")
        timestamps = {}
        for flag in ("synchronized", "decision", "bank_request"):
            require(sum(row[flag] for row in rows) == 1, f"nonunique {flag} observation")
            timestamps[flag] = tick(first(flag))
        synchronized, decision, request = (timestamps[k] for k in
                                            ("synchronized", "decision", "bank_request"))
        require(10 <= synchronized - external <= 19, "synchronizer latency changed")
        require(decision - synchronized == 20, "wait decision latency changed")
        require(request - decision == 30, "decoded write latency changed")
        commit_index = first("pins")
        commit = tick(commit_index)
        require(commit == request, "bank commit edge changed")
        claim_index = first("oe")
        require(tick(claim_index) < armed, "initial software claim missing before wait")
        require(all(row["oe"] == 1 for row in rows[claim_index:]), "output ownership lost")
        require(all(row["pins"] == 1 for row in rows[commit_index:]), "output glitches after commit")
        halt_index = first("normal_halt")
        require(halt_index >= commit_index and
                all(row["normal_halt"] for row in rows[halt_index:]),
                "halt precedes completion or is not stable")
        latency = commit - external
        measurements.append({"phase": phase, "external_to_bank_ticks": latency,
                             "external_to_bank_cycles": str(Fraction(latency, 10))})
    latencies = [m["external_to_bank_ticks"] for m in measurements]
    require((min(latencies), max(latencies)) == (60, 69), "phase response envelope changed")
    return {"scope": "consumer digital edge-label trace check; not ASIC workload inspection",
            "workload_identity": hashlib.sha256(canonical(CONTRACT)).hexdigest(),
            "capture_identity": hashlib.sha256(canonical(capture)).hexdigest(),
            "firmware_words": 6, "firmware_bytes": 12,
            "minimum_response_ticks": min(latencies), "maximum_response_ticks": max(latencies),
            "phases": measurements}
