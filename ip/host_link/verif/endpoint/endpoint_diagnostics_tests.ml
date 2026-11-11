(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "endpoint_diagnostics_tests.ml" *)
(* HL4a: the harness's key assertions detect the failures they exist for, and report
   enough to reproduce them, written against the endpoint fixture, its agents, and the
   scoreboard.

   Each case sets up a controlled mismatch between what the host did and what the check
   expects, and requires the check to raise [Harness_failure]. None of them changes the
   loader or leaves a failing test in the suite. The first case prints a complete report,
   so its format is reviewed here.

   Ported from the HL4a suite's hardware_loader_diagnostics_tests.ml with the same names,
   scenarios, order, and checks (docs/serial_host_pilot.md, SP5). The checks under test
   are the single implementations in [Fixture] and [Endpoint_scenario], so each report is
   the original's. Contract-faithful scenarios run under [Scoreboard.run], which then
   checks what the monitors saw after the negative has been caught; the robustness and
   construction cases run under [Fixture.run].
*)

open! Core
open! Hardcaml_protemu
open! Endpoint_scenario
module Wire = Protemu_host_link_wire.Wire
module Serial_host = Protemu_serial_host_agent
module Driver = Serial_host.Driver
module Item = Serial_host.Item
module Timing = Serial_host.Config.Timing
module Status = Protemu_control_port_agent.Item.Status
module Endpoint = Protemu_host_link_endpoint
module Fixture = Endpoint.Fixture
module Scoreboard = Endpoint.Scoreboard
module Latency = Endpoint.Latency

let%expect_test "the retention check detects a response that the host committed" =
  (* The host supplies the final fall, which commits the response; the retention check
     that guards replay must then fail at the commit boundary. The transcript is limited
     to twelve events to show how truncation is reported.
  *)
  Scoreboard.run
    ~transcript_limit:12
    ~scenario:"negative: committed response checked as retained"
    (fun t board ->
       let driver = Fixture.driver t in
       set_status t { Status.halted_idle with image_valid = 1 };
       let frame = Item.encode ~tag:0x75 Run in
       let started = t.cycle in
       let request_deselected = Driver.send_frame driver frame in
       Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
       ignore
         (Scoreboard.offer board ~deselected:request_deselected Run ~accepted:true : int);
       ignore (Driver.wait_ready driver ~since:request_deselected : int);
       let selected = t.cycle in
       let read =
         Driver.read_response
           driver
           ~expected:(Wire.Request.correlation ~tag:0x75 Run)
           ~decide:(fun _ -> Commit)
           ()
       in
       Scoreboard.read board ~selected read;
       print_s
         (require_failure t "retention after a commit" (fun () ->
            Fixture.expect_retained t ~deselected:read.deselected ~cycles:10)));
  [%expect
    {|
    (test/host_link/hardware_loader_testbench.ml.Harness_failure
     (scenario "negative: committed response checked as retained") (cycle 990)
     (phase Pre_edge) (what "retained response keeps LRDY high for 10 cycles")
     (expected ((() true))) (actual ((((984 false)) false)))
     (transcript
      ((earlier_events_omitted 2)
       (events
        ((8 (Select true))
         (8 (Sent (bytes "a5 10 75 20 00 00 57") (extra_bits 0)))
         (8 (Status ((halted 1) (engines_idle 1) (image_valid 1))))
         (11 (Busy true)) (460 (Select false))
         (463 (Offer (request Run) (accepted true))) (464 (Ready true))
         (465 (Select true))
         (974 (Response_read (bytes "5a 10 75 20 00 00 00 e6") (outcome Commit)))
         (981 (Select false)) (984 (Ready false)) (984 (Busy false)))))))
    |}]
;;

let%test_unit "the offer check detects a one-cycle change in offer timing" =
  (* HL4b must not add a pipeline stage. An expectation one cycle late stands in for a
     loader that offers one cycle late.
  *)
  Scoreboard.run ~scenario:"negative: offer one cycle late" (fun t board ->
    let exchange = transact ~board t ~tag:0x11 (Write_word { address = 1; word = 2 }) in
    ignore
      (require_failure t "a late offer" (fun () ->
         expect_offers
           t
           ~since:exchange.started
           "offer one cycle later than observed"
           [ { cycle = exchange.request_deselected + Latency.offer_after_deselect + 1
             ; request = Load_write { address = 1; data = 2 }
             ; accepted = true
             }
           ])
       : Sexp.t);
    ignore
      (Scoreboard.offer
         board
         ~deselected:exchange.request_deselected
         (Load_write { address = 1; data = 2 })
         ~accepted:true
       : int))
;;

let%test_unit "the quiet check detects a response that was not cancelled" =
  (* Without the disable, the retained STATUS response keeps LRDY high. *)
  Scoreboard.run ~scenario:"negative: response not discarded" (fun t board ->
    let driver = Fixture.driver t in
    let frame = Item.encode ~tag:0x12 Status in
    let started = t.cycle in
    let request_deselected = Driver.send_frame driver frame in
    Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
    ignore (Driver.wait_ready driver ~since:request_deselected : int);
    ignore
      (require_failure t "a retained response" (fun () -> expect_quiet t 10 "no response")
       : Sexp.t))
;;

let%test_unit "waits are bounded and time out with a report" =
  (* Robustness responder: the READBACK response never arrives. *)
  Fixture.run ~scenario:"negative: bounded wait" (fun t ->
    let driver = Fixture.driver t in
    (Fixture.responder t).readback_completion <- Never;
    let request_deselected =
      Driver.send_frame driver (Item.encode ~tag:0x13 (Read_word { address = 0 }))
    in
    ignore
      (require_failure t "an unbounded wait" (fun () ->
         ignore (Driver.wait_ready ~budget:100 driver ~since:request_deselected : int))
       : Sexp.t);
    expect_int
      t
      "the wait stopped at its budget"
      ~expected:(request_deselected + (Fixture.timing t).deselect_gap + 100)
      t.cycle)
;;

let%test_unit "the harness refuses host timing outside the P3.5 envelope" =
  match
    Fixture.run
      ~timing:{ Timing.envelope with clock_low = 3 }
      ~scenario:"negative: 3-cycle low"
      (fun (_ : Fixture.t) -> ())
  with
  | () -> raise_s [%message "a 3-cycle LCLK low was accepted"]
  | exception _ -> ()
;;
