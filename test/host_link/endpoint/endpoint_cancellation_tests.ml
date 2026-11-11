(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "endpoint_cancellation_tests.ml" *)
(* HL4a: in-flight protection, correlation, and reset/disable cancellation at the composed
   [Host_link]'s serial pins and [Control_port], written against the endpoint fixture, its
   agents, and the scoreboard.

   Early selections here are out-of-contract host traffic that the loader must ignore:
   they cannot shift out, consume, or overwrite the command moving through dispatch or a
   completion wait. Each test says whether its responder follows the [Control_port]
   contract or is a robustness probe of the loader's waits. A robustness probe says
   nothing about the current [Emulator_core], whose READBACK and ABORT completions are
   prompt.

   Ported from the HL4a suite's hardware_loader_cancellation_tests.ml with the same names,
   scenarios, order, and checks (docs/serial_host_pilot.md, SP5). Contract-faithful
   scenarios with in-contract host traffic run under [Scoreboard.run], which also requires
   the monitors to have seen each frame and read the driver reports and each offer and
   READBACK response the test writes out, including a response read that reset cuts short,
   which the scoreboard expects as an abandoned read. Early selections, which the serial
   monitor classifies by the host-side rule rather than the loader's, and robustness
   probes run under [Fixture.run].
*)

open! Core
open! Hardcaml_protemu
open! Endpoint_scenario
module Wire = Protemu_host_link_wire.Wire
module Serial_host = Protemu_serial_host_agent
module Driver = Serial_host.Driver
module Item = Serial_host.Item
module Exchange = Serial_host.Item.Exchange
module Control_port_agent = Protemu_control_port_agent
module Request = Control_port_agent.Item.Request
module Status = Control_port_agent.Item.Status
module Response = Control_port_agent.Item.Response
module Endpoint = Protemu_host_link_endpoint
module Fixture = Endpoint.Fixture
module Scoreboard = Endpoint.Scoreboard
module Latency = Endpoint.Latency

(* A legal VERIFY with a tag no scenario uses, clocked in by the early selection. If the
   loader took it as a request, its tag, command, or offer would appear.
*)
let intruder_tag = 0x77

let intruder =
  Item.encode ~tag:intruder_tag (Verify_word { address = 0x55; expected = 0x6666 })
;;

let intruder_correlation = { Wire.Correlation.tag = intruder_tag; command = 0x13 }

(* The response is neither for the intruder nor decodable as its answer. *)
let expect_not_intruder t (exchange : Exchange.t) =
  match Wire.Response.decode_correlated ~expected:intruder_correlation exchange.bytes with
  | Error (Correlation_mismatch _) -> ()
  | result ->
    Fixture.fail
      t
      ~phase:Host_sample
      "the response does not correlate with the early selection's frame"
      ~expected:[%sexp "Correlation_mismatch"]
      ~actual:[%sexp (result : (Wire.Response.t, Wire.Response.Decode_error.t) Result.t)]
;;

(* Sends [request] and deselects without the gap, holds [early] cycles, then selects and
   clocks the intruder frame. Returns the exchange read afterwards.
*)
let with_early_selection ?(disturbances = [ 1 ]) (t : Fixture.t) ~tag request =
  let driver = Fixture.driver t in
  let started = t.cycle in
  Driver.begin_frame driver;
  Driver.send driver (Item.encode ~tag request);
  let request_deselected = Driver.end_frame driver in
  List.iter disturbances ~f:(fun at ->
    Fixture.hold t (request_deselected + at - t.cycle);
    ignore (disturb t intruder : int));
  receive t ~started ~request_deselected ~expected:(Wire.Request.correlation ~tag request)
;;

let%test_unit "an early selection during dispatch cannot consume or overwrite the command"
  =
  (* Contract-faithful responder. Selections one to three cycles after the deselection are
     too early for the loader's four-cycle qualification; the peer uses one to two.
  *)
  List.iter [ 1; 2; 3 ] ~f:(fun early ->
    Fixture.run
      ~scenario:(sprintf "early selection %d cycles into dispatch" early)
      (fun t ->
         let exchange = with_early_selection ~disturbances:[ early ] t ~tag:0x0a Info in
         expect_response
           t
           "INFO after an early selection"
           ~expected:(response ~tag:0x0a Info ~payload:info_payload Complete)
           exchange.response;
         expect_not_intruder t exchange;
         expect_no_offers t ~since:exchange.started "neither INFO nor the intruder offers";
         let exchange =
           with_early_selection
             ~disturbances:[ early ]
             t
             ~tag:0x0b
             (Write_word { address = 0x21; word = 0x4321 })
         in
         expect_response
           t
           "WRITE after an early selection"
           ~expected:(response ~tag:0x0b Write_word Complete)
           exchange.response;
         expect_not_intruder t exchange;
         expect_offered_once
           t
           exchange
           (Load_write { address = 0x21; data = 0x4321 })
           ~accepted:true;
         expect_int
           t
           "LRDY rises one cycle after the offer despite the early selection"
           ~expected:
             (exchange.request_deselected
              + Latency.offer_after_deselect
              + Latency.ready_after_offer)
           exchange.ready))
;;

let%test_unit "an early selection during a READ wait cannot consume or overwrite it" =
  let read = Wire.Request.Read_word { address = 0x3a } in
  let expected = response ~tag:0x3a Read_word ~payload:(Word 0x3a3a) Complete in
  let run ~scenario ~completion ~disturbances =
    Fixture.run ~scenario (fun t ->
      (Fixture.responder t).readback_completion <- completion;
      (Fixture.responder t).memory.(0x3a) <- 0x3a3a;
      let exchange = with_early_selection ~disturbances t ~tag:0x3a read in
      expect_response t "READ after early selections" ~expected exchange.response;
      expect_not_intruder t exchange;
      expect_offered_once t exchange (Read { address = 0x3a }) ~accepted:true;
      let offer = exchange.request_deselected + Latency.offer_after_deselect in
      let extra =
        match completion with
        | Delayed extra -> extra
        | _ -> 0
      in
      expect_int
        t
        "LRDY rises one cycle after the READBACK response"
        ~expected:
          (offer + Latency.readback_after_offer + extra + Latency.ready_after_completion)
        exchange.ready)
  in
  (* Contract-faithful: the response arrives during the early selection. *)
  run
    ~scenario:"early selection over a prompt READ"
    ~completion:Contract
    ~disturbances:[ 1 ];
  (* Robustness probe: a 2000-cycle response delay, with two early selections inside it.
     Each intruder frame takes about 710 cycles to clock in.
  *)
  run
    ~scenario:"robustness: early selections inside a delayed READ"
    ~completion:(Delayed 2000)
    ~disturbances:[ 1; 900 ]
;;

let%test_unit "an early selection during an ABORT wait cannot consume or overwrite it" =
  (* Contract-faithful: cleanup is visible one cycle after the accepting edge. *)
  Fixture.run ~scenario:"early selection over a prompt ABORT" (fun t ->
    set_status t Status.running;
    let exchange = with_early_selection t ~tag:0x76 Abort in
    expect_response
      t
      "ABORT"
      ~expected:(response ~tag:0x76 Abort Complete)
      exchange.response;
    expect_not_intruder t exchange;
    expect_offered_once t exchange Abort ~accepted:true;
    expect_int
      t
      "LRDY rises one cycle after cleanup is visible"
      ~expected:
        (exchange.request_deselected
         + Latency.offer_after_deselect
         + Latency.abort_clean_after_offer
         + Latency.ready_after_completion)
      exchange.ready);
  (* Robustness probe: cleanup never completes by itself. The test clears the five cleanup
     conditions one at a time, with early selections in between; LRDY waits for the last
     one.
  *)
  Fixture.run ~scenario:"robustness: staged ABORT cleanup" (fun t ->
    let driver = Fixture.driver t in
    (Fixture.responder t).abort_completion <- Never;
    set_status t { Status.running with software_claim = 0x10 };
    let started = t.cycle in
    Driver.begin_frame driver;
    Driver.send driver (Item.encode ~tag:0x57 Abort);
    let request_deselected = Driver.end_frame driver in
    let stages : (string * (Status.t -> Status.t)) list =
      [ ("halted", fun s -> { s with halted = 1; execution_active = 0; phase = 0 })
      ; ("engines idle", fun s -> { s with engines_idle = 1 })
      ; ("outputs released", fun s -> { s with pin_oe = 0 })
      ; ("software claim released", fun s -> { s with software_claim = 0 })
      ; ("engine claim released", fun s -> { s with engine_claim = 0 })
      ]
    in
    List.iteri stages ~f:(fun index (what, update) ->
      Fixture.hold t 60;
      if index = 1 then ignore (disturb t intruder : int);
      Fixture.check
        t
        ~phase:Pre_edge
        ("no ABORT response before cleanup: " ^ what)
        [%sexp_of: (int * bool) list]
        [%equal: (int * bool) list]
        ~expected:[]
        (Fixture.ready_changes ~since:request_deselected t);
      set_status t (update (Fixture.responder t).status));
    let visible = t.cycle in
    let exchange =
      receive
        t
        ~started
        ~request_deselected
        ~expected:(Wire.Request.correlation ~tag:0x57 Abort)
    in
    expect_response
      t
      "staged ABORT"
      ~expected:(response ~tag:0x57 Abort Complete)
      exchange.response;
    expect_not_intruder t exchange;
    expect_offered_once t exchange Abort ~accepted:true;
    expect_int
      t
      "LRDY rises one cycle after the last cleanup condition is visible"
      ~expected:(visible + Latency.ready_after_completion)
      exchange.ready)
;;

let%test_unit "consecutive distinct tags and commands each correlate with their own \
               answer"
  =
  (* Contract-faithful. Each answer is decoded against its own request's correlation, and
     against the previous one, which must mismatch. A stale or overwritten answer would
     fail one of the two.
  *)
  Scoreboard.run ~scenario:"correlation sequence" (fun t board ->
    (Fixture.responder t).memory.(1) <- 0x0101;
    (* Each request with the offer it makes, if any, and for READ the READBACK pulse's
       data and match flag, written out for the scoreboard.
    *)
    let requests : (int * Wire.Request.t * (Request.t * (int * bool) option) option) list =
      [ 0x01, Status, None
      ; 0x02, Read_word { address = 1 }, Some (Read { address = 1 }, Some (0x0101, false))
      ; 0x03, Load_start { length = 2 }, Some (Load_start { length = 2 }, None)
      ; 0x04, Info, None
      ; ( 0x05
        , Write_word { address = 1; word = 2 }
        , Some (Load_write { address = 1; data = 2 }, None) )
      ; 0x06, Stop, Some (Stop, None)
      ]
    in
    ignore
      (List.fold requests ~init:None ~f:(fun previous (tag, request, offer) ->
         let exchange = transact ~board t ~tag request in
         Option.iter offer ~f:(fun (offer, readback) ->
           let offered =
             Scoreboard.offer
               board
               ~deselected:exchange.request_deselected
               offer
               ~accepted:true
           in
           Option.iter readback ~f:(fun (data, matches) ->
             Scoreboard.readback board ~offered ~data ~matches));
         Option.iter previous ~f:(fun correlation ->
           match Wire.Response.decode_correlated ~expected:correlation exchange.bytes with
           | Error (Correlation_mismatch _) -> ()
           | result ->
             Fixture.fail
               t
               ~phase:Host_sample
               "an answer does not correlate with the previous request"
               ~actual:
                 [%sexp
                   (result : (Wire.Response.t, Wire.Response.Decode_error.t) Result.t)]);
         Some (Wire.Request.correlation ~tag request))
       : Wire.Correlation.t option))
;;

(* Reset or disable for [cycles] cycles from the current one, then back. *)
let pulse (t : Fixture.t) ~reset ~cycles =
  let at = t.cycle in
  if reset then Fixture.set_reset t true else Fixture.set_enable t false;
  Fixture.hold t cycles;
  if reset then Fixture.set_reset t false else Fixture.set_enable t true;
  at
;;

let%test_unit "reset and disable cancel a partial request" =
  (* As in the peer: one byte and three bits, cancellation with LSEL_N still low, then
     LSEL_N high in the cycle reset or enable is restored.
  *)
  List.iter [ false; true ] ~f:(fun reset ->
    let name = if reset then "reset" else "disable" in
    Scoreboard.run ~scenario:(name ^ " during a partial request") (fun t board ->
      let driver = Fixture.driver t in
      let frame = Item.encode ~tag:0xb0 (Load_start { length = 1 }) in
      let since = t.cycle in
      Driver.begin_frame driver;
      Driver.send driver (String.prefix frame 1) ~extra_bits:3 ~extra_byte:frame.[1];
      if reset then Fixture.set_reset t true else Fixture.set_enable t false;
      Fixture.hold t 4;
      if t.ready || t.ldo || t.busy
      then
        Fixture.fail
          t
          ~phase:Pre_edge
          (name ^ " releases LRDY, LDO, and busy")
          ~actual:
            [%sexp { ready : bool = t.ready; ldo : bool = t.ldo; busy : bool = t.busy }];
      if reset then Fixture.set_reset t false else Fixture.set_enable t true;
      let deselected = Driver.deselect driver in
      record_request
        ~extra_bits:3
        ~extra_byte:frame.[1]
        (Some board)
        ~selected:since
        ~deselected
        (String.prefix frame 1);
      expect_quiet t 300 (name ^ ": the partial request is never answered or offered");
      expect_no_offers t ~since (name ^ ": nothing was offered");
      expect_info_works ~board t ~tag:0xb1 (name ^ ": a fresh INFO works")))
;;

let%test_unit "reset or disable in the dispatch cycle cancels the command" =
  (* Contract-faithful: the offer is still visible in that cycle, and the core refuses
     every offer under reset or disable (item 8). No response follows.
  *)
  List.iter [ false; true ] ~f:(fun reset ->
    let name = if reset then "reset" else "disable" in
    Scoreboard.run ~scenario:(name ^ " in the dispatch cycle") (fun t board ->
      let driver = Fixture.driver t in
      let frame = Item.encode ~tag:0xc0 (Write_word { address = 2; word = 3 }) in
      let started = t.cycle in
      Driver.begin_frame driver;
      Driver.send driver frame;
      let request_deselected = Driver.end_frame driver in
      Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
      Fixture.hold t Latency.offer_after_deselect;
      let at = pulse t ~reset ~cycles:1 in
      expect_int
        t
        (name ^ " falls in the dispatch cycle")
        ~expected:(request_deselected + Latency.offer_after_deselect)
        at;
      expect_quiet t 300 (name ^ ": no response and no further offer");
      expect_offers
        t
        ~since:started
        (name ^ ": the dispatch-cycle offer is refused")
        [ { cycle = at; request = Load_write { address = 2; data = 3 }; accepted = false }
        ];
      ignore
        (Scoreboard.offer
           board
           ~deselected:request_deselected
           (Load_write { address = 2; data = 3 })
           ~accepted:false
         : int);
      expect_info_works ~board t ~tag:0xc1 (name ^ ": a fresh INFO works")))
;;

let%test_unit "reset or disable during a READ wait cancels its response" =
  List.iter [ false; true ] ~f:(fun reset ->
    let name = if reset then "reset" else "disable" in
    (* Contract-faithful: cancellation in the cycle between the accepting edge and the
       next cancels the READBACK response (item 5).
    *)
    Scoreboard.run ~scenario:(name ^ " during a prompt READ") (fun t board ->
      let driver = Fixture.driver t in
      let frame = Item.encode ~tag:0xd0 (Read_word { address = 5 }) in
      let started = t.cycle in
      Driver.begin_frame driver;
      Driver.send driver frame;
      let request_deselected = Driver.end_frame driver in
      Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
      let offer = request_deselected + Latency.offer_after_deselect in
      Fixture.hold t (offer + 1 - t.cycle);
      ignore (pulse t ~reset ~cycles:1 : int);
      expect_quiet t 300 (name ^ ": no READ response");
      Fixture.check
        t
        ~phase:Post_run
        (name ^ ": the READBACK response was cancelled")
        [%sexp_of: Response.t list]
        [%equal: Response.t list]
        ~expected:[]
        (Fixture.responses ~since:started t);
      expect_offers
        t
        ~since:started
        (name ^ ": READ was offered once")
        [ { cycle = offer; request = Read { address = 5 }; accepted = true } ];
      ignore
        (Scoreboard.offer
           board
           ~deselected:request_deselected
           (Read { address = 5 })
           ~accepted:true
         : int);
      (Fixture.responder t).memory.(5) <- 0x0505;
      let exchange = transact ~board t ~tag:0xd1 (Read_word { address = 5 }) in
      expect_response
        t
        (name ^ ": a fresh READ works")
        ~expected:(response ~tag:0xd1 Read_word ~payload:(Word 0x0505) Complete)
        exchange.response;
      let offered =
        Scoreboard.offer
          board
          ~deselected:exchange.request_deselected
          (Read { address = 5 })
          ~accepted:true
      in
      Scoreboard.readback board ~offered ~data:0x0505 ~matches:false);
    (* Robustness probe: a delayed READ is cancelled, then a stray response pulse arrives
       after re-enabling. The loader no longer waits and must ignore it.
    *)
    Fixture.run
      ~scenario:
        (sprintf "robustness: %s during a delayed READ, then a stray response" name)
      (fun t ->
         let driver = Fixture.driver t in
         (Fixture.responder t).readback_completion <- Delayed 100;
         let started = t.cycle in
         Driver.begin_frame driver;
         Driver.send driver (Item.encode ~tag:0xd2 (Read_word { address = 6 }));
         let request_deselected = Driver.end_frame driver in
         Fixture.hold t 40;
         ignore (pulse t ~reset ~cycles:2 : int);
         let stray = request_deselected + 120 in
         Fixture.hold t (stray - t.cycle);
         Control_port_agent.Responder.inject_readback_response
           (Fixture.responder t)
           ~cycle:stray
           ~data:0xdead
           ~matches:false;
         expect_quiet t 300 (name ^ ": the stray response is ignored");
         Fixture.check
           t
           ~phase:Post_run
           (name ^ ": the stray response pulse was driven")
           [%sexp_of: int list]
           [%equal: int list]
           ~expected:[ stray ]
           (List.map (Fixture.responses ~since:started t) ~f:(fun r -> r.cycle));
         expect_info_works t ~tag:0xd3 (name ^ ": a fresh INFO works")))
;;

let%test_unit "robustness: reset or disable during an ABORT wait cancels its response" =
  (* Robustness probe: cleanup never completes by itself. After the cancellation the test
     makes the status clean; the loader no longer waits, so no stale response appears.
  *)
  List.iter [ false; true ] ~f:(fun reset ->
    let name = if reset then "reset" else "disable" in
    Fixture.run ~scenario:(name ^ " during a stalled ABORT") (fun t ->
      let driver = Fixture.driver t in
      (Fixture.responder t).abort_completion <- Never;
      set_status t Status.running;
      let started = t.cycle in
      Driver.begin_frame driver;
      Driver.send driver (Item.encode ~tag:0xe0 Abort);
      let request_deselected = Driver.end_frame driver in
      Fixture.hold t 50;
      ignore (pulse t ~reset ~cycles:3 : int);
      set_status t (Status.cleaned Status.running);
      expect_quiet t 300 (name ^ ": no ABORT response after cleanup");
      expect_offers
        t
        ~since:started
        (name ^ ": ABORT was offered once")
        [ { cycle = request_deselected + Latency.offer_after_deselect
          ; request = Abort
          ; accepted = true
          }
        ];
      expect_info_works t ~tag:0xe1 (name ^ ": a fresh INFO works")))
;;

let%test_unit "disable discards a retained response in the same cycle" =
  (* LRDY is gated by enable, so it falls in the disabled cycle itself; the retained
     response is gone when enable returns.
  *)
  Scoreboard.run ~scenario:"disable with a retained response" (fun t board ->
    let driver = Fixture.driver t in
    let frame = Item.encode ~tag:0xf0 Status in
    let started = t.cycle in
    let request_deselected = Driver.send_frame driver frame in
    Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
    ignore (Driver.wait_ready driver ~since:request_deselected : int);
    Fixture.hold t 10;
    let at = pulse t ~reset:false ~cycles:1 in
    Fixture.check
      t
      ~phase:Pre_edge
      "LRDY falls in the disabled cycle and stays low"
      [%sexp_of: (int * bool) list]
      [%equal: (int * bool) list]
      ~expected:[ at, false ]
      (Fixture.ready_changes ~since:at t);
    expect_quiet t 300 "the discarded response does not return";
    if t.busy then Fixture.fail t ~phase:Pre_edge "busy is clear after the discard";
    expect_no_offers t ~since:started "STATUS offers nothing";
    expect_info_works ~board t ~tag:0xf1 "a fresh INFO works")
;;

let%test_unit "reset discards a partially read response" =
  (* Reset is synchronous: LRDY and LDO fall from the cycle after the first reset edge.
     LSEL_N stays low through reset and rises in the cycle reset is released, as in the
     peer. The scoreboard expects the cut-short read as abandoned, with the twenty bits
     the driver sampled and the cycle it raised LSEL_N.
  *)
  Scoreboard.run ~scenario:"reset during a response read" (fun t board ->
    let driver = Fixture.driver t in
    set_status t { Status.halted_idle with image_valid = 1; image_length = 1 };
    let frame = Item.encode ~tag:0xf2 Status in
    let started = t.cycle in
    let request_deselected = Driver.send_frame driver frame in
    Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
    ignore (Driver.wait_ready driver ~since:request_deselected : int);
    let selected = t.cycle in
    Driver.begin_frame driver;
    let read = Queue.create () in
    for _ = 1 to 20 do
      Queue.enqueue read (Driver.read_bit driver)
    done;
    Fixture.set_reset t true;
    let at = t.cycle in
    Fixture.hold t 3;
    Fixture.check
      t
      ~phase:Pre_edge
      "LRDY falls in the cycle after the first reset edge"
      [%sexp_of: (int * bool) list]
      [%equal: (int * bool) list]
      ~expected:[ at + 1, false ]
      (Fixture.ready_changes ~since:at t);
    Fixture.set_reset t false;
    let deselected = Driver.deselect driver in
    Scoreboard.abandoned
      board
      ~selected
      ~deselected
      ~bits:(Queue.length read)
      (Item.bytes_of_bits (Queue.to_list read));
    expect_quiet t 300 "the discarded response does not return";
    if t.busy then Fixture.fail t ~phase:Pre_edge "busy is clear after reset";
    expect_no_offers t ~since:started "STATUS offers nothing";
    let exchange = transact ~board t ~tag:0xf3 Status in
    expect_response
      t
      "a fresh STATUS after reset"
      ~expected:
        (response
           ~tag:0xf3
           Status
           ~payload:
             (Status
                { flags = [ Enabled; Halted; Engines_idle; Image_valid ]
                ; image_length = 1
                ; words_written = 0
                ; words_verified = 0
                ; pc = 0
                ; fault_kind = No_fault
                ; phase = Halted
                })
           Complete)
      exchange.response)
;;
