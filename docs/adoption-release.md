# Normal ASIC/Workbench adoption — 2026-11-12 closeout

## Result

**Normal installed tooling is complete in the accepted scope below.** Protemu
builds against a checked local installation, exposes public named flows and
preparation, runs real simulation cases in Workbench, and displays a large retained
negative timing result with validated provenance. Existing failed evidence was
preserved. This is not a claim of Protemu timing closure or full physical acceptance.

## Everyday commands on this machine

From the Protemu checkout:

```sh
source scripts/env.sh
flock ../.protemu-build.lock dune build -j10 @all
flock ../.protemu-build.lock dune runtest -j2

bash scripts/workbench.sh status
bash scripts/workbench.sh daemon
# In another terminal:
bash scripts/workbench.sh client
```

Activation selects the local prefix's ASIC libraries and Workbench executables.
It validates installed hashes and fails closed on missing/changed state. Failed
interactive activation clears owned old paths/exports and installs temporary
command guards; successful activation removes them. Do not ignore activation
failure and assume the shared switch has a compatible API.

Public project examples, without launching EDA:

```sh
bash scripts/project.sh flow list --json
bash scripts/project.sh flow describe --flow stock_sram --json
bash scripts/project.sh flow plan --flow stock_sram --endpoint timing --json
bash scripts/project.sh prepare --flow stock_sram --json
```

Flows are `flops` and `stock_sram`. `balanced` is the unchanged default profile;
`timing_repair` is opt-in for `stock_sram`, with only
`RUN_POST_GRT_RESIZER_TIMING=true` added. The normal path uses public project/provider
interfaces rather than the legacy `asic/flow.sh` defaults. Plans/bundles bind actual
source and choices; recompute previews after edits.

## Fresh installation and explicit refresh

Required base compiler/dependencies remain in switch `5.2.0+ox`. The local installer
checks/builds independent source captures and installs a new private prefix without
changing shared opam packages. ASIC's timing-reader and physical-runtime fixes are
committed in `4b6bb60562c0133db9e3ccc6b183736e5658a3f0`, now the normal lockfile
pin. Workbench remains an explicit working-tree capture:

```sh
python3 -B scripts/install-tools.py \
  --asic-source ../hardcaml_asic \
  --workbench-source ../hardcaml_workbench
source scripts/env.sh
bash scripts/workbench.sh configure --toolchain-root /absolute/verified/toolchain
bash scripts/workbench.sh prepare-simulation --pdk-root /absolute/verified/toolchain/pdk
bash scripts/workbench.sh configure --simulation
bash scripts/workbench.sh status
```

On this machine the verified toolchain root is
`/home/wayne/devel/jane/hardcaml_asic/.toolchain`. It is selected in place, not copied
or silently reprovisioned. Status distinguishes metadata readiness from actual
physical preflight/execution. Physical runs use the supported tool6/Docker CPU6/STA1
profile; builds and simulations are not run concurrently with that EDA allocation.

`bootstrap.sh --tools-only` uses the same committed `pinned_revision` from
`tools-source.lock.json` (`4b6bb60`); `compatibility_base_revision` remains `3335f47`
as the compatibility baseline, not the source selector. For subsequent uncommitted
ASIC development, explicitly add `--asic-source-mode working-tree` (or
`--development`). Base HEADs alone do not reproduce dirty source captures: receipts
retain the full bytes, hashes and dirty attribution. No P6 compiled-source stamp is claimed.
Updating the default pin does not refresh the installed generation or requalify it;
the accepted snapshot and source hashes below still identify the original captures.
The historical `asic/tinytapeout/asic-dependencies.lock` and PT.3a private prefix
remain historical evidence, not the selector for the normal installed compiler.

Installed selectors, manifests and `.workbench/` companions are local machine state.
Existing owned configuration is backed up on refresh; unknown edits are rejected.
Changing the tools prefix makes status report `configure_required` until companions
are updated. Simulation refresh validates the old generation against its own sealed
catalog, qualifies the new complete catalog, and only then publishes it. Old
generations, failed installs and failed test attempts are retained.

## Accepted installed snapshot

```text
Tools: .dev/tools/generations/f88b8d44e7524aa3862fc163d2e2baec/prefix
Simulation: .dev/workbench/simulation/generations/64971bc2ad2945ecbd1994ccb955d41f
ASIC source tree: 53b2bdaf02ee12fe43269cc0a9c1059e89720084ce0614003347ea57c8aa255e
Workbench source tree: a8e87a3885720f227c5d5d153ccb684492ccc7eb9d6e7534c24fa7ad522f5b2d
```

Both tools are explicit captured-working-tree builds. Independent review checked
846 ASIC and 759 Workbench files against captured/installed snapshots, installed
inventories and selected-generation consistency. Subsequent documentation edits
describe those exact accepted captures; they do not replace their recorded hashes.

Final release evidence:

```text
_flow_results/workbench/releases/714edccf3d934c1b99ce50c6930c7948/
  closeout.json
  asic/ and workbench/                 frozen sources and qualification proofs
  installed-reinspection/             installed CLI/service verification
  normal-installed-journey-a49f737a4ee6440690cff2e93370451d/
  final-normal-status.json
```

## Simulation and workload acceptance

Testing exposes four serial-system cases (Flops/Exact × behavioral/implementation)
and three event-response cases (behavioral, Flops, Exact). All seven passed the
final installation's actual qualification. No build occurs in discovery/execution;
the installation captures prebuilt emitters, sources, models and checker identities.

Serial cases execute the real loader package, bind `fixed-loader-v1`, and retain
the PT.3b oracle, positive transcript, full VCD and negative-comparison self-check.
A labelled first-100-µs byte prefix is available for the embedded waveform viewer;
the full VCD remains separately available. Benchmark assertion failure is semantic
`Failed`; tool failure/malformed output/timeout is incomplete, not a fake DUT fail.

The event workload composes the real **core+Program_memory**, loaded through the
direct control port. It explicitly excludes the serial host link/package wrapper
and does not claim a loader bundle association. Six writes and six verification
reads precede accepted RUN. All ten external phases retain raw timestamps and VCDs,
checked against the independent event-response oracle and model/image semantics.

Measured phase0…9 response ticks, in all three configurations:

```text
60, 69, 68, 67, 66, 65, 64, 63, 62, 61
```

This is 6–6.9 periods under the 10-tick simulation clock contract. Flops/Exact
comparison has ten zero deltas with controlled assignment, sampling and tool/source
identities. The independent software model's 13-cycle schedule is a different
measurement and is not compared as a speed result. Artifacts are generic
`protemu.event-response-result` JSON and VCD, **not** ASIC's memory-only
`Workload_result`. Whole-package physical/performance selection is not inferred.

Actual public RPC execution and production PTY navigation/viewing verified real
attempts, serial/event waveforms and comparison readback. Simulation launches in
that acceptance used RPC; PTY input covered navigation and viewing. Live cancellation
probes observed serial VVP and nested event-provider/producer/native-emitter children;
both finished `Cancelled / Incomplete`, with recorded PID/start identities reaped.
The complete producer result directory must remain available for evidence reinspection;
a copied JSON artifact alone is not a portable closure.

Standalone producer evidence: `_flow_results/pt8/qualification-01/receipt.json`.
All 33 HDL replays (three configurations × ten phases plus calibration), 33 VCDs,
1,584 captured edges and three model executions passed. Public compare correctly
withholds implementation deltas for behavioral-versus-implementation control pairs.

## Physical candidate and tooling defect recovery

The real production TUI launched exactly one new `stock_sram/timing_repair` prefix
through Timing. No hardware/cycle changes or constraint relaxation occurred.
Run `b591d335b32a49b8a019739ef7044e4e` completed all six stages; final extracted STA:

| Metric | Original separate candidate | Timing-repair candidate |
| --- | ---: | ---: |
| Slow setup slack | −4.0586 ns | **−3.0998 ns** |
| Setup TNS | −1025.2167 ns | −681.6674 ns |
| Setup violations | 503 | 444 |
| Worst hold slack | +0.0705 ns | +0.0678 ns |
| Hold / slew / capacitance violations | 0 / 0 / 0 | 0 / 0 / 0 |

Post-GRT repair loaded all three corners, added four setup and nine hold buffers,
resized two instances and made one pin swap. It helped but did not close timing.
Physical evidence: `_flow_results/workbench/physical-timing-repair/5835fa53371044c484e1ec59af1ac25d/`.

The larger STA logs exposed the old collector's line-count limit. The new reader
streams hashes/metrics in 64 KiB chunks, caps individual lines at 16 KiB, reports at
32 MiB and aggregate reports at 256 MiB, and retains duplicate/malformed/binary and
mutation checks. Actual metric at line280760 and violation count at281247 now parse.

Explicit read-only reinspection:

```sh
hardcaml-asic-flow inspect "$EXECUTION" \
  --domain timing --stage timing --refresh-timing --json
```

It provides new source/analysis digests and original-observation lineage. Workbench
negotiates `timing_reinspection1`, validates that lineage and digest-fences details.
Actual installed UI exposes **193 bounded rows**, including a **−3.099803 ns** path,
and labels **original unavailable/unknown; recomputed completed/fail**. The index
is explicitly truncated (32 sampled paths per report), not exhaustive path coverage.
All 28 protected observation/execution/journal files remained byte-identical.
Successful query/collection does not mean a passing timing goal.

## Magic follow-up

On the original coarse run `0d5ed7ff`, four serial controls reproduced exact marker
multisets: stock9, M2-wide-OBS-removed7M3, M3-wide-OBS-removed2M2, both removed0.
Only the witnessed local short-overlap/boundary geometries received narrow coverage,
bound to exact stock identity, intact reader/deck/run inputs and complete controls.

The independent separate-record physical-profile recheck passes, with raw Magic
count9 retained and original failed run untouched. Production controls remain
300 seconds/case; this diagnostic explicitly used480 seconds. Its control coverage
is not blanket acceptance or a promise that future full runs cannot time out.
See `_flow_results/pt3c/magic-controls-0d5ed7ff-20261112-02/` and
`magic-recheck-0d5ed7ff-20261112-01/`.

## Nine-part status: generic capability versus Protemu obligation

| Item | Current disposition |
| --- | --- |
| PT.0 | Complete in bounded example scope; original probe failures preserved |
| PT.1 | Required stock Exact backend complete; timed-model work optional/deferred |
| PT.2 | Stock/R0 library/example physical scope complete; Protemu Magic recheck passes separately |
| PT.3 | Normal adoption, system regression and routed functionality pass; **Protemu setup timing/full physical acceptance remain open** |
| PT.4 | Normal installed preparation and exact resource inventory pass |
| PT.5 | Public reporting/inspection works; historical failed coarse record still cannot prove all stage/retention/resource measurements |
| PT.6 | Normal installed Resources UI and bounded typed negative Timing reinspection pass |
| PT.7 | Constraint review identifies real topology/IO limits; ordinary STA works, **Protemu-specific linked exceptions/physical timing adequacy remain open** |
| PT.8 | Fixed loader association and controlled core+RAM functional comparison pass; **whole-package performance/physical selection remain open** |

The old `0d5ed7ff` reader reports unresolved realization because its failed record
does not establish completed producer boundaries. Aggregate macro count1 or
whole-design standard-cell area is not substituted for verified resource attribution.
Evidence: `_flow_results/adoption-resources/inspection-01/`.

No extra register/cycle, frequency reduction, generated clock or blanket false path
was introduced. A future pipeline revision would require an explicit update of the
cycle-exact architecture/model/protocol evidence; it is not a hidden release fix.

## Final checks and remaining release qualifications

Final normal `dune build -j10 @all`, cache-aware `dune runtest -j2`, `@pt3a`, and
`@scripts/project-cli @scripts/timing-profile` pass. ASIC/WB captures passed their
required suites before selection. Independent review found no blocking defect in
the accepted normal installation, resource, simulation, cancellation and retained
timing-inspection paths. All owned daemons/clients/children stopped; no EDA remains.

This does not qualify every future backlog item, multi-macro profile, full signoff,
P6 compiled-source stamping, platform portability or unsupported linked exceptions.
The owner subsequently committed/pushed ASIC as `4b6bb60` and Protemu as `edbcee9`;
Workbench still has uncommitted tooling changes. The normal ASIC selector now uses
that committed revision; the retained acceptance evidence above remains tied to
its original working-tree captures. No Git staging, commits, pushes or authorship
changes were performed by the agent during the closeout or this selector update.
