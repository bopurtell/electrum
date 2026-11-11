# Package/tooling formatting follow-up — 2026-11-11

Follow-up to `../package-tooling-post/` and the seven introduced formatting
findings in `../independent-review/20261111-final/RECEIPT.md`. This directory is
new evidence; prior command ledgers, failed runs, comparisons and review findings
remain historical records and were not overwritten.

## Corrections and scoped checks

Applied exactly the seven review-provided formatting diffs with apply_patch:

- `bin/asic_bundle.ml`: wrap the project-construction call.
- `chip_top/rtl/observable_design.ml` and `chip_top/rtl/package_top.ml`: remove
  the extra blank line between opens and module declarations.
- `chip_top/rtl/memory_design.ml`: the same blank-line correction and comment
  wrapping.
- `lib/dune`, `chip_top/project/dune`, `tinytapeout/test/dune`: stanza/comment
  separation and the recorded long copy-files stanza wrapping.

All four `ocamlformat --check` commands exit 0. All three read-only
`dune format-dune-file` outputs match their authored files exactly. Results are
in `scoped-formatting.json`; actual commands and logs are retained.

All checks/emissions execute sequentially under
`/home/wayne/devel/jane/.protemu-build.lock`, using the installed switch
`5.2.0+ox`; all Dune build/exec invocations use `-j5`.

## Results

| Check | Result |
| --- | --- |
| Scoped format checks | 7/7 pass |
| `dune build @install @lint -j5` | Exit 0 |
| `dune build @fmt -j5` | Exit 1: 23 baseline-preserved files; zero introduced failures |
| Regenerated RTL vs immutable pre-move baseline | 17/17 byte-identical |
| Fresh bundle source roles vs immutable pre-move baseline | 6/6 byte-identical |
| Fresh metadata/repeatability/conflict checks | All three kinds pass |
| Fresh copied inputs and manifest-declared file hashes | All three kinds pass |
| Pins, constraints, flow config and selected resource metadata | Match baseline |
| `git diff --check` | Exit 0 |

`format-backlog.json` lists all 23 current owner paths, their corresponding
baseline paths, and byte-identity results. Every remaining failure is an exact
baseline byte match, including the preserved Dune file. No preserved source was
formatted to make the global check pass.

## Refreshed bundle identities and inventories

`refresh.py` imports the original audit harness, directs output to this new
directory, replays the 17 original generator commands at current owner paths,
emits all three bundles, invokes the production checker and performs the original
bundle comparison in byte-only mode. The harness's new optional `run_tools=False`
parameter skips synthesis/simulation; its original default behavior is retained.

Source path inventories are unchanged from the prior package/tooling post-move
emission. Each kind has exactly four changed input hashes: `bin/asic_bundle.ml`,
`chip_top/project/dune`, `lib/dune`, and its selected package design source.
`tinytapeout/test/dune` is not a declared bundle source input.

| Kind | New full identity |
| --- | --- |
| Observable | `bac91a5ec1b121f92003aa5831ba1a598e3f5018d16eca745ba929e56ad4da61` |
| Memory | `c5447c5b949e36e2bd62a496e7785e21e0c90d6252d3620208fcd6e29d796047` |
| Loader | `6aa524a6212878dc73b19bf788ca7b6b2d75a35fe238084bd7fb826a0836612b` |

`format-inventory-changes.json` records previous/new identities and complete
before/after entries for every changed source input. `bundle-comparison.json`
records fresh role hashes, source inventories, metadata and collateral checks
against the immutable baseline. `generated-comparison.json` records all 17
generated RTL hashes. `source-hashes.json` fingerprints the seven formatted files.

## Verification scope

No ordinary regression, `@rtl` or synthesis run was repeated for these
whitespace/comment-layout-only corrections. Fresh RTL byte identity covers every
previously compared generator and bundle role. Earlier passing forced ordinary
and three-tier emitted regressions and same-tool synthesis comparisons remain
recorded in `../package-tooling-post/`; they are not claimed as new runs here.
The initial ordinary-regression failure and subsequent successful retry remain
intact there. `result-summary.json` records this refresh's actual outcomes,
including the expected global formatting failure separately from new failures.

No coordinator documentation, frozen/moved byte-preserved implementation, Git
index/history/configuration, staged files, dependencies or physical-flow state
was edited by this follow-up.
