# Ownership-oriented layout migration

2026-11-11. **Implemented and verified; owner review pending.** This is the bounded ownership/path
amendment to [architecture_migration.md](architecture_migration.md), not a new
hardware milestone or a replacement for the verification-overhaul queue.

## Scope and preservation

Move existing RTL and verification to their owners, extract package/project
construction from the bundle CLI, and update active source-path consumers.
Preserve hardware behavior, flat `Hardcaml_protemu` module names, pure-library
boundaries, emitted module/port names, resource `program`, Flops selection and
latency. Keep the current compatible installed ASIC API (`simulation_build`).
PT.3 dependency/API and Exact-SRAM adoption remain separate.

The serial-host pilot's later decisions remain authoritative: interface-owned
agent libraries, independent monitors, test-owned scheduling, and scoped
environments. Sequences remain lists/generators of items. This move neither
replaces scenarios/checkers nor installs a new verification framework. The frozen
HL4a suite stays active, byte-preserved and excluded from formatting changes.

No Git staging, commits, pushes, index/history/configuration mutation. Existing
disposable fixture operations are permitted. Builds run **sequentially at `-j5`**
under `/home/wayne/devel/jane/.protemu-build.lock`, within the owner's global20
pool. Three implementation agents have disjoint source ownership; no concurrent
heavy builds, provisioning or physical flow is part of this migration.

## Identified baseline

Clean starting revision: `b3a4cb6a420613465f635a616bedba967c4ab307`.
Persistent evidence:
`.dev/ownership-migration/20261111-b3a4cb6-baseline/RECEIPT.md`.
The receipt records all356 tracked files,475 inline-test registrations, frozen
oracle hashes, installed APIs,17 emitted RTL outputs, all three bundle kinds and
both source roles, ordered ports, and same-tool generic synthesis statistics.

Baseline `@install @lint`, forced ordinary `runtest`, and forced `@rtl` passed,
including the three independent loader-peer configurations. Supplemental memory
and loader simulation-role lint reports pre-existing `INITIALDLY` warnings as
failures; those failures are retained rather than changing warning policy.

## Accepted destination map

| Current owner | New owner |
| --- | --- |
| `lib/pluggable_primitives/` | `ip/mechanisms/rtl/` |
| `lib/staging/` | `ip/mechanisms/rtl/staging/` |
| `lib/memory/` | `ip/program_memory_controller/rtl/` |
| `lib/emulator_core/` | `ip/emulator_core/rtl/` |
| `lib/legacy/executable_core.ml` | `ip/emulator_core/rtl/legacy/` |
| `lib/host_link/` | `ip/host_link/rtl/` |
| `lib/system/protemu_top.ml` | `rtl/protemu_top.ml` |
| `lib/legacy/p0_observable.ml` | `chip_top/rtl/bringup/p0_observable.ml` |
| Hardware under `test/primitives/` and staging integration suites | `ip/mechanisms/verif/` |
| `test/core/protocol_core/` | `ip/program_memory_controller/verif/controller/` |
| `test/integration/program_memory_backend/` | `ip/program_memory_controller/verif/backend_integration/` |
| `test/core/control_execution/` | `ip/emulator_core/verif/execution/` |
| `test/core/control_port/` | `ip/emulator_core/verif/control_port/` |
| `test/integration/core_engine/` | `ip/emulator_core/verif/core_engine/` |
| `test/host_link/` | `ip/host_link/verif/`, including agents, endpoint and active frozen archive |
| `test/integration/wrapper/` (actually P0 core checks) | `chip_top/verif/observable/core/` |
| Shared observation/replay/environment support | `verif/common/` |
| Cross-owner sweep entry point | `verif/regression/` |
| Whole-system emitted serial peer | `verif/system/emitted/` |
| Package compositions/project declaration in `bin/asic_bundle.ml` | `chip_top/rtl/` and `chip_top/project/` |
| Authored emitted-RTL benches | Owning IP's or chip's `verif/`; target rules may retain compatibility targets |

`lib/` remains a build facade for the existing public hardware library, with
explicit module/source gathering rather than duplicate authored implementations.
ASIC-dependent package construction has its own library. `f_model/`, `isa/`,
`host_link_wire/` and their public/library contracts remain unchanged. Their pure
software/model tests stay distinguishable from DUT verification. Host/simulator,
codec and verification-support qualification belong under software/tool `test/`.

Do not reinterpret `archived/hl4a` as inert data. Conversely, retained `flow_results/`,
dated reports and historical bundle snapshots stay inert historical bytes. Root
`loader_core.v` and tracked generated P0 RTL remain untouched unless an explicit
preservation finding requires a separate decision.

## Implementation ownership and gates

1. Hardware agent: mechanical RTL moves, `lib/dune` facade and hardware-only tests.
2. Verification agent: owner-local/shared verification moves, support/test library
   boundaries, root sweep aliases and software-test path consumers outside TT.
3. Package/tooling agent: package extraction, `bin/` wiring, emitted benches and
   TT Dune/scripts/source inventories/CI paths. Keep target execution entry points.
4. Coordinator: authoritative documentation, integration, independent review and
   verified closeout. Source fixes are attributed to their actual scope.

Acceptance requires the baseline obligations to remain registered, functional
goldens/programs/traces and frozen oracle bytes preserved, ordinary and emitted
RTL checks passing, and pre/post RTL/ports/resources compared. Bundle source-path
and identity changes are expected and reviewed separately from logic changes.
Every baseline failure or unavailable check is reported honestly. AM3 protocol
API restructuring, AM5 interface grouping, general VO continuation and PT.3
adoption are not implicitly completed by this layout work.

## Execution record

- Baseline captured before implementation. Three agents performed disjoint RTL,
  verification and package/tooling slices. All heavy builds were serialized at
  `-j5` under the shared lock. No dependency upgrade, physical implementation/P&R
  or sibling edit occurred; HDL simulation and generic synthesis did run.
- All26 relocated hardware source files are byte-identical. `lib/dune` gathers
  them explicitly while retaining the26 public flat modules and installed interfaces.
- Verification moved142 files;135 are byte-identical. Required path/stanza and
  diagnostic-identity adjustments preserve all scenarios, expect blocks, programs,
  seeds and goldens. All475 registrations remain:348 relocated,127 retained.
  The eight frozen archive files, including Dune and formatting exclusion, match.
- `protemu_chip_project` owns `Chip_project`, `Package_top`, `Program_memory`,
  `Observable_design` and `Memory_design`. The current ASIC API, Flops binding,
  latency, reset/output gating and CLI modes remain unchanged.
- Eight authored HDL benches moved byte-identically. TT compatibility targets still
  run all three independent loader-peer configurations. Source inventories, sandbox
  dependencies, script/Makefile paths and CI job flags were updated together.
- All17 generated RTL files and six bundle RTL roles match baseline byte-for-byte.
  All six same-tool bundle synthesis statistics match. Pins, constraints, flow
  configuration and resource selections match. Bundle identities change only with
  reviewed source-path/inventory/source-formatting changes.
- Passing checks: `@install @lint`, forced ordinary `runtest`, forced `@rtl`,
  `@verification-required`, `@verification-long`, `@verification-four-state`, host
  CLI/goldens, all three bundle metadata/repeatability/conflict checks, and explicit
  observable/memory simulations for both source roles.
- Independent source/evidence review found no correctness blocker and identified
  seven introduced formatting failures. Those seven were corrected and scoped
  formatting plus fresh install/lint and output comparisons passed. Global `@fmt`
  still reports23 failures, all byte-identical to mapped baseline files; none is
  introduced. Supplemental behavioral-RAM `INITIALDLY` failures remain recorded.
- No expectations were promoted. Original failed intermediate path/formatting
  checks remain beside subsequent successful checks. The Git index is unchanged;
  no staging/history/configuration operation was performed.

### Persistent evidence

All paths are beneath `.dev/ownership-migration/` in this checkout:

| Directory | Evidence |
| --- | --- |
| `20261111-b3a4cb6-baseline/` | Starting356 tracked files, registrations, installed APIs, generated outputs and commands |
| `20261111-hardware-owner/` | Exact26-file move map, source hashes and15 direct-generator comparisons |
| `verification-post/` | Exhaustive142-file map,475 registration map, frozen/golden audits and test commands |
| `package-tooling-post/` | All17 generated outputs, six bundle roles/statistics, benches and active-path checks |
| `independent-review/20261111-final/` | Independent source/dependency/evidence review and formatting findings |
| `package-tooling-format-post/` | Seven formatting corrections, baseline-only formatting classification and refreshed bundle manifests |

The refreshed observable/memory/loader identity prefixes are respectively
`bac91a5ec1b121f9`, `c5447c5b949e36e2`, and `6aa524a6212878dc`; complete identities
and file inventories are recorded in the final comparison receipt. These identify
new source captures, not changed hardware outputs.

### Remaining work

The current [layout guide](repository_layout.md) and root README own live paths.
Historical records retain their original source/command spellings. AM0's original
pre-AM1/AM2 evidence gaps are not retroactively closed by this new baseline. AM3
protocol/Codec separation, AM5 grouped interfaces/responsibility review, AM6 owner
acceptance and wider VO continuation remain open at their recorded scope. PT.3
needs a deliberate current-ASIC API/dependency upgrade and consumer acceptance.
