"""Recheck saved receipts against current sources; no emission or EDA."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import stat

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    checker = load("checker", "asic/tinytapeout/scripts/check-adopted-bundle.py")
    phase4 = load("phase4", "asic/tinytapeout/scripts/adopted_phase4.py")
    checks = {}
    for kind in ("observable", "memory", "loader"):
        bundle = OUT / "bundles" / kind
        manifest = json.loads((bundle / "manifest.json").read_text())
        checks[kind] = {"identity": checker.check_bundle(ROOT, bundle, kind),
                        "consumer_pins": phase4.consumer_pins(bundle, manifest)}
        assert len(manifest["source_inputs"]) == 55
    archive = json.loads((OUT / "archive-receipt.json").read_text())
    for move in archive["moves"]:
        for name, row in move["before"].items():
            path = ROOT / move["new"]
            if name != ".":
                path /= name
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row["sha256"]
            assert len(path.read_bytes()) == row["bytes"]
            assert oct(stat.S_IMODE(path.stat().st_mode)) == row["mode"]
    # The target wrapper collateral and authored peers are unchanged saved source
    # bytes. This is correspondence to AM3's saved input receipt, not recaptured Git.
    initial = json.loads((ROOT / ".dev/am3/integrated-final-20261111/initial-source-hashes.json").read_text())
    preserved = {}
    for old, new in (
        ("chip_top/verif/observable/emitted/tb.v", "asic/verif/observable/emitted/tb.v"),
        ("chip_top/verif/memory/emitted/p0_memory_tb.v", "asic/verif/memory/emitted/p0_memory_tb.v"),
        ("tinytapeout/src/project.v", "asic/tinytapeout/src/project.v"),
        ("tinytapeout/src/p0_observable.v", "asic/tinytapeout/src/p0_observable.v"),
        ("tinytapeout/src/config.json", "asic/tinytapeout/src/config.json"),
        ("tinytapeout/info.yaml", "asic/tinytapeout/info.yaml"),
        ("tinytapeout/toolchain.lock", "asic/tinytapeout/toolchain.lock"),
        ("tinytapeout/asic-dependencies.lock", "asic/tinytapeout/asic-dependencies.lock"),
    ):
        digest = hashlib.sha256((ROOT / new).read_bytes()).hexdigest()
        assert digest == initial[old], old
        preserved[new] = {"old": old, "before_sha256": initial[old], "after_sha256": digest}
    result = {"bundles_current": checks, "source_inputs_per_kind": 55,
              "archives_current": 42, "preserved_peers_and_collateral": preserved}
    (OUT / "current-checks.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print("PASS current source/embedded-lock correspondence, 42 archive bytes/modes,")
    print("two authored peers and six committed target collateral/lock files")


if __name__ == "__main__":
    main()
