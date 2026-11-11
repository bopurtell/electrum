# Repository ownership and verification layout

Current layout after the 2026-11-11 [ownership migration](ownership_layout.md).
The subsequent [AM3 protocol/Codec separation](architecture_migration.md#am3--protocol-library-and-codec-separation)
is implemented; canonical protocol source is `host_link_protocol/`.

## Ownership rules

An IP owns its RTL and verification, including interface-specific agents, stimulus,
models and monitors. A system importing an agent does not transfer its ownership.
Root `verif/` owns cross-owner infrastructure and whole-system verification.
`chip_top/` owns package/resource integration and its verification. Software/tool
contracts use `test/`; directory spelling does not change Dune's `runtest` semantics.

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
    verif/serial_host/            reusable item/config/driver/monitor/agent library
    verif/endpoint/               scheduler, adapters, scoreboard and endpoint scenarios
    verif/{serial_phy,frame_rx,command_dispatch,frame_tx}/
    verif/archived/hl4a/          frozen but ACTIVE regression oracle
rtl/protemu_top.ml                target-independent system, external program-RAM port
chip_top/
  rtl/                           package/observable/memory tops and RAM binding
    bringup/p0_observable.ml
  project/                       protemu_chip_project library, declaration and input inventory
  verif/observable/              P0 core and package-peer checks
  verif/memory/emitted/          explicitly selected memory-package peer
verif/
  common/                        shared Observation, Replay and Env facilities
  system/emitted/                one independent loader serial peer, used at three boundaries
  regression/                    long/four-state sweep entry point
test/
  f_model/                       pure reference-model/program/encoding checks
  host/                          host API contracts
  host_link_protocol/            pure codec/fixed-vector and compatibility checks
  host_simulator/                simulator/host CLI integration and golden output
  verification_support/         shared checker/replay qualification
  backend_conformance/          simulator-adapter scheduling qualification
```

Three alias-only compatibility directories remain under the former `test/` paths
for protocol-core, control-execution and UART-slice replay commands. They contain
no duplicate implementation or suite library; current source has one owner.

## Library boundaries

- `hardcaml_protemu` remains one wrapped public library with flat module names.
  `lib/dune` explicitly gathers owner-local sources into its build directory.
  Authored hardware is not duplicated and the library remains ASIC-independent.
- `protemu_chip_project` separately owns the ASIC-dependent package compositions,
  `Program_memory` binding and `Chip_project` declaration. `bin/asic_bundle.ml`
  handles the CLI and emission; it is no longer the owner of all package hardware.
- `isa/` and `f_model/` retain their independent libraries/APIs; the model remains
  independent of Hardcaml. `host_link_protocol/` is a pure Core library whose root
  exposes protocol definitions and whose `Codec` owns software byte conversion.
  `host_link_wire/` is now only a temporary old-source-API facade, not another owner.
  AM3 changed those API paths with exact wire/RTL preservation; finer subsystem
  hardware-library decomposition remains separate.
- Serial-host and control-port agents remain test-free reusable libraries.
  Their item types, independent observation, active/passive roles and environment-
  owned time are unchanged. See [the pilot decisions](serial_host_pilot.md#decisions).

## Evidence boundaries

The endpoint fixture uses the real Host_link with a control-port responder; it is
not a substitute for whole-system verification. The independent Verilog peer has
one authored source in `verif/system/emitted/` and still runs against the reusable
system, behavioral package and synthesis package. It retains its own wire/CRC
expectations instead of deriving them from the implementation codec.

`tinytapeout/src/dune` and `tinytapeout/test/dune` retain compatible generated
targets/aliases and consume the owner-local benches. `@rtl` covers the existing
tiers; the memory bench retains its explicit checker activation rather than being
silently added to default execution.

`f_model/` tests establish model behavior. Tests of `Observation` or simulator
scheduling qualify verification tools. Neither alone is evidence that product RTL
satisfies those contracts. Keep software tests and DUT checks distinct even when
one suite composes multiple libraries.

## Storage and compatibility

`_build/` is generated; `.dev/ownership-migration/` contains local baseline and
verification receipts. `flow_results/`, dated `tinytapeout/reports/`, captured
bundles and history documents retain their old paths/hashes. Root `loader_core.v`
and committed P0 RTL were preserved. Do not confuse those retained artifacts with
the actively executed `ip/host_link/verif/archived/hl4a` oracle.

Old generator selectors and emitted names, including `protocol_core`,
`executable_core`, `integrated_core` and `loader_core`, remain compatibility
surfaces. The source's current owner name need not rename the generated module.
