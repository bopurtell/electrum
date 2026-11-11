# Hardware-owner handoff

Implemented eight wrapped owner libraries and the alias-only old public facade.
No Git commands/mutations, docs edits, ASIC integration edits, software/verification
consumer edits, EDA runs or provisioning were performed by this owner.

## Public APIs

Each owner also directly depends on `core hardcaml` (omitted below). All public
names are `hardcaml_protemu.<suffix>`. All exported module contents remain those
of the original source, with only cross-owner module aliases added.

| Library / public suffix | OCaml wrapper and modules | Direct project dependencies |
| --- | --- | --- |
| protemu_mechanisms / mechanisms | Protemu_mechanisms.{Byte_fifo,Input_events,Pin_bank,Shift_lane,Timing} | none |
| protemu_mechanisms_staging / mechanisms_staging | Protemu_mechanisms_staging.{Observed_transfer,Observed_transfer_bank,Primitive_demo,Uart_slice,Uart_tx} | protemu_mechanisms |
| protemu_controller / controller | Protemu_controller.Program_memory_controller | none |
| protemu_core / core | Protemu_core.{Control_port,Emulator_core,Execution_unit,Instruction_decoder,Primitive_dispatch} | protemu_controller, protemu_mechanisms, protemu_isa |
| protemu_core_legacy / core_legacy | Protemu_core_legacy.Executable_core | protemu_core, protemu_controller |
| protemu_host_link / host_link | Protemu_host_link.{Command_dispatch,Frame_rx,Frame_tx,Host_link,Serial_phy,Wire_crc,Wire_layout} | protemu_core, protemu_controller, protemu_isa, host_link_protocol |
| protemu_system / system | Protemu_system.Protemu_top | protemu_core, protemu_host_link, protemu_controller, protemu_isa |
| protemu_asic_bringup / asic_bringup | Protemu_asic_bringup.P0_observable | none |

`software/compatibility/hardware/` retains library/public name `hardcaml_protemu`.
It depends directly on all eight owners, compiling one file of 26 module aliases.
It does not compile any hardware source, and none of the eight owners depends on
it. Staging and legacy have their own child Dune libraries; no recursive flattening
or copy rules are used. `lib/`, its empty old subdirectories, root `rtl/`, and old
`chip_top/rtl/bringup/` were removed after moving their owned contents.

## Evidence

- `before.json`: captured before editing, maps all 26 source paths/SHA-256s/old and
  new namespaces and hashes 105 saved AM3 final17/bundle files.
- `source-comparison.json`: all 26 source bodies match their original SHA-256
  after removing only the newly added cross-owner aliases. Thirteen files need
  aliases; the other thirteen remain byte-identical. Both textual moves are
  mapped explicitly. All ports, constructors, signal scopes and logic are intact.
- `generated-comparison.json`: 17/17 outputs byte-identical to AM3 final17, with
  complete old/new SHA-256 values; fresh outputs are in `generated/`.
- `commands.jsonl`: locked build, install, installed API compilation/runtime,
  generation and scoped-check execution records, including transitional failures.
- `installed-findlib.log`: confirms findlib selected this receipt's actual local
  installed package, not a workspace or preexisting opam package.
- `installed_identity.ml`: all 26 module signatures and 98 bidirectional
  `Signal.t` interface-record coercions compile against that installed package.
- `owner-lint-and-frozen-hl4a.log`: scoped hardware lint and frozen HL4a runtest
  completed successfully; frozen sources and their Dune file were not edited.

All builds used `flock /home/wayne/devel/jane/.protemu-build.lock`, opam switch
`5.2.0+ox`, and `-j5` for build/exec commands. `dune build @install` succeeded.

## Coordinator / owner C follow-up

Six bundle-role comparison is blocked by the still-old source-input inventory in
`asic/project/chip_project.ml` (`bin/`, `chip_top/`, `lib/dune`, root `tinytapeout/`,
ISA/protocol paths). This is owner C's file and was not edited. See
`bundle-observable.log`. After inventory updates, run:

```
python3 .dev/final-layout/hardware/verify.py bundles
```

The script uses the relocated ASIC emitter, preserves serial build locking, and
compares all six simulation/synthesis role bytes/SHA-256s with AM3. It runs no EDA.
Whole-repository registration, emitted-test, archive and CLI audits remain with
their designated owners/coordinator.
