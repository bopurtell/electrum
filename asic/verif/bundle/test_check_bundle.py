"""Pure negative-oracle fixtures; no emitter, Git subprocess or build."""

import copy
import unittest

from check_bundle import check_snapshot


class SnapshotOracleTests(unittest.TestCase):
    def setUp(self):
        self.manifest = {
            "project": "protemu_memory", "top_module": "memory_top",
            "resource_snapshot": {
                "schema_version": 1, "scope": "resolved", "mode": "implementation",
                "project": "protemu_memory", "top": "memory_top",
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


if __name__ == "__main__":
    unittest.main()
