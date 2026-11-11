(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Stable bundle CLI; chip construction and source inventory belong to Chip_project. *)

open! Core
open! Hardcaml_asic
open! Protemu_chip_project

let check_conflicts kind =
  List.iter
    [ "CLOCK_PERIOD", "clock"; "VERILOG_FILES", "source"; "DIE_AREA", "target" ]
    ~f:(fun (key, label) ->
      let conflicting : Flow.Librelane.Override.t =
        { key; value = `Int 1; reason = "negative integration check" }
      in
      let result =
        Chip_project.project
          ~overrides:(Tt_cmos5l.overrides ~extra:[ conflicting ] ())
          kind
        |> Or_error.bind ~f:Project.elaborate_for_flow
      in
      match result with
      | Ok _ -> failwithf "%s conflict was accepted" label ()
      | Error error ->
        let diagnostic = Error.to_string_hum error in
        if not (String.is_substring diagnostic ~substring:key)
        then failwithf "%s conflict did not identify %s: %s" label key diagnostic ());
  printf "PASS clock, source-list, and target configuration conflicts\n"
;;

let emit kind output_dir source_root =
  let project = Chip_project.project kind |> Or_error.ok_exn in
  let resolved = Project.elaborate_for_flow project |> Or_error.ok_exn in
  let simulation_build = Project.elaborate project ~mode:Simulation |> Or_error.ok_exn in
  let bundle =
    Bundle.render
      ~simulation_build
      ~source_root
      ~input_paths:(Chip_project.input_paths kind)
      resolved
    |> Or_error.ok_exn
  in
  Bundle.write bundle ~output_dir |> Or_error.ok_exn;
  printf "%s %s\n" output_dir (Bundle.identity bundle)
;;

let () =
  match Array.to_list Stdlib.Sys.argv with
  | [ _; "--check-conflicts" ] -> check_conflicts "observable"
  | [ _; "--check-conflicts"; kind ] -> check_conflicts kind
  | [ _; output_dir; source_root ] -> emit "observable" output_dir source_root
  | [ _; kind; output_dir; source_root ] -> emit kind output_dir source_root
  | _ ->
    failwith
      "usage: asic_bundle [observable|memory|loader] OUTPUT_DIR SOURCE_ROOT | \
       --check-conflicts [observable|memory|loader]"
;;
