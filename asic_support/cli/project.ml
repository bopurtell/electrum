(* Silver's configured gateway and the compatibility entry point for existing scripts. *)
module U = Unix
open! Core
open Hardcaml_asic

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
    String.chop_suffix (U.realpath Stdlib.Sys.executable_name) ~suffix:"/asic_support/cli/project.exe"
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
  run
    ~listing:(fun () ->
      let manifest = catalog None in
      let chips = List.map (Chip_catalog.entries manifest) ~f:(fun entry ->
        let id = entry.id in
        let label = if String.equal id electrum.id then electrum.label else id in
        id, label)
      in
      display_listing ~default:(Chip_catalog.default_target manifest) chips)
    ~select_owner:(fun ?root id ->
      let entry = Chip_catalog.select (catalog root) ~id |> Or_error.ok_exn in
      if String.equal entry.id electrum.id
         && String.equal entry.executable "asics/electrum/cli/chip.exe"
      then electrum
      else forward entry ~explicit:(Option.is_some id))
;;
