# Final review addendum — formatting closure, 2026-11-11

**Clearance: no implementation/correctness blocker remains. All seven introduced
formatting findings from the original receipt are closed.** The original findings
and receipts remain unchanged as historical evidence.

Reviewed `package-tooling-format-post/RECEIPT.md`, its commands, scoped checks,
format-backlog classification, current source hashes and refreshed manifests/output
inventories. Ran only `addendum-check.py` in this directory; it performs read-only
file/hash comparisons and writes this directory's new validation report. No heavy
build/test, formatter, EDA, flow, dependency activation or Git mutation was run.

## Closure and current-source identity

- Each of the seven current files exactly matches the new receipt's SHA-256.
  Reversing the original review's proposed formatting diff reconstructs the exact
  original reviewed bytes for each file. There are no additional non-documentation
  implementation changes since that review.
- All seven scoped format checks passed in the new recorded run, and fresh
  `@install @lint` passed. The remaining global `@fmt` result comprises exactly
  **23 files**, each independently rechecked as a byte-identical mapped baseline
  file; introduced failures: **zero**.
- Recompared all **17 fresh generated RTL outputs** and **six fresh bundle roles**
  directly against baseline bytes. All match. Bundle pin/config/constraint/resource
  metadata match. All declared file hashes and copied current source inputs verify.
- Current inventories contain **11 observable, 12 memory, and 44 loader inputs**.
  Per kind, exactly four source-input hashes changed from the pre-format bundle:
  `bin/asic_bundle.ml`, `chip_top/project/dune`, `lib/dune`, and the selected package
  design. Path inventories are unchanged. TT test-rule formatting is not a bundle
  source input. The refreshed identities match the coordinator documentation:
  - observable: `bac91a5ec1b121f92003aa5831ba1a598e3f5018d16eca745ba929e56ad4da61`
  - memory: `c5447c5b949e36e2bd62a496e7785e21e0c90d6252d3620208fcd6e29d796047`
  - loader: `6aa524a6212878dc73b19bf788ca7b6b2d75a35fe238084bd7fb826a0836612b`
- Original independent findings for **26 RTL sources, 475 registrations, eight
  frozen files, installed flat interfaces, selected source closure, ASIC/model
  separation and runtime script paths** remain valid: none of those implementation
  inputs changed except the exact reviewed formatting diffs.
- Prior six-role same-tool synthesis comparisons and passing ordinary/three-tier
  emitted regressions remain applicable to identical emitted bytes. They were not
  rerun or represented as fresh EDA results in this follow-up.
- Git index SHA-256 still equals the original baseline. All **2492** installed
  Hardcaml-family hashes match. Independently checked **46 historical files and
  outputs**, including historical/physical receipts, dated TT reports, root
  `loader_core.v` and committed TT RTL; all match.
- Coordinator changes to root README/index/layout/architecture/phase/verification/
  serial-pilot/formatting documents are intentional documentation updates. They are
  not required to match the original 356-file source snapshot.

Machine-readable evidence: `ADDENDUM-validation.json`. Reviewed documentation
hashes are recorded in `addendum-current-doc-hashes.json`.

## Documentation accuracy notes (nonblocking)

Two small inaccuracies were reported to the coordinator without editing docs:

1. `docs/ownership_layout.md:102` says “No dependency upgrade, EDA/P&R … occurred.”
   Generic Yosys synthesis and emitted-RTL HDL simulation did run. Spell this as
   “no dependency upgrade, physical implementation/P&R …” to avoid implying that
   no EDA verification tools ran.
2. `docs/repository_layout.md:101` calls the active archive
   `verif/archived/hl4a`; the full owner path is
   `ip/host_link/verif/archived/hl4a` (already correct elsewhere in that guide).

Other current-status claims are consistent with the inspected implementation and
receipts: owner acceptance remains pending; protocol/Codec, grouped-interface,
wider VO and newer ASIC API/SRAM work are not claimed complete; the P0 core tests
are distinguished from package-peer checks and the memory bench's explicit
activation is not presented as default `@rtl` execution.

## Precise remaining baseline limitations

- **23 baseline-preserved formatting failures** remain; the global formatter is
  not passing, despite all introduced formatting failures being resolved.
- The two supplemental **memory/loader Simulation-role lint failures** remain
  baseline `INITIALDLY` warning-policy results. They do not invalidate the passing
  existing HDL simulations, whose documented options differ.
- Generic synthesis/RTL identity is not mapped/P&R, physical timing, CDC/analog,
  unrestricted reset equivalence or a new formal proof. The original pre-AM1/AM2
  dirty-tree evidence and historical loader formal-equivalence gaps are not
  reconstructed or closed by this new baseline.
- Broader AM3/AM5/AM6 acceptance, VO continuation, and PT.3 newer ASIC API/Exact-SRAM
  adoption remain separately scoped owner decisions/work, as documented.
