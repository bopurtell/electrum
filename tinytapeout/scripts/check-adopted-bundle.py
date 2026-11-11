#!/usr/bin/env python3
"""Check fresh observable, memory, and loader ASIC bundles and wrapper traces."""

import argparse
import hashlib
import json
import pathlib
import subprocess
import tempfile


def run(*args, cwd=None, quiet=False):
    subprocess.run(
        args,
        cwd=cwd,
        check=True,
        stdout=subprocess.DEVNULL if quiet else None,
    )


def lock_values(path):
    return dict(
        line.split("=", 1)
        for line in path.read_text().splitlines()
        if line and not line.startswith("#")
    )


def check_bundle(root, bundle, kind):
    manifest = json.loads((bundle / "manifest.json").read_text())
    config = json.loads((bundle / "src/config.json").read_text())
    lock = lock_values(root / "tinytapeout/asic-dependencies.lock")
    assert manifest["source_revision"] == subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=root, text=True
    ).strip()
    suffix = {"observable": "", "memory": "_memory", "loader": "_loader"}[kind]
    assert manifest["top_module"] == "tt_um_leemperor_hardcaml_protemu" + suffix
    assert manifest["project"] == "protemu_" + kind
    assert manifest["requested_tools"] == {
        "support_tools_revision": lock["support_tools_revision"],
        "pdk_revision": lock["pdk_revision"],
        "librelane": lock["librelane_version"],
        "python": lock["python"],
    }
    assert manifest["synthesis_sources"] == [
        "src/tt_um_leemperor_hardcaml_protemu" + suffix + ".v"
    ]
    assert manifest["simulation_sources"] == [
        "simulation/tt_um_leemperor_hardcaml_protemu" + suffix + ".v"
    ]
    assert config["CLOCK_PORT"] == "clk"
    assert abs(config["CLOCK_PERIOD"] - 1e9 / 48e6) < 1e-10
    assert config["DESIGN_NAME"] == manifest["top_module"]
    assert config["VERILOG_FILES"] == [
        "dir::tt_um_leemperor_hardcaml_protemu" + suffix + ".v"
    ]
    assert config["PNR_SDC_FILE"] == "dir::../constraints/top.sdc"
    assert config["SIGNOFF_SDC_FILE"] == "dir::../constraints/top.sdc"
    assert "tt_block_6x4_pgvdd.def" in config["FP_DEF_TEMPLATE"]
    info = (bundle / "info.yaml").read_text()
    assert 'tiles: "6x4"' in info
    assert f'top_module: "{manifest["top_module"]}"' in info
    assert "create_clock -name clk" in (bundle / "constraints/top.sdc").read_text()
    source_paths = {item["path"] for item in manifest["source_inputs"]}
    expected_source = {
        "observable": "chip_top/rtl/bringup/p0_observable.ml",
        "memory": "ip/program_memory_controller/rtl/program_memory_controller.ml",
        "loader": "ip/host_link/rtl/host_link.ml",
    }[kind]
    assert {
        "bin/asic_bundle.ml", expected_source, "tinytapeout/asic-dependencies.lock",
        "chip_top/project/dune", "chip_top/project/chip_project.ml",
    } <= source_paths
    package_sources = {
        "observable": {"chip_top/rtl/observable_design.ml"},
        "memory": {"chip_top/rtl/memory_design.ml", "chip_top/rtl/program_memory.ml"},
        "loader": {"chip_top/rtl/package_top.ml", "chip_top/rtl/program_memory.ml"},
    }
    assert package_sources[kind] <= source_paths
    if kind == "observable":
        assert '"P0 command valid"' in info
        assert manifest["resources"] == []
        assert manifest["simulation_resources"] == []
    else:
        if kind == "memory":
            assert '"Memory request opcode bit 2 / response bit 7"' in info
        else:
            assert 'ui[0]: "Loader select, active low"' in info
            assert 'uo[1]: "Loader response ready"' in info
            assert {"rtl/protemu_top.ml", "ip/emulator_core/rtl/emulator_core.ml"} <= source_paths
            assert {
                "host_link_protocol/dune",
                "host_link_protocol/definitions.ml",
                "host_link_protocol/codec.ml",
                "host_link_protocol/host_link_protocol.ml",
                "host_link_protocol/host_link_protocol.mli",
            } <= source_paths
            assert not any(path.startswith("host_link_wire/") for path in source_paths)
            assert "ip/emulator_core/rtl/control_port.ml" in source_paths
            assert "ip/host_link/rtl/serial_phy.ml" in source_paths
            assert "ip/host_link/rtl/frame_rx.ml" in source_paths
            assert "ip/host_link/rtl/frame_tx.ml" in source_paths
            assert "ip/host_link/rtl/command_dispatch.ml" in source_paths
            assert {"ip/host_link/rtl/wire_crc.ml", "ip/host_link/rtl/wire_layout.ml"} <= source_paths
        request = (
            "((kind single_port_ram)\n (contract\n  ((width 16) (depth 256) "
            "(read_latency 1) (port 1rw) (disabled_output hold)\n   "
            "(write_output unspecified))))"
        )
        expected = {
            "id": "program",
            "request": request,
            "requirement": "Flops",
            "policy": "Default",
            "selection": "((implementation Flops) (reason Explicit_flops))",
            "elaborated_as": "Selected_implementation",
            "source_roles": ["Generated_synthesis_rtl"],
        }
        simulation_expected = dict(expected)
        simulation_expected["elaborated_as"] = "Behavioral_model"
        simulation_expected["source_roles"] = ["Generated_behavioral_model"]
        assert manifest["resources"] == [expected]
        assert manifest["simulation_resources"] == [simulation_expected]
        synthesis_rtl = (bundle / manifest["synthesis_sources"][0]).read_text()
        simulation_rtl = (bundle / manifest["simulation_sources"][0]).read_text()
        assert "initial begin" not in synthesis_rtl
        assert "initial begin" in simulation_rtl
    for item in manifest["source_inputs"]:
        source = root / item["path"]
        copied = bundle / "inputs" / item["path"]
        assert copied.read_bytes() == source.read_bytes()
    for item in manifest["files"]:
        path = bundle / item["path"]
        assert hashlib.sha256(path.read_bytes()).hexdigest() == item["sha256"]
    return manifest["identity"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata-only", action="store_true")
    parser.add_argument(
        "--kind", choices=("observable", "memory", "loader"), default="observable"
    )
    args = parser.parse_args()
    root = pathlib.Path(__file__).resolve().parents[2]
    emitter = root / "_build/default/bin/asic_bundle.exe"
    run(str(emitter), "--check-conflicts", args.kind, cwd=root)
    with tempfile.TemporaryDirectory(prefix="protemu-adopted-") as scratch:
        scratch = pathlib.Path(scratch)
        first, second = scratch / "first", scratch / "second"
        run(str(emitter), args.kind, str(first), str(root), cwd=root)
        run(str(emitter), args.kind, str(second), str(root), cwd=root)
        assert check_bundle(root, first, args.kind) == check_bundle(root, second, args.kind)
        assert (first / "manifest.json").read_bytes() == (
            second / "manifest.json"
        ).read_bytes()
        print("PASS repeatable bundle, manifest, metadata, and conflict checks")
        if args.metadata_only:
            return
        image = "ghcr.io/librelane/librelane:" + lock_values(
            root / "tinytapeout/asic-dependencies.lock"
        )["librelane_version"]
        try:
            image_id = subprocess.check_output(
                ["docker", "image", "inspect", "--format", "{{.Id}}", image],
                text=True,
                stderr=subprocess.DEVNULL,
            ).strip()
        except (FileNotFoundError, subprocess.CalledProcessError) as error:
            raise SystemExit(
                f"pinned LibreLane image unavailable: {image}; "
                f"install Docker and run 'docker pull {image}'"
            ) from error
        suffix = {"observable": "", "memory": "_memory", "loader": "_loader"}[args.kind]
        top = "tt_um_leemperor_hardcaml_protemu" + suffix
        if args.kind == "loader":
            for role in ("simulation", "src"):
                obj_dir = scratch / ("loader-" + role)
                source = first / role / f"{top}.v"
                run(
                    "verilator",
                    "--binary",
                    "--timing",
                    "--Mdir",
                    str(obj_dir),
                    "--top-module",
                    "p3_loader_tb",
                    "-DLOADER_WRAPPER",
                    "-Wno-DECLFILENAME",
                    "-Wno-COMBDLY",
                    "-Wno-TIMESCALEMOD",
                    "-Wno-INITIALDLY",
                    "-Wno-WIDTHTRUNC",
                    "-Wno-WIDTHEXPAND",
                    "-Wno-ZERODLY",
                    str(source),
                    str(root / "verif/system/emitted/p3_loader_tb.v"),
                    "-j",
                    "1",
                    cwd=root,
                    quiet=True,
                )
                run(str(obj_dir / "Vp3_loader_tb"), cwd=root, quiet=True)
            commands = "\n".join([
                f"verilator --lint-only --top-module {top} -Wno-DECLFILENAME -Wno-COMBDLY /bundle/src/{top}.v",
                f"yosys -p 'read_verilog /bundle/src/{top}.v; hierarchy -check -top {top}; synth -top {top}; stat'",
            ])
        else:
            testbench = "tb.v" if args.kind == "observable" else "p0_memory_tb.v"
            commands = "\n".join([
                f"iverilog -g2012 -Wall -Wno-timescale -s tb -o /tmp/protemu-wrapper /bundle/src/{top}.v /test/{testbench}",
                "vvp /tmp/protemu-wrapper",
                f"iverilog -g2012 -Wall -Wno-timescale -s tb -o /tmp/protemu-wrapper-sim /bundle/simulation/{top}.v /test/{testbench}",
                "vvp /tmp/protemu-wrapper-sim",
                f"verilator --lint-only --top-module {top} -Wno-DECLFILENAME -Wno-COMBDLY /bundle/src/{top}.v",
                f"yosys -p 'read_verilog /bundle/src/{top}.v; hierarchy -check -top {top}; synth -top {top}; stat'",
            ])
        testbench_dir = (
            root / "verif/system/emitted"
            if args.kind == "loader"
            else root / "chip_top/verif" / args.kind / "emitted"
        )
        run(
            "docker",
            "run",
            "--rm",
            "--pull=never",
            "--network",
            "none",
            "-v",
            f"{first}:/bundle:ro",
            "-v",
            f"{testbench_dir}:/test:ro",
            "--entrypoint",
            "sh",
            image,
            "-ec",
            commands,
            quiet=True,
        )
        print(f"PASS emitted RTL wrapper roles, lint, and synthesis ({image_id})")


if __name__ == "__main__":
    main()
