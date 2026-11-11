(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "agent.ml" *)
(* The serial-host agent: its [Config], a [Driver] when active, and the passive [Monitor].

   The agent owns no time and no sequencer. The environment steps the driver through
   [Driver.Env.step] and calls [sample] once per cycle; a test's sequence is ordinary
   calls on [driver_exn]. The monitor is independent of the driver even in one agent:
   nothing here passes driver state to it. See docs/serial_host_pilot.md.
*)

open! Core

type t =
  { config : Config.t
  ; driver : Driver.t option (* [None] exactly when passive *)
  ; monitor : Monitor.t
  }

(* An active agent needs [host], the pin adapter and environment hooks for its driver; a
   passive one must not be given them. Either mistake raises.
*)
let create ?host (config : Config.t) =
  let driver =
    match config.mode, host with
    | Active, Some (pins, env) -> Some (Driver.create ~timing:config.timing pins env)
    | Passive, None -> None
    | Active, None ->
      raise_s [%message "an active serial-host agent needs pins and environment hooks"]
    | Passive, Some _ -> raise_s [%message "a passive serial-host agent has no driver"]
  in
  { config; driver; monitor = Monitor.create () }
;;

let driver_exn t =
  match t.driver with
  | Some driver -> driver
  | None -> raise_s [%message "a passive serial-host agent has no driver"]
;;

let sample t ~cycle pins = Monitor.sample t.monitor ~cycle pins
let observed t = Monitor.observed t.monitor
