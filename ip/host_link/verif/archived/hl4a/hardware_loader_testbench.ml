(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "hardware_loader_testbench.ml" *)
(* HL4a compatibility shim over the Host_link endpoint fixture, and the HL4a suite's own
   scenario and check helpers.

   The environment the HL4a suite runs in is [Protemu_host_link_endpoint.Fixture]
   (test/host_link/endpoint/): the real composed [Host_link], an active serial-host agent
   on its pins, a Control_port responder agent behind its port, one scheduler, the
   transcript, and [Harness_failure]. Its header holds the scheduling contract, also
   recorded in docs/host_link_hl4a_record.md. This file keeps the HL4a names over it, as
   aliases and one-line wrappers, so the four HL4a test files and
   serial_host_monitor_tests.ml compile and print exactly as before
   (docs/serial_host_pilot.md, SP4). [t] is the fixture's state; [t.stub] is its
   Control_port responder under the HL4a name, and [t.timing] mirrors the serial driver's
   timing for the tests that read it.

   What remains here is HL4a scenario and check code: the composite transactions
   ([receive], [exchange], [transact], [disturb]), the [expect_*] checks other than the
   fixture's LRDY lifecycle checks, and the expected responses ([response],
   [info_payload]). Legal requests are built with [Wire.Request.encode] and responses are
   read with [Wire.Response.decode_correlated]; malformed frames come from [Raw]. The
   suite is the cycle-observed baseline that the HL4b extractions must reproduce.
*)

open! Core
open! Hardcaml
open! Hardcaml_protemu
module Wire = Protemu_host_link_wire.Wire
module Endpoint = Protemu_host_link_endpoint
module Fixture = Endpoint.Fixture
module Sim = Fixture.Sim
module Serial_host = Protemu_serial_host_agent
module Control_port_agent = Protemu_control_port_agent
module Timing = Serial_host.Config.Timing
module Outcome = Serial_host.Item.Outcome
module Pause = Serial_host.Item.Pause
module Read = Serial_host.Item.Read
module Exchange = Serial_host.Item.Exchange
module Raw = Serial_host.Item.Raw

let hex = Serial_host.Item.hex
let bits_of_byte = Serial_host.Item.bits_of_byte
let bytes_of_bits = Serial_host.Item.bytes_of_bits
let encode = Serial_host.Item.encode

(* The checker's latency predictions, shared with the endpoint pilots. *)
module Latency = Endpoint.Latency

(* Decoded offers and core status come from the Control_port agent's [Item]. *)
module Request = Control_port_agent.Item.Request
module Status = Control_port_agent.Item.Status

(* The HL4a name for the Control_port agent's responder (test/core/control_port/), kept as
   a shim so the tests' spelling ([t.stub.accept], [t.stub.memory.(i)],
   [Core_stub.Offer.t], [Core_stub.inject_readback_response], ...) is unchanged. The
   responder's header lists its contract-faithful behavior and its robustness probes. HL4a
   uses the [Outstanding] injection policy: an injected pulse is the pending READBACK
   response, so it can refuse a READBACK and is cancelled like one.
*)
module Core_stub = struct
  module Completion = Control_port_agent.Item.Completion
  module Offer = Control_port_agent.Item.Offer
  module Response = Control_port_agent.Item.Response

  type t = Control_port_agent.Responder.t

  let inject_readback_response = Control_port_agent.Responder.inject_readback_response
end

module Phase = Fixture.Phase
module Event = Fixture.Event

(* The fixture's state under the HL4a name, with its fields, which the tests read. *)
type t = Fixture.t =
  { scenario : string
  ; sim : Sim.t
  ; serial_host : Serial_host.Agent.t
  ; control_port : Control_port_agent.Agent.t
  ; mutable cycle : int
  ; mutable reset : bool
  ; mutable enable : bool
  ; mutable select_n : bool
  ; mutable clock : bool
  ; mutable data : bool
  ; mutable ldi_fault : int -> bool
  ; mutable ready : bool
  ; mutable ldo : bool
  ; mutable busy : bool
  ; mutable ready_changes : (int * bool) list
  ; mutable last_status : Status.t
  ; transcript : (int * Event.t) Queue.t
  ; transcript_limit : int
  ; mutable omitted : int
  ; mutable finished : bool
  ; stub : Core_stub.t
  ; mutable timing : Timing.t
  }

(* The fixture's environment under the HL4a names. *)

let log = Fixture.log
let note = Fixture.note
let transcript = Fixture.transcript
let fail = Fixture.fail
let check = Fixture.check
let failure_of = Fixture.failure_of
let cycle = Fixture.cycle
let hold = Fixture.hold
let set_reset = Fixture.set_reset
let set_enable = Fixture.set_enable
let set_status t status = t.stub.status <- status
let ready_changes = Fixture.ready_changes
let create = Fixture.create
let driver = Fixture.driver
let set_timing = Fixture.set_timing

(* The serial monitor's items, oldest first; a checker dequeues what it compares. *)
let observed = Fixture.serial_observed
let offers = Fixture.offers

let accepted ?since t =
  offers ?since t |> List.filter ~f:(fun (offer : Core_stub.Offer.t) -> offer.accepted)
;;

let responses = Fixture.responses
let expect_ready_cleared = Fixture.expect_ready_cleared
let expect_retained = Fixture.expect_retained

let expect_no_offers t ~since what =
  check
    t
    ~phase:Post_run
    what
    [%sexp_of: Core_stub.Offer.t list]
    [%equal: Core_stub.Offer.t list]
    ~expected:[]
    (offers ~since t)
;;

let expect_offers t ~since what expected =
  check
    t
    ~phase:Post_run
    what
    [%sexp_of: Core_stub.Offer.t list]
    [%equal: Core_stub.Offer.t list]
    ~expected
    (offers ~since t)
;;

let expect_int t ?cycle what ~expected actual =
  check t ?cycle ~phase:Post_run what [%sexp_of: int] Int.equal ~expected actual
;;

(* Holds [cycles] and requires LRDY and LDO low and no offer throughout. *)
let expect_quiet t cycles what =
  let since = t.cycle in
  for _ = 1 to cycles do
    cycle t;
    if t.ready || t.ldo
    then
      fail
        t
        ~phase:Pre_edge
        what
        ~expected:[%sexp { ready = false; ldo = false }]
        ~actual:[%sexp { ready : bool = t.ready; ldo : bool = t.ldo }]
  done;
  expect_no_offers t ~since what
;;

(* Host serial driver: [Serial_host.Driver] through the fixture's adapter, under the HL4a
   names and argument order. Each wrapper's behavior and failure is the driver's.
*)

let select t = Serial_host.Driver.select (driver t)
let deselect t = Serial_host.Driver.deselect (driver t)
let send_bit t value = Serial_host.Driver.send_bit (driver t) value

let send t ?extra_bits ?extra_byte bytes =
  Serial_host.Driver.send (driver t) ?extra_bits ?extra_byte bytes
;;

let send_rest_of_byte t byte ~bits =
  Serial_host.Driver.send_rest_of_byte (driver t) byte ~bits
;;

let begin_frame t = Serial_host.Driver.begin_frame (driver t)
let end_frame t = Serial_host.Driver.end_frame (driver t)

let send_frame t ?extra_bits ?extra_byte bytes =
  Serial_host.Driver.send_frame (driver t) ?extra_bits ?extra_byte bytes
;;

let wait_ready ?budget t ~since = Serial_host.Driver.wait_ready ?budget (driver t) ~since

let read_bit ?final ?high_pause t =
  Serial_host.Driver.read_bit ?final ?high_pause (driver t)
;;

let abandon_response t = Serial_host.Driver.abandon_response (driver t)
let finish_response t outcome = Serial_host.Driver.finish_response (driver t) outcome

let read_response t ?expected ?pause ~decide () =
  Serial_host.Driver.read_response (driver t) ?expected ?pause ~decide ()
;;

let read_prefix t ~bits = Serial_host.Driver.read_prefix (driver t) ~bits
let commit_if_valid = Serial_host.Item.commit_if_valid

(* Waits for LRDY after a request frame, reads and validates the response, commits it, and
   checks that LRDY clears on the commit boundary. A response that fails validation is
   replayed first, so the failure report describes a retained response.
*)
let receive ?ready_budget ?pause t ~started ~request_deselected ~expected =
  let ready = wait_ready ?budget:ready_budget t ~since:request_deselected in
  let read = read_response t ~expected ?pause ~decide:commit_if_valid () in
  match read.decoded with
  | Error error ->
    fail
      t
      ~phase:Host_sample
      "response decodes and correlates; it was replayed"
      ~expected:[%sexp (expected : Wire.Correlation.t)]
      ~actual:[%sexp (error : Wire.Response.Decode_error.t), (hex read.bytes : string)]
  | Ok response ->
    expect_ready_cleared t ~deselected:read.deselected;
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
let exchange ?ready_budget ?pause t frame ~expected =
  let started = t.cycle in
  let request_deselected = send_frame t frame in
  receive ?ready_budget ?pause t ~started ~request_deselected ~expected
;;

let transact ?ready_budget ?pause t ~tag request =
  exchange
    ?ready_budget
    ?pause
    t
    (encode ~tag request)
    ~expected:(Wire.Request.correlation ~tag request)
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
   sending a request ([send] checks that LDO stays low at every rise), deselect, and hold
   the gap. Returns the deselection cycle.
*)
let disturb t bytes =
  note t "out-of-contract selection";
  send_frame t bytes
;;

let expect_response t what ~expected (actual : Wire.Response.t) =
  check
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

let expect_info_works t ~tag what =
  let since = t.cycle in
  let exchange = transact t ~tag Info in
  expect_response
    t
    what
    ~expected:(response ~tag Info ~payload:info_payload Complete)
    exchange.response;
  expect_no_offers t ~since what
;;
