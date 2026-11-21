open Hardcaml_asic
open Electrum_chip_project

let create ~flow ~profile =
  match flow with
  | "stock_sram" ->
    let selection = Resource_policy.Requirement.Exact in
    let operation = Flow.Operation.Hardening in
    let overrides =
      if String.equal profile "timing_repair"
      then Some (Chip_project.default_overrides ~selection ~operation @
        [ { Flow.Librelane.Override.key = "RUN_POST_GRT_RESIZER_TIMING"
          ; value = `Bool true
          ; reason = "Explicit stock_sram/timing_repair candidate: enable post-global-route setup/hold repair without changing synthesis strategy, timing intent, resource policy or placement"
          } ])
      else None
    in
    Chip_project.chip_target ?overrides ~selection ~operation Loader
  | _ -> Chip_project.chip_target Loader
;;
