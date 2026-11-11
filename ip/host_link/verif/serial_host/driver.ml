(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "driver.ml" *)
(* The serial host's driver: it clocks request frames into LDI and response frames out of
   LDO, in whole system cycles inside the P3.5 envelope of [Config.Timing].

   The serial host is the link's master, so reading a response is driving too. The driver
   works on logical pins through [Pins], never on a simulator. It advances time only
   through the environment's [Env.step], which owns the cycle, and it reports transcript
   events and failures through [Env.log] and [Env.fail], so the environment keeps its own
   report format. It never reads the monitor: LRDY history comes from
   [Pins.ready_changes], the environment's own sampled record.

   One protocol check stays here: LDO must be low at every rise of a request bit. It is
   keyed to what the driver is doing, which the passive monitor cannot see; SP4 in
   docs/serial_host_pilot.md records why it was not moved to the monitor.
*)

open! Core
module Wire = Protemu_host_link_wire.Wire
module Timing = Config.Timing
open Item

(* The pin adapter. Host pins set here are applied by the environment from the next
   [Env.step]; the DUT's pins are read as the environment sampled them, pre-edge.
   [ready_changes ~since] is the environment's record of LRDY changes at or after [since],
   oldest first; a change may lie before the current cycle.
*)
module Pins = struct
  type t =
    { set_select_n : bool -> unit (* LSEL_N *)
    ; set_clock : bool -> unit (* LCLK *)
    ; set_data : bool -> unit (* LDI *)
    ; ldo : unit -> bool (* pre-edge LDO of the last cycle *)
    ; ready_changes : since:int -> (int * bool) list
    }
end

(* Transcript events the driver reports, in the cycle it reports them. [bytes] are raw. *)
module Event = struct
  type t =
    | Select of bool (* host drives LSEL_N low when true *)
    | Sent of
        { bytes : string
        ; extra_bits : int
        }
    | Response_read of
        { bytes : string
        ; outcome : Outcome.t
        }
  [@@deriving sexp_of]
end

(* A failed driver-side check, for the environment to report. *)
module Failure = struct
  module Kind = struct
    type t =
      | Host_sample (* the host's LDO sample, pre-edge in its LCLK rise cycle *)
      | Ready_wait (* an exhausted wait for LRDY, checked pre-edge *)
    [@@deriving sexp_of]
  end

  type t =
    { kind : Kind.t
    ; what : string
    ; expected : Sexp.t
    ; actual : Sexp.t
    }
  [@@deriving sexp_of]
end

(* Environment hooks. [step] runs one whole cycle (pins applied, sampled, clocked); [now]
   is the cycle the next [step] runs; [fail] must not return.
*)
module Env = struct
  type t =
    { step : unit -> unit
    ; now : unit -> int
    ; log : Event.t -> unit
    ; fail : 'a. Failure.t -> 'a
    }
end

type t =
  { pins : Pins.t
  ; env : Env.t
  ; mutable timing : Timing.t
  }

let create ?(timing = Timing.envelope) pins env =
  Timing.validate timing;
  { pins; env; timing }
;;

let timing t = t.timing

let set_timing t timing =
  Timing.validate timing;
  t.timing <- timing
;;

let hold t cycles =
  for _ = 1 to cycles do
    t.env.step ()
  done
;;

(* Host serial driver. Pins are applied by [Env.step]; these functions only set them and
   hold the durations in [t.timing].
*)

let select t =
  t.pins.set_select_n false;
  t.env.log (Select true)
;;

(* LSEL_N high and LDI low from the current cycle; returns that cycle. *)
let deselect t =
  t.pins.set_select_n true;
  t.pins.set_data false;
  t.env.log (Select false);
  t.env.now ()
;;

(* One request bit: LDI changes with the preceding fall, is held [clock_low] cycles before
   the rise and [clock_high] after it. At each rise LDO must be low: a selection that is
   sending a request is never also shifting out a response.
*)
let send_bit t value =
  t.pins.set_data value;
  t.pins.set_clock false;
  hold t t.timing.clock_low;
  t.pins.set_clock true;
  t.env.step ();
  if t.pins.ldo ()
  then
    t.env.fail
      { kind = Host_sample
      ; what = "LDO stays low while a request is clocked in"
      ; expected = [%sexp false]
      ; actual = [%sexp true]
      };
  hold t (t.timing.clock_high - 1);
  t.pins.set_clock false
;;

(* Clocks [bytes], then the first [extra_bits] bits of [extra_byte]; all MSB first. *)
let send t ?(extra_bits = 0) ?(extra_byte = '\xff') bytes =
  t.env.log (Sent { bytes; extra_bits });
  String.iter bytes ~f:(fun byte -> List.iter (bits_of_byte byte) ~f:(send_bit t));
  List.iter (List.take (bits_of_byte extra_byte) extra_bits) ~f:(send_bit t)
;;

(* The last [8 - bits] bits of [byte], completing a byte begun with [~extra_bits:bits]. *)
let send_rest_of_byte t byte ~bits =
  List.iter (List.drop (bits_of_byte byte) bits) ~f:(send_bit t)
;;

(* LSEL_N low, then [select_lead] cycles before the first rise. The first bit's setup
   interval ([clock_low]) is part of the lead.
*)
let begin_frame t =
  select t;
  hold t (Int.max 0 (t.timing.select_lead - t.timing.clock_low))
;;

(* [select_trail] cycles after the last fall, then LSEL_N high; returns that cycle. The
   caller holds the gap.
*)
let end_frame t =
  hold t t.timing.select_trail;
  deselect t
;;

(* A complete selected frame, including the trailing gap; returns the deselection cycle. *)
let send_frame t ?extra_bits ?extra_byte bytes =
  begin_frame t;
  send t ?extra_bits ?extra_byte bytes;
  let deselected = end_frame t in
  hold t t.timing.deselect_gap;
  deselected
;;

(* First LRDY rise at or after [since], advancing at most [budget] cycles. *)
let wait_ready ?(budget = Config.ready_budget) t ~since =
  let rec loop spent =
    match
      List.find (t.pins.ready_changes ~since) ~f:(fun (_, ready) -> ready)
      |> Option.map ~f:fst
    with
    | Some rise -> rise
    | None ->
      if spent >= budget
      then
        t.env.fail
          { kind = Ready_wait
          ; what = sprintf "LRDY rises within %d cycles of cycle %d" budget since
          ; expected = [%sexp true]
          ; actual = [%sexp false]
          }
      else (
        t.env.step ();
        loop (spent + 1))
  in
  loop 0
;;

(* One response bit: [clock_low] cycles low, then a rise whose cycle samples LDO. With
   [final], LCLK is left high after the sample.
*)
let read_bit ?(final = false) ?(high_pause = 0) t =
  t.pins.set_clock false;
  hold t t.timing.clock_low;
  t.pins.set_clock true;
  t.env.step ();
  let value = t.pins.ldo () in
  hold t high_pause;
  if not final
  then (
    hold t (t.timing.clock_high - 1);
    t.pins.set_clock false);
  value
;;

(* Stops a selected response read before its final bit: [select_trail] cycles after the
   last fall, LSEL_N high, then the gap. Returns the deselection cycle.
*)
let abandon_response t =
  let deselected = end_frame t in
  hold t t.timing.deselect_gap;
  deselected
;;

(* After the final rise and validation, with LCLK high. Commit supplies the final fall;
   replay deselects first and leaves the final fall out. Returns the deselection cycle.
*)
let finish_response t (outcome : Outcome.t) =
  hold t (t.timing.clock_high - 1);
  let deselected =
    match outcome with
    | Commit ->
      t.pins.set_clock false;
      end_frame t
    | Replay ->
      let deselected = deselect t in
      hold t t.timing.clock_high;
      t.pins.set_clock false;
      deselected
  in
  hold t t.timing.deselect_gap;
  deselected
;;

(* Reads the response through its final rise, validates it with LCLK high, and finishes
   with [decide]'s outcome. The length comes from the received header; a declared payload
   beyond the largest response is read only to the maximum frame length, so the decoder
   reports it.
*)
let read_response t ?expected ?(pause : Pause.t option) ~decide () =
  begin_frame t;
  let selected = t.env.now () in
  let bits = Queue.create () in
  let read_one ~final =
    let count = Queue.length bits + 1 in
    let pause_here = Option.filter pause ~f:(fun pause -> pause.after_bits = count) in
    let high_pause =
      match pause_here with
      | Some { cycles; clock_high = true; _ } -> cycles
      | _ -> 0
    in
    Queue.enqueue bits (read_bit t ~final ~high_pause);
    match pause_here with
    | Some { cycles; clock_high = false; _ } -> hold t cycles
    | _ -> ()
  in
  for _ = 1 to 8 * Wire.Response.header_length do
    read_one ~final:false
  done;
  let header = bytes_of_bits (Queue.to_list bits) in
  let declared = Wire.U16.get header ~pos:Wire.Response.Offset.payload_length in
  let total =
    Int.min
      (Wire.Response.header_length + declared + Wire.Crc.length)
      Wire.Response.max_length
  in
  for index = (8 * Wire.Response.header_length) + 1 to 8 * total do
    read_one ~final:(index = 8 * total)
  done;
  let bytes = bytes_of_bits (Queue.to_list bits) in
  let decoded =
    match expected with
    | Some expected -> Wire.Response.decode_correlated ~expected bytes
    | None -> Wire.Response.decode bytes
  in
  let outcome = decide decoded in
  t.env.log (Response_read { bytes; outcome });
  let deselected = finish_response t outcome in
  { Read.selected; deselected; bytes; decoded; outcome }
;;

(* Reads the first [bits] bits of a response and deselects before the final bit. Returns
   the bits read, packed MSB first, and the deselection cycle.
*)
let read_prefix t ~bits =
  begin_frame t;
  let values = Queue.create () in
  for _ = 1 to bits do
    Queue.enqueue values (read_bit t)
  done;
  let deselected = abandon_response t in
  bytes_of_bits (Queue.to_list values), deselected
;;
