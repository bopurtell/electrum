# Repository ownership and verification layout

Current layout after the 2026-11-11 [final ownership/library migration](final_layout_migration.md).
The [AM3 protocol/Codec separation](architecture_migration.md#am3--protocol-library-and-codec-separation)
remains implemented; canonical protocol source now lives with its IP at
`ip/host_link/protocol/`.

## Ownership rules

An IP owns its RTL and verification, including interface-specific agents, stimulus,
models and monitors. A system importing an agent does not transfer its ownership.
Root `verif/` owns cross-owner infrastructure and whole-system verification.
`asic/` owns this single ASIC's package/resource integration and verification.
Software/tool contracts use owner-local `test/`; there is no root test bucket.
Directory spelling does not change Dune's `runtest` semantics.

```text
ip/
  mechanisms/
    rtl/                          leaf mechanisms
      staging/                    implemented experimental compositions
    verif/
      blocks/                     byte_fifo, input_events, pin_bank, shift_lane, timing
      staging/                    observed transfers, primitive demo, UART and emitted peers
  program_memory_controller/
    rtl/
    verif/controller/             original protocol_core corpus
    verif/backend_integration/    same consumer against selected RAM implementations
  emulator_core/
    rtl/                          execution, decoder, dispatch, Control_port and composition
      legacy/                     retained executable-core composition
    verif/execution/
    verif/control_port/           reusable responder/monitor agent
    verif/core_engine/
    verif/emitted/
  host_link/
    rtl/                          endpoint, PHY, RX, dispatch, TX and hardware wire helpers
    protocol/                     pure definitions + Codec, with local test/
    verif/serial_host/            reusable item/config/driver/monitor/agent library
    verif/endpoint/               scheduler, adapters, scoreboard and endpoint scenarios
    verif/{serial_phy,frame_rx,command_dispatch,frame_tx}/
    verif/archived/hl4a/          frozen but ACTIVE regression oracle
    verif/archived/support/       private old-API adapter for the frozen oracle only
  electrum_system/rtl/             Electrum_top system, external program-RAM port
asic/
  rtl/                           package/observable/memory tops and RAM binding
    bringup/p0_observable.ml
  project/                       electrum_chip_project library, declaration and input inventory
  cli/                           ASIC bundle executable
  verif/observable/              P0 core and package-peer checks
  verif/memory/emitted/          explicitly selected memory-package peer
  tinytapeout/                   target collateral and physical-flow helpers
  flow.sh                        explicit physical-flow front door
verif/
  common/                        Observation, Replay, Env; qualification in local test/
  backends/conformance/          simulator scheduling qualification and local test/
  reference/model/              independent model, model-side peers/studies and local test/
  system/emitted/                one independent loader serial peer, used at three boundaries
  system/emit/                   existing multi-owner RTL generation selector
  regression/                    long/four-state sweep entry point
software/
  host/                          host API and local test/
  simulator/                     simulator backend and local test/
  cli/                           commands, local test/, examples/ and scripts/
  compatibility/host_link_wire/  old protocol source API and local compatibility tests
spec/isa/                        ISA, assembler and encoding definitions
firmware/examples/               selected-ISA programs, independent pure library
scripts/                         bootstrap.sh, env.sh, dependency and switch helpers
archive/legacy/                  inert historical evidence and loader_core.v snapshot
```

The old alias-only test paths are retired. Replay commands name current owners;
six non-frozen path-only diagnostic expectations were updated explicitly. Functional
goldens, example files, program bytes and frozen regressions remain unchanged.

## Library boundaries

- Wrapped hardware libraries now enforce owner dependencies. Public sublibraries
  are `electrum.{mechanisms,mechanisms_staging,controller,core,core_legacy,
  host_link,system,asic_bringup}`. Their roots are respectively `Electrum_mechanisms`,
  `Electrum_mechanisms_staging`, `Electrum_controller`, `Electrum_core`,
  `Electrum_core_legacy`, `Electrum_host_link`, `Electrum_system`, `Electrum_asic_bringup`.
  There is no installed flat `Electrum` module or Dune main library. The
  opam/Findlib package name remains a namespace container for its sublibraries.
- The original flat name exists only in a private non-installed adapter under
  `ip/host_link/verif/archived/support/`, for the unchanged frozen HL4a suite.
  Canonical owners have no reverse dependency on it; it does not compile RTL copies.
- `electrum_asic_rtl` owns ASIC-dependent package compositions/`Program_memory`;
  `electrum_chip_project` owns the declaration. `asic/cli/asic_bundle.ml` is the CLI.
- `spec/isa/` and `verif/reference/model/` retain their independent APIs and the
  model has no Hardcaml dependency. Pure `electrum_firmware_examples` owns authored
  example programs, reexported type-identically by the model for compatibility.
- `ip/host_link/protocol/` exposes `Host_link_protocol` definitions and `Codec`
  byte operations. The old protocol API is a separate source-compatible facade
  under `software/compatibility/host_link_wire/`, not another implementation.
- Serial-host and control-port agents remain test-free reusable libraries.
  Their item types, independent observation, active/passive roles and environment-
  owned time are unchanged. See [the pilot decisions](serial_host_pilot.md#decisions).

## Evidence boundaries

The endpoint fixture uses the real Host_link with a control-port responder; it is
not a substitute for whole-system verification. The independent Verilog peer has
one authored source in `verif/system/emitted/` and still runs against the reusable
system, behavioral package and synthesis package. It retains its own wire/CRC
expectations instead of deriving them from the implementation codec.

`asic/tinytapeout/src/dune` and `asic/tinytapeout/test/dune` retain compatible generated
targets/aliases and consume the owner-local benches. `@rtl` covers the existing
tiers; the memory bench retains its explicit checker activation rather than being
silently added to default execution.

Reference-model tests establish model behavior. Tests of `Observation` or simulator
scheduling qualify verification tools. Neither alone is evidence that product RTL
satisfies those contracts. Keep software tests and DUT checks distinct even when
one suite composes multiple libraries.

## Storage and compatibility

`_build/` contains generated compilation output, `_flow_tools/` provisioned runtime,
`_flow_results/` new execution results, and `.dev/` installations/migration evidence.
The42 historical files formerly under root `flow_results/`, target reports and
root `loader_core.v` moved byte-for-byte to `archive/legacy/`. Five tarballs were
not unpacked/repacked; captured paths remain historical, not rewritten. The
[archive index](../archive/INDEX.md) maps old/new locations. Archive children are
data-only. The frozen HL4a suite remains active at its IP owner, not in this archive.

Old generator selectors and emitted names, including `protocol_core`,
`executable_core`, `integrated_core` and `loader_core`, remain compatibility
surfaces. The source's current owner name need not rename the generated module.
