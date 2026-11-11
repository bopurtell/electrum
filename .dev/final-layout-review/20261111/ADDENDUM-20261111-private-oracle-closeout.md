# Final-layout closeout addendum — 2026-11-11

**Final bounded clearance: no implementation blocker or introduced-formatting
finding remains in the reviewed closeout.** This addendum supersedes the original
receipt's description of a public hardware compatibility facade. The original
receipt, intermediate installation snapshots and findings remain historical and
were not overwritten.

The owner explicitly changed the acceptance boundary: the installed flat hardware
API is now removed. The unchanged frozen oracle receives a private local adapter.
Reviewer implemented neither this change nor the formatting fixes and edited no
authored source. Coordinator documentation remains separately owned/in progress.

## Current installed/private boundary

Read A's `.dev/final-layout/hardware/CURRENT.md`, `private_oracle.py`, raw proof
JSON/logs/command ledger, the exact support sources, current standard install, and
the fresh isolated install referenced by the final proof.

- `software/compatibility/hardware/` is absent.
- `ip/host_link/verif/archived/support/dune` has internal name `hardcaml_protemu`
  but **no `public_name` or install stanza**. Its ML file is exactly the expected
  26 canonical module aliases, with no hardware/function/type implementation.
- Authored dependency closure and namespace scans confine the flat library/module
  to frozen HL4a plus this support directory. No canonical owner, active design,
  non-frozen verification, software, firmware or ASIC closure depends on it.
- Independently parsed both the current standard and fresh isolated installed
  Dune-package files: **13 named installed sublibraries**, no Dune main library
  named `hardcaml_protemu`, and no installed dependency on the private adapter.
  Neither installation contains flat `hardcaml_protemu` module/archive artifacts
  or old `hardcaml_protemu__*` artifacts. All 26 installed owner source files match
  their current authored RTL bytes in both installations.
- Reviewed eight successful canonical Findlib consumer builds/links and eight
  installed-only Dune consumer builds. Their sources import actual canonical
  modules and the final command records use the final isolated consumer directory.
  The isolated configuration excludes `_build` and historical project installs;
  sanitized external dependency directories contain no ambient Protemu package.
- The two actual OCaml negative logs report **Unbound module
  `Hardcaml_protemu`**. The separate installed-only Dune negative reports **Library
  `hardcaml_protemu` not found**. Successful positive controls and expected negative
  exits are present in the final ledger; this is not mere failure to find every
  package in a broken installation.

Precise documentation boundary: the **opam package and Findlib namespace
container** `hardcaml_protemu` still exist for its sublibraries. They do not expose
the removed flat OCaml module or an installed Dune main library. Within this
workspace, the private library name still exists to satisfy the immutable frozen
Dune declaration; current graph use is limited to that oracle. Do not describe
the private adapter as an installed/public compatibility promise, or older `.dev`
installation snapshots as the current API.

The separate **pure wire compatibility facade** remains an independently scoped
AM3 compatibility surface; removal of the public hardware facade does not imply
that the old wire package was removed too. External hardware consumers must use
the canonical owner sublibraries/modules and rebuild; the former flat API is no
longer supported by the installed package.

## Preservation, formatting and fresh input/output correspondence

Independently rechecked with read-only `closeout.py`:

- **26 RTL files** exactly match A's pre-removal hashes; **eight frozen files**
  exactly match their pre-removal hashes. The new adapter does not alter any of
  those eight files. Current registration count remains **481**.
- B's **11** and C's **seven** formatter-pass records bind to the exact current
  source SHA-256 values: all **18 introduced findings are closed**. C's captured
  formatter-of-original checks and current hashes agree; B's expectation-preservation
  and baseline-backlog classification remains recorded. The additional private
  adapter's scoped formatting and fresh install/lint pass are recorded in A's
  current checks. This is scoped closure, not a claim that global `@fmt` now passes.
- Fresh install/lint and the post-removal forced frozen/endpoint/dispatch/core-engine/
  simulator suites exit zero in A's final ledger. No post-removal full EDA run is
  invented; the earlier combined-tree full verification remains earlier evidence.
- All **six fresh C bundle roles** match AM3 bytes. Every manifest contains exactly
  the same **55 canonical source inputs**, all matching current authored bytes,
  copied input bytes and declared hashes. No input references the private or former
  public flat adapter, software, reference-model or historical archive sources.
- Refreshed identities independently match:
  - observable: `1782b66c7121a157abf145ccfe8d3848af7e466ae5a49889fea40f21fd8898a0`
  - memory: `aa5fc077159b64c391f3d49238be3979d3948c384a6249e89fb052c65f7c693b`
  - loader: `9f6b707a6d184b75261330ea88b08ce0b63d834303b895028fdeb8d605a8ee58`
- All **42 historical archive files** retain the original review's hashes and
  modes, including all five opaque tarballs. The external archive index still has
  SHA-256 `9997f07e017fe62fca14e933f6ca718a48a7f47ef4dd7cb5f13d0de3d499d71d`.
  Only archive Dune metadata was formatted; historical contents were not repacked.

## Factual gaps and remaining limitations

No unaccounted implementation or current-install factual gap was found. Important
limits for final documentation are:

1. Current installed API evidence is **A's private-oracle proof**, not the
   superseded public-facade/98-coercion installation proof. Canonical owner
   declarations remain installed; the adapter is local test support only.
2. The final eight positive consumer checks prove installed import/link boundary,
   while negative probes prove absence of the flat module/main library. They do
   not constitute new hardware behavioral coverage.
3. Existing global baseline formatting failures and the two historical supplemental
   Simulation-role `INITIALDLY` lint failures are not claimed fixed. No global
   formatter, compilation, build or EDA was rerun by this review.
4. Earlier exact RTL/statistics comparisons are preservation evidence, not fresh
   mapped/P&R, physical timing/CDC/analog signoff or a new formal-equivalence proof.
   Deferred hardware/interface/API/SRAM work and original historical evidence gaps
   retain their separately documented scope.

## Review record

Machine-readable result: `CLOSEOUT-validation.json`, including exact remaining flat
references, installed sublibrary names, current bundle identities and index hash.
The only execution performed by this reviewer was:

```text
python3 -B .dev/final-layout-review/20261111/closeout.py
```

It reads source/proof/installed-artifact bytes and metadata; it runs no build,
compiler, EDA, environment activation, provisioning or physical-flow command.
Writes are confined to this receipt directory.

Git HEAD remains `7269746b8833ce8edefafa7ba6e9fe249efe1073`. Git index SHA-256
still equals the original independent-review baseline:
`b17f790e60bd3032f0f9e3edb93e1a0e8a755cbb37f8fe96da5d9dda1dc3ae48`.
The cached diff is empty. No source, Git index/history/configuration or sibling
file was mutated by this review.
