# Architecture and migration plan

**Delivered layout follow-up:** [final hardware-first layout](final_layout_migration.md)
uses singular `asic/`, owner-local wrapped hardware libraries, colocated software/
model tests and explicit historical archives. The root facade and installed flat
hardware API are removed; AM5 port grouping remains separately pending.

**Current status, 2026-11-11:** this document describes the implemented IP/system/
chip ownership model and the remaining AM work. [Repository layout](repository_layout.md)
is the detailed path guide; [ownership migration](ownership_layout.md) records the
preservation baseline. Dated implementation records retain historical names/results.

| Item | Implementation status | Remaining boundary |
| --- | --- | --- |
| AM0 | Identified post-rename ownership and AM3 baselines captured | Original pre-AM1/AM2 evidence gaps remain; do not claim retrospective equivalence |
| AM1 | Core/controller names implemented and preserved | Original owner acceptance remains separately recorded |
| AM2 | Host_link / Electrum_top ownership implemented and preserved | Original owner acceptance remains separately recorded |
| AM3 | **Protocol/Codec separation implemented and independently reviewed** | Owner review; temporary old-source API facade retained |
| AM4 | **Chip/package/project extraction implemented and independently reviewed** | Owner review; no SRAM/backend upgrade implied |
| AM5 | **Pending** grouped interfaces and responsibility review | Preserve flattened ports and temporal contracts |
| AM6 | **Pending** architecture acceptance / verification handoff | Reconcile owner acceptance and remaining AM5 scope |

The earlier checklist below retains owner-acceptance gates; an unchecked gate does
not mean an implemented item must be written again. Implementation evidence is in
the dated records. VO work and PT.3 dependency/SRAM adoption are separate queues.

## Authority and order of work

This document owns architectural naming, responsibility and interface migration.
Broader verification-infrastructure changes remain sequenced through AM6 and
[verification.md](verification.md#verification-overhaul-sequence), with the later
explicitly authorized [serial-host pilot](serial_host_pilot.md) preserved as an
exception already implemented. Existing tests remain the preservation baseline.
Mechanical path/API updates do not authorize replacing drivers, assertions or scenarios.

- [construction-plan.md](construction-plan.md) and the P3 records own hardware behavior.
- [verification.md](verification.md) owns enduring verification architecture and the VO
  implementation sequence, including functional coverage, memory verification, and formal.
- [host_link_migration.md](host_link_migration.md) records the completed HL decomposition;
  [organization_migration.md](organization_migration.md) records the earlier directory move.
  Their historical names and results are not current rename instructions.
- [history/verification_migration.md](history/verification_migration.md) records the
  previous verification refactor; it does not sequence this migration.
- [flow.md](flow.md) owns build-bundle and physical-flow execution.

### Execution rules

Record the starting revision and all relevant dirty/untracked inputs. Preserve unrelated
working-tree changes. Only the repository owner commits; implementation agents return
unstaged changes and evidence unless the owner explicitly requests otherwise.

Every `dune build`, `dune runtest`, and `dune exec` invocation
must include `-j 5`. Run them sequentially; concurrent heavy builds have caused server
failures. A tool that could not run is recorded as unavailable/not run, never as passing.

Every implementation-agent handoff must include an end-of-task documentation step. After
implementation and verification, update this document's Implementation records with a dated
entry for the assigned AM item: starting source/diff, delivered changes, exact commands and
results, evidence locations, deviations, and remaining work. Update the entry even when the
work is partial or blocked, labelling that status accurately. The final response must point
to the entry. Record implementation completion separately from owner/planning acceptance;
do not check acceptance boxes merely because implementation was delivered. This per-item
record is required at the end of each handoff, not deferred to AM6's broader active-doc sweep.
Future agent prompts must repeat this requirement alongside the no-commits and sequential
`-j 5` execution rules. No AI agent may create or amend git commits.

## Accepted decisions

1. Use names describing the hardware's role, not its construction phase or one historical
   feature such as loading firmware.
2. Decompose by responsibility, state ownership, and useful interface contracts. Thin
   composition files are appropriate; a module is not split merely to increase file count.
3. Source ownership follows `ip/<owner>/{rtl,verif}`, including reusable
   `ip/electrum_system/`, and singular `asic/{rtl,project,cli,verif}`. Wrapped
   owner libraries now enforce explicit dependencies. Installed consumers use the
   `Electrum_*` owner roots; the flat `Electrum` API is removed. Only the
   frozen oracle retains a private test adapter. ASIC libraries keep resource/
   target tooling out of reusable hardware.
4. Keep program storage separate from its access controller and from the system using it.
5. Keep protocol definitions and software byte conversion separate from the hardware
   endpoint and physical transaction scheduling.
6. Preserve behavior, cycle contracts, resource selection, and the existing package ABI.
   This migration adds no capture memory, payload cache, transport, or memory arbitration feature.

## Current source ownership

These are implemented owner paths, not proposed renames. Historical generator
selectors and emitted module names remain compatible even when their spelling
differs from the current OCaml owner.

| Owner | Current source | Responsibility |
| --- | --- | --- |
| `Host_link` | `ip/host_link/rtl/host_link.ml` | Complete serial control endpoint; composes PHY/RX/dispatch/TX |
| `Electrum_top` | `ip/electrum_system/rtl/electrum_top.ml` | Endpoint/core system composition; external program-memory port |
| `Program_memory_controller` | `ip/program_memory_controller/rtl/program_memory_controller.ml` | Load/readback/verify, image validity, fetch/access arbitration |
| `Execution_unit` | `ip/emulator_core/rtl/execution_unit.ml` | Execution, architectural state, run/stop/abort/step |
| `Primitive_dispatch` | `ip/emulator_core/rtl/primitive_dispatch.ml` | Execution-command dispatch and mechanism composition |
| `Emulator_core` | `ip/emulator_core/rtl/emulator_core.ml` | Controller + execution + mechanisms |
| Mechanisms | `ip/mechanisms/rtl/` and `staging/` | Existing leaf blocks and experimental compositions |
| `Package_top` | `asic/rtl/package_top.ml` | Target-specific system/resource/pin/reset composition |
| `Program_memory` | `asic/rtl/program_memory.ml` | Chip-owned storage binding, currently explicit Flops |
| `Chip_project` | `asic/project/chip_project.ml` | Pinout, project declaration and source inventories |
| `Host_link_protocol` / `Codec` | `ip/host_link/protocol/` | Pure protocol vocabulary/layouts versus software byte conversion |

`Electrum_top` and `Host_link` are compositions, not monolithic implementations of
their children. Preserve their extracted boundaries; do not repeat HL4 or invent
pipeline stages merely to produce more files.

## Target hierarchy and ownership

```text
Package_top                       target-specific package integration
├── Electrum_top                   reusable emulator system, no RAM implementation
│   ├── Host_link
│   │   ├── Serial_phy            input synchronization and edge events
│   │   ├── Frame_rx              receive, validation, retained request fields
│   │   ├── Command_dispatch      control offers, waits, response construction
│   │   └── Frame_tx              retained response, arming, shifting, replay/commit
│   └── Emulator_core
│       ├── Program_memory_controller
│       ├── Execution_unit
│       └── Primitive_dispatch    existing mechanism composition and primitives
└── Program_memory                selected resource binding, currently explicit flops
```

The diagram describes semantic containment; emitted RTL may be flattened. It does not
require one Verilog module per OCaml module.

### Host endpoint and downstream control

`Host_link` exposes physical-side serial inputs/outputs and a downstream `Control_port`.
The PHY produces synchronized observations, not core commands. RX produces validated
handoffs consumed by dispatch; dispatch produces core requests consumed by `Emulator_core`.
The core produces decisions/status consumed by dispatch. TX consumes published responses
and PHY events. PHY clock/select events may fan out to both RX and TX.

`Control_port` remains the core-owned request/decision/status contract. A single producer
and consumer at a transaction boundary does not imply a FIFO or a ready/valid conversion.
Retained fields, eligibility, one-shot offers, completion waits, and same-cycle priorities
retain their existing contracts. The serial clock remains sampled data, not a logic clock.

`Electrum_top` connects those components, exposes the program-memory and protocol-pin
boundaries, and records unused interface tie-offs. It does not decode frames or own RAM.
`Package_top` supplies memory, maps package pins, and adapts reset/output enables. Package
choices do not leak into `Host_link` or `Emulator_core`.

### Memory: controller, storage, and implementation

- `ip/program_memory_controller/rtl/` owns target-independent access logic and contracts. Its
  implementation is `Program_memory_controller`; a directory rename does not add storage.
- `Program_memory_controller` owns legal access, image metadata, and instruction/readback
  validity. It does not implement a vendor SRAM or select a physical backend.
- `Program_memory` in the package library binds the existing width/depth/latency requirement
  to `hardcaml_asic.Single_port_ram`. Backend primitives and their generic conformance remain
  owned by `hardcaml_asic`; this is not a second memory backend implementation.
- The system boundary remains the existing latency-one single-port contract. The package
  selects the implementation; a test fixture may supply a contract model instead.

Capture buffers, TX/RX payload buffers, and shared-memory arbitration require separate
feature contracts if introduced. Name buffers by purpose. Do not create a `Memory_system`
owner until there is actual shared coordination to own. Simulator-side trace storage is
not evidence of an implemented hardware capture buffer.

### Pure protocol and codec

`Host_link_protocol` owns version, commands/results, layouts, capability/status encodings,
and CRC parameters. `Host_link_protocol.Codec` owns typed request encoding and response
decoding/correlation. A codec serializes/parses bytes; it does not compress data, clock
pins, poll ready, retry commands, or commit responses.

Keep the library free of Hardcaml and emulator implementation dependencies. Preserve fixed
vectors, validation precedence, range checks, and the distinction between malformed bytes
and a well-formed refusal. Software CRC computation can be a pure helper; the hardware
  `Wire_crc` under `ip/host_link/rtl/` remains a hardware helper, not the software
  reference implementation.

Implemented canonical API: internal Dune library `host_link_protocol`, public
package `electrum.host_link_protocol`, root `Host_link_protocol`.
Definitions/types/layouts and CRC parameters are root APIs; software CRC/u16
conversion and request/response byte operations/errors are under `Codec`.

```ocaml
module Protocol = Host_link_protocol
let request = Protocol.Request.Read_word { address = 0 }
let encoded = Protocol.Codec.Request.encode ~tag:1 request
```

`software/compatibility/host_link_wire/` is a thin temporary source-compatibility facade, public package
`electrum.host_link_wire`, root path `Electrum_host_link_wire.Wire`. It
reexports canonical types and helpers; it contains no independent protocol/codec
implementation. New consumers use the canonical API. Retaining the facade protects
the frozen regression and external source users, not binary compatibility: compiled
clients should rebuild. Removal requires an explicit consumer/archive decision.

### Responsibility-based submodules

Every further extraction starts with a short ownership table: state, writers, readers,
reset/disable behavior, inputs/outputs, handoff timing, and dependencies. A leaf should have
a meaningful standalone contract. Composition modules primarily wire children and expose
interfaces; package composition additionally selects resources and target adaptation.

Do not split `I`, `O`, and `create` into separate files as a blanket convention. Keep them
with their owner when cohesive. Keep shared interface definitions in named modules when
multiple owners use the same contract. Preserve independently useful existing children
such as `Instruction_decoder`; additional execution/dispatch splitting must have its own
approved ownership analysis before implementation.

### Grouped interfaces

Use nested Hardcaml interface records for meaningful groups: serial inputs/outputs,
`Control_port` request/decision/status, program-memory request/read data, and protocol-pin
signals. Separate incoming and outgoing directions in `I` and `O`; mixed logical
interfaces within one `I` record are normal. Clock/reset/enable may remain direct fields.

`Control_port` already demonstrates nested interfaces. This is OCaml-level grouping,
not a requirement to emit SystemVerilog interfaces or modports. AM5 must inventory derived
flat names, widths, order, and directions and preserve external names with explicit naming
attributes/adaptation. No ready/ack handshake, queue, or latency is added just for grouping.

## Implemented source layout and dependency ownership

```text
ip/
  mechanisms/{rtl,verif}/        leaf mechanisms and staging compositions
  program_memory_controller/
    rtl/                        access controller, not storage implementation
    verif/                      controller contracts and RAM-consumer integration
  emulator_core/{rtl,verif}/     execution/dispatch/core and control-port agent
  host_link/{rtl,protocol,verif}/ endpoint/children, pure protocol, agents/environment
  electrum_system/rtl/            Electrum_top reusable system composition
asic/
  rtl/                          package tops, resource binding and bring-up designs
  project/                      ASIC project declaration and source inventory
  cli/                          bundle/project entry points
  verif/                        chip/package verification
  tinytapeout/                  target-specific collateral/flow helpers
verif/                          common, backends, reference model, system, regression
spec/isa/                       shared instruction specification/assembler
firmware/examples/              selected-ISA example programs
software/{host,simulator,cli}/   host API, simulator and CLI; local tests/examples
software/compatibility/         old pure protocol API, not a second implementation
scripts/                        explicit setup/activation helpers
archive/legacy/                 historical evidence, excluded from live rule discovery
```

`electrum_chip_project` may depend on `hardcaml_asic`, `electrum` and target
adapters. Reusable hardware must not acquire an ASIC-library dependency. Package
construction is already outside command-line initialization, so fixtures can use
the same production composition without importing CLI side effects.

There is no global copy-all hardware assembly and no installed root hardware
module. The `electrum` package is a container for named sublibraries such
as `.core` and `.host_link`. A private26-alias adapter at
`ip/host_link/verif/archived/support/` lets frozen HL4a run unchanged; it is not
installed and no canonical library depends on it. Unwrapped test libraries are
retained where their existing harness contracts require them; this does not flatten
the hardware dependency graph or describe emitted-Verilog hierarchy.

Review architectural dependencies despite the flat namespace: system depends on endpoint
and emulator; endpoint depends on the control contract and shared configuration, not the
emulator implementation constructor; core depends on memory control and primitives;
package depends on the reusable system and resource/target layer. Existing width/INFO
dependencies on core configuration must be inventoried before moving their ownership.
Owner-library dependencies are enforced by Dune. Port/interface grouping remains
AM5 work and is independent of OCaml module names or physical RTL flattening.

## Implementation sequence

Each item is a separate handoff/review unit. The status table distinguishes delivered
implementation from pending work; boxes below are owner-acceptance obligations.
Do not repeat implemented renames/extractions merely because acceptance is unchecked.

### AM0 — Baseline and change inventory

- [ ] Record source/diff, dependency/tool identities, existing regression results, and
  generated standalone/bundle RTL for both source roles.
- [ ] Enumerate OCaml modules, test imports/paths, Dune dependencies, generator selectors,
  emitted module/port names, manifests/source-input lists, scripts, CI, and active docs
  affected by the migration. Record the root `loader_core.v` snapshot's provenance and
  consumers; do not assume it is an input to active Dune tests or delete it incidentally.
- [ ] Record the accepted HL4 exit baseline and remaining product/physical obligations.

Exit: a reproducible baseline and explicit old-to-new map. Existing failures are identified
before renames, not silently attributed to them.

Retrospective closeout (owner direction, 2026-09-26): AM1/AM2 implementation has already
proceeded without a separate AM0 capture. Recover available historical evidence from
identified revisions and retained artifacts, distinguishing original results from later
reconstructions. Record the scope of `37c85e5` as a comparison baseline, including any
architectural edits already present. Do not represent a reconstructed committed tree as
the exact original dirty working tree. Identify unrecoverable pre-change inputs/results
explicitly; the owner accepts that a complete original baseline may no longer be available.
Complete the consumer/compatibility inventory and establish an identified, reproducible
post-AM1/AM2 source-and-artifact baseline for subsequent stages. Closeout must list the
historical gaps and their consequences for comparison; this accommodation does not turn
missing evidence into a pass or mark AM0 complete by itself.

### AM1 — Core and memory-controller naming

Prerequisite: AM0.

- [ ] Accept the implemented `Program_memory_controller`, `Execution_unit`,
  `Primitive_dispatch` and `Emulator_core` names and their current IP ownership.
- [ ] Accept the updated live consumers, tests, generators, metadata inputs and references.
  Preserve Config values and control-port ownership; do not redesign memory or execution.

Exit: unchanged functional expectations and reviewed generated-output comparison. Old names
remain only in explicitly historical material or recorded compatibility surfaces.

### AM2 — Endpoint and system ownership

Prerequisite: AM1.

- [ ] Accept `Host_link` under its IP owner, retaining its four children/helpers.
- [ ] Accept `Electrum_top` under reusable `ip/electrum_system/rtl/`.
- [ ] Accept the documented logical interfaces, tie-offs and external-memory boundary.

Exit: the top remains thin composition; endpoint behavior and every existing exact-cycle
assertion remain unchanged. This stage does not move scenario ownership or rebuild agents.

### AM3 — Protocol library and Codec separation

Prerequisite: AM2.

**Implemented and independently reviewed, 2026-11-11.** See the AM3 execution record.

- [ ] Accept `Host_link_protocol` root definitions/types and `Codec` byte operations,
  including the documented internal/public package names and compatibility facade.
- [ ] Accept canonical active consumers, codec tests, Dune dependencies and source
  inventories, with independent vectors and HDL peer preserved.

Exit: pure library dependency boundary, unchanged encoding/decoding behavior and wire bytes,
and reviewed hardware-output comparison. Record any transitional aliases and their removal.

### AM4 — Package and program-memory binding extraction

Prerequisite: AM3.

**Authorized ordering amendment, 2026-11-11:** owner-approved organizational work
delivered the package/project extraction independently of AM3, preserving the
existing protocol API. `electrum_chip_project` now owns tops, RAM binding and
declaration; all six bundle RTL roles are byte-identical to the identified current
baseline. See the implementation record below. This does not accept AM3 or mark
the broader AM4 owner-acceptance checklist complete implicitly.

- [ ] Accept `electrum_chip_project` with `Package_top`, `Program_memory`, bring-up tops
  and reusable project construction under the chip owner.
- [ ] Accept the thin argument-parsing/emission entry point in `asic/cli/`; tests must not need to
  import a CLI module with top-level side effects to elaborate a production top.
- [ ] Preserve resource policy (currently Flops), source roles, target constraints, package
  pin ABI, reset/output gating, and all existing flow modes.

Exit: the same package can be constructed by the emitter and an OCaml fixture; reusable hardware stays
ASIC-independent. Manifest path/identity changes are explained; hardware changes are not
accepted merely because bundle metadata changed.

### AM5 — Grouped interfaces and responsibility review

Prerequisite: AM4.

- [ ] Specify ownership and flattened-port maps for the serial, memory, and protocol-pin
  groups; adopt nested interfaces without timing or package-ABI changes.
- [ ] Review the renamed hierarchy for remaining mixed responsibilities. Record justified
  extraction candidates or that the existing boundary is sufficient; implement only
  separately specified extractions with state/timing ownership and preservation checks.

Exit: interface grouping and dependency review are complete. No required split exists
solely because a composition is one file. Unresolved behavioral changes are separate work,
not hidden conditions on this migration.

### AM6 — Architecture acceptance and verification handoff

Prerequisite: AM1–AM5 accepted.

- [ ] Re-run the relevant existing build/lint, ordinary regression, emitted-RTL tiers,
  and bundle checks against the final source state; record exact commands/results.
- [ ] Review module/port/resource inventories and cumulative RTL/synthesis deltas.
- [ ] Update active docs, source lists, and invocation examples; retain historical records.
- [ ] Publish final paths/APIs and map every old verification suite to its renamed DUT.
  Hand that baseline to VO0 in `verification.md`.

Exit: architecture accepted, current evidence located, and no test obligation silently
removed. This gate authorizes the verification restructuring; it does not complete it.

## Preservation and evidence rules

An OCaml rename does not require renaming emitted tops, CLI modes, or package ports.
Initially preserve those compatibility surfaces. Any proposed change to them requires an
explicit consumer map and a separately reviewed transition; names in historical commands
stay as recorded. New verification alias names belong to VO6, not an incidental AM rename.

For each stage, record touched source and test paths, commands, tools, result status, and
unresolved differences. Compare emitted outputs under identical options. Prefer byte
identity when names and construction order are preserved; otherwise classify port, name,
logic, and resource differences. For changed logic, record equivalence scope, state mapping,
preprocessing/reset assumptions, and unproven points. Refactor equivalence is not general
design correctness or proof of the Verilog emitter.

Retain the existing independent serial peer and all three configurations during AM work.
Do not update expectations to make a rename pass. Existing synthesis-delta review rules
still apply: report exact same-tool per-type counts and investigate differences; neither
name-only edits nor equivalent RTL guarantee equal mapping. Generic synthesis is not
physical timing or mapped signoff evidence.

Suggested existing entry points (run sequentially, after verifying current aliases):

```sh
./scripts/with-switch.sh dune build @install @lint -j 5
./scripts/with-switch.sh dune runtest -j 5
./scripts/with-switch.sh dune build @rtl -j 5
```

Use focused/forced runs where needed to demonstrate fresh execution and the existing
bundle checker for affected source roles. Record tool prerequisites rather than weakening
checks. No checks in this section have been run merely by creating this plan.

## Deferred decisions

- Further namespace changes beyond the implemented owner-local wrapped libraries.
- Renaming emitted package tops/ports, public CLI selectors, and historical artifact names.
- SRAM selection and vendor-model integration; new capture/payload storage and arbitration.
- Additional execution/dispatch decomposition without a reviewed responsibility contract.
- Shared external packaging of verification support; VO begins with project-local libraries.

## Implementation records

Add dated records naming the work item, source/diff, delivered changes, exact checks,
assumptions, deviations, and remaining work. Historical HL evidence is baseline context,
not a fresh result for this migration.

### 2026-09-26 — AM1/AM2 rename completion (unstaged, awaiting owner review)

Source: `08496b7` plus the owner's uncommitted AM1/AM2 edits; RTL baseline from `37c85e5`
(last revision before renamed modules were consumed; `host_link.ml` existed but was unused).
AM0 was not run as a separate item; only the generated-RTL baseline below was recorded.

Delivered:

- AM1: `Core_mechanisms` → `Primitive_dispatch` (`lib/emulator_core/primitive_dispatch.ml`).
  Remaining `Protocol_core`, `Control_execution`, `Integrated_core` consumers updated in
  `bin/`, `host/`, tests, and source comments.
- AM2: `lib/host_link/hardware_loader.ml` removed; `Host_link` (owner's rewrite) is the
  endpoint. In it, the forward-declared response wires take their widths from
  `Frame_tx.I.port_widths` (they were 1 bit), and `~rtlmangle:false` is restored on `I`/`O`.
  `Electrum_top` instantiates `Host_link` and documents its logical interfaces, tie-offs, and
  external memory boundary.
- Bundle source-input lists (`bin/asic_bundle.ml`) and `check-adopted-bundle.py` expected
  paths now name the new files.

Recorded compatibility surfaces, intentionally unchanged: emitted circuit names
(`protocol_core`, `integrated_core`, `loader_core`), `generate_core` selectors, Dune RTL
target file names, instance scopes (`"core"`, `"loader"`, `"access"`, `"execution"`,
`"mechanisms"`), and test suite file/directory/library names (`test/core/protocol_core/`,
`test/core/control_execution/`, `test/host_link/hardware_loader_*`), whose reorganization
belongs to VO. The root `loader_core.v` snapshot is untouched.

Checks (sequential, `-j 5`, via `scripts/with-switch.sh`): `dune build @install`,
`dune build @lint`, `dune build`, `dune runtest`, `dune build @rtl` all exit 0; the
independent serial peer reports PASS on `loader_core`, the wrapper simulation source, and
the production synthesis source.

Generated-output comparison against `37c85e5`, same options: `protocol_core`,
`executable_core`, `integrated_core`, and both `program_memory_backend` roles are
byte-identical. `loader_core` and both `loader_wrapper` sources differ: identical port list,
module list, and reg/always counts; internal names/order changed by `Host_link`'s
construction order (TX before dispatch through forward wires, reordered `busy_o` OR).
Same-tool `yosys synth` of baseline vs new `loader_core`: identical per-type cell counts
(13752 cells); only +3 public wires / +174 bits, the three forward-declared
`dispatch_response_*` wires (1 + 168 + 5). This is generic synthesis, not mapped or
physical evidence. A yosys `equiv_simple`/`equiv_induct` run did not finish within
15 minutes; formal equivalence of the loader is unproven.

Remaining: owner review of the loader RTL delta and AM1/AM2 acceptance; active docs outside
this record still use the old names (AM6).

### 2026-11-11 — Ownership amendment and package extraction delivered

Source baseline: clean `b3a4cb6a420613465f635a616bedba967c4ab307`, already containing
AM1/AM2 implementation and the later SP agent pilot. The separately captured new
baseline does not reconstruct the original pre-AM1/AM2 dirty tree or close its
historical formal-equivalence gap.

Delivered:26 byte-preserved hardware relocations with a flat public-library facade;
owner-local verification and agents; shared/root verification versus software tests;
`electrum_chip_project` package/project extraction; thin bundle CLI; single-source
emitted peers with compatibility target rules; source inventories, scripts and CI
path/budget alignment. No interface grouping, protocol API rename, ASIC dependency
upgrade or SRAM selection change occurred.

All475 registrations and eight frozen archive files are retained. All17 generated
RTL outputs and six bundle RTL roles are byte-identical; six same-tool bundle
synthesis statistics, pin metadata, resources and constraints match. Bundle source
identities change with the explicitly recorded path/formatting changes.

Verification ran sequentially through `flock ../.electrum-build.lock`, switch
`5.2.0+ox`, explicit `-j5`: install/lint, forced ordinary regression, emitted RTL
including all three loader-peer tiers, required/long/four-state aliases, CLI golden
checks, three-kind bundle checks and explicit observable/memory role simulations.
Independent review found no correctness blocker. Seven introduced formatting
issues were corrected and rechecked;23 baseline-only global-format failures and
two supplemental behavioral-RAM lint failures remain explicitly recorded.

Exact commands, path maps, output comparisons and receipts:
[ownership_layout.md#execution-record](ownership_layout.md#execution-record).
No index/history/configuration mutation, physical flow or sibling source edit.
Implementation is delivered; owner acceptance and remaining AM3/AM5/AM6, VO and
PT.3 decisions remain explicit separate work.

### 2026-11-11 — AM3 protocol/Codec separation delivered

Starting source: clean `0bb9abc`, after the ownership migration. Exact pre-edit
wire source, API map and hashes are retained under
`.dev/am3/20261111-0bb9abc-wire-baseline/`. The canonical library uses `core` only
and has no hardware, ISA, ASIC, simulator or agent dependency.

Delivered API:

| Responsibility | Canonical path |
| --- | --- |
| Version, command/result/capability/fault/phase values | `Host_link_protocol` root modules |
| Request/response/INFO/STATUS types, layouts and correlation | Root protocol modules |
| CRC parameters and integer bound | `Crc` and `U16.max` at the root |
| Software CRC and integer byte conversion | `Codec.Crc`, `Codec.U16` |
| Request encoding and encode errors | `Codec.Request` |
| Response decoding/correlation validation and decode errors | `Codec.Response` |

Thirteen byte-helper bodies and both error declarations retain their original
semantics and validation precedence. Low-level helpers retain their preconditions;
they are not replacements for complete frame validation. All active consumers use
the canonical API. The implementation-free old facade is used only by frozen HL4a
and the explicit compatibility test; external source users may also use it during
transition. No archived test/peer source was modified.

Tests: original26 fixed-vector/negative tests preserved, five canonical boundary
tests and one compatibility test added (32 pure tests;481 total registrations).
A hash-verified original implementation in a temporary verification fixture passed
2,242,474 differential comparisons;30 compile-negative probes verify software
operations/errors are absent from canonical definitions. Installed canonical-only
and canonical/shim consumers compile with shared type identity.

Integrated verification: `@install @lint`, forced ordinary `runtest`, and forced
`@rtl` pass, including all three independent loader-peer tiers. All17 generated
RTL files, six bundle roles and six same-tool synthesis statistics match baseline.
Pins, constraints/configuration and resource selections are unchanged. The loader
inventory has47 current source inputs, including the five canonical library files
and no shim sources. New bundle identities reflect reviewed source changes.

Every Dune invocation used switch `5.2.0+ox`, sequential `-j5` and
`/home/wayne/devel/jane/.electrum-build.lock`. An earlier caller timeout during RTL
checking is retained; the completed forced run took507.642 seconds. Scoped format
checks pass; the same23 baseline global-format failures remain, with no new failures.
No physical P&R, dependency upgrade, Git index/history/configuration mutation or
expectation promotion occurred. All2,492 fingerprinted installed dependency files
remained unchanged during final verification.

Evidence:
- `.dev/am3/20261111-0bb9abc-wire-baseline/{handoff,verification-handoff}.txt`
- `.dev/am3/consumer-handoff.txt` and reproducible `consumer-audit.py`
- `.dev/am3/integrated-final-20261111/receipt.txt` and command/output inventories
- `.dev/am3/independent-review/20261111-am3/RECEIPT.md` — no blockers found

Next implementation: AM5's separately specified interface maps and responsibility
review. AM6/VO owner acceptance and PT.3 API/dependency/SRAM adoption remain open.
