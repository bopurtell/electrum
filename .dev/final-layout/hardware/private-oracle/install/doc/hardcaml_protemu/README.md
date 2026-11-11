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
| `rtl/` | Reusable `Protemu_top` system composition |
| `chip_top/` | Package tops, program-RAM binding, project declarations and chip verification |
| `verif/` | Shared observation/replay facilities, whole-system serial peer and regression sweeps |
| `test/` | Model/software/codec/host tests and verification-tool qualification |
| `isa/`, `host_link_protocol/` | Pure shared specifications; host-link byte operations live under `Codec` |
| `f_model/` | Independent reference model and model-side firmware/studies |
| `host/`, `bin/` | Host software and repository CLI/generator entry points |
| `tinytapeout/` | Target integration, compatibility build targets and physical-flow tooling |

[Repository layout](docs/repository_layout.md) explains the boundaries and current
test locations. [Ownership migration](docs/ownership_layout.md) records the exact
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

All sessions share a maximum20-job budget. The default `flow.sh` can launch a real
physical flow; see [flow.md](docs/flow.md) before using it. It is not a generic
regression shortcut.

## Current migration status

The ownership layout and chip/package extraction are implemented and verified.
The existing serial-host/control-port agents, monitors, scheduler and frozen HL4a
oracle are preserved. AM3 protocol/Codec separation is also implemented and verified;
new consumers use `Host_link_protocol` and `Host_link_protocol.Codec`. The old
`host_link_wire/` library is a temporary source-compatibility facade. AM5 grouped
interfaces and wider architecture/verification acceptance remain open. Exact SRAM
adoption and the newer ASIC API migration belong to PT.3, not this layout change.

Historical evidence under `flow_results/` and dated target reports retains its
original inputs and identities. Local migration receipts are under
`.dev/ownership-migration/`; generated build files stay under `_build/`.
