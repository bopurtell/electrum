# Independent integrated-source review — 2026-11-11

## Decision

**No functional/correctness blocker found. Changed-file formatting is not yet
clear: seven introduced formatting failures remain, listed below.** This is an
independent review of the integrated sources against
`b3a4cb6a420613465f635a616bedba967c4ab307` and the retained pre-move baseline;
the reviewer implemented no migration sources. Authoritative documentation is
being edited concurrently and is outside this review's incomplete-guide judgment.

## Independent preservation results

`review.py` recomputes these comparisons from the immutable baseline tar and the
current filesystem, rather than accepting the agents' boolean claims:

- All **26** hardware implementations are byte-identical at their owner paths;
  old authored implementations are absent and each has one authored RTL owner.
  `lib/dune` supplies build-tree copies only. See `hardware.json`.
- All **475** registrations match by mapped suite path and exact declaration text;
  every module containing a registration is byte-identical, including its full
  assertions and expectation bodies. All **34** existing test/fixture/agent library
  stanzas retain their module/dependency/wrapping/inline-test definitions after
  splitting common libraries. See `registration-summary.json`.
- All **eight frozen files** match, including the archive Dune declaration and
  `.ocamlformat-ignore`. The endpoint fixture, scoreboard, serial agent and
  Control_port agent retain their source implementations. Four focused diagnostic
  helpers only preserve historical exception atoms; Replay's mapping is restricted
  to redacted fixture presentation. Live Replay paths/rerun commands remain current.
  Exact support-file deltas are saved as `*.diff`.
- All **17** generated RTL outputs and **six** bundle source roles match baseline
  bytes. Package pins, timing constraints, config, metadata, selected resources and
  requested tools match. Current bundle copied inputs match actual current sources;
  declared bundle file hashes verify. See `generated-rtl.json`, `bundle-roles.json`.
- All six actual post-move generic-synthesis results have the identical Yosys creator
  identity and identical complete design statistics, including per-type cell counts.
  Totals (simulation / synthesis): observable **62 / 62**, memory **9211 / 13550**,
  loader **22536 / 26814**, with zero baseline delta. The four standalone core RTL
  inputs are also byte-identical; no new standalone synthesis run was claimed or
  performed during this review.
- The eight independently authored emitted benches match baseline bytes. The
  three existing loader tiers and their execution chain remain registered, using
  the external memory model, package Simulation RAM, and package Implementation
  RAM respectively. Root `loader_core.v`, committed TT RTL, golden traces, pure
  models, ISA, protocol library, pure tests, historical records and archived physical
  results remain unchanged. See `emitted-benches.json`.

## Correctness and integration inspection

- Installed build-tree package contains all 26 public flat module aliases, source
  `.ml` files and compiled `.cmi` interfaces. No baseline hardware `.mli` existed to
  preserve; no explicit interface was silently dropped. See `package-api.json`.
- Reusable `hardcaml_protemu` stays independent of `hardcaml_asic` and the separate
  private `protemu_chip_project` library. Package constructors have no CLI execution
  side effects. `f_model` still depends only on `core` and pure `protemu_isa`.
- Directly inspected `Package_top`, `Program_memory`, both bring-up designs and the
  slim emitter. Reset synchronizer/gating, package pins, memory feedback, clock and
  enable connections, resource name/width/depth/latency, construction order and CLI
  default/selectors preserve the original compositions. Project metadata/pinout/
  timing/resource-policy declaration is text-identical except the intended
  `Loader_design` → `Package_top` module reference; observable construction is
  identical ignoring extraction indentation. See `extraction-controls.json`.
- Installed `ocamldep -modules` closure from each selected design has **no missing
  local source input** in its current manifest. The shared project declaration,
  facade and new package-library Dune source inputs are recorded. Dune RTL rules
  include the new authored source trees. See `manifest-closure.json` and
  `ocaml-source-dependencies.log`.
- Reviewed active runtime script/bench paths: adopted flow postcheck, staged-project
  bench copy, bundle checker loader compiler and Docker test mount, direct/staged
  Makefile fallback, CLI workflow, regression sweeps and diagnostic compatibility
  aliases. `make -n rtl` resolves the chip-owned observable bench. Bash syntax checks
  pass. No flow/default, staging, EDA, Docker or provisioning command was executed.
- All **2492 installed Hardcaml-family file hashes** still match the baseline;
  old installed ASIC API identity is unchanged. Git index SHA-256 matches the original
  baseline. No index/history/configuration writes or sibling edits were performed.
  See `unchanged-environment.json`.

## Formatting finding for the coordinator

Targeted current-source checks, under the shared build lock, identify these **new**
formatting failures, not the frozen/byte-preserved baseline backlog:

| File | Evidence |
| --- | --- |
| `bin/asic_bundle.ml` | `format-bin__asic_bundle.ml.diff` |
| `chip_top/rtl/observable_design.ml` | `format-chip_top__rtl__observable_design.ml.diff` |
| `chip_top/rtl/memory_design.ml` | `format-chip_top__rtl__memory_design.ml.diff` |
| `chip_top/rtl/package_top.ml` | `format-chip_top__rtl__package_top.ml.diff` |
| `lib/dune` | `format-lib__dune.diff` |
| `chip_top/project/dune` | `format-chip_top__project__dune.diff` |
| `tinytapeout/test/dune` | `format-tinytapeout__test__dune.diff` |

`ocamlformat --check` and read-only `dune format-dune-file` comparisons were used;
no formatter modified sources. `chip_project.ml`, `program_memory.ml`, `bin/dune`,
TT source rules, and all three compatibility-alias Dune files pass the targeted
formatting checks. `targeted-formatting.json` contains exact outcomes. Source-format
diffs are whitespace/layout changes. Coordinator/owning agent should format these
seven files and refresh affected copied-input bundle identities as appropriate.
Do not format the frozen oracle or attribute these new failures to its backlog.

The two baseline supplemental simulation-role lint failures (`INITIALDLY`) also
remain baseline context; they are distinct from these formatting findings and from
the passing production `@rtl` tier.

## Checks and evidence use

Reviewed the hardware-owner source/generated reports, verification-post receipt
and exhaustive map, and package-tooling-post command ledger/results. The final
recorded install/lint, forced ordinary regression, and forced RTL run pass; the
earlier ordinary failure is correctly retained as historical and superseded by the
passing `ordinary-runtest-after-owner-fixes` result. Full checks were not repeated.

Commands run by this reviewer:

```text
python3 -B .dev/ownership-migration/independent-review/20261111-final/review.py
python3 -B .dev/ownership-migration/independent-review/20261111-final/controls.py
```

Their source documents all subordinate commands: read-only Git inspection,
installed `ocamldep`, Bash parsing, dry-run Makefile resolution, and targeted
format-only checks. No EDA test, provisioning or dependency activation occurred.
Review-owned files live only in this receipt directory. Current non-documentation
source hashes and tracked diff are preserved in `current-source-hashes.json` and
`tracked-diff.patch` for this review point.
