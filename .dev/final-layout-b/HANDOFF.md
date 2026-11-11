# Final-layout owner B handoff

Implemented 2026-11-11 against `docs/final_layout_migration.md`. No staging,
commits, index/configuration changes, provisioning, physical implementation or
dependency/API upgrades. Hardware RTL, hardware compatibility facade, ASIC/TT,
emitter sources, root `dune`, `bin/dune` and documentation are owned elsewhere.

## Source map

`baseline.json` records 81 per-file moves, pre-move SHA-256 values and exact
inline-test registration declarations. The map covers:

- Host API -> `software/host`, simulator -> `software/simulator`.
- Only `bin/protemu.ml` and `bin/sim_cli.ml` -> `software/cli`.
- ISA -> `spec/isa`; protocol -> `ip/host_link/protocol`; wire facade ->
  `software/compatibility/host_link_wire`.
- Model -> `verif/reference/model`; authored selected-ISA example programs ->
  `firmware/examples/example_programs.ml` (identical bytes).
- Model/host/protocol/facade tests -> owner-local `test` directories.
- Simulator ML tests -> `software/simulator/test`; CLI rules and seven expected
  files -> `software/cli/test`; six literal example files ->
  `software/cli/examples` (all identical bytes).
- Tool qualification -> `verif/common/test`; backend conformance ->
  `verif/backends/conformance` and its local `test`.
- CLI workflow script -> `software/cli/scripts` (executable permission retained).

Stanza splits supplement that one-to-one map: `host/dune` became host and simulator
Dune files; `test/host_simulator/dune` became simulator ML tests and CLI workflow
rules; backend-conformance Dune became implementation/benchmark and local tests.
Three root test forwarding aliases were deleted, not reimplemented.

`protemu_firmware_examples` depends only on Core and ISA. The model root facade
reexports all existing model modules and uses a true module alias:
`module Example_programs = Protemu_firmware_examples.Example_programs`. No source
copying or duplicate program implementation. Existing Firmware_* operation
sequences/independent peers and encoding studies remain in the independent model.

## Paths and imports

Active verification/simulator sources import actual wrapped owners; test wrapping,
module names and registrations are retained. The frozen eight-file HL4a oracle
and its old hardware-facade dependency are unchanged.

CLI discovery searches upward using `asic/tinytapeout/toolchain.lock`, preferring
the outer source root over a copied marker in `_build/default`. Dispatch paths
match C's `scripts/`, `asic/flow.sh`, and `asic/tinytapeout/scripts/`. Environment
reporting matches C's `_flow_tools/{venv,pdk}` defaults (bootstrap help also names
`_flow_tools/precheck-venv`). The examples run from `software/cli`, preserving
literal `examples/...` commands, script line numbers and CLI golden bytes.

Replay redaction now redacts source identity only; no old-path rewrite remains.
Live diagnostic source paths and rerun commands refer to canonical owners.

## Expectation whitelist and preservation

Only these six non-frozen files have expectation changes, all mechanically
verified to be path substitutions only:

1. `ip/emulator_core/verif/execution/control_execution_property_tests.ml`
2. `ip/program_memory_controller/verif/controller/protocol_core_property_tests.ml`
3. `ip/mechanisms/verif/staging/uart_slice/uart_slice_property_tests.ml`
4. `ip/mechanisms/verif/blocks/input_events/input_events_timing_tests.ml`
5. `ip/mechanisms/verif/blocks/input_events/input_events_four_state_tests.ml`
6. `verif/common/test/replay_expect_tests.ml`

`preservation.json` records 479/479 B-scope registration declarations, with the
two ASIC registrations bringing the current whole-tree total to 481. All eight
frozen files, the UART frame trace, six CLI examples, seven CLI goldens and the
authored firmware example source match baseline hashes. Existing model test
sources moved unchanged. No new inline-test registrations were introduced.

All of `test/`, `f_model/`, `host/`, `host_link_protocol/`, `host_link_wire/`,
`isa/`, and `examples/` were removed after their sources moved. Inspection showed
no remaining files in `test/`; removal used `rmdir` only (which refuses nonempty
directories), including the empty remnants of the previous migration. No user
files or ignored state were recursively deleted.

## Checks performed

Every Dune build/test/exec was serialized with `../.protemu-build.lock`, used
`scripts/with-switch.sh` (default switch `5.2.0+ox`) and explicit `-j5`.

| Check | Result |
| --- | --- |
| `dune build -j5 @install` | PASS |
| `dune build -j5 @lint` | PASS |
| B owner-local `dune runtest -j5` (software, protocol, model, shared qualification and all four IP verification trees) | PASS |
| Root `dune runtest -j5` | PASS after C fixed generated-file dependencies in TT's `cmp` rule |
| `software/cli/scripts/p3.4-cli-workflow.sh` under shared lock | PASS, including image and timeout-output comparisons |
| `cli_discovery.py` under shared lock | PASS: Dune root/nested entry and direct built executable from `/tmp/opencode` without `DUNE_SOURCEROOT` |
| `type_identity.ml` compiled with switch ocamlfind/ocamlc and built model/firmware/ISA interfaces | PASS, bidirectional Byte_loop type identity and shared Program/Invalid types |
| `audit.py verify` | PASS; result in `preservation.json` |
| `dependency_audit.py` | PASS; 48 active authored closures avoid the old hardware facade; result in `dependencies.json` |
| `git diff --check` | PASS |

Initial root runtest encountered C's relocated TT `cmp` rule lacking explicit
generated-file dependencies. No B test failed. C subsequently added those
dependencies; the root rerun passed. No unresolved B failures remain.

The dependency audit retains pure Core/ISA boundaries for model, firmware, host,
ISA, canonical protocol and wire facade, and confirms the frozen suite still
depends on the old hardware facade. This is authored dependency closure; external
package transitives are resolved by the successful Dune build.

Coordinator/A/C own final 17-RTL/six-role comparisons and archive relocation
hashes. This handoff does not substitute software test results for those checks.

## Introduced-formatting closure

After independent final 481-registration/RTL clearance, applied only formatter
output through `apply_patch` to the eleven B-owned introduced failures selected
by `.dev/final-layout/hardware/integrated-format-classification.json`:

| Source | Formatter check |
| --- | --- |
| `firmware/examples/dune` | PASS |
| `ip/emulator_core/verif/control_port/item.ml` | PASS |
| `ip/emulator_core/verif/core_engine/core_engine_control_port_tests.ml` | PASS |
| `ip/host_link/verif/command_dispatch/command_dispatch_testbench.ml` | PASS |
| `ip/mechanisms/verif/blocks/input_events/input_events_four_state_bench.ml` | PASS |
| `ip/mechanisms/verif/blocks/pin_bank/pin_bank_testbench.ml` | PASS |
| `ip/program_memory_controller/verif/controller/protocol_core_property_tests.ml` | PASS |
| `software/cli/protemu.ml` | PASS |
| `software/cli/test/dune` | PASS |
| `software/simulator/dune` | PASS |
| `verif/backends/conformance/dune` | PASS |

`preformat.json` preserves all eleven source texts and hashes of the 23 mapped
baseline failures before these edits. `format-closure.json` records the eleven
before/after source hashes and successful formatter equality checks, verifies
all 23 baseline files and eight frozen files remain byte-identical, and verifies
formatting changed no expectation payload. No baseline-formatting file was fixed.

Follow-up checks, serialized under `../.protemu-build.lock` with the existing
switch and `-j5`:

- `dune build -j5 @install @lint`: PASS (`format-install-lint.log`).
- Scoped `dune runtest -j5` over core-engine, command-dispatch, input-events,
  pin-bank, controller, CLI, simulator, backend-conformance and reference-model
  suites: PASS (`format-scoped-suites.log`).
- Refreshed `preservation.json`: PASS, 481 total registrations, unchanged
  functional bytes and the same six-file path-only expectation whitelist.
- Refreshed `dependencies.json`: PASS.
- `git diff --check`: PASS.

No heavy RTL rerun was needed for this formatting-only follow-up. No coordinator
documentation, hardware/public-facade/private-oracle-adapter source or frozen
archive was edited by B in this closure.
