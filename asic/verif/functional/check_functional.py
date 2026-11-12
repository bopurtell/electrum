#!/usr/bin/env python3
"""Explicit PT3b host-Icarus replay. No nested builds, provisioning or physical flow."""

import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
import os
from pathlib import Path, PurePosixPath
import re
import resource
import shutil
import signal
import subprocess
import time
import uuid


MACRO = "RM_IHPSG13_1P_256x16_c2_bm_bist"
MODEL_HASHES = {
    f"pdk_dir::libs.ref/sg13cmos5l_sram/verilog/{MACRO}.v":
        "645c475787b077da4dbd15856c68bbae46aa9846a155239eb895ed2de7511053",
    "pdk_dir::libs.ref/sg13cmos5l_sram/verilog/RM_IHPSG13_1P_core_behavioral_bm_bist.v":
        "d0a6258f8e9c93d1d5b1f78c0a1d66f30d28b1ad8037e5e07f53d1a4e3670b12",
}
BENCHES = {
    "memory": ("asic/verif/memory/emitted/p0_memory_tb.v", "tb", []),
    "loader": ("verif/system/emitted/p3_loader_tb.v", "p3_loader_tb", ["LOADER_WRAPPER"]),
}
LOADER_SCENARIOS = [
    "initial-image-invalid", "incomplete-duplicate-unverified-refused",
    "mismatch-never-authorizes-run", "serial-load-verify-readback",
    "extension-fetch-and-branch-execution", "replacement-invalidates-and-old-tail-faults",
    "all-six-live-host-classes-refused-fetch-survives", "blocking-stall-stable-across-status-polls",
    "stalled-abort-recovers", "active-disable-releases-and-preserves-image",
    "disabled-image-readback-and-rerun", "active-reset-invalidates-image",
    "accepted-partial-load-disable-cancels-session",
    "partial-frame-disable-cancels",
]
PENDING_SCENARIOS = ["pending-read-disable", "pending-read-reset",
                     "pending-fetch-disable", "pending-fetch-reset"]


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def inventory(root):
    result = {}
    for path in sorted(root.rglob("*")):
        require(not path.is_symlink(), f"symlink in inventory: {path}")
        if path.is_file():
            result[str(path.relative_to(root))] = digest(path.read_bytes())
    return result


def safe_path(root, relative):
    parts = PurePosixPath(relative)
    require(relative and not parts.is_absolute() and ".." not in parts.parts
            and str(parts) == relative, f"unsafe relative path: {relative}")
    path = (root / relative).resolve(strict=True)
    require(path.is_relative_to(root.resolve()) and path.is_file(),
            f"source escapes root or is not a file: {relative}")
    return path


def resolve_models(manifest, pdk):
    contract = manifest["macro_contract"]
    simulation = contract["implementation_simulation"]
    require(simulation["defines"] == ["FUNCTIONAL"], "unexpected functional defines")
    refs = simulation["models"]
    require(len(refs) == 2 and set(refs) == set(MODEL_HASHES),
            "unexpected manifest functional model closure")
    resources = manifest["resource_snapshot"]["resources"]
    typed = [c["reference"] for r in resources for c in r["collateral"]
             if c["role"] == "simulation_model"]
    require(sorted(typed) == sorted(refs), "typed functional collateral disagrees with manifest")
    require(manifest["target"]["technology"] == "ihp-sg13cmos5l", "unexpected PDK technology")
    process = pdk / "ihp-sg13cmos5l"
    require(process.resolve().is_relative_to(pdk.resolve()), "PDK process escapes root")
    result = []
    for ref in refs:
        # The locked PDK shares SRAM models with sg13g2 via repository-internal
        # symlinks. Contain the resolved file in the whole verified PDK checkout.
        path = safe_path(pdk, "ihp-sg13cmos5l/" + ref.removeprefix("pdk_dir::"))
        require(digest(path.read_bytes()) == MODEL_HASHES[ref], f"vendor model drift: {path}")
        result.append((ref, path))
    return result


def check_oracle(output, code, kind, negative=False):
    mismatch = re.search(r"^PT3B EXPECTED_MISMATCH(?: .*)?$", output, re.M)
    passes = re.findall(rf"^PT3B PASS {kind} observations=([0-9]+)\s*$", output, re.M)
    if negative:
        require(code > 0 and mismatch is not None and not passes,
                f"{kind}: negative oracle requires expected mismatch and nonzero exit")
        return None
    require(code == 0 and mismatch is None and len(passes) == 1 and int(passes[0]) > 0,
            f"{kind}: missing positive contract PT3B PASS {kind} observations=<N> (N>0), or failed replay")
    return int(passes[0])


def check_loader(output, observations, profile):
    require(profile in ("package", "exact", "external_contract"), "unknown loader profile")
    external = profile == "external_contract"
    boundary = profile != "package"
    rounds = 3 if external else 1
    scenarios = (LOADER_SCENARIOS + (PENDING_SCENARIOS if boundary else [])) * rounds
    actual = re.findall(r"^PT3B OBS ([^\r\n]+)$", output, re.M)
    require(actual == scenarios, f"{profile}: loader scenario transcript missing or out of order")
    require(observations == len(scenarios), f"{profile}: incorrect loader observation count")
    counters = re.findall(r"^PT3B COUNTERS refusals=([0-9]+) cancellations=([0-9]+) "
                          r"reads=([0-9]+) writes=([0-9]+)\s*$", output, re.M)
    require(len(counters) == 1, f"{profile}: missing unique loader counters")
    refusals, cancellations, reads, writes = map(int, counters[0])
    require((refusals, cancellations) == (6 * rounds, (4 if boundary else 0) * rounds),
            f"{profile}: incorrect refusal/cancellation counters")
    require((reads > 0 and writes > 0) if boundary else (reads == 0 and writes == 0),
            f"{profile}: missing runtime RAM read/write evidence or unexpected package probes")
    poison = re.findall(r"^PT3B ORACLE poison=([0-9]+) architectural_digest=([0-9a-fA-F]{8})\s*$",
                        output, re.M)
    if external:
        require([p for p, _ in poison] == ["0", "1", "2"] and
                len({value.lower() for _, value in poison}) == 1,
                "external contract: missing zero/ones/X rounds or architectural digests disagree")
    else:
        require(not poison, "package replay must not claim external-RAM poison evidence")
    return {"profile": profile, "scenarios": actual,
            "counters": dict(refusals=refusals, cancellations=cancellations, reads=reads, writes=writes),
            "poison_rounds": [{"representation": ["zero", "ones", "X"][int(p)],
                               "architectural_digest": value} for p, value in poison],
            "macro_runtime_evidence": profile == "exact"}


def replay_inputs(manifest, bundle, selection, role, model_sources, bench_defines):
    exact = selection == "exact" and role == "synthesis_sources"
    sources = [safe_path(bundle, path) for path in manifest[role]]
    stubs = set(manifest.get("macro_contract", {}).get("blackbox_sources", []))
    require(not stubs.intersection(manifest[role]), "synthesis stub selected for replay")
    defines = ["PT3B", *bench_defines] + (["PT3B_EXACT", "FUNCTIONAL"] if exact else [])
    require(not exact or len(model_sources) == 2, "Exact implementation needs both vendor models")
    return exact, defines, sources + (model_sources if exact else [])


class Evidence:
    def __init__(self, directory, root):
        self.directory = directory
        directory.mkdir(parents=True, exist_ok=False)
        self.root = root
        self.record = {"schema_version": 1, "status": "running",
                       "scope": "PT3b emitted RTL vendor-functional; not physical or timed",
                       "required_replay_count": 9, "required_external_contract": True,
                       "negative_check": "expected comparison flip; oracle self-check, not DUT fault injection",
                       "budget": "bounded1; serial children", "commands": [], "replays": []}
        self.save()

    def save(self):
        pending = self.directory / "receipt.pending"
        pending.write_text(json.dumps(self.record, indent=2) + "\n")
        pending.replace(self.directory / "receipt.json")

    def run(self, argv, *, timeout=120, success=True):
        argv = [str(x) for x in argv]
        index = len(self.record["commands"])
        entry = {"argv": argv, "cwd": str(self.root), "timeout_seconds": timeout,
                 "stdout": f"command-{index:03d}.stdout", "stderr": f"command-{index:03d}.stderr"}
        entry["available_memory_kib_before"] = available_memory()
        self.record["commands"].append(entry)
        self.save()
        started = time.monotonic()
        with (self.directory / entry["stdout"]).open("w") as out, \
             (self.directory / entry["stderr"]).open("w") as err:
            process = subprocess.Popen(argv, cwd=self.root, stdout=out, stderr=err,
                                       start_new_session=True)
            try:
                process.wait(timeout=timeout)
            except BaseException as error:
                # Only this child's new session/group is owned by this runner.
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.wait()
                entry["timed_out"] = isinstance(error, subprocess.TimeoutExpired)
                raise
            finally:
                entry.update(exit=process.returncode, seconds=time.monotonic() - started)
                entry["available_memory_kib_after"] = available_memory()
                entry["runner_children_peak_rss_kib_so_far"] = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
                self.save()
        output = (self.directory / entry["stdout"]).read_text(errors="replace")
        output += (self.directory / entry["stderr"]).read_text(errors="replace")
        if success:
            require(process.returncode == 0, f"command {index} failed ({process.returncode}): {argv}")
        return process.returncode, output

    def snapshot(self, source, relative):
        destination = self.directory / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        data = source.read_bytes()
        destination.write_bytes(data)
        return destination, digest(data)


def available_memory():
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            return int(line.split()[1])
    return None


def load_checks(root):
    spec = importlib.util.spec_from_file_location("pt3a_checks", root / "asic/verif/bundle/check_bundle.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.check_snapshot


def replay(evidence, tools, name, sources, bench, top, defines, kind, *,
           profile=None, identity=None, role=None):
    executable = evidence.directory / (name + ".vvp")
    record = {"name": name, "bundle_identity": identity, "role": role,
              "vendor_functional": "FUNCTIONAL" in defines, "defines": defines,
              "sources": [{"path": str(path), "sha256": digest(path.read_bytes())}
                          for path in [*sources, bench]], "status": "running"}
    evidence.record["replays"].append(record)
    evidence.save()
    evidence.run([tools["iverilog"], "-g2012", "-Wall", "-s", top, "-o", executable,
                  *["-D" + define for define in defines], *sources, bench])
    record["positive_command"] = len(evidence.record["commands"])
    code, output = evidence.run([tools["vvp"], "-N", executable], timeout=300, success=False)
    record["observations"] = check_oracle(output, code, kind)
    if kind == "loader":
        record["acceptance"] = check_loader(output, record["observations"], profile)
    record["negative_command"] = len(evidence.record["commands"])
    code, output = evidence.run([tools["vvp"], "-N", executable, "+PT3B_EXPECT_MISMATCH"],
                                timeout=300, success=False)
    check_oracle(output, code, kind, negative=True)
    record["negative_oracle_selfcheck"] = "passed; expected comparison flip, no DUT fault injection"
    record["status"] = "passed"
    evidence.save()


def validate_bundle(bundle, root, selection, kind, evidence, check_snapshot):
    manifest = json.loads((bundle / "manifest.json").read_text())
    payload = {k: v for k, v in manifest.items() if k != "identity"}
    require(digest(json.dumps(payload, separators=(",", ":"), ensure_ascii=False).encode())
            == manifest["identity"], "manifest identity mismatch")
    actual = inventory(bundle)
    files = manifest["files"]
    require(len(files) == len(actual) - 1 and
            {x["path"]: x["sha256"] for x in files} ==
            {k: v for k, v in actual.items() if k != "manifest.json"}, "bundle inventory mismatch")
    require(manifest["project"] == "protemu_" + kind, "wrong emitted project")
    require(manifest["top_module"] == "tt_um_leemperor_hardcaml_protemu_" + kind,
            "wrong emitted top")
    require(manifest["operation"] == ("Synthesis" if selection == "exact" else "Hardening"),
            "unexpected emitted operation")
    require(manifest["source_revision"] == evidence.record["source_revision"], "source revision mismatch")
    check_snapshot(manifest, selection)
    simulation_resources = manifest["simulation_resources"]
    require(len(simulation_resources) == 1 and
            simulation_resources[0]["elaborated_as"] == "Behavioral_model" and
            simulation_resources[0]["source_roles"] == ["Generated_behavioral_model"],
            "simulation resource is not behavioral")
    for item in manifest["source_inputs"]:
        source = safe_path(root, item["path"])
        copied = safe_path(bundle, "inputs/" + item["path"])
        require(digest(source.read_bytes()) == item["sha256"] == digest(copied.read_bytes()),
                f"source attribution mismatch: {source}")
    for role in ("simulation_sources", "synthesis_sources"):
        require(len(manifest[role]) == 1, "unexpected RTL closure")
        safe_path(bundle, manifest[role][0])
    require(not set(manifest["simulation_sources"]) & set(manifest["synthesis_sources"]),
            "behavioral/implementation source sets overlap")
    synthesis = safe_path(bundle, manifest["synthesis_sources"][0]).read_text()
    simulation = safe_path(bundle, manifest["simulation_sources"][0]).read_text()
    require(MACRO not in simulation, "behavioral RTL contains vendor macro")
    if selection == "exact":
        require(len(re.findall(r"\b" + MACRO + r"\s+hc_resource_7_program\s*\(", synthesis)) == 1,
                "missing unique production macro instance")
        require(not set(manifest["macro_contract"]["blackbox_sources"]) &
                 set(manifest["synthesis_sources"]), "synthesis stub in RTL source set")
        require(manifest["macro_contract"]["schema_version"] == 1 and
                manifest["macro_contract"]["execution"] == "synthesis_only" and
                [(m["resource"], m["module"], m["instance"])
                 for m in manifest["macro_contract"]["macros"]] ==
                [("program", MACRO, "hc_resource_7_program")], "unexpected macro contract")
    else:
        require(MACRO not in synthesis and "macro_contract" not in manifest, "Flops contains macro")
    return manifest


def execute(args, evidence):
    root = evidence.root
    lock = dict(line.split("=", 1) for line in
                (root / "asic/tinytapeout/asic-dependencies.lock").read_text().splitlines()
                if line and not line.startswith("#"))
    receipt_path = Path(os.environ.get("PROTEMU_ASIC_RECEIPT", "/missing-private-provider"))
    provider = json.loads(receipt_path.read_text())
    prefix = Path(os.environ.get("PROTEMU_ASIC_PREFIX", "/missing-private-prefix"))
    require(provider["checks_passed"] is True and provider["revision"] == lock["asic_revision"]
            and provider["prefix"] == str(prefix), "private provider receipt mismatch")
    require(inventory(prefix) == provider["installed_sha256"], "private provider inventory drift")
    _, receipt_sha = evidence.snapshot(receipt_path, "inputs/provider-receipt.json")
    evidence.snapshot(args.cli, "inputs/asic_bundle.exe")
    _, core_emitter_sha = evidence.snapshot(args.core_emitter, "inputs/generate_core.exe")
    core_source = root / "verif/system/emit/generate_core.ml"
    _, core_source_sha = evidence.snapshot(core_source, "inputs/verif/system/emit/generate_core.ml")
    evidence.snapshot(Path(__file__).resolve(), "inputs/check_functional.py")
    evidence.snapshot(root / "asic/verif/bundle/check_bundle.py", "inputs/check_bundle.py")
    evidence.snapshot(root / "asic/tinytapeout/asic-dependencies.lock", "inputs/asic-dependencies.lock")
    _, resolution = evidence.run(["ocamlfind", "query", "hardcaml_asic",
                                 "hardcaml_asic.flow_domain", "hardcaml_asic.execution"])
    require(resolution.splitlines() == [str(prefix / "lib/hardcaml_asic" / suffix)
                                       for suffix in ("", "flow_domain", "execution")],
            "private dependency resolution mismatch")
    evidence.record["source_revision"] = evidence.run(["git", "rev-parse", "HEAD"])[1].strip()
    evidence.record["source_status"] = evidence.run(["git", "status", "--porcelain=v1",
                                                    "--untracked-files=all"])[1]
    pdk = (args.pdk_root or root.parent / "hardcaml_asic/.toolchain/pdk").resolve(strict=True)
    revision = evidence.run(["git", "-C", pdk, "rev-parse", "HEAD"])[1].strip()
    status = evidence.run(["git", "-C", pdk, "status", "--porcelain=v1", "--untracked-files=all"])[1]
    require(revision == lock["pdk_revision"] and not status, "PDK must be clean at locked revision")
    evidence.record["pdk"] = {"root": str(pdk), "revision": revision, "status": status}
    evidence.record["environment"] = {key: os.environ.get(key) for key in
                                      ("PATH", "OCAMLPATH", "DUNE_BUILD_DIR", "MAKEFLAGS",
                                       "OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS")}
    tools = {}
    for tool, version in (("iverilog", "-V"), ("vvp", "-V")):
        path = shutil.which(tool)
        require(path is not None, f"required host simulator missing: {tool}")
        tools[tool] = str(Path(path).resolve(strict=True))
        evidence.run([tools[tool], version])
    evidence.record["tools"] = tools
    check_snapshot = load_checks(root)
    watched = {args.cli: digest((evidence.directory / "inputs/asic_bundle.exe").read_bytes()),
               args.core_emitter: core_emitter_sha, core_source: core_source_sha,
               receipt_path: receipt_sha,
               root / "asic/verif/bundle/check_bundle.py":
                   digest((evidence.directory / "inputs/check_bundle.py").read_bytes()),
               Path(__file__).resolve():
                   digest((evidence.directory / "inputs/check_functional.py").read_bytes())}
    for kind, (bench_relative, top, bench_defines) in BENCHES.items():
        bench_source = root / bench_relative
        bench, bench_hash = evidence.snapshot(bench_source, "inputs/" + bench_relative)
        watched[bench_source] = bench_hash
        text = bench.read_text()
        require(f"PT3B PASS {kind} observations=" in text and "PT3B_EXPECT_MISMATCH" in text
                and "PT3B EXPECTED_MISMATCH" in text,
                f"{kind} bench missing PT3B positive/negative oracle contract; coordinate bench owner")
        for selection in ("flops", "exact"):
            bundles = []
            for repeat in range(2):
                bundle = evidence.directory / f"{kind}-{selection}-{repeat}"
                _, output = evidence.run([args.cli, "--selection", selection, kind, bundle, root])
                manifest = validate_bundle(bundle, root, selection, kind, evidence, check_snapshot)
                for item in manifest["source_inputs"]:
                    source = safe_path(root, item["path"])
                    require(source not in watched or watched[source] == item["sha256"],
                            f"source changed between emissions: {source}")
                    watched[source] = item["sha256"]
                require(output.strip() == f"{bundle} {manifest['identity']}", "emitter receipt mismatch")
                bundles.append(bundle)
            require(inventory(bundles[0]) == inventory(bundles[1]), "repeat emission differs")
            model_sources = []
            if selection == "exact":
                models = []
                for reference, path in resolve_models(manifest, pdk):
                    snapshot, sha = evidence.snapshot(path, "models/" + path.name)
                    require(sha == MODEL_HASHES[reference], "model changed while snapshotting")
                    watched[path] = sha
                    model_sources.append(snapshot)
                    models.append({"reference": reference, "resolved": str(path),
                                   "snapshot": str(snapshot.relative_to(evidence.directory)), "sha256": sha})
                evidence.record["models"] = models
            for role in ("simulation_sources", "synthesis_sources"):
                name = f"{kind}-{selection}-{role}"
                exact, defines, sources = replay_inputs(
                    manifest, bundles[0], selection, role, model_sources, bench_defines)
                replay(evidence, tools, name, sources, bench, top, defines, kind,
                       profile="exact" if exact else "package", identity=manifest["identity"], role=role)
    # Required full-system contract oracle: the bench varies only unspecified
    # initial/write outputs across zero/ones/X; disabled output continues to hold.
    cores = [evidence.directory / f"loader-external-contract-{repeat}.v" for repeat in range(2)]
    for core in cores:
        evidence.run([args.core_emitter, "loader", core])
        require(re.search(r"\bmodule\s+loader_core\b", core.read_text()) is not None
                and MACRO not in core.read_text(), "unexpected external-contract core RTL")
    require(cores[0].read_bytes() == cores[1].read_bytes(), "external core repeat emission differs")
    evidence.record["external_contract"] = {
        "required": True, "emitter_sha256": core_emitter_sha,
        "rtl_sha256": digest(cores[0].read_bytes()), "repeats": [p.name for p in cores],
        "ram_model": "bench latency-one 1RW; disabled hold; initial/write output zero, ones, X",
        "comparison": "bench item-by-item architectural transcript equality across all three rounds",
        "vendor_model_perturbation": False}
    bench = evidence.directory / "inputs" / BENCHES["loader"][0]
    replay(evidence, tools, "loader-external-contract", [cores[0]], bench, "p3_loader_tb",
           ["PT3B"], "loader", profile="external_contract", role="external_contract")
    require(len(evidence.record["replays"]) == 9 and
            all(item["status"] == "passed" for item in evidence.record["replays"]),
            "incomplete required replay matrix")
    for path, sha in watched.items():
        require(digest(path.read_bytes()) == sha, f"consumed input changed during replay: {path}")
    require(inventory(prefix) == provider["installed_sha256"], "provider changed during replay")
    require(evidence.run(["git", "-C", pdk, "rev-parse", "HEAD"])[1].strip() == revision
            and not evidence.run(["git", "-C", pdk, "status", "--porcelain=v1", "--untracked-files=all"])[1],
            "PDK changed during replay")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", type=Path, required=True)
    parser.add_argument("--core-emitter", type=Path, required=True)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--pdk-root", default=os.environ.get("PT3B_PDK_ROOT") or None, type=Path)
    parser.add_argument("--evidence-dir", default=os.environ.get("PT3B_EVIDENCE_DIR") or "")
    args = parser.parse_args()
    # Dune's workspace_root can name its build mirror. Locate the authored checkout.
    root = args.source_root.resolve()
    while not (root / ".git").exists():
        require(root != root.parent, "source root is not inside a Git checkout")
        root = root.parent
    directory = (Path(args.evidence_dir) if args.evidence_dir else root / "_flow_results/pt3b" /
                 (datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ-") + uuid.uuid4().hex[:12]))
    evidence = Evidence(directory.absolute(), root)
    print(f"PT3b evidence: {evidence.directory}", flush=True)
    try:
        args.cli = args.cli.resolve(strict=True)
        args.core_emitter = args.core_emitter.resolve(strict=True)
        for key in ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
                    "NUMEXPR_NUM_THREADS", "VECLIB_MAXIMUM_THREADS"):
            os.environ[key] = "1"
        execute(args, evidence)
        evidence.record["status"] = "passed"
    except BaseException as error:
        evidence.record.update(status="failed", error=f"{type(error).__name__}: {error}")
        for item in evidence.record["replays"]:
            if item["status"] == "running":
                item.update(status="failed", error=evidence.record["error"])
        raise
    finally:
        evidence.record["sha256"] = {k: v for k, v in inventory(evidence.directory).items()
                                     if k != "receipt.json"}
        evidence.save()
    print("PASS PT3b memory+loader four source roles plus required external-contract oracle; "
          "positive replay and negative comparison self-checks")


if __name__ == "__main__":
    main()
