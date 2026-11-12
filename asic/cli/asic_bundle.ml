(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Stable bundle CLI; chip construction and source inventory belong to Chip_project. *)

open! Core
open! Hardcaml_asic
open! Protemu_chip_project

let check_conflicts ~selection ?operation kind =
  List.iter
    [ "CLOCK_PERIOD", "clock"; "VERILOG_FILES", "source"; "DIE_AREA", "target" ]
    ~f:(fun (key, label) ->
      let conflicting : Flow.Librelane.Override.t =
        { key; value = `Int 1; reason = "negative integration check" }
      in
      let result =
        Chip_project.project
          ~selection
          ?operation
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

let emit ~selection ?operation kind output_dir source_root =
  let project = Chip_project.project ~selection ?operation kind |> Or_error.ok_exn in
  let bundle =
    Project.emit_bundle project ~source_root ~output_dir |> Or_error.ok_exn
  in
  printf "%s %s\n" output_dir (Bundle.identity bundle)
;;

let usage =
  "usage: asic_bundle [--selection flops|exact] [--operation synthesis|hardening] \
   [observable|memory|loader] OUTPUT_DIR SOURCE_ROOT | \
   --check-conflicts [observable|memory|loader]\n\
   Defaults: flops/hardening; exact defaults to synthesis.\n\
   Exact requires memory or loader; exact hardening requires reviewed physical intent \
   and is unsupported in PT.3a.\n"
;;

(* Strip additive options without changing the legacy positional forms. Repeated,
   incomplete and unknown options fail before elaboration or output publication. *)
let main () =
  let rec parse selection operation positional = function
    | [] ->
      Option.value selection ~default:Resource_policy.Requirement.Flops,
      operation,
      List.rev positional
    | "--selection" :: value :: rest when Option.is_none selection ->
      let selection =
        match value with
        | "flops" -> Resource_policy.Requirement.Flops
        | "exact" -> Exact
        | _ -> failwith "--selection must be flops or exact"
      in
      parse (Some selection) operation positional rest
    | "--operation" :: value :: rest when Option.is_none operation ->
      let operation =
        match value with
        | "synthesis" -> Flow.Operation.Synthesis
        | "hardening" -> Hardening
        | _ -> failwith "--operation must be synthesis or hardening"
      in
      parse selection (Some operation) positional rest
    | "--check-conflicts" :: rest ->
      parse selection operation ("--check-conflicts" :: positional) rest
    | arg :: _ when String.is_prefix arg ~prefix:"-" ->
      failwithf "unknown, repeated, or incomplete option: %s" arg ()
    | arg :: rest -> parse selection operation (arg :: positional) rest
  in
  match Array.to_list Stdlib.Sys.argv |> List.tl_exn with
  | [ "--help" ] | [ "-h" ] -> printf "%s" usage
  | args ->
    let selection, operation, positional = parse None None [] args in
    (match positional with
     | [ "--check-conflicts" ] -> check_conflicts ~selection ?operation "observable"
     | [ "--check-conflicts"; kind ] -> check_conflicts ~selection ?operation kind
     | [ output_dir; source_root ] ->
       emit ~selection ?operation "observable" output_dir source_root
     | [ kind; output_dir; source_root ] ->
       emit ~selection ?operation kind output_dir source_root
     | _ -> failwith usage)
;;

let () =
  try main () with
  | exn ->
    eprintf "asic_bundle: %s\n%!" (Exn.to_string exn);
    Stdlib.exit 2
;;
