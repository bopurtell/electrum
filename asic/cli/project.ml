(* Silver's configured gateway and the compatibility entry point for existing scripts. *)
module U = Unix
module Loader = Electrum_loader_flows.Generated
module Memory = Electrum_memory_flows.Generated
module Observable = Electrum_observable_flows.Generated
open! Core
open Hardcaml_asic
open Electrum_chip_project

let catalog root =
  let root = match root with
    | Some root -> U.realpath root
    | None -> Chip_cli.discover (U.getcwd ())
  in
  Chip_catalog.load (Filename.concat root Chip_catalog.filename) |> Or_error.ok_exn
;;

let forward (entry : Chip_catalog.entry) ~explicit =
  let guard = "ELECTRUM_FORWARDED_CHIP" in
  if Option.is_some (Sys.getenv guard) then Chip_cli.bad "Chip executable points back to the gateway";
  let context =
    String.chop_suffix (U.realpath Stdlib.Sys.executable_name) ~suffix:"/asic/cli/project.exe"
    |> Option.value_or_thunk ~default:(fun () -> Chip_cli.bad "Cannot locate Electrum CLI build context")
  in
  let path = Filename.concat context entry.executable in
  (try U.access path [ U.X_OK ] with
   | U.Unix_error _ -> Chip_cli.bad ("Build the selected chip first: " ^ entry.executable));
  let argv = Sys.get_argv () in
  argv.(0) <- path;
  let argv = if explicit then argv else Array.append argv [| "--chip"; entry.id |] in
  U.execve path argv (Array.append (U.environment ()) [| guard ^ "=" ^ entry.id |])
;;

let () =
  let open Chip_cli in
  let builtins =
    [ owner Loader ~create:Loader.create ~source_inputs:Loader.source_inputs ~target:Electrum_loader_flows.Target.create
    ; owner Memory ~create:Memory.create ~source_inputs:Memory.source_inputs ~target:Electrum_memory_flows.Target.create
    ; owner Observable ~create:Observable.create ~source_inputs:Observable.source_inputs ~target:Electrum_observable_flows.Target.create
    ]
  in
  run
    ~listing:(fun () ->
      let manifest = catalog None in
      let chips = List.map (Chip_catalog.entries manifest) ~f:(fun entry ->
        let id = entry.id in
        let label = Result.ok (Chip_kind.of_string id) |> Option.value_map ~default:id ~f:Chip_kind.label in
        id, label)
      in
      display_listing ~default:(Chip_catalog.default_target manifest) chips)
    ~select_owner:(fun ?root id ->
      let entry = Chip_catalog.select (catalog root) ~id |> Or_error.ok_exn in
      match List.find builtins ~f:(fun owner ->
        let id = Chip_kind.id owner.kind in
        String.equal id entry.id
        && String.equal entry.executable ("asics/" ^ id ^ "/cli/chip.exe")) with
      | Some owner -> owner
      | None -> forward entry ~explicit:(Option.is_some id))
;;
