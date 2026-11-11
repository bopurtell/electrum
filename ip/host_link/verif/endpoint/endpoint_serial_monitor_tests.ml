(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "endpoint_serial_monitor_tests.ml" *)
(* SP2: the serial-host agent's passive monitor agrees with its driver at the composed
   [Host_link]'s serial pins, written against the endpoint fixture.

   The scoreboard here compares two independent streams. Expected items are written from
   what the driver sent and from the results it returned ([Read.t], [Exchange.t], a prefix
   and its deselection cycle). Actual items are the monitor's, rebuilt from the sampled
   pins alone. Neither component reads the other; only this file and its helpers in
   [Endpoint_scenario] ([expect_observed] and the expected-item builders) join them. The
   last case corrupts one LDI bit on its way to the DUT, through the fixture's test-only
   adapter path ([ldi_fault]), and requires the scoreboard to report it. See
   docs/serial_host_pilot.md, SP2.

   Ported from the archived SP2 suite's serial_host_monitor_tests.ml with the same names,
   scenarios, order, and checks (docs/serial_host_pilot.md, SP5). The serial comparisons
   stay this file's own, so each drains the serial monitor itself. The contract-faithful
   cases run under [Scoreboard.run] with only Control_port expectations on the board: the
   offers and READBACK responses the test writes out, and, on the serial side, that
   nothing was left unchecked. The agent construction case builds no fixture, and the
   fault injection runs under [Fixture.run].
*)

open! Core
open! Hardcaml_protemu
open! Endpoint_scenario
module Wire = Protemu_host_link_wire.Wire
module Serial_host = Protemu_serial_host_agent
module Driver = Serial_host.Driver
module Item = Serial_host.Item
module Observed = Serial_host.Item.Observed
module Raw = Serial_host.Item.Raw
module Exchange = Serial_host.Item.Exchange
module Endpoint = Protemu_host_link_endpoint
module Fixture = Endpoint.Fixture
module Scoreboard = Endpoint.Scoreboard

let%expect_test "the monitor's items for one WRITE_WORD transaction" =
  Scoreboard.run ~scenario:"monitor trace" (fun t board ->
    let exchange = transact t ~tag:0x31 (Write_word { address = 0x12; word = 0xbeef }) in
    Queue.iter (Fixture.serial_observed t) ~f:(fun item ->
      print_s (Scoreboard.sexp_of_serial_item item));
    expect_observed
      t
      "WRITE_WORD"
      (transaction
         t
         exchange
         (Item.encode ~tag:0x31 (Write_word { address = 0x12; word = 0xbeef })));
    ignore
      (Scoreboard.offer
         board
         ~deselected:exchange.request_deselected
         (Load_write { address = 0x12; data = 0xbeef })
         ~accepted:true
       : int));
  [%expect
    {|
    (request (selected 8) (deselected 716)
     (bytes "a5 10 31 11 04 00 12 00 ef be ff") (extra_bits ()))
    (response (selected 721) (deselected 1237) (bytes "5a 10 31 11 00 00 00 1e")
     (extra_bits ())
     (decoded (Ok ((tag 49) (command 17) (result Complete) (payload Empty))))
     (ending Commit))
    |}]
;;

let%test_unit "legal INFO, READ, and VERIFY transactions" =
  (* The READBACK data is the responder's default memory, [address * 0x0101 lxor 0xa55a]:
     0xa659 at address 3 and 0xa15e at address 4.
  *)
  Scoreboard.run ~scenario:"monitor: legal transactions" (fun t board ->
    let offer (exchange : Exchange.t) request ~data ~matches =
      let offered =
        Scoreboard.offer
          board
          ~deselected:exchange.request_deselected
          request
          ~accepted:true
      in
      Scoreboard.readback board ~offered ~data ~matches
    in
    ignore (expect_transaction t ~tag:0x41 Info : Exchange.t);
    offer
      (expect_transaction t ~tag:0x42 (Read_word { address = 3 }))
      (Read { address = 3 })
      ~data:0xa659
      ~matches:false;
    offer
      (expect_transaction
         t
         ~tag:0x43
         (Verify_word { address = 3; expected = (Fixture.responder t).memory.(3) }))
      (Verify { address = 3; expected = 0xa659 })
      ~data:0xa659
      ~matches:true;
    offer
      (expect_transaction t ~tag:0x44 (Verify_word { address = 4; expected = 0 }))
      (Verify { address = 4; expected = 0 })
      ~data:0xa15e
      ~matches:false)
;;

let%test_unit "a malformed request is observed as the raw bytes clocked" =
  Scoreboard.run ~scenario:"monitor: malformed request" (fun t (_ : Scoreboard.t) ->
    let info = Wire.Command.to_int Info in
    List.iter
      [ Raw.frame ~magic:0x00 ~tag:0x24 ~command:info []
      ; Raw.flip_last (Item.encode ~tag:0x25 Info) ~mask:0x80
      ]
      ~f:(fun frame ->
        let started = t.cycle in
        let request_deselected = Driver.send_frame (Fixture.driver t) frame in
        let exchange =
          receive
            t
            ~started
            ~request_deselected
            ~expected:{ tag = Char.to_int frame.[2]; command = info }
        in
        expect_observed t ("malformed " ^ Item.hex frame) (transaction t exchange frame)))
;;

let%test_unit "a request with trailing extra bits keeps them apart from its bytes" =
  Scoreboard.run ~scenario:"monitor: extra bits" (fun t (_ : Scoreboard.t) ->
    let frame = Item.encode ~tag:0x26 (Write_word { address = 0; word = 0x1234 }) in
    let started = t.cycle in
    let request_deselected =
      Driver.send_frame (Fixture.driver t) frame ~extra_bits:3 ~extra_byte:'\xa0'
    in
    let exchange =
      receive
        t
        ~started
        ~request_deselected
        ~expected:{ tag = 0x26; command = Wire.Command.to_int Write_word }
    in
    expect_observed
      t
      "WRITE_WORD and three bits"
      (transaction t exchange frame ~extra_bits:3 ~extra_byte:'\xa0'))
;;

let%test_unit "a replayed response, then its commit" =
  Scoreboard.run ~scenario:"monitor: replay" (fun t (_ : Scoreboard.t) ->
    let driver = Fixture.driver t in
    let frame = Item.encode ~tag:0x27 Status in
    let expected = Wire.Request.correlation ~tag:0x27 Status in
    let started = t.cycle in
    let request_deselected = Driver.send_frame driver frame in
    ignore (Driver.wait_ready driver ~since:request_deselected : int);
    let replayed = Driver.read_response driver ~expected ~decide:(fun _ -> Replay) () in
    let exchange = receive t ~started ~request_deselected ~expected in
    expect_observed
      t
      "STATUS replayed once, then committed"
      [ request ~selected:started ~deselected:request_deselected frame
      ; response_read t replayed
      ; committed t exchange
      ])
;;

let%test_unit "abandoned reads before and after the header" =
  (* INFO is the largest response, so the frame its header declares is
     [Wire.Response.max_length] bytes. Twenty-four bits stop inside the header; sixty-four
     stop after it, where only the declared length shows the read was cut short.
  *)
  Scoreboard.run ~scenario:"monitor: abandoned reads" (fun t (_ : Scoreboard.t) ->
    let driver = Fixture.driver t in
    let frame = Item.encode ~tag:0x28 Info in
    let started = t.cycle in
    let request_deselected = Driver.send_frame driver frame in
    ignore (Driver.wait_ready driver ~since:request_deselected : int);
    let abandoned ~bits ~decoded =
      let selected = t.cycle in
      let bytes, deselected = Driver.read_prefix driver ~bits in
      Observed.Response
        { selected; deselected; bytes; extra_bits = []; decoded; ending = Abandoned }
    in
    let short =
      abandoned
        ~bits:24
        ~decoded:(Error (Truncated { expected = Wire.Response.min_length; actual = 3 }))
    in
    let past_header =
      abandoned
        ~bits:64
        ~decoded:(Error (Truncated { expected = Wire.Response.max_length; actual = 8 }))
    in
    let exchange =
      receive
        t
        ~started
        ~request_deselected
        ~expected:(Wire.Request.correlation ~tag:0x28 Info)
    in
    expect_observed
      t
      "INFO abandoned twice, then committed"
      [ request ~selected:started ~deselected:request_deselected frame
      ; short
      ; past_header
      ; committed t exchange
      ])
;;

let%test_unit "the agent is active only with a driver" =
  let passive = Serial_host.Agent.create Serial_host.Config.passive in
  assert (Option.is_none passive.driver);
  assert (Queue.is_empty (Serial_host.Agent.observed passive));
  match Serial_host.Agent.create (Serial_host.Config.active ()) with
  | (_ : Serial_host.Agent.t) -> raise_s [%message "an active agent without hooks"]
  | exception _ -> ()
;;

let%expect_test "the scoreboard reports an LDI bit the driver did not send" =
  (* Test-only: the adapter inverts LDI on its way to the DUT for the whole interval of
     request bit 20, from the fall before it to the fall after it. That is bit 4 of the
     tag byte, so the pins carry tag 0x4a where the driver sent 0x42. The driver's own
     record is unchanged; only the monitor can see the difference.
  *)
  Fixture.run ~transcript_limit:4 ~scenario:"negative: one LDI bit corrupted" (fun t ->
    let frame = Item.encode ~tag:0x42 Info in
    let started = t.cycle in
    let timing = Fixture.timing t in
    let period = timing.clock_low + timing.clock_high in
    let from = started + lead t + (20 * period) in
    t.ldi_fault <- (fun cycle -> cycle >= from && cycle < from + period);
    let request_deselected = Driver.send_frame (Fixture.driver t) frame in
    t.ldi_fault <- Fn.const false;
    print_s
      (require_failure t "a corrupted LDI bit" (fun () ->
         expect_observed
           t
           "the monitor saw the frame the driver sent"
           [ request ~selected:started ~deselected:request_deselected frame ])));
  [%expect
    {|
    (test/host_link/hardware_loader_testbench.ml.Harness_failure
     (scenario "negative: one LDI bit corrupted") (cycle 463) (phase Post_run)
     (what "the monitor saw the frame the driver sent")
     (expected
      (((request (selected 8) (deselected 460) (bytes "a5 10 42 00 00 00 df")
         (extra_bits ())))))
     (actual
      (((request (selected 8) (deselected 460) (bytes "a5 10 4a 00 00 00 df")
         (extra_bits ())))))
     (transcript
      ((earlier_events_omitted 3)
       (events
        ((8 (Sent (bytes "a5 10 42 00 00 00 df") (extra_bits 0)))
         (11 (Busy true)) (460 (Select false)) (463 (Ready true)))))))
    |}]
;;
