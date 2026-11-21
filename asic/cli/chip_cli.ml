(* Shared chip CLI. All physical execution is delegated to the installed provider. *)
module U = Unix
open! Core
open Hardcaml_asic

let usage =
  "chip list [--json] | flow list|describe|plan|emit|run | \
   describe|prepare|preview|resources [--chip ID] [--variant default] [OPTIONS]"
;;
let bad message = failwith (message ^ "\n" ^ usage)
let ok = Or_error.ok_exn
let absolute path = if Filename.is_relative path then Filename.concat (U.getcwd ()) path else path
let rec discover path =
  if Stdlib.Sys.file_exists (Filename.concat path Chip_catalog.filename) then path
  else let parent = Filename.dirname path in
    if String.equal path parent || Stdlib.Sys.file_exists (Filename.concat path "dune-project")
    then bad "No chip catalog in this project; use --project-root"
    else discover parent
let rec mkdir path =
  try U.mkdir path 0o755 with
  | U.Unix_error (U.EEXIST, _, _) -> ()
  | U.Unix_error (U.ENOENT, _, _) -> mkdir (Filename.dirname path); mkdir path

let provider explicit =
  match explicit with
  | Some p -> absolute p
  | None ->
    String.split (Option.value (Sys.getenv "PATH") ~default:"") ~on:':'
    |> List.find_map ~f:(fun dir ->
      let p = absolute (Filename.concat dir "hardcaml-asic-flow") in
      try U.access p [ U.X_OK ]; Some p with _ -> None)
    |> Option.value_or_thunk ~default:(fun () -> bad "source scripts/env.sh to select installed ASIC")
;;

let check_provider path =
  let ch = U.open_process_args_in path [| path; "--version"; "--json" |] in
  let metadata = Yojson.Safe.from_channel ch in
  (match U.close_process_in ch with U.WEXITED 0 -> () | _ -> bad "provider metadata failed");
  let open Yojson.Safe.Util in
  match metadata |> member "cli_contract" |> member "version",
        metadata |> member "cli_contract" |> member "capabilities" |> member "namedflow1" with
  | `Int 4, `Bool true -> ()
  | _ -> bad "named flows require CLI4 + namedflow1"
;;

type owner =
  { id : string
  ; label : string
  ; catalog : unit -> Flow.Catalog.t Or_error.t
  ; source_inputs : string list
  ; target : flow:string -> profile:string -> Chip_target.t Or_error.t
  }

let electrum =
  let module Flows = Electrum_flows.Generated in
  { id = "electrum"
  ; label = "Electrum"
  ; catalog = (fun () -> Flows.create ~default_flow:"flops" ~default_profile:"balanced")
  ; source_inputs = "asics/electrum/cli/dune" :: "asics/electrum/cli/chip.ml" :: Flows.source_inputs
  ; target = Electrum_flows.Target.create
  }
;;

let display_listing ~default chips =
  let chip (id, label) =
    `Assoc [ "id", `String id; "label", `String label;
      "default_variant", `String "default";
      "variants", `List [`Assoc ["id", `String "default"; "label", `String "Default"]] ]
  in
  `Assoc [ "schema_version", `Int 1; "default_chip", `String default;
    "chips", `List (List.map chips ~f:chip) ]
;;

let flow_id entry =
  Flow.Catalog.Entry.methodology entry |> Flow.Methodology.id |> Flow.Selection.Id.to_string
;;

let choose_flow catalog flow =
  let id = Option.value_or_thunk flow ~default:(fun () ->
    Flow.Catalog.default catalog |> Flow.Selection.flow |> Option.value_exn
    |> Flow.Selection.Id.to_string) in
  List.find (Flow.Catalog.entries catalog) ~f:(fun entry -> String.equal id (flow_id entry))
  |> Option.value_or_thunk ~default:(fun () -> bad ("Unknown flow ID " ^ id))
;;

let target_for_flow owner resolved =
  let flow = Flow.Catalog.entry resolved |> flow_id in
  let profile = Flow.Catalog.profile resolved |> Flow.Profile.id |> Flow.Selection.Id.to_string in
  owner.target ~flow ~profile |> ok
;;

let main ~select_owner named command args =
  let json = ref false and verbose = ref false and simulation = ref false in
  let flow = ref None and profile = ref None and endpoint = ref None in
  let chip = ref None and variant = ref None in
  let root = ref None and source = ref None and results = ref None and expected = ref None in
  let provider_path = ref None and tools = ref None and support = ref None in
  let pdk = ref None and python = ref None and timeout = ref None and request = ref [] in
  let opt name dest = name, Stdlib.Arg.String (fun s ->
    if String.is_empty s || String.is_prefix s ~prefix:"--" || Option.is_some !dest
    then bad ("duplicate or missing value: " ^ name);
    dest := Some s), "VALUE " ^ name in
  let common = [ opt "--chip" chip; opt "--variant" variant;
                 "--json", Stdlib.Arg.Set json, "JSON output";
                 "--verbose", Stdlib.Arg.Set verbose, "Diagnostics" ] in
  let roots = [opt "--project-root" root; opt "--source-root" source] in
  let selection = [opt "--flow" flow; opt "--profile" profile] in
  let set text =
    let key, value = String.lsplit2 text ~on:'=' |> Option.value_or_thunk
      ~default:(fun () -> bad "--set requires KEY=VALUE") in
    let kind = Flow.Parameter.Key.of_string key |> ok |> Flow.Parameter.descriptor
      |> Flow.Parameter.value_type in
    let assignment = match kind with
      | Enum -> Flow.Parameter.of_string_value ~key value |> ok
      | Boolean ->
        let scalar = match Yojson.Safe.from_string value with
          | `Bool b -> `Bool b | _ -> bad "--set requires a JSON boolean" in
        Flow.Parameter.of_scalar ~key scalar |> ok
    in request := assignment :: !request
  in
  let preparation = selection @ roots @ [ opt "--endpoint" endpoint;
    "--set", Stdlib.Arg.String set, "KEY=VALUE typed parameter" ] in
  let options = common @
    (if named then match command with
     | "list" -> roots
     | "describe" -> roots @ [opt "--flow" flow]
     | "plan" -> preparation
     | "emit" -> preparation @ [opt "--results-root" results; opt "--expected-plan-identity" expected]
     | "run" -> preparation @ [opt "--results-root" results; opt "--expected-plan-identity" expected;
       opt "--provider" provider_path; opt "--toolchain" tools; opt "--support-tools" support;
       opt "--pdk-root" pdk; opt "--python" python; opt "--timeout" timeout]
     | _ -> bad "unknown flow command"
     else match command with
     | "describe" -> selection @ roots
     | "prepare" -> selection @ roots @ [opt "--results-root" results]
     | "preview" -> selection @ roots
     | "resources" -> selection @ roots @ ["--simulation", Stdlib.Arg.Set simulation, "Behavioral inventory"]
     | _ -> bad "unknown project command") in
  Stdlib.Arg.parse_argv ~current:(ref 0) (Array.of_list ("project" :: args)) options
    (fun s -> bad ("unexpected argument: " ^ s)) usage;
  (match !root, !source with
   | Some a, Some b when not (String.equal (U.realpath a) (U.realpath b)) -> bad "conflicting roots"
   | _ -> ());
  let print value = printf "%s\n%!" (if !json then Yojson.Safe.to_string value else Yojson.Safe.pretty_to_string value) in
  let owner = select_owner ?root:(Option.first_some !root !source) !chip in
  Option.iter !variant ~f:(fun id ->
    if not (String.equal id "default") then bad ("Unknown variant for " ^ owner.id ^ ": " ^ id));
  let catalog = owner.catalog () |> ok in
  if named && String.equal command "list" then print (Flow_spec.list_to_yojson catalog)
  else if named && String.equal command "describe" then (
    if Option.is_none !flow then bad "flow describe requires --flow";
    print (Flow_spec.describe_to_yojson (choose_flow catalog !flow)))
  else (
    let source_root () = match !root, !source with
      | Some a, _ | _, Some a -> U.realpath a
      | _ -> discover (U.getcwd ()) in
    if not named then (
      if Option.is_some !profile then bad "--profile is supported by named flows only";
      let entry = choose_flow catalog !flow in
      let selected_flow = flow_id entry in
      let endpoint = Flow.Methodology.endpoints (Flow.Catalog.Entry.methodology entry) |> List.hd_exn in
      let selection = Flow.Selection.create ?flow:!flow () |> ok in
      let resolved = Flow.Catalog.resolve ~selection catalog ~endpoint () |> ok in
      let target = target_for_flow owner resolved in
      match command with
      | "describe" -> print (`Assoc ["project_name", `String (Chip_target.name target);
          "declaration_sexp", `String (Sexp.to_string_hum (Chip_target.describe target))])
      | "resources" ->
        let snapshot = if !simulation then
          Chip_target.elaborate target ~mode:Simulation |> ok |> Resource_snapshot.of_elaborated
          else Chip_target.elaborate_for_flow target |> ok |> Resource_snapshot.of_resolved in
        print (Resource_snapshot.to_json snapshot)
      | "preview" ->
        (match Chip_target.prepare_resources ~methodology:resolved ~catalog_inputs:owner.source_inputs
                 target ~source_root:(source_root ()) with
         | Ok p -> printf "%s%!" (Resource_preparation.to_string p)
         | Error e -> print (Resource_preparation.Failure.to_json e); Stdlib.exit 1)
      | "prepare" ->
        let source_root = source_root () in
        let store = Option.value_map !results ~f:absolute
          ~default:(Filename.concat source_root "_flow_results/workbench/preparation") in
        let module E = Hardcaml_asic_execution in
        let request = E.Identity_json.parse (Yojson.Safe.to_string (`Assoc
          (["project", `String (Chip_target.name target);
            "flow", `String selected_flow; "source_root", `String source_root]
           @ Option.value_map !variant ~default:[] ~f:(fun id -> ["variant", `String id]))))
          |> Result.map_error ~f:E.Identity_json.error_message |> Result.ok_or_failwith in
        let outcome = E.Preparation_service.run_cli ~store ~request ~json:!json
          ~prepare:(fun ~on_phase -> Chip_target.prepare_resources ~on_phase ~methodology:resolved
            ~catalog_inputs:owner.source_inputs target ~source_root) () in
        Stdlib.exit (Option.value outcome.record.exit_code ~default:1)
      | _ -> bad "unknown command")
    else (
      let source_root = source_root () in
      let endpoint = Option.value_or_thunk !endpoint ~default:(fun () -> bad "--endpoint is required")
        |> Flow.Stage.of_string |> ok in
      if String.equal command "run" && Option.is_none !expected then bad "run requires --expected-plan-identity";
      Option.iter !timeout ~f:(fun s -> if Int.of_string s <= 0 then bad "--timeout must be positive");
      let selection = Flow.Selection.create ?flow:!flow ?profile:!profile () |> ok in
      let request = Flow.Parameter.check_assignments ~configurable:Flow.Parameter.Key.all !request |> ok in
      let resolved = Flow.Catalog.resolve ~selection ~request catalog ~endpoint () |> ok in
      let target = target_for_flow owner resolved in
      let prepared = Methodology_plan.prepare ~catalog ~selection ~request ~endpoint
        ~catalog_inputs:owner.source_inputs ?expected_plan_identity:!expected target ~source_root |> ok in
      let plan = Methodology_plan.Prepared.plan prepared in
      if String.equal command "plan" then print (Methodology_plan.to_yojson plan)
      else (
        let provider = if String.equal command "run" then Some (provider !provider_path) else None in
        Option.iter provider ~f:check_provider;
        let results = Option.value_map !results ~f:absolute ~default:(Filename.concat source_root "_flow_results/workbench/asic") in
        let bundle = Methodology_plan.Prepared.bundle prepared in
        let published = Bundle.publish bundle ~store_dir:(Filename.concat results "bundles") |> ok in
        if String.equal command "emit" then print (`Assoc ["schema_version", `Int 1;
          "kind", `String "bundle_emission"; "bundle_identity", `String (Bundle.identity bundle);
          "plan_identity", `String (Methodology_plan.plan_identity plan); "output_dir", `String published.directory;
          "reused", `Bool published.reused; "plan", Methodology_plan.to_yojson plan])
        else (
          let workspace = Filename.concat results (sprintf "attempt-%d-%08x%08x" (U.getpid ())
            (Stdlib.Random.bits ()) (Stdlib.Random.bits ())) in
          let launch = workspace ^ ".plan.json" in
          mkdir results;
          let fd = U.openfile launch [U.O_WRONLY; U.O_CREAT; U.O_EXCL] 0o444 in
          let ch = U.out_channel_of_descr fd in
          Out_channel.output_string ch (Methodology_plan.to_string plan); Out_channel.close ch;
          let toolchain = Option.value_map !tools ~f:absolute ~default:(Filename.concat source_root "_flow_tools") in
          let resolve override suffix = Option.value_map override ~f:absolute ~default:(Filename.concat toolchain suffix) in
          let argv = ["stages"; published.directory; "--methodology-plan"; launch;
            "--expected-plan-identity"; Methodology_plan.plan_identity plan; "--workspace"; workspace;
            "--checkpoint-store"; Filename.concat workspace "checkpoints";
            "--support-tools"; resolve !support "tt"; "--pdk-root"; resolve !pdk "pdk";
            "--python"; resolve !python
              (if Stdlib.Sys.file_exists (Filename.concat toolchain ".venv/bin/python")
               then ".venv/bin/python" else "venv/bin/python")]
            @ Option.value_map !timeout ~default:[] ~f:(fun s -> ["--timeout"; s])
            @ (if !json then ["--json"] else []) @ (if !verbose then ["--verbose"] else []) in
          let provider = Option.value_exn provider in
          U.execv provider (Array.of_list (provider :: argv))))))
;;

let run ~listing ~select_owner =
  Stdlib.Random.self_init ();
  try match Array.to_list (Sys.get_argv ()) with
    | [_; ("--help" | "-h")] -> printf "%s\n" usage
    | [_; "list"; "--json"] | [_; "chip"; "list"; "--json"] ->
      printf "%s\n" (Yojson.Safe.to_string (listing ()))
    | [_; "list"] | [_; "chip"; "list"] ->
      printf "%s\n" (Yojson.Safe.pretty_to_string (listing ()))
    | _ :: "flow" :: command :: args -> main ~select_owner true command args
    | _ :: command :: args -> main ~select_owner false command args
    | _ -> bad "command required"
  with
  | Stdlib.Arg.Help s -> printf "%s" s
  | exn -> eprintf "chip: %s\n%!" (Exn.to_string exn); Stdlib.exit 2
;;

let run_owner owner =
  let id = owner.id in
  run
    ~listing:(fun () -> display_listing ~default:id [ id, owner.label ])
    ~select_owner:(fun ?root:_ chip ->
      Option.iter chip ~f:(fun requested ->
        if not (String.equal requested id)
        then bad ("Chip not owned by this executable: " ^ requested));
      owner)
;;
