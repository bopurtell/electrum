(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "emit_event_response.ml" *)
(* Verification-only composition: production core + production program RAM helper.
   Project.elaborate deliberately stops before TT interface/physical-flow resolution.
   Direct Control_port transport; no Host_link, TT package/reset/pad wrapper.
   There is no external RAM-data input or other bypass for the selected RAM. *)
open! Core
open! Hardcaml
open! Hardcaml_asic
open! Protemu_core

module Design = struct
  module I = struct
    type 'a t =
      { clock_i : 'a
      ; reset_i : 'a
      ; en_i : 'a
      ; control_request_i : 'a Control_port.Request.t [@rtlsuffix "_i"]
      ; pin_async_i : 'a [@bits 8]
      ; software_claim_valid_i : 'a
      ; software_claim_mask_i : 'a [@bits 8]
      }
    [@@deriving hardcaml ~rtlmangle:false]
  end
  module O = Emulator_core.O
  let name = "protemu_event_response"

  let create context (i : _ I.t) =
    let read_data = Signal.wire 16 in
    let o = Emulator_core.create (Elaboration.Context.scope context)
      { Emulator_core.I.clock_i = i.clock_i
      ; reset_i = i.reset_i
      ; en_i = i.en_i
      ; control_request_i = i.control_request_i
      ; prog_mem_read_data_i = read_data
      ; pin_async_i = i.pin_async_i
      ; software_claim_valid_i = i.software_claim_valid_i
      ; software_claim_mask_i = i.software_claim_mask_i
      ; step_valid_i = Signal.gnd
      ; occupied_i = Signal.zero 8
      ; software_release_valid_i = Signal.gnd
      ; software_release_mask_i = Signal.zero 8
      ; tx_ready_i = Signal.gnd
      ; rx_valid_i = Signal.gnd
      ; rx_data_i = Signal.zero 8
      ; transfer_rx_ready_i = Signal.vdd
      } in
    Signal.assign read_data
      (Protemu_asic_rtl.Program_memory.create context ~clock:i.clock_i
         ~enable:o.prog_mem_enable_o ~write_enable:o.prog_mem_write_enable_o
         ~address:o.prog_mem_address_o ~write_data:o.prog_mem_write_data_o);
    o
end

let () =
  try
    let args = Sys.get_argv () in
    if Array.length args <> 4 then
      failwith "usage: emit_event_response flops|exact behavioral|implementation EXISTING_OUTPUT_DIR";
    let requirement = match args.(1) with
      | "flops" -> Resource_policy.Requirement.Flops
      | "exact" -> Exact
      | _ -> failwith "selection must be flops or exact" in
    let mode = match args.(2) with
      | "behavioral" -> Elaboration.Mode.Simulation
      | "implementation" -> Implementation
      | _ -> failwith "mode must be behavioral or implementation" in
    let policy = Resource_policy.create
      [{ selector = Resource_policy.Selector.instance_exn "program"; requirement }]
      |> Or_error.ok_exn in
    let project = Project.create ~name:"protemu_event_response_verification"
      ~metadata:{title="Event response verification"; author="Protemu";
                 description="Production loaded core with observed public ports"}
      ~design:(module Design)
      ~target:{harness=Tiny_tapeout {tiles=T6x4}; technology=Technology.ihp_sg13cmos5l}
      ~flow:(Flow.librelane Synthesis) ~policy () |> Or_error.ok_exn in
    let elaborated = Project.elaborate project ~mode |> Or_error.ok_exn in
    let circuit = Elaboration.Elaborated_project.circuit elaborated in
    let resources = Elaboration.Elaborated_project.resources elaborated in
    if List.length resources <> 1 then failwith "expected exactly one program resource";
    let rtl = Rtl.create Verilog [circuit] |> Rtl.full_hierarchy |> Rope.to_string in
    Out_channel.write_all (Filename.concat args.(3) "top.v") ~data:rtl;
    Out_channel.write_all (Filename.concat args.(3) "elaboration.sexp")
      ~data:(Sexp.to_string_hum (Elaboration.Elaborated_project.sexp_of_t elaborated) ^ "\n");
    let module C = Protemu_controller.Program_memory_controller.Config in
    let composition = `Assoc
      [ "system_boundary", `String "core+Program_memory"
      ; "top_module", `String Design.name
      ; "core", `String "Protemu_core.Emulator_core"
      ; "memory", `String "Protemu_asic_rtl.Program_memory"
      ; "host_transport", `String "direct-control-port"
      ; "host_link", `Bool false
      ; "package_wrapper", `Bool false
      ; "program_depth", `Int C.program_depth
      ; "program_width", `Int C.program_width
      ; "read_latency_edges", `Int 1
      ] in
    Out_channel.write_all (Filename.concat args.(3) "composition.json")
      ~data:(Yojson.Safe.to_string composition ^ "\n")
  with exn -> eprintf "%s\n%!" (Exn.to_string exn); Stdlib.exit 2
