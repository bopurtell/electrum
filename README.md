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
| `asic/` | This ASIC's package tops, RAM binding, project/CLI, target integration and verification |
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
older one. See [normal setup and acceptance](docs/adoption-release.md) for installing
or refreshing the local tools without changing the shared switch.

Normal fresh installs select ASIC commit `4b6bb60` from
[`tools-source.lock.json`](tools-source.lock.json), including the committed
timing-reader and physical-runtime fixes. Workbench is captured from its working
tree. Explicit ASIC development capture remains available via `--development`;
changing the pin does not refresh an existing local installation or its receipts.

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

All sessions share a maximum20-job budget. The default `asic/flow.sh` can launch a real
physical flow; see [flow.md](docs/flow.md) before using it. It is not a generic
regression shortcut.

## Workbench and ASIC adoption

```sh
bash scripts/workbench.sh status
bash scripts/workbench.sh daemon
# In a second terminal:
bash scripts/workbench.sh client
```

The normal project exposes named `flops` and `stock_sram` flows, source/resource
preparation, four serial-system cases and three event-response cases in Testing,
and actual waveform artifacts. The opt-in `stock_sram/timing_repair` profile changes
only post-global-route timing repair. It does not change hardware or the cycle
contract. **Electrum still misses 48 MHz slow-corner setup**; Workbench accurately
inspects that negative result. Tooling acceptance is separate from design acceptance.

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
