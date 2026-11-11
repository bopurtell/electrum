"""Formatter-output patch generation and preservation receipt; never edits source."""
import difflib
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]
FILES = [
    "firmware/examples/dune",
    "ip/emulator_core/verif/control_port/item.ml",
    "ip/emulator_core/verif/core_engine/core_engine_control_port_tests.ml",
    "ip/host_link/verif/command_dispatch/command_dispatch_testbench.ml",
    "ip/mechanisms/verif/blocks/input_events/input_events_four_state_bench.ml",
    "ip/mechanisms/verif/blocks/pin_bank/pin_bank_testbench.ml",
    "ip/program_memory_controller/verif/controller/protocol_core_property_tests.ml",
    "software/cli/protemu.ml",
    "software/cli/test/dune",
    "software/simulator/dune",
    "verif/backends/conformance/dune",
]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def formatted(name):
    args = ["dune", "format-dune-file", name] if Path(name).name == "dune" else ["ocamlformat", name]
    return subprocess.check_output([str(ROOT / "scripts/with-switch.sh"), *args], cwd=ROOT)


def snapshot():
    classification = json.loads((ROOT / ".dev/final-layout/hardware/integrated-format-classification.json").read_text())
    baseline = [item["path"] for item in classification["retained_baseline_files"]]
    assert len(baseline) == 23
    assert not set(FILES).intersection(baseline)
    frozen = json.loads((OUT / "baseline.json").read_text())["frozen"]
    data = {
        "sources": {name: (ROOT / name).read_text() for name in FILES},
        "baseline23": {name: digest((ROOT / name).read_bytes()) for name in baseline},
        "frozen8": frozen,
    }
    (OUT / "preformat.json").write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    print("*** Begin Patch")
    for name in FILES:
        before = data["sources"][name]
        after = formatted(name).decode()
        if before == after:
            continue
        print("*** Update File: " + str(ROOT / name))
        for line in list(difflib.unified_diff(before.splitlines(), after.splitlines(), n=3, lineterm=""))[2:]:
            print("@@" if line.startswith("@@") else line)
    print("*** End Patch")


def verify():
    data = json.loads((OUT / "preformat.json").read_text())
    results = []
    for name in FILES:
        current = (ROOT / name).read_bytes()
        assert current == formatted(name), (name, "formatter mismatch")
        before = data["sources"][name]
        after = current.decode()
        # The actual formatter output is the sole permitted change.
        before_tokens = re.findall(r'\[%expect(?:_exact)?\s+(\{\|.*?\|\}|"(?:[^"\\]|\\.)*")\s*\]', before, re.S)
        after_tokens = re.findall(r'\[%expect(?:_exact)?\s+(\{\|.*?\|\}|"(?:[^"\\]|\\.)*")\s*\]', after, re.S)
        assert before_tokens == after_tokens, (name, "expectation payload changed")
        results.append({"path": name, "formatter_pass": True, "before_sha256": digest(before.encode()), "after_sha256": digest(current)})
    for name, sha in data["baseline23"].items():
        assert digest((ROOT / name).read_bytes()) == sha, (name, "baseline file changed")
    for name, sha in data["frozen8"].items():
        assert digest((ROOT / name).read_bytes()) == sha, (name, "frozen file changed")
    print(json.dumps({"files": results, "all11_formatter_pass": True, "baseline23_byte_preserved": True, "frozen8_byte_preserved": True, "expectation_payloads_unchanged_by_formatting": True}, indent=2))


{"snapshot": snapshot, "verify": verify}[sys.argv[1]]()
