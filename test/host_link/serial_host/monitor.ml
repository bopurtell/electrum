(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "monitor.ml" *)
(* The serial host's passive monitor: it rebuilds what crossed the serial pins, per
   selection, as [Item.Observed] items.

   The environment's scheduler calls [sample] once per cycle with that cycle's pre-edge
   pin values, as applied to and read from the DUT. The monitor never advances time and
   never reads driver state, the driver's results, or any core-side stub; it knows only
   the pins and the P3.5 frame rules. Items go to [observed], the analysis-port analogue,
   which a checker drains.

   Per selection (LSEL_N low to high) it records:

   1. the first selected cycle and the first deselected cycle;
   2. the LDI and LDO values at each LCLK rise while selected, pre-edge in the rise cycle,
      which is where the host samples LDO;
   3. LRDY in the first selected cycle;
   4. LCLK in the deselection cycle.

   A selection that begins with LRDY high is a response read (P3.5: while LRDY is high, a
   selection starts a response read and request input is ignored); any other selection is
   a request frame. This is the host-side rule at the pins. The loader decides on its
   synchronized view two cycles later and also requires four deselected cycles first, so
   an out-of-contract selection made just before LRDY rises, or too soon after a
   deselection, can be classified differently from how the loader treated it.

   A response read ends in [Replay] when LSEL_N rises with LCLK high, in [Commit] when
   LCLK is low and every bit of the frame its header declares was clocked, and otherwise
   in [Abandoned]. As on the host side, a declared length beyond the largest response is
   capped at [Wire.Response.max_length].
*)

open! Core
module Wire = Protemu_host_link_wire.Wire
module Observed = Item.Observed

(* One cycle's pins: host-driven LSEL_N, LCLK, LDI and DUT-driven LDO, LRDY, pre-edge. *)
module Sample = struct
  type t =
    { select_n : bool
    ; clock : bool
    ; ldi : bool
    ; ldo : bool
    ; ready : bool
    }
  [@@deriving sexp_of]
end

(* An open selection; bits are oldest first. *)
module Selection = struct
  type t =
    { selected : int
    ; ready_at_select : bool
    ; ldi : bool Queue.t
    ; ldo : bool Queue.t
    }
end

type t =
  { mutable clock : bool (* LCLK in the previous sampled cycle *)
  ; mutable selection : Selection.t option
  ; observed : Observed.t Queue.t
  }

let create () = { clock = false; selection = None; observed = Queue.create () }

(* Observed items, oldest first. A checker dequeues what it has compared. *)
let observed t = t.observed

(* Whole bytes MSB first, and the bits of a final partial byte. *)
let split bits =
  let whole = List.length bits / 8 * 8 in
  Item.bytes_of_bits (List.take bits whole), List.drop bits whole
;;

(* Bits in the response frame whose header begins [bytes], if the header is complete. *)
let response_bits bytes =
  if String.length bytes < Wire.Response.header_length
  then None
  else (
    let declared = Wire.U16.get bytes ~pos:Wire.Response.Offset.payload_length in
    Some
      (8
       * Int.min
           (Wire.Response.header_length + declared + Wire.Crc.length)
           Wire.Response.max_length))
;;

let close t (selection : Selection.t) ~deselected ~clock_high =
  let item : Observed.t =
    if selection.ready_at_select
    then (
      let bits = Queue.to_list selection.ldo in
      let bytes, extra_bits = split bits in
      let ending : Observed.Ending.t =
        if clock_high
        then Replay
        else (
          match response_bits bytes with
          | Some length when List.length bits >= length -> Commit
          | _ -> Abandoned)
      in
      Response
        { selected = selection.selected
        ; deselected
        ; bytes
        ; extra_bits
        ; decoded = Wire.Response.decode bytes
        ; ending
        })
    else (
      let bytes, extra_bits = split (Queue.to_list selection.ldi) in
      Request { selected = selection.selected; deselected; bytes; extra_bits })
  in
  Queue.enqueue t.observed item
;;

(* Called by the scheduler once per cycle, pre-edge. A selection opens in its first cycle
   with LSEL_N low and closes in the first cycle with it high; a rise in the deselection
   cycle is not part of the selection.
*)
let sample t ~cycle (pins : Sample.t) =
  (match t.selection, pins.select_n with
   | None, false ->
     t.selection
     <- Some
          { selected = cycle
          ; ready_at_select = pins.ready
          ; ldi = Queue.create ()
          ; ldo = Queue.create ()
          }
   | Some selection, true ->
     close t selection ~deselected:cycle ~clock_high:pins.clock;
     t.selection <- None
   | None, true | Some _, false -> ());
  (match t.selection with
   | Some selection when pins.clock && not t.clock ->
     Queue.enqueue selection.ldi pins.ldi;
     Queue.enqueue selection.ldo pins.ldo
   | _ -> ());
  t.clock <- pins.clock
;;
