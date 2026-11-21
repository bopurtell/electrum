(* hardcaml-asic profile directory v1 *)
open Hardcaml_asic

let create ~additional_profiles =
  Electrum_chip_project.Flow_declaration.entry ~id:"stock_sram_synthesis"
    ~label:"Memory / stock SRAM synthesis"
    ~description:"Exact stock IHP 256x16 SRAM; no reviewed physical placement for this chip"
    ~endpoints:[ Flow.Stage.Synthesis ] ~additional_profiles ()
;;
