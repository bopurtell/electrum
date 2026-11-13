open! Core
open Hardcaml_asic

let source_inputs = [ "asic/project/flow_catalog.ml"; "asic/cli/project.ml" ]

let create () =
  let open Or_error.Let_syntax in
  let%bind profile =
    Flow.Profile.create ~id:"balanced" ~label:"Balanced"
      ~description:"Current Electrum synthesis defaults; unchanged timing envelope"
      ~assignments:[]
  in
  let%bind timing_repair =
    Flow.Profile.create ~id:"timing_repair" ~label:"Post-global-route timing repair (opt-in)"
      ~description:"Project-owned override RUN_POST_GRT_RESIZER_TIMING=true: opt-in post-global-route setup/hold repair; preserves AREA 0, all three RSZ corners, 48 MHz timing intent and macro placement"
      ~assignments:[]
  in
  let entry id label description =
    let%bind methodology =
      Flow.Methodology.create ~id ~label ~description
        ~backend_recipe:Librelane_classic_v1
        ~endpoints:(if String.equal id "stock_sram" then
          List.filter Flow.Stage.all ~f:(fun stage -> not (String.equal (Flow.Stage.to_string stage) "signoff"))
          else Flow.Stage.all)
        ~configurable:Flow.Parameter.Key.all ~defaults:[]
    in
    Flow.Catalog.Entry.create ~methodology
      ~profiles:(if String.equal id "stock_sram" then [ profile; timing_repair ] else [ profile ])
      ~default_profile:"balanced"
  in
  let%bind flops = entry "flops" "Loader / flops"
    "Fresh loader physical prefixes with explicit flop program memory" in
  let%bind sram = entry "stock_sram" "Loader / stock SRAM"
    "Fresh loader physical prefixes with exact stock IHP 256x16 SRAM; candidate placement, not physical acceptance" in
  Flow.Catalog.create ~entries:[ flops; sram ] ~default_flow:"flops" ~default_profile:"balanced"
;;

let project ?(profile = "balanced") flow =
  let selection = match flow with
    | "flops" -> Resource_policy.Requirement.Flops
    | "stock_sram" -> Exact
    | _ -> failwith "unknown flow; expected flops or stock_sram"
  in
  let operation = Flow.Operation.Hardening in
  let overrides =
    match flow, profile with
    | _, "balanced" -> None
    | "stock_sram", "timing_repair" ->
      Some (Chip_project.default_overrides ~selection ~operation @
        [ { Flow.Librelane.Override.key = "RUN_POST_GRT_RESIZER_TIMING"
          ; value = `Bool true
          ; reason = "Explicit stock_sram/timing_repair candidate: enable post-global-route setup/hold repair without changing synthesis strategy, timing intent, resource policy or placement"
          } ])
    | _ -> failwith "unsupported profile for this flow; timing_repair is opt-in stock_sram only"
  in
  Chip_project.project ?overrides ~selection ~operation "loader"
;;
