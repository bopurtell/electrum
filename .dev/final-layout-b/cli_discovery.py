"""Exercise dispatch/root discovery using an invalid step rejected before flow work."""
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PROBE = "__final_layout_root_discovery_probe__"
commands = [
    (ROOT, [str(ROOT / "scripts/with-switch.sh"), "dune", "exec", "-j5", "protemu", "--", "flow", PROBE], False),
    (ROOT / "software/cli/examples", [str(ROOT / "scripts/with-switch.sh"), "dune", "exec", "-j5", "protemu", "--", "flow", PROBE], False),
    (Path("/tmp/opencode"), [str(ROOT / "_build/default/software/cli/protemu.exe"), "flow", PROBE], True),
]
results = []
for cwd, command, direct in commands:
    env = dict(os.environ)
    if direct:
        env.pop("DUNE_SOURCEROOT", None)
    run = subprocess.run(command, cwd=cwd, env=env, capture_output=True, text=True)
    assert run.returncode == 2, (command, run.returncode, run.stdout, run.stderr)
    assert f"flow: unknown step: {PROBE}" in run.stderr, run.stderr
    assert "cannot find the repository root" not in run.stderr
    results.append({"cwd": str(cwd), "command": command, "exit": run.returncode, "stderr": run.stderr})
print(json.dumps(results, indent=2))
