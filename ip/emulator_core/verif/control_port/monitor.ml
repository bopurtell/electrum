(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "monitor.ml" *)
(* The Control_port agent's passive monitor: it records what crossed the port as
   [Item.Observed] items.

   The environment's scheduler calls [sample] once per cycle, pre-edge, after the cycle's
   decision has been applied and settled, with that cycle's request, decision, and status
   records as [int]s read from the ports. The monitor never advances time and never reads
   responder state; it knows only the port records and the contract's field pairing.

   Per cycle it emits, in this order:

   1. an [Offer] for each request whose valid is high, in [Control_port.Request]'s field
      order, accepted when that request's [*_accepted] decision field is high (item 3);
   2. a [Response] when [readback_response_valid] is high, with the data and match fields
      of that cycle (item 5).

   Status is part of the sample so that a checker can be given one consistent view of the
   cycle; no item is emitted for it today. Items go to [observed], the analysis-port
   analogue, which a checker reads or drains.
*)

open! Core
open! Electrum_core
module Observed = Item.Observed

(* One cycle's port records, pre-edge. *)
module Sample = struct
  type t =
    { request : int Control_port.Request.t
    ; decision : int Control_port.Decision.t
    ; status : int Control_port.Status.t
    }
end

type t = { observed : Observed.t Queue.t }

let create () = { observed = Queue.create () }

(* The decision field that accepts [request]. *)
let accepted (decision : int Control_port.Decision.t) (request : Item.Request.t) =
  let field =
    match request with
    | Load_start _ -> decision.load_start_accepted
    | Load_write _ -> decision.load_write_accepted
    | Load_complete -> decision.load_complete_accepted
    | Read _ | Verify _ -> decision.readback_accepted
    | Run -> decision.run_accepted
    | Stop -> decision.stop_accepted
    | Abort -> decision.abort_accepted
  in
  field <> 0
;;

let sample t ~cycle ({ request; decision; status = _ } : Sample.t) =
  List.iter (Item.Request.of_port request) ~f:(fun request ->
    Queue.enqueue
      t.observed
      (Offer { cycle; request; accepted = accepted decision request }));
  if decision.readback_response_valid <> 0
  then
    Queue.enqueue
      t.observed
      (Response
         { cycle
         ; data = decision.readback_response_data
         ; matches = decision.readback_response_match <> 0
         })
;;

let observed t = t.observed
