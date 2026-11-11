open! Core
open! Hardcaml
open! Hardcaml_asic
open! Hardcaml_protemu

module I = Tt_cmos5l.I
module O = Tt_cmos5l.O

let name = "tt_um_leemperor_hardcaml_protemu_loader"

let create context (i : _ I.t) =
  let open Signal in
  let core_reset = Tt_cmos5l.synchronised_reset ~clock:i.clk ~rst_n:i.rst_n () in
  let memory_read_data = wire Program_memory_controller.Config.program_width in
  let system =
    Protemu_top.create
      (Elaboration_context.scope context)
      { Protemu_top.I.clock_i = i.clk
      ; reset_i = core_reset
      ; enable_i = i.ena
      ; serial_select_n_i = bit i.ui_in ~pos:0
      ; serial_clock_i = bit i.ui_in ~pos:1
      ; serial_data_i = bit i.ui_in ~pos:2
      ; prog_mem_read_data_i = memory_read_data
      ; pin_async_i = i.uio_in
      ; occupied_i = zero Protemu_isa.Pins.count
      }
  in
  let ram_read_data =
    Program_memory.create
      context
      ~clock:i.clk
      ~enable:system.prog_mem_enable_o
      ~write_enable:system.prog_mem_write_enable_o
      ~address:system.prog_mem_address_o
      ~write_data:system.prog_mem_write_data_o
  in
  assign memory_read_data ram_read_data;
  let pads_enabled = i.rst_n &: i.ena &: ~:core_reset in
  { O.uo_out =
      Tt_cmos5l.gate
        ~enable:pads_enabled
        (concat_msb [ zero 6; system.serial_ready_o; system.serial_data_o ])
  ; uio_out = Tt_cmos5l.gate ~enable:pads_enabled system.pins_o
  ; uio_oe = Tt_cmos5l.gate ~enable:pads_enabled system.pin_oe_o
  }
;;
