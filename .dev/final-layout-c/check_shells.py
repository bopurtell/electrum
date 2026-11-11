"""Relocation checks that never provision tools or launch a flow step."""
import ast
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]


def main():
    scripts = sorted((ROOT / "scripts").glob("*.sh"))
    scripts += [ROOT / "asic/flow.sh"]
    scripts += sorted((ROOT / "asic/tinytapeout/scripts").glob("*.sh"))
    for path in scripts:
        subprocess.run(["bash", "-n", str(path)], check=True)
    python = sorted((ROOT / "asic/tinytapeout/scripts").glob("*.py"))
    for path in python:
        ast.parse(path.read_text(), filename=str(path))
    subprocess.run(["bash", str(ROOT / "asic/tinytapeout/scripts/check-flow.sh")],
                   cwd="/", check=True)
    with tempfile.TemporaryDirectory(prefix="protemu-env-layout-") as tmp:
        fixture = Path(tmp) / "checkout with spaces"
        (fixture / "scripts").mkdir(parents=True)
        source = fixture / "scripts/env.sh"
        source.write_bytes((ROOT / "scripts/env.sh").read_bytes())
        tools = fixture / "_flow_tools"
        (tools / "venv/bin").mkdir(parents=True)
        python = tools / "venv/bin/python"
        python.write_text("#!/bin/sh\nexit 0\n")
        python.chmod(0o755)
        env_file = tools / "toolchain-env.sh"
        env_file.write_text(f"export PDK_ROOT='{tools}/pdk'\nexport TT_SUPPORT_TOOLS_DIR='{tools}/tt'\n")
        stub = Path(tmp) / "stub"
        stub.mkdir()
        opam = stub / "opam"
        opam.write_text("#!/bin/sh\n[ \"$1\" = env ] || exit 98\nprintf ':\\n'\n")
        opam.chmod(0o755)
        command = r'''
set -eu
cd() { return 99; }
pwd() { return 99; }
grep() { return 99; }
paste() { return 99; }
source "$1"
source "$1"
[[ $PDK_ROOT == "$2/_flow_tools/pdk" ]]
[[ $TT_SUPPORT_TOOLS_DIR == "$2/_flow_tools/tt" ]]
[[ $VIRTUAL_ENV == "$2/_flow_tools/venv" ]]
[[ ${PATH%%:*} == "$VIRTUAL_ENV/bin" ]]
rest=${PATH#*:}
[[ :$rest: != *":$VIRTUAL_ENV/bin:"* ]]
[[ :$rest: != *":$3/bin:"* ]]
[[ -z ${_protemu_root+x} && -z ${_protemu_src+x} ]]
'''
        env = dict(os.environ, PATH=f"{stub}:/old-checkout/venv/bin:/usr/bin:/bin",
                   VIRTUAL_ENV="/old-checkout/venv")
        subprocess.run(["bash", "-c", command, "activation-check", str(source),
                        str(fixture), "/old-checkout/venv"], cwd="/", env=env, check=True)
    receipt = json.loads((OUT / "archive-receipt.json").read_text())
    index = (ROOT / "archive/INDEX.md").read_text()
    count = 0
    for move in receipt["moves"]:
        assert move["before"] == move["after"]
        for name, record in move["before"].items():
            display = "loader_core.v" if name == "." else name
            row = f'| `{display}` | {record["bytes"]} | `{record["sha256"]}` |'
            assert row in index, display
            count += 1
    assert count == 42
    result = {"shell_syntax": len(scripts), "python_syntax": 4,
              "stub_flow_checks": 17, "activation_from_other_cwd": True,
              "activation_repeated_and_previous_venv_removed": True,
              "activation_ignores_shell_function_collisions": True,
              "activation_checkout_path_with_spaces": True,
              "archive_index_rows_verified": count}
    (OUT / "shell-archive-checks.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
