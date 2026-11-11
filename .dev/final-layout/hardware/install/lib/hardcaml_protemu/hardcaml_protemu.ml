(* Source compatibility for the former flat hardware library. Keep these aliases
   type-identical to the owner libraries; no hardware is compiled in this facade. *)
module Byte_fifo = Protemu_mechanisms.Byte_fifo
module Input_events = Protemu_mechanisms.Input_events
module Pin_bank = Protemu_mechanisms.Pin_bank
module Shift_lane = Protemu_mechanisms.Shift_lane
module Timing = Protemu_mechanisms.Timing
module Observed_transfer = Protemu_mechanisms_staging.Observed_transfer
module Observed_transfer_bank = Protemu_mechanisms_staging.Observed_transfer_bank
module Primitive_demo = Protemu_mechanisms_staging.Primitive_demo
module Uart_slice = Protemu_mechanisms_staging.Uart_slice
module Uart_tx = Protemu_mechanisms_staging.Uart_tx
module Program_memory_controller = Protemu_controller.Program_memory_controller
module Control_port = Protemu_core.Control_port
module Emulator_core = Protemu_core.Emulator_core
module Execution_unit = Protemu_core.Execution_unit
module Instruction_decoder = Protemu_core.Instruction_decoder
module Primitive_dispatch = Protemu_core.Primitive_dispatch
module Executable_core = Protemu_core_legacy.Executable_core
module Command_dispatch = Protemu_host_link.Command_dispatch
module Frame_rx = Protemu_host_link.Frame_rx
module Frame_tx = Protemu_host_link.Frame_tx
module Host_link = Protemu_host_link.Host_link
module Serial_phy = Protemu_host_link.Serial_phy
module Wire_crc = Protemu_host_link.Wire_crc
module Wire_layout = Protemu_host_link.Wire_layout
module Protemu_top = Protemu_system.Protemu_top
module P0_observable = Protemu_asic_bringup.P0_observable
