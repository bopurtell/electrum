# Agent C integration handoff

**Formatting follow-up complete:** see `format-review/receipt.md` for seven/seven
formatter-clean source files, fresh `@install @lint`, six fresh byte-identical
bundle RTL roles, and final current-byte 55-input manifest checks. New identities
and source hashes live in that receipt; earlier identities below are historical.
All 42 archives and the original external index remain byte/mode preserved. No
EDA or fresh generic-statistics run was performed in the follow-up. The coordinator
reported the integrated verification/481 registrations/three RTL tiers passing.

- `chip_top` active sources moved to `asic` except A-owned bringup.
- ASIC-dependent `protemu_asic_rtl` library is separate from preserved
  `protemu_chip_project`, which now depends on `protemu_asic_rtl`.
- All four emitters moved and use canonical owner libraries. `bin/dune` deleted;
  B owns `software/cli/dune` and moving protemu/sim_cli.
- Root dune binary binding points to `software/cli/protemu.exe`.
- Tools remain scripts: bootstrap/env moved to `scripts/`, with-switch and
  ocaml-deps remain. CLI should exec `asic/flow.sh`, check root sentinel
  `asic/tinytapeout/toolchain.lock`, expect `_flow_tools/pdk` and
  `_flow_tools/venv`, and name the new script paths in help.
- New output defaults `_flow_results/{adopted,flow-*,archives}`; tool state
  `_flow_tools/{venv,precheck-venv,pdk,tt,toolchain-env.sh}`. Legacy staging is
  `_flow_results/legacy/p0-staged`; stage lock `_flow_results/legacy/.stage.lock`.
- Three-way source inventory/sandbox/checker update delivered. Source inventory
  captures actual canonical ASIC RTL library source closure for all three kinds,
  no compatibility facade/model/software or legacy core/staging library.
- Archives 42 files (34 flow +7 reports +1 RTL), modes/bytes identical; five opaque
  tarballs. See archive/INDEX.md and local archive-receipt.json. No old runtime
  state existed. No provisioning, physical runs, or Git/index commands run.
- Stub orchestration: 17 checks, zero failures, including caller-relative output,
  bundle and run overrides. Shell activation checked from another cwd, twice,
  with an old venv, colliding shell functions, and a checkout path with spaces.
- Locked emitter builds and loader sandbox source generation passed. Scoped
  ASIC/emitter lint and ASIC observable/target-source runtests passed. The latter
  exposed an old cmp rule missing its generated-file dependencies; those explicit
  dependencies are now present and the fresh focused rerun passed.
- `emission-comparison.json`: fresh 17/17 standalone RTL and six/six bundle roles
  exactly match AM3 final bytes. All other manifest semantic fields match, as do
  config.json, top.sdc and info.yaml for all three packages. All three repeat
  emissions had identical manifest bytes/identity. Source identity changes only.
- `current-checks.json`: all 55 canonical source inputs per kind match copied
  bundle bytes; phase4 consumer pins match the relocated locks. Two authored peers
  and six committed target collateral/lock files match saved AM3 source hashes.
- `shell-archive-checks.json`: syntax checked all 16 shell scripts and four Python
  helpers; all 42 durable archive-index rows match the captured before hashes.
- Root/nested/direct CLI probes belong to B (`.dev/final-layout-b/cli_discovery.py`).
  C did not run EDA or @rtl; coordinator's integrated @rtl execution is outstanding
  under the explicit no-EDA owner scope. No physical/provisioning work was run.
- Coordinator owns active documentation including moved asic/tinytapeout/README.md;
  it was moved byte-for-byte and still needs active links/commands updated.

## Exact verification commands

All Dune commands below were prefixed by
`flock ../.protemu-build.lock ./scripts/with-switch.sh` (switch default 5.2.0+ox).

1. `dune build -j5 asic/cli/asic_bundle.exe asic/verif/observable/emit/generate.exe ip/mechanisms/verif/emit/generate_p2.exe verif/system/emit/generate_core.exe asic/tinytapeout/src/loader_wrapper.simulation.generated.v asic/tinytapeout/src/loader_wrapper.synthesis.generated.v` — PASS.
2. `dune build -j5 ip/program_memory_controller/verif/backend_integration/emit_program_memory_backend.exe` — PASS.
3. `flock ../.protemu-build.lock ./scripts/with-switch.sh python3 -B .dev/final-layout-c/check_emissions.py` — PASS; no EDA.
4. `dune build -j5 @asic/lint @ip/mechanisms/verif/emit/lint @verif/system/emit/lint` — PASS.
5. `dune runtest -j5 asic/verif/observable/core asic/tinytapeout/src` — first attempt failed on missing cmp dependency; after adding explicit deps, PASS.
6. `python3 -B .dev/final-layout-c/check_shells.py` — PASS (17 flow checks, activation, syntax, index).
7. `python3 -B .dev/final-layout-c/verify_current.py` — PASS (current manifests/locks, archive bytes/modes, saved source correspondence).

## New bundle identities

- observable: `0e0efe48f49259148d953582f2bf2f24495b26d544a88dbcd1afd96aee1da932`
- memory: `fa14482458b5c423abcff4da424aaaa255cfd0cd1cb661e6c2722ab2921a4b6a`
- loader: `9c9441417723ae4e5c8d13fb3f2bcd413bcef3d66b655bf0c2a68fff048a1951`

These identify the exact saved emission source state; subsequent coordinator edits
to an inventoried file legitimately require a fresh identity, not archive rewrites.
