# Environment and entry points

The [ASIC/Workbench adoption closeout](adoption-release.md) records an earlier
installation and its exact evidence. The normal selector below has since moved
to ASIC's `Chip_target` API and starter flow collections. The legacy `asic/flow.sh`
workflow is a separate interface.

## Normal captured compiler/library selection

The normal installer uses [`tools-source.lock.json`](../tools-source.lock.json).
Its default is ASIC commit `c1c4fa3e9990a1cd584c23b1c3d5ddd7c6bdbb12`.
Workbench is captured from its working tree; CI supplies a recorded clean
Silver checkout. Check prerequisites and install from the sibling checkouts:

```sh
scripts/ocaml-deps.sh --tool-deps
mkdir -p /tmp/opencode   # scratch directory for the pinned upstream tests
python3 -B scripts/install-tools.py \
  --asic-source ../hardcaml_asic \
  --workbench-source ../silver
source scripts/env.sh
```

If prerequisites are missing, run `scripts/ocaml-deps.sh --install --tool-deps`
to install the published dependencies. For subsequent uncommitted ASIC
development, explicitly add `--asic-source-mode working-tree` (or its alias
`--development`). `bootstrap.sh --tools-only` also uses the committed pin above.

This builds/checks independent captured sources and installs a new local prefix;
it does not mutate the shared opam switch. The pinned ASIC supplies its own
installer; older explicit revisions without that installer use Electrum's Dune
fallback. Changing the lock alone does not activate a new generation. Previous
generations and failed captures remain in `.dev/tools/generations/`.
The selected machine installation is
`.dev/tools/current.json`; its referenced `receipt.json`, checked installed-file
inventory, and `sources.asic` record identify the accepted compiler/library input.
For working-tree mode, `revision`/`base_revision` name checkout HEAD provenance,
**not** a clean revision stamp. `dirty`, full `status`, `files`, and `tree_sha256`
record the actual captured bytes. A receipt does not implement the CLI's separate
source-artifact stamping contract.

`asic/tinytapeout/asic-dependencies.lock` still records historical PT3a provenance
(`b0b3384…`). That file and old private-provider receipts are preserved; neither
silently selects the normal compiler/library. `tools-source.lock.json` records
the normal compatibility base separately from an explicit development snapshot;
for this migration it is the same commit as the normal pin.

Failed `env.sh` activation returns 2, removes its old generation paths/exports,
and blocks ordinary project tool commands in that shell until activation succeeds.
Workbench `status` reports `configure_required` if its published prefix differs
from the current selected installation. Explicit simulation refresh checks the
previous generation against its own sealed catalog/schema and file hashes, then
requires the new catalog's real cases to qualify before publication.

The older flow-layer/legacy entry points described below have independent
historical locks and qualification boundaries. Shared-switch dependency changes
require explicit `--install-deps`; `bootstrap.sh --tools-only` is the pinned local
tools installation entry point.

Run these commands from the repository root:

```sh
./scripts/bootstrap.sh --tools-only  # select the local ASIC and Silver builds first
./scripts/bootstrap.sh          # check OCaml dependencies and prepare flow collateral
./scripts/bootstrap.sh --check  # report the state of every layer; change nothing
source scripts/env.sh           # activate tools in each new shell
./asic/flow.sh --help            # read the stages and overrides before implementation
```

`scripts/bootstrap.sh` prepares tools and stages no design by default.
`asic/flow.sh` consumes that environment and never provisions by default. A bare
`./asic/flow.sh` deliberately starts the full physical sequence and can take hours;
name the steps when you want only part of it. The flow's stages, overrides,
artifacts and qualification status are in **[flow.md](flow.md)**.

For ordinary build and verification, activate the selected local prefix and use the
shared build lock. Run sequentially; outer test concurrency is deliberately lower
because individual tests can create child processes:

```sh
source scripts/env.sh
flock ../.electrum-build.lock dune build -j10 @all
flock ../.electrum-build.lock dune runtest -j2
# Explicit additional HDL verification:
flock ../.electrum-build.lock dune build -j2 @rtl
```

`@rtl` runs emitted-RTL simulation/lint and generic synthesis, not physical
implementation. `dune exec -j5 electrum -- flow` is an alias for `asic/flow.sh`,
including its full physical default. The public `electrum` name remains available
through root `dune`'s binding to `software/cli/electrum.exe`; no CLI installation is
needed. `dune exec -j5 electrum -- bootstrap` converges the flow layer once OCaml
exists and only reports on the OCaml layer.

The remaining `electrum` commands (`check`, `stage`, `legacy-harden`, `precheck`)
drive the legacy staged project, a different input from the adopted bundle.
`./scripts/bootstrap.sh --legacy-project` explicitly stages/configures it; normal
bootstrap does not. See [the legacy path](flow.md#the-legacy-path).

## Layers

| Layer | Contents | Lifetime | Managed by |
| --- | --- | --- | --- |
| 0. Host | git, Python/venv support, Docker-compatible runtime, HDL tools, Nix and group membership as needed | machine | you or your administrator; bootstrap detects prerequisites and prints guidance |
| 1. OCaml | opam switch `5.2.0+ox` and published dependencies | machine, shared with other Hardcaml checkouts | `scripts/ocaml-deps.sh`; requests only missing packages |
| 2. Flow | `_flow_tools/{venv,precheck-venv,pdk,tt,toolchain-env.sh}` and the pinned LibreLane image | per checkout/worktree; an external support-tools checkout may be selected | `asic/tinytapeout/scripts/bootstrap-toolchain.sh`, pinned by `asic/tinytapeout/toolchain.lock` |
| 3. Shell | opam environment, `PDK_ROOT`, support-tools location and `_flow_tools/venv/bin` on `PATH` | one terminal | `source scripts/env.sh` |
| 4. Build/execution | `_build/`, `_flow_results/{adopted,flow-*,archives}` | derived from source and each execution | Dune and `asic/flow.sh` |

`--install-deps` adds missing published Electrum prerequisites to the shared
switch. `scripts/ocaml-deps.sh --install --tool-deps` also adds the dependencies
of the locked ASIC and sibling Silver sources. Neither command pins ASIC or
Workbench into the shared switch; use the local tools installer for them.

Layers 1 and 2 are plain shell called directly by `scripts/bootstrap.sh`, so
`--check` can report a missing OCaml environment without first compiling a CLI.
Layer 3 must be sourced because a child process cannot change its parent's shell.
The repository's scripts locate their own tools; flow builds use
`scripts/with-switch.sh`. Activation is for commands you type by hand.

`scripts/env.sh` reads `_flow_tools/toolchain-env.sh` and activates only
`_flow_tools/venv`; precheck uses `_flow_tools/precheck-venv/bin/python` explicitly
because its package pins conflict with the main environment. Re-sourcing removes
the previously active environment from `PATH` instead of stacking environments.

## Scenarios

| Situation | Run / action |
| --- | --- |
| New machine | Install the relevant host prerequisites, then run `scripts/ocaml-deps.sh --install --tool-deps` and install the local tools as above. Switch creation and downloads can take substantial time/storage. |
| Fresh clone or new worktree | Run `./scripts/bootstrap.sh --tools-only`, then `source scripts/env.sh`. For the legacy flow collateral, also run `./scripts/bootstrap.sh`. Environments are per checkout/worktree. |
| New terminal or reboot | `source scripts/env.sh`; use `dune exec -j5 electrum -- doctor` for a report. `asic/flow.sh` does not require activation. |
| Inspecting a recorded run | `ELECTRUM_RUN=/path/to/run ./asic/flow.sh report`; collection/reporting need system Python and recorded artifacts, not OCaml or a PDK. |
| Tools-source lock or opam dependencies changed | Run `scripts/ocaml-deps.sh --tool-deps` to check prerequisites, then `./scripts/bootstrap.sh --tools-only` to select a new local generation. The legacy flow-tool lock is checked by ordinary bootstrap. |
| Offline | `./scripts/bootstrap.sh --offline` validates/reuses existing state without fetching. |
| Interrupted bootstrap | Rerun; inspect any partial state the script identifies rather than deleting it automatically. |
| Python/OS/group-membership drift | Run `doctor`; inspect any environment that needs recreation. Bootstrap does not delete an existing environment for you. |
| Editor/LSP outside an activated shell | Select switch `5.2.0+ox` in the editor; sourcing `scripts/env.sh` affects that terminal only. |

## Ownership and storage

- Chip wrappers and named flow declarations live in `asics/<chip>/`; shared
  ASIC inputs live in `asic/rtl/` and `asic/project/`. The bundle CLI is
  `asic/cli/asic_bundle.ml`. Target locks/helpers are in `asic/tinytapeout/`.
- Provisioned tools/runtime live under ignored `_flow_tools/`; design execution
  output lives under ignored `_flow_results/`. Legacy staging uses
  `_flow_results/legacy/p0-staged`.
- The adopted bundle derives RTL source sets, timing constraints, TT metadata and
  configuration from the typed declaration. Hand-maintained
  `asic/tinytapeout/info.yaml` and `asic/tinytapeout/src/config.json` are legacy
  design inputs only.
- Preserved physical evidence is under [`archive/legacy/`](../archive/legacy/);
  [`archive/INDEX.md`](../archive/INDEX.md) records the byte-preserved moves.
  `.dev/` contains local migration/installation bookkeeping, not provisioned flow
  runtime. Existing legacy ignored state is not implicitly moved or reprovisioned.

The bootstrap does not install host packages, use `sudo`, edit shell startup files,
emit/harden a design, run precheck, select a different target, or delete runs.
Its explicit `--tools-only` path builds/tests/installs captured tool sources locally.
`--legacy-project` is the explicit exception for staging/configuration. Tool-version
and target changes require reviewed lock/declaration changes; `6x4` remains the
selected allocation. Submission/export and CI publication remain explicit work.

## Qualification boundary

The historical [bounded adoption scope](adoption-release.md) includes installed
simulation/UI acceptance, Electrum physical attempts and typed negative timing
reinspection. That evidence is tied to its original snapshot, not a qualification
of the current default pin. The following layout record is also historical:

The 2026-11-11 layout migration checked script/root discovery, activation and
stub-only flow orchestration, plus nonphysical build/bundle preservation. It did
not provision tools or rerun physical implementation. The last recorded full
physical qualification is the historical September 2026 observable-top evidence
linked from [flow.md](flow.md#verified-behavior-and-known-limits); it is not a new
qualification of the current production top or relocated runtime layout.
