module Flows = Electrum_observable_flows.Generated

let () =
  Chip_cli.run_owner
    (Chip_cli.owner Observable ~create:Flows.create ~source_inputs:Flows.source_inputs
       ~target:Electrum_observable_flows.Target.create)
;;
