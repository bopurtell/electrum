(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "config.ml" *)
(* Configuration for the serial-host agent: whether it drives the pins, the host's P3.5
   timing envelope in system cycles, and the default budgets of its bounded waits.

   docs/p3.5-hardware-loader.md owns the envelope; [Timing.validate] rejects host timing
   outside it. A budget only bounds a wait so that a loader that never answers fails with
   a report instead of hanging; it is not a protocol limit. See docs/serial_host_pilot.md.
*)

open! Core

(* Host serial timing in system cycles. P3.5 requires at least four of each. *)
module Timing = struct
  type t =
    { clock_low : int (* LCLK low; LDI setup before the rise *)
    ; clock_high : int (* LCLK high; LDI hold after the rise *)
    ; select_lead : int (* LSEL_N low before the first rise *)
    ; select_trail : int (* last fall before LSEL_N high *)
    ; deselect_gap : int (* LSEL_N high between frames *)
    }
  [@@deriving sexp_of]

  let minimum = 4

  let envelope =
    { clock_low = 4; clock_high = 4; select_lead = 4; select_trail = 4; deselect_gap = 4 }
  ;;

  let validate t =
    List.iter
      [ "clock_low", t.clock_low
      ; "clock_high", t.clock_high
      ; "select_lead", t.select_lead
      ; "select_trail", t.select_trail
      ; "deselect_gap", t.deselect_gap
      ]
      ~f:(fun (field, cycles) ->
        if cycles < minimum
        then
          raise_s
            [%message
              "host timing is outside the P3.5 envelope"
                (field : string)
                (cycles : int)
                (minimum : int)])
  ;;
end

(* Default cycles to wait for an LRDY rise before failing (docs/host_link_hl4a_record.md,
   item 8).
*)
let ready_budget = 20_000

(* An active agent drives the host pins through its [Driver] and monitors them; a passive
   one only monitors.
*)
module Mode = struct
  type t =
    | Active
    | Passive
  [@@deriving sexp_of]
end

(* [timing] is the driver's starting timing; [Driver.set_timing] may change it later. A
   passive agent ignores it.
*)
type t =
  { mode : Mode.t
  ; timing : Timing.t
  }
[@@deriving sexp_of]

let active ?(timing = Timing.envelope) () = { mode = Active; timing }
let passive = { mode = Passive; timing = Timing.envelope }
