"""Pure oracle fixtures only. These hand-authored traces are NOT DUT results.

Run: python3 -B -m unittest discover -s asic/verif/workloads -v
No build, simulation, tool provisioning or child process is performed.
"""

from copy import deepcopy
import unittest

import event_response as oracle


def fixture():
    phases = []
    for phase in range(10):
        # The sweep's edge labels: armed=235, synchronized=255/265,
        # decision=275/285, bank request/commit=305/315.
        sync = 25 if phase == 0 else 26
        samples = [{"edge": edge, "armed": 23 <= edge < sync + 2,
                    "synchronized": edge == sync, "decision": edge == sync + 2,
                    "bank_request": edge == sync + 5, "pins": int(edge >= sync + 5),
                    "oe": int(edge >= 1), "normal_halt": edge >= sync + 7,
                    "fault": False} for edge in range(48)]
        phases.append({"phase": phase, "external_tick": 245 + phase, "samples": samples})
    return {"schema": "protemu.event-response-capture", "version": 1,
            "status": "completed", "workload": oracle.workload(), "phases": phases}


class EventResponseTests(unittest.TestCase):
    def rejects(self, mutate, message):
        capture = fixture()
        mutate(capture)
        with self.assertRaisesRegex(ValueError, message):
            oracle.check_capture(capture)

    def test_complete_phase_contract_and_exact_cycle_fractions(self):
        result = oracle.check_capture(fixture())
        self.assertEqual((result["minimum_response_ticks"], result["maximum_response_ticks"]), (60, 69))
        self.assertEqual(result["phases"][0]["external_to_bank_cycles"], "6")
        self.assertEqual(result["phases"][1]["external_to_bank_cycles"], "69/10")
        self.assertEqual(result["firmware_bytes"], 12)

    def test_contract_is_a_copy(self):
        contract = oracle.workload()
        contract["image_words"][0] = 0
        self.assertEqual(oracle.workload()["image_words"][0], 0x7804)

    def test_faster_but_different_contract_is_rejected(self):
        self.rejects(lambda c: c["workload"].update(clock_period_ticks=5), "contract differs")
        self.rejects(lambda c: c["workload"]["memory"].update(read_latency_edges=2), "contract differs")
        self.rejects(lambda c: c["workload"]["image_words"].pop(), "contract differs")

    def test_source_role_or_model_labels_cannot_be_smuggled_into_contract(self):
        self.rejects(lambda c: c["workload"].update(selection="exact"), "contract differs")

    def test_missing_duplicate_reordered_phase_reject(self):
        self.rejects(lambda c: c["phases"].pop(), "ten phases")
        self.rejects(lambda c: c["phases"][1].update(phase=0), "exactly once")
        self.rejects(lambda c: c["phases"].reverse(), "exactly once")

    def test_partial_failed_or_interrupted_capture_has_no_metrics(self):
        for status in ("running", "failed", "interrupted"):
            self.rejects(lambda c: c.update(status=status), "not completed")

    def test_truncated_or_reordered_samples_reject(self):
        self.rejects(lambda c: c["phases"][0]["samples"].pop(), "incomplete")
        self.rejects(lambda c: c["phases"][0]["samples"][1].update(edge=0), "reordered edge")

    def test_clock_phase_and_post_settle_convention_are_not_interchangeable(self):
        self.rejects(lambda c: c["phases"][0].update(external_tick=246), "external phase")
        self.rejects(lambda c: c["workload"].update(sampling="all-post-edge"), "contract differs")

    def test_hidden_cycle_change_rejects(self):
        def delay_decision(c):
            rows = c["phases"][0]["samples"]
            rows[27]["decision"] = False
            rows[28]["decision"] = True
        self.rejects(delay_decision, "decision latency changed")

    def test_duplicate_or_missing_witness_rejects(self):
        self.rejects(lambda c: c["phases"][0]["samples"][26].update(synchronized=True), "nonunique")
        self.rejects(lambda c: c["phases"][0]["samples"][30].update(bank_request=False), "nonunique")

    def test_early_pin_or_lost_ownership_or_glitch_rejects(self):
        self.rejects(lambda c: c["phases"][0]["samples"][29].update(pins=1), "commit edge")
        self.rejects(lambda c: c["phases"][0]["samples"][35].update(oe=0), "ownership lost")
        self.rejects(lambda c: c["phases"][0]["samples"][35].update(pins=0), "glitches")

    def test_fault_or_missing_completion_rejects(self):
        self.rejects(lambda c: c["phases"][0]["samples"][35].update(fault=True), "core fault")
        def remove_halt(c):
            for row in c["phases"][0]["samples"]:
                row["normal_halt"] = False
        self.rejects(remove_halt, "missing normal_halt")
        self.rejects(lambda c: c["phases"][0]["samples"][2].update(normal_halt=True), "halt precedes")

    def test_unknowns_wrong_types_and_extra_fields_reject(self):
        self.rejects(lambda c: c["phases"][0]["samples"][30].update(pins="x"), "invalid pins")
        self.rejects(lambda c: c["phases"][0]["samples"][30].update(oe=True), "invalid oe")
        self.rejects(lambda c: c["phases"][0]["samples"][30].update(fault=0), "invalid sample fault")
        self.rejects(lambda c: c.update(seconds=0.01), "capture fields")
        self.rejects(lambda c: c.update(version=True), "capture version")

    def test_capture_identity_covers_observation_bytes_semantically(self):
        original = fixture()
        changed = deepcopy(original)
        changed["phases"][0]["samples"][22]["armed"] = True
        # An earlier armed edge changes stimulus meaning rather than only a hash.
        with self.assertRaisesRegex(ValueError, "external phase"):
            oracle.check_capture(changed)
        self.assertEqual(oracle.check_capture(original), oracle.check_capture(deepcopy(original)))


if __name__ == "__main__":
    unittest.main()
