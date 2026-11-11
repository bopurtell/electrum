# The ASIC flow

This is the source of truth for **`./asic/flow.sh`**: stages, inputs/outputs,
overrides, resuming and qualification status. The bundle contract is in
[asic-adoption.md](asic-adoption.md), setup in [environment.md](environment.md),
and the OCaml/Python boundary rationale in [tooling_theory1.md](tooling_theory1.md).
Commands below use the repository root unless explicitly labelled historical.

## The one path

[`asic/flow.sh`](../asic/flow.sh) is the public implementation command. It
consumes an environment; [`scripts/bootstrap.sh`](../scripts/bootstrap.sh)
prepares it. Normal bootstrap stages no design, and normal flow invocation does
not provision. The transitional explicit `bootstrap` flow step provisions tools.
Ordinary Dune build/test aliases do not start physical implementation.

The adopted input is an immutable `hardcaml_asic` bundle. Its configuration comes
from [`asic/project/chip_project.ml`](../asic/project/chip_project.ml), with
package/resource constructors in [`asic/rtl/`](../asic/rtl/) and emission through
[`asic/cli/asic_bundle.ml`](../asic/cli/asic_bundle.ml). The hand-maintained
`asic/tinytapeout/info.yaml` and `asic/tinytapeout/src/config.json` belong only to
[the legacy staged-project path](#the-legacy-path).

## Quick start

```sh
./scripts/bootstrap.sh          # prepare tools; normal mode stages no design
source scripts/env.sh           # activation for commands typed in this shell
./asic/flow.sh --help            # stages, overrides and resuming
```

To prepare a bundle without hardening:

```sh
export PROTEMU_FLOW_OUT="$PWD/_flow_results/my-experiment"
./asic/flow.sh build emit preflight
```

A bare **`./asic/flow.sh` starts the full physical sequence**, allocates a fresh
output directory and can take hours. Named stages run only the requested work.
The layout migration did not execute that full sequence; see
[qualification](#verified-behavior-and-known-limits).

## Stages

The bare/default sequence is:

```text
build → emit → preflight → run → postcheck → collect → report → archive
```

| Stage | What it does | Needs | Writes |
| --- | --- | --- | --- |
| `build` | Dune build and runtest through the pinned switch, `-j5` | OCaml layer | `_build/` |
| `emit` | Emits the immutable bundle from the typed declaration | OCaml layer | `$PROTEMU_BUNDLE` |
| `preflight` | Validates bundle, collateral, versions, image and configuration; starts no physical run | bundle, flow tools | `$PROTEMU_FLOW_OUT/preflight.json` |
| `run` | Starts LibreLane hardening on the bundle | bundle, PDK, image | new directory under `$PROTEMU_RUNS`, `run.json` |
| `postcheck` | TT precheck and gate-level wrapper simulation | completed full run and precheck tools | `postcheck.json` |
| `collect` | Collects recorded run artifacts | explicit run | `results.json` |
| `report` | Prints timing/physical verdicts; fails required nonpassing verdicts | recorded/collected results | terminal summary |
| `archive` | Copies verified records/reports from a `completed` run | completed run | `$PROTEMU_FLOW_RESULTS/<date>-<run id>/` |
| `bootstrap` | Explicit transitional flow-tool provisioning; prefer `scripts/bootstrap.sh` | host prerequisites | `_flow_tools/` |

`--full` explicitly requests the default sequence and fresh allocation. Steps run
in the supplied order, and **no step produces an earlier step's prerequisites**.
`./asic/flow.sh run` hardens an existing bundle; it does not emit one first.

For example, after preparation and preflight above:

```sh
./asic/flow.sh run postcheck collect report
```

## Output and artifacts

`PROTEMU_FLOW_OUT` names one experiment: one bundle and its execution attempts.

- Full/default runs allocate `_flow_results/flow-<timestamp>-<unique suffix>/`
  unless `PROTEMU_FLOW_OUT` explicitly names the experiment.
- Named stages default to `_flow_results/adopted`.
- Bundles default to `$PROTEMU_FLOW_OUT/bundle`, runs to
  `$PROTEMU_FLOW_OUT/runs`. Every attempt gets its own run directory; failed runs
  retain logs.
- Emission refuses a nonempty bundle directory. Choose a new output directory;
  the flow does not delete an existing bundle to make emission pass.
- New archives default to `_flow_results/archives/<date>-<run id>/`.
- These execution outputs are ignored. Durable evidence must be deliberately
  promoted/preserved; the `archive` stage does not itself make files tracked.
- Provisioned/runtime state is separate under `_flow_tools/`, not under the
  authored target tree or `.dev/`.

### Environment

`./asic/flow.sh --help` is authoritative.

| Variable | Meaning | Default |
| --- | --- | --- |
| `PROTEMU_FLOW_OUT` | experiment directory | fresh `_flow_results/flow-*` for full runs; `_flow_results/adopted` for named stages |
| `PROTEMU_BUNDLE` | emitted bundle | `$PROTEMU_FLOW_OUT/bundle` |
| `PROTEMU_RUNS` | execution storage | `$PROTEMU_FLOW_OUT/runs` |
| `PROTEMU_RUN` | existing run for stages after `run` | none; never guessed |
| `PROTEMU_FLOW_RESULTS` | archive parent | repository `_flow_results/archives` |
| `PROTEMU_ARCHIVE` | exact archive destination | derived from run start time/ID |
| `PROTEMU_STAGE` | `full` or `synthesis` | `full` |
| `PROTEMU_DESIGN` | `observable`, `memory` or `loader` | `observable` |
| `PROTEMU_TT` | support-tools checkout | `TT_SUPPORT_TOOLS_DIR` from environment/bootstrap, otherwise `_flow_tools/tt` |
| `PROTEMU_PDK_ROOT` | IHP CMOS5L PDK root | `PDK_ROOT` from environment/bootstrap, otherwise `_flow_tools/pdk` |
| `PROTEMU_FLOW_PY` | LibreLane Python | `_flow_tools/venv/bin/python` |
| `PROTEMU_PRECHECK_PY` | precheck Python | `_flow_tools/precheck-venv/bin/python` |
| `PROTEMU_ALLOW_PYTHON_MISMATCH` | `0` requires the bundle's exact Python minor | `1` |

The runner loads `_flow_tools/toolchain-env.sh` when present. Explicit overrides
can select existing external tools without reprovisioning. Relative output,
bundle, runs, run and archive overrides resolve against the **caller's working
directory**; the script's own location determines repository-root defaults.

## Resuming and inspecting a run

Stages following `run` in the same invocation use the run just produced. A
separate invocation must name its run; the newest directory is never selected
implicitly:

```sh
PROTEMU_RUN=/absolute/path/to/run ./asic/flow.sh postcheck collect report
PROTEMU_RUN=/absolute/path/to/run ./asic/flow.sh report
```

`collect` and `report` read recorded artifacts using system `python3`; they need
neither a switch nor a PDK and do not rebuild or provision. Use an actual recorded
run tree for these commands; a curated archive directory is not necessarily an
unpacked executable run tree.

## Synthesis only

```sh
PROTEMU_STAGE=synthesis ./asic/flow.sh build emit preflight run collect report
```

This starts mapped synthesis, not just generic RTL checks. `postcheck` requires a
completed full run. Synthesis alone does not establish routed timing or physical
closure.

## Failure, interruption, and the summary

A failing stage stops later stages and returns nonzero. The final summary gives
stage/end-to-end time, failed or interrupted stage, and paths of records/logs
that exist, including an archive when created. Missing evidence is not a pass.

SIGTERM returns 143 and reports interruption. Bash may defer handling a signal
sent only to the wrapper until its foreground stage returns; the correct status
and summary do not imply immediate cancellation of that stage.

## Where results are kept

Full run directories are scratch, historically roughly 240 MB per attempt.
`archive` selects records/reports, historically about 1 MB, and re-verifies hashes
pinned by the run. Its destination is named from the run's own start time and
ID. Re-archiving replaces generated archive files but leaves a curated README
alone. Incomplete runs are refused; their original directories/logs remain the
diagnostic source.

The previous tracked `flow_results/` tree is now byte-preserved under
[`archive/legacy/flow_results/`](../archive/legacy/flow_results/). Dated target
reports are under
[`archive/legacy/tinytapeout/reports/`](../archive/legacy/tinytapeout/reports/).
Their original commands, absolute paths, manifests and identities were not
rewritten. [`archive/INDEX.md`](../archive/INDEX.md) records old/new locations and
unchanged hashes. New `_flow_results/archives/` output is distinct from this
historical archive.

Historical evidence:

- [P0.5b first adopted physical run](../archive/legacy/flow_results/20260918-230920-05f65042/README.md),
  with [experiment record](../archive/legacy/tinytapeout/reports/2026-09-19-p0.5b-adopted-physical.md).
- [P0.5c clean-staging reproduction](../archive/legacy/flow_results/20260920-081325-ccecd9ed/README.md),
  including its complete emitted input bundle, with
  [experiment record](../archive/legacy/tinytapeout/reports/2026-09-20-p0.5c-clean-staging-physical.md).
- [P0.7 memory mapped-synthesis result](../archive/legacy/flow_results/20260920-071538-a538212c/README.md),
  with [experiment record](../archive/legacy/tinytapeout/reports/2026-09-20-p0.7-memory-synthesis.md).

## Checking the flow itself

```sh
./asic/tinytapeout/scripts/check-flow.sh  # stub orchestration, no physical tools
flock ../.protemu-build.lock ./scripts/with-switch.sh dune build -j5 asic/cli/asic_bundle.exe
python3 asic/tinytapeout/scripts/check-adopted-bundle.py --metadata-only
```

[`check-flow.sh`](../asic/tinytapeout/scripts/check-flow.sh) substitutes a stub for
Dune. Its 17 checks cover arguments, allocation, resuming, caller-relative
overrides, failures and signals. It uses temporary fixtures and may create the
ignored `_flow_results/` parent for default-allocation checks; it starts no real
producer/physical tool. CI runs it separately from ordinary `runtest`.

The bundle checker validates a different contract; its full mode runs HDL tools
in the pinned image, while `--metadata-only` does not. See
[ASIC adoption checks](asic-adoption.md#checks). The flow does not invoke this
checker automatically. `./asic/flow.sh build emit preflight` exercises real
bundle generation and prerequisite validation without hardening, but still needs
a provisioned environment for preflight.

## Implementation map

| File | Role |
| --- | --- |
| [`asic/flow.sh`](../asic/flow.sh) | public entry point, root detection, full-run default, runner exit status |
| [`adopted-flow.sh`](../asic/tinytapeout/scripts/adopted-flow.sh) | sequencing, allocation, summary/signals; builds via `scripts/with-switch.sh` |
| [`adopted_phase4.py`](../asic/tinytapeout/scripts/adopted_phase4.py) | preflight, execution, postchecks, collection |
| [`adopted_report.py`](../asic/tinytapeout/scripts/adopted_report.py) | recorded results and required verdicts |
| [`adopted_archive.py`](../asic/tinytapeout/scripts/adopted_archive.py) | verified record/report extraction into new archives |
| [`asic/cli/asic_bundle.ml`](../asic/cli/asic_bundle.ml) | stable bundle CLI |
| [`asic/project/chip_project.ml`](../asic/project/chip_project.ml) | typed declaration and canonical source inventory |

Runner/reporter/archiver are consumer-side helpers; runtime does not reach into a
`hardcaml_asic` source checkout. Recorded dependency revisions are in
`asic/tinytapeout/asic-dependencies.lock` and `toolchain.lock`.

## Aliases and compatibility

| Command | Meaning |
| --- | --- |
| `dune exec -j5 protemu -- flow` | alias for `./asic/flow.sh`, including its physical default |
| `dune exec -j5 protemu -- harden` | `./asic/flow.sh run` |
| `asic/tinytapeout/scripts/adopted-flow.sh` | underlying runner; no arguments prints help |

`harden` rejects legacy `-tag`/`-no-docker` flags with an explicit diagnostic
directing users to `legacy-harden`. They are not reinterpreted as adopted-flow
options. Bootstrap still accepts `--adopted-only` as a compatibility no-op;
`--no-container` skips resolving the image and leaves its availability to later
physical steps. It does not change the adopted runner into a native runner.

### The legacy path

`protemu check`, `stage`, `legacy-harden` and `precheck` use committed P0 RTL and
hand-maintained `asic/tinytapeout/info.yaml`/`src/config.json`. Explicit
`./scripts/bootstrap.sh --legacy-project` stages/configures this input under
`_flow_results/legacy/p0-staged`. The stage lock is
`_flow_results/legacy/.stage.lock`; legacy logs are under
`_flow_results/legacy/logs`, and preserved prior legacy runs under
`_flow_results/archives/legacy`. Normal bootstrap does not stage it. These are
different inputs from the adopted bundle, even where they share checking tools.

## Verified behavior and known limits

**Current layout checks, 2026-11-11:** the relocated orchestration passed 17
stub-only checks, including caller-relative overrides and root discovery.
Activation and canonical source/bundle preservation were checked separately.
The wider functional/RTL regression is nonphysical verification. This migration
did **not** provision tools or rerun P&R, physical precheck or gate-level
qualification. Generic synthesis is not mapped/physical closure.

**Historical physical qualification, recorded by 2026-09-20:**

- P0.5b ran the observable design end-to-end with LibreLane signoff, TT precheck
  and gate-level simulation. It used modified/untracked inputs and cannot be
  restored from `source_revision` alone.
- P0.5c reproduced the observable result from committed protemu `8d3ada1` with
  locked ASIC `a257424` in an isolated prefix. Its complete preserved input bundle
  was independently restored/revalidated. This is the last recorded full
  clean-staging physical qualification, not a fresh qualification of the present
  loader production top or relocated tool/runtime defaults.
- P0.7's memory result completed mapped synthesis only; it is not routed closure.
- The older orchestration record reports 14 stub checks. The relocation added
  three relative-override checks; today's count is 17.
- Historical setup/preflight and alias checks remain evidence of their recorded
  source/environment, not proof that the relocated environment was reprovisioned.

Old recorded spellings map as follows; these are **historical names**, not current
quickstart commands:

| Historical root path | Current root path |
| --- | --- |
| `./flow.sh` | `./asic/flow.sh` |
| `./bootstrap.sh` | `./scripts/bootstrap.sh` |
| `source env.sh` | `source scripts/env.sh` |
| `tinytapeout/scripts/` | `asic/tinytapeout/scripts/` |
| `bin/asic_bundle.ml` | `asic/cli/asic_bundle.ml` (CLI), `asic/project/chip_project.ml` (declaration) |

Real failed/interrupted-run reporting and current-top physical closure are not
established by stub paths or historical observable results. The archived records
retain their original limitations and missing checks.

## History

[flow_migration.md](flow_migration.md) records the earlier interface migration.
Its commands/evidence are historical; use this document for today's paths.
