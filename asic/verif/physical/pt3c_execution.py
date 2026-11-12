#!/usr/bin/env python3
"""Explicit PT3c execution ownership; no emission, builds, provisioning or replay.

No arguments prints help. inspect/freeze perform no runtime probes. preflight/run
require a coordinator allocation and start a detached, persistent supervisor.
The installed provider owns its process groups and containers; cancellation is
forwarded to that provider, never to unrelated processes or containers.
"""

import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[3]
SCRIPT = Path(__file__).resolve()
STATE = ROOT / ".dev/pt3a-provider"
TC = ROOT.parent / "hardcaml_asic/.toolchain"
LOCK = ROOT.parent / ".protemu-build.lock"
TOP = "tt_um_leemperor_hardcaml_protemu_loader"
STOCK = "RM_IHPSG13_1P_256x16_c2_bm_bist"
IMAGE = "sha256:d109140b8f17fc54f4fca998beb8124f4949404ec52e339eebd2250854a18b5a"
LIMITS = {"tool_workers": 6, "container_cpus": 6, "sta_workers": 1}
TERMINAL = {"completed", "failed", "cancelled"}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def load(path):
    return json.loads(Path(path).read_text())


def sha(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def save(path, value, exclusive=False):
    path = Path(path)
    data = json.dumps(value, indent=2, sort_keys=True) + "\n"
    if exclusive:
        with path.open("x") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
    else:
        temporary = path.with_name(path.name + ".pending")
        with temporary.open("w") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        temporary.replace(path)


def child(root, relative):
    require(isinstance(relative, str) and relative and not Path(relative).is_absolute(),
            "expected relative input path")
    path = (root / relative).resolve(strict=True)
    require(path.is_relative_to(root.resolve()), f"input escapes root: {relative}")
    require(path.is_file(), f"not a file: {path}")
    return path


def query(argv):
    result = subprocess.run(argv, cwd=ROOT, stdin=subprocess.DEVNULL,
                            capture_output=True, text=True, timeout=30,
                            env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"})
    require(result.returncode == 0, f"readiness query failed: {argv}: {result.stderr}")
    return result.stdout.strip()


def lock_values(path):
    return dict(line.split("=", 1) for line in path.read_text().splitlines()
                if line and not line.startswith("#"))


def provider_command(*args):
    return ["bash", str(ROOT / "scripts/with-private-asic.sh"),
            "hardcaml-asic-flow", *map(str, args)]


def readiness():
    """Static/local inventories only: never docker run, Nix evaluation or EDA."""
    receipt_path = STATE / "receipt.json"
    receipt = load(receipt_path)
    prefix = STATE / "prefix"
    require(receipt["checks_passed"] is True and receipt["prefix"] == str(prefix),
            "invalid private-provider receipt")
    actual = {}
    for path in sorted(prefix.rglob("*")):
        require(not path.is_symlink(), f"provider symlink: {path}")
        if path.is_file():
            actual[str(path.relative_to(prefix))] = sha(path)
    require(actual == receipt["installed_sha256"], "private provider inventory changed")
    require(sha(STATE / "bin/dune") == receipt["dune_budget_sha256"], "Dune guard changed")
    pins = lock_values(ROOT / "asic/tinytapeout/asic-dependencies.lock")
    toolpins = lock_values(ROOT / "asic/tinytapeout/toolchain.lock")
    installed = lock_values(prefix / "lib/hardcaml_asic/flow/hardcaml_asic_flow/data/toolchain.lock")
    require(pins["asic_revision"] == receipt["revision"], "ASIC dependency/receipt mismatch")
    revisions = {}
    for name, key in (("tt", "support_tools_revision"), ("pdk", "pdk_revision")):
        path = TC / name
        revisions[name] = query(["git", "-C", str(path), "rev-parse", "HEAD"])
        require(revisions[name] == pins[key] == toolpins[key] == installed[key],
                f"{name} revision mismatch")
        require(not query(["git", "-C", str(path), "status", "--porcelain"]),
                f"{name} checkout dirty")
    for key in ("librelane_version", "python"):
        require(pins[key] == toolpins[key] == installed[key], f"tool pin mismatch: {key}")
    require(pins["librelane_version"] == "3.1.0.dev3" and pins["python"] == "3.11",
            "unsupported runtime pins")
    for name in (".venv", ".venv-precheck"):
        require(os.access(TC / name / "bin/python", os.X_OK), f"missing {name} Python")
        require("version = 3.11." in (TC / name / "pyvenv.cfg").read_text(),
                f"{name} must use Python 3.11")
    image = query(["docker", "image", "inspect", "ghcr.io/librelane/librelane:3.1.0.dev3",
                   "--format", "{{.Id}}"])
    require(image == IMAGE, "tested local image mismatch; no automatic pull")
    for program in ("docker", "nix-shell"):
        require(any(os.access(Path(p) / program, os.X_OK)
                    for p in ("/usr/local/bin", "/usr/bin", "/bin")), f"missing {program}")
    tracked = [receipt_path, STATE / "bin/dune", ROOT / "scripts/with-private-asic.sh",
               ROOT / "scripts/private-asic-env.py", SCRIPT,
               ROOT / "asic/tinytapeout/asic-dependencies.lock",
               ROOT / "asic/tinytapeout/toolchain.lock"]
    tracked += [TC / name / "pyvenv.cfg" for name in (".venv", ".venv-precheck")]
    return {"provider_revision": receipt["revision"], "provider_source_identity": "external_receipt",
            "toolchain": str(TC), "collateral_revisions": revisions, "image_id": image,
            "tracked_sha256": {str(p): sha(p) for p in tracked},
            "resource_limits": LIMITS, "runtime_preflight": "not_run",
            "task_limit_claim": "CPU/tool bounds, not a global six-task guarantee"}


def bundle_snapshot(bundle):
    bundle = Path(bundle).resolve(strict=True)
    manifest = load(bundle / "manifest.json")
    require(manifest["top_module"] == TOP and manifest["project"] == "protemu_loader",
            "requires the actual loader package")
    require(manifest["operation"] == "Hardening", "requires a fresh Hardening bundle")
    contract = manifest["macro_contract"]
    require(contract["schema_version"] == 2 and contract["execution"] == "fresh_full",
            "requires schema-2 fresh_full macro contract")
    macros = contract["macros"]
    require(len(macros) == 1, "requires exactly one program SRAM")
    macro = macros[0]
    require(macro["resource"] == "program" and macro["module"] == STOCK,
            "requires the stock Exact program SRAM")
    intent = macro["physical_intent"]
    require(intent["location_um"] == [40, 480] and intent["halo_um"] == 2
            and intent["orientation"] == "R0", "requires reviewed program(40,480), halo2, R0")
    require(intent["power"] == {"VDD!": "VPWR", "VDDARRAY!": "VPWR", "VSS!": "VGND"},
            "unexpected SRAM supplies")
    for entry in manifest["files"]:
        require(sha(child(bundle, entry["path"])) == entry["sha256"],
                f"bundle file changed: {entry['path']}")
    sources = {}
    for entry in manifest["source_inputs"]:
        source = child(ROOT, entry["path"])
        require(sha(source) == entry["sha256"] == sha(child(bundle, entry["copy"])),
                f"source not frozen at emitted bytes: {entry['path']}")
        sources[entry["path"]] = entry["sha256"]
    require(sources, "empty source inventory")
    require(load(bundle / "physical/macro-plan.json") == contract["physical_plan"],
            "physical plan mismatch")
    return {"bundle": str(bundle), "identity": manifest["identity"],
            "manifest_sha256": sha(bundle / "manifest.json"), "sources_sha256": sources,
            "head": query(["git", "rev-parse", "HEAD"]),
            "git_status": query(["git", "status", "--porcelain"]),
            "macro_instance": macro["instance"]}


def verify_freeze(frozen):
    require(frozen["schema"] == 1, "unsupported freeze receipt")
    current = bundle_snapshot(frozen["bundle"]["bundle"])
    # Unrelated owners may edit non-input files; the declared source bytes and HEAD
    # are frozen, not the entire worktree's status string.
    for key in ("bundle", "identity", "manifest_sha256", "sources_sha256", "head", "macro_instance"):
        require(current[key] == frozen["bundle"][key], f"freeze changed: {key}")
    require(readiness() == frozen["readiness"], "provider/toolchain readiness changed after freeze")


def process_identity(pid):
    try:
        data = Path(f"/proc/{pid}/stat").read_text()
        # comm can contain spaces and parentheses; fields after its final ')' start at state.
        fields = data[data.rindex(")") + 2:].split()
        return {"pid": pid, "pgid": os.getpgid(pid), "start_ticks": fields[19],
                "boot_id": Path("/proc/sys/kernel/random/boot_id").read_text().strip()}
    except (OSError, ValueError):
        return None


def checked_outcome(value, runs, identity):
    run = Path(value["run_dir"]).resolve(strict=True)
    require(run.parent == runs.resolve(), "provider outcome escaped this attempt's runs")
    require(Path(value["run_record"]).resolve() == run / "run.json", "run record path mismatch")
    record = load(run / "run.json")
    require(record["run_id"] == value["run_id"] and record["build_identity"] == identity,
            "provider outcome identity mismatch")
    require(record["requested_stage"] == "full", "provider outcome is not full")
    require(record["status"] == value["status"], "provider outcome status mismatch")
    return run, record


def host_resources():
    memory = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
    disk = os.statvfs(ROOT)
    return {"available_memory_kib": int(memory["MemAvailable"].split()[0]),
            "free_disk_bytes": disk.f_bavail * disk.f_frsize,
            "load_average": list(os.getloadavg()),
            "memory_pressure": Path("/proc/pressure/memory").read_text()}


def resource_gate(min_available_gib):
    resources = host_resources()
    require(resources["available_memory_kib"] >= min_available_gib * 1024**2,
            "insufficient available memory for the assigned launch")
    require(resources["free_disk_bytes"] >= 10 * 1024**3, "less than 10 GiB free disk")
    return resources


def inspect_attempt(directory):
    directory = Path(directory).resolve(strict=True)
    with (directory / "owner.lock").open("r") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            alive = False
        except BlockingIOError:
            alive = True
        receipt = load(directory / "receipt.json")
        owner = receipt.get("supervisor")
        alive = bool(alive and owner and owner == process_identity(owner["pid"]))
    receipt["owner_alive"] = alive
    if receipt["status"] not in TERMINAL and not alive:
        receipt["monitor_warning"] = "writer absent; do not relaunch or assume container cleanup"
    return receipt


class Supervisor:
    def __init__(self, directory):
        self.directory = directory
        self.request = load(directory / "request.json")
        self.receipt = load(directory / "receipt.json")
        self.cancelled = False
        self.provider = None
        self.started = time.monotonic()

    def publish(self, **fields):
        self.receipt.update(fields)
        self.receipt["heartbeat_unix"] = time.time()
        save(self.directory / "receipt.json", self.receipt)
        sample = {key: self.receipt.get(key) for key in
                  ("heartbeat_unix", "status", "phase", "resources", "provider_status", "container_name")}
        with (self.directory / "monitor.jsonl").open("a") as stream:
            stream.write(json.dumps(sample, sort_keys=True) + "\n")
            stream.flush()

    def signal(self, number, _frame):
        self.cancelled = True
        if self.provider is not None and self.provider.poll() is None:
            # The provider supervises its own process group and owned Docker resource.
            self.provider.send_signal(signal.SIGTERM)

    def single_run(self):
        records = list((self.directory / "runs").glob("*/run.json"))
        require(len(records) <= 1, "multiple runs in exclusive attempt; refusing to guess")
        if not records:
            return
        record = load(records[0])
        require(record["build_identity"] == self.request["freeze"]["bundle"]["identity"],
                "unexpected run in exclusive attempt")
        self.receipt["observed_run_record"] = str(records[0])
        self.receipt["execution_log"] = str(records[0].parent / "execution.log")
        self.receipt["provider_status"] = record["status"]
        self.receipt["container_name"] = record.get("container_name")
        self.receipt["provider_resource_limits"] = record.get("resource_limits")

    def phase(self, name, args):
        require(not self.cancelled, "execution cancelled")
        argv = provider_command(*args)
        out = self.directory / f"{name}.stdout"
        err = self.directory / f"{name}.stderr"
        phase = {"name": name, "argv": argv, "stdout": str(out), "stderr": str(err),
                 "started_unix": time.time(), "returncode": None}
        self.receipt.setdefault("phases", []).append(phase)
        self.publish(phase=name)
        with out.open("xb") as stdout, err.open("xb") as stderr:
            self.provider = subprocess.Popen(argv, cwd=ROOT, stdin=subprocess.DEVNULL,
                                             stdout=stdout, stderr=stderr)
            try:
                phase["process"] = process_identity(self.provider.pid)
                self.publish()
                cancellation_at = None
                while self.provider.poll() is None:
                    if time.monotonic() - self.started > self.request["max_seconds"]:
                        self.cancelled = True
                        self.receipt["deadline_exceeded"] = True
                    if self.cancelled:
                        if cancellation_at is None:
                            cancellation_at = time.monotonic()
                            self.provider.terminate()
                        elif time.monotonic() - cancellation_at > 60:
                            # Do not kill the provider while daemon-owned cleanup is pending.
                            self.receipt["cleanup_attention"] = "provider still draining cancellation after 60s"
                    self.single_run()
                    self.publish(resources=host_resources())
                    time.sleep(2)
                phase["returncode"] = self.provider.wait()
            finally:
                # Even monitor/publication errors must not abandon a live provider.
                # Provider cancellation already bounds owned process/container cleanup.
                if self.provider.poll() is None:
                    self.provider.terminate()
                    self.provider.wait()
                self.provider = None
        phase["ended_unix"] = time.time()
        self.single_run()
        self.publish()
        return phase["returncode"]

    def run(self):
        for number in (signal.SIGINT, signal.SIGTERM):
            signal.signal(number, self.signal)
        # An interactive caller disconnecting cannot kill the persistent owner.
        signal.signal(signal.SIGHUP, signal.SIG_IGN)
        with (self.directory / "owner.lock").open("r+") as owner:
            fcntl.flock(owner, fcntl.LOCK_EX | fcntl.LOCK_NB)
            # A crashed or failed attempt is never silently restarted in place.
            with (self.directory / "supervisor.claim").open("x") as claim:
                claim.write(json.dumps(process_identity(os.getpid())) + "\n")
            self.publish(supervisor=process_identity(os.getpid()), status="checking")
            try:
                require(self.request["operation"] in ("preflight", "run")
                        and self.request["allocation"] == "serial6"
                        and self.request["coordinator"].strip(), "invalid allocated request")
                require(sha(SCRIPT) == self.request["script_sha256"], "supervisor source changed")
                # No waiting queue: an allocation must still be valid when launched.
                with LOCK.open("r+") as shared:
                    fcntl.flock(shared, fcntl.LOCK_EX | fcntl.LOCK_NB)
                    verify_freeze(self.request["freeze"])
                    resources = resource_gate(self.request["min_available_gib"])
                    self.publish(status="running", shared_lock=str(LOCK), resources=resources)
                    bundle = self.request["freeze"]["bundle"]["bundle"]
                    code = self.phase("preflight", ["preflight", bundle, "--toolchain", TC,
                                      "--results-root", self.directory,
                                      "--output", self.directory / "preflight.json", "--json"])
                    require(code == 0 and load(self.directory / "preflight.json")["ready"] is True,
                            "runtime preflight failed; full flow was not launched")
                    verify_freeze(self.request["freeze"])
                    if self.request["operation"] == "run":
                        self.publish(resources=resource_gate(self.request["min_available_gib"]))
                        code = self.phase("full", ["run", bundle, "--toolchain", TC,
                                          "--runs", self.directory / "runs", "--stage", "full", "--json"])
                        # Outcome stdout, never a newest-run heuristic, binds final paths.
                        value = load(self.directory / "full.stdout")
                        run, record = checked_outcome(value, self.directory / "runs",
                                                      self.request["freeze"]["bundle"]["identity"])
                        self.publish(provider_outcome=value, run_dir=str(run),
                                     run_record=str(run / "run.json"),
                                     flow_dir=str(run / "project/runs/asic"),
                                     routed_netlist=str(run / f"project/runs/asic/final/nl/{TOP}.nl.v"))
                        # Collection/reporting preserve failures as well as successes.
                        if not self.cancelled:
                            collect_code = self.phase("collect", ["collect", run, "--json"])
                            report_code = self.phase("report", ["report", run, "--json"])
                            self.publish(collect_exit_code=collect_code, report_exit_code=report_code)
                            require(collect_code == 0, "collection failed")
                            # report's exit status is an acceptance verdict, not run completion.
                            # Pre-replay acceptance is intentionally not yet established.
                            load(self.directory / "report.stdout")
                            self.publish(results=str(run / "results.json"),
                                         report_json=str(self.directory / "report.stdout"))
                        require(code == 0 and value["exit_code"] == 0 and record["status"] == "completed"
                                and record["completed_stage"] == "full", "physical execution failed")
                        require(record["resource_limits"] == LIMITS, "unexpected effective provider limits")
                        verify_freeze(self.request["freeze"])
                    require(not self.cancelled, "execution cancelled")
                    self.receipt.update(status="completed", acceptance="not_evaluated_replay_owned_separately")
            except Exception as error:
                self.receipt.update(status="cancelled" if self.cancelled else "failed", error=str(error))
            finally:
                self.receipt.update(ended_unix=time.time(), phase="terminal", heartbeat_unix=time.time())
                # Publish the durable terminal outcome before advertising terminal status.
                save(self.directory / "outcome.json", self.receipt, exclusive=True)
                self.publish()
        return 0 if self.receipt["status"] == "completed" else 1


def launch(args):
    frozen_bytes = args.freeze.read_bytes()
    frozen = json.loads(frozen_bytes)
    verify_freeze(frozen)
    directory = args.evidence.resolve()
    require(directory.parent.is_dir(), "evidence parent must already exist")
    directory.mkdir()  # Existing attempts, including failed attempts, are never reused.
    (directory / "owner.lock").touch()
    # Retain activation/identity inputs, not only pointers to mutable local state.
    snapshots = directory / "owner-inputs"
    snapshots.mkdir()
    inventory = []
    for index, (path, expected) in enumerate(frozen["readiness"]["tracked_sha256"].items()):
        data = Path(path).read_bytes()
        require(hashlib.sha256(data).hexdigest() == expected, f"owner input changed: {path}")
        retained = snapshots / f"{index:02d}-{Path(path).name}"
        with retained.open("xb") as stream:
            stream.write(data)
        inventory.append({"source": path, "snapshot": str(retained), "sha256": expected})
    request = {"schema": 1, "operation": args.command, "freeze": frozen,
               "freeze_path": str(args.freeze.resolve()),
               "freeze_sha256": hashlib.sha256(frozen_bytes).hexdigest(),
               "allocation": "serial6", "coordinator": args.coordinator,
               "global_job_budget": 20, "max_seconds": args.max_seconds,
               "min_available_gib": args.min_available_gib,
               "owner_input_snapshots": inventory,
               "script_sha256": sha(SCRIPT)}
    save(directory / "request.json", request, exclusive=True)
    save(directory / "receipt.json", {"schema": 1, "status": "starting", "operation": args.command,
         "evidence": str(directory), "resource_limits": LIMITS, "allocation": "serial6",
         "coordinator": args.coordinator, "acceptance": "not_evaluated",
         "outcome_path": str(directory / "outcome.json"),
         "supervisor_log": str(directory / "supervisor.log"),
         "monitor_log": str(directory / "monitor.jsonl"),
         "task_limit_claim": "CPU/tool concurrency only; not total OS tasks"}, exclusive=True)
    with (directory / "supervisor.log").open("xb") as log:
        process = subprocess.Popen([sys.executable, "-B", str(SCRIPT), "_supervise", str(directory)],
                                   cwd=ROOT, stdin=subprocess.DEVNULL, stdout=log, stderr=log,
                                   start_new_session=True, close_fds=True)
    # Return well inside an API timeout; the session-independent owner persists.
    print(json.dumps({"receipt": str(directory / "receipt.json"),
                      "supervisor": process_identity(process.pid), "evidence": str(directory)}))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command")
    inspect = commands.add_parser("inspect", help="read-only local readiness; no probes")
    inspect.add_argument("--bundle", type=Path)
    freeze = commands.add_parser("freeze", help="bind current emitted source bytes after owners freeze")
    freeze.add_argument("--bundle", required=True, type=Path)
    freeze.add_argument("--output", required=True, type=Path)
    for name in ("preflight", "run"):
        command = commands.add_parser(name, help="explicit allocated detached execution")
        command.add_argument("--freeze", required=True, type=Path)
        command.add_argument("--evidence", required=True, type=Path)
        command.add_argument("--allocation", required=True, choices=["serial6"])
        command.add_argument("--coordinator", required=True, help="allocation reference/owner")
        command.add_argument("--max-seconds", type=int, default=86400,
                             help="whole-attempt deadline, then graceful provider cancellation")
        command.add_argument("--min-available-gib", type=int, default=8,
                             help="launch-time MemAvailable floor (default 8 GiB)")
    for name in ("monitor", "cancel"):
        command = commands.add_parser(name)
        command.add_argument("evidence", type=Path)
        if name == "monitor":
            command.add_argument("--watch", action="store_true")
    internal = commands.add_parser("_supervise", help=argparse.SUPPRESS)
    internal.add_argument("evidence", type=Path)
    args = parser.parse_args()
    if args.command is None:
        parser.print_help()
    elif args.command == "inspect":
        result = {"readiness": readiness(), "resources": host_resources()}
        if args.bundle:
            result["bundle"] = bundle_snapshot(args.bundle)
        print(json.dumps(result, indent=2))
    elif args.command == "freeze":
        value = {"schema": 1, "created_unix": time.time(), "bundle": bundle_snapshot(args.bundle),
                 "readiness": readiness()}
        verify_freeze(value)
        save(args.output, value, exclusive=True)
        print(args.output.resolve())
    elif args.command in ("preflight", "run"):
        require(args.max_seconds > 0 and args.min_available_gib > 0 and args.coordinator.strip(),
                "positive deadline/memory floor and allocation owner required")
        launch(args)
    elif args.command == "_supervise":
        return Supervisor(args.evidence).run()
    elif args.command == "monitor":
        while True:
            value = inspect_attempt(args.evidence)
            print(json.dumps(value, indent=2), flush=True)
            if not args.watch or value["status"] in TERMINAL or not value["owner_alive"]:
                return 0 if value["status"] == "completed" else 1
            time.sleep(5)
    elif args.command == "cancel":
        value = inspect_attempt(args.evidence)
        require(value["status"] not in TERMINAL and value["owner_alive"], "no verified live supervisor")
        owner = value["supervisor"]
        require(owner == process_identity(owner["pid"]), "supervisor PID identity changed")
        os.kill(owner["pid"], signal.SIGTERM)
        print("Cancellation requested; monitor until provider cleanup and terminal receipt.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)  # Stopping the monitor does not stop the execution owner.
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        sys.exit(f"pt3c execution: {error}")
