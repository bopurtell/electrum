open Electrum_chip_project

let create ~flow ~profile:_ =
  match flow with
  | "stock_sram_synthesis" -> Chip_project.chip_target ~selection:Exact ~operation:Synthesis Memory
  | _ -> Chip_project.chip_target Memory
;;
