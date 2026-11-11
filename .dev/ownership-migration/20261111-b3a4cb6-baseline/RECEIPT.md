# Ownership migration: pre-move baseline receipt

Baseline revision: `b3a4cb6a420613465f635a616bedba967c4ab307`.
Repository: `/home/wayne/devel/jane/hardcaml_protemu`.
Evidence root: `.dev/ownership-migration/20261111-b3a4cb6-baseline/`.

The initial read-only status check was clean before this evidence directory was
created. `initial-status.txt` is the subsequent recorded status (including the
capture helper itself); `initial-diff.patch` records tracked differences at snapshot
time. This task owns baseline capture only. Documentation is owned by the parallel
coordinator. Workspace `AGENTS.md` and Protemu architecture-migration, verification,
serial-host-pilot, formatting, and flow instructions were read.

## Immutable source and dependency inputs

- `source-snapshot.tar.gz` and `source-snapshot.json`: every tracked file's bytes,
  relative path, SHA-256, and size before any builds or moves. Includes all hardware,
  software, fixtures, independent models/peers, inline expectations, golden traces,
  source registrations, scripts, locks, and historical evidence.
- `frozen-oracle.json`: focused hash inventory of the frozen HL4a archive and its
  formatting exclusion. Oracle contents also reside in the full source snapshot.
- `registrations.tar.gz` / `.json`: Dune, opam, lock files, and CI declarations.
  `test-registrations.json`: file/line/text inventory of inline test registrations.
- `installed-apis.tar.gz` / `.json`: installed Hardcaml-family ML/MLI and package
  metadata bytes/hashes. `installed-hardcaml-files.json` additionally fingerprints
  all installed Hardcaml-family files, including compiled artifacts.
- `logs/opam-packages.log`: actual installed package versions; this is the authority,
  rather than sibling source checkouts. `logs/opam-switch.log` records switch prefix.
- `existing-build-outputs.tar.gz` / `.json`: relevant pre-existing `_build` outputs
  preserved before baseline execution. No clean was performed.

## Execution and compatibility

`capture.py` snapshots and runs the baseline; `finalize.py` derives inventories and
adds standalone core generic-synthesis statistics. All heavy work is sequential
under an exclusive `fcntl.flock(..., LOCK_EX)` on
`/home/wayne/devel/jane/.protemu-build.lock`, interoperable with the shared shell
`flock` lock. Process inventories were checked before execution and after acquiring
the lock; no other heavy build job was active. Dune uses the documented five-job
budget; existing Verilator rules use their own single-job compilation setting.

Primary commands:

```sh
opam exec --switch=5.2.0+ox -- dune build @install @lint -j5
opam exec --switch=5.2.0+ox -- dune runtest --force -j5
opam exec --switch=5.2.0+ox -- dune build @rtl --force -j5
```

Install/lint may reuse valid Dune results; ordinary regression and RTL aliases are
forced. Every command, actual argv, working directory, timestamp, elapsed time,
return code, and log path is in `commands.jsonl`. `result-summary.json` is the
machine-readable outcome summary once finalization completes.

Installed `hardcaml_asic` is `0.1.0`; its installed `bundle.mli` has SHA-256
`dcadee4fa32c0ab704dd3f395170a00c95002385b78ce5aa9190eb83f0dd273a`
and exposes the `simulation_build` parameter consumed by the baseline emitter.
See `tool-compatibility.json` and `logs/version-*.log`. Host tools include Icarus,
VVP, Verilator 5.020, Yosys 0.33 (`2584903a060`), and C++.
The current switch/API was used throughout; no dependency activation or upgrade
was performed.

## Outputs retained for migration comparisons

- `generated/`: fresh explicit-output generation of observable, all four core
  selectors, all ten P2 selectors, and both program-memory backend roles (17 RTL
  files). Exact invocations are recorded in `commands.jsonl`.
- `bundles/{observable,memory,loader}/`: complete fresh bundles, including both
  synthesis and simulation source roles, manifests, copied inputs, identities,
  resource selections, configuration, pin metadata, constraints, and requested
  tool identities. Bundles are also archived in `bundle-outputs.tar.gz` / `.json`.
- `logs/bundle-check-*.log`: existing metadata-only checker, including conflict
  checks and independent double-emission repeatability; `logs/retained-metadata-*`
  checks the actual persistent bundles with the existing checker implementation.
- `logs/compile-*`, `logs/simulate-*`, and `logs/lint-*`: host-tool checks on both
  observable and memory bundle source roles, plus lint of both loader roles.
- `logs/rtl.log`: existing emitted-RTL tests, including all three independent
  loader-peer configurations (external contract RAM, behavioral package RAM,
  implementation package RAM). `loader-tested-bundle-comparison.json` compares
  the persistent loader bundle RTL bytes to the wrapper sources tested by Dune.
- `baseline-build-outputs.tar.gz` / `.json`: generated HDL, trace/golden outputs,
  relevant metadata and logs from the final `_build` state; the fresh explicit
  emitter outputs are also in `generated-outputs.tar.gz` / `.json`.
- `synth-*.json`, `logs/synth-*.log`, `synthesis-inventory.json`: exact same-host-tool
  generic `yosys synth` statistics, including per-type cell counts, for every
  bundle/source role and the four standalone core selectors.
- `rtl-interface-inventory.json`: per-source hash, emitted module names, ordered
  port names, widths/directions, register declaration counts, and always counts.
- `root-loader-history.txt` and `root-loader-references.json`: provenance and
  consumer/reference inventory for the tracked root `loader_core.v` snapshot.

## Comparison strategy and handoff

1. Re-run the recorded selectors/options using the same installed switch and tools.
   Check source hashes first; preserve every frozen archive file byte-for-byte.
   Map moved registrations one-to-one using the raw Dune files and inline-test
   inventory. Existing endpoint/agent/scoreboard ownership and oracle expectations
   are baseline inputs, not replacement implementations.
2. Compare generated RTL bytes/SHA-256 first. For nonidentical files, compare module
   names, ordered ports/widths/directions, then logic/state construction and exact
   same-tool per-type synthesis counts. Investigate every nonzero cost delta.
3. Compare both bundle source roles independently. Compare configuration, timing,
   pins, resource policy/selection and source roles as semantic values. Manifest
   identities and copied input paths/hashes are expected to change when files move;
   enumerate those changes rather than normalizing away hardware differences.
4. Preserve forced ordinary regression, exact-cycle endpoint and frozen HL4a
   expectations, and all three independent HDL peer tiers. Bundle wrapper results
   can be tied to the persistent loader bundles by the recorded byte comparison.
5. Generic synthesis is a resource/cost baseline, not mapped/P&R or physical signoff.
   No new formal-equivalence result is claimed. Historical HL4/AM acceptance remains
   historical context in the snapshotted docs.

`final-source-comparison.json` verifies tracked input preservation separately from
coordinator documentation changes and checks the Git index hash. `final-status.txt`
identifies persistent untracked evidence. `evidence-sha256.json` inventories evidence
bytes at finalization time. No Git add/commit/push/config operation was used; no
source references or sibling files were edited. No flow/default execution or
tracked-RTL staging script was invoked.

## Results

| Check | Exit | Seconds |
| --- | ---: | ---: |
| build-install-lint | 0 | 0.885 |
| ordinary-runtest | 0 | 17.643 |
| rtl | 0 | 494.434 |
| bundle-check-observable | 0 | 0.115 |
| retained-metadata-observable | 0 | 0.036 |
| simulate-observable-synthesis | 0 | 0.005 |
| lint-observable-synthesis | 0 | 0.044 |
| synth-observable-synthesis | 0 | 0.115 |
| simulate-observable-simulation | 0 | 0.006 |
| lint-observable-simulation | 0 | 0.045 |
| synth-observable-simulation | 0 | 0.114 |
| bundle-check-memory | 0 | 0.156 |
| retained-metadata-memory | 0 | 0.038 |
| simulate-memory-synthesis | 0 | 0.018 |
| lint-memory-synthesis | 0 | 0.093 |
| synth-memory-synthesis | 0 | 3.816 |
| simulate-memory-simulation | 0 | 0.007 |
| lint-memory-simulation | 1 | 0.056 |
| synth-memory-simulation | 0 | 1.849 |
| bundle-check-loader | 0 | 0.636 |
| retained-metadata-loader | 0 | 0.044 |
| lint-loader-synthesis | 0 | 0.56 |
| synth-loader-synthesis | 0 | 19.851 |
| lint-loader-simulation | 1 | 0.425 |
| synth-loader-simulation | 0 | 17.405 |
| synth-core-access | 0 | 0.301 |
| synth-core-executable | 0 | 3.275 |
| synth-core-integrated | 0 | 6.15 |
| synth-core-loader | 0 | 12.91 |

Failures: lint-memory-simulation, lint-loader-simulation.

Both additional simulation-role lint commands exit 1 because Verilator 5.020
reports `INITIALDLY` for the existing behavioral RAM's nonblocking initial-block
assignments (256 warnings per role). The exact diagnostics are retained in
`logs/lint-memory-simulation.log` and `logs/lint-loader-simulation.log`. No RTL or
warning options were changed to make these checks pass. The existing `@rtl`
loader simulations already use their documented `-Wno-INITIALDLY` option and pass;
these supplemental lint invocations intentionally retain their actual failure.

Captured: 356 tracked files, 475 inline-test registrations, 17 explicitly generated
RTL files, and six bundle/source-role combinations. The full source snapshot
includes the endpoint suite, both pilot agents, their fixture and scoreboard, and
the frozen oracle. All tracked files and the Git index were unchanged at finalization.

Tracked non-documentation changes: [].
Persistent/tested loader RTL role comparisons: [True, True].

Baseline capture and comparison inventories are complete; ready for ownership-migration agents.
