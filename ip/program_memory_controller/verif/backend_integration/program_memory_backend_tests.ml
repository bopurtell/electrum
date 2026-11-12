(* P0.7 integration of protemu's consumer with hardcaml_asic's registered RAM. *)

open! Core
open! Hardcaml
open! Hardcaml_asic
open! Protemu_f_model
open! Protocol_core_testbench

let build = Program_memory_backend_design.build

let check_resource build ~mode =
  let resources = Elaborated_project.resources build in
  assert (List.length resources = 1);
  let resource = List.hd_exn resources in
  assert (String.equal (Resource.Id.to_string resource.id) "program");
  assert (String.equal resource.request.kind "single_port_ram");
  assert (
    Sexp.equal
      resource.request.contract
      (Sexp.of_string
         "((width 16) (depth 256) (read_latency 1) (port 1rw) (disabled_output hold) \
          (write_output unspecified))"));
  assert (Resource_policy.Requirement.equal resource.requirement Flops);
  assert (Resource_policy.Applied.equal resource.policy Default);
  assert (Resource.Selection.Implementation.equal resource.selection.implementation Flops);
  assert (Resource.Selection.Reason.equal resource.selection.reason Explicit_flops);
  let elaboration, sources =
    match mode with
    | Elaboration.Mode.Simulation ->
      Resource.Record.Elaborated_as.Behavioral_model,
      [ Resource.Record.Source.Generated_behavioral_model ]
    | Implementation -> Selected_implementation, [ Generated_synthesis_rtl ]
  in
  assert (Resource.Record.Elaborated_as.equal resource.elaborated_as elaboration);
  assert ([%equal: Resource.Record.Source.t list] resource.sources sources)
;;

let run mode =
  let build = build mode in
  check_resource build ~mode;
  let t = create ~circuit:(Elaborated_project.circuit build) () in
  let words = [ 0x00ff; 0xa55a; 0xffff ] in
  complete_load t words;
  step t (input ~readback:(1, false, 0) ());
  check t.edge "read request has no same-edge response" None t.model.response.readback;
  step t (input ());
  check
    t.edge
    "registered read response after disabled port cycle"
    (Some (0xa55a, false))
    t.model.response.readback;
  step t (input ());
  check
    t.edge
    "held output is not consumed without validity"
    None
    t.model.response.readback;
  let before = memory_snapshot t in
  step t (input ~load_write:(3, 0x1234) ());
  check
    t.edge
    "rejected write did not alter valid storage"
    true
    (Array.equal (Option.equal Int.equal) before t.store.words);
  step t (input ~run:true ());
  step t (input ~fetch:2 ());
  step t (input ());
  check
    t.edge
    "fetch returned a defined written word"
    (Some 0xffff)
    t.model.response.fetch
;;

let run_acceptance mode =
  let build = build mode in
  check_resource build ~mode;
  let circuit = Elaborated_project.circuit build in
  let create poison = create ~poison ~circuit () in
  Protocol_core_unit_tests.run_all create;
  match Protocol_core_property_tests.quickcheck ~circuit ~here:[%here] () with
  | None -> ()
  | Some failure -> failwith failure
;;

let%test_unit "behavioral RAM elaboration serves the protemu consumer" =
  run Elaboration.Mode.Simulation
;;

let%test_unit "explicit flop RAM elaboration serves the protemu consumer" =
  run Elaboration.Mode.Implementation
;;

let%test_unit "behavioral RAM reruns P3.1a directed and generated acceptance" =
  run_acceptance Elaboration.Mode.Simulation
;;

let%test_unit "explicit flop RAM reruns P3.1a directed and generated acceptance" =
  run_acceptance Elaboration.Mode.Implementation
;;
