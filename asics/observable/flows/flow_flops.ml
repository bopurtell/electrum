(* hardcaml-asic profile directory v1 *)
open Hardcaml_asic

let create ~additional_profiles =
  Electrum_chip_project.Flow_declaration.entry ~id:"flops" ~label:"Observable / flops"
    ~description:"Protocol mechanisms bring-up; no registered program memory"
    ~endpoints:Flow.Stage.all ~additional_profiles ()
;;
