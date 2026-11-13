(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "item.ml" *)
(* Items for the Control_port agent: the transactions that cross [Emulator_core]'s control
   port, decoded from its [int] request, decision, and status records.

   [Control_port] in ip/emulator_core/rtl/control_port.ml owns the records and the
   temporal contract; items refer to them and never redefine them. Nothing here touches a
   simulator: each suite converts its ports to [int] records at its adapter. [Responder]
   answers [Request] offers; [Monitor] rebuilds [Observed] items from the port records.
   See docs/serial_host_pilot.md.
*)

open! Core
open! Electrum_core

(* A decoded [Control_port.Request] offer. READ carries no expected word: that operand is
   meaningful only with [readback_verify].
*)
module Request = struct
  type t =
    | Load_start of { length : int }
    | Load_write of
        { address : int
        ; data : int
        }
    | Load_complete
    | Read of { address : int }
    | Verify of
        { address : int
        ; expected : int
        }
    | Run
    | Stop
    | Abort
  [@@deriving sexp_of, compare, equal]

  (* Every request whose valid is high, in [Control_port.Request]'s field order. *)
  let of_port (r : int Control_port.Request.t) =
    let valid value = value <> 0 in
    List.filter_opt
      [ Option.some_if (valid r.load_start_valid) (Load_start { length = r.load_length })
      ; Option.some_if
          (valid r.load_write_valid)
          (Load_write { address = r.load_address; data = r.load_data })
      ; Option.some_if (valid r.load_complete_valid) Load_complete
      ; Option.some_if
          (valid r.readback_valid)
          (if valid r.readback_verify
           then Verify { address = r.readback_address; expected = r.readback_expected }
           else Read { address = r.readback_address })
      ; Option.some_if (valid r.run_valid) Run
      ; Option.some_if (valid r.stop_valid) Stop
      ; Option.some_if (valid r.abort_valid) Abort
      ]
  ;;
end

(* When a responder completes an accepted READBACK or ABORT. [Delayed] and [Never] are
   robustness probes of a producer's waits, not behavior of the current [Emulator_core];
   tests using them say so.
*)
module Completion = struct
  type t =
    | Contract
    | Delayed of int (* extra cycles beyond the contract; robustness only *)
    | Never (* robustness only *)
  [@@deriving sexp_of]
end

(* One offer and its decision, in the cycle it was decided. *)
module Offer = struct
  type t =
    { cycle : int
    ; request : Request.t
    ; accepted : bool
    }
  [@@deriving sexp_of, compare, equal]
end

(* One READBACK response pulse, in the cycle its valid is high. *)
module Response = struct
  type t =
    { cycle : int
    ; data : int
    ; matches : bool
    }
  [@@deriving sexp_of, compare, equal]
end

(* Core status as plain integers, one per [Control_port.Status] field. *)
module Status = struct
  type t = int Control_port.Status.t

  let sexp_of_t (t : t) = Control_port.Status.sexp_of_t Int.sexp_of_t t
  let equal = Control_port.Status.equal Int.equal

  let halted_idle : t =
    { halted = 1
    ; engines_idle = 1
    ; image_valid = 0
    ; load_active = 0
    ; image_length = 0
    ; words_written = 0
    ; words_verified = 0
    ; verification_failed = 0
    ; fetch_fault = 0
    ; execution_active = 0
    ; normal_halt = 0
    ; execution_fault = 0
    ; fault_kind = 0
    ; pc = 0
    ; phase = 0
    ; pin_oe = 0
    ; software_claim = 0
    ; engine_claim = 0
    }
  ;;

  (* Executing with one engine driving and claiming pin 1. *)
  let running : t =
    { halted_idle with
      halted = 0
    ; engines_idle = 0
    ; image_valid = 1
    ; execution_active = 1
    ; phase = 5
    ; pin_oe = 0x02
    ; engine_claim = 0x02
    }
  ;;

  (* Contract item 6: halted, engines idle, and no output enable or claim. The responder
     also clears [execution_active] and reports the halted phase.
  *)
  let cleaned (t : t) : t =
    { t with
      halted = 1
    ; engines_idle = 1
    ; execution_active = 0
    ; phase = 0
    ; pin_oe = 0
    ; software_claim = 0
    ; engine_claim = 0
    }
  ;;

  (* Nonzero fields only, by port name, for a transcript. *)
  let summary (t : t) =
    Control_port.Status.(map2 port_names t ~f:(fun name value -> name, value) |> to_list)
    |> List.filter ~f:(fun (_, value) -> value <> 0)
  ;;
end

(* What the passive monitor saw cross the port, in cycle order. *)
module Observed = struct
  type t =
    | Offer of Offer.t
    | Response of Response.t
  [@@deriving sexp_of, compare, equal]

  let offer = function
    | Offer offer -> Some offer
    | Response _ -> None
  ;;

  let response = function
    | Response response -> Some response
    | Offer _ -> None
  ;;
end
