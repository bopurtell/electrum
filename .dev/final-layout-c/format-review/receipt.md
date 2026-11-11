# C-owned final formatting correction receipt

2026-11-11. Completed the seven scoped formatting corrections requested after
functional review. Source edits were applied only with `apply_patch`; each final
file exactly equals the pinned formatter output captured from its pre-edit bytes.
No source logic, dependency, selector, input-inventory membership, or flags changed.
The only `.ml` change reflows a comment in `Chip_project.input_paths`.

| Scoped file | Format check | Exactly formatter of original |
| --- | --- | --- |
| `archive/dune` | PASS | PASS |
| `asic/project/chip_project.ml` | PASS | PASS |
| `asic/tinytapeout/src/dune` | PASS | PASS |
| `asic/tinytapeout/test/dune` | PASS | PASS |
| `asic/verif/observable/emit/dune` | PASS | PASS |
| `ip/mechanisms/verif/emit/dune` | PASS | PASS |
| `verif/system/emit/dune` | PASS | PASS |

## Verification

All verification commands used:

```text
flock ../.protemu-build.lock ./scripts/with-switch.sh python3 -B .dev/final-layout-c/format-review/review.py MODE
```

The existing switch default is `5.2.0+ox`. Dune subprocesses explicitly use `-j5`.

- `before`: captured seven original source texts/hashes and their formatter output,
  and checked all 42 historical files against the original archive receipt plus
  the existing external index hash.
- `after`: PASS all seven. The first attempt identified one remaining indentation
  at the UART trace diff operand; after its formatting-only patch, all seven pass.
- `build`: PASS `dune build -j5 @install @lint` and explicit ASIC-emitter build.
  Logs: `install-lint.log` and `bundle-emitter-build.log`.
- `bundles`: PASS newly emitted six simulation/synthesis RTL roles against saved
  AM3 bytes, unchanged semantic manifest fields/configuration/constraints/pins/
  resource policy, conflict rejection, and repeated identical package manifests.
- `current`: PASS all three manifests' 55 inputs against current source bytes and
  copied inputs, all seven format checks, and unchanged archives/index.

## Source inventory and identities

All three packages still have exactly **55 independent canonical source inputs**.
No `software/compatibility/hardware/`, other software, reference model, or global
flat hardware facade is inventoried. No inventory membership was removed or added.
Fresh manifests record the updated source hashes; old emission receipts remain
historical snapshots and were not rewritten.

| Package | Fresh identity |
| --- | --- |
| observable | `1782b66c7121a157abf145ccfe8d3848af7e466ae5a49889fea40f21fd8898a0` |
| memory | `aa5fc077159b64c391f3d49238be3979d3948c384a6249e89fb052c65f7c693b` |
| loader | `9f6b707a6d184b75261330ea88b08ce0b63d834303b895028fdeb8d605a8ee58` |

`bundle-comparison.json` contains all 165 source input records and all six fresh
RTL before/after hashes. `final-current-checks.json` separately records current
source hashes after emission; `format-and-archive-checks.json` records the seven
before/after source hashes and preservation result.

## Preservation and boundaries

All **42 historical file hashes, byte lengths and modes** remain identical to the
original pre-migration receipt, including all five opaque tarballs. The external
`archive/INDEX.md` remains unchanged with SHA-256
`9997f07e017fe62fca14e933f6ca718a48a7f47ef4dd7cb5f13d0de3d499d71d`.
Only new `archive/dune` metadata was formatted.

The supplied functional-review result (`@verification`, 481 registrations and
three RTL tiers passing) remains prior review evidence. This formatting follow-up
ran no EDA/P&R, provisioning, or Git mutation. Generic synthesis statistics were
not reexecuted and are not represented as fresh measurements. A's public-flat-
facade removal is outside this write set. No C-owned blockers remain.
