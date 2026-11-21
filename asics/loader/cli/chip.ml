module Flows = Electrum_loader_flows.Generated

let () =
  Chip_cli.run_owner
    (Chip_cli.owner Loader ~create:Flows.create ~source_inputs:Flows.source_inputs
       ~target:Electrum_loader_flows.Target.create)
;;
