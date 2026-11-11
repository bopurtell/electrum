# Environment and entry points

Run these commands from the repository root:

```sh
./scripts/bootstrap.sh          # install missing environment layers, then verify
./scripts/bootstrap.sh --check  # report the state of every layer; change nothing
source scripts/env.sh           # activate tools in each new shell
./asic/flow.sh --help            # read the stages and overrides before implementation
```

`scripts/bootstrap.sh` prepares tools and stages no design by default.
`asic/flow.sh` consumes that environment and never provisions by default. A bare
`./asic/flow.sh` deliberately starts the full physical sequence and can take hours;
name the steps when you want only part of it. The flow's stages, overrides,
artifacts and qualification status are in **[flow.md](flow.md)**.

For ordinary build and verification work, use the pinned switch and shared build
lock. Run these sequentially with explicit `-j5`:

```sh
flock ../.protemu-build.lock ./scripts/with-switch.sh dune build -j5 @install @lint
flock ../.protemu-build.lock ./scripts/with-switch.sh dune runtest -j5
flock ../.protemu-build.lock ./scripts/with-switch.sh dune build -j5 @rtl
flock ../.protemu-build.lock ./scripts/with-switch.sh dune exec -j5 protemu -- doctor
```

`@rtl` runs emitted-RTL simulation/lint and generic synthesis, not physical
implementation. `dune exec -j5 protemu -- flow` is an alias for `asic/flow.sh`,
including its full physical default. The public `protemu` name remains available
through root `dune`'s binding to `software/cli/protemu.exe`; no CLI installation is
needed. `dune exec -j5 protemu -- bootstrap` converges the flow layer once OCaml
exists and only reports on the OCaml layer.

The remaining `protemu` commands (`check`, `stage`, `legacy-harden`, `precheck`)
drive the legacy staged project, a different input from the adopted bundle.
`./scripts/bootstrap.sh --legacy-project` explicitly stages/configures it; normal
bootstrap does not. See [the legacy path](flow.md#the-legacy-path).

## Layers

| Layer | Contents | Lifetime | Managed by |
| --- | --- | --- | --- |
| 0. Host | git, Python/venv support, Docker-compatible runtime, HDL tools, Nix and group membership as needed | machine | you or your administrator; bootstrap detects prerequisites and prints guidance |
| 1. OCaml | opam switch `5.2.0+ox` and this repository's dependencies | machine, shared with other Hardcaml checkouts | `scripts/ocaml-deps.sh`; installs missing packages without upgrading/downgrading shared packages |
| 2. Flow | `_flow_tools/{venv,precheck-venv,pdk,tt,toolchain-env.sh}` and the pinned LibreLane image | per checkout/worktree; an external support-tools checkout may be selected | `asic/tinytapeout/scripts/bootstrap-toolchain.sh`, pinned by `asic/tinytapeout/toolchain.lock` |
| 3. Shell | opam environment, `PDK_ROOT`, support-tools location and `_flow_tools/venv/bin` on `PATH` | one terminal | `source scripts/env.sh` |
| 4. Build/execution | `_build/`, `_flow_results/{adopted,flow-*,archives}` | derived from source and each execution | Dune and `asic/flow.sh` |

Layer 1 also resolves unpublished dependencies from sibling checkouts, currently
`hardcaml_asic`. Its path pin can include uncommitted work in that checkout and
requires rebuilding the installed package after dependency edits. Keep the
recorded old ASIC API/revision; this layout migration is not an API upgrade.

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
| New machine | Install the host prerequisites named by `./scripts/bootstrap.sh --check`, including any required group membership; then run `./scripts/bootstrap.sh`. Switch creation and downloads can take substantial time/storage. |
| Fresh clone or new worktree | Run `./scripts/bootstrap.sh`, then `source scripts/env.sh`. Flow environments are per checkout/worktree. |
| New terminal or reboot | `source scripts/env.sh`; use `dune exec -j5 protemu -- doctor` for a report. `asic/flow.sh` does not require activation. |
| Inspecting a recorded run | `PROTEMU_RUN=/path/to/run ./asic/flow.sh report`; collection/reporting need system Python and recorded artifacts, not OCaml or a PDK. |
| Lockfile or opam dependencies changed | Rerun `./scripts/bootstrap.sh`. The CLI bootstrap command only reports on the OCaml layer. Managed clean PDK/support-tool checkouts are checked against the lock. |
| Offline | `./scripts/bootstrap.sh --offline` validates/reuses existing state without fetching. |
| Interrupted bootstrap | Rerun; inspect any partial state the script identifies rather than deleting it automatically. |
| Python/OS/group-membership drift | Run `doctor`; inspect any environment that needs recreation. Bootstrap does not delete an existing environment for you. |
| Editor/LSP outside an activated shell | Select switch `5.2.0+ox` in the editor; sourcing `scripts/env.sh` affects that terminal only. |

## Ownership and storage

- Authored ASIC inputs live in `asic/rtl/` and `asic/project/`; the bundle CLI is
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
build/emit/harden a design, run precheck, select a different target, or delete runs.
`--legacy-project` is the explicit exception for staging/configuration. Tool-version
and target changes require reviewed lock/declaration changes; `6x4` remains the
selected allocation. Submission/export and CI publication remain explicit work.

## Qualification boundary

The 2026-11-11 layout migration checked script/root discovery, activation and
stub-only flow orchestration, plus nonphysical build/bundle preservation. It did
not provision tools or rerun physical implementation. The last recorded full
physical qualification is the historical September 2026 observable-top evidence
linked from [flow.md](flow.md#verified-behavior-and-known-limits); it is not a new
qualification of the current production top or relocated runtime layout.
