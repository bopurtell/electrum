open! Core
open! Hardcaml_asic
open! Protemu_controller

let create context ~clock ~enable ~write_enable ~address ~write_data =
  let memory_config =
    Single_port_ram.Config.create_exn
      ~width:Program_memory_controller.Config.program_width
      ~depth:Program_memory_controller.Config.program_depth
      ~read_latency:1
  in
  Single_port_ram.create
    context
    ~name:"program"
    memory_config
    ~clock
    ~enable
    ~write_enable
    ~address
    ~write_data
;;
