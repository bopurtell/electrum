# Verification ownership migration — 2026-11-11

Implementation delivered unstaged against baseline
`b3a4cb6a420613465f635a616bedba967c4ab307`. Baseline evidence is the sibling
`20261111-b3a4cb6-baseline/` directory. Starting working tree: coordinator edits to
`docs/README.md`, `docs/architecture_migration.md`, `docs/verification.md`, untracked
`docs/ownership_layout.md` and `.dev/`. Other agents concurrently own hardware,
package/tooling and authoritative documentation. No index/history/configuration
operation was performed. All authored moves and edits used apply_patch.

## Preservation evidence

`audit.json` is the exhaustive old/new file map: 142 files, with baseline/current
SHA-256, mode, byte-comparison and inline-registration count for every moved file;
it also enumerates every one of the 475 mapped inline registration lines.
`audit.py` independently regenerates the report from the immutable baseline tar
and current sources, asserting registration multiset equality, identical expect
forms, all moved modes, all frozen hashes and retained pure-tree hashes.

- 142 moved files; 135 are byte-identical.
- 348 moved inline registrations plus 127 retained registrations = 475 baseline
  obligations; no new or removed registration.
- All test/scenario source files and expect blocks remain byte-identical. The four
  focused host-link testbenches preserve historical exception atoms in their
  diagnostic-return helpers. No monitor, driver, scheduler or scenario was replaced.
- All eight frozen files match, including `archived/hl4a/dune` and the parent
  `.ocamlformat-ignore`; the archive's 40 tests remain registered and pass.
- UART trace, CLI golden files, models, ISA, wire library and their retained test
  trees match baseline. Workflow script remains executable, mode `0775`.
- Registration-map SHA-256:
  `5ce780c72782e2f5434c7015686c5770d61fd97f3528a4316ac3d41448460753`.
- File-map SHA-256 (ordered JSON rows, including both hashes):
  `58df98abf41f70f64b77818b5661d607879e78c50f8e86de358200ec8c2099d3`.

## Complete owner map and registration counts

Every directory move includes its full contents. Counts are actual inline
registrations, not counts of scenarios invoked within a registration.

| Original owner | Destination | Files | Registrations |
| --- | --- | ---: | ---: |
| `test/primitives/byte_fifo/` | `ip/mechanisms/verif/blocks/byte_fifo/` | 3 | 4 |
| `test/primitives/input_events/` | `ip/mechanisms/verif/blocks/input_events/` | 8 | 14 |
| `test/primitives/pin_bank/` | `ip/mechanisms/verif/blocks/pin_bank/` | 5 | 6 |
| `test/primitives/shift_lane/` | `ip/mechanisms/verif/blocks/shift_lane/` | 3 | 4 |
| `test/primitives/timing/` | `ip/mechanisms/verif/blocks/timing/` | 3 | 3 |
| `test/primitives/observed_transfer/` | `ip/mechanisms/verif/staging/observed_transfer/` | 5 | 22 |
| `test/primitives/uart_tx/` | `ip/mechanisms/verif/staging/uart_tx/` | 3 | 2 |
| `test/integration/observed_transfer_bank/` | `ip/mechanisms/verif/staging/observed_transfer_bank/` | 4 | 13 |
| `test/integration/primitive_demo/` | `ip/mechanisms/verif/staging/primitive_demo/` | 3 | 1 |
| `test/integration/uart_slice/` | `ip/mechanisms/verif/staging/uart_slice/` | 7 | 15 |
| `test/core/protocol_core/` | `ip/program_memory_controller/verif/controller/` | 4 | 3 |
| `test/integration/program_memory_backend/` | `ip/program_memory_controller/verif/backend_integration/` | 4 | 4 |
| `test/core/control_execution/` | `ip/emulator_core/verif/execution/` | 8 | 25 |
| `test/core/control_port/` | `ip/emulator_core/verif/control_port/` | 6 | 0 |
| `test/integration/core_engine/` | `ip/emulator_core/verif/core_engine/` | 5 | 22 |
| `test/host_link/` | `ip/host_link/verif/` | 48 | 186 |
| `test/integration/wrapper/` | `chip_top/verif/observable/core/` | 3 | 2 |
| `test/integration/host_simulator/` | `test/host_simulator/` | 9 | 16 |
| `test/common/` | split by existing stanza/module ownership below | 9 | 6 |
| `test/dune`, `test/verification_sweep.ml` | `verif/regression/dune`, `verif/regression/verification_sweep.ml` | 2 | 0 |

`test/common/` exact split:

- `observation.ml`, `replay.ml`, `env.ml` → `verif/common/`, preserving the
  unwrapped `protemu_test_common` library with the same explicit modules/dependencies.
- `checker_expect_tests.ml`, `replay_expect_tests.ml` → `test/verification_support/`,
  preserving `protemu_common_tests` and its dependency on `protemu_pin_bank_testbench`.
- `backend_conformance.ml`, `backend_conformance_expect_tests.ml`,
  `backend_conformance_bench.ml` → `test/backend_conformance/`, preserving
  `protemu_backend_conformance`, `protemu_backend_conformance_tests` and the bench.
- Original Dune stanzas relocated into those three directories. Reusable common
  support has no dependency on qualification tests or the pin-bank fixture, so the
  existing support/fixture import relation stays acyclic.

Only seven moved files differ: `verif/common/dune` (stanza split),
`verif/common/replay.ml` (redacted snapshot spelling), `test/host_simulator/dune`
(relative paths), and the four focused host-link testbenches (exception atoms).
Root aliases and `scripts/p3.4-cli-workflow.sh` consume their new destinations.

### Diagnostic compatibility

Live Replay reports/artifacts retain actual new source paths. Redacted controlled
fixtures retain their old path spelling so expectation bytes stay intact. Three
alias-only compatibility Dune files remain at `test/core/protocol_core/`,
`test/core/control_execution/`, and `test/integration/uart_slice/`: their old
snapshot-tested rerun commands forward to the owning suite. These contain no
implementation, modules or duplicate test library. Ordinary recursive regression
depends on the same underlying actions once.

## Checks executed by the verification agent

All Dune invocations used `-j 5`, sequentially under
`flock /home/wayne/devel/jane/.protemu-build.lock`, via `scripts/with-switch.sh`;
the final commands explicitly set `OPAM_SWITCH=5.2.0+ox`.

| Command (after the common lock/switch prefix) | Result |
| --- | --- |
| `dune build @install @lint -j 5` | Pass after relocation |
| `dune runtest --force -j 5` | Initial run exposed only relocated exception/report path text; no expectations promoted |
| `dune runtest --force -j 5` | One lock-wait attempt timed out at 120 seconds while agent 3 held the lock; not reported as a test result |
| `dune runtest --force -j 5` (600-second tool budget) | Pass, full fresh ordinary regression, including active archive and CLI/trace diffs |
| `dune build @install @lint @verification-required @verification-long @verification-four-state -j 5` | Pass; both long-sweep success messages printed |
| `./scripts/p3.4-cli-workflow.sh` (under lock/switch environment) | Pass; image and timeout-output comparisons pass |
| `dune build @install @lint @fmt -j 5` | Formatting fails; full output in `fmt.log` |
| Focused formatting aliases over common/support/software and dispatch/PHY directories | Only byte-preserved `test/backend_conformance/backend_conformance.ml` fails |
| `ocamlformat --check` on all five edited OCaml files | Pass |
| `git diff --check` | Pass |
| `python3 .dev/ownership-migration/verification-post/audit.py` | Pass; exhaustive result retained as `audit.json` |

Global formatting also reports baseline-preserved RTL/model/test files and
other-agent new Dune/package formatting. This task fixes its newly introduced
formatting only; byte-preserved files retain their baseline bytes. All changed
OCaml files pass the direct formatter check. Emitted RTL/EDA was not run by this
agent; agent 3 owns those checks and their evidence.

## Agent 3 / coordinator handoff

TT-relative dependency destinations (relative to `tinytapeout/src/` or
`tinytapeout/test/` as appropriate):

- `../../test/integration/program_memory_backend/emit_program_memory_backend.exe`
  → `../../ip/program_memory_controller/verif/backend_integration/emit_program_memory_backend.exe`.
- `../../test/integration/uart_slice/uart_frame.trace`
  → `../../ip/mechanisms/verif/staging/uart_slice/uart_frame.trace`.
- UART trace emitter:
  `test/integration/uart_slice/emit_uart_frame_trace.exe`
  → `ip/mechanisms/verif/staging/uart_slice/emit_uart_frame_trace.exe`.
- Program-memory controller suite:
  `test/core/protocol_core/` → `ip/program_memory_controller/verif/controller/`.
- Shared/system split: this agent owns `verif/common/` and `verif/regression/`;
  agent 3 owns `verif/system/emitted/` and other authored emitted benches.

Both TT executable/trace dependencies already name these new destinations in
agent 3's concurrently edited Dune files at final inspection. Authoritative docs
and migration acceptance remain the coordinator's responsibility; this receipt
supplies the dated implementation record and evidence for that documentation.
