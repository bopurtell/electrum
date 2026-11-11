# Independent final-layout review — 2026-11-11

## Decision

**No concrete implementation/source-layout blocker found. Bounded layout clearance,
subject to A's separately running integrated verification and coordinator closeout.**
Reviewer implemented none of A/B/C and changed no authored source. Documentation
is intentionally unfinished/coordinator-owned and is not judged as a completed
guide here. No build, compilation, Dune action, formatter, activation, provisioning,
staging, physical flow or EDA was run by this review.

Read the authorized `docs/final_layout_migration.md` and all three handoffs:
`.dev/final-layout/hardware/handoff.md`, `.dev/final-layout-b/HANDOFF.md`, and
`.dev/final-layout-c/handoff.md`. Review baseline is committed HEAD
`7269746b8833ce8edefafa7ba6e9fe249efe1073` plus the current unstaged implementation.

## Enforced libraries and namespace identity

- Independently parsed all authored library/executable Dune stanzas and recursively
  checked dependency closure. All **eight wrapped owners** exist with their public
  installed names: mechanisms, mechanisms_staging, controller, core, core_legacy,
  host_link, system and asic_bringup.
- None of the eight depends directly or transitively on the old hardware facade,
  old wire facade or `hardcaml_asic`. The ASIC-dependent `protemu_asic_rtl` and
  `protemu_chip_project` are separate; the latter depends directly on the former.
  ASIC composition reaches canonical system/core/controller/mechanisms/protocol/
  ISA/bringup, without compatibility hardware, staging or legacy-core libraries.
- No global unqualified assembly remains. Each of the 26 hardware implementations
  has exactly one authored RTL owner. Removing only the added cross-owner aliases
  recovers the exact pre-change Git source and captured SHA-256 for every file.
- The old public `Hardcaml_protemu` facade is exactly **26 true module aliases**,
  not copied RTL, wrappers or constructor implementations. Its authored bytes
  match both the build install and A's isolated installed package. The generated
  Dune-package dependency metadata independently agrees with the eight owner
  stanzas and has no reverse facade or ASIC requirement.
- Reviewed A's installed-package identity fixture and successful compile/run
  evidence: all 26 module signatures and 98 bidirectional interface-record
  coercions. Those are A's recorded results, not compilation repeated by this
  reviewer. The current facade source still matches that installed artifact.

Reports: `graph.json`, `hardware.json`, `compiled-dependencies.json`.

### Actual compatibility traces

Do not generalize this as “there are no old namespace references.” Authored
`Hardcaml_protemu` imports remain in the **active frozen HL4a archive**, intentionally
unchanged. Its Dune library retains the old hardware facade. Non-frozen authored
library/executable closures do not reach that hardware facade. The old pure wire
namespace remains in frozen code and its dedicated compatibility test; the pure
wire facade itself still depends on canonical protocol definitions/Codec. The
hardware facade's own source consists of canonical owner aliases. Exact source
trace paths are in `graph.json`.

## Software, reference model, firmware and verification preservation

- Pure authored closures remain intact: ISA and host use Core/ISA only; canonical
  protocol uses Core; wire compatibility uses Core/canonical protocol. Model adds
  only the pure firmware-example library. Firmware examples depend on Core/ISA,
  not hardware, simulator or reference-model implementation.
- `firmware/examples/example_programs.ml` equals the old selected-ISA source bytes.
  Model `Example_programs` is a true alias to that owner, not a duplicated program
  source. Reference `Firmware_*` sequences/peers remain in the model. Reviewed B's
  compiled type-identity fixture for shared Byte_loop/Program/Invalid types.
- Reconstructed the complete registration multiset from pre-change Git bytes and
  current source paths: **481 = 481**, including the two ASIC registrations.
- All **eight frozen files** match both original Git and B's captured hashes.
  UART trace remains preserved under its active owner.
- All **six CLI examples and seven CLI goldens** match original committed bytes.
  CLI workflow actions run from `software/cli`, retaining literal `examples/...`
  commands and diagnostic line numbers. Root/nested/direct CLI discovery evidence
  was inspected, including removal of DUNE_SOURCEROOT for the direct probe.
- Compared all pre-existing expectation forms. Only the **six explicitly approved
  diagnostic files** differ, and replacing the documented old source/rerun paths
  reproduces the complete new expectation bytes. No other expectation changed.
- Old root `test`, `f_model`, `host`, `host_link_protocol`, `host_link_wire`, `isa`,
  `examples`, `lib`, `rtl`, `chip_top`, `bin`, `tinytapeout`, and `flow_results`
  trees are absent; three root test forwarding aliases are not recreated.

Report: `preservation.json` (including the exact six-file whitelist).

## ASIC inputs, sandbox closure and output correspondence

- Independently enumerated the actual `Chip_project.input_paths` list: **55 unique
  existing canonical inputs**. The three saved C bundles declare exactly that set;
  all copied source bytes, source hashes and manifest file hashes verify against
  the current filesystem.
- Every input is explicitly covered by a file or source-tree dependency of the
  relocated loader-wrapper Dune rule. No file relies on an incidental copied
  root source or the former compatibility assembly.
- The common closure deliberately includes all three linked package designs. It
  includes ASIC RTL/project/CLI declarations, wrapped owner Dune files, ISA and
  canonical protocol including its `.mli`; it excludes software/model/compatibility
  implementations, legacy core and mechanism staging.
- Recompared six saved C bundle role byte streams to the AM3 integrated baseline:
  exact identity. A and C both record fresh 17-output emitter comparison evidence.
  This review does not replace A's pending integrated/EDA gate or present an older
  run as a new whole-tree result.

Report: `source-inventories.json` includes the full 55-path list and current saved
bundle identities. Inventory hash/identity changes are source provenance changes,
separate from output RTL equivalence.

## Historical archive and loader provenance

Independently compared **all 42 relocated files** directly to the original committed
Git tree, not merely to C's before/after booleans: 34 flow-result files, seven dated
TT reports and the one RTL snapshot. All bytes match; current modes match captured
pre-change modes (`0664`, preserving committed non-executable status). Each hash is
also present in the durable index. Original relative historical subtrees remain.

All **five `.tar.gz` files** match their original opaque bytes. No historical
tarball was unpacked, repacked, regenerated or edited by this review.
`archive/dune` uses `(data_only_dirs :standard)` so its historical children do not
participate as Dune source/rules; the active library graph and ASIC inventories
do not reach the archive.

The loader snapshot remains 895852 bytes, SHA-256
`dfb870cf40267029fb3bc3ddd78b4f9ec31a625c5602716aed3c2d894005c035`, at
`archive/legacy/rtl/loader_core.v`. Its pre-move Git history is preserved in
`loader-provenance.txt`; the last recorded original-path commit is
`9f6ed2d6b4e8bba1a863210f892d453fd02dad52` (the backup before reorganization).
It was relocated as evidence, not regenerated or substituted for active emitted
RTL. Per-file review results: `archives.json`.

## Script/root/output and guard inspection

Read root resolution and active paths in the CLI, bootstrap/env, adopted flow,
stage/harden/precheck tools, emitters, bundle checker, phase4 consumer, Makefile,
workflow script and CI. No hidden wrong-root or relocated-guard regression found:

- `scripts/{env,bootstrap}.sh` resolve the parent source root; target scripts and
  `asic/flow.sh` use their new depth. Phase4/checker lock resolution points to
  `asic/tinytapeout`; CLI discovery searches the actual new sentinel and avoids
  preferring a copied `_build/default` marker over the outer source tree.
- Tools/environment use `_flow_tools/{venv,precheck-venv,pdk,tt,toolchain-env.sh}`.
  New adopted outputs use `_flow_results/{adopted,flow-*,archives}`; legacy staging
  and its lock use `_flow_results/legacy`. Historical archive paths are not output
  defaults. Explicit external support-tool overrides and the inherited external
  sibling fallback remain allowed reads; bootstrap/hardening pass resolved tools
  into their staging invocation.
- Flow validates step names before output allocation; caller-relative output,
  bundle and run overrides are normalized before Dune subprocess directory changes.
  The default still means full physical execution; no review command invoked it.
- Stage deletion retains both an exact relocated staging-path guard and the
  inherited nonblocking shared stage lock. Bootstrap retains `--check` mutation
  gating and the explicit tools/stage write whitelist.
- Independent **17-shell syntax checks**, four Python AST parses and `make -n rtl`
  pass. The Makefile dry run resolves the chip-owned peer and root `_flow_results`
  output, not the former target build path. No commands printed by Make were run.
  C's 17 stub-only flow checks and controlled activation fixture evidence were
  reviewed, not rerun against this checkout's actual environment.

Reports: `script-controls.json`, `make-dry-run.log`. Review command ledger is the
following pair of read-only helpers; they write only this new receipt directory:

```text
python3 -B .dev/final-layout-review/20261111/review.py
python3 -B .dev/final-layout-review/20261111/script_controls.py
```

## Remaining gates and limitations

- A owns the ongoing integrated build/regression/emitted verification and its
  results. No final combined-tree test pass is invented by this source review.
- **Scoped/global formatting was not run in this review**; no claim that new
  formatting is clean, and no new formatter finding is asserted from visual
  indentation alone. Existing baseline formatting/lint limitations remain separate
  from any introduced failures A/coordinator may subsequently identify.
- Coordinator's current documentation is intentionally in progress.
- Existing ASIC API/Flops policy, independent oracles, deferred grouped-interface/
  VO work, and historical formal/physical evidence gaps retain their prior scope.

Git index SHA-256 was captured before the comparisons and is unchanged afterward;
the cached diff remains empty. `review-state.json` records exact index identities.
No Git index/history/config mutation, source edits, sibling edits, provisioning,
environment activation or EDA occurred during this independent review.
