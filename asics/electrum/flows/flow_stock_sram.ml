(* hardcaml-asic profile directory v1 *)
open! Core
open Hardcaml_asic

let create ~additional_profiles =
  Or_error.bind
    (Flow.Profile.create ~id:"timing_repair" ~label:"Post-global-route timing repair (opt-in)"
       ~description:"Chip-owned RUN_POST_GRT_RESIZER_TIMING override; not inherited by profile duplicates"
       ~assignments:[])
    ~f:(fun timing_repair ->
      Electrum_chip_project.Flow_declaration.entry
        ~id:"stock_sram" ~label:"Electrum / stock SRAM"
        ~description:"Exact stock IHP 256x16 SRAM; candidate placement, not physical acceptance"
        ~endpoints:(List.filter Flow.Stage.all ~f:(function Signoff -> false | _ -> true))
        ~additional_profiles ~profiles:[ timing_repair ] ())
;;
