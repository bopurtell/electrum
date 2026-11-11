# Serial-host agent pilot

Status: started 2026-10-18. SP1–SP6 are complete, pending owner review: every HL4a and
SP2 test runs as the endpoint suite, and the originals are frozen in the archive; since
SP6 the scoreboard also expects abandoned reads, and T3, T8, and C10 run under it. This is
an early trial of the
[verification.md](verification.md#next-state) agent architecture on the Host_link serial interface, run ahead of the AM6 gate. It is
not the VO1 handoff. What it establishes feeds back into `verification.md` and VO1 once
AM work is accepted.

Authority: [verification.md](verification.md) owns verification policy and evidence
rules; [p3.5-hardware-loader.md](p3.5-hardware-loader.md) owns serial protocol and timing;
[`control_port.ml`](../lib/emulator_core/control_port.ml) owns the core-control temporal
contract; [host_link_hl4a_record.md](host_link_hl4a_record.md) records the exact-cycle
baseline the pilot must reproduce. Where this document's layout differs from the
"Proposed paths" in `verification.md`, this document reflects the owner's later decision.

## Execution rules

- Do not run any git command that writes history or the index (`add`, `commit`, `push`,
  `stash`, `reset`, `checkout` of files, …). The owner commits. Read-only git is fine.
- Every `dune build`/`dune runtest`/`dune exec` call uses `-j 5` and runs sequentially,
  as required by [verification.md](verification.md#agent-execution-constraints). Never run
  two Dune invocations at once.
- Follow [formatting_guide.md](formatting_guide.md) and
  [comment_guidelines.md](comment_guidelines.md); source files carry the standard
  three-line header. Code is formatted with the repository `.ocamlformat`
  (`profile = janestreet`).
- The endpoint suite (`test/host_link/endpoint/`) stays active and passing throughout,
  and the frozen HL4a archive (`test/host_link/archived/hl4a/`) keeps building and running
  unchanged. A refactoring step must leave the expect output of both byte-identical; never
  promote a changed expectation to make a move pass.
- Do not change hardware (`lib/`) behavior.

## Decisions

1. **Support lives with the interface owner.** Agents, items, drivers, monitors, and
   responders sit inside the test directory of the submodule that owns the interface, not
   in a central `test/support/` tree. Only interface-agnostic facilities (observation
   validity, replay, clocks, reporting) go in `test/common/`.
2. **One wrapped Dune library per agent**, the analogue of a UVM agent package. It has no
   `inline_tests`, so other suites (endpoint, system, package fixtures) can depend on it
   without linking another suite's tests. Its tests live in the owning suite's library.
   Users alias it the way they alias the codec:
   `module Serial_host = Protemu_serial_host_agent`.
3. **Items are per agent, not per directory.** Each agent has its own `Item` module for
   the transactions crossing its boundary. Product protocol types (`Wire.Request.t`,
   `Wire.Response.t`) stay in `host_link_wire/` and are referenced, never redefined or
   re-exported.
4. **Type ownership:**

   | Type (from `hardware_loader_testbench.ml`) | Owner |
   | --- | --- |
   | `Outcome`, `Pause`, `Read`, `Exchange`, `Raw`, MSB-first bit/byte conversion, `hex`, `encode` | Serial agent `Item` |
   | `Timing` (P3.5 envelope, `validate`), wait budgets | Serial agent `Config` |
   | Decoded `Request`, `Status`, `Core_stub.Offer`/`Response`, `Completion` | Control_port agent `Item` (SP3) |
   | `Phase`, `Event`, transcript, `cycle` scheduler | Environment / endpoint fixture (SP4) |
   | `Latency` | Checker / predictor (expected values, not items) |
   | `response`, `info_payload`, other expected responses | Scenario/checker side; stays in the suite |

5. **UVM roles kept, framework not.** Driver, monitor, agent (active/passive), and
   responder keep their UVM responsibilities. Sequences are lists or Quickcheck generators
   of items; there is no sequencer object, factory, or configuration database. One
   scheduler owns time; agents participate through its phases.
6. **Serial host is a master.** Clocking a response out of LDO is the driver's job, so
   the driver both sends request frames and collects response frames. A separate passive
   monitor (SP2) reconstructs both directions from LSEL_N, LCLK, LDI, LDO, and LRDY and
   never trusts what the driver intended.
7. **Control_port responder is a reactive (slave) driver.** It decides combinationally in
   the offer cycle, so it is a hook inside the scheduler's cycle phases, not a self-timed
   process. Recording offers and responses moves to a Control_port monitor (SP3).

## Layout

After SP5:

```text
test/host_link/                directories only
  serial_host/                 library protemu_serial_host_agent (SP1–SP2)
    dune
    item.ml                    serial transactions and pure helpers
    config.ml                  timing envelope, budgets
    driver.ml                  SP2
    monitor.ml                 SP2 (passive)
    agent.ml                   SP2
  endpoint/                    SP4–SP5; the authoritative Host_link-level suite
    dune                       library protemu_host_link_endpoint (no inline_tests) and
                               test library protemu_host_link_endpoint_tests
    latency.ml                 checker's latency predictions (moved from the testbench)
    fixture.ml                 scheduler, agents, adapters, transcript, Harness_failure, run
    scoreboard.ml              opt-in end-of-scenario check over both monitors
    endpoint_scenario.ml       HL4a and SP2 scenario/check helpers, against the fixture
    endpoint_transaction_tests.ml    10 HL4a transaction tests (includes the SP4 pilot)
    endpoint_framing_tests.ml        7 HL4a framing tests
    endpoint_cancellation_tests.ml   10 HL4a cancellation tests
    endpoint_diagnostics_tests.ml    5 HL4a diagnostics (includes the SP4 pilot)
    endpoint_serial_monitor_tests.ml 8 SP2 monitor/driver scoreboard tests
    endpoint_lifecycle_tests.ml      fresh-state isolation of two scoped runs
  archived/
    .ocamlformat-ignore        frozen code is never reformatted
    hl4a/                      library protemu_host_link_tests, frozen (SP5a); 40 tests
      dune                     header comment says it is the frozen archive
      hardware_loader_testbench.ml HL4a compatibility shim over the fixture, plus HL4a helpers
      hardware_loader_*_tests.ml   the original HL4a suite (32 tests)
      serial_host_monitor_tests.ml the original SP2 monitor/driver scoreboard (8 tests)
  command_dispatch/
    command_dispatch_testbench.ml  consumes the Control_port agent through a Core_stub shim
  serial_phy/ frame_rx/ frame_tx/  block suites, unchanged
test/core/control_port/        library protemu_control_port_agent (SP3)
  dune
  item.ml                      decoded Request, Offer, Response, Completion, Status
  config.ml                    Mode (Responder | Passive), Injection policy
  responder.ml                 reactive core stand-in (decision and edge work)
  monitor.ml                   passive; Offer and Response items from the port records
  agent.ml
```

## Sequence

### SP1 — Serial-host library with `Item` and `Config`

- [x] Create `test/host_link/serial_host/` with a wrapped library `protemu_serial_host`
  (no `inline_tests`) containing `Item` and `Config`. It depends only on what these
  modules need (expected: `core`, `protemu_host_link_wire`); no Hardcaml dependency yet.
- [x] **Move** (do not copy) the types and pure helpers listed for `Item` and `Config` in
  the ownership table out of `hardware_loader_testbench.ml`, keeping their definitions,
  comments, and behavior. The testbench refers to them through module aliases so the four
  test files compile without edits.
- [x] Leave in the testbench everything that touches the simulator or the stub
  (driving/reading functions, `cycle`, `Core_stub`, `Request`, `Status`, `Latency`,
  `Phase`, `Event`, checks). SP2 moves the driving functions.
- [x] Wire-level wait budgets used as defaults (e.g. `wait_ready`'s 20 000) become named
  values in `Config`, with the same values.
- [x] Verify: the library builds, the HL4a suite and focused host-link suites pass with no
  expect diff, lint is clean, and new/edited files are formatted (`@fmt` still fails on two
  untouched, pre-existing files: `hardware_loader_framing_tests.ml`, `frame_rx_validation_tests.ml`).

Exit: one implementation of each moved type, consumed by the existing suite; unchanged
test output.

### SP2 — Serial driver, passive monitor, and agent

Goal: the serial host's pin activity comes from a reusable driver, and an independent
passive monitor reconstructs what crossed the pins. The HL4a suite behaves and prints
exactly as before.

Design constraints:

- **No simulator handle in the library.** `Driver` and `Monitor` work on logical serial
  pins (`LSEL_N`, `LCLK`, `LDI` driven by the host; `LDO`, `LRDY` driven by the DUT) as
  plain booleans. The suite supplies a small adapter that maps them to the DUT's ports
  and to its scheduler. AM5 interface grouping should then change only that adapter.
  The library keeps no Hardcaml dependency unless a concrete need is recorded.
- **The scheduler still owns time.** The driver advances time only through a `step`
  supplied by the environment (today the testbench's `cycle`), never by stepping a
  simulator itself. The monitor is called by the scheduler once per cycle with that
  cycle's pre-edge pin values; it never advances time.
- **Reporting goes through hooks.** The driver reports failures and transcript events
  through callbacks the environment provides, so the testbench keeps its `Phase`,
  `Event`, transcript, and `Harness_failure` format. Failure messages and transcripts
  must be byte-identical to today's.
- **What moves to `Driver`:** the host pin-driving and response-reading functions
  (`select`, `deselect`, `send_bit`, `send`, `send_rest_of_byte`, `begin_frame`,
  `end_frame`, `send_frame`, `wait_ready`, `read_bit`, `read_response`,
  `abandon_response`, `finish_response`, `read_prefix`) and the driver's per-agent timing
  state (`Config.Timing`). `commit_if_valid` is a pure read policy and moves to `Item`.
  Composite scenario/check helpers (`receive`, `exchange`, `transact`, `disturb`,
  `expect_*`) stay in the suite: they combine driving with `Latency` expectations and
  stub checks. The testbench keeps thin wrappers or aliases so the four test files
  compile without edits.
- **LRDY history.** `wait_ready` today finds the first LRDY rise in the scheduler's
  recorded changes, which can lie before the call. Preserve those semantics; the
  environment's sampled history is supplied through the adapter. The driver must not
  read the monitor.
- **Driver-side protocol check.** `send_bit`'s "LDO stays low while a request is clocked
  in" check stays in the driver for SP2 so failure timing is unchanged. Moving protocol
  assertions to the monitor is a later decision.
- **Monitor is passive and independent.** It reconstructs, per selection (LSEL_N low to
  high): the cycles selected/deselected, the bits sampled on LDI and on LDO at each LCLK
  rise (pre-edge, matching the host's sample phase), whether LRDY was high at selection,
  and how the selection ended (final LCLK fall before deselect = commit; deselect with
  LCLK high = replay; fewer bits than the frame declared = abandoned). From that it
  emits typed observed items in `Item`: request frames as raw bytes plus trailing extra
  bits (there is no `Wire.Request.decode`; do not add one to the product codec), and
  response reads as bytes plus `Wire.Response.decode` result and ending. It must not use
  driver state, the testbench's `Read`/`Exchange` results, or the core stub. Observed
  items go to a queue (the analysis-port analogue) the environment or checker reads.
- **The monitor must not alter existing output.** Attached to the HL4a testbench, it may
  not add transcript events or change any existing expect output.
- **Agent.** `Agent` assembles `Config` (with an `Active | Passive` mode), an optional
  `Driver`, and the `Monitor`. Passive mode has no driver. Keep it thin; no sequencer.

Tasks:

- [x] Define the pin adapter and environment hooks; implement `Driver` by moving the
  listed functions; reduce the testbench to the adapter, hooks, and aliases/wrappers.
- [x] Implement `Monitor` and its observed items; attach it to the testbench's `cycle`.
- [x] Implement `Agent`; the testbench constructs an active agent.
- [x] Add a focused suite file in `test/host_link/` that cross-checks monitor items
  against driver results for: a legal transaction (INFO), a READ/VERIFY exchange, a
  malformed request (`Raw`), a replayed response, an abandoned read (`read_prefix`), and
  a request with extra trailing bits. Each check is a scoreboard comparison, plus one
  concise expect trace of the monitor's items for a single transaction.
- [x] Failure sensitivity: show the monitor reports a mismatch when the observed pins
  disagree with the driver's intent (e.g. a deliberately corrupted pin value injected
  through the adapter in a test-only path), using the suite's existing negative-check
  idiom (`failure_of`).
- [x] Verify: HL4a and focused host-link suites pass with no expect diff; new tests pass;
  lint clean; new/edited files formatted; full `dune build -j 5` passes.

Exit: reusable driver, passive monitor, and agent used by the existing suite, with
unchanged HL4a output and a monitor shown to detect a disagreement.

### SP3 — Control_port agent

Goal: one Control_port agent library, owned by the interface owner (`Emulator_core`),
replaces the two hand-written core stubs in `hardware_loader_testbench.ml` and
`command_dispatch_testbench.ml`. Recording what crossed the port moves from the stub to
a passive monitor. Both suites behave and print exactly as before.

Current state (inventory, 2026-10-18):

- Both testbenches define the same decoded `Request` (HL4a decodes `Bits.t` ports,
  dispatch decodes `int` ports), the same `Completion`/`Offer`/`Response`, and nearly
  the same `Status` (dispatch adds `sexp_of_t`/`equal`; its `summary` returns a string,
  HL4a's a list).
- The stubs differ:

  | Aspect | HL4a `Core_stub` | Dispatch `Core_stub` |
  | --- | --- | --- |
  | `memory` | `int array`, written by tests (`memory.(7) <- …`) | `int -> int`, read by tests (`memory 0x33`); same default formula |
  | Injected READBACK pulse | stored as `pending_response`, so it is outstanding and can refuse a READBACK | separate `injected` list, never outstanding |
  | Delivered pulses | recorded in `responses` | not recorded |
  | Extra robustness probes | none | `read_match` (READ match high), `rejected` (force every rejected signal) |
  | Pending-response expiry | cleared at the delivery edge | filtered by `cycle > edge` |

- `test/integration/core_engine/core_engine_control_port_tests.ml` drives the real
  `Emulator_core` through Control_port (the master side). It is out of SP3's scope; a
  master-mode driver is a follow-up.

Design constraints:

- **Location and library.** `test/core/control_port/`, a wrapped library
  `protemu_control_port_agent` with no `inline_tests`, modules `item`, `config`,
  `responder`, `monitor`, `agent`. It may depend on `hardcaml_protemu` for the
  `Control_port` records and widths. It works on `int` port records; each suite converts
  `Bits.t` at its adapter.
- **`Item`:** decoded `Request` (with `of_port` over `int Control_port.Request.t`),
  `Offer`, `Response`, `Completion`, and the shared `Status` values (`halted_idle`,
  `running`, `cleaned`, list `summary`, `sexp_of_t`, `equal`). Suite-specific printing
  (dispatch's string summary) stays in that suite as a wrapper over the shared one.
- **`Responder` is a reactive driver.** It owns the policy (`status`, `accept`,
  `memory`, completion modes, the robustness probes) and implements the contract-faithful
  decision and post-edge behavior from `control_port.ml` items 3, 5, and 6. The
  READBACK latency it implements is the contract's (item 5), defined in the responder,
  not taken from a suite's `Latency`. It is called from the scheduler's cycle phases
  (decision before the second settle, edge work after the edge) and never advances time.
  It no longer records offers or delivered responses.
- **Preserve both stubs' behavior exactly**, including the injection difference. Make
  the difference an explicit, labelled policy choice (for example, whether an injected
  pulse counts as outstanding) rather than two implementations. `memory` becomes one
  representation (an `int array` sized by `Program_memory_controller.Config.program_depth`
  with the existing default contents).
- **`Monitor` is passive.** Called once per cycle, pre-edge, after the decision is
  applied, with that cycle's `int` request, decision, and status records. It emits
  `Offer` items (cycle, decoded request, accepted from the decision port) and `Response`
  items (READBACK response pulses from the decision port) to a queue. It never reads
  responder state. The suites' `offers`/`responses` accessors read the monitor. The
  "at most one request per cycle" and "offer does not depend on decision" checks stay in
  the suites' `cycle` so failure timing is unchanged.
- **`Agent`:** `Config.Mode` is `Responder | Passive`; passive has no responder. A
  `Master` mode is reserved for the core-side follow-up and not implemented here.
- **Suite shims.** Each testbench keeps `t.stub` and a `Core_stub` module name as a thin
  shim (aliases to `Item`/`Responder` types and functions) so test files keep their
  spelling. The four HL4a test files and `serial_host_monitor_tests.ml` stay unedited.
  The only permitted test-file edits are mechanical changes in
  `test/host_link/command_dispatch/*_tests.ml` from `t.stub.memory N` to
  `t.stub.memory.(N)`; no other test-file edits, and no expect changes anywhere.

Tasks:

- [x] Create the library with `Item`, `Config`, `Responder`, `Monitor`, `Agent`.
- [x] Adopt it in `hardware_loader_testbench.ml`: responder via the shim, monitor
  attached in `cycle`, `offers`/`responses` from the monitor.
- [x] Adopt it in `command_dispatch_testbench.ml` the same way; delete its duplicate
  `Request`, `Core_stub`, and shared `Status` values.
- [x] Non-vacuity: temporarily break the monitor (for example, take `accepted` from the
  wrong decision field) and confirm existing exact-offer tests fail; restore.
- [x] Verify: `dune runtest -j 5 test/host_link` passes with no expect diff in any suite
  (HL4a, serial-host monitor, dispatch, PHY, RX, TX); lint clean; new/edited files
  formatted; full `dune build -j 5` passes.

Exit: one Control_port responder and monitor serving both suites, duplicate stub code
removed, unchanged output, and a monitor shown to be load-bearing.

### SP4 — Endpoint fixture and pilot tests

Goal: a scoped endpoint fixture (real `Host_link`, active serial-host agent, Control_port
responder agent, one scheduler) that owns what `hardware_loader_testbench.ml` owns today,
with the HL4a testbench reduced to a compatibility shim over it, plus two pilot tests
written in the new style.

Design constraints:

- **Location.** `test/host_link/endpoint/`, one library with `inline_tests`
  (`protemu_host_link_endpoint_tests`) holding the fixture module and the pilot test
  files. Host_link owns the endpoint, so the fixture stays in its suite. If the HL4a
  library must depend on the fixture, split the fixture into its own non-test library in
  the same directory instead and record why.
- **One implementation.** The scheduler (`cycle`, `hold`), reset/enable control,
  `Phase`, `Event`, transcript, `fail`/`check`/`Harness_failure`, the serial and
  Control_port adapters and hooks, and both agents move from the HL4a testbench into the
  fixture. The HL4a testbench becomes a thin shim (aliases and wrappers) over the fixture,
  as `verification.md` allows for a `*_testbench.ml` entry point. No second copy of the
  scheduler. HL4a, serial-host monitor, and dispatch expect output stay byte-identical;
  their test files stay unedited.
- **Fresh state per test.** The fixture exposes a scoped entry point (for example
  `Endpoint.run ?timing ~scenario f`) that builds a fresh simulator, agents, monitors, and
  transcript, runs `f`, and finishes. `create` may remain for the shim.
- **No timing mirror.** The fixture keeps one source of timing (the driver's). The
  `t.timing` copy introduced in SP2 may remain only inside the HL4a shim, if HL4a tests
  still read it.
- **Scoreboard.** The fixture provides an opt-in end-of-scenario check that drains both
  monitors and compares them with independent expectations: serial monitor items against
  the driver's sent frames and read results; Control_port monitor offers against the
  scenario's expected offers and `Latency` predictions. It is not applied automatically to
  HL4a scenarios, because some HL4a probes are deliberately out of contract (see the SP2
  classification note).
- **Both agents, one owner.** The fixture owns the serial-host and Control_port agents;
  the `stub`/`core` duplication left by SP3 collapses to the fixture's agent, with
  `t.stub` kept only in the shim. Transcript `Offer`/`Readback_response` events may be
  sourced from the Control_port monitor only if every existing transcript stays
  byte-identical. The SP3 injection policies (`Outstanding` for HL4a, `Independent` for
  dispatch) stay as they are; converging them is an owner decision.
- **LDO-low check.** If no existing expect output depends on where `send_bit`'s
  "LDO stays low while a request is clocked in" failure is raised, move it to a
  monitor-side protocol assertion reported through the fixture. Otherwise keep it in the
  driver and record why.

Tasks:

- [x] Create the fixture by moving the environment out of the HL4a testbench; reduce the
  testbench to a shim; all existing suites unchanged.
- [x] Port one HL4a transaction test and one HL4a diagnostic negative into
  `test/host_link/endpoint/` using the fixture's scoped run, agents, and scoreboard
  directly (not the shim). Their expect blocks must match the originals' text exactly;
  record which originals were chosen. Keep the originals running.
- [x] Show fresh-state isolation: two scoped runs in one test do not share monitor items,
  transcript, offers, or responder policy.
- [x] Non-vacuity: break one scoreboard comparison (or the responder's contract latency)
  and confirm the pilot tests fail; restore.
- [x] Verify: `dune runtest -j 5 test/host_link --force` passes with no expect diff in any
  existing suite; pilot tests pass; lint clean; new/edited files formatted; full
  `dune build -j 5` passes.

Exit: the endpoint fixture is the single environment for Host_link-level tests, the HL4a
suite runs unchanged through its shim, and two pilot tests show the new authoring style
with identical observations.

### SP5 — Port HL4a to the endpoint; archive the originals

Goal: every HL4a scenario and the SP2 monitor scoreboard run as endpoint tests written
against `Fixture`, `Scoreboard`, and `Serial_host.Driver` directly. The originals are
preserved byte-for-byte, still building and running, under `test/host_link/archived/hl4a/`.

Owner decisions (2026-10-18):

- "Endpoint" is the Host_link fixture tier (real `Host_link`, serial-host agent, Control_port
  responder), not the top of the hierarchy; `test/host_link/` is. Block suites
  (`serial_phy/`, `frame_rx/`, `frame_tx/`, `command_dispatch/`) are out of scope and stay
  as they are.
- Old tests are kept for history until the structure settles. They move to
  `test/host_link/archived/hl4a/` and keep running as a frozen oracle. Dropping them from
  the build later is a separate owner decision.

Target layout:

```text
test/host_link/
  archived/
    .ocamlformat-ignore        frozen code is never reformatted
    hl4a/                      library protemu_host_link_tests, moved verbatim
      dune                     (only its header comment may change)
      hardware_loader_testbench.ml, hardware_loader_*_tests.ml, serial_host_monitor_tests.ml
  serial_host/                 unchanged
  endpoint/
    dune                       fixture library unchanged; test library gains the new modules
    latency.ml fixture.ml scoreboard.ml
    endpoint_scenario.ml       HL4a's scenario/check helpers, written against the fixture
    endpoint_transaction_tests.ml    all 10 HL4a transaction tests (includes the SP4 pilot)
    endpoint_framing_tests.ml        all 7 HL4a framing tests
    endpoint_cancellation_tests.ml   all 10 HL4a cancellation tests
    endpoint_diagnostics_tests.ml    all 5 HL4a diagnostics (includes the SP4 pilot)
    endpoint_serial_monitor_tests.ml all 8 SP2 monitor/scoreboard tests
    endpoint_lifecycle_tests.ml      unchanged
  serial_phy/ frame_rx/ frame_tx/ command_dispatch/   unchanged
```

After SP5, `test/host_link/` holds directories only.

Archive rules:

- Move with plain `mv`, never `git mv` (no index writes). Every moved `.ml` file is
  byte-identical to its source (`sha256sum` before and after). The dune file moves too,
  and only its header comment may change, to say the directory is a frozen archive. The
  library name stays `protemu_host_link_tests`.
- Add `test/host_link/archived/.ocamlformat-ignore` so `@fmt` skips frozen code. That also
  clears the pre-existing `hardware_loader_framing_tests.ml` `@fmt` failure. The
  `frame_rx_validation_tests.ml` failure is out of scope.
- Archived code is never edited. If an endpoint change would break the archive, stop and
  report. Do not patch the archive.
- `Harness_failure`'s registered atom (`test/host_link/hardware_loader_testbench.ml...`)
  stays as it is. Renaming it is an owner decision.

Port rules:

- Same test names, scenario strings, order within each file, and contract-faithful versus
  robustness labelling as the originals. Comments are carried over and reworded only
  where they name shim functions.
- The two SP4 pilots are the ports of their originals. Extend those files; do not
  duplicate them.
- HL4a's scenario and check helpers (`receive`, `exchange`, `transact`, `disturb`,
  `expect_offered_once`, `expect_no_offers`, `expect_offers`, `expect_int`,
  `expect_quiet`, `expect_response`, `response`, `info_payload`, `expect_info_works`,
  `accepted`, `set_status`) get one implementation in `endpoint_scenario.ml`, inside the
  test library, not the fixture library: they are the scenario/checker side. Helpers
  that drive transactions take an optional scoreboard and record the driver's side into
  it, as the pilot's local `transact` does. The pilot's local `transact` and
  `expect_response` move there. Test files must not open or name anything under
  `archived/`.
- Use `Scoreboard.run` for contract-faithful scenarios whose expectations can be written
  out. Use `Fixture.run` for labelled robustness or out-of-contract probes, and where the
  scoreboard cannot model the scenario (arming probes, early selections; see the SP2
  classification note). Record each test's choice and reason in a table.
- Every original check is kept, with the same expected values and cycles. An original
  check may be replaced by a scoreboard expectation only when the scoreboard checks the
  same fact, as the pilot did. List each replacement. Expected values are written out
  from the scenario and never computed from the loader.
- Expect blocks match the originals' text exactly and pass without promotion.
- Identical observations, per test (the SP4 method): the full transcript, the serial
  monitor's items, and the Control_port monitor's items from the original (run in
  `archived/hl4a/`) and from the port are identical, compared by script. All temporary
  edits are removed afterwards, from copies, and the removal is checked with `cmp`.
- Non-vacuity, at least one per ported file: break something the file's checks depend on
  (a scoreboard comparison, a helper, or a latency), confirm that file fails, then
  restore.
- Do not change `lib/`, `host_link_wire/`, the agent libraries, or the block suites. Change
  `fixture.ml` or `scoreboard.ml` only if a port cannot be written otherwise; keep the
  change minimal and record it. Every suite, including the archive, must stay unchanged.

Steps (one agent at a time, in order):

- [x] SP5a: archive move and `.ocamlformat-ignore`; `endpoint_scenario.ml`; port the
  transaction and diagnostics files. Verify.
- [x] SP5b: port framing, cancellation, and the serial monitor tests. Update the living
  references to these files in `verification.md` (test table, `test/host_link/` mentions)
  and the layout block in this file. Dated records in other docs are left as written.
  Verify.

Verify (each step): `dune runtest -j 5 test/host_link --force` passes with no expect diff
in any suite; the archived suite still runs its 40 tests; the new files' test counts match
the originals; `@test/host_link/lint` is clean; `@test/host_link/fmt` fails only on
`frame_rx_validation_tests.ml`; full `dune build -j 5` passes; the archive's SHA-256 sums
are unchanged.

Exit: the endpoint suite is the authoritative Host_link-level suite, with every HL4a
scenario ported and shown to be observation-identical, and the originals frozen and running
in `archived/hl4a/`.

### SP6 — `Scoreboard.abandoned`

Goal: the scoreboard can expect an abandoned response read, so T8 ("an abandoned partial
read replays from byte zero without re-offering") and C10 ("reset discards a partially
read response") run under `Scoreboard.run` (owner decision, 2026-10-18).

Design constraints:

- **Driver-side only.** `Scoreboard.abandoned` builds an `Observed.Response` with
  `ending = Abandoned` from what the scenario and driver know: the selection cycle the
  scenario records, the deselection cycle and bits that `Driver.read_prefix` returned (or,
  for a read cut short by reset, what the scenario drove), and the bit count. Whole bytes
  and `extra_bits` are split from the driver's packed bits exactly as the monitor
  represents them. The expected `decoded` field comes from `Wire.Response.decode` of the
  whole bytes, the same independent codec `read` relies on. Nothing is read from a
  monitor, the responder, or the loader. If the codec cannot supply the expected decode,
  write it out in the scenario, as the SP2 monitor tests did.
- **Additive.** `abandoned` is a new function. `request`, `read`, `offer`, `readback`,
  `check`, and `run` keep their behavior, and every existing endpoint test's
  observations and expect blocks stay as they are.
- **The ports move to `Scoreboard.run`.** T8 and C10 switch from `Fixture.run`, record
  every serial item and every offer and READBACK pulse the scenario implies, and keep all
  of their original checks. If C10's reset makes an item impossible to express from the
  driver's side, keep C10 on `Fixture.run` and record why.
- **Optional helper.** If `endpoint_scenario.ml` gains a `read_prefix ?board` wrapper,
  it records the expectation the way `transact ?board` does.
- `archived/`, `lib/`, `host_link_wire/`, the agent libraries, and the block suites do not
  change.

Tasks:

- [x] Add `Scoreboard.abandoned`, with a comment in the file's style. Update the
  scoreboard's header and the SP5 tables' T8/C10 rows in this file.
- [x] Move T8 and C10 to `Scoreboard.run`.
- [x] Move T3 to `Scoreboard.run` (owner scope addition, 2026-10-18). Its host side is
  in contract, so every frame, read, offer (refused ones with `accepted = false`), and
  READBACK pulse it implies is written out from the driver's side and `Latency`; every
  original check, the name, scenario strings, and robustness labels stay. A labelled
  robustness case that cannot be expressed runs in its own `Fixture.run` inside the test,
  as C7 does, with the reason recorded. Evidence: T3's dumps are identical to SP5's.
  Non-vacuity: a refused offer expected as accepted fails T3; restore it.
- [x] Evidence: T8's and C10's transcript and monitor-item dumps are unchanged from SP5
  (SP5a/SP5b method). Non-vacuity: an abandoned expectation one bit short, and one with
  the wrong deselection cycle, each fail T8 and C10; restore both.
- [x] Verify as in SP5.

Exit: no endpoint test stays on `Fixture.run` only because of an abandoned read.

## Implementation records

Agents append a dated entry per step: source/diff baseline, files moved or created, exact
commands and results, deviations from this plan, and follow-ups.

### 2026-10-18 — SP1

Baseline: `ca7c593688e110fdae2191d91e258dd91b0c7587` (`git rev-parse HEAD`). At the start
the working tree differed from it only in docs: `docs/README.md` and
`docs/verification.md` modified, and this file untracked. Those edits were left as found.
`dune runtest -j 5 test/host_link` passed before any change.

Created:

- `test/host_link/serial_host/dune`: wrapped library `protemu_serial_host`, modules
  `item config`, no `inline_tests`; `libraries core protemu_host_link_wire`, `ppx_jane`,
  `ppx_js_style` lint and the same warning flags as its siblings. No Hardcaml.
- `test/host_link/serial_host/item.ml`: `hex`, `bits_of_byte`, `bytes_of_bits`,
  `Outcome`, `Pause`, `Read`, `Exchange`, `encode`, `Raw`. Wire is referenced as
  `module Wire = Protemu_host_link_wire.Wire`; no Wire type is redefined.
- `test/host_link/serial_host/config.ml`: `Timing` (`t`, `minimum`, `envelope`,
  `validate`) and `ready_budget = 20_000`.

Changed:

- `test/host_link/hardware_loader_testbench.ml`: the moved definitions are deleted and
  replaced, after `module Sim`, by aliases (`module Serial_host = Protemu_serial_host`,
  `Timing`, `Outcome`, `Pause`, `Read`, `Exchange`, `Raw`, and `hex`, `bits_of_byte`,
  `bytes_of_bits`, `encode`). `wait_ready`'s default budget is now
  `Serial_host.Config.ready_budget`. The header sentence saying `Raw` is local to the
  suite was corrected. Everything that touches the simulator or stub stayed.
- `test/host_link/dune`: `protemu_serial_host` added to `libraries`.

Every moved block is byte-identical to its original text (checked with a script against
a copy of the pre-change file). New one-line comments were added above `hex`, the
MSB-first conversions, `Outcome`, `Read`, `Exchange`, `encode` and `ready_budget`,
which had none.
The four test files are unedited. No `.mli` files were added, since no test library uses
them.

Commands, run one at a time from the repository root through
`./scripts/with-switch.sh`:

| Command | Result |
| --- | --- |
| `dune build -j 5 @test/host_link/serial_host/all` | pass |
| `dune runtest -j 5 test/host_link` | pass, no expect diff (HL4a, serial_phy, frame_rx, frame_tx, command_dispatch) |
| `dune build -j 5 @test/host_link/lint` | pass |
| `dune build -j 5 @test/host_link/fmt` | fails only on two files this step did not touch (below); every created or edited file is clean |
| `dune build -j 5` | pass (7.7 s) |

Deviations: none from the plan. The `@fmt` check was not made to pass, because both
failures predate this step and are in files outside its scope:
`test/host_link/hardware_loader_framing_tests.ml` (header comment wrap; the step forbids
editing the test files) and `test/host_link/frame_rx/frame_rx_validation_tests.ml`
(comment wrap). `--auto-promote` was not used.

Follow-ups for SP2:

- Move the driving and reading functions (`send_bit`, `send`, `read_bit`,
  `read_response`, `finish_response`, `abandon_response`, `read_prefix`, frame helpers,
  `wait_ready`) into `Driver`. `commit_if_valid` is pure and could move with them or into
  `Item`.
- When the aliases are retired, the comment in `hardware_loader_framing_tests.ml` that
  names `[Hardware_loader_testbench.Raw]` should point to `Serial_host.Item.Raw`. That
  file's existing `@fmt` diff can be fixed in the same edit.
- `docs/host_link_hl4a_record.md` item 8 still states the 20 000 default without naming
  `Config.ready_budget`; it is still accurate.

### 2026-10-18 — SP2

Baseline: `ca7c593688e110fdae2191d91e258dd91b0c7587` (`git rev-parse HEAD`), with the
uncommitted SP1 tree as recorded above (`docs/README.md`, `docs/verification.md`,
`test/host_link/dune`, `test/host_link/hardware_loader_testbench.ml` modified;
`test/host_link/serial_host/` and this file untracked). Nothing was committed or staged.
`dune runtest -j 5 test/host_link --force` passed before any change (7.0 s). A copy of
`test/host_link/` was kept outside the tree for comparison.

Created:

- `test/host_link/serial_host/driver.ml`: `Pins`, `Event`, `Failure`, `Env`, the driver
  state `t` (pins, hooks, `mutable timing`) and the moved functions.
- `test/host_link/serial_host/monitor.ml`: `Sample`, the per-selection reconstruction
  and the `observed` queue.
- `test/host_link/serial_host/agent.ml`: `t`, `create`, `driver_exn`, `sample`,
  `observed`.
- `test/host_link/serial_host_monitor_tests.ml`: the scoreboard suite (8 tests).

Changed:

- `serial_host/item.ml`: `commit_if_valid` moved in from the testbench (text unchanged);
  new `Observed` items; header no longer says the driving functions are in the testbench.
- `serial_host/config.ml`: `Mode` (`Active | Passive`), `t = { mode; timing }`, `active`,
  `passive`; header updated.
- `serial_host/dune`: modules `item config driver monitor agent`; comment updated. Still
  `core` and `protemu_host_link_wire` only, no Hardcaml.
- `hardware_loader_testbench.ml`: the fourteen driver functions and `commit_if_valid` are
  replaced by one-line wrappers or aliases with the same names and argument order; it
  gains the port-side adapter `serial_pins`, the driver-side `serial_host_hooks`, the
  record fields `agent` and `ldi_fault`, the accessors `driver` and `observed`, and one
  call in `cycle` that passes the pins to the monitor after the pre-edge observation.
  `ready_changes` moved above `create` (unchanged) because the hooks use it. Header
  comment and contract items 1 and 2 updated.
- `test/host_link/dune`: `serial_host_monitor_tests` added to `modules`.

The four HL4a test files are unedited (SHA-256 identical to the baseline copy). Each
moved function keeps its comment; the only body changes are the mechanical substitutions
below.

API (library `Protemu_serial_host`, no `.mli`):

```ocaml
(* Driver: pin adapter and environment hooks *)
module Pins : sig
  type t =
    { set_select_n : bool -> unit; set_clock : bool -> unit; set_data : bool -> unit
    ; ldo : unit -> bool                                  (* pre-edge LDO, last cycle *)
    ; ready_changes : since:int -> (int * bool) list      (* environment's LRDY record *)
    }
end
module Event : sig
  type t = Select of bool | Sent of { bytes : string; extra_bits : int }
         | Response_read of { bytes : string; outcome : Item.Outcome.t }
end
module Failure : sig
  module Kind : sig type t = Host_sample | Ready_wait end
  type t = { kind : Kind.t; what : string; expected : Sexp.t; actual : Sexp.t }
end
module Env : sig
  type t = { step : unit -> unit; now : unit -> int; log : Event.t -> unit
           ; fail : 'a. Failure.t -> 'a }
end
type t
val create : ?timing:Config.Timing.t -> Pins.t -> Env.t -> t   (* validates timing *)
val timing : t -> Config.Timing.t
val set_timing : t -> Config.Timing.t -> unit
val select, deselect, send_bit, send, send_rest_of_byte, begin_frame, end_frame,
    send_frame, wait_ready, read_bit, abandon_response, finish_response,
    read_response, read_prefix   (* HL4a signatures with [t] = Driver.t *)

(* Monitor *)
module Sample : sig
  type t = { select_n : bool; clock : bool; ldi : bool; ldo : bool; ready : bool }
end
type t
val create : unit -> t
val sample : t -> cycle:int -> Sample.t -> unit
val observed : t -> Item.Observed.t Queue.t

(* Agent *)
type t = { config : Config.t; driver : Driver.t option; monitor : Monitor.t }
val create : ?host:Driver.Pins.t * Driver.Env.t -> Config.t -> t
  (* raises for Active without host, or Passive with one *)
val driver_exn : t -> Driver.t
val sample : t -> cycle:int -> Monitor.Sample.t -> unit
val observed : t -> Item.Observed.t Queue.t

(* Item additions *)
val commit_if_valid : (Wire.Response.t, _) Result.t -> Outcome.t
module Observed : sig
  module Ending : sig type t = Commit | Replay | Abandoned end
  module Request : sig
    type t = { selected : int; deselected : int; bytes : string; extra_bits : bool list }
  end
  module Response : sig
    type t = { selected : int; deselected : int; bytes : string; extra_bits : bool list
             ; decoded : (Wire.Response.t, Wire.Response.Decode_error.t) Result.t
             ; ending : Ending.t }
  end
  type t = Request of Request.t | Response of Response.t
end
```

Wiring. `create` builds the hooks from a `t Set_once.t` (the closures need `t`, and `t`
holds the agent), then `Serial_host.Agent.create ~host (Config.active ~timing ())`, which
validates the timing before the simulator is built, as before. The pin setters write
`t.select_n`/`t.clock`/`t.data`, which `cycle` applies as before; `ldo` and
`ready_changes` read `cycle`'s pre-edge record; `step` is `cycle t`; `now` is `t.cycle`.
`log` maps each driver event to the same-named `Event` constructor, applying `hex` to
the bytes; `fail` calls the testbench's `fail` with `Host_sample -> Phase.Host_sample`
and `Ready_wait -> Phase.Pre_edge`, keeping its default cycle (`t.cycle - 1`). In
`cycle`, after `t.ldo` is sampled and before the edge, `serial_pins i o` reads LSEL_N,
LCLK and LDI back from the input ports and LDO and LRDY from the pre-edge outputs and
passes them to `Agent.sample`. The monitor logs nothing. `ldi_fault` (default
`Fn.const false`) inverts the LDI applied to the port in the cycles it selects; it is the
test-only corruption path.

Substitutions in the moved bodies: `t.select_n/clock/data <- v` became
`t.pins.set_* v`; `cycle t` became `t.env.step ()`; `t.ldo` became `t.pins.ldo ()`;
`t.cycle` became `t.env.now ()`; `ready_changes ~since t` became
`t.pins.ready_changes ~since`; `log t (...)` became `t.env.log (...)`, with `hex` moved
to the testbench's mapping; the two `fail t ~phase ...` calls became `t.env.fail` with a
`Failure.Kind`. `hold` is a local loop over `step`.

Scoreboard suite (`serial_host_monitor_tests.ml`): expected items are built from the
driver's side only (the frame sent and `extra_bits`/`extra_byte`, `Exchange.t`,
`Read.t` with its correlated decode mapped back to the response it carries, and
`read_prefix`'s bytes and deselection cycle with a written-out `Truncated` decode) and
compared with `check` against the drained monitor queue. Cases: one WRITE_WORD trace
(expect block, bytes in hex); INFO, READ, VERIFY (match) and VERIFY (mismatch); two raw
malformed requests (bad magic, flipped CRC); WRITE_WORD plus three trailing bits; a
STATUS replayed once then committed; an INFO abandoned at 24 bits and at 64 bits (past
the header) then committed; passive/active agent construction; and the negative. The
negative sets `ldi_fault` for the eight cycles of request bit 20, so the pins carry tag
0x4a where the driver sent 0x42, and requires `failure_of` to return the scoreboard's
`Harness_failure`; its full report is in the expect block.

Commands, run one at a time from the repository root through `./scripts/with-switch.sh`:

| Command | Result |
| --- | --- |
| `dune runtest -j 5 test/host_link --force` (baseline) | pass |
| `dune build -j 5 @test/host_link/serial_host/all` | pass |
| `dune runtest -j 5 test/host_link` | pass; no diff to any existing expect output; new suite 8/8 |
| `dune build -j 5 @test/host_link/lint` | pass |
| `dune build -j 5 @test/host_link/fmt` | fails only on the two pre-existing files (`hardware_loader_framing_tests.ml`, `frame_rx/frame_rx_validation_tests.ml`); every created or edited file is clean |
| `dune build -j 5` | pass |

The new suite's two expect blocks were promoted with
`dune promote test/host_link/serial_host_monitor_tests.ml` after review. Formatting was
promoted only for the files this step created or edited (`dune promote` naming the
testbench, the new suite, `agent.ml`, `driver.ml`, `monitor.ml`); the diffs were comment
rewraps and line breaks. No HL4a expectation was promoted.

Non-vacuity: in `monitor.ml` the bit capture condition `pins.clock && not t.clock`
(LCLK rise) was changed to `(not pins.clock) && t.clock` (LCLK fall), the wrong
sampling phase. `dune runtest -j 5 test/host_link` then failed 5 of the new suite's 8
tests, every scoreboard case (wrong bytes, and `Truncated` decodes from the lost final
bit), and no HL4a test. The runner stops before writing expect corrections when a test
throws, so the trace block was not separately reported. The file was restored from a
copy and the suite passed again.

Deviations:

- `t.timing` stays in the testbench record as a mirror of the driver's timing, because
  the HL4a tests read `t.timing` and record fields cannot be computed. `set_timing`
  writes both, through `Driver.set_timing`, which validates.
- The adapter types live in `Driver` (`Pins`, `Env`) and `Monitor` (`Sample`) rather
  than a separate module, to keep the planned layout.
- The monitor classifies a selection as a response read when LRDY is high in its first
  selected cycle. The loader decides two cycles later on its synchronized view and also
  requires four deselected cycles, so the HL4a arming characterization and early-selection
  probes can be classified differently from how the loader treated them. Those items are
  not checked anywhere.
- Response items carry `extra_bits` as requests do, so a read stopped mid-byte is
  represented exactly; `read_prefix` itself still packs a partial byte as before.

Follow-ups:

- SP3/SP4: the endpoint fixture can own the `Set_once` construction and the scoreboard,
  and drop the `t.timing` mirror once tests read `Driver.timing`.
- The LDO-low check in `send_bit` could move to the monitor as a protocol assertion,
  with a decision on failure timing.
- Decide whether HL4a scenarios should drain or check the monitor queue; today it only
  accumulates.
- `docs/host_link_hl4a_record.md`'s harness table still places the driver in the
  testbench; it is a dated record and was not edited.
- The comment in `hardware_loader_framing_tests.ml` naming
  `[Hardware_loader_testbench.Raw]` is still pending, as recorded for SP1.

### 2026-10-18 — SP3

Baseline: `ca7c593688e110fdae2191d91e258dd91b0c7587` (`git rev-parse HEAD`), with the
uncommitted SP1/SP2 tree recorded above. Nothing was committed or staged. A copy of
`test/host_link/` and SHA-256 sums of the four HL4a test files and
`serial_host_monitor_tests.ml` were kept outside the tree.
`dune runtest -j 5 test/host_link --force` passed before any change (7.2 s).

Created (`test/core/control_port/`):

- `dune`: wrapped library `protemu_control_port_agent`, modules
  `item config responder monitor agent`, no `inline_tests`; `libraries core
  hardcaml_protemu`, `ppx_jane`, `ppx_js_style` lint, the siblings' warning flags.
- `item.ml`: `Request` (with `of_port` over `int Control_port.Request.t`), `Completion`,
  `Offer`, `Response`, `Status` (`t`, `sexp_of_t`, `equal`, `halted_idle`, `running`,
  `cleaned`, list `summary`), and `Observed`.
- `config.ml`: `Mode` (`Responder | Passive`; `Master` reserved in a comment only),
  `Injection` (`Outstanding | Independent`), `t = { mode; injection }`, `responder`,
  `passive`.
- `responder.ml`: the merged stub: decision, acceptance, post-edge work, and the
  contract latencies `readback_latency = 2` (item 5) and `abort_cleanup_latency = 0`
  (item 6). It records nothing.
- `monitor.ml`: `Sample`, the `observed` queue.
- `agent.ml`: `t`, `create`, `responder_exn`, `sample`, `observed`.

Changed:

- `test/host_link/hardware_loader_testbench.ml`: `Request`, `Status`, and `Core_stub`
  (≈280 lines) replaced by aliases and the shim below; new record field `core`, adapter
  `control_port_sample`, one monitor call in `cycle`; `offers`/`responses` read the
  monitor; header and contract item 2 updated.
- `test/host_link/command_dispatch/command_dispatch_testbench.ml`: duplicate `Request`,
  the shared `Status` values, and `Core_stub` deleted; same shim, field, adapter, and
  monitor call; `offers` reads the monitor; header and contract item 3 updated.
- `test/host_link/dune`, `test/host_link/command_dispatch/dune`: add
  `protemu_control_port_agent`.
- `test/host_link/command_dispatch/command_dispatch_{command,lifecycle,response,wait}_tests.ml`:
  the 13 occurrences of `t.stub.memory N` became `t.stub.memory.(N)`. Formatting then
  dropped the now-redundant parentheses on 10 of those same lines
  (`Word (t.stub.memory.(1))` → `Word t.stub.memory.(1)`). No other test-file change.

The four HL4a test files and `serial_host_monitor_tests.ml` are byte-identical
(`sha256sum -c` against the start copy). Nothing under `lib/` or `host_link_wire/`
changed.

API (library `Protemu_control_port_agent`, no `.mli`):

```ocaml
(* Item *)
module Request : sig
  type t = Load_start of { length : int } | Load_write of { address : int; data : int }
         | Load_complete | Read of { address : int }
         | Verify of { address : int; expected : int } | Run | Stop | Abort
  [@@deriving sexp_of, compare, equal]
  val of_port : int Control_port.Request.t -> t list   (* every valid, field order *)
end
module Completion : sig type t = Contract | Delayed of int | Never end
module Offer : sig type t = { cycle : int; request : Request.t; accepted : bool } end
module Response : sig type t = { cycle : int; data : int; matches : bool } end
module Status : sig
  type t = int Control_port.Status.t
  val sexp_of_t : t -> Sexp.t   val equal : t -> t -> bool
  val halted_idle : t   val running : t   val cleaned : t -> t
  val summary : t -> (string * int) list                (* nonzero fields *)
end
module Observed : sig
  type t = Offer of Offer.t | Response of Response.t
  val offer : t -> Offer.t option   val response : t -> Response.t option
end

(* Config *)
module Mode : sig type t = Responder | Passive end
module Injection : sig type t = Outstanding | Independent end
type t = { mode : Mode.t; injection : Injection.t }
val responder : injection:Injection.t -> t
val passive : t

(* Responder *)
type t =
  { mutable status : Status.t; mutable accept : Request.t -> bool
  ; memory : int array                       (* program_depth words, default pattern *)
  ; mutable readback_completion : Completion.t; mutable abort_completion : Completion.t
  ; mutable read_match : bool; mutable rejected : bool option     (* robustness only *)
  ; injection : Config.Injection.t
  ; mutable pending_response : Response.t option; mutable injected : Response.t list
  ; mutable pending_cleanup : int option }
val readback_latency : int                   (* 2, contract item 5 *)
val abort_cleanup_latency : int              (* 0, contract item 6 *)
val default_memory : unit -> int array
val create : injection:Config.Injection.t -> t
val response : t -> cycle:int -> Response.t option
val inject_readback_response : t -> cycle:int -> data:int -> matches:bool -> unit
val decide : t -> reset:bool -> enable:bool -> Request.t -> bool
val decision : t -> cycle:int -> offer:(Request.t * bool) option -> int Control_port.Decision.t
val edge : t -> cycle:int -> reset:bool -> enable:bool -> offer:(Request.t * bool) option -> unit

(* Monitor *)
module Sample : sig
  type t = { request : int Control_port.Request.t; decision : int Control_port.Decision.t
           ; status : int Control_port.Status.t }
end
type t
val create : unit -> t
val sample : t -> cycle:int -> Sample.t -> unit
val observed : t -> Item.Observed.t Queue.t

(* Agent *)
type t = { config : Config.t; responder : Responder.t option; monitor : Monitor.t }
val create : Config.t -> t
val responder_exn : t -> Responder.t       (* raises for a passive agent *)
val sample : t -> cycle:int -> Monitor.Sample.t -> unit
val observed : t -> Item.Observed.t Queue.t
```

`decide` lost its `~cycle` argument, which the stubs used only to record the offer.
The monitor emits, per cycle, an `Offer` for each valid request (accepted from that
request's `*_accepted` field) and then a `Response` when `readback_response_valid` is
high. `Sample.status` is carried but emits nothing yet.

Shim, identical in both testbenches apart from the comment:

```ocaml
module Control_port_agent = Protemu_control_port_agent
module Request = Control_port_agent.Item.Request
module Status = Control_port_agent.Item.Status      (* dispatch: include + string summary *)
module Core_stub = struct
  module Completion = Control_port_agent.Item.Completion
  module Offer = Control_port_agent.Item.Offer
  module Response = Control_port_agent.Item.Response
  type t = Control_port_agent.Responder.t
  let inject_readback_response = Control_port_agent.Responder.inject_readback_response
end
```

Dispatch's `Status` is `include Control_port_agent.Item.Status` with `summary` redefined
over the shared one as the `name=hex` comma string its transcript prints. Tests keep
`t.stub.status`, `.accept`, `.memory.(i)`, `.readback_completion`, `.abort_completion`,
`.read_match`, `.rejected` (fields of `Responder.t`, reached by type),
`Core_stub.Offer.t`, `Core_stub.Response.t`, `Completion` constructors, and
`Core_stub.inject_readback_response`.

Wiring. Each `create` builds `Agent.create (Config.responder ~injection)` (HL4a
`Outstanding`, dispatch `Independent`) and stores the agent as `core` and its responder
as `stub`. `cycle` calls `Responder.decision`, `decide`, `response`, and `edge` where it
called the stub's, unchanged in order. After the second settle and the
decision-independence check, an adapter (`control_port_sample`) reads the request from
the pre-edge outputs and the decision and status back from the input ports, as `int`s,
and passes them to `Agent.sample`. HL4a calls it next to the serial monitor's sample;
dispatch calls it right after the check, before its pre-edge sample and busy check, which
is where the stub used to record the offer. The "at most one request per cycle" and
"offer does not depend on decision" checks stay in both `cycle`s, unchanged. HL4a's
`Request.of_port` now gets the `Bits.t` request converted with `Bits.to_int_trunc`; the
independence check still compares the `Bits.t` records, so its report is unchanged.
`offers` and `responses` filter `Queue.to_list (Agent.observed t.core)`. Transcript
fields (`Event.Offer`, `Event.Readback_response`, dispatch's `Sample.accepted` and
`readback_response`) still come from the responder's values, as before.

Behavior preservation, per inventory row:

| Aspect | How it is preserved |
| --- | --- |
| `memory` | One `int array` of `program_depth` words with the old default formula. HL4a writes it as before; dispatch reads `memory.(N)`, which equals the old `memory N` for every address the tests use (all < 256). |
| Injected READBACK pulse | `Config.Injection`: `Outstanding` stores it as `pending_response` (HL4a: outstanding, replaces a pending response, cancelled by reset/disable/accepted ABORT or LOAD_START); `Independent` keeps a separate `injected` list (dispatch: never outstanding, not cancelled, pending response wins a shared cycle). `response` checks the pending response first, then the list, which is empty under `Outstanding`. |
| Delivered pulses | No longer recorded by the responder. The monitor records a `Response` whenever `readback_response_valid` is high on the port, which the responder drives exactly when the old stub recorded one (`response ~cycle` is `Some`). Dispatch gains these items but has no accessor reading them. |
| Robustness probes | `read_match` and `rejected` are responder fields with defaults `false` and `None`. HL4a never sets them, and its old READ match was `false`, so its decisions are unchanged. `rejected` only overrides `*_rejected`; the monitor reads `*_accepted`, so offers are unaffected. |
| Pending-response expiry | One rule: at each edge a response whose cycle is ≤ that edge's cycle is dropped (dispatch's filter). HL4a cleared a pending response only at the edge of its own cycle. The two agree for every response scheduled for the current or a later cycle: every contract or `Delayed n ≥ -1` READBACK, and any injection made for a cycle not yet run, which covers every test. They differ only for a response scheduled in a cycle that has already passed (an injection with a past cycle or `Delayed n < -1`). HL4a's stub would keep such a response outstanding for ever; the responder drops it at the next edge. |

Two more differences not reachable from the tests: the monitor reads the decision back
from the ports, so a word wider than `program_width` written into `memory` would be seen
truncated (the old stub recorded the untruncated `int`). Also, if the
decision-independence check fails, the failing cycle's offer is not recorded, whereas
the stub recorded it in `decide`. That check is the only one that can fail between
`decide` and the monitor call in either suite. Neither failure report includes offers:
both transcripts log that cycle's offer only after the check.

Commands, run one at a time from the repository root through `./scripts/with-switch.sh`:

| Command | Result |
| --- | --- |
| `dune runtest -j 5 test/host_link --force` (baseline) | pass (7.2 s) |
| `dune build -j 5 @test/core/control_port/all` | pass |
| `dune runtest -j 5 test/host_link --force` | pass; no expect diff in any suite (HL4a, serial-host monitor, dispatch, serial_phy, frame_rx, frame_tx) |
| `dune build -j 5 @test/host_link/lint @test/core/control_port/lint` | pass |
| `dune build -j 5 @test/host_link/fmt @test/core/control_port/fmt` | fails only on the two pre-existing files (`hardware_loader_framing_tests.ml`, `frame_rx/frame_rx_validation_tests.ml`) |
| `dune build -j 5` | pass |

Formatting was promoted with `dune promote` naming only files this step created or
edited (`responder.ml`, `config.ml`, both testbenches, and the three dispatch test files
with rewritten lines). The diffs were comment rewraps, line breaks, and the parenthesis
removal noted above. `_build/.promotion-staging` also held stale SP2 entries for
`serial_host/*.ml` and `serial_host_monitor_tests.ml`, and these were not promoted. No
expect output was promoted.

Non-vacuity, each with the monitor restored from a copy afterwards and the suite passing
again:

1. `monitor.ml`: ABORT's acceptance read from `stop_accepted` instead of
   `abort_accepted`. `dune runtest -j 5 test/host_link --force` failed 5 tests across
   both suites: dispatch `READ, VERIFY, and ABORT are offered once and wait; operands are
   exact` and `ABORT completes at the first wait cycle whose status shows cleanup`; HL4a
   `an early selection during an ABORT wait cannot consume or overwrite it`,
   `robustness: reset or disable during an ABORT wait cancels its response`, and
   `each shared command is offered once with its operands and completes on time`. Every
   failure was an exact-offer check (`expect_offers`/`expect_offered_once`).
2. `monitor.ml`: response pulses dropped (`if false && ...`). 3 HL4a tests failed:
   `reset or disable during a READ wait cancels its response` (the stray pulse),
   `each shared command is offered once ...` (READ_WORD response cycle), and
   `VERIFY reports a mismatch with the actual word; READ ignores the match flag`. The
   dispatch suite has no response accessor and passed, as expected.

Deviations:

- Pending-response expiry is unified rather than made a policy (see the table). An
  exact copy of HL4a's rule would only keep a past-cycle response outstanding for ever,
  so a second policy for it was not added.
- `Responder.decide` no longer takes `~cycle`.
- The monitor reads the decision and status back from the ports through each suite's
  adapter, not from the responder's `int` records. This is the SP2 `serial_pins`
  pattern.
- `Monitor.Sample` carries `status`, but the monitor emits no item for it.
- The dispatch suite got no `responses` accessor because no test needs one.
- The suites' dune header comments still say "test-only core stub"; that remains
  accurate and was left.

Follow-ups:

- SP4: the endpoint fixture can own both agents and drop the `stub`/`core` duplication
  in the testbench record. Transcript fields (`Event.Offer`, `Readback_response`,
  dispatch `Sample.accepted`) could then come from the monitor. Retire the `Core_stub`
  shims when tests move to `Control_port_agent` names; at the same time, point the
  `[Core_stub]` mention in `hardware_loader_transaction_tests.ml` at the responder.
- SP4: decide whether the injection policy should converge on one choice. Today it
  exists only to keep the two suites' recorded behavior.
- Master mode: `test/integration/core_engine/core_engine_control_port_tests.ml` drives
  the real `Emulator_core` through Control_port. A `Master` mode driver plus this same
  passive monitor would let that suite share `Item` and the monitor. That needs a
  `Config.Mode.Master` and a driver with a scheduler `step` hook, as in SP2.
- A protocol checker over `Observed` (one decision per valid, response latency, item 3
  rejection rule against the `*_rejected` fields) could use the monitor directly. The
  `rejected` probe would then need a labelled exemption.

### 2026-10-18 — SP4

Baseline: `ca7c593688e110fdae2191d91e258dd91b0c7587` (`git rev-parse HEAD`), with the
uncommitted SP1–SP3 tree recorded above. Nothing was committed or staged. A copy of
`test/host_link/`, `test/core/control_port/` and this file, and SHA-256 sums of the four
HL4a test files, `serial_host_monitor_tests.ml`, and every
`test/host_link/command_dispatch/*_tests.ml`, were kept outside the tree.
`dune runtest -j 5 test/host_link --force` passed before any change (7.6 s).

Created (`test/host_link/endpoint/`):

- `dune`: two libraries (below).
- `latency.ml`: `Latency`, moved from the testbench (definitions and comments unchanged;
  ocamlformat rewrapped three comments after the de-indentation).
- `fixture.ml`: the environment moved from the testbench: `Sim`, `Phase`, `Event`, the
  state record, `log`/`note`/`transcript`, `Report` and `Harness_failure`,
  `fail`/`check`/`failure_of`, the serial and Control_port adapters, `cycle`, `hold`,
  `set_reset`/`set_enable`, `ready_changes`, the serial driver's hooks, `create`, plus the
  new `run`, accessors, and the two LRDY lifecycle checks `expect_ready_cleared` and
  `expect_retained`.
- `scoreboard.ml`: the opt-in end-of-scenario scoreboard.
- `endpoint_transaction_tests.ml`, `endpoint_diagnostics_tests.ml`: the two pilots.
- `endpoint_lifecycle_tests.ml`: fresh-state isolation.

Changed:

- `test/host_link/hardware_loader_testbench.ml`: reduced to the shim below (730 → 322
  lines). Header rewritten.
- `test/host_link/dune`: `protemu_host_link_endpoint` added to `libraries`; header
  comment names the fixture.
- `test/host_link/serial_host/driver.ml`: header comment only, pointing at the LDO-low
  decision below.

Byte-identical to the start copy (`sha256sum -c`): the four HL4a test files,
`serial_host_monitor_tests.ml`, and all five `command_dispatch/*_tests.ml`. Every other
file under `test/core/control_port/` and `test/host_link/serial_host/` is identical to the
start copy (`diff -r`). Nothing under `lib/` or `host_link_wire/` changed. Each moved
definition other than `cycle`, `serial_host_hooks`, `create`, and the exception is
textually identical (whitespace-normalized comparison against the start copy).

Dune arrangement. The HL4a library (`protemu_host_link_tests`) must depend on the fixture,
because its testbench becomes a shim over it, so the fixture cannot live in a library with
`inline_tests`: depending on one would link this directory's tests into the HL4a runner.
`test/host_link/endpoint/dune` therefore holds two libraries with disjoint `modules`:

- `protemu_host_link_endpoint` (wrapped, no `inline_tests`): `latency fixture
  scoreboard`; `core hardcaml hardcaml_protemu protemu_host_link_wire
  protemu_serial_host protemu_control_port_agent`; `ppx_jane`.
- `protemu_host_link_endpoint_tests` (`wrapped false`, `inline_tests` with the
  `-source-tree-root .` workaround): the three test files; depends on the fixture library
  and the two agents, never on the HL4a library.

There is no cycle: HL4a → fixture → agents. This is the "split" the SP4 location
constraint allows; the single `protemu_host_link_endpoint_tests` library it names as the
default would have forced HL4a to link the pilots.

Fixture API (`Protemu_host_link_endpoint`, no `.mli`; users alias it as
`module Endpoint = Protemu_host_link_endpoint`):

```ocaml
(* Fixture *)
module Sim = Cyclesim.With_interface (Host_link.I) (Host_link.O)
module Phase : sig type t = Settle | Pre_edge | Host_sample | Post_run end
module Event : sig type t = Reset of bool | Enable of bool | Select of bool | Sent of ...
                 | Offer of ... | Readback_response of ... | Status of ... | Ready of bool
                 | Busy of bool | Response_read of ... | Note of string end   (* HL4a's *)
type t =
  { scenario : string; sim : Sim.t
  ; serial_host : Serial_host.Agent.t; control_port : Control_port_agent.Agent.t
  ; mutable cycle : int; mutable reset : bool; mutable enable : bool
  ; mutable select_n : bool; mutable clock : bool; mutable data : bool
  ; mutable ldi_fault : int -> bool; mutable ready : bool; mutable ldo : bool
  ; mutable busy : bool; mutable ready_changes : (int * bool) list
  ; mutable last_status : Status.t; transcript : (int * Event.t) Queue.t
  ; transcript_limit : int; mutable omitted : int; mutable finished : bool
  ; stub : Control_port_agent.Responder.t        (* HL4a shim only *)
  ; mutable timing : Timing.t }                  (* HL4a shim only *)
module Report : sig type t = { scenario; cycle; phase; what; expected; actual; transcript } end
exception Harness_failure of Report.t
val log : t -> ?cycle:int -> Event.t -> unit
val note : t -> string -> unit
val transcript : t -> Sexp.t
val fail : t -> ?cycle:int -> ?expected:Sexp.t -> ?actual:Sexp.t -> phase:Phase.t -> string -> 'a
val check : t -> ?cycle:int -> phase:Phase.t -> string -> ('a -> Sexp.t)
  -> ('a -> 'a -> bool) -> expected:'a -> 'a -> unit
val failure_of : (unit -> unit) -> Sexp.t option
val cycle : t -> unit                     (* raises once the scoped run has finished *)
val hold : t -> int -> unit
val set_reset : t -> bool -> unit
val set_enable : t -> bool -> unit
val ready_changes : ?since:int -> t -> (int * bool) list
val create : ?timing:Timing.t -> ?transcript_limit:int -> string -> t   (* for the shim *)
val run : ?timing:Timing.t -> ?transcript_limit:int -> scenario:string -> (t -> 'a) -> 'a
val driver : t -> Serial_host.Driver.t
val responder : t -> Control_port_agent.Responder.t
val timing : t -> Timing.t                (* the driver's; the one source *)
val set_timing : t -> Timing.t -> unit
val serial_observed : t -> Serial_host.Item.Observed.t Queue.t
val control_port_observed : t -> Control_port_agent.Item.Observed.t Queue.t
val offers : ?since:int -> t -> Offer.t list
val responses : ?since:int -> t -> Response.t list
val expect_ready_cleared : t -> deselected:int -> unit
val expect_retained : t -> deselected:int -> cycles:int -> unit

(* Scoreboard: expected items, from the driver's side and Latency *)
type t
val create : unit -> t
val request : t -> ?extra_bits:bool list -> selected:int -> deselected:int -> string -> unit
val read : t -> selected:int -> Read.t -> unit
val offer : t -> deselected:int -> Request.t -> accepted:bool -> int  (* predicted cycle *)
val readback : t -> offered:int -> data:int -> matches:bool -> unit
val check : t -> Fixture.t -> unit        (* drains both monitors; Post_run failures *)
val run : ?timing:Timing.t -> ?transcript_limit:int -> scenario:string
  -> (Fixture.t -> t -> 'a) -> 'a

(* Latency: offer_after_deselect, ready_after_offer, validation_error_ready,
   readback_after_offer, ready_after_completion, abort_clean_after_offer,
   ready_cleared_after_deselect, response_select_to_armed (unchanged) *)
```

`run` builds a fresh `create` instance and runs `f` under `Exn.protect`; when `f` returns
or raises it sets `finished`, after which `cycle` raises
`"the endpoint fixture is used after its scoped run"`. `Scoreboard.run` is `Fixture.run`
with a fresh scoreboard checked when `f` returns. `Scoreboard.check` compares, in order,
the drained serial items with the expected requests and reads (a correlation mismatch is
expected as the response it carries, since the monitor decodes uncorrelated), the
drained offers with the expected offers at `deselected + Latency.offer_after_deselect`,
and the drained READBACK responses with the expected pulses at
`offered + Latency.readback_after_offer`. It is never applied to HL4a scenarios.

Changes to moved code:

- `cycle`: reads the responder through `Agent.responder_exn` rather than `t.stub`; checks
  `finished`; samples the Control_port monitor right after the decision-independence
  check (SP3 sampled it next to the serial monitor) and logs `Event.Offer` and
  `Event.Readback_response` from the items the monitor emitted in that cycle, instead of
  from the responder's values. That is the order the transcript already used (offer and
  response before LRDY and busy). Every existing transcript is byte-identical, which the
  unchanged expect blocks and the comparison below confirm.
- `create`: fields renamed `agent` → `serial_host`, `core` → `control_port` (no test reads
  them); `finished = false`.
- `serial_host_hooks`: `hex` spelled `Serial_host.Item.hex`.
- `Harness_failure`: now `of Report.t`, with a hand-registered sexp converter (below).

Shim (`hardware_loader_testbench.ml`): aliases `Wire`, `Endpoint`, `Fixture`, `Sim`,
`Serial_host`, `Control_port_agent`, `Timing`, `Outcome`, `Pause`, `Read`, `Exchange`,
`Raw`, `hex`, `bits_of_byte`, `bytes_of_bits`, `encode`, `Latency = Endpoint.Latency`,
`Request`, `Status`, `Phase`, `Event`; the SP3 `Core_stub` module unchanged;
`type t = Fixture.t = { ... }` re-exporting the fields; one-line aliases `log`, `note`,
`transcript`, `fail`, `check`, `failure_of`, `cycle`, `hold`, `set_reset`, `set_enable`,
`ready_changes`, `create`, `driver`, `set_timing`, `observed` (= `serial_observed`),
`offers`, `responses`, `expect_ready_cleared`, `expect_retained`; the wrappers
`set_status` and `accepted`; and the SP2 driver wrappers unchanged. What stays as HL4a
code is the suite's scenario/check side: `expect_no_offers`, `expect_offers`,
`expect_int`, `expect_quiet`, `receive`, `exchange`, `transact`, `expect_offered_once`,
`disturb`, `expect_response`, `response`, `info_payload`, `expect_info_works`. No
scheduler, adapter, or reporting code remains in it.

Ported pilots, written against `Fixture`, `Scoreboard`, and `Serial_host.Driver`
directly (neither opens or names the shim):

1. Transaction: "VERIFY reports a mismatch with the actual word; READ ignores the match
   flag" (`hardware_loader_transaction_tests.ml`), same name and scenario string. A local
   `transact` is HL4a's `transact` sequence as driver calls (`send_frame`, `wait_ready`,
   `read_response ~decide:commit_if_valid`, the replay failure, `expect_ready_cleared`),
   so pin activity and cycles are the original's. It keeps the original's two response
   checks; the original's offer and READ match-flag checks become scoreboard
   expectations, and the scoreboard adds both serial frames and reads, the READ offer, and
   the VERIFY pulse. Both original and port are `%test_unit`s with no expect block.
   Evidence of identical observations: a temporary expect test in the HL4a library ran the
   original's body through the shim with `~transcript_limit:100_000`, and the pilot
   temporarily printed the same three things at its end; the full transcript, the serial
   monitor's items, and the Control_port monitor's items were identical, 48 lines each
   (scripted comparison of the two `.corrected` outputs). Both temporary edits were then
   removed (the pilot restored from a copy, the scratch module deleted, the dune file
   restored).
2. Diagnostic negative: "the retention check detects a response that the host committed"
   (`hardware_loader_diagnostics_tests.ml`), same name, scenario, and
   `~transcript_limit:12`, under `Scoreboard.run`, with the check under test being the one
   implementation, `Fixture.expect_retained`, which the shim aliases. The pilot's
   `[%expect]` block was written as the original's text and passes unpromoted; a script
   extracting both blocks found them equal (SHA-256
   `e6149312863d6c5ce22097f635b27a2abf7c97913c829e36cd83bc06966eb43b` for both). The
   scoreboard then checks the RUN frame, its committed read, and the one offer.

The originals keep running unchanged.

Exception name. `[@@deriving sexp_of]` names an exception after its defining file, so
moving `Harness_failure` would have printed
`test/host_link/endpoint/fixture.ml.Harness_failure` and changed the HL4a diagnostic and
SP2 negative expect blocks. The fixture instead registers the converter itself
(`Sexplib0.Sexp_conv.Exn_converter.add`), emitting the atom
`"test/host_link/hardware_loader_testbench.ml.Harness_failure"` followed by
`Report.sexp_of_t`'s fields, which is exactly the derived format of the original inline
record. Reports in the HL4a suite and both pilots therefore print under the old name.
Renaming it is an expect change for the owner.

Isolation (`endpoint_lifecycle_tests.ml`, one `%test_unit`): a first `Fixture.run` sets
every responder policy a test can set (`accept` refusing, `memory.(0)`, `status`,
`readback_completion`), sends a WRITE_WORD that is refused, waits for LRDY, and returns its
handle and a snapshot. A second run in the same test then requires its own snapshot to
equal a fresh endpoint written out by hand: cycle 8, transcript exactly
`((0 (Reset true)) (4 (Reset false)))`, no serial or Control_port items, no offers, `accept`
true, `Responder.default_memory ()`, `Status.halted_idle`, `Contract`. A second check
requires the first snapshot to differ from that in every field, so the comparison is not
vacuous. Finally `Fixture.cycle` on the escaped first handle must raise.

LDO-low check: kept in the driver. No existing expect output depends on where the failure
is raised (no test exercises it), but a monitor-side assertion is a different check. The
driver's check is keyed to its own intent (`send_bit`); the passive monitor only knows the
pins, and classifies a selection as a request when LRDY is low in its first selected
cycle. To test the move, `monitor.ml` temporarily raised when LDO was high at an LCLK
rise in a selection it classified as a request. `dune runtest -j 5 test/host_link --force`
then failed one existing test, "a response selection arms only after four deselected
cycles and with LRDY high" (`hardware_loader_transaction_tests.ml`): its READ probe
selects two cycles before LRDY rises (selected 612), which the loader arms, so the read
returns `0x5a` and LDO is high at the rise in cycle 624. Moving the check would have
failed an unedited test. The monitor was restored from its copy (`cmp` clean). A
monitor-side protocol assertion needs the loader's arming rule (synchronized view, four
deselected cycles) or a labelled exemption for arming probes; that is a follow-up.

Commands, run one at a time from the repository root through `./scripts/with-switch.sh`:

| Command | Result |
| --- | --- |
| `dune runtest -j 5 test/host_link --force` (baseline) | pass (7.6 s) |
| `dune build -j 5 @test/host_link/endpoint/all` | pass |
| `dune runtest -j 5 test/host_link --force` | pass (12.5 s); no expect diff in any existing suite (HL4a, serial-host monitor, dispatch, serial_phy, frame_rx, frame_tx); pilots 3/3 |
| `dune build -j 5 @test/host_link/lint` | pass (includes `endpoint/`) |
| `dune build -j 5 @test/host_link/fmt` | fails only on the two pre-existing files (`hardware_loader_framing_tests.ml`, `frame_rx/frame_rx_validation_tests.ml`) |
| `dune build -j 5` | pass |
| `sha256sum -c` over the protected test files | all OK |

The pilots ran as the inline runner's three tests (checked with the built runner's
`-verbose`). Formatting was applied with `ocamlformat --inplace` (the switch's binary and
the repository `.ocamlformat`) on the seven files this step created or edited, not with
`dune promote`, because `_build/.promotion-staging` held stale entries from earlier steps
and from this step's temporary runs; the diffs were comment rewraps and line breaks, and
`@fmt` then reported only the two pre-existing files. No expect output was promoted
anywhere; the only new expect block is the diagnostic pilot's, written as the original's
text.

Non-vacuity, each restored from a copy afterwards (`cmp` clean) and the suite passing
again:

1. Scoreboard: the serial comparison's actual side filtered to request items only.
   `dune runtest -j 5 test/host_link --force` failed the transaction pilot
   (`"the serial monitor saw the driver's frames and reads"`, both reads missing) and no
   other test. That run stops at the throwing `%test_unit`, so the diagnostic pilot was
   run alone with the built inline runner (`-only-test endpoint_diagnostics_tests.ml`):
   it raised the same scoreboard failure after its report (`expect.uncaught_exn` in the
   corrected file, which was deleted).
2. Responder contract latency: `Responder.readback_latency` changed from 2 to 3. The
   transaction pilot failed at `"the Control_port monitor saw the predicted READBACK
   responses"`. Its HL4a original did not fail, since it checks only the READ pulse's
   match flag; the scoreboard's `Latency` prediction is what catches it. Also failing,
   as expected: HL4a `each shared command is offered once ...`, `an early selection during
   a READ wait ...`, `a response selection arms only after ...`, and eleven dispatch tests
   that depend on the responder.

Deviations:

- **The fixture record carries `stub` and `timing`.** SP4 asks for `t.stub` and the
  `t.timing` mirror only in the shim. The unedited HL4a tests read `t.stub`, `t.timing`,
  `t.cycle`, `t.ready`, `t.ldo`, `t.busy` and write `t.ldi_fault` on one value, and record
  fields cannot be computed, so the shim's `t` must be the fixture's record. The
  alternative, a shim record mirroring `cycle`, `ready`, `ldo`, `busy` and `ldi_fault`
  every cycle, would copy far more state. Both fields are labelled "HL4a shim only"; no
  fixture code reads them (`cycle` uses `responder`, and `timing` returns the driver's).
  They go when the HL4a tests are migrated (VO2).
- `Harness_failure`'s converter is hand-registered under the HL4a name (above).
- `Latency` moved into the fixture library, though SP4 does not list it: the pilots and
  the scoreboard need the same predictions, and the shim aliases them.
- `expect_ready_cleared` and `expect_retained` moved into the fixture as its LRDY
  lifecycle checks, so the diagnostic pilot exercises the same check as the HL4a
  original. The other composite helpers stay in the shim as HL4a scenario code.
- The Control_port monitor is sampled earlier in `cycle`, and the transcript's offer and
  READBACK events now come from it (allowed by SP4, with byte-identical transcripts).
- The fixture `create` keeps the HL4a defaults (`Outstanding` injection, transcript limit
  48); the SP3 injection policies are unchanged.

Follow-ups:

- VO1: this fixture, the two agents, and the scoreboard are the pilot's answer to "typed
  transactions, scheduling/adapters, driver/monitor ownership, agent assembly,
  observations, scoreboards, configuration, scoped lifetime"; VO1 should fix module
  signatures (`.mli`s), decide whether `Scoreboard` should also accept expectations
  derived from `Exchange.t`, and write the runnable "how to build a test" example. Effect
  handlers are not used, so no lifetime note is needed yet.
- VO2: migrate the HL4a tests onto `Fixture`/`Scoreboard` names and delete the shim,
  the `stub`/`timing` record fields, `Core_stub`, and the `t.stub`/`set_status`
  spellings; then rename `Harness_failure`'s printed name (an expect change) and fix the
  `[Hardware_loader_testbench.Raw]` and `[Core_stub]` comment references and the
  framing file's `@fmt` diff in the same edit. Decide which HL4a composites (`receive`,
  `transact`, `expect_quiet`, `expect_offered_once`) become shared endpoint sequences or
  checks; the transaction pilot's local `transact` duplicates HL4a's `receive` today.
  The SP2 monitor suite's local scoreboard could use `Scoreboard`.
- Decide whether the scoreboard should run on HL4a's contract-faithful scenarios once the
  serial monitor's classification can be reconciled with the loader's arming rule.
- LDO-low as a monitor-side protocol assertion: needs the loader's arming rule or a
  labelled exemption for the arming characterization (above).
- Converging the SP3 injection policies remains an owner decision.
- Master mode: `test/integration/core_engine/core_engine_control_port_tests.ml` still
  drives the real `Emulator_core` itself. A `Config.Mode.Master` driver with a scheduler
  `step` hook, plus the existing passive monitor, would let it share the agent; a system
  fixture (VO3) would then own that scheduler as this fixture owns the endpoint's.
- `docs/host_link_hl4a_record.md` still places the harness in the testbench; it is a
  dated record and was not edited.

### 2026-10-18 — SP5a

Baseline: `ca7c593688e110fdae2191d91e258dd91b0c7587` (`git rev-parse HEAD`), with the
uncommitted SP1–SP4 tree recorded above: `docs/README.md`, `docs/verification.md`,
`test/host_link/dune`, `test/host_link/hardware_loader_testbench.ml`, the dispatch
testbench, dune file, and four test files modified; this file, `test/core/control_port/`,
`test/host_link/endpoint/`, `test/host_link/serial_host/`, and
`test/host_link/serial_host_monitor_tests.ml` untracked. Nothing was committed or staged.
A copy of `test/host_link/` and this file, SHA-256 sums of the seven files to be moved,
and SHA-256 sums of every file under `lib/`, `host_link_wire/`, `serial_host/`,
`test/core/control_port/`, the four block suites, and `endpoint/` were kept outside the
tree. `dune runtest -j 5 test/host_link --force` passed before any change (8.0 s).

Moved, with plain `mv`, from `test/host_link/` to `test/host_link/archived/hl4a/`:
`dune`, `hardware_loader_testbench.ml`, `hardware_loader_transaction_tests.ml`,
`hardware_loader_framing_tests.ml`, `hardware_loader_cancellation_tests.ml`,
`hardware_loader_diagnostics_tests.ml`, `serial_host_monitor_tests.ml`. `sha256sum -c`
against the pre-move sums passes for all six `.ml` files, straight after the move and
again at the end of the step. The dune file differs only in its header comment, which now
says it is the frozen HL4a archive, that SP5 ports its tests to `endpoint/`, and that it
is never edited or reformatted; everything from `(library` on is byte-identical (`cmp`),
so the library is still `protemu_host_link_tests`. `test/host_link/` now holds
directories only.

Nothing in the archive was path-sensitive. The suite builds and passes its 40 tests
unchanged from the new directory (the built runner lists 40 names; the `%test_unit`s are now registered under
`test/host_link/archived/hl4a/`). The only printed path, `Harness_failure`'s atom
`test/host_link/hardware_loader_testbench.ml.Harness_failure`, is the fixture's
hand-registered constant (SP4), not derived from a file location, so the diagnostic and
SP2 negative expect blocks are unchanged. The `-source-tree-root .` workaround is
relative to the runner's directory and still works one level deeper.

Created:

- `test/host_link/archived/.ocamlformat-ignore`: a comment line and the pattern
  `hl4a/*.ml`. The installed ocamlformat (`3aa293b`, the switch's build) reads every
  `.ocamlformat-ignore` from the file's directory up to the project root; each line is a
  path relative to the ignore file's directory, matched as an anchored shell glob with
  `pathname` set, so `*` does not cross `/`. `ocamlformat --debug` reports
  `hl4a/hardware_loader_framing_tests.ml is ignored`, and Dune tracks the file: with it
  removed, `@test/host_link/fmt` reported `archived/hl4a/hardware_loader_framing_tests.ml`
  again; with it restored, only `frame_rx_validation_tests.ml`. The `.ocamlformat` profile
  is unchanged.
- `test/host_link/endpoint/endpoint_scenario.ml` (216 lines), in the test library
  `protemu_host_link_endpoint_tests`: HL4a's scenario and check helpers, one
  implementation, written against `Fixture`, `Scoreboard`, and `Serial_host.Driver`.

Changed:

- `test/host_link/endpoint/endpoint_transaction_tests.ml` (113 → 818 lines): all ten HL4a
  transaction tests, in the original order; the SP4 pilot is the fourth and now uses the
  shared `transact`/`expect_response`.
- `test/host_link/endpoint/endpoint_diagnostics_tests.ml` (79 → 160 lines): all five HL4a
  diagnostics; the SP4 pilot is the first.
- `test/host_link/endpoint/dune`: `endpoint_scenario` added to the test library's
  `modules`; header comment names the archive and the scenario module. The fixture
  library is unchanged.
- `test/host_link/archived/hl4a/dune`: header comment only (above).

`fixture.ml`, `scoreboard.ml`, `latency.ml`, and `endpoint_lifecycle_tests.ml` are
byte-identical to the start copy, as is everything under `lib/`, `host_link_wire/`,
`serial_host/`, `test/core/control_port/`, `serial_phy/`, `frame_rx/`, `frame_tx/`, and
`command_dispatch/` (`sha256sum -c`; the only mismatches are the three endpoint files
listed above).

`Endpoint_scenario` API (no `.mli`; test files `open! Endpoint_scenario`, as HL4a opened
its testbench):

```ocaml
val set_status : Fixture.t -> Status.t -> unit            (* the responder's status *)
val accepted : ?since:int -> Fixture.t -> Offer.t list
val expect_no_offers : Fixture.t -> since:int -> string -> unit
val expect_offers : Fixture.t -> since:int -> string -> Offer.t list -> unit
val expect_int : Fixture.t -> ?cycle:int -> string -> expected:int -> int -> unit
val expect_quiet : Fixture.t -> int -> string -> unit
val record_request : Scoreboard.t option -> selected:int -> deselected:int -> string -> unit
val receive : ?board:Scoreboard.t -> ?ready_budget:int -> ?pause:Pause.t -> Fixture.t
  -> started:int -> request_deselected:int -> expected:Wire.Correlation.t -> Exchange.t
val exchange : ?board:Scoreboard.t -> ?ready_budget:int -> ?pause:Pause.t -> Fixture.t
  -> string -> expected:Wire.Correlation.t -> Exchange.t
val transact : ?board:Scoreboard.t -> ?ready_budget:int -> ?pause:Pause.t -> Fixture.t
  -> tag:int -> Wire.Request.t -> Exchange.t
val expect_offered_once : Fixture.t -> Exchange.t -> Request.t -> accepted:bool -> unit
val disturb : ?board:Scoreboard.t -> Fixture.t -> string -> int   (* deselection cycle *)
val expect_response : Fixture.t -> string -> expected:Wire.Response.t -> Wire.Response.t -> unit
val response : tag:int -> Wire.Command.t -> ?payload:Wire.Response.Payload.t
  -> Wire.Result_code.t -> Wire.Response.t
val info_payload : Wire.Response.Payload.t
val expect_info_works : ?board:Scoreboard.t -> Fixture.t -> tag:int -> string -> unit
```

Each body is the HL4a shim's, with the shim's names replaced by the fixture's
(`check` → `Fixture.check`, `t.stub` → `Fixture.responder t`, `send_frame t` →
`Driver.send_frame (Fixture.driver t)`, and so on), so pin activity, cycles, check labels,
and failure reports are unchanged. Given a `board`, `exchange` records the frame it sent
(`Scoreboard.request` with the cycle LSEL_N fell and the deselection cycle), `receive`
records the `Read.t` the driver returned (`Scoreboard.read` with the cycle LSEL_N fell,
taken just before `Driver.read_response`), and `disturb` records its frame; `transact` and
`expect_info_works` pass the board through. Offers and READBACK pulses are never recorded
by a helper: each test writes them out with `Scoreboard.offer`/`Scoreboard.readback`. The
pilot's local `transact` and `expect_response` were deleted; the shared `transact`
returns HL4a's `Exchange.t` rather than the pilot's `(deselected, response)` pair.

Per-test choices. "Kept" means every original check is still made, with the same label,
expected value, and cycle; the scoreboard column lists what the scoreboard checks in
addition.

| Original → port (same name) | Run | Why | Original checks replaced by the scoreboard | Scoreboard expectations |
| --- | --- | --- | --- | --- |
| T1 INFO and STATUS report the fixed descriptor and the core's status | `Scoreboard` | contract-faithful | none (kept) | 6 frames and committed reads; no offers or pulses |
| T2 each shared command is offered once ... completes on time | `Scoreboard` | contract-faithful | none (kept) | 11 frames and reads, 11 accepted offers, READBACK pulses for READ (`0x0bad`, match low) and VERIFY (`0x5678`, match high); the case record gained a `readback` field for these |
| T3 a refused command reports the status-derived class ... | `Scoreboard` (SP6; `Fixture` in SP5a) | host traffic in contract throughout; the refused STOP and ABORT keep their robustness labels and are expressible as refused offers | none (kept) | 12 frames and committed reads, 12 refused offers (`accepted false`); no pulses |
| T4 VERIFY reports a mismatch ...; READ ignores the match flag (SP4 pilot) | `Scoreboard` | contract-faithful | as in SP4: `expect_offered_once` for VERIFY → `Scoreboard.offer`; "the READ response carried a low match flag" → `Scoreboard.readback ~matches:false` | 2 frames and reads, 2 offers, 2 pulses |
| T5 a selected request may pause ... between and within bits | `Scoreboard` | contract-faithful; the hand-built frame is recorded with `Scoreboard.request` | none (kept) | 1 frame, 1 read, 1 offer |
| T6 asymmetric and slower whole-cycle host timing ... | `Scoreboard` (one run per timing) | contract-faithful | none (kept) | per run: INFO and WRITE frames and reads, 1 offer |
| T7 a selected response may pause ... and resume | `Scoreboard` | contract-faithful | none (kept) | 2 frames, 2 paused reads; no offers |
| T8 an abandoned partial read replays from byte zero ... | `Scoreboard` (SP6; `Fixture` in SP5a) | contract-faithful; the 24-bit prefix is a `Scoreboard.abandoned` read, recorded by `Endpoint_scenario.read_prefix ~board` | none (kept) | 1 frame, 1 abandoned read (3 bytes), 1 committed read, 1 accepted `Run` offer; no pulses |
| T9 final-bit validation rejection retains the response; ... | `Scoreboard` | contract-faithful; both rejections are `Scoreboard.read`s with `Replay` endings | none (kept) | 1 frame, 3 reads (2 replay, 1 commit), 1 offer |
| T10 a response selection arms only after four deselected cycles ... | `Fixture` (four runs) | out-of-contract arming characterization and a robustness delayed READ; early selections (SP2 classification note) | n/a | n/a |
| D1 the retention check detects a response that the host committed (SP4 pilot) | `Scoreboard` | as in SP4; the check under test is `Fixture.expect_retained` | none | RUN frame, committed read, 1 offer |
| D2 the offer check detects a one-cycle change in offer timing | `Scoreboard` | contract-faithful scenario; the negative is `expect_offers` | none (kept) | 1 frame, 1 read, 1 offer at the observed cycle |
| D3 the quiet check detects a response that was not cancelled | `Scoreboard` | contract-faithful; the response is left unread | none (kept) | 1 frame; no read, offer, or pulse |
| D4 waits are bounded and time out with a report | `Fixture` | labelled robustness responder (`Never`) | n/a | n/a |
| D5 the harness refuses host timing outside the P3.5 envelope | `Fixture` | construction is under test; `Fixture.run` raises before a fixture exists | n/a | n/a |

Test names, scenario strings, order, and every string literal in each test body (check
labels, scenarios, hex constants) were compared by script between each original and its
port: all equal except the one SP4 replacement in T4. The only expect block (D1) has the
same SHA-256 in both files
(`e6149312863d6c5ce22097f635b27a2abf7c97913c829e36cd83bc06966eb43b`, as recorded for SP4)
and passes unpromoted. Comments were carried over verbatim except "stub" → "responder"
where they named the HL4a `Core_stub` (T2, T3, T4, D4, and both file headers) and
`[Core_stub]` → `[Control_port_agent.Responder]` (T4); each file header gained a paragraph
on the port and the `Scoreboard.run`/`Fixture.run` split.

Evidence of identical observations. Instead of per-test scratch printing, `fixture.ml`
itself was instrumented temporarily, so every fixture instance in both suites was
captured without touching the archive: `create` registered the instance and wrote its
scenario; `log` wrote every transcript event before the bounded queue; and `cycle` wrote
each item the serial and Control_port monitors emitted in that cycle, so the scoreboard's
draining could not hide any. Lines went to the file named by `SP5A_DUMP` (an `at_exit`
writer was tried first, but the inline runner exits without running it). The archived
runner (`-only-test hardware_loader_{transaction,diagnostics}_tests.ml`) and the endpoint
runner (`-only-test endpoint_{transaction,diagnostics}_tests.ml`) were built with Dune and
then run directly, one at a time. A script compared the dumps instance by instance:

| File | Fixture instances | Events | Serial items | Control_port items | Result |
| --- | --- | --- | --- | --- | --- |
| transaction (10 tests) | 15 | 563 | 99 | 39 | identical per instance; dump files byte-identical (SHA-256 `78d9b21c…`) |
| diagnostics (5 tests) | 4 | 41 | 6 | 3 | identical per instance; dump files byte-identical (SHA-256 `2e89edb4…`) |

D5 builds no instance in either suite: `Serial_host.Agent.create` rejects the timing
before the simulator exists, in the original's `create` and the port's `Fixture.run`
alike. `fixture.ml` was then restored from its copy and `cmp` against the start copy is
clean; no `SP5A`/`sp5a` text remains anywhere under `test/` or `lib/`. The dumps,
comparison script and output are in the session scratchpad, not the tree.

Non-vacuity, each made in a file under `endpoint/`, run with the built endpoint runner per
file, then restored from a copy (`cmp` clean):

1. `Endpoint_scenario.expect_offered_once` expected the offer one cycle late. The
   transaction file failed 6 of 10 (T2, T3, T5, T6, T8, T9, every user of the helper) at
   "the command is offered once, three cycles after its deselection"; diagnostics, which
   does not use it, passed.
2. `Endpoint_scenario.expect_quiet` skipped its LRDY/LDO check. The diagnostics file
   failed 1 of 5 (D3, "the negative check must fail: a retained response"); the
   transaction file's positive uses passed, as expected.
3. `Scoreboard.offer` predicted one cycle late. Transaction failed 5 of 10 (T2, T4, T5,
   T6, T9: every scoreboard test with an offer) and diagnostics 2 of 5 (D2, and D1 as an
   expect diff), all at "the Control_port monitor saw the predicted offers". The
   generated `.corrected` file in `_build` was deleted.

Commands, run one at a time from the repository root through `./scripts/with-switch.sh`
(the evidence and non-vacuity runs used the built inline runners directly, also one at a
time):

| Command | Result |
| --- | --- |
| `dune runtest -j 5 test/host_link --force` (baseline) | pass (8.0 s) |
| `dune runtest -j 5 test/host_link --force` (after the move, before the ports) | pass (12.0 s); archive 40/40 |
| `dune build -j 5 @test/host_link/fmt` (ignore file present / removed) | only `frame_rx_validation_tests.ml` / also `archived/hl4a/hardware_loader_framing_tests.ml` |
| `dune build -j 5 @test/host_link/endpoint/all` | pass |
| `dune runtest -j 5 test/host_link --force` (final) | pass (12.2 s); no expect diff in any suite (archive, serial_phy, frame_rx, frame_tx, command_dispatch, endpoint) |
| inline runners `-list-test-names` | archive 40; endpoint transaction 10, diagnostics 5, lifecycle 1 |
| `dune build -j 5 @test/host_link/lint` | pass |
| `dune build -j 5 @test/host_link/fmt` | fails only on `frame_rx/frame_rx_validation_tests.ml` (pre-existing, out of scope) |
| `dune build -j 5` | pass |
| `sha256sum -c` over the six archived `.ml` files | all OK |

The three created or rewritten `.ml` files were formatted with `ocamlformat --inplace`
(the switch's binary and the repository `.ocamlformat`), not `dune promote`, because
`_build/.promotion-staging` still holds stale entries from earlier steps; the diffs were
line breaks only. The staged copy of the archived framing file left by the fmt check
without the ignore file was deleted from `_build`; `dune promotion list` is empty. No
expect output was promoted anywhere and `--auto-promote` was not used.

Deviations:

- **Evidence by fixture instrumentation**, not SP4's per-test printing (above). It covers
  every instance, including the four runs of T10 and the three of T6, and keeps the
  archive untouched; the only temporary edit was to `fixture.ml`.
- **T3 runs under `Fixture.run`** although ten of its twelve cases are contract-faithful,
  because the port rules send labelled robustness probes to `Fixture.run`. Its host side
  is in contract and the scoreboard could express it (twelve refused offers, no pulses);
  moving it is the owner's call.
- **T8 runs under `Fixture.run`** because `Scoreboard` has no expectation for an
  abandoned read. Adding one would change `scoreboard.ml`, which this step did not need.
- **T2's case record gained `readback`**, the written-out data and match flag of the
  READ and VERIFY pulses, so the scoreboard's pulse expectations are not derived from the
  expected responses.
- **D5 uses `Fixture.run`** where the original called `create`; both raise from the same
  timing validation before a fixture is built.
- `disturb` takes `?board` for uniformity, though only the cancellation file (SP5b) uses
  it. `record_request` is exposed because there is no `.mli`.
- The fixture library and the archive's shim are unchanged, so the archived suite still
  links `Endpoint.Fixture` through its shim; the dune header comments say so.

Follow-ups for SP5b:

- Port framing (7), cancellation (10), and the serial monitor suite (8) onto
  `Endpoint_scenario`. The cancellation file uses `disturb`, reset/enable, and early
  selections (mostly `Fixture.run`); the monitor suite's abandoned reads and extra-bit
  frames suggest a `Scoreboard.abandoned` (and `?extra_bits` already exists on
  `Scoreboard.request`), which would also let T8 move to `Scoreboard.run`. Record any
  scoreboard change.
- Update the living references named in SP5b: `verification.md`'s test table and
  `test/host_link/` mentions, this file's Layout block, and the Execution rules bullet
  that still names `test/host_link/hardware_loader_*`. Also stale but outside SP5a's
  scope: the header of `endpoint/fixture.ml` (line 15) and `latency.ml` still describe
  the HL4a suite at `test/host_link/hardware_loader_testbench.ml` and "the endpoint
  pilots"; fixing them is a fixture-library comment edit.
- `git status` now shows the six tracked originals (`dune`, the testbench, and four test
  files) as deleted and `test/host_link/archived/` as untracked; committing them together
  lets Git record the renames. `serial_host_monitor_tests.ml` was never tracked.
- Owner decisions still open: renaming `Harness_failure`'s printed atom (an expect change
  in the archive and in `endpoint_diagnostics_tests.ml`), dropping the archive from the build, and
  whether T3 should move to `Scoreboard.run`.

### 2026-10-18 — SP5b

Baseline: `ca7c593688e110fdae2191d91e258dd91b0c7587` (`git rev-parse HEAD`), with the
uncommitted SP1–SP5a tree recorded above: `docs/README.md`, `docs/verification.md`, the
dispatch testbench, dune file, and four test files modified; `test/host_link/dune` and the
five tracked HL4a files shown as deleted (moved by SP5a); this file,
`test/core/control_port/`, and `test/host_link/{archived,endpoint,serial_host}/`
untracked. Nothing was committed or staged. A copy of `test/host_link/`, this file, and
`verification.md`, and SHA-256 sums of every file under `lib/`, `host_link_wire/`,
`test/host_link/`, `test/core/control_port/`, and `docs/` were kept in the session
scratchpad. The six archived `.ml` files matched SP5a's pre-move sums.
`dune runtest -j 5 test/host_link --force` passed before any change (8.1 s).

Created (`test/host_link/endpoint/`):

- `endpoint_framing_tests.ml` (416 lines): all seven HL4a framing tests, in the original
  order.
- `endpoint_cancellation_tests.ml` (568 lines): all ten HL4a cancellation tests.
- `endpoint_serial_monitor_tests.ml` (255 lines): all eight SP2 monitor/driver scoreboard
  tests.

Changed:

- `endpoint_scenario.ml` (216 → 330 lines): the additions below; header comment names
  them.
- `endpoint_diagnostics_tests.ml` (160 → 154 lines): its local `require_failure` was
  deleted, since the serial monitor suite needs the same function; it now uses
  `Endpoint_scenario.require_failure`, whose text is identical. Nothing else changed.
- `endpoint/dune`: the three modules added to the test library; header comment says the
  library is the whole ported suite. The fixture library is unchanged.
- `endpoint/fixture.ml` and `endpoint/latency.ml`: header comment only. `fixture.ml`
  names the endpoint suite and the archive's shim at
  `test/host_link/archived/hl4a/hardware_loader_testbench.ml` instead of the old path;
  `latency.ml` names the endpoint suite, `Scoreboard`, and the archived suite instead of
  "the HL4a suite, the endpoint pilots". `diff` against the start copy shows only those
  comment lines; ocamlformat leaves both files unchanged.
- `docs/verification.md` and this file (below).

Byte-identical to the start copy: `scoreboard.ml`, `endpoint_transaction_tests.ml`,
`endpoint_lifecycle_tests.ml` (`cmp`), everything under `archived/` (`diff -r`), and every
file under `lib/`, `host_link_wire/`, `serial_host/`, `test/core/control_port/`,
`serial_phy/`, `frame_rx/`, `frame_tx/`, and `command_dispatch/` (`sha256sum -c`; the only
mismatches are the files listed above). No `Scoreboard` or `Fixture` behaviour changed.

`Endpoint_scenario` additions (no `.mli`):

```ocaml
val require_failure : Fixture.t -> string -> (unit -> unit) -> Sexp.t  (* from diagnostics *)
val extra_bits_sent : ?extra_bits:int -> ?extra_byte:char -> unit -> bool list
val record_request                                      (* gains ?extra_bits ?extra_byte *)
  : ?extra_bits:int -> ?extra_byte:char -> Scoreboard.t option
  -> selected:int -> deselected:int -> string -> unit

(* Serial monitor expectations, from serial_host_monitor_tests.ml *)
val expect_observed : Fixture.t -> string -> Observed.t list -> unit
val lead : Fixture.t -> int
val request : ?extra_bits:int -> ?extra_byte:char -> selected:int -> deselected:int
  -> string -> Observed.t
val response_read : Fixture.t -> Read.t -> Observed.t
val committed : Fixture.t -> Exchange.t -> Observed.t
val transaction : ?extra_bits:int -> ?extra_byte:char -> Fixture.t -> Exchange.t
  -> string -> Observed.t list
val expect_transaction : Fixture.t -> tag:int -> Wire.Request.t -> Exchange.t
```

`extra_bits_sent` is the partial final byte as `Driver.send` clocks it (the first
`extra_bits` bits of `extra_byte`, with the driver's defaults 0 and `'\xff'`); both
`record_request` and the monitor suite's `request` use it, so the scoreboard and the
monitor suite build partial bytes the same way. The monitor suite's `sexp_of_item` and
`uncorrelated` were not copied: `Scoreboard.sexp_of_serial_item` and
`Scoreboard.uncorrelated` are the same functions (only `hex` is spelled
`Serial_host.Item.hex`), so the port uses those, and `expect_observed`'s report prints
exactly as before. `lead` reads `Fixture.timing` (the driver's timing) instead of the
shim-only `t.timing` mirror, which holds the same value. `expect_transaction` returns its
exchange, where the original returned `unit`, so the Control_port expectations can be
placed from the driver's deselection cycle.

Per-test choices. As in SP5a, "kept" means every original check is still made with the
same label, expected value, and cycle. No original check was replaced by a scoreboard
expectation in SP5b; the last column is what the scoreboard checks in addition.

| Original → port (same name) | Run | Why | Scoreboard expectations |
| --- | --- | --- | --- |
| F1 the maximum legal frame dispatches; a twelfth byte latches overrun | `Scoreboard` | contract-faithful: a malformed frame is host traffic the loader must reject, sent with in-contract timing and gaps | 9 frames and committed reads (WRITE_WORD, four rejected frames, four INFOs); 1 accepted `Load_write` offer; no pulses |
| F2 long zero prefixes and valid-looking suffixes cannot dispatch | `Scoreboard` | as F1 | 12 frames and reads; no offers |
| F3 bad magic, version, CRC, command, and payload length are rejected | `Scoreboard` | as F1 | 36 frames and reads; no offers |
| F4 device bounds refuse lengths and addresses without an offer | `Scoreboard` | as F1 | 7 frames and reads; no offers |
| F5 truncated frames and partial bytes are incomplete, echoed from four bytes | `Scoreboard` | as F1; each partial final byte is recorded as `extra_bits` | 24 frames (including the empty selection) and reads; no offers |
| F6 a zeroed echo can match INFO with tag 0 but is still an error | `Scoreboard` | as F1; the replayed mismatch is a `Scoreboard.read` with a `Replay` ending | 4 frames, 5 reads (1 replay); no offers |
| F7 the peer's sixteen malformed trials at seed 20260921 are rejected | `Scoreboard` | as F1 | 32 frames and reads; no offers |
| C1 an early selection during dispatch cannot consume or overwrite the command | `Fixture` (three runs) | early selections: out-of-contract host traffic, classified by the monitor's host-side rule (SP2 classification note) | n/a |
| C2 an early selection during a READ wait cannot consume or overwrite it | `Fixture` (two runs) | early selections; the second run is also a labelled robustness probe (`Delayed 2000`) | n/a |
| C3 an early selection during an ABORT wait cannot consume or overwrite it | `Fixture` (two runs) | early selections; the second run is also a labelled robustness probe (`Never`, staged cleanup) | n/a |
| C4 consecutive distinct tags and commands each correlate with their own answer | `Scoreboard` | contract-faithful; each request-list entry gained its written-out offer and READBACK pulse | 6 frames and reads; 4 accepted offers (READ, LOAD_START, LOAD_WRITE, STOP); 1 pulse (`0x0101`, match low) |
| C5 reset and disable cancel a partial request | `Scoreboard` (one run each) | in-contract host traffic and responder; the original has no robustness label | per run: the partial frame (one byte and three bits, deselected in the restored cycle), INFO frame and read; no offers |
| C6 reset or disable in the dispatch cycle cancels the command | `Scoreboard` (one run each) | contract-faithful | per run: WRITE frame, the refused `Load_write` offer (`accepted false`), INFO frame and read |
| C7 reset or disable during a READ wait cancels its response | prompt READ: `Scoreboard`; delayed READ with stray pulse: `Fixture` (four runs) | the prompt READ is contract-faithful; the delayed READ is a labelled robustness probe | prompt run: 2 READ frames, 1 read, 2 accepted READ offers, 1 pulse (`0x0505`, match low) for the fresh READ and none for the cancelled one |
| C8 robustness: reset or disable during an ABORT wait cancels its response | `Fixture` (two runs) | labelled robustness probe (`Never`) | n/a |
| C9 disable discards a retained response in the same cycle | `Scoreboard` | in-contract host traffic and responder; unlabelled | STATUS frame (its response is discarded, never read), INFO frame and read; no offers |
| C10 reset discards a partially read response | `Scoreboard` (SP6; `Fixture` in SP5b) | in-contract host traffic and responder; the read reset cuts short is a `Scoreboard.abandoned` read of the 20 bits the driver sampled, deselected in the cycle reset is released | STATUS frame, 1 abandoned read (2 bytes and 4 extra bits), fresh STATUS frame and committed read; no offers or pulses |
| M1 the monitor's items for one WRITE_WORD transaction | `Scoreboard` | contract-faithful | 1 accepted `Load_write` offer; no serial items, since the file's own `expect_observed` drains the serial monitor (the scoreboard then requires the queue to be empty) |
| M2 legal INFO, READ, and VERIFY transactions | `Scoreboard` | contract-faithful | 3 accepted offers (READ 3, VERIFY 3 `0xa659`, VERIFY 4 0), 3 pulses (`0xa659` low, `0xa659` high, `0xa15e` low), written out from the responder's default memory; serial side as M1 |
| M3 a malformed request is observed as the raw bytes clocked | `Scoreboard` | as F1 | no offers or pulses; serial side as M1 |
| M4 a request with trailing extra bits keeps them apart from its bytes | `Scoreboard` | as F1 | as M3 |
| M5 a replayed response, then its commit | `Scoreboard` | contract-faithful | as M3 |
| M6 abandoned reads before and after the header | `Scoreboard` | the abandoned reads are this file's own expectations; the Control_port side is expressible | as M3 |
| M7 the agent is active only with a driver | neither | builds agents directly; no fixture exists (as in the original) | n/a |
| M8 the scoreboard reports an LDI bit the driver did not send | `Fixture` | test-only LDI fault injection: the pins deliberately disagree with the driver, which the file's own check must report | n/a |

Test names, scenario strings, order, and every string literal in each test body were
compared by SP5a's script between each original and its port: equal for all 25 tests. The
two expect blocks in the monitor suite have the original's SHA-256
(`c298149fb646dc16d227bc0f442b86b60c07d9df5c874ef095a247b10b118cb9` and
`5bca65be0cc0a8787ff6e52a1df77dbc9abe33e219deefa0759ae76ad67837ac`) and pass
unpromoted; D1's is still `e6149312…`. The script still reports SP4's one recorded T4
replacement in the transaction file and nothing else. Comments were carried over verbatim
except: "stub" → "responder" (framing and cancellation headers, C1);
`[Hardware_loader_testbench.Raw]` → `[Serial_host.Item.Raw]` (framing header, the SP1/SP2
follow-up); "through the testbench's test-only adapter path" → "through the fixture's
test-only adapter path ([ldi_fault])" and "only this file joins them" → "only this file
and its helpers in [Endpoint_scenario] ... join them" (monitor header). Each header gained
a paragraph on the port and the `Scoreboard.run`/`Fixture.run` split; `expect_rejected`,
C4's request list, and M2 gained one comment each for the scoreboard additions. Other
than names (`create` → `Fixture.run`/`Scoreboard.run`, `t.stub` → `Fixture.responder t`,
`send_frame t` → `Driver.send_frame (Fixture.driver t)`, `t.timing` → `Fixture.timing t`,
`Core_stub.inject_readback_response` → `Control_port_agent.Responder.inject_readback_response`),
the bodies changed only to record the scoreboard's side: C5 binds the deselection cycle
it used to ignore, C6, C7, and F6 bind the frame they send, and F6 takes the selection
cycle before its replayed read.

Evidence of identical observations, by SP5a's method: `fixture.ml` was instrumented
temporarily so that `create` wrote the scenario, `log` wrote every transcript event before
the bounded queue, and `cycle` wrote each item the Control_port and serial monitors
emitted, right after each monitor's `sample`, to the file named by `SP5B_DUMP`. Both
runners were built by explicit target and run directly, one at a time, per file
(`-only-test hardware_loader_<file>_tests.ml` / `serial_host_monitor_tests.ml` and
`-only-test endpoint_<file>_tests.ml`); the transaction and diagnostics pairs were rerun
too, since `endpoint_scenario.ml` and the diagnostics file changed. SP5a's comparison
script compared the dumps instance by instance:

| File | Fixture instances | Events | Serial items | Control_port items | Result |
| --- | --- | --- | --- | --- | --- |
| framing (7 tests) | 7 | 1258 | 249 | 1 | identical per instance; dumps byte-identical (SHA-256 `1b762262…`) |
| cancellation (10 tests) | 20 | 495 | 80 | 28 | identical per instance; dumps byte-identical (`ef174a64…`) |
| serial monitor (8 tests) | 7 | 133 | 24 | 7 | identical per instance; dumps byte-identical (`4367fbed…`) |
| transaction (rerun) | 15 | 563 | 99 | 39 | identical; byte-identical to SP5a's dumps (`78d9b21c…`) |
| diagnostics (rerun) | 4 | 41 | 6 | 3 | identical; byte-identical to SP5a's dumps (`2e89edb4…`) |

M7 builds no instance in either suite. The comparison was made once before formatting and
again on the final files, with the same dumps. `fixture.ml` was restored from its copy each
time (`cmp` clean against the copy, which differs from the start copy only in the header
comment edit above); no `SP5B`/`sp5b` text remains under `test/` or `lib/`. The dumps,
instrumentation script, comparison output, and runner logs are in the session scratchpad.

Non-vacuity, each a temporary edit under `endpoint/`, run per file with the built endpoint
runner, then restored from a copy (`cmp` clean):

1. `Endpoint_scenario.extra_bits_sent` took one bit fewer. Framing failed 1 of 7 (F5, at
   "the serial monitor saw the driver's frames and reads"), cancellation 1 of 10 (C5, the
   same scoreboard check), and the monitor suite 1 of 8 (M4, at its own "WRITE_WORD and
   three bits"): every test with a partial final byte.
2. `Scoreboard.check` compared only accepted offers. Cancellation failed 1 of 10 (C6:
   expected the refused `Load_write` offer at cycle 719, actual none); framing and the
   monitor suite, which expect no refused offers, passed.
3. `Endpoint_scenario.lead` returned one cycle more. The monitor suite failed 6 of 8: M2–M6
   at their `expect_observed` labels, and M1 as an expect diff (uncaught
   `Harness_failure` at "WRITE_WORD", response `selected` 720 against 721). M7 has no
   fixture; M8 passed because its expected item uses the selection cycle directly and the
   fault window, shifted one cycle, still covers request bit 20's sample. Framing and
   cancellation, which do not use `lead`, passed. The generated `.corrected` file was
   deleted.

Commands, run one at a time from the repository root through `./scripts/with-switch.sh`
(the evidence and non-vacuity runs used the built inline runners directly, also one at a
time):

| Command | Result |
| --- | --- |
| `dune runtest -j 5 test/host_link --force` (baseline) | pass (8.1 s) |
| `dune build -j 5 @test/host_link/endpoint/all` | pass |
| `dune runtest -j 5 test/host_link --force` (ports, first run) | pass (10.2 s); no expect diff in any suite |
| `dune build -j 5 <endpoint and archive inline-test-runner.exe>` | pass (needed before each direct runner use; `@all` does not relink the runners) |
| inline runners, per file, with and without instrumentation | see the evidence and non-vacuity results above |
| `dune build -j 5 @test/host_link/fmt` (before formatting) | the three new files and `endpoint_scenario.ml`, plus `frame_rx_validation_tests.ml` |
| `dune runtest -j 5 test/host_link --force` (final) | pass (13.6 s); no expect diff in any suite (archive, serial_phy, frame_rx, frame_tx, command_dispatch, endpoint) |
| inline runners `-list-test-names` | endpoint transaction 10, framing 7, cancellation 10, diagnostics 5, serial monitor 8, lifecycle 1 (40 ported plus lifecycle); archive 40 |
| `dune build -j 5 @test/host_link/lint` | pass |
| `dune build -j 5 @test/host_link/fmt` | fails only on `frame_rx/frame_rx_validation_tests.ml` (pre-existing, out of scope) |
| `dune build -j 5` | pass |
| `sha256sum -c` over the six archived `.ml` files | all OK; `diff -r` of `archived/` against the start copy is empty |

The four created or rewritten `.ml` files and the diagnostics file were formatted with
`ocamlformat --inplace` (the switch's binary and the repository `.ocamlformat`), not
`dune promote`; the diffs were line breaks and comment rewraps only. No `.corrected` file
remains in `_build`, no expect output was promoted anywhere, and `--auto-promote` was not
used.

Docs:

- This file: the Layout block now shows the post-SP5 tree; the Execution rules bullet
  names the endpoint suite as the one that must stay passing and the archive as unchanged;
  SP5b is ticked; the status line says SP5 is complete pending owner review.
- `verification.md` (minimal edits next to the owner's uncommitted ones): the HL4 status
  paragraph (formerly line 61) names the endpoint suite and the frozen archive with working
  links; the test-inventory row for `test/host_link/` (32) became two rows,
  `test/host_link/endpoint/` (41: 32 HL4a, 8 SP2, 1 lifecycle) and
  `test/host_link/archived/hl4a/` (40, frozen); the "Independent hardware loader" evidence
  row's link now points at the archive and mentions the endpoint suite.

Dangling links in dated docs, left as written: `host_link_migration.md` lines 121, 163,
and 354 (`../test/host_link/hardware_loader_testbench.ml`); `host_link_hl4a_record.md`
line 56 (`../test/host_link/hardware_loader_testbench.ml`) and line 271
(`../test/host_link/hardware_loader_diagnostics_tests.ml`). Stale plain-text paths (not
links) in dated records: the file tables of `host_link_hl4a_record.md` (lines 40–44),
`host_link_hl4b1_record.md` (45–49), `host_link_hl4b2_record.md` (55–59), and
`host_link_hl4b3_record.md` (60–64), and `architecture_migration.md` line 392, which names
`test/host_link/hardware_loader_*` as an unchanged compatibility surface. Outside SP5b's
list and not edited: `docs/README.md`'s row for this file (an uncommitted owner line) still
says "SP1–SP4 steps", and `fixture.ml`'s `Harness_failure` comment (not a header comment)
still says "the endpoint pilots".

Deviations:

- **M1's `[%expect]` block follows the `Scoreboard.run` call** instead of sitting between
  the print and `expect_observed`. The block compares the output collected up to it, and
  `expect_observed` prints nothing, so it sees the same output; outside the closure its
  text and indentation stay identical to the original's.
- **The monitor suite keeps its own serial scoreboard.** Its negative's report is
  `expect_observed`'s, so that check cannot become `Scoreboard`'s. The contract-faithful
  cases run under `Scoreboard.run` with Control_port expectations only, which adds the
  offers and READBACK pulses of M1 and M2 to what the suite checks; the scoreboard's
  serial comparison there only requires that the file left nothing unchecked.
- **`require_failure` moved** from `endpoint_diagnostics_tests.ml` (an SP5a file) to
  `Endpoint_scenario`, to avoid a second copy in the monitor suite.
- **`expect_transaction` returns its exchange** (the original returned `unit`); M2 ignores
  the INFO one.
- **`disturb`'s `?board` is still unused.** Every cancellation test that disturbs runs
  under `Fixture.run`, as the port rules direct for early selections, including the
  contract-faithful-responder runs of C1–C3.
- **C5 and C9 run under `Scoreboard.run`** although the original labels neither: host
  traffic and responder are in contract, and reset or disable are ordinary inputs.
- **C10 runs under `Fixture.run`**, like T8, because `Scoreboard` has no abandoned-read
  expectation. `Scoreboard.abandoned` was not added (owner decision).
- The direct runners must be built by their target path: an `@all` build does not relink
  them, and a first evidence attempt ran a stale runner and wrote no dumps. It was
  discarded and rerun.

Remaining owner decisions:

- Renaming `Harness_failure`'s printed atom (an expect change in the archive,
  `endpoint_diagnostics_tests.ml`, and now `endpoint_serial_monitor_tests.ml`).
- Dropping the archive from the build. The fixture record's HL4a-shim-only fields (`stub`,
  `timing`) can go only with it, since the archived tests still read them.
- Whether T3 should move to `Scoreboard.run`.
- Whether to add `Scoreboard.abandoned`, which would let T8 and C10 move to
  `Scoreboard.run` (M6 could use it too).
- Whether the scoreboard should cover early selections (C1–C3, T10); that needs the
  serial monitor's classification reconciled with the loader's arming rule.
- Whether the monitor suite's local serial scoreboard should be replaced by `Scoreboard`,
  which would change its negative's expect block.
- Converging the SP3 injection policies.
- Whether to fix the dangling links listed above in the dated records.

### 2026-10-18 — SP6

Baseline: `ca7c593688e110fdae2191d91e258dd91b0c7587` (`git rev-parse HEAD`), with the
uncommitted SP1–SP5b tree recorded above; nothing was committed or staged. A copy of
`test/host_link/` and this file, and SHA-256 sums of every file under `lib/`,
`host_link_wire/`, `test/`, and `docs/`, were kept in the session scratchpad. At the start
`fixture.ml` and `scoreboard.ml` were byte-identical to SP5b's final copies, and
`endpoint_scenario.ml` differed from SP5b's only in a rewrap of its header comment (an
edit made after SP5b). `dune runtest -j 5 test/host_link --force` passed before any
change (9.1 s). Scope: the plan's SP6, plus T3, which the owner added during the step
(the T3 task line above).

Changed (`test/host_link/endpoint/`; nothing created or moved):

- `scoreboard.ml` (163 → 199 lines): `abandoned`, below. Header: expected serial items
  now include an abandoned read's bits and deselection cycle; the stale sentence "The
  scoreboard is not applied to the HL4a scenarios" became "a scenario opts in through
  [run] or by calling [check]; scenarios with early selections do not", with the same SP2
  reference. `request`, `read`, `offer`, `readback`, `check`, and `run` are byte-identical.
- `endpoint_scenario.ml` (330 → 343 lines): `read_prefix ?board`, below; the header names
  it and says a helper may record the bits of an abandoned read.
- `endpoint_transaction_tests.ml` (818 → 834 lines): T3 and T8 under `Scoreboard.run`;
  each test comment gained one sentence on what the scoreboard expects, and the file
  header says the refused STOP and ABORT probes, whose host traffic is in contract, run
  under `Scoreboard.run` too.
- `endpoint_cancellation_tests.ml` (568 → 579 lines): C10 under `Scoreboard.run`; its
  comment gained one sentence; the file header no longer lists "a response abandoned by
  reset" among the `Fixture.run` cases.
- This file (below).

Byte-identical to the start copy: `fixture.ml`, `latency.ml`, `dune`, and the other four
endpoint test files (`cmp`); everything under `archived/` (`diff -r`); every file under
`lib/`, `host_link_wire/`, `serial_host/`, `test/core/control_port/`, and the block
suites (`sha256sum -c`; the only mismatches are the four files above).

`Scoreboard.abandoned` and the helper:

```ocaml
val Scoreboard.abandoned
  : Scoreboard.t -> selected:int -> deselected:int -> bits:int -> string -> unit
val Endpoint_scenario.read_prefix
  : ?board:Scoreboard.t -> Fixture.t -> bits:int -> string * int
```

`abandoned t ~selected ~deselected ~bits packed` enqueues one expected
`Observed.Response` with `ending = Abandoned`. `packed` is `bits` bits packed MSB first
with a final partial byte in its low bits, which is what `Driver.read_prefix` returns
(`Item.bytes_of_bits`); `selected` is the cycle LSEL_N fell, taken by the scenario before
the read, as for `read`; `deselected` is the cycle the driver reported. The first
`bits / 8` characters are the whole bytes; a partial byte's `bits % 8` low bits, in MSB
order, are `extra_bits`, which is how the monitor's `split` holds them. `decoded` is
`Wire.Response.decode` of the whole bytes (uncorrelated, as the monitor decodes). A
`packed` whose length is not `ceil (bits / 8)` raises with `bits` and the hex bytes: a bug
in the test, like `Item.encode`'s bad request. Nothing comes from a monitor, the
responder, or the loader. The codec supplied every expected decode (`Truncated` with
`actual 3` for T8 and `actual 2` for C10), so no scenario writes one out.
`Endpoint_scenario.read_prefix ?board t ~bits` takes the selection cycle, calls
`Driver.read_prefix`, and, given a board, records `Scoreboard.abandoned` with the driver's
result; its pin activity is `Driver.read_prefix`'s. T10's four `Fixture.run` probes still
call `Driver.read_prefix` directly. M6 keeps its own written-out abandoned items
(`endpoint_serial_monitor_tests.ml` was outside SP6's files).

Per-test changes. Every original check is kept with the same label, expected value, and
cycle; no original check was replaced by a scoreboard expectation. The SP5a and SP5b
tables' T3, T8, and C10 rows now say `Scoreboard` and what it expects.

| Test | Was | Now | Scoreboard expectations | Body changes beyond the board |
| --- | --- | --- | --- | --- |
| T3 a refused command reports the status-derived class ... | `Fixture` | `Scoreboard` (one run, all 12 cases) | 12 frames and committed reads (`transact ~board`), 12 refused offers (`Scoreboard.offer ~accepted:false` from each request's deselection); no READBACK pulses | none |
| T8 an abandoned partial read replays from byte zero ... | `Fixture` | `Scoreboard` | RUN frame, the 24-bit abandoned read (`read_prefix ~board`), the committed read (`receive ~board`), 1 accepted `Run` offer; no pulses | the frame is bound to `frame` for `Scoreboard.request` |
| C10 reset discards a partially read response | `Fixture` | `Scoreboard` | STATUS frame, the abandoned read (2 bytes and 4 extra bits, deselected in the cycle reset is released), the fresh STATUS frame and committed read; no offers or pulses | the frame is bound; the selection cycle is taken before `Driver.begin_frame`; the 20 `Driver.read_bit` results are queued instead of ignored; `Driver.deselect`'s cycle is bound |

C10 is expressible from the driver's side: under reset LCLK stays low, so the monitor
samples exactly the 20 rises the driver clocked, and the read ends with LCLK low before
the declared length, which the monitor reports as `Abandoned`. The bits are the values
`Driver.read_bit` returned (the pre-edge LDO of each rise cycle, which is what the monitor
samples), packed with `Item.bytes_of_bits` as `read_prefix` packs them. T3 needed no
split run: the refused STOP and ABORT are ordinary refused offers to the scoreboard, and
their labels stay in the case table. `structure.py` (SP5a's script) still reports
identical names, scenario strings, literals, and order for both files against the
archive, except SP4's one recorded T4 replacement.

Evidence of identical observations, by the SP5a/SP5b method: `fixture.ml` was
instrumented temporarily by SP5b's script (dump variable renamed `SP6_DUMP`), both
runners were built by target path, and the archived and endpoint transaction and
cancellation files were run directly, one at a time. SP5b's comparison script:

| File | Fixture instances | Result |
| --- | --- | --- |
| transaction | 15 | archive and port identical per instance; T3 ("refused commands": 140 events, 24 serial items, 12 Control_port items) and T8 ("partial read replay": 16, 3, 1) included; dump byte-identical to SP5b's (SHA-256 `78d9b21c…`) |
| cancellation | 20 | identical per instance; C10 ("reset during a response read": 24, 4, 0) included; dump byte-identical to SP5b's (`ef174a64…`) |

The dumps show T8's abandoned item as `5a 10 75` with no extra bits and C10's as
`5a 10` with extra bits `(true true true true)`, the high nibble of the tag `0xf2`, so the
partial-byte split is exercised. `fixture.ml` was restored from its copy and `cmp` against
the start copy is clean; the only `SP6` text under `test/` or `lib/` is the
`endpoint_scenario.ml` header's reference to this section.

Non-vacuity, each a temporary edit, the endpoint runner rebuilt and run over all 41 tests,
then restored from a copy (`cmp` clean):

1. `Scoreboard.abandoned` expected one bit fewer (the last bit dropped and the bits
   re-split). Failed 2 of 41, T8 and C10, at "the serial monitor saw the driver's frames
   and reads" (T8 expected `5a 10` and seven extra bits against `5a 10 75`; C10 expected
   three extra bits against four).
2. `Scoreboard.abandoned` expected `deselected + 1`. Failed 2 of 41, T8 (662 against
   661) and C10 (629 against 628), at the same check.
3. T3's `Scoreboard.offer` expected `~accepted:true`. Failed 1 of 41, T3, at "the
   Control_port monitor saw the predicted offers".

No `.corrected` file was generated or remains in `_build`.

Commands, run one at a time from the repository root through `./scripts/with-switch.sh`
(the evidence and non-vacuity runs used the built inline runners directly, also one at a
time):

| Command | Result |
| --- | --- |
| `dune runtest -j 5 test/host_link --force` (baseline) | pass (9.1 s) |
| `dune build -j 5 @test/host_link/endpoint/all` | pass |
| `ocamlformat` on the four changed files | comment rewraps in `scoreboard.ml` and the C10 comment, applied with `--inplace`; all four now format clean |
| `dune runtest -j 5 test/host_link --force` (after the change) | pass (13.2 s) |
| `dune build -j 5 <endpoint and archive inline-test-runner.exe>` | pass (before each direct runner use) |
| inline runners, per file and over the endpoint suite | see the evidence and non-vacuity results above |
| `dune runtest -j 5 test/host_link --force` (final) | pass (13.1 s); no expect diff in any suite |
| inline runners `-list-test-names` | endpoint 41 (transaction 10, framing 7, cancellation 10, diagnostics 5, serial monitor 8, lifecycle 1); archive 40 |
| `dune build -j 5 @test/host_link/lint` | pass |
| `dune build -j 5 @test/host_link/fmt` | fails only on `frame_rx/frame_rx_validation_tests.ml` (pre-existing, out of scope) |
| `dune build -j 5` | pass |
| `sha256sum -c` over the six archived `.ml` files | all OK; `diff -r` of `archived/` against the start copy is empty |

No expect output was promoted and `--auto-promote` was not used.

Deviations:

- **T3 added to SP6** by the owner during the step; done under the same rules as T8 and
  C10, in one `Scoreboard.run`.
- **Header comments of the two test files and the scoreboard** were edited beyond the
  task's wording, because each described T8, C10, or T3 as staying on `Fixture.run`, or
  (the scoreboard's) the pre-SP5 state.
- **C10's body** queues the bits `Driver.read_bit` returned instead of ignoring them;
  pins and cycles are unchanged (evidence above).
- **The fixture was instrumented temporarily** for the evidence, as in SP5a and SP5b, and
  restored (`cmp` clean); no other file outside SP6's list was touched.

Remaining owner decisions, updated from SP5b: T3 and `Scoreboard.abandoned` are settled.
M6 could now use `Scoreboard.abandoned` if the monitor suite's local serial scoreboard is
replaced (still open, as are the `Harness_failure` atom, dropping the archive, early
selections under the scoreboard, the SP3 injection policies, and the dangling links in
dated records). After SP6 no endpoint test stays on `Fixture.run` because of an abandoned
read: T10 (early selections), C1–C3, C7's delayed READ, C8, D4, D5, and M8 remain there
for the reasons in the SP5 tables.
