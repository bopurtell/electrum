(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "scoreboard.ml" *)
(* The endpoint fixture's opt-in end-of-scenario scoreboard. It joins two independent
   streams per monitor: the items a monitor rebuilt from the pins or the port, and the
   items the scenario expects.

   Expected serial items come from the driver's side only: the frame the scenario sent,
   with the cycles the driver reported; the [Read.t] the driver returned; and, for a read
   abandoned before its final bit, the bits the driver read and the cycle it deselected.
   Expected Control_port items are the scenario's offers and READBACK responses, placed in
   time by [Latency]'s predictions from the request's deselection cycle. Nothing expected
   is read from a monitor, the responder, or the loader. [check] drains both monitors and
   the expectations and compares them in order, so a missing, extra, reordered, or
   mistimed item is a failure reported through [Fixture.check].

   A scenario opts in through [run] or by calling [check]. Scenarios with early selections
   do not: the serial monitor classifies those by the host-side rule rather than the
   loader's (docs/serial_host_pilot.md, SP2 deviations).
*)

open! Core
module Wire = Host_link_protocol
module Serial_host = Protemu_serial_host_agent
module Control_port_agent = Protemu_control_port_agent
module Observed = Serial_host.Item.Observed
module Read = Serial_host.Item.Read
module Request = Control_port_agent.Item.Request
module Offer = Control_port_agent.Item.Offer
module Response = Control_port_agent.Item.Response

(* Expected items, oldest first. *)
type t =
  { serial : Observed.t Queue.t
  ; offers : Offer.t Queue.t
  ; responses : Response.t Queue.t
  }

let create () =
  { serial = Queue.create (); offers = Queue.create (); responses = Queue.create () }
;;

(* A request frame of [bytes], clocked from the cycle LSEL_N fell ([selected]) to the
   cycle it rose ([deselected]). [extra_bits] are the bits of a final partial byte.
*)
let request t ?(extra_bits = []) ~selected ~deselected bytes =
  Queue.enqueue t.serial (Request { selected; deselected; bytes; extra_bits })
;;

(* The monitor decodes without a correlation, so a driver-side mismatch is the response it
   carries.
*)
let uncorrelated = function
  | Error (Wire.Codec.Response.Decode_error.Correlation_mismatch { response; _ }) ->
    Ok response
  | decoded -> decoded
;;

(* A complete response read that the driver returned as [read]. [selected] is the cycle
   LSEL_N fell, which the scenario records before calling the driver; [Read.selected]
   counts from after the select lead.
*)
let read t ~selected (read : Read.t) =
  Queue.enqueue
    t.serial
    (Response
       { selected
       ; deselected = read.deselected
       ; bytes = read.bytes
       ; extra_bits = []
       ; decoded = uncorrelated read.decoded
       ; ending =
           (match read.outcome with
            | Commit -> Commit
            | Replay -> Replay)
       })
;;

(* A response read the driver abandoned before its final bit, as [Driver.read_prefix]
   reports it: [bits] bits read, packed MSB first with a final partial byte in the low
   bits of [packed]. [selected] is the cycle LSEL_N fell, which the scenario records
   before the read; [deselected] is the cycle the driver raised it. The whole bytes and
   the bits of the partial byte are split as the monitor holds them, and [decoded] is
   [Wire.Codec.Response.decode] of the whole bytes. A [packed] of the wrong length for
   [bits] is a bug in the test.
*)
let abandoned t ~selected ~deselected ~bits packed =
  let whole = bits / 8 in
  let partial = bits % 8 in
  if String.length packed <> whole + Bool.to_int (partial > 0)
  then
    raise_s
      [%message
        "abandoned read: packed bits do not match the bit count"
          (bits : int)
          ~packed:(Serial_host.Item.hex packed : string)];
  let bytes = String.prefix packed whole in
  let extra_bits =
    if partial = 0
    then []
    else List.drop (Serial_host.Item.bits_of_byte packed.[whole]) (8 - partial)
  in
  Queue.enqueue
    t.serial
    (Response
       { selected
       ; deselected
       ; bytes
       ; extra_bits
       ; decoded = Wire.Codec.Response.decode bytes
       ; ending = Abandoned
       })
;;

(* [request] offered [Latency.offer_after_deselect] cycles after the deselection of its
   frame, with decision [accepted]. Returns the predicted offer cycle.
*)
let offer t ~deselected request ~accepted =
  let cycle = deselected + Latency.offer_after_deselect in
  Queue.enqueue t.offers { cycle; request; accepted };
  cycle
;;

(* A READBACK response pulse [Latency.readback_after_offer] cycles after the accepted
   offer in cycle [offered].
*)
let readback t ~offered ~data ~matches =
  Queue.enqueue
    t.responses
    { cycle = offered + Latency.readback_after_offer; data; matches }
;;

(* Serial items with bytes in hex, for reports. *)
let sexp_of_serial_item : Observed.t -> Sexp.t = function
  | Request { selected; deselected; bytes; extra_bits } ->
    [%message
      "request"
        (selected : int)
        (deselected : int)
        ~bytes:(Serial_host.Item.hex bytes : string)
        (extra_bits : bool list)]
  | Response { selected; deselected; bytes; extra_bits; decoded; ending } ->
    [%message
      "response"
        (selected : int)
        (deselected : int)
        ~bytes:(Serial_host.Item.hex bytes : string)
        (extra_bits : bool list)
        (decoded : (Wire.Response.t, Wire.Codec.Response.Decode_error.t) Result.t)
        (ending : Observed.Ending.t)]
;;

let drain queue =
  let items = Queue.to_list queue in
  Queue.clear queue;
  items
;;

(* Drains both monitors and every expectation, then compares, in this order: serial items,
   offers, READBACK responses. The first disagreement fails at [Post_run].
*)
let check t fixture =
  let serial = drain (Fixture.serial_observed fixture) in
  let port = drain (Fixture.control_port_observed fixture) in
  Fixture.check
    fixture
    ~phase:Post_run
    "the serial monitor saw the driver's frames and reads"
    [%sexp_of: serial_item list]
    [%equal: Observed.t list]
    ~expected:(drain t.serial)
    serial;
  Fixture.check
    fixture
    ~phase:Post_run
    "the Control_port monitor saw the predicted offers"
    [%sexp_of: Offer.t list]
    [%equal: Offer.t list]
    ~expected:(drain t.offers)
    (List.filter_map port ~f:Control_port_agent.Item.Observed.offer);
  Fixture.check
    fixture
    ~phase:Post_run
    "the Control_port monitor saw the predicted READBACK responses"
    [%sexp_of: Response.t list]
    [%equal: Response.t list]
    ~expected:(drain t.responses)
    (List.filter_map port ~f:Control_port_agent.Item.Observed.response)
;;

(* [Fixture.run] with a fresh scoreboard, checked when [f] returns. A scenario that raises
   is reported by its own failure, not the scoreboard's.
*)
let run ?timing ?transcript_limit ~scenario f =
  Fixture.run ?timing ?transcript_limit ~scenario (fun fixture ->
    let t = create () in
    let result = f fixture t in
    check t fixture;
    result)
;;
