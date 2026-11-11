(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "endpoint_scenario.ml" *)
(* The endpoint suite's scenario and check helpers, ported from the HL4a suite and written
   against [Fixture], [Scoreboard], and [Serial_host.Driver]: the composite transactions
   ([receive], [exchange], [transact], [read_prefix], [disturb]), the offer, LRDY, and
   response checks ([expect_*]), the expected responses ([response], [info_payload]), the
   responder shortcuts ([set_status], [accepted]), and the negative-check idiom
   ([require_failure]). The last section holds the serial monitor suite's own
   expectations: items built from the driver's side only, compared against the drained
   serial monitor by [expect_observed].

   These are the scenario/checker side, so they live in the test library, not the fixture
   library. Each helper's pin activity, cycles, checks, and failure reports are its HL4a
   original's, or the driver call's it wraps. A helper that drives a transaction takes an
   optional [board] and records the driver's side into it: the frame it sent, with the
   cycles LSEL_N fell and rose, the [Read.t] the driver returned, or the bits of a read it
   abandoned. Offers and READBACK responses are not recorded here; each test writes those
   out from its scenario. See docs/serial_host_pilot.md, SP5 and SP6.
*)

open! Core
module Wire = Protemu_host_link_wire.Wire
module Serial_host = Protemu_serial_host_agent
module Driver = Serial_host.Driver
module Item = Serial_host.Item
module Exchange = Serial_host.Item.Exchange
module Observed = Serial_host.Item.Observed
module Read = Serial_host.Item.Read
module Control_port_agent = Protemu_control_port_agent
module Offer = Control_port_agent.Item.Offer
module Endpoint = Protemu_host_link_endpoint
module Fixture = Endpoint.Fixture
module Scoreboard = Endpoint.Scoreboard
module Latency = Endpoint.Latency

(* The responder's core status, applied from the next cycle. *)
let set_status t status = (Fixture.responder t).status <- status

(* The offers the responder accepted, oldest first. *)
let accepted ?since t =
  Fixture.offers ?since t |> List.filter ~f:(fun (offer : Offer.t) -> offer.accepted)
;;

let expect_no_offers t ~since what =
  Fixture.check
    t
    ~phase:Post_run
    what
    [%sexp_of: Offer.t list]
    [%equal: Offer.t list]
    ~expected:[]
    (Fixture.offers ~since t)
;;

let expect_offers t ~since what expected =
  Fixture.check
    t
    ~phase:Post_run
    what
    [%sexp_of: Offer.t list]
    [%equal: Offer.t list]
    ~expected
    (Fixture.offers ~since t)
;;

let expect_int t ?cycle what ~expected actual =
  Fixture.check t ?cycle ~phase:Post_run what [%sexp_of: int] Int.equal ~expected actual
;;

(* Holds [cycles] and requires LRDY and LDO low and no offer throughout. *)
let expect_quiet (t : Fixture.t) cycles what =
  let since = t.cycle in
  for _ = 1 to cycles do
    Fixture.cycle t;
    if t.ready || t.ldo
    then
      Fixture.fail
        t
        ~phase:Pre_edge
        what
        ~expected:[%sexp { ready = false; ldo = false }]
        ~actual:[%sexp { ready : bool = t.ready; ldo : bool = t.ldo }]
  done;
  expect_no_offers t ~since what
;;

(* The bits of a final partial byte as [Driver.send] clocks them: the first [extra_bits]
   bits of [extra_byte], MSB first, with the driver's defaults.
*)
let extra_bits_sent ?(extra_bits = 0) ?(extra_byte = '\xff') () =
  List.take (Item.bits_of_byte extra_byte) extra_bits
;;

(* Records a request frame the driver sent, with any partial final byte, when the scenario
   keeps a scoreboard.
*)
let record_request ?extra_bits ?extra_byte board ~selected ~deselected frame =
  Option.iter board ~f:(fun board ->
    Scoreboard.request
      board
      ~extra_bits:(extra_bits_sent ?extra_bits ?extra_byte ())
      ~selected
      ~deselected
      frame)
;;

(* Waits for LRDY after a request frame, reads and validates the response, commits it, and
   checks that LRDY clears on the commit boundary. A response that fails validation is
   replayed first, so the failure report describes a retained response.
*)
let receive
  ?board
  ?ready_budget
  ?pause
  (t : Fixture.t)
  ~started
  ~request_deselected
  ~expected
  =
  let driver = Fixture.driver t in
  let ready = Driver.wait_ready ?budget:ready_budget driver ~since:request_deselected in
  let selected = t.cycle in
  let read =
    Driver.read_response driver ~expected ?pause ~decide:Item.commit_if_valid ()
  in
  Option.iter board ~f:(fun board -> Scoreboard.read board ~selected read);
  match read.decoded with
  | Error error ->
    Fixture.fail
      t
      ~phase:Host_sample
      "response decodes and correlates; it was replayed"
      ~expected:[%sexp (expected : Wire.Correlation.t)]
      ~actual:
        [%sexp (error : Wire.Response.Decode_error.t), (Item.hex read.bytes : string)]
  | Ok response ->
    Fixture.expect_ready_cleared t ~deselected:read.deselected;
    { Exchange.started
    ; request_deselected
    ; ready
    ; response_selected = read.selected
    ; response_deselected = read.deselected
    ; bytes = read.bytes
    ; response
    }
;;

(* A complete transaction for [frame]: send it with the gap, then [receive]. *)
let exchange ?board ?ready_budget ?pause (t : Fixture.t) frame ~expected =
  let started = t.cycle in
  let request_deselected = Driver.send_frame (Fixture.driver t) frame in
  record_request board ~selected:started ~deselected:request_deselected frame;
  receive ?board ?ready_budget ?pause t ~started ~request_deselected ~expected
;;

let transact ?board ?ready_budget ?pause t ~tag request =
  exchange
    ?board
    ?ready_budget
    ?pause
    t
    (Item.encode ~tag request)
    ~expected:(Wire.Request.correlation ~tag request)
;;

(* [Driver.read_prefix]: reads the first [bits] bits of a response and abandons it.
   Returns the bits read, packed MSB first, and the deselection cycle; with a [board],
   records them as an abandoned read selected in the current cycle.
*)
let read_prefix ?board (t : Fixture.t) ~bits =
  let selected = t.cycle in
  let packed, deselected = Driver.read_prefix (Fixture.driver t) ~bits in
  Option.iter board ~f:(fun board ->
    Scoreboard.abandoned board ~selected ~deselected ~bits packed);
  packed, deselected
;;

(* The command reached the core exactly once, [Latency.offer_after_deselect] cycles after
   its frame's deselection, with [request]'s operands.
*)
let expect_offered_once t (exchange : Exchange.t) request ~accepted =
  expect_offers
    t
    ~since:exchange.started
    "the command is offered once, three cycles after its deselection"
    [ { cycle = exchange.request_deselected + Latency.offer_after_deselect
      ; request
      ; accepted
      }
    ]
;;

(* Out-of-contract selection while a command is in flight: select, clock [bytes] as if
   sending a request ([Driver.send] checks that LDO stays low at every rise), deselect,
   and hold the gap. Returns the deselection cycle.
*)
let disturb ?board (t : Fixture.t) bytes =
  Fixture.note t "out-of-contract selection";
  let selected = t.cycle in
  let deselected = Driver.send_frame (Fixture.driver t) bytes in
  record_request board ~selected ~deselected bytes;
  deselected
;;

let expect_response t what ~expected (actual : Wire.Response.t) =
  Fixture.check
    t
    ~phase:Host_sample
    what
    [%sexp_of: Wire.Response.t]
    [%equal: Wire.Response.t]
    ~expected
    actual
;;

(* Response written out from a scenario's expected fields. *)
let response ~tag command ?(payload = Wire.Response.Payload.Empty) result =
  { Wire.Response.tag; command = Wire.Command.to_int command; result; payload }
;;

(* A legal INFO with a fresh tag, answered with the fixed INFO descriptor: the check that
   the loader accepts new work after a malformed frame or a cancellation.
*)
let info_payload =
  Wire.Response.Payload.Info
    { wire_major = 1
    ; wire_minor = 0
    ; isa_version = 1
    ; memory_layout = 1
    ; capabilities =
        [ Status; Program_load; Program_read; Program_verify; Run; Stop; Abort ]
    ; memory_word_bits = 16
    ; memory_depth = 256
    ; max_request_payload_bytes = 4
    ; protocol_pin_count = 8
    }
;;

let expect_info_works ?board (t : Fixture.t) ~tag what =
  let since = t.cycle in
  let exchange = transact ?board t ~tag Info in
  expect_response
    t
    what
    ~expected:(response ~tag Info ~payload:info_payload Complete)
    exchange.response;
  expect_no_offers t ~since what
;;

(* The report of [f]'s [Harness_failure]; fails at [Post_run] if [f] does not raise. *)
let require_failure t what f =
  match Fixture.failure_of f with
  | Some failure -> failure
  | None -> Fixture.fail t ~phase:Post_run ("the negative check must fail: " ^ what)
;;

(* Serial monitor expectations: the SP2 scoreboard over the serial monitor alone. *)

(* The serial monitor's items since the last call are exactly [expected], in order.
   Compared items are dequeued.
*)
let expect_observed t what expected =
  let observed = Fixture.serial_observed t in
  let actual = Queue.to_list observed in
  Queue.clear observed;
  Fixture.check
    t
    ~phase:Post_run
    what
    [%sexp_of: Scoreboard.serial_item list]
    [%equal: Observed.t list]
    ~expected
    actual
;;

(* Cycles [Driver.begin_frame] holds after LSEL_N falls. [Read.selected] counts from after
   it; the monitor's [selected] is the cycle LSEL_N fell.
*)
let lead t =
  let timing = Fixture.timing t in
  Int.max 0 (timing.select_lead - timing.clock_low)
;;

(* Expected items, from the driver's side only. *)

let request ?extra_bits ?extra_byte ~selected ~deselected bytes : Observed.t =
  Request
    { selected
    ; deselected
    ; bytes
    ; extra_bits = extra_bits_sent ?extra_bits ?extra_byte ()
    }
;;

let response_read t (read : Read.t) : Observed.t =
  Response
    { selected = read.selected - lead t
    ; deselected = read.deselected
    ; bytes = read.bytes
    ; extra_bits = []
    ; decoded = Scoreboard.uncorrelated read.decoded
    ; ending =
        (match read.outcome with
         | Commit -> Commit
         | Replay -> Replay)
    }
;;

let committed t (exchange : Exchange.t) : Observed.t =
  Response
    { selected = exchange.response_selected - lead t
    ; deselected = exchange.response_deselected
    ; bytes = exchange.bytes
    ; extra_bits = []
    ; decoded = Ok exchange.response
    ; ending = Commit
    }
;;

(* A request frame [frame] and its committed response. *)
let transaction ?extra_bits ?extra_byte t (exchange : Exchange.t) frame =
  [ request
      ?extra_bits
      ?extra_byte
      ~selected:exchange.started
      ~deselected:exchange.request_deselected
      frame
  ; committed t exchange
  ]
;;

(* [transact], then requires the serial monitor to have seen exactly its frame and
   committed response. Returns the exchange, for expectations on the Control_port side.
*)
let expect_transaction t ~tag request =
  let exchange = transact t ~tag request in
  expect_observed
    t
    (Sexp.to_string [%sexp (request : Wire.Request.t)])
    (transaction t exchange (Item.encode ~tag request));
  exchange
;;
