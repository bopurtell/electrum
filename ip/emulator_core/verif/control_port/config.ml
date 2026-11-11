(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "config.ml" *)
(* Configuration for the Control_port agent: whether it answers the port as the core, and
   how its responder treats an injected READBACK response pulse.

   The temporal contract, including the READBACK latency, belongs to control_port.ml and
   is implemented in [Responder]; nothing here changes it. See docs/serial_host_pilot.md.
*)

open! Core

(* A [Responder] agent answers a producer's offers as the core does and monitors the port;
   a [Passive] one only monitors. A [Master] mode, which would drive requests into the
   real [Emulator_core], is reserved for a later step and not implemented.
*)
module Mode = struct
  type t =
    | Responder
    | Passive
  [@@deriving sexp_of]
end

(* How [Responder.inject_readback_response], a robustness probe, interacts with accepted
   READBACKs. Both are labelled choices that existing suites rely on.

   - [Outstanding]: the injected pulse replaces the responder's pending READBACK response.
     It makes a READBACK outstanding until its cycle passes, so a READBACK offered
     meanwhile is refused; reset, disable, or an accepted ABORT or LOAD_START cancels it.
     The HL4a loader suite uses this.
   - [Independent]: injected pulses are kept apart from the pending response. They never
     make a READBACK outstanding, reset and disable do not cancel them, and an accepted
     READBACK's response wins a cycle in which both are due. The dispatch suite uses this.
*)
module Injection = struct
  type t =
    | Outstanding
    | Independent
  [@@deriving sexp_of]
end

(* [injection] is the responder's policy; a passive agent ignores it. *)
type t =
  { mode : Mode.t
  ; injection : Injection.t
  }
[@@deriving sexp_of]

let responder ~injection = { mode = Responder; injection }
let passive = { mode = Passive; injection = Independent }
