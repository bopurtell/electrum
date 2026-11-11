"""Non-EDA emission/ABI preservation check; run under the shared build lock."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]
BASE = ROOT / ".dev/am3/integrated-final-20261111"
BUILD = ROOT / "_build/default"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def run(exe, *args):
    subprocess.run([str(BUILD / exe), *map(str, args)], cwd=ROOT, check=True)


def main():
    generated = OUT / "generated"
    bundles = OUT / "bundles"
    generated.mkdir(exist_ok=False)
    bundles.mkdir(exist_ok=False)
    result = {"generated": {}, "bundles": {}}
    run("asic/verif/observable/emit/generate.exe", "-output", generated / "p0_observable.v",
        "-module-name", "p0_observable")
    for block in ("pin_bank", "input_events", "timing", "byte_fifo_8", "shift_lane",
                  "observed_transfer", "observed_transfer_bank", "primitive_demo", "uart_tx", "uart_slice"):
        run("ip/mechanisms/verif/emit/generate_p2.exe", block, generated / f"{block}.v")
    for kind in ("access", "executable", "integrated", "loader"):
        run("verif/system/emit/generate_core.exe", kind, generated / f"{kind}.v")
    for role in ("simulation", "implementation"):
        run("ip/program_memory_controller/verif/backend_integration/emit_program_memory_backend.exe",
            role, generated / f"program_memory_backend.{role}.v")
    for source in sorted(generated.iterdir()):
        before, after = (BASE / "generated" / source.name).read_bytes(), source.read_bytes()
        result["generated"][source.name] = {
            "before_sha256": sha(before), "after_sha256": sha(after), "byte_equal": before == after}
    checker_path = ROOT / "asic/tinytapeout/scripts/check-adopted-bundle.py"
    spec = importlib.util.spec_from_file_location("bundle_checker", checker_path)
    checker = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(checker)
    for kind in ("observable", "memory", "loader"):
        dest, repeated = bundles / kind, bundles / (kind + "-repeat")
        run("asic/cli/asic_bundle.exe", "--check-conflicts", kind)
        run("asic/cli/asic_bundle.exe", kind, dest, ROOT)
        run("asic/cli/asic_bundle.exe", kind, repeated, ROOT)
        identity = checker.check_bundle(ROOT, dest, kind)
        assert identity == checker.check_bundle(ROOT, repeated, kind)
        assert (dest / "manifest.json").read_bytes() == (repeated / "manifest.json").read_bytes()
        old = json.loads((BASE / "bundles" / kind / "manifest.json").read_text())
        new = json.loads((dest / "manifest.json").read_text())
        fields = set(old) | set(new)
        functional = fields - {"identity", "source_revision", "source_inputs", "files"}
        comparison = {key: old.get(key) == new.get(key) for key in sorted(functional)}
        roles = {}
        for role, key in (("simulation", "simulation_sources"), ("synthesis", "synthesis_sources")):
            assert old[key] == new[key]
            for name in new[key]:
                before = (BASE / "bundles" / kind / name).read_bytes()
                after = (dest / name).read_bytes()
                roles[role] = {"before_sha256": sha(before), "after_sha256": sha(after),
                               "byte_equal": before == after}
        collateral = {}
        for name in ("src/config.json", "constraints/top.sdc", "info.yaml"):
            before = (BASE / "bundles" / kind / name).read_bytes()
            after = (dest / name).read_bytes()
            collateral[name] = {"before_sha256": sha(before), "after_sha256": sha(after),
                                "byte_equal": before == after}
        result["bundles"][kind] = {"old_identity": old["identity"], "new_identity": identity,
                                   "repeatable": True, "unchanged_manifest_fields": comparison,
                                   "rtl": roles, "collateral": collateral,
                                   "source_paths": [row["path"] for row in new["source_inputs"]]}
    (OUT / "emission-comparison.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    assert len(result["generated"]) == 17
    assert all(row["byte_equal"] for row in result["generated"].values())
    for row in result["bundles"].values():
        assert all(row["unchanged_manifest_fields"].values()), row["unchanged_manifest_fields"]
        assert all(item["byte_equal"] for item in row["rtl"].values())
        assert all(item["byte_equal"] for item in row["collateral"].values())
    print("PASS: 17 standalone RTL outputs, six bundle RTL roles, package collateral/ABI,")
    print("canonical source manifests and repeatable emission; no EDA/provisioning executed")


if __name__ == "__main__":
    main()
