# Landed-tree integrated verification

All commands ran serially under `/home/wayne/devel/jane/.protemu-build.lock`,
opam switch `5.2.0+ox`, with `-j5` for Dune build/exec. The forced integrated
verification used a 900000ms outer tool timeout.

| Command | Result | Seconds |
| --- | --- | --- |
| dune build @install @lint -j5 | passed | 0.318 |
| dune build @verification --force -j5 | passed | 508.767 |
| dune build @verification-long --force -j5 | passed | 4.269 |
| dune build @verification-four-state --force -j5 | passed | 0.906 |
| dune build @fmt -j5 | 41 failing files: 23 baseline + 18 introduced | see commands.jsonl |

The integrated alias forced both ordinary runtest and all emitted-RTL tiers.
Its log records all three loader sensitivity-peer passes. The source audit
counts all 481 test registrations.

## Final outputs and identity

- Refreshed standalone generation: 17/17 byte-identical to AM3 final17.
- Refreshed bundle emission: 6/6 simulation/synthesis roles byte-identical to AM3.
  Final fresh bundles are `bundles-final/`; hashes are in
  `bundles-final-comparison.json`.
- Each of the three fresh bundles has 55 canonical source inputs. All copied
  source bytes and declared SHA-256s match current authored sources.
- Installed facade check refreshed successfully: 26 module signatures and 98
  bidirectional interface-record coercions; findlib resolves the local install.
- Hardware source comparison remains 26/26 unchanged except explicit owner aliases.
- All 105 previously captured AM3 output/input artifacts retain their original hashes.

## Layout

All 13 retired roots are absent: lib, bin, test, host, f_model, rtl, chip_top,
isa, host_link_protocol, host_link_wire, tinytapeout, examples, flow_results.
The active audit covers 61 Dune files and 194 OCaml sources. There are no active
`include_subdirs unqualified` stanzas or OCaml-source copy assembly rules.
The remaining six copy rules carry emitted Verilog verification peers.
Thirty intentional unwrapped test/support stanzas remain across 28 Dune files;
wrapping was not mechanically changed.

## Formatting classification

The initial check found 43 failing files. Corrected two small A-owned formatting
defects only: multiline `libraries` lists in `ip/host_link/rtl/dune` and
`ip/protemu_system/rtl/dune`. These are whitespace-only changes. A subsequent
`@install @lint`, full 17-output regeneration, installed facade test, and fresh
bundle emission passed. No functional source changed after forced verification.

Final check: 41 failures. All 23 prior baseline failures retain exactly the same
formatter edit lines after relocation; no baseline formatting was rewritten.
The exact remaining 18 introduced failing files are:

```
archive/dune
asic/project/chip_project.ml
asic/tinytapeout/src/dune
asic/tinytapeout/test/dune
asic/verif/observable/emit/dune
firmware/examples/dune
ip/emulator_core/verif/control_port/item.ml
ip/emulator_core/verif/core_engine/core_engine_control_port_tests.ml
ip/host_link/verif/command_dispatch/command_dispatch_testbench.ml
ip/mechanisms/verif/blocks/input_events/input_events_four_state_bench.ml
ip/mechanisms/verif/blocks/pin_bank/pin_bank_testbench.ml
ip/mechanisms/verif/emit/dune
ip/program_memory_controller/verif/controller/protocol_core_property_tests.ml
software/cli/protemu.ml
software/cli/test/dune
software/simulator/dune
verif/backends/conformance/dune
verif/system/emit/dune
```

See `integrated-format-classification.json` for complete baseline/current edit
comparisons and `integrated-format-check.log` for exact hunks. These other-owner
files and the archived artifacts were not edited. Coordinator docs remain owned
by the coordinator. No Git mutation, physical implementation or provisioning.
