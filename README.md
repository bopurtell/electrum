# Electrum

Formerly Hardcaml Protemu. The package is now `electrum`, the CLI is
`dune exec electrum -- …`, and wrapped OCaml libraries use `Electrum_*`
(for example, `electrum.core` / `Electrum_core`). Project environment variables
use `ELECTRUM_*`. This is a source/API rename; consumers must update their
dependencies and module references. Newly generated RTL uses `electrum` names.
Historical bundles, receipts, the original architecture PDF, and the frozen
HL4a oracle retain their original identities.

After moving a checkout, start a fresh shell and reinstall the local tools with
`python3 scripts/install-tools.py`, then `source scripts/env.sh`: existing tool
receipts and installed executables contain absolute paths. Reconfigure Workbench
for the new checkout path using the setup in [adoption-release.md](docs/adoption-release.md).

A programmable protocol-emulator design, its independent reference model, host
software, and ASIC integration. The repository owns the hardware and its
verification; `hardcaml_asic` supplies resource/backend tooling.

## Source ownership

| Path | Responsibility |
| --- | --- |
| `ip/mechanisms/` | Leaf mechanisms and staging compositions, with their verification |
| `ip/program_memory_controller/` | Access/image-validity controller and consumer verification |
| `ip/emulator_core/` | Execution, primitive dispatch, core composition and control-port agent |
| `ip/host_link/` | Serial endpoint, block verification, serial agent and endpoint environment |
| `ip/electrum_system/` | Reusable `Electrum_top` system composition with external RAM interface |
| `asics/{loader,memory,observable}/` | Chip-local package tops, flow collections and owner CLIs |
| `asic/` | Shared Tiny Tapeout declarations, RAM binding, Silver gateway, and integration verification |
| `verif/` | Shared plumbing, independent reference model, system peers and regression sweeps |
| `spec/isa/`, `ip/host_link/protocol/` | Pure shared specifications; host-link byte operations live under `Codec` |
| `firmware/examples/` | Actual chosen-ISA example programs |
| `software/{host,simulator,cli}/` | Host API, simulator backend and command-line software, with local tests/examples |
| `software/compatibility/host_link_wire/` | Temporary source-compatible old protocol API |
| `scripts/` | Repository environment/bootstrap helpers |
| `archive/legacy/` | Byte-preserved historical flow reports, bundles and generated-RTL snapshot |

[Repository layout](docs/repository_layout.md) explains the boundaries and current
test locations. [Final layout migration](docs/final_layout_migration.md) records the exact
preservation results. [Documentation index](docs/README.md) links product and
architecture plans.

## Build and verify

Activate the checked local ASIC/Workbench installation in each shell. The project
uses the current public ASIC API; the shared opam installation may still expose an
older one. See [environment setup](docs/environment.md) for installing
or refreshing the local tools without changing the shared switch.

Normal installs select the chip-target and flow-collection-capable ASIC provider
recorded in [`tools-source.lock.json`](tools-source.lock.json). Silver is captured
from its working tree. Explicit ASIC development capture remains available via
`--development`. Refresh older tool receipts before building this checkout.

```sh
source scripts/env.sh
flock ../.electrum-build.lock dune build -j10 @all
flock ../.electrum-build.lock dune runtest -j2
```

`@rtl` runs emitted-RTL simulation/lint and generic synthesis using Icarus,
Verilator and Yosys. It does not launch physical implementation. `@verification`
combines ordinary regression and emitted-RTL checks; `@verification-long` and
`@verification-four-state` select deeper sweeps explicitly.

Focused hardware verification is colocated, for example:

```sh
flock ../.electrum-build.lock dune runtest -j2 ip/host_link/verif
flock ../.electrum-build.lock dune runtest -j2 ip/emulator_core/verif
```

All sessions share a maximum 20-job budget. The default `asic/flow.sh` can launch a real
physical flow; see [flow.md](docs/flow.md) before using it. It is not a generic
regression shortcut.

## Silver and chip targets

```sh
bash scripts/bootstrap.sh --tools-only
bash scripts/workbench.sh configure --source-only
bash scripts/workbench.sh status
bash scripts/workbench.sh daemon
# In a second terminal:
bash scripts/workbench.sh client
```

Omit `--source-only` to retain and revalidate a previously configured physical
toolchain, or use `--toolchain-root` to select one explicitly.

Silver treats the root `dune-project` as one project. `hardcaml_asic` elaborates
the separately registered chips in [`hardcaml-asic-targets.json`](hardcaml-asic-targets.json):

| Chip | Flows |
| --- | --- |
| `loader` (default) | `flops`; `stock_sram` through `timing` |
| `memory` | `flops`; `stock_sram_synthesis` at `synthesis` only |
| `observable` | `flops`; no registered program RAM |

Use **`--chip` to select hardware**, **`--flow` to select its methodology**, and
**`--profile` to select settings for that flow**. All three chips default to
`flops/balanced` and expose a single `default` hardware variant. For example:

```sh
bash scripts/project.sh chip list --json
bash scripts/project.sh flow plan --chip memory --flow stock_sram_synthesis \
  --endpoint synthesis --json
```

Silver can add flow files or duplicate typed profile settings in a chip's
`flows/` collection. Rebuild with `bash scripts/workbench.sh build` to pick up
new declarations; adding a flow does not change the default. New named flows
use the chip's flop baseline unless you bind a different resource policy in
its `flows/target.ml`. Loader's existing `stock_sram/timing_repair` is an
explicit chip-owned override, not a typed setting inherited by profile
duplicates. It changes only post-global-route timing repair. **Electrum still
misses 48 MHz slow-corner setup**; this migration does not qualify physical timing.

`dune build @scripts/chip-targets` checks plans and bundles, including RTL parity
between the named-flow and legacy CLI paths.
With the project-local tools active, `python3 -B scripts/check-silver-chip-targets.py`
also checks discovery, selection, authoring and source-only bundle preparation
through a real Silver daemon in a temporary checkout, without a PDK.

[Current commands, nine-part status and retained evidence](docs/adoption-release.md).

## Current migration status

The final hardware-first layout and owner-local wrapped libraries are implemented
and verified. There is no root `lib/`, `bin/` or `test/`, and no installed flat
`Electrum` hardware API. Installed consumers select explicit sublibraries,
for example `electrum.core` / `Electrum_core` or
`electrum.host_link` / `Electrum_host_link`.
The existing serial-host/control-port agents, monitors, scheduler and frozen HL4a
oracle are preserved. AM3 protocol/Codec separation is also implemented and verified;
new consumers use `Host_link_protocol` and `Host_link_protocol.Codec`. The old
protocol API remains only in `software/compatibility/host_link_wire/`. A private,
non-installed hardware adapter preserves frozen HL4a; new designs cannot depend on
it through the installed package. AM5 grouped
interfaces and wider architecture/verification acceptance remain open. Exact SRAM
and current ASIC/Workbench adoption are now verified in bounded consumer scope;
Electrum physical timing closure and final configuration selection remain open.

Historical evidence under `archive/legacy/` retains its original bytes/identities;
[archive/INDEX.md](archive/INDEX.md) maps former paths. New execution results use
`_flow_results/`, provisioned tools use `_flow_tools/`, local installations/evidence
use `.dev/`, and Dune outputs use `_build/`.
