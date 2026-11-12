(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "chip_project.ml" *)
(* ASIC project declaration for the current Tiny Tapeout observable top.

   Everything the Tiny Tapeout CMOS5L template fixes -- the wrapper ports, the LibreLane
   template settings and the reset and pad-gating idiom -- comes from Tt_cmos5l. What is
   left below is this chip: which core it wraps, how its pins are used, how fast it runs,
   and what it declares as its own source inputs. *)

open! Core
open! Hardcaml
open! Hardcaml_asic
open! Protemu_asic_rtl

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

let input_paths kind =
  (match kind with
   | "observable" | "memory" | "loader" -> ()
   | _ -> failwith "kind must be observable, memory, or loader");
  (* Capture the explicit source closure of the canonical ASIC RTL/project libraries. The
     CLI links all three package designs; no software compatibility facade or
     reference-model source participates in this build. *)
  [ "dune-project"
  ; "hardcaml_protemu.opam"
  ; "asic/cli/dune"
  ; "asic/cli/asic_bundle.ml"
  ; "asic/project/dune"
  ; "asic/project/chip_project.ml"
  ; "asic/rtl/dune"
  ; "asic/rtl/observable_design.ml"
  ; "asic/rtl/memory_design.ml"
  ; "asic/rtl/package_top.ml"
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
  ; "ip/protemu_system/rtl/dune"
  ; "ip/protemu_system/rtl/protemu_top.ml"
  ]
;;

(* Selection changes only the registered program resource's implementation. Exact is
   emission-only Synthesis here: a Hardening declaration needs reviewed physical intent. *)
let project
  ?(overrides = Tt_cmos5l.overrides ())
  ?(selection = Resource_policy.Requirement.Flops)
  ?operation
  kind
  =
  let open Or_error.Let_syntax in
  let%bind () =
    match selection with
    | Flops -> Ok ()
    | Exact when String.equal kind "observable" ->
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
    | Exact, Flow.Operation.Hardening ->
      Or_error.error_string
        "exact Hardening is unsupported in PT.3a: reviewed macro physical placement intent is required; use synthesis"
    | _ -> Ok ()
  in
  let%bind policy =
    Resource_policy.create
      (if String.equal kind "observable"
       then []
       else
         [ { selector = Resource_policy.Selector.instance_exn "program"
           ; requirement = selection
           }
         ])
  in
  let design, name, title, description, pinout =
    match kind with
    | "observable" ->
      ( (module Observable_design : Project.Design)
      , "protemu_observable"
      , "Hardcaml protocol emulator"
      , "Programmable protocol emulator primitives generated by Hardcaml"
      , observable_pinout )
    | "memory" ->
      ( (module Memory_design : Project.Design)
      , "protemu_memory"
      , "Hardcaml protocol emulator memory consumer"
      , "P0.7 whole-word load and readback through registered program memory"
      , memory_pinout )
    | "loader" ->
      ( (module Package_top : Project.Design)
      , "protemu_loader"
      , "Hardcaml protocol emulator with independent hardware loader"
      , "P3.5 fixed serial loader, integrated core, and registered program memory"
      , loader_pinout )
    | _ -> failwith "kind must be observable, memory, or loader"
  in
  Project.create
    ~source_inputs:(input_paths kind)
    ~name
    ~metadata:{ title; author = "Bohdan Purtell"; description }
    ~design
    ~target:
      { harness = Tiny_tapeout { tiles = T6x4 }; technology = Technology.ihp_sg13cmos5l }
    ~flow:(Flow.librelane ~overrides operation)
    ~clocks:[ { Clock.port = "clk"; period = Time_float.Span.of_sec (1. /. 48e6) } ]
    ~timing:
      (Timing.create
         ~input_delays:
           (List.map [ "ui_in"; "uio_in"; "ena"; "rst_n" ] ~f:(fun port ->
              { Hardcaml_asic.Timing.Delay.port
              ; minimum = Time_float.Span.of_ns 0.
              ; maximum = Time_float.Span.of_ns 1.
              }))
         ~output_delays:
           (List.map [ "uo_out"; "uio_out"; "uio_oe" ] ~f:(fun port ->
              { Hardcaml_asic.Timing.Delay.port
              ; minimum = Time_float.Span.of_ns 0.
              ; maximum = Time_float.Span.of_ns 2.
              }))
         ())
    ~pinout
    ~policy
    ()
;;
