"""Read-only source/preservation inventory for final-layout owner B."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
MOVES = {
    "host/host_api.ml": "software/host/host_api.ml",
    "host/simulator_backend.ml": "software/simulator/simulator_backend.ml",
    "bin/protemu.ml": "software/cli/protemu.ml",
    "bin/sim_cli.ml": "software/cli/sim_cli.ml",
    "scripts/p3.4-cli-workflow.sh": "software/cli/scripts/p3.4-cli-workflow.sh",
}
TREES = {
    "f_model": "verif/reference/model",
    "isa": "spec/isa",
    "host_link_protocol": "ip/host_link/protocol",
    "host_link_wire": "software/compatibility/host_link_wire",
    "examples": "software/cli/examples",
    "test/f_model": "verif/reference/model/test",
    "test/host": "software/host/test",
    "test/host_link_protocol": "ip/host_link/protocol/test",
    "test/host_link_protocol_compatibility": "software/compatibility/host_link_wire/test",
    "test/verification_support": "verif/common/test",
}


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def registrations(p):
    return re.findall(r"let%(?:expect_test|test_unit|test)\b[^=\n]*", p.read_text())


def baseline():
    moves = dict(MOVES)
    for old, new in TREES.items():
        for p in (ROOT / old).rglob("*"):
            if p.is_file():
                moves[str(p.relative_to(ROOT))] = str(Path(new) / p.relative_to(ROOT / old))
    moves["f_model/example_programs.ml"] = "firmware/examples/example_programs.ml"
    for p in (ROOT / "test/host_simulator").iterdir():
        if p.is_file():
            moves[str(p.relative_to(ROOT))] = str(Path("software/simulator/test" if p.suffix == ".ml" else "software/cli/test") / p.name)
    for p in (ROOT / "test/backend_conformance").iterdir():
        if p.is_file():
            target = "verif/backends/conformance/test" if p.name == "backend_conformance_expect_tests.ml" else "verif/backends/conformance"
            moves[str(p.relative_to(ROOT))] = str(Path(target) / p.name)
    paths = set(moves)
    for pattern in ("ip/*/verif/**/*.ml", "ip/*/verif/**/dune", "verif/**/*.ml", "verif/**/dune"):
        paths.update(str(p.relative_to(ROOT)) for p in ROOT.glob(pattern))
    frozen = [p for p in (ROOT / "ip/host_link/verif/archived").rglob("*") if p.is_file()]
    data = {
        "moves": moves,
        "sources": {s: {"sha256": digest(ROOT / s), "registrations": registrations(ROOT / s) if s.endswith(".ml") else []} for s in sorted(paths)},
        "frozen": {str(p.relative_to(ROOT)): digest(p) for p in frozen},
        "functional": {str(p.relative_to(ROOT)): digest(p) for p in ROOT.glob("ip/*/verif/**/*") if p.is_file() and p.suffix in (".trace", ".expected")},
    }
    print(json.dumps(data, indent=2, sort_keys=True))


def verify():
    data = json.loads((Path(__file__).parent / "baseline.json").read_text())
    counts = [0, 0]
    changed = []
    changed_expectations = []
    expectation_whitelist = {
        "ip/emulator_core/verif/execution/control_execution_property_tests.ml",
        "ip/program_memory_controller/verif/controller/protocol_core_property_tests.ml",
        "ip/mechanisms/verif/staging/uart_slice/uart_slice_property_tests.ml",
        "ip/mechanisms/verif/blocks/input_events/input_events_timing_tests.ml",
        "ip/mechanisms/verif/blocks/input_events/input_events_four_state_tests.ml",
        "verif/common/test/replay_expect_tests.ml",
    }
    path_changes = {
        "test/core/control_execution": "ip/emulator_core/verif/execution",
        "test/core/protocol_core": "ip/program_memory_controller/verif/controller",
        "test/integration/uart_slice": "ip/mechanisms/verif/staging/uart_slice",
        "test/primitives/input_events": "ip/mechanisms/verif/blocks/input_events",
        "test/common": "verif/common/test",
    }
    expect_pattern = r'\[%expect(?:_exact)?\s+(\{\|.*?\|\}|"(?:[^"\\]|\\.)*")\s*\]'
    for old, meta in data["sources"].items():
        new = data["moves"].get(old, old)
        if old == "host/dune":
            continue
        p = ROOT / new
        if not p.exists():
            raise RuntimeError(f"Missing source {old} -> {new}")
        got = registrations(p) if p.suffix == ".ml" else []
        assert got == meta["registrations"], (old, "registration changed")
        counts[0] += len(meta["registrations"])
        counts[1] += len(got)
        if digest(p) != meta["sha256"]:
            changed.append(new)
            if p.suffix == ".ml":
                before = subprocess.check_output(["git", "show", "HEAD:" + old], cwd=ROOT)
                assert hashlib.sha256(before).hexdigest() == meta["sha256"], (old, "baseline differs from HEAD")
                before_blocks = re.findall(expect_pattern, before.decode(), re.S)
                after_blocks = re.findall(expect_pattern, p.read_text(), re.S)
                if before_blocks != after_blocks:
                    assert new in expectation_whitelist, (new, "unexpected golden change")
                    normalized = []
                    for block in before_blocks:
                        for source, target in path_changes.items():
                            block = block.replace(source, target)
                        normalized.append(block)
                    assert normalized == after_blocks, (new, "non-path expectation change")
                    changed_expectations.append(new)
    for old, sha in (data["frozen"] | data["functional"]).items():
        assert digest(ROOT / old) == sha, old
    for old, new in data["moves"].items():
        if old.startswith("examples/") or old.endswith(".expected") or old == "f_model/example_programs.ml":
            assert digest(ROOT / new) == data["sources"][old]["sha256"], old
    global_counts = {}
    for root in ("ip", "software", "verif", "asic", "spec", "firmware"):
        global_counts[root] = sum(len(registrations(p)) for p in (ROOT / root).rglob("*.ml"))
    assert sum(global_counts.values()) == 481, global_counts
    retired = ["test", "f_model", "host", "host_link_protocol", "host_link_wire", "isa", "examples"]
    assert all(not (ROOT / name).exists() for name in retired)
    print(json.dumps({"registrations_before_after": counts, "global_registrations": global_counts, "global_total": sum(global_counts.values()), "frozen_files": len(data["frozen"]), "functional_goldens": len(data["functional"]), "cli_example_and_golden_files": sum(old.startswith("examples/") or old.endswith(".expected") for old in data["moves"]), "moves": len(data["moves"]), "path_only_expectation_whitelist": sorted(changed_expectations), "removed_empty_roots": retired, "changed_sources": changed}, indent=2))


if __name__ == "__main__":
    {"baseline": baseline, "verify": verify}[sys.argv[1]]()
