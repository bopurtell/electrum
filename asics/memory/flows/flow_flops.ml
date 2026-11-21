(* hardcaml-asic profile directory v1 *)
open Hardcaml_asic

let create ~additional_profiles =
  Electrum_chip_project.Flow_declaration.entry ~id:"flops" ~label:"Memory / flops"
    ~description:"Program memory bring-up with flop-backed storage"
    ~endpoints:Flow.Stage.all ~additional_profiles ()
;;
