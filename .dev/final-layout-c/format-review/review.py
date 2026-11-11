"""Scoped formatting and non-EDA preservation receipts; never edits source files."""
import hashlib
import difflib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import sys

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
BASE = ROOT / ".dev/am3/integrated-final-20261111/bundles"
FILES = ["archive/dune", "asic/project/chip_project.ml", "asic/tinytapeout/src/dune",
         "asic/tinytapeout/test/dune", "asic/verif/observable/emit/dune",
         "ip/mechanisms/verif/emit/dune", "verif/system/emit/dune"]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def save(name, value):
    with (OUT / name).open("x") as stream:
        json.dump(value, stream, indent=2, sort_keys=True)
        stream.write("\n")


def run(name, args):
    result = subprocess.run(args, cwd=ROOT, capture_output=True)
    (OUT / (name + ".log")).write_bytes(result.stdout + result.stderr)
    print(name, "exit", result.returncode, flush=True)
    assert result.returncode == 0, (name, result.stderr.decode())
    return result.stdout


def formatted(path):
    if path.endswith(".ml"):
        return subprocess.check_output(["ocamlformat", path], cwd=ROOT)
    return subprocess.check_output(["dune", "format-dune-file", "-j5", path], cwd=ROOT)


def archives():
    receipt = json.loads((OUT.parent / "archive-receipt.json").read_text())
    result = {}
    for move in receipt["moves"]:
        for name, expected in move["before"].items():
            path = ROOT / move["new"]
            if name != ".":
                path /= name
            data = path.read_bytes()
            actual = dict(sha256=digest(data), bytes=len(data),
                          mode=oct(stat.S_IMODE(path.stat().st_mode)))
            assert actual == expected, str(path)
            result[str(path.relative_to(ROOT))] = actual
    result["archive/INDEX.md"] = {"sha256": digest((ROOT / "archive/INDEX.md").read_bytes())}
    return result


def before():
    records = {}
    for name in FILES:
        data = (ROOT / name).read_bytes()
        expected = formatted(name)
        records[name] = {"before_sha256": digest(data), "before_text": data.decode(),
                         "expected_sha256": digest(expected), "expected_text": expected.decode()}
    save("before.json", {"files": records, "archives_and_index": archives()})
    print("Captured seven original/formatter outputs and 42 archive files plus index")


def after():
    snapshot = json.loads((OUT / "before.json").read_text())
    results = {}
    for name, row in snapshot["files"].items():
        actual = (ROOT / name).read_bytes()
        results[name] = {"before_sha256": row["before_sha256"], "after_sha256": digest(actual),
                         "matches_formatter_of_original": actual.decode() == row["expected_text"],
                         "format_clean": actual == formatted(name)}
        assert all(results[name][key] for key in ("matches_formatter_of_original", "format_clean")), name
    current = archives()
    assert current == snapshot["archives_and_index"]
    save("format-and-archive-checks.json", {"files": results, "archive_files": 42,
         "archive_and_index_unchanged": True, "archive_index_sha256": current["archive/INDEX.md"]["sha256"]})
    print("PASS seven/seven scoped format checks; exactly formatter-only edits; archives/index intact")


def differences():
    for name in FILES:
        actual = (ROOT / name).read_text().splitlines(keepends=True)
        expected = formatted(name).decode().splitlines(keepends=True)
        sys.stdout.writelines(difflib.unified_diff(actual, expected, fromfile=name, tofile="formatted"))


def build():
    run("install-lint", ["dune", "build", "-j5", "@install", "@lint"])
    run("bundle-emitter-build", ["dune", "build", "-j5", "asic/cli/asic_bundle.exe"])


def bundles():
    spec = importlib.util.spec_from_file_location("checker", ROOT / "asic/tinytapeout/scripts/check-adopted-bundle.py")
    checker = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(checker)
    emitter = str(ROOT / "_build/default/asic/cli/asic_bundle.exe")
    results = {}
    for kind in ("observable", "memory", "loader"):
        dest, repeat = OUT / "bundles" / kind, OUT / "bundles" / (kind + "-repeat")
        assert not dest.exists() and not repeat.exists()
        run(kind + "-conflicts", [emitter, "--check-conflicts", kind])
        run(kind + "-emit", [emitter, kind, str(dest), str(ROOT)])
        run(kind + "-repeat", [emitter, kind, str(repeat), str(ROOT)])
        identity = checker.check_bundle(ROOT, dest, kind)
        assert identity == checker.check_bundle(ROOT, repeat, kind)
        assert (dest / "manifest.json").read_bytes() == (repeat / "manifest.json").read_bytes()
        manifest = json.loads((dest / "manifest.json").read_text())
        original = json.loads((BASE / kind / "manifest.json").read_text())
        paths = [row["path"] for row in manifest["source_inputs"]]
        assert len(paths) == len(set(paths)) == 55
        assert not any(path.startswith(("software/", "lib/", "verif/")) for path in paths)
        fields = (set(manifest) | set(original)) - {"identity", "source_revision", "source_inputs", "files"}
        assert all(manifest.get(key) == original.get(key) for key in fields)
        comparisons = {}
        for role, key in (("simulation", "simulation_sources"), ("synthesis", "synthesis_sources")):
            assert manifest[key] == original[key]
            for path in manifest[key]:
                old, new = (BASE / kind / path).read_bytes(), (dest / path).read_bytes()
                comparisons[role] = {"before_sha256": digest(old), "after_sha256": digest(new), "byte_equal": old == new}
                assert old == new, (kind, role)
        for path in ("src/config.json", "constraints/top.sdc", "info.yaml"):
            assert (BASE / kind / path).read_bytes() == (dest / path).read_bytes()
        results[kind] = {"old_identity": original["identity"], "new_identity": identity,
            "rtl": comparisons, "repeatable_manifest": True, "semantic_manifest_and_collateral_equal": True,
            "source_inputs": manifest["source_inputs"], "source_inputs_count": len(paths),
            "source_inputs_match_current_and_copies": True, "compatibility_facade_in_inventory": False}
    save("bundle-comparison.json", {"packages": results, "fresh_rtl_roles": 6,
        "all_rtl_byte_equal": True, "generic_stats_reexecuted": False, "eda_executed": False})
    print("PASS six fresh bundle RTL roles; 55 current inputs/package; no facade; updated identities")


def current():
    spec = importlib.util.spec_from_file_location("checker", ROOT / "asic/tinytapeout/scripts/check-adopted-bundle.py")
    checker = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(checker)
    results = {}
    for kind in ("observable", "memory", "loader"):
        dest = OUT / "bundles" / kind
        identity = checker.check_bundle(ROOT, dest, kind)
        manifest = json.loads((dest / "manifest.json").read_text())
        assert len(manifest["source_inputs"]) == 55
        results[kind] = {"identity": identity, "current_input_hashes": {
            row["path"]: digest((ROOT / row["path"]).read_bytes()) for row in manifest["source_inputs"]}}
    assert archives() == json.loads((OUT / "before.json").read_text())["archives_and_index"]
    assert all((ROOT / name).read_bytes() == formatted(name) for name in FILES)
    save("final-current-checks.json", {"packages": results, "current_inputs_per_package": 55,
         "scoped_format_clean": 7, "archive_and_index_unchanged": True})
    print("PASS final current-byte references for all three 55-input manifests, seven formats, archives/index")


if __name__ == "__main__":
    {"before": before, "after": after, "build": build, "bundles": bundles,
     "differences": differences, "current": current}[sys.argv[1]]()
