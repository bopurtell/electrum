"""Validate the private provider receipt before executing a consumer command."""
import hashlib
import json
import os
from pathlib import Path
import sys


def main():
    root = Path(__file__).resolve().parent.parent
    state = root / ".dev/pt3a-provider"
    receipt = json.loads((state / "receipt.json").read_text())
    prefix = state / "prefix"
    if receipt["prefix"] != str(prefix) or receipt["checks_passed"] is not True:
        raise ValueError("private provider receipt does not match this installation")
    actual = {}
    for path in sorted(prefix.rglob("*")):
        if path.is_symlink():
            raise ValueError(f"unexpected provider symlink: {path}")
        if path.is_file():
            actual[str(path.relative_to(prefix))] = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != receipt["installed_sha256"]:
        raise ValueError("private provider inventory changed; refusing switch fallback")
    switch = Path(receipt["switch_prefix"])
    shim = state / "bin/dune"
    if hashlib.sha256(shim.read_bytes()).hexdigest() != receipt["dune_budget_sha256"]:
        raise ValueError("private Dune budget guard changed")
    env = dict(os.environ)
    # Explicit paths replace ambient overlays; the switch supplies only the base
    # toolchain/dependencies. ASIC is always resolved from the verified prefix.
    env.update(
        PATH=f"{state}/bin:{prefix}/bin:{switch}/bin:/usr/local/bin:/usr/bin:/bin",
        OCAMLPATH=f"{prefix}/lib:{switch}/lib",
        CAML_LD_LIBRARY_PATH=f"{prefix}/lib/stublibs:{switch}/lib/stublibs",
        OPAM_SWITCH_PREFIX=str(switch),
        OPAMSWITCH=receipt["switch"],
        OCAMLLIB=str(switch / "lib/ocaml"),
        CAMLLIB=str(switch / "lib/ocaml"),
        PT3A_REAL_DUNE=str(switch / "bin/dune"),
        DUNE_BUILD_DIR=str(state / "consumer-build"),
        PROTEMU_ASIC_PREFIX=str(prefix),
        PROTEMU_ASIC_RECEIPT=str(state / "receipt.json"),
        DUNEJOBS="1", OPAMJOBS="1", MAKEFLAGS="-j1",
        HARDCAML_ASIC_TEST_WORKERS="2",
        OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", MKL_NUM_THREADS="1",
        NUMEXPR_NUM_THREADS="1", VECLIB_MAXIMUM_THREADS="1",
    )
    for key in ("OCAMLFIND_CONF", "OCAMLFIND_DESTDIR", "OCAMLFIND_TOOLCHAIN",
                "DUNE_WORKSPACE", "DUNE_PROFILE"):
        env.pop(key, None)
    if len(sys.argv) < 2:
        raise ValueError("usage: bash scripts/with-private-asic.sh COMMAND [ARG ...]")
    os.execvpe(sys.argv[1], sys.argv[1:], env)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError) as error:
        sys.exit(f"private ASIC environment: {error}")
