"""Negative-oracle fixtures; Git locates the compatibility checker, no build/emitter."""

import copy
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

from check_bundle import check_snapshot

root = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())
scripts = root / "asic_support/tinytapeout/scripts"
spec = importlib.util.spec_from_file_location("adopted_checks", scripts / "check-adopted-bundle.py")
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)
phase4_spec = importlib.util.spec_from_file_location("adopted_phase4", scripts / "adopted_phase4.py")
phase4 = importlib.util.module_from_spec(phase4_spec)
phase4_spec.loader.exec_module(phase4)


class EmbeddedDependencyLockTests(unittest.TestCase):
    def test_current_and_retained_paths_are_supported_but_not_ambiguous(self):
        lock = scripts.parent / "asic-dependencies.lock"
        values = phase4.read_lock(lock)
        manifest = {
            "target": {"technology": "ihp-sg13cmos5l", "tiles": "6x4"},
            "requested_tools": {k: values[k] for k in
                                ("support_tools_revision", "pdk_revision", "python")},
        }
        manifest["requested_tools"]["librelane"] = values["librelane_version"]
        with tempfile.TemporaryDirectory() as tmp:
            bundle = Path(tmp)
            for directory in ("asic", "asic_support"):
                with self.subTest(directory=directory):
                    embedded = bundle / "inputs" / directory / "tinytapeout" / lock.name
                    embedded.parent.mkdir(parents=True)
                    shutil.copyfile(lock, embedded)
                    self.assertEqual(phase4.consumer_pins(bundle, manifest)["asic_revision"],
                                     values["asic_revision"])
                    embedded.unlink()
            for directory in ("asic", "asic_support"):
                shutil.copyfile(lock, bundle / "inputs" / directory / "tinytapeout" / lock.name)
            with self.assertRaisesRegex(phase4.PrerequisiteError, "exactly one"):
                phase4.consumer_pins(bundle, manifest)


class SnapshotOracleTests(unittest.TestCase):
    def setUp(self):
        self.manifest = {
            "project": "electrum_memory", "top_module": "memory_top",
            "resource_snapshot": {
                "schema_version": 1, "scope": "resolved", "mode": "implementation",
                "project": "electrum_memory", "top": "memory_top",
                "resources": [{
                    "id": {"path": [], "name": "program", "display": "program"},
                    "policy": {"kind": "instance", "resource": "program"},
                    "requirement": "flops", "elaborated_as": "selected_implementation",
                    "request": {
                        "kind": "single_port_ram",
                        "contract": {"list": [
                            {"list": [{"atom": key}, {"atom": value}]} for key, value in (
                                ("width", "16"), ("depth", "256"), ("read_latency", "1"),
                                ("port", "1rw"), ("disabled_output", "hold"),
                                ("write_output", "unspecified"))]}},
                    "selection": {"implementation": {"kind": "flops"},
                                  "reason": {"kind": "explicit_flops"}},
                    "sources": [{"kind": "generated_synthesis_rtl"}],
                    "collateral": [], "actual_instances": {"status": "not_applicable"},
                    "physical_intent": {"status": "unavailable"},
                }],
            },
        }

    def test_explicit_flops_fixture(self):
        check_snapshot(self.manifest, "flops")

    def test_resource_proof_rejects_corruption(self):
        corruptions = (
            ("id", {"path": [], "name": "progam", "display": "progam"}),
            ("policy", {"kind": "default"}),
            ("elaborated_as", "behavioral_model"),
            ("sources", [{"kind": "generated_behavioral_model"}]),
            ("selection", {"implementation": {"kind": "flops"},
                           "reason": {"kind": "flop_fallback", "technology": "ihp-sg13cmos5l"}}),
        )
        for key, value in corruptions:
            with self.subTest(key=key):
                manifest = copy.deepcopy(self.manifest)
                manifest["resource_snapshot"]["resources"][0][key] = value
                with self.assertRaises(AssertionError):
                    check_snapshot(manifest, "flops")


class PhysicalCandidateOracleTests(unittest.TestCase):
    def setUp(self):
        macro = "RM_IHPSG13_1P_256x16_c2_bm_bist"
        supplies = {"VDD!": "VPWR", "VDDARRAY!": "VPWR", "VSS!": "VGND"}
        self.manifest = {
            "project": "electrum_loader", "operation": "Hardening",
            "macro_contract": {
                "schema_version": 2, "execution": "fresh_full",
                "physical_plan": {
                    "schema_version": 1, "strategy": "cmos5l_m4_edge_access_v1",
                    "plan_file": "physical/macro-plan.json", "pdn_tcl": "physical/pdn.tcl",
                    "checking_profile": "cmos5l_real_gds_v1",
                    "lvs_scope": "abstract_macro_boundary_with_schematic_cdl",
                    "macros": [{"resource": "program", "instance": "hc_resource_7_program",
                                "module": macro, "location_um": [40., 480.],
                                "orientation": "R0", "halo_um": 2., "supplies": supplies}],
                },
                "macros": [{"physical_intent": {
                    "location_um": [40., 480.], "orientation": "R0", "halo_um": 2.,
                    "power": supplies, "execution": "fresh_full"}}],
            },
        }
        self.config = {
            "MACROS": {macro: {"instances": {"hc_resource_7_program": {
                "location": [40., 480.], "orientation": "R0"}}}},
            "DIE_AREA": "0 0 1289.28 710.64",
            "FP_MACRO_HORIZONTAL_HALO": 2., "FP_MACRO_VERTICAL_HALO": 2.,
            "PDN_MACRO_CONNECTIONS": ["^hc_resource_7_program$ VPWR VGND VDD! VSS!",
                                      "^hc_resource_7_program$ VPWR VGND VDDARRAY! VSS!"],
            "PDN_CFG": "dir::../physical/pdn.tcl", "PDN_CONNECT_MACROS_TO_GRID": True,
            "PDN_MULTILAYER": False, "PDN_VERTICAL_LAYER": "Metal4", "PDN_VWIDTH": 2.1,
            "PDN_VPITCH": 50., "PDN_VOFFSET": 10., "PDN_RAIL_LAYER": "Metal1",
            "PDN_RAIL_WIDTH": 0.44, "PDN_ENABLE_RAILS": True,
            "PDN_ENABLE_PINS": True, "PDN_ENABLE_GLOBAL_CONNECTIONS": True,
            "PDN_SKIPTRIM": False, "PDN_CORE_RING": False, "RUN_KLAYOUT_DRC": True,
            "ROUTING_OBSTRUCTIONS": ["Metal4 40 480 276.8 598.78"],
        }
        self.files = {
            "physical/macro-plan.json": json.dumps(self.manifest["macro_contract"]["physical_plan"]).encode(),
            # Fixture markers only, not executable PDN or physical acceptance.
            "physical/pdn.tcl": b"resource $resource footprint/halo exceeds usable core\n"
                                b"no legal edge contact for $supply\n"
                                b"foreach supply {VDD! VDDARRAY! VSS!}\n"
                                b"lappend ::hc_pdn::instances [list [encoding convertfrom utf-8 "
                                b"[binary decode hex 70726f6772616d]] {hc_resource_7_program} "
                                b"{RM_IHPSG13_1P_256x16_c2_bm_bist} 40 480 2]",
        }

    def test_candidate_declaration(self):
        checks.check_loader_physical(self.manifest, self.config, self.files)

    def test_consistently_rebound_example_coordinates_reject(self):
        contract = self.manifest["macro_contract"]
        contract["physical_plan"]["macros"][0]["location_um"] = [40., 81.]
        contract["macros"][0]["physical_intent"]["location_um"] = [40., 81.]
        self.files["physical/macro-plan.json"] = json.dumps(contract["physical_plan"]).encode()
        instance = next(iter(self.config["MACROS"].values()))["instances"]["hc_resource_7_program"]
        instance["location"] = [40., 81.]
        self.config["ROUTING_OBSTRUCTIONS"] = ["Metal4 40 81 276.8 199.78"]
        with self.assertRaises(AssertionError):
            checks.check_loader_physical(self.manifest, self.config, self.files)

    def test_physical_proof_rejects_corruption(self):
        mutations = [
            ("contract", "schema_version", 1), ("contract", "execution", "synthesis_only"),
            ("config", "PDN_MACRO_CONNECTIONS", ["hc_resource_7_program VPWR VGND VDD! VSS!"]),
            ("config", "FP_MACRO_VERTICAL_HALO", 0.),
            ("config", "PDN_CONNECT_MACROS_TO_GRID", False),
            ("config", "PDN_VERTICAL_LAYER", "TopMetal1"),
            ("config", "FP_PDN_VPITCH", 50.),
            ("config", "ROUTING_OBSTRUCTIONS", ["Metal4 40 480 276.8 599.78"]),
            ("files", "physical/macro-plan.json", b"{}"),
            ("files", "physical/pdn.tcl", b"# unchecked power geometry"),
        ]
        for target, key, value in mutations:
            with self.subTest(target=target, key=key):
                manifest, config, files = copy.deepcopy((self.manifest, self.config, self.files))
                {"contract": manifest["macro_contract"], "config": config, "files": files}[target][key] = value
                with self.assertRaises(AssertionError):
                    checks.check_loader_physical(manifest, config, files)


if __name__ == "__main__":
    unittest.main()
