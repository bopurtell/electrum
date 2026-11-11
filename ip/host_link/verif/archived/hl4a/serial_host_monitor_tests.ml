(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "serial_host_monitor_tests.ml" *)
(* SP2: the serial-host agent's passive monitor agrees with its driver at the composed
   [Host_link]'s serial pins.

   The scoreboard here compares two independent streams. Expected items are written from
   what the driver sent and from the results it returned ([Read.t], [Exchange.t], a prefix
   and its deselection cycle). Actual items are the monitor's, rebuilt from the sampled
   pins alone. Neither component reads the other; only this file joins them. The last case
   corrupts one LDI bit on its way to the DUT, through the testbench's test-only adapter
   path, and requires the scoreboard to report it. See docs/serial_host_pilot.md, SP2.
*)

open! Core
open! Hardcaml_protemu
open! Hardware_loader_testbench
module Observed = Serial_host.Item.Observed

(* Items with bytes in hex, for the trace and for scoreboard reports. *)
let sexp_of_item : Observed.t -> Sexp.t = function
  | Request { selected; deselected; bytes; extra_bits } ->
    [%message
      "request"
        (selected : int)
        (deselected : int)
        ~bytes:(hex bytes : string)
        (extra_bits : bool list)]
  | Response { selected; deselected; bytes; extra_bits; decoded; ending } ->
    [%message
      "response"
        (selected : int)
        (deselected : int)
        ~bytes:(hex bytes : string)
        (extra_bits : bool list)
        (decoded : (Wire.Response.t, Wire.Response.Decode_error.t) Result.t)
        (ending : Observed.Ending.t)]
;;

(* The scoreboard: the monitor's items since the last call are exactly [expected], in
   order. Compared items are dequeued.
*)
let expect_observed t what expected =
  let actual = Queue.to_list (observed t) in
  Queue.clear (observed t);
  check
    t
    ~phase:Post_run
    what
    [%sexp_of: item list]
    [%equal: Observed.t list]
    ~expected
    actual
;;

(* Cycles [begin_frame] holds after LSEL_N falls. [Read.selected] counts from after it;
   the monitor's [selected] is the cycle LSEL_N fell.
*)
let lead t = Int.max 0 (t.timing.select_lead - t.timing.clock_low)

(* Expected items, from the driver's side only. *)

let request ?(extra_bits = 0) ?(extra_byte = '\xff') ~selected ~deselected bytes
  : Observed.t
  =
  Request
    { selected
    ; deselected
    ; bytes
    ; extra_bits = List.take (bits_of_byte extra_byte) extra_bits
    }
;;

(* The monitor decodes without a correlation, so a driver-side mismatch is the response it
   carries.
*)
let uncorrelated = function
  | Error (Wire.Response.Decode_error.Correlation_mismatch { response; _ }) -> Ok response
  | decoded -> decoded
;;

let response_read t (read : Read.t) : Observed.t =
  Response
    { selected = read.selected - lead t
    ; deselected = read.deselected
    ; bytes = read.bytes
    ; extra_bits = []
    ; decoded = uncorrelated read.decoded
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

let expect_transaction t ~tag request =
  let exchange = transact t ~tag request in
  expect_observed
    t
    (Sexp.to_string [%sexp (request : Wire.Request.t)])
    (transaction t exchange (encode ~tag request))
;;

let%expect_test "the monitor's items for one WRITE_WORD transaction" =
  let t = create "monitor trace" in
  let exchange = transact t ~tag:0x31 (Write_word { address = 0x12; word = 0xbeef }) in
  Queue.iter (observed t) ~f:(fun item -> print_s (sexp_of_item item));
  [%expect
    {|
    (request (selected 8) (deselected 716)
     (bytes "a5 10 31 11 04 00 12 00 ef be ff") (extra_bits ()))
    (response (selected 721) (deselected 1237) (bytes "5a 10 31 11 00 00 00 1e")
     (extra_bits ())
     (decoded (Ok ((tag 49) (command 17) (result Complete) (payload Empty))))
     (ending Commit))
    |}];
  expect_observed
    t
    "WRITE_WORD"
    (transaction
       t
       exchange
       (encode ~tag:0x31 (Write_word { address = 0x12; word = 0xbeef })))
;;

let%test_unit "legal INFO, READ, and VERIFY transactions" =
  let t = create "monitor: legal transactions" in
  expect_transaction t ~tag:0x41 Info;
  expect_transaction t ~tag:0x42 (Read_word { address = 3 });
  expect_transaction
    t
    ~tag:0x43
    (Verify_word { address = 3; expected = t.stub.memory.(3) });
  expect_transaction t ~tag:0x44 (Verify_word { address = 4; expected = 0 })
;;

let%test_unit "a malformed request is observed as the raw bytes clocked" =
  let t = create "monitor: malformed request" in
  let info = Wire.Command.to_int Info in
  List.iter
    [ Raw.frame ~magic:0x00 ~tag:0x24 ~command:info []
    ; Raw.flip_last (encode ~tag:0x25 Info) ~mask:0x80
    ]
    ~f:(fun frame ->
      let started = t.cycle in
      let request_deselected = send_frame t frame in
      let exchange =
        receive
          t
          ~started
          ~request_deselected
          ~expected:{ tag = Char.to_int frame.[2]; command = info }
      in
      expect_observed t ("malformed " ^ hex frame) (transaction t exchange frame))
;;

let%test_unit "a request with trailing extra bits keeps them apart from its bytes" =
  let t = create "monitor: extra bits" in
  let frame = encode ~tag:0x26 (Write_word { address = 0; word = 0x1234 }) in
  let started = t.cycle in
  let request_deselected = send_frame t frame ~extra_bits:3 ~extra_byte:'\xa0' in
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
    (transaction t exchange frame ~extra_bits:3 ~extra_byte:'\xa0')
;;

let%test_unit "a replayed response, then its commit" =
  let t = create "monitor: replay" in
  let frame = encode ~tag:0x27 Status in
  let expected = Wire.Request.correlation ~tag:0x27 Status in
  let started = t.cycle in
  let request_deselected = send_frame t frame in
  ignore (wait_ready t ~since:request_deselected : int);
  let replayed = read_response t ~expected ~decide:(fun _ -> Replay) () in
  let exchange = receive t ~started ~request_deselected ~expected in
  expect_observed
    t
    "STATUS replayed once, then committed"
    [ request ~selected:started ~deselected:request_deselected frame
    ; response_read t replayed
    ; committed t exchange
    ]
;;

let%test_unit "abandoned reads before and after the header" =
  (* INFO is the largest response, so the frame its header declares is
     [Wire.Response.max_length] bytes. Twenty-four bits stop inside the header; sixty-four
     stop after it, where only the declared length shows the read was cut short.
  *)
  let t = create "monitor: abandoned reads" in
  let frame = encode ~tag:0x28 Info in
  let started = t.cycle in
  let request_deselected = send_frame t frame in
  ignore (wait_ready t ~since:request_deselected : int);
  let abandoned ~bits ~decoded =
    let selected = t.cycle in
    let bytes, deselected = read_prefix t ~bits in
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
    ]
;;

let%test_unit "the agent is active only with a driver" =
  let passive = Serial_host.Agent.create Serial_host.Config.passive in
  assert (Option.is_none passive.driver);
  assert (Queue.is_empty (Serial_host.Agent.observed passive));
  match Serial_host.Agent.create (Serial_host.Config.active ()) with
  | (_ : Serial_host.Agent.t) -> raise_s [%message "an active agent without hooks"]
  | exception _ -> ()
;;

let require_failure t what f =
  match failure_of f with
  | Some failure -> failure
  | None -> fail t ~phase:Post_run ("the negative check must fail: " ^ what)
;;

let%expect_test "the scoreboard reports an LDI bit the driver did not send" =
  (* Test-only: the adapter inverts LDI on its way to the DUT for the whole interval of
     request bit 20, from the fall before it to the fall after it. That is bit 4 of the
     tag byte, so the pins carry tag 0x4a where the driver sent 0x42. The driver's own
     record is unchanged; only the monitor can see the difference.
  *)
  let t = create ~transcript_limit:4 "negative: one LDI bit corrupted" in
  let frame = encode ~tag:0x42 Info in
  let started = t.cycle in
  let period = t.timing.clock_low + t.timing.clock_high in
  let from = started + lead t + (20 * period) in
  t.ldi_fault <- (fun cycle -> cycle >= from && cycle < from + period);
  let request_deselected = send_frame t frame in
  t.ldi_fault <- Fn.const false;
  print_s
    (require_failure t "a corrupted LDI bit" (fun () ->
       expect_observed
         t
         "the monitor saw the frame the driver sent"
         [ request ~selected:started ~deselected:request_deselected frame ]));
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
