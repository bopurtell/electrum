(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "latency.ml" *)
(* Latencies of the unsplit loader, in cycles, fixed here as the HL4b baseline. P3.5
   bounds only the host envelope; these values are the current cycle behavior, each
   explained from the loader's structure or the [Control_port] contract. Cycle n is the
   cycle in which the host drives the pin change.

   These are the checker's predictions, written from that explanation; nothing here is
   read from the loader or from the Control_port responder, whose own contract latencies
   ([Responder.readback_latency]) are a separate implementation. The endpoint suite,
   [Scoreboard], and the archived HL4a suite (test/host_link/archived/hl4a/) share this
   one copy (docs/serial_host_pilot.md, SP4).
*)

open! Core

(* LSEL_N high in cycle n passes the two-stage synchronizer (edges n and n+1), is seen as
   a release in cycle n+2, arms dispatch at edge n+2, and is offered in cycle n+3.
*)
let offer_after_deselect = 3

(* An immediate response is stored at the offer's edge, so LRDY is high from the next
   cycle. Dispatch-stage errors (unknown command, wrong fixed length, device bounds) use
   the same cycle but offer nothing.
*)
let ready_after_offer = 1

(* A frame that fails deselect validation (overrun, incomplete, magic, version, oversized
   length, CRC) stores its error at the release edge n+2, so LRDY is high from n+3: one
   cycle before a valid frame would be offered.
*)
let validation_error_ready = 3

(* Contract item 5: an offer accepted at edge E has its response valid in the cycle
   between E+1 and E+2.
*)
let readback_after_offer = 2

(* The loader stores a READ or ABORT response at the edge of the cycle in which the
   completion is visible.
*)
let ready_after_completion = 1

(* Contract item 6: cleanup is visible in the first cycle after the accepting edge. *)
let abort_clean_after_offer = 1

(* After a synchronized final fall, LSEL_N high in cycle n is seen as a release in cycle
   n+2, which clears LRDY from cycle n+3.
*)
let ready_cleared_after_deselect = 3

(* LSEL_N low in cycle n is seen as a selection in cycle n+2. It arms a response read only
   if LRDY is high and four deselected cycles have been counted in that cycle.
*)
let response_select_to_armed = 2
