"""Hand-authored raw/VCD parser fixtures, never DUT execution evidence."""

from copy import deepcopy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from unittest.mock import Mock
import subprocess
import signal
import io

import event_response as oracle
import event_evidence as evidence
import produce_event_response as producer
import inspect_event_response as public_cli
from test_event_response import fixture


def raw_fixture(phase=0):
    run = fixture()["phases"][phase]
    reads = {9+2*i: i for i in range(6)}
    reads.update({23+i: i for i in range(6)})
    lines = []
    for edge, row in enumerate(run["samples"]):
        write = 3 <= edge <= 8
        address = edge-3 if write else reads.get(edge, 0)
        data = oracle.CONTRACT["image_words"][address] if write else 0
        acceptance = (32 if edge == 1 else 16 if edge == 2 else 8 if write else
                      4 if edge in range(9, 20, 2) else 2 if edge == 21 else 1 if edge == 22 else 0)
        lines.append(f"PRE {edge} {(5+10*edge)*1000} {int(row['decision'])} "
                     f"{int(row['bank_request'])} {int(write or edge in reads)} {int(write)} "
                     f"{address} {data} {acceptance:06b}")
        response = edge in range(10, 21, 2)
        word = oracle.CONTRACT["image_words"][(edge-10)//2] if response else 0
        lines.append(" ".join(map(str, ["POST", edge, (6+10*edge)*1000,
            int(row["armed"]), int(row["synchronized"]), row["pins"], row["oe"],
            int(row["normal_halt"]), int(row["fault"]), 6, 4, 2,
            int(response), word, int(response), int(edge >= 21), 6, 6, 6, int(edge > 0)])))
    lines.append(f"DONE {phase} {run['external_tick']}")
    return "\n".join(lines) + "\n"


def vcd_fixture(raw):
    names = ["clock_i", "pin_async_i", "timing_busy_o", "rising_o", "pins_o", "pin_oe_o",
             "normal_halt_o", "execution_fault_o", "fetch_fault_o", "mechanism_kind_o",
             "mechanism_completion_valid_o", "mechanism_request_valid_o", "mechanism_accepted_o",
             "prog_mem_enable_o", "prog_mem_write_enable_o", "prog_mem_address_o", "prog_mem_write_data_o",
             "fetch_cycles_o", "instruction_count_o", "extension_fetches_o"]
    codes = {name: chr(65+i) for i, name in enumerate(names)}
    lines = ["$timescale 1ps $end", "$scope module tb $end"]
    widths = {"pin_async_i": 8, "rising_o": 8, "pins_o": 8, "pin_oe_o": 8,
              "mechanism_kind_o": 4, "prog_mem_address_o": 8, "prog_mem_write_data_o": 16,
              "fetch_cycles_o": 32, "instruction_count_o": 32, "extension_fetches_o": 32}
    lines += [f"$var wire {widths.get(name, 1)} {codes[name]} {name} $end" for name in names]
    lines += ["$upscope $end", "$enddefinitions $end"]
    events = [(0, "clock_i", 0), (0, "pin_async_i", 0)]
    raw_lines = raw.splitlines()
    for edge in range(48):
        pre, post = raw_lines[2*edge].split(), raw_lines[2*edge+1].split()
        time = int(pre[2])
        decision, request = int(pre[3]), int(pre[4])
        for name, value in (("mechanism_completion_valid_o", decision),
                            ("mechanism_kind_o", 9 if decision else 4),
                            ("mechanism_request_valid_o", request), ("mechanism_accepted_o", request)):
            events.append((time-2000, name, value))
        for name, value in zip(("prog_mem_enable_o", "prog_mem_write_enable_o", "prog_mem_address_o",
                                "prog_mem_write_data_o"), map(int, pre[5:9])):
            events.append((time-2000, name, value))
        events += [(time, "clock_i", 1), (time+5000, "clock_i", 0)]
        for name, value in zip(("timing_busy_o", "rising_o", "pins_o", "pin_oe_o",
                                 "normal_halt_o", "execution_fault_o", "fetch_fault_o"),
                                (int(post[3]), int(post[4])*8, int(post[5]), int(post[6]), int(post[7]), int(post[8]), 0)):
            events.append((time+1000, name, value))
        for name, value in zip(("fetch_cycles_o", "instruction_count_o", "extension_fetches_o"), map(int, post[9:12])):
            events.append((time+1000, name, value))
    external = int(raw_lines[-1].split()[2])
    if external >= 0:
        events.append((external*1000, "pin_async_i", 8))
    for time, name, value in sorted(events):
        lines += [f"#{time}", f"b{value:b} {codes[name]}"]
    return "\n".join(lines) + "\n"


def retained_fixture(directory):
    """Entirely synthetic retained evidence to exercise readers, not producers."""
    directory = Path(directory)
    def save(relative, data):
        path = directory / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        if not isinstance(data, str):
            data = json.dumps(data)
        path.write_text(data)
    capture = fixture()
    traffic = []
    for phase in range(-1, 10):
        raw = raw_fixture(max(0, phase))
        if phase < 0:
            lines = raw.splitlines()
            for edge in range(48):
                pre, post = lines[2*edge].split(), lines[2*edge+1].split()
                pre[3:5] = ["0", "0"]
                post[3:9] = [str(int(edge >= 23)), "0", "0", post[6], "0", "0"]
                lines[2*edge], lines[2*edge+1] = " ".join(pre), " ".join(post)
            lines[-1] = "DONE -1 -1"
            raw = "\n".join(lines) + "\n"
        _, counts = producer.parse_trace(raw, phase)
        name = "calibration" if phase < 0 else f"phase-{phase}"
        save(name + "/raw.trace", raw)
        save(name + "/waveform.vcd", vcd_fixture(raw))
        if phase >= 0:
            traffic.append({"phase": phase, **counts})
    save("capture.json", capture)
    save("workload.json", oracle.workload())
    save("reference.json", {"schema": "electrum.event-response-reference", "version": 1,
        "halted": True, "image_words": oracle.CONTRACT["image_words"], "pin0_wave": "zz00000000111",
        "cycles": 13, "fetch_cycles": 6, "instructions": 4, "extension_fetches": 2})
    save("emitted/top.v", "// fixture only, not executable RTL\n")
    save("emitted/elaboration.sexp", "(fixture-only)")
    save("emitted/composition.json", producer.COMPOSITION)
    save("sources/checker.py", "# synthetic fixture source\n")
    tools = {}
    for tool in ("emitter", "reference", "iverilog", "vvp"):
        save("tools/"+tool, "fixture-"+tool)
        tools[tool] = {"path": "/fixture/"+tool, "sha256": producer.sha(("fixture-"+tool).encode())}
    result = {"schema": "electrum.event-response-result", "version": 1, "status": "completed",
              "hardware_assignment": producer.ASSIGNMENT, "controls": producer.CONTROLS,
              "system_boundary": producer.SYSTEM_BOUNDARY, "composition": producer.COMPOSITION,
              "hardware_assignment_identity": producer.sha(oracle.canonical(producer.ASSIGNMENT)),
              "loader_project_variant_identity": None,
              "selection": "flops", "source_role": "implementation", "tools": tools,
              "functional_verification": "passed", "measurements": oracle.check_capture(capture),
              "reference_check": producer.check_reference(json.loads((directory/"reference.json").read_text())),
              "traffic": traffic, "artifacts": producer.artifact_inventory(directory)}
    save("result.json", result)
    return directory / "result.json"


class RawProducerTests(unittest.TestCase):
    def test_all_phase_raw_traces_replay_to_existing_oracle(self):
        capture = fixture()
        for phase in range(10):
            raw = raw_fixture(phase)
            run, counts = producer.parse_trace(raw, phase)
            self.assertEqual(run, capture["phases"][phase])
            self.assertEqual((counts["ram_writes"], counts["ram_reads"]), (6, 12))
            self.assertEqual(evidence.check_waveform(vcd_fixture(raw), raw)["samples"], 48)
        oracle.check_capture(capture)

    def test_setup_acceptance_and_actual_readback_are_required(self):
        raw = raw_fixture()
        for before, after, message in (("000001", "000000", "acceptance"),
            ("POST 10 106000 0 0 0 1 0 0 6 4 2 1 30724", "POST 10 106000 0 0 0 1 0 0 6 4 2 1 30725", "readback")):
            self.assertIn(before, raw)
            with self.assertRaisesRegex(ValueError, message):
                producer.parse_trace(raw.replace(before, after, 1), 0)

    def test_missing_rows_unknown_live_values_and_wrong_timestamps_reject(self):
        raw = raw_fixture()
        for bad in ("\n".join(raw.splitlines()[:-1]), raw.replace("PRE 2 25000", "PRE 2 25001"),
                    raw.replace("PRE 2 25000 0", "PRE 2 25000 x")):
            with self.assertRaises(ValueError):
                producer.parse_trace(bad, 0)

    def test_ram_force_or_changed_fetch_sequence_is_detected(self):
        raw = raw_fixture()
        with self.assertRaisesRegex(ValueError, "RAM load traffic"):
            producer.parse_trace(raw.replace("PRE 3 35000 0 0 1 1 0 30724", "PRE 3 35000 0 0 0 1 0 30724"), 0)
        with self.assertRaisesRegex(ValueError, "fetch address"):
            producer.parse_trace(raw.replace("PRE 23 235000 0 0 1 0 0", "PRE 23 235000 0 0 1 0 1"), 0)

    def test_actual_ram_observations_are_retained_and_cross_checked_with_vcd(self):
        raw = raw_fixture()
        _, counts = producer.parse_trace(raw, 0)
        self.assertEqual([row["address"] for row in counts["execution_reads"]], list(range(6)))
        self.assertEqual([row["edge"] for row in counts["execution_reads"]], list(range(23, 29)))
        wave = vcd_fixture(raw)
        before = "#233000\nb0 P"
        self.assertIn(before, wave)
        with self.assertRaisesRegex(ValueError, "RAM operation/address mismatch"):
            evidence.check_waveform(wave.replace(before, "#233000\nb1 P"), raw)

    def test_fetch_counter_cannot_replace_actual_port_observations(self):
        raw = raw_fixture()
        with self.assertRaisesRegex(ValueError, "fetch counter disagrees"):
            producer.parse_trace(raw.replace("POST 47 476000 0 0 1 1 1 0 6 4 2",
                                            "POST 47 476000 0 0 1 1 1 0 7 4 2"), 0)

    def test_wrong_vcd_values_or_stimulus_or_timescale_reject(self):
        raw = raw_fixture()
        wave = vcd_fixture(raw)
        for before, after, message in (("#306000\nb1 E", "#306000\nb0 E", "sample mismatch"),
                                      ("#245000\nb1000 B", "#246000\nb1000 B", "stimulus differs"),
                                      ("1ps", "1ns", "timescale")):
            self.assertIn(before, wave)
            with self.assertRaisesRegex(ValueError, message):
                evidence.check_waveform(wave.replace(before, after), raw)

    def test_vcd_missing_signal_or_truncation_rejects(self):
        raw = raw_fixture()
        wave = vcd_fixture(raw)
        with self.assertRaisesRegex(ValueError, "missing VCD signal"):
            evidence.check_waveform(wave.replace("pins_o", "unrelated"), raw)
        with self.assertRaises(ValueError):
            evidence.check_waveform(wave[:wave.index("#300000")], raw)

    def test_independent_model_must_execute_expected_program(self):
        reference = {"schema": "electrum.event-response-reference", "version": 1, "halted": True,
                     "image_words": oracle.CONTRACT["image_words"], "pin0_wave": "zz00000000111",
                     "cycles": 13, "fetch_cycles": 6, "instructions": 4, "extension_fetches": 2}
        self.assertIn("not compared", producer.check_reference(reference)["schedule_comparison"])
        with self.assertRaisesRegex(ValueError, "model scenario differs"):
            producer.check_reference({**reference, "pin0_wave": "zz11111111111"})

    def test_existing_output_refused_without_child(self):
        with tempfile.TemporaryDirectory() as directory, patch("subprocess.Popen") as spawn:
            with self.assertRaises(FileExistsError):
                producer.main(["--selection", "flops", "--output", directory, "--pdk", directory])
            spawn.assert_not_called()

    def test_timeout_kills_only_owned_child_group_and_retains_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            runner = producer.Producer(Path(directory), 1)
            child = Mock(pid=12345, returncode=-9)
            child.wait.side_effect = [subprocess.TimeoutExpired("fixture", 1), -9]
            with patch("subprocess.Popen", return_value=child) as spawn, patch("os.killpg") as kill:
                with self.assertRaises(subprocess.TimeoutExpired):
                    runner.run(["/fixture-only"], directory)
                self.assertTrue(spawn.call_args.kwargs["start_new_session"])
                kill.assert_called_once_with(12345, signal.SIGKILL)
            self.assertEqual(runner.commands[0]["status"], "interrupted")


class RetainedReaderTests(unittest.TestCase):
    def test_full_replay_and_identical_controlled_pair(self):
        with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
            left, right = retained_fixture(a), retained_fixture(b)
            self.assertEqual(evidence.inspect(left)["measurements"]["minimum_response_ticks"], 60)
            comparison = evidence.compare(left, right)
            self.assertEqual(comparison["status"], "comparable")
            self.assertEqual(comparison["right_minus_left_response_ticks"], [0]*10)
            self.assertIsNone(comparison["physical_area_speed_delta"])

    def test_raw_whitespace_tampering_rejects_digest(self):
        with tempfile.TemporaryDirectory() as directory:
            result = retained_fixture(directory)
            trace = Path(directory)/"phase-0/raw.trace"
            trace.write_text(trace.read_text()+"\n")
            with self.assertRaisesRegex(ValueError, "digest/length"):
                evidence.inspect(result)

    def test_rebound_raw_waveform_still_requires_semantic_replay(self):
        with tempfile.TemporaryDirectory() as directory:
            path = retained_fixture(directory)
            wave = Path(directory)/"phase-0/waveform.vcd"
            wave.write_text(wave.read_text().replace("#306000\nb1 E", "#306000\nb0 E"))
            result = json.loads(path.read_text())
            result["artifacts"] = producer.artifact_inventory(Path(directory))
            producer.write_json(path, result)
            with self.assertRaisesRegex(ValueError, "sample mismatch"):
                evidence.inspect(path)

    def test_behavioral_context_is_confounded(self):
        with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
            left, right = retained_fixture(a), retained_fixture(b)
            value = json.loads(right.read_text())
            value["source_role"] = "behavioral"
            producer.write_json(right, value)
            comparison = evidence.compare(left, right)
            self.assertEqual(comparison["status"], "confounded_or_unavailable")
            self.assertIsNone(comparison["right_minus_left_response_ticks"])

    def test_changed_tool_bytes_are_confounded_even_with_valid_local_digests(self):
        with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
            left, right = retained_fixture(a), retained_fixture(b)
            tool = Path(b)/"tools/vvp"
            tool.write_text("different fixture tool")
            value = json.loads(right.read_text())
            value["tools"]["vvp"]["sha256"] = producer.sha(tool.read_bytes())
            value["artifacts"] = producer.artifact_inventory(Path(b))
            producer.write_json(right, value)
            comparison = evidence.compare(left, right)
            self.assertIn("different vvp artifact", comparison["reasons"])
            self.assertIsNone(comparison["right_minus_left_response_ticks"])

    def test_failed_result_cannot_publish_measurements(self):
        with tempfile.TemporaryDirectory() as directory:
            path = retained_fixture(directory)
            value = json.loads(path.read_text())
            value["status"] = "failed"
            producer.write_json(path, value)
            with self.assertRaisesRegex(ValueError, "incomplete result exposes"):
                evidence.inspect(path)

    def test_loader_assignment_or_boundary_cannot_be_substituted(self):
        for change, message in (({"system_boundary": "loader-package"}, "system boundary"),
            ({"hardware_assignment": {"package": "loader-v1"}}, "hardware/measurement"),
            ({"loader_project_variant_identity": "fixed-loader-v1"}, "not the loader")):
            with self.subTest(change=change), tempfile.TemporaryDirectory() as directory:
                path = retained_fixture(directory)
                value = json.loads(path.read_text())
                value.update(change)
                producer.write_json(path, value)
                with self.assertRaisesRegex(ValueError, message):
                    evidence.compare(path, path)

    def test_rebound_emitted_composition_cannot_change_boundary(self):
        with tempfile.TemporaryDirectory() as directory:
            path = retained_fixture(directory)
            composition = Path(directory)/"emitted/composition.json"
            producer.write_json(composition, {**producer.COMPOSITION, "host_link": True})
            result = json.loads(path.read_text())
            result["artifacts"] = producer.artifact_inventory(Path(directory))
            producer.write_json(path, result)
            with self.assertRaisesRegex(ValueError, "emitted composition mismatch"):
                evidence.inspect(path)

    def test_changed_workload_clock_or_source_cannot_receive_delta(self):
        for field, data in (("controls", {**producer.CONTROLS, "clock_period_ns": 20}),
                            ("hardware_assignment", {**producer.ASSIGNMENT, "program_depth": 128})):
            with self.subTest(field=field), tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
                left, right = retained_fixture(a), retained_fixture(b)
                result = json.loads(right.read_text())
                result[field] = data
                producer.write_json(right, result)
                with self.assertRaisesRegex(ValueError, "hardware/measurement"):
                    evidence.compare(left, right)
        with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
            left, right = retained_fixture(a), retained_fixture(b)
            (Path(b)/"sources/checker.py").write_text("# different source\n")
            result = json.loads(right.read_text())
            result["artifacts"] = producer.artifact_inventory(Path(b))
            producer.write_json(right, result)
            comparison = evidence.compare(left, right)
            self.assertIsNone(comparison["right_minus_left_response_ticks"])
            self.assertIn("source/checker snapshots differ or are absent", comparison["reasons"])


class PublicCliTests(unittest.TestCase):
    def query(self, args):
        out, err = io.StringIO(), io.StringIO()
        with patch("subprocess.Popen", side_effect=AssertionError("read-only query spawned a child")):
            code = public_cli.main(args + ["--json"], stdout=out, stderr=err)
        self.assertEqual(err.getvalue(), "")
        return code, json.loads(out.getvalue())

    def test_inspection_and_comparison_json(self):
        with tempfile.TemporaryDirectory() as directory:
            path = retained_fixture(directory)
            code, value = self.query(["inspect", str(path)])
            self.assertEqual(code, 0)
            self.assertEqual(value["schema"], "electrum.event-response-inspection")
            self.assertEqual(value["result"]["system_boundary"], "core+Program_memory")
            code, value = self.query(["compare", "--left", str(path), "--right", str(path)])
            self.assertEqual(code, 0)
            self.assertEqual(value["right_minus_left_response_ticks"], [0]*10)

    def test_readable_failure_and_confounded_pair_exit_one(self):
        with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
            left, right = retained_fixture(a), retained_fixture(b)
            result = json.loads(right.read_text())
            result.update(status="failed", measurements=None, functional_verification="not_passed")
            producer.write_json(right, result)
            code, value = self.query(["inspect", str(right)])
            self.assertEqual(code, 1)
            self.assertIsNone(value["measurements"])
            code, value = self.query(["compare", "--left", str(left), "--right", str(right)])
            self.assertEqual(code, 1)
            self.assertIsNone(value["right_minus_left_response_ticks"])

    def test_invalid_or_duplicate_field_evidence_exit_two(self):
        with tempfile.TemporaryDirectory() as directory:
            path = retained_fixture(directory)
            path.write_text('{"version": 1, ' + path.read_text()[1:])
            code, value = self.query(["inspect", str(path)])
            self.assertEqual(code, 2)
            self.assertEqual(value["status"], "invalid")
            self.assertIn("duplicate JSON field", value["diagnostic"])


    def test_package_assignment_comparison_is_invalid_not_a_delta(self):
        with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
            left, right = retained_fixture(a), retained_fixture(b)
            result = json.loads(right.read_text())
            result["hardware_assignment"] = {"package": "loader-v1"}
            producer.write_json(right, result)
            code, value = self.query(["compare", "--left", str(left), "--right", str(right)])
            self.assertEqual(code, 2)
            self.assertEqual(value["status"], "invalid")
            self.assertNotIn("right_minus_left_response_ticks", value)


if __name__ == "__main__":
    unittest.main()
