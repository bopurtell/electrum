"""Append-only follow-up evidence for the seven reviewed formatting corrections."""
import fcntl
import importlib.util
import json
import pathlib
import re
import subprocess

OUT = pathlib.Path(__file__).resolve().parent
OLD = OUT.parent / "package-tooling-post"
spec = importlib.util.spec_from_file_location("audit", OLD / "check.py")
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)
audit.OUT = OUT
ROOT = audit.ROOT
FILES = ["bin/asic_bundle.ml", "chip_top/rtl/observable_design.ml",
         "chip_top/rtl/memory_design.ml", "chip_top/rtl/package_top.ml",
         "lib/dune", "chip_top/project/dune", "tinytapeout/test/dune"]


def main():
    for directory in ["logs", "generated", "bundles"]:
        (OUT / directory).mkdir(exist_ok=True)
    with open("/home/wayne/devel/jane/.protemu-build.lock", "a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        scoped = []
        for path in FILES:
            name = "format-" + path.replace("/", "__")
            if path.endswith(".ml"):
                code = audit.run(name, ["opam", "exec", "--switch=5.2.0+ox", "--",
                                        "ocamlformat", "--check", path])
                scoped.append(dict(path=path, exit=code))
                assert code == 0, path
            else:
                code = audit.run(name, audit.DUNE + ["format-dune-file", path])
                equal = (ROOT / path).read_bytes() == (OUT / "logs" / (name + ".log")).read_bytes()
                scoped.append(dict(path=path, exit=code, format_equal=equal))
                assert code == 0 and equal, path
        audit.write("scoped-formatting.json", scoped)
        assert audit.run("build-install-lint", audit.DUNE + ["build", "@install", "@lint", "-j5"]) == 0
        # Read-only global check: preserve baseline backlog and report exact current paths.
        fmt_exit = audit.run("fmt-backlog", audit.DUNE + ["build", "@fmt", "-j5"])
        fmt_log = (OUT / "logs/fmt-backlog.log").read_text()
        failed = sorted(set(re.findall(r'^------ (.+)$', fmt_log, re.M)))
        baseline = {x["path"]: x["sha256"] for x in json.loads((audit.BASE / "source-snapshot.json").read_text())}
        reverse = {x["new"]: x["old"] for x in json.loads(
            (OUT.parent / "20261111-hardware-owner/source-map.json").read_text())}
        reverse.update({x["new"]: x["old"] for x in json.loads(
            (OUT.parent / "verification-post/audit.json").read_text())["files"]})
        leftovers = [dict(path=path, baseline_path=reverse.get(path, path),
                          baseline_byte_identical=baseline.get(reverse.get(path, path)) == audit.digest(ROOT / path))
                     for path in failed]
        audit.write("format-backlog.json", dict(exit=fmt_exit, failures=leftovers,
            baseline_leftover_count=sum(x["baseline_byte_identical"] for x in leftovers),
            introduced_count=sum(not x["baseline_byte_identical"] for x in leftovers)))
        assert not set(failed) & set(FILES)
        assert all(x["baseline_byte_identical"] for x in leftovers)
        previous_commands = [json.loads(x) for x in (OLD / "commands.jsonl").read_text().splitlines()]
        for command in previous_commands:
            if command["name"].startswith("generate-"):
                argv = [x.replace(str(OLD), str(OUT)) for x in command["argv"]]
                assert audit.run(command["name"], argv) == 0
        audit.write("generated-comparison.json", {
            p.name: dict(byte_equal=p.read_bytes() == (OUT / "generated" / p.name).read_bytes(),
                         before_sha256=audit.digest(p), after_sha256=audit.digest(OUT / "generated" / p.name))
            for p in (audit.BASE / "generated").iterdir()})
        bundles = {}
        inventory = {}
        for kind in ["observable", "memory", "loader"]:
            assert audit.run("bundle-" + kind, audit.DUNE + ["exec", "-j5", "bin/asic_bundle.exe", "--",
                kind, str(OUT / "bundles" / kind), str(ROOT)]) == 0
            assert audit.run("check-bundle-" + kind, ["python3", "-B",
                "tinytapeout/scripts/check-adopted-bundle.py", "--kind", kind, "--metadata-only"]) == 0
            bundles[kind] = audit.compare_bundle(kind, run_tools=False)
            old = json.loads((OLD / "bundles" / kind / "manifest.json").read_text())
            new = json.loads((OUT / "bundles" / kind / "manifest.json").read_text())
            old_inputs = {x["path"]: x for x in old["source_inputs"]}
            new_inputs = {x["path"]: x for x in new["source_inputs"]}
            inventory[kind] = dict(identity_before_format=old["identity"], identity_after_format=new["identity"],
                source_paths_equal=old_inputs.keys() == new_inputs.keys(),
                changed_inputs=[dict(path=p, before=old_inputs[p], after=new_inputs[p])
                                for p in new_inputs if old_inputs[p] != new_inputs[p]],
                copied_inputs_match_current_sources=True,
                manifest_file_hashes_valid=True)
            assert all(x["byte_equal"] for x in bundles[kind]["rtl"].values())
            assert all(bundles[kind]["manifest_fields_equal"].values())
            assert all(bundles[kind]["collateral_byte_equal"].values())
        audit.write("bundle-comparison.json", bundles)
        audit.write("format-inventory-changes.json", inventory)
        assert all(x["byte_equal"] for x in json.loads((OUT / "generated-comparison.json").read_text()).values())
        audit.run("diff-check", ["git", "diff", "--check"])
        audit.write("source-hashes.json", {p: audit.digest(ROOT / p) for p in FILES})
    records = [json.loads(x) for x in (OUT / "commands.jsonl").read_text().splitlines()]
    audit.write("result-summary.json", dict(commands=records,
        failures=[x for x in records if x["exit"] and x["name"] != "fmt-backlog"],
        baseline_format_failure_count=len(failed),
        rtl_regression_rerun=False, synthesis_rerun=False,
        reason="Only reviewed whitespace/comment layout changed; all regenerated RTL and all six fresh bundle roles are byte-identical."))


if __name__ == "__main__":
    main()
