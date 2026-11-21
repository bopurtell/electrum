module Flows = Electrum_memory_flows.Generated

let () =
  Chip_cli.run_owner
    (Chip_cli.owner Memory ~create:Flows.create ~source_inputs:Flows.source_inputs
       ~target:Electrum_memory_flows.Target.create)
;;
