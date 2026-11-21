open! Core
open! Hardcaml
open! Hardcaml_asic
open! Electrum_asic_bringup
module I = Tt_cmos5l.I
module O = Tt_cmos5l.O

(* We have about a square um of space. *)
let name = "tt_um_leemperor_electrum"

let create context (i : _ I.t) =
  let open Signal in
  let core_reset = Tt_cmos5l.synchronised_reset ~clock:i.clk ~rst_n:i.rst_n () in
  let core =
    P0_observable.create
      (Elaboration.Context.scope context)
      { P0_observable.I.clock_i = i.clk
      ; reset_i = core_reset
      ; enable_i = i.ena
      ; command_valid_i = bit i.ui_in ~pos:6
      ; delay_i = select i.ui_in ~high:3 ~low:0
      ; pin_value_i = concat_msb [ zero 7; bit i.ui_in ~pos:4 ]
      ; pin_oe_i = concat_msb [ zero 7; bit i.ui_in ~pos:5 ]
      }
  in
  (* The status byte is held low through the core reset as well, so a reader cannot
     mistake the reset state of the timer for a command result. *)
  let pads_enabled = i.rst_n &: i.ena in
  { O.uo_out =
      Tt_cmos5l.gate
        ~enable:(pads_enabled &: ( ~: ) core_reset)
        (concat_msb
           [ core.rejected_o; core.done_o; core.busy_o; core.ready_o; core.timer_o ])
  ; uio_out = Tt_cmos5l.gate ~enable:pads_enabled core.pins_o
  ; uio_oe = Tt_cmos5l.gate ~enable:pads_enabled core.pin_oe_o
  }
;;
