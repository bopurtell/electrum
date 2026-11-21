(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "chip_project.ml" *)
(* Chip-target declarations for the Electrum Tiny Tapeout package tops.

   Everything the Tiny Tapeout CMOS5L template fixes -- the wrapper ports, the LibreLane
   template settings and the reset and pad-gating idiom -- comes from Tt_cmos5l. What is
   left below is this chip: which core it wraps, how its pins are used, how fast it runs,
   and what it declares as its own source inputs. *)

open! Core
open! Hardcaml
open! Hardcaml_asic

let observable_pinout : Pinout.t =
  let descriptions = function
    | Pinout.Bank.Ui ->
      [ "P0 delay bit 0"
      ; "P0 delay bit 1"
      ; "P0 delay bit 2"
      ; "P0 delay bit 3"
      ; "P0 protocol pin 0 value"
      ; "P0 protocol pin 0 output enable"
      ; "P0 command valid"
      ; "Reserved"
      ]
    | Uo ->
      [ "Timer bit 0"
      ; "Timer bit 1"
      ; "Timer bit 2"
      ; "Timer bit 3"
      ; "Command ready"
      ; "Timer busy"
      ; "Command done pulse"
      ; "Command rejected pulse"
      ]
    | Uio -> List.init 8 ~f:(fun bit -> "Protocol pin " ^ Int.to_string bit)
  in
  List.concat_map [ Pinout.Bank.Ui; Uo; Uio ] ~f:(fun bank ->
    List.mapi (descriptions bank) ~f:(fun bit description ->
      { Pinout.bank; bit; description }))
;;

let memory_pinout : Pinout.t =
  let descriptions = function
    | Pinout.Bank.Ui ->
      List.init 8 ~f:(fun bit -> "Memory request address/length bit " ^ Int.to_string bit)
    | Uo ->
      [ "Status/response high bit 0"
      ; "Status/response high bit 1"
      ; "Status/response high bit 2"
      ; "Status/response high bit 3"
      ; "Status/response high bit 4"
      ; "Status/response high bit 5"
      ; "Status/response high bit 6"
      ; "Status/response high bit 7"
      ]
    | Uio ->
      [ "Reserved request input / response bit 0"
      ; "Reserved request input / response bit 1"
      ; "Reserved request input / response bit 2"
      ; "Reserved request input / response bit 3"
      ; "Reserved request input / response bit 4"
      ; "Memory request opcode bit 0 / response bit 5"
      ; "Memory request opcode bit 1 / response bit 6"
      ; "Memory request opcode bit 2 / response bit 7"
      ]
  in
  List.concat_map [ Pinout.Bank.Ui; Uo; Uio ] ~f:(fun bank ->
    List.mapi (descriptions bank) ~f:(fun bit description ->
      { Pinout.bank; bit; description }))
;;

let loader_pinout : Pinout.t =
  let descriptions = function
    | Pinout.Bank.Ui ->
      [ "Loader select, active low"
      ; "Loader host clock, idle low"
      ; "Loader host-to-device data"
      ; "Reserved"
      ; "Reserved"
      ; "Reserved"
      ; "Reserved"
      ; "Reserved"
      ]
    | Uo ->
      [ "Loader device-to-host data"
      ; "Loader response ready"
      ; "Reserved"
      ; "Reserved"
      ; "Reserved"
      ; "Reserved"
      ; "Reserved"
      ; "Reserved"
      ]
    | Uio -> List.init 8 ~f:(fun bit -> "Protocol pin " ^ Int.to_string bit)
  in
  List.concat_map [ Pinout.Bank.Ui; Uo; Uio ] ~f:(fun bank ->
    List.mapi (descriptions bank) ~f:(fun bit description ->
      { Pinout.bank; bit; description }))
;;

let shared_input_paths =
  (* Capture the shared design libraries explicitly. No software compatibility
     facade or reference-model source participates in this build. The root chip
     registry only selects an owner; changing its default must not invalidate
     a plan for an explicitly selected, unchanged chip. *)
  [ "dune-project"
  ; "electrum.opam"
  ; "tools-source.lock.json"
  ; "asic/cli/dune"
  ; "asic/cli/asic_bundle.ml"
  ; "asic/cli/chip_cli.ml"
  ; "asic/cli/project.ml"
  ; "asic/project/flow_declaration.ml"
  ; "asic/project/chip_kind.ml"
  ; "asic/project/fixed_loader_variant.ml"
  ; "asic/project/dune"
  ; "asic/project/chip_project.ml"
  ; "asic/rtl/dune"
  ; "asic/rtl/program_memory.ml"
  ; "asic/rtl/bringup/dune"
  ; "asic/rtl/bringup/p0_observable.ml"
  ; "asic/tinytapeout/asic-dependencies.lock"
  ; "asic/tinytapeout/toolchain.lock"
  ; "spec/isa/dune"
  ; "spec/isa/assembler.ml"
  ; "spec/isa/descriptor.ml"
  ; "spec/isa/encoding.ml"
  ; "spec/isa/enum.ml"
  ; "spec/isa/event_kind.ml"
  ; "spec/isa/instruction.ml"
  ; "spec/isa/invalid.ml"
  ; "spec/isa/kinds.ml"
  ; "spec/isa/pins.ml"
  ; "spec/isa/program.ml"
  ; "ip/host_link/protocol/dune"
  ; "ip/host_link/protocol/definitions.ml"
  ; "ip/host_link/protocol/codec.ml"
  ; "ip/host_link/protocol/host_link_protocol.ml"
  ; "ip/host_link/protocol/host_link_protocol.mli"
  ; "ip/mechanisms/rtl/dune"
  ; "ip/mechanisms/rtl/byte_fifo.ml"
  ; "ip/mechanisms/rtl/input_events.ml"
  ; "ip/mechanisms/rtl/pin_bank.ml"
  ; "ip/mechanisms/rtl/shift_lane.ml"
  ; "ip/mechanisms/rtl/timing.ml"
  ; "ip/program_memory_controller/rtl/dune"
  ; "ip/program_memory_controller/rtl/program_memory_controller.ml"
  ; "ip/emulator_core/rtl/dune"
  ; "ip/emulator_core/rtl/control_port.ml"
  ; "ip/emulator_core/rtl/emulator_core.ml"
  ; "ip/emulator_core/rtl/execution_unit.ml"
  ; "ip/emulator_core/rtl/instruction_decoder.ml"
  ; "ip/emulator_core/rtl/primitive_dispatch.ml"
  ; "ip/host_link/rtl/dune"
  ; "ip/host_link/rtl/command_dispatch.ml"
  ; "ip/host_link/rtl/frame_rx.ml"
  ; "ip/host_link/rtl/frame_tx.ml"
  ; "ip/host_link/rtl/host_link.ml"
  ; "ip/host_link/rtl/serial_phy.ml"
  ; "ip/host_link/rtl/wire_crc.ml"
  ; "ip/host_link/rtl/wire_layout.ml"
  ; "ip/electrum_system/rtl/dune"
  ; "ip/electrum_system/rtl/electrum_top.ml"
  ]
;;

let default_overrides ~selection ~operation =
  match selection, operation with
  | Resource_policy.Requirement.Exact, Flow.Operation.Hardening ->
    (* These settings are generated, protected facts of the macro physical plan. *)
    Tt_cmos5l.overrides
      ~without:[ "RUN_KLAYOUT_DRC"; "FP_PDN_VPITCH"; "FP_PDN_VWIDTH"; "FP_PDN_MULTILAYER" ]
      ()
  | _ -> Tt_cmos5l.overrides ()
;;

(* Selection changes only the registered program resource's implementation. Exact
   defaults to Synthesis; explicit loader Hardening uses the reviewed PT.3c candidate. *)
let chip_target ?overrides ?(selection = Resource_policy.Requirement.Flops) ?operation (kind : Chip_kind.t) =
  let open Or_error.Let_syntax in
  let%bind () =
    match selection with
    | Flops -> Ok ()
    | Exact when Chip_kind.equal kind Observable ->
      Or_error.error_string "observable has no program resource; exact selection is unsupported"
    | Exact -> Ok ()
    | Exact_or_flop_fallback ->
      Or_error.error_string "selection must be explicit Flops or Exact; fallback is unsupported"
  in
  let operation =
    Option.value
      operation
      ~default:(match selection with Exact -> Flow.Operation.Synthesis | _ -> Hardening)
  in
  let%bind () =
    match selection, operation with
    | Exact, Flow.Operation.Hardening when not (Chip_kind.equal kind Loader) ->
      Or_error.error_string
        "exact Hardening requires reviewed physical placement intent and is supported only for loader; use synthesis for memory"
    | _ -> Ok ()
  in
  let overrides =
    Option.value overrides ~default:(default_overrides ~selection ~operation)
  in
  let macros =
    match selection, operation with
    | Exact, Flow.Operation.Hardening ->
      (* Electrum candidate, not example acceptance: the actual 6x4 core is
         [2.88,3.78,1286.4,706.86] um. The 236.8x118.78 um stock macro plus 2 um
         halo occupies [38,478,278.8,600.78], near the upper-left TT signal pins
         with controller space below its bottom signal edge. x=40 aligns positive
         M4 fingers [111.70,114.51] with grid [111.83,113.93]. The provider must
         check actual core fit, all supply contacts and routing at execution. *)
      [ Macro_intent.tt_cmos5l_r0
          ~resource:(Resource.Id.of_string_exn "program")
          ~x_um:40.
          ~y_um:480.
          ~halo_um:2.
          ()
      ]
    | _ -> []
  in
  let%bind policy =
    Resource_policy.create
      (if Chip_kind.equal kind Observable
       then []
       else
         [ { selector = Resource_policy.Selector.instance_exn "program"
           ; requirement = selection
           }
         ])
  in
  let design, rtl_file, name, title, description, pinout =
    match kind with
    | Observable ->
      ( (module Electrum_observable_rtl.Observable_design : Chip_target.Design)
      , "observable_design.ml"
      , "electrum_observable"
      , "Hardcaml protocol emulator"
      , "Programmable protocol emulator primitives generated by Hardcaml"
      , observable_pinout )
    | Memory ->
      ( (module Electrum_memory_rtl.Memory_design : Chip_target.Design)
      , "memory_design.ml"
      , "electrum_memory"
      , "Hardcaml protocol emulator memory consumer"
      , "P0.7 whole-word load and readback through registered program memory"
      , memory_pinout )
    | Loader ->
      ( (module Electrum_loader_rtl.Package_top : Chip_target.Design)
      , "package_top.ml"
      , "electrum_loader"
      , "Hardcaml protocol emulator with independent hardware loader"
      , "P3.5 fixed serial loader, integrated core, and registered program memory"
      , loader_pinout )
  in
  let rtl_root = "asics/" ^ Chip_kind.id kind ^ "/rtl/" in
  let delays ports maximum =
    List.map ports ~f:(fun port ->
      { Timing.Delay.port
      ; minimum = Time_float.Span.of_ns 0.
      ; maximum = Time_float.Span.of_ns maximum
      })
  in
  let create () =
    Chip_target.create
      ~source_inputs:(shared_input_paths @ [ rtl_root ^ "dune"; rtl_root ^ rtl_file ])
      ~name
      ~metadata:{ title; author = "Bohdan Purtell"; description }
      ~design
      ~target:
        { harness = Tiny_tapeout { tiles = T6x4 }; technology = Technology.ihp_sg13cmos5l }
      ~flow:(Flow.librelane ~overrides ~macros operation)
      ~clocks:[ { Clock.port = "clk"; period = Time_float.Span.of_sec (1. /. 48e6) } ]
      (* Inherited provisional, unexcepted I/O analysis envelope. Loader/protocol
         inputs are asynchronous; these delays are not an external phase contract
         or proof of CDC/reset-release safety. No generated clocks or exceptions. *)
      ~timing:(Timing.create
        ~input_delays:(delays [ "ui_in"; "uio_in"; "ena"; "rst_n" ] 1.)
        ~output_delays:(delays [ "uo_out"; "uio_out"; "uio_oe" ] 2.)
        ())
      ~pinout
      ~policy
      ()
  in
  if Chip_kind.equal kind Loader then (
    let%bind variant = Fixed_loader_variant.create () in
    Chip_target.of_variant ~variant ~create:(fun selected ->
      let%bind () = Fixed_loader_variant.validate selected in
      create ()))
  else create ()
;;
