# Hardcaml Protemu

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
| `ip/protemu_system/` | Reusable `Protemu_top` system composition with external RAM interface |
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

Use the existing compatible switch and installed ASIC API. This source currently
uses `Bundle.render ~simulation_build`; selecting the example's newer ASIC install
is a separate dependency/API migration, not a prerequisite for these commands.

Run commands sequentially, with the shared build lock and explicit `-j5`:

```sh
flock ../.protemu-build.lock ./scripts/with-switch.sh dune build -j5 @install @lint
flock ../.protemu-build.lock ./scripts/with-switch.sh dune runtest -j5
flock ../.protemu-build.lock ./scripts/with-switch.sh dune build -j5 @rtl
```

`@rtl` runs emitted-RTL simulation/lint and generic synthesis using Icarus,
Verilator and Yosys. It does not launch physical implementation. `@verification`
combines ordinary regression and emitted-RTL checks; `@verification-long` and
`@verification-four-state` select deeper sweeps explicitly.

Focused hardware verification is colocated, for example:

```sh
flock ../.protemu-build.lock ./scripts/with-switch.sh dune runtest -j5 ip/host_link/verif
flock ../.protemu-build.lock ./scripts/with-switch.sh dune runtest -j5 ip/emulator_core/verif
```

All sessions share a maximum20-job budget. The default `asic/flow.sh` can launch a real
physical flow; see [flow.md](docs/flow.md) before using it. It is not a generic
regression shortcut.

## Current migration status

The final hardware-first layout and owner-local wrapped libraries are implemented
and verified. There is no root `lib/`, `bin/` or `test/`, and no installed flat
`Hardcaml_protemu` hardware API. Installed consumers select explicit sublibraries,
for example `hardcaml_protemu.core` / `Protemu_core` or
`hardcaml_protemu.host_link` / `Protemu_host_link`.
The existing serial-host/control-port agents, monitors, scheduler and frozen HL4a
oracle are preserved. AM3 protocol/Codec separation is also implemented and verified;
new consumers use `Host_link_protocol` and `Host_link_protocol.Codec`. The old
protocol API remains only in `software/compatibility/host_link_wire/`. A private,
non-installed hardware adapter preserves frozen HL4a; new designs cannot depend on
it through the installed package. AM5 grouped
interfaces and wider architecture/verification acceptance remain open. Exact SRAM
adoption and the newer ASIC API migration belong to PT.3, not this layout change.

Historical evidence under `archive/legacy/` retains its original bytes/identities;
[archive/INDEX.md](archive/INDEX.md) maps former paths. New execution results use
`_flow_results/`, provisioned tools use `_flow_tools/`, local installations/evidence
use `.dev/`, and Dune outputs use `_build/`.
