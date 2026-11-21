(* hardcaml-asic profile directory v1 *)
open Hardcaml_asic

let create ~additional_profiles =
  Electrum_chip_project.Flow_declaration.entry ~id:"flops" ~label:"Electrum / flops"
    ~description:"Fresh Electrum physical prefixes with explicit flop program memory"
    ~endpoints:Flow.Stage.all ~additional_profiles ()
;;
