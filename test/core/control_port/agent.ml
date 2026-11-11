(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "agent.ml" *)
(* The Control_port agent: its [Config], a [Responder] in responder mode, and the passive
   [Monitor].

   The agent owns no time and no sequencer. The environment's scheduler calls the
   responder in its cycle phases and [sample] once per cycle; a test sets the responder's
   policy fields directly. The monitor is independent of the responder even in one agent:
   nothing here passes responder state to it. See docs/serial_host_pilot.md.
*)

open! Core

type t =
  { config : Config.t
  ; responder : Responder.t option (* [None] exactly when passive *)
  ; monitor : Monitor.t
  }

let create (config : Config.t) =
  let responder =
    match config.mode with
    | Responder -> Some (Responder.create ~injection:config.injection)
    | Passive -> None
  in
  { config; responder; monitor = Monitor.create () }
;;

let responder_exn t =
  match t.responder with
  | Some responder -> responder
  | None -> raise_s [%message "a passive Control_port agent has no responder"]
;;

let sample t ~cycle sample = Monitor.sample t.monitor ~cycle sample
let observed t = Monitor.observed t.monitor
