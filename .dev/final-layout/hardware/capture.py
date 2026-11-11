"""Capture hardware migration evidence without invoking the build."""
import hashlib
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = pathlib.Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def destination(source):
    if source == "rtl/protemu_top.ml":
        return "ip/protemu_system/rtl/protemu_top.ml", "Protemu_system"
    if source.startswith("chip_top/rtl/bringup/"):
        return source.replace("chip_top/", "asic/", 1), "Protemu_asic_bringup"
    groups = [
        ("ip/mechanisms/rtl/staging/", "Protemu_mechanisms_staging"),
        ("ip/mechanisms/rtl/", "Protemu_mechanisms"),
        ("ip/program_memory_controller/rtl/", "Protemu_controller"),
        ("ip/emulator_core/rtl/legacy/", "Protemu_core_legacy"),
        ("ip/emulator_core/rtl/", "Protemu_core"),
        ("ip/host_link/rtl/", "Protemu_host_link"),
    ]
    return source, next(namespace for prefix, namespace in groups if source.startswith(prefix))


def capture():
    sources = []
    for relative in re.findall(r"\(copy_files ../([^\s)]+)\)", (ROOT / "lib/dune").read_text()):
        target, namespace = destination(relative)
        module = pathlib.Path(relative).stem.capitalize()
        sources.append(dict(source=relative, destination=target, sha256=digest(ROOT / relative),
                            old_namespace="Hardcaml_protemu." + module,
                            namespace=namespace + "." + module))
    assert len(sources) == 26
    baseline = ROOT / ".dev/am3/integrated-final-20261111"
    outputs = {str(path.relative_to(ROOT)): digest(path)
               for directory in (baseline / "generated", baseline / "bundles")
               for path in sorted(directory.rglob("*")) if path.is_file()}
    (OUT / "before.json").write_text(json.dumps(dict(sources=sources, am3_outputs=outputs), indent=2) + "\n")
    print(f"Captured {len(sources)} hardware sources and {len(outputs)} AM3 files")


if __name__ == "__main__":
    capture()
