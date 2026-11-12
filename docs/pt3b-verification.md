# PT.3b — real-system vendor-functional regression

## Accepted scope — 2026-11-12

PT.3b emitted-RTL functional verification is complete against Protemu base
`6f1b235`, with the captured test worktree changes, private ASIC revision
`b0b3384acbe22c8a30264cbdf0c19008c58bf3c5` and clean PDK revision
`2bbec755dc67ca3db0261c3d6163e15735d66710`. Production hardware and vendor models
were not modified. PT.3c implemented-netlist and physical/timing acceptance remain
separate; these are functional, not timed/SDF, simulations.

## Run

From the Protemu checkout with the [PT.3a private dependency](pt3a-adoption.md):

```sh
flock ../.protemu-build.lock \
  bash scripts/with-private-asic.sh dune build -j1 @pt3b
```

This explicit opt-in alias is not part of ordinary `runtest` or the existing
Yosys/physical-flow aliases. It emits fresh bundles, runs 15 harness tests and
executes host Icarus functional simulations. Child commands are serial, with
120-second emission/compile limits and 300-second replay limits. The runner does
not invoke nested Dune, Docker synthesis, or physical EDA.

The default PDK is sibling `hardcaml_asic/.toolchain/pdk`; `PT3B_PDK_ROOT` overrides
it. The runner requires the recorded clean revision and exact model hashes. Shared
process collateral symlinks are allowed only within that verified PDK checkout.
Every invocation creates a new `_flow_results/pt3b/<timestamp>-<id>/` directory.
`PT3B_EVIDENCE_DIR` can select a new evidence directory explicitly. Old output is
never overwritten; failed attempts remain failed.

## Matrix and evidence

For each production memory and loader design, fresh Flops and Exact bundles are
emitted twice and every output byte is compared. Each is replayed using its
behavioral source role and its implementation source role, making eight runs.
The ninth run uses the real loader/core with an external contract RAM, varying
only unspecified outputs and initial storage across zero, ones and X.

| Positive replay | Observations | Execution-time refusals | Pending cancellations |
| --- | ---: | ---: | ---: |
| Memory: each of four source roles | 26 | — | — |
| Loader: both behavioral roles and Flops implementation | 14 each | 6 each | 0 |
| Loader: Exact implementation | 18 | 6 | 4 |
| Loader: external contract RAM, three policies | 54 | 18 | 12 |

Every executable also performs a deliberate expected-data comparison flip. All
nine negative runs reach `PT3B EXPECTED_MISMATCH`, exit 1 and omit the positive
completion marker. This proves oracle sensitivity; it is **not DUT fault injection**.
Compilation errors, timeout and unrelated failures cannot satisfy that check.

The actual vendor model is selected from the emitted manifest's functional-model
references, snapshotted unchanged, and compiled with `FUNCTIONAL`. The synthesis
black-box stub is never used as an executable model. Exact implementation observes
the real `hc_resource_7_program` ports. Its final loader run recorded **4,787 reads
and 51 writes**, in the same run that completed all scenarios.

Model SHA-256:

```text
RM_IHPSG13_1P_256x16_c2_bm_bist.v
645c475787b077da4dbd15856c68bbae46aa9846a155239eb895ed2de7511053

RM_IHPSG13_1P_core_behavioral_bm_bist.v
d0a6258f8e9c93d1d5b1f78c0a1d66f30d28b1ad8037e5e07f53d1a4e3670b12
```

## System assertions

- Real serial load, verification, readback and instruction/extension fetch, with
  independent expected responses and architectural effects.
- Incomplete, unverified and mismatching-image rejection; immediate replacement
  invalidation; shorter-image tail protection and address bounds.
- All six execution-time host request classes rejected, with storage preserved;
  ABORT remains accessible.
- Genuine blocking core stall, stable status and recovery.
- Disable preserves a completed image and releases outputs; reset invalidates it.
  Disable also cancels an accepted partial-load session without reviving its image.
- Exact and external-contract runs witness a RAM read before cancelling pending
  READ/FETCH by reset or disable. Settled-cycle ready/data/pin outputs are checked
  every cycle over four cancellation plus twelve recovery cycles, followed by
  status/PC and fresh-operation checks. This proves system-visible cancellation,
  not the absence of every internal transient pulse.
- Unknown RAM enable/address/operation and write data reject. Raw RAM output may
  remain unknown when unowned. Serial ready/response checks are four-state aware.
- Contract-RAM policies are explicitly initialized and checked. Defined reads retain
  latency one and disabled output holds. Checked responses and sampled architectural
  pins agree item by item across zero, ones and X; all three diagnostic digests are
  `bb726429`. Digest equality alone is not the acceptance oracle.

## Final receipts and independent review

Accepted full gate:

```text
_flow_results/pt3b/20261112T025223Z-e25bdb2e69a6/receipt.json
```

Nine positive replays, nine negative self-checks, 15 harness fixtures and final
source/provider/model stability checks passed. Evidence retains complete bundles,
source and model snapshots, tools/argv/environment, raw logs, identities and hashes.

Official legacy Verilator core, behavioral-package and Flops-package regressions
also passed, preserving the exact legacy phase assertion:

```text
_flow_results/pt3b/legacy-20261112T025437Z-8deba240399a/receipt.json
```

Both final receipts match the current loader bench SHA-256:

```text
ec9668b02dfa7be9da115078cdc75a5ad034d73ad2e8147f41108a5b6205d93f
```

Independent read-only review checked these source identities, actual compile lists,
vendor-runtime counters, raw logs, negative failure location and all prior review
fixes. Earlier failed/superseded attempts remain retained, including PDK symlink
admission and source-change-during-run failures. A fresh PT.3a gate also passed
during this work. Ordinary `runtest` was not rerun for these opt-in bench-only changes.

All builds/Verilator compilation used `-j1` and the shared Protemu lock. No physical
EDA, dependency reinstall, Git staging, commit or push occurred. No claim is made
that these bounded passes resolve the host's previously observed hardware faults.

## Next: PT.3c

Choose reviewed Protemu-specific macro placement and timing intent, implement the
actual macro-backed system, then replay its final netlist with the functional macro
model and retain timing/check outcomes. PT.3a still rejects Exact Hardening without
that physical intent. Example timing evidence is not Protemu physical acceptance.
