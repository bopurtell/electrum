#!/usr/bin/env python3
"""Check fresh observable, memory, and loader ASIC bundles and wrapper traces."""

import argparse
import hashlib
import json
import os
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


def tree(root):
    return {str(path.relative_to(root)): path.read_bytes()
            for path in root.rglob("*") if path.is_file()}


def check_loader_physical(manifest, config, files):
    """Declaration geometry only: no placed database, power or routing acceptance."""
    assert manifest["project"] == "protemu_loader"
    assert manifest["operation"] == "Hardening"
    macro = "RM_IHPSG13_1P_256x16_c2_bm_bist"
    supplies = {"VDD!": "VPWR", "VDDARRAY!": "VPWR", "VSS!": "VGND"}
    candidate = {
        "resource": "program", "instance": "hc_resource_7_program", "module": macro,
        "location_um": [40., 480.], "orientation": "R0", "halo_um": 2.,
        "supplies": supplies,
    }
    contract = manifest["macro_contract"]
    assert contract["schema_version"] == 2
    assert contract["execution"] == "fresh_full"
    assert contract["physical_plan"] == {
        "schema_version": 1, "strategy": "cmos5l_m4_edge_access_v1",
        "plan_file": "physical/macro-plan.json", "pdn_tcl": "physical/pdn.tcl",
        "checking_profile": "cmos5l_real_gds_v1",
        "lvs_scope": "abstract_macro_boundary_with_schematic_cdl", "macros": [candidate],
    }
    assert json.loads(files["physical/macro-plan.json"]) == contract["physical_plan"]
    assert contract["macros"][0]["physical_intent"] == {
        "location_um": [40., 480.], "orientation": "R0", "halo_um": 2.,
        "power": supplies, "execution": "fresh_full",
    }
    assert set(config["MACROS"]) == {macro}
    assert config["MACROS"][macro]["instances"] == {
        "hc_resource_7_program": {"location": [40., 480.], "orientation": "R0"}}
    assert config["DIE_AREA"] == "0 0 1289.28 710.64"
    # Actual reference 6x4 geometry, not the example's (40,81) acceptance.
    core = (2.88, 3.78, 1286.4, 706.86)
    bounds = (40. - 2., 480. - 2., 40. + 236.8 + 2., 480. + 118.78 + 2.)
    assert core[0] <= bounds[0] < bounds[2] <= core[2]
    assert core[1] <= bounds[1] < bounds[3] <= core[3]
    assert config["FP_MACRO_HORIZONTAL_HALO"] == config["FP_MACRO_VERTICAL_HALO"] == 2.
    assert config["PDN_MACRO_CONNECTIONS"] == [
        "^hc_resource_7_program$ VPWR VGND VDD! VSS!",
        "^hc_resource_7_program$ VPWR VGND VDDARRAY! VSS!",
    ]
    assert config["PDN_CFG"] == "dir::../physical/pdn.tcl"
    assert config["PDN_CONNECT_MACROS_TO_GRID"] is True
    assert config["PDN_MULTILAYER"] is False
    assert config["PDN_VERTICAL_LAYER"] == "Metal4"
    assert (config["PDN_VWIDTH"], config["PDN_VPITCH"], config["PDN_VOFFSET"]) == (2.1, 50., 10.)
    assert config["PDN_RAIL_LAYER"] == "Metal1"
    assert config["PDN_RAIL_WIDTH"] == 0.44
    for key in ("PDN_ENABLE_RAILS", "PDN_ENABLE_PINS", "PDN_ENABLE_GLOBAL_CONNECTIONS"):
        assert config[key] is True
    assert config["PDN_SKIPTRIM"] is False and config["PDN_CORE_RING"] is False
    assert config["RUN_KLAYOUT_DRC"] is True
    assert not any(key.startswith("FP_PDN_") for key in config)
    obstruction, = config["ROUTING_OBSTRUCTIONS"]
    layer, *rectangle = obstruction.split()
    assert layer == "Metal4" and list(map(float, rectangle)) == [40., 480., 276.8, 598.78]
    pdn = files["physical/pdn.tcl"].decode()
    assert "resource $resource footprint/halo exceeds usable core" in pdn
    assert "no legal edge contact for $supply" in pdn
    assert "foreach supply {VDD! VDDARRAY! VSS!}" in pdn
    assert ("lappend ::hc_pdn::instances [list [encoding convertfrom utf-8 "
            "[binary decode hex 70726f6772616d]] {hc_resource_7_program} {" + macro +
            "} 40 480 2]") in pdn


def check_bundle(root, bundle, kind, selection="flops", operation=None):
    operation = operation or ("synthesis" if selection == "exact" else "hardening")
    assert operation in ("synthesis", "hardening")
    physical = selection == "exact" and operation == "hardening"
    manifest = json.loads((bundle / "manifest.json").read_text())
    payload = {key: value for key, value in manifest.items() if key != "identity"}
    assert hashlib.sha256(json.dumps(
        payload, separators=(",", ":"), ensure_ascii=False
    ).encode()).hexdigest() == manifest["identity"]
    files = tree(bundle)
    assert {item["path"] for item in manifest["files"]} == set(files) - {"manifest.json"}
    assert len(manifest["files"]) == len(files) - 1
    config = json.loads((bundle / "src/config.json").read_text())
    lock = lock_values(root / "asic/tinytapeout/asic-dependencies.lock")
    assert manifest["source_revision"] == subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=root, text=True
    ).strip()
    suffix = {"observable": "", "memory": "_memory", "loader": "_loader"}[kind]
    assert manifest["top_module"] == "tt_um_leemperor_hardcaml_protemu" + suffix
    assert manifest["project"] == "protemu_" + kind
    assert manifest["operation"] == operation.capitalize()
    assert config == manifest["flow_configuration"]
    assert manifest.get("timing_intent") is None
    assert manifest.get("timing_physical_qualification") is None
    if not physical:
        assert {key: config[key] for key in (
            "RUN_KLAYOUT_DRC", "FP_PDN_VPITCH", "FP_PDN_VWIDTH", "FP_PDN_MULTILAYER")} == {
                "RUN_KLAYOUT_DRC": 0, "FP_PDN_VPITCH": 50.,
                "FP_PDN_VWIDTH": 2.1, "FP_PDN_MULTILAYER": 0}
        assert not any(path.startswith("physical/") for path in files)
    expected_tools = {
        "support_tools_revision": lock["support_tools_revision"],
        "pdk_revision": lock["pdk_revision"],
        "librelane": lock["librelane_version"],
        "python": lock["python"],
    }
    assert {key: manifest["requested_tools"][key] for key in expected_tools} == expected_tools
    assert manifest["synthesis_sources"] == [
        "src/tt_um_leemperor_hardcaml_protemu" + suffix + ".v"
    ]
    assert manifest["simulation_sources"] == [
        "simulation/tt_um_leemperor_hardcaml_protemu" + suffix + ".v"
    ]
    assert config["CLOCK_PORT"] == "clk"
    assert abs(config["CLOCK_PERIOD"] - 1e9 / 48e6) < 1e-10
    assert config["CLOCK_UNCERTAINTY_CONSTRAINT"] == 0.25
    assert config["CLOCK_TRANSITION_CONSTRAINT"] == 0.15
    assert config["TIME_DERATING_CONSTRAINT"] == 5.
    assert config["MAX_FANOUT_CONSTRAINT"] == 10
    assert config["OUTPUT_CAP_LOAD"] == 6.
    if selection == "exact":
        assert config["STA_CORNERS"] == [
            "nom_fast_1p32V_m40C", "nom_slow_1p08V_125C", "nom_typ_1p20V_25C"]
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
    sdc = (bundle / "constraints/top.sdc").read_text()
    assert "create_clock -name clk" in sdc
    assert sdc.count("create_clock ") == 1
    assert not any(command in sdc for command in (
        "set_false_path", "set_multicycle_path", "create_generated_clock"))
    for port in ("ui_in", "uio_in", "ena", "rst_n"):
        for bound, delay in (("min", 0), ("max", 1)):
            assert f"set_input_delay -{bound} {delay} -clock clk [get_ports {{{port}}}]" in sdc
    for port in ("uo_out", "uio_out", "uio_oe"):
        for bound, delay in (("min", 0), ("max", 2)):
            assert f"set_output_delay -{bound} {delay} -clock clk [get_ports {{{port}}}]" in sdc
    source_paths = {item["path"] for item in manifest["source_inputs"]}
    assert {
        "asic/cli/dune", "asic/rtl/dune", "asic/rtl/bringup/dune",
        "ip/mechanisms/rtl/dune", "ip/program_memory_controller/rtl/dune",
        "ip/emulator_core/rtl/dune", "ip/host_link/rtl/dune",
        "ip/protemu_system/rtl/dune", "ip/host_link/protocol/dune", "spec/isa/dune",
    } <= source_paths
    assert not any(path.startswith(("software/", "verif/", "lib/", "bin/", "chip_top/"))
                   for path in source_paths)
    expected_source = {
        "observable": "asic/rtl/bringup/p0_observable.ml",
        "memory": "ip/program_memory_controller/rtl/program_memory_controller.ml",
        "loader": "ip/host_link/rtl/host_link.ml",
    }[kind]
    assert {
        "asic/cli/asic_bundle.ml", expected_source, "asic/tinytapeout/asic-dependencies.lock",
        "asic/project/dune", "asic/project/chip_project.ml", "asic/rtl/dune",
    } <= source_paths
    package_sources = {
        "observable": {"asic/rtl/observable_design.ml"},
        "memory": {"asic/rtl/memory_design.ml", "asic/rtl/program_memory.ml"},
        "loader": {"asic/rtl/package_top.ml", "asic/rtl/program_memory.ml"},
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
            assert {"ip/protemu_system/rtl/protemu_top.ml", "ip/emulator_core/rtl/emulator_core.ml"} <= source_paths
            assert {
                "ip/host_link/protocol/dune",
                "ip/host_link/protocol/definitions.ml",
                "ip/host_link/protocol/codec.ml",
                "ip/host_link/protocol/host_link_protocol.ml",
                "ip/host_link/protocol/host_link_protocol.mli",
            } <= source_paths
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
            "policy": "(Rule (Instance program))",
            "selection": "((implementation Flops) (reason Explicit_flops))",
            "elaborated_as": "Selected_implementation",
            "source_roles": ["Generated_synthesis_rtl"],
        }
        simulation_expected = dict(expected)
        simulation_expected["elaborated_as"] = "Behavioral_model"
        simulation_expected["source_roles"] = ["Generated_behavioral_model"]
        if selection == "exact":
            macro = "RM_IHPSG13_1P_256x16_c2_bm_bist"
            for record in (expected, simulation_expected):
                record["requirement"] = "Exact"
                record["selection"] = (
                    f"((implementation (Macro {macro}))\n"
                    " (reason (Exact_mapping (technology ihp-sg13cmos5l))))"
                )
            # Typed role/reference equality is checked by resource_contract_tests.
            expected["source_roles"] = manifest["resources"][0]["source_roles"]
            assert len(expected["source_roles"]) == 11
            assert len(set(expected["source_roles"])) == 11
            contract = manifest["macro_contract"]
            if physical:
                assert kind == "loader"
                check_loader_physical(manifest, config, files)
            else:
                assert contract["schema_version"] == 1
                assert contract["execution"] == "synthesis_only"
                assert "physical_plan" not in contract
                assert not any(path.startswith("physical/") for path in files)
            assert len(contract["macros"]) == 1
            actual = contract["macros"][0]
            assert (actual["resource"], actual["module"], actual["instance"]) == (
                "program", macro, "hc_resource_7_program"
            )
            assert len(contract["blackbox_sources"]) == 1
            assert config["EXTRA_VERILOG_MODELS"] == [
                "dir::../" + path for path in contract["blackbox_sources"]]
            assert all(path in files for path in contract["blackbox_sources"])
            assert not set(contract["blackbox_sources"]) & set(manifest["simulation_sources"])
            assert contract["fast_temperature_difference"] == "standard_cells_m40C_macro_m55C"
            assert contract["implementation_simulation"] == {
                "defines": ["FUNCTIONAL"],
                "models": [
                    f"pdk_dir::libs.ref/sg13cmos5l_sram/verilog/{macro}.v",
                    "pdk_dir::libs.ref/sg13cmos5l_sram/verilog/RM_IHPSG13_1P_core_behavioral_bm_bist.v",
                ],
            }
        else:
            assert "macro_contract" not in manifest
        # Formatting is not the resource contract; compare normalized S-expressions.
        def normalized(record):
            return {key: " ".join(value.split()) if isinstance(value, str) else value
                    for key, value in record.items()}
        assert list(map(normalized, manifest["resources"])) == [normalized(expected)]
        assert list(map(normalized, manifest["simulation_resources"])) == [normalized(simulation_expected)]
        synthesis_rtl = (bundle / manifest["synthesis_sources"][0]).read_text()
        simulation_rtl = (bundle / manifest["simulation_sources"][0]).read_text()
        assert "initial begin" not in synthesis_rtl
        assert "initial begin" in simulation_rtl
        assert synthesis_rtl != simulation_rtl
        if selection == "exact":
            import re
            assert len(re.findall(r"\b" + macro + r"\s+hc_resource_7_program\s*\(", synthesis_rtl)) == 1
            assert macro not in simulation_rtl
        else:
            assert "RM_IHPSG13_1P_256x16_c2_bm_bist" not in synthesis_rtl
    for item in manifest["source_inputs"]:
        source = root / item["path"]
        copied = bundle / "inputs" / item["path"]
        assert copied.read_bytes() == source.read_bytes()
        assert hashlib.sha256(copied.read_bytes()).hexdigest() == item["sha256"]
        assert item["git_status"] == subprocess.check_output(
            ["git", "status", "--porcelain=v1", "--untracked-files=all", "--", item["path"]],
            cwd=root, text=True,
        ).rstrip("\n")
    for item in manifest["files"]:
        path = bundle / item["path"]
        assert hashlib.sha256(path.read_bytes()).hexdigest() == item["sha256"]
    return manifest["identity"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata-only", action="store_true")
    parser.add_argument("--selection", choices=("flops", "exact"), default="flops")
    parser.add_argument("--operation", choices=("synthesis", "hardening"))
    parser.add_argument("--emitter", type=pathlib.Path)
    parser.add_argument(
        "--kind", choices=("observable", "memory", "loader"), default="observable"
    )
    args = parser.parse_args()
    if args.selection == "exact" and not args.metadata_only:
        parser.error("Exact source/resource checks require --metadata-only; vendor-model replay is PT.3b")
    root = pathlib.Path(__file__).resolve().parents[3]
    build_dir = pathlib.Path(os.environ.get("DUNE_BUILD_DIR", str(root / "_build")))
    emitter = (args.emitter or build_dir / "default/asic/cli/asic_bundle.exe").resolve()
    selection_args = ["--selection", args.selection]
    if args.operation:
        selection_args += ["--operation", args.operation]
    run(str(emitter), *selection_args, "--check-conflicts", args.kind, cwd=root)
    with tempfile.TemporaryDirectory(prefix="protemu-adopted-") as scratch:
        scratch = pathlib.Path(scratch)
        first, second = scratch / "first", scratch / "second"
        run(str(emitter), *selection_args, args.kind, str(first), str(root), cwd=root)
        run(str(emitter), *selection_args, args.kind, str(second), str(root), cwd=root)
        assert check_bundle(root, first, args.kind, args.selection, args.operation) == check_bundle(root, second, args.kind, args.selection, args.operation)
        assert (first / "manifest.json").read_bytes() == (
            second / "manifest.json"
        ).read_bytes()
        assert tree(first) == tree(second)
        print("PASS repeatable bundle, manifest, metadata, and conflict checks")
        if args.metadata_only:
            return
        image = "ghcr.io/librelane/librelane:" + lock_values(
            root / "asic/tinytapeout/asic-dependencies.lock"
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
            else root / "asic/verif" / args.kind / "emitted"
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
