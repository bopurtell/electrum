(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "endpoint_transaction_tests.ml" *)
(* HL4a: legal transactions, host timing, pauses, and response replay/commit at the
   composed [Host_link]'s serial pins and [Control_port], written against the endpoint
   fixture, its agents, and the scoreboard.

   Expected responses are written out from the P3.5 record and the scenario's responder
   configuration, never computed from the offered request or the loader's logic. Each test
   says whether its responder follows the [Control_port] contract or deliberately departs
   from it as a loader robustness probe. See docs/host_link_hl4a_record.md for the case
   map.

   Ported from the HL4a suite's hardware_loader_transaction_tests.ml with the same names,
   scenarios, order, and checks (docs/serial_host_pilot.md, SP5). Contract-faithful
   scenarios run under [Scoreboard.run], which also requires the monitors to have seen
   each frame and read the driver reports and each offer and READBACK response the test
   writes out; so do the refused STOP and ABORT probes, whose host traffic is in contract.
   Other robustness probes, and scenarios the scoreboard cannot express, run under
   [Fixture.run].
*)

open! Core
open! Electrum_mechanisms
open! Electrum_core
open! Electrum_host_link
open! Endpoint_scenario
module Wire = Host_link_protocol
module Serial_host = Electrum_serial_host_agent
module Driver = Serial_host.Driver
module Item = Serial_host.Item
module Timing = Serial_host.Config.Timing
module Pause = Serial_host.Item.Pause
module Control_port_agent = Electrum_control_port_agent
module Request = Control_port_agent.Item.Request
module Status = Control_port_agent.Item.Status
module Response = Control_port_agent.Item.Response
module Offer = Control_port_agent.Item.Offer
module Endpoint = Electrum_host_link_endpoint
module Fixture = Endpoint.Fixture
module Scoreboard = Endpoint.Scoreboard
module Latency = Endpoint.Latency

(* Raw INFO response for tag 0x5c, with its CRC from an independent bitwise CRC-8/ATM
   script (check value [123456789] -> [0xf4]), not from [Wire].
*)
let info_response_5c = "5a 10 5c 00 00 0d 00 01 00 01 01 7f 00 10 00 00 01 04 00 08 36"

let%test_unit "INFO and STATUS report the fixed descriptor and the core's status" =
  (* Contract-faithful: status is a live observation with no qualifier (item 9). *)
  Scoreboard.run ~scenario:"INFO and STATUS" (fun t board ->
    let exchange = transact ~board t ~tag:0x5c Info in
    Fixture.check
      t
      ~phase:Host_sample
      "INFO bytes"
      [%sexp_of: string]
      String.equal
      ~expected:info_response_5c
      (Item.hex exchange.bytes);
    expect_response
      t
      "INFO"
      ~expected:(response ~tag:0x5c Info ~payload:info_payload Complete)
      exchange.response;
    expect_no_offers t ~since:exchange.started "INFO is answered without an offer";
    expect_int
      t
      "INFO is ready one cycle after its dispatch cycle"
      ~expected:
        (exchange.request_deselected
         + Latency.offer_after_deselect
         + Latency.ready_after_offer)
      exchange.ready;
    let status_cases : (string * Status.t * Wire.Status.t) list =
      [ ( "after reset"
        , Status.halted_idle
        , { flags = [ Enabled; Halted; Engines_idle ]
          ; image_length = 0
          ; words_written = 0
          ; words_verified = 0
          ; pc = 0
          ; fault_kind = No_fault
          ; phase = Halted
          } )
      ; ( "verified image after a normal halt"
        , { Status.halted_idle with
            image_valid = 1
          ; image_length = 3
          ; words_written = 3
          ; words_verified = 3
          ; normal_halt = 1
          ; pc = 2
          }
        , { flags = [ Enabled; Halted; Engines_idle; Image_valid; Normal_halt ]
          ; image_length = 3
          ; words_written = 3
          ; words_verified = 3
          ; pc = 2
          ; fault_kind = No_fault
          ; phase = Halted
          } )
      ; ( "executing with an engine on pin 1; the 17-bit PC is reported in 16 bits"
        , { Status.running with image_length = 10; pc = 0x1_0007 }
        , { flags =
              [ Enabled; Image_valid; Execution_active; Pin_output_enabled; Pin_claimed ]
          ; image_length = 10
          ; words_written = 0
          ; words_verified = 0
          ; pc = 0x0007
          ; fault_kind = No_fault
          ; phase = Mechanism_wait
          } )
      ; ( "invalid-instruction fault"
        , { Status.halted_idle with
            image_valid = 1
          ; image_length = 1
          ; words_written = 1
          ; words_verified = 1
          ; execution_fault = 1
          ; fault_kind = 1
          ; phase = 6
          ; pc = 1
          }
        , { flags = [ Enabled; Halted; Engines_idle; Image_valid; Execution_fault ]
          ; image_length = 1
          ; words_written = 1
          ; words_verified = 1
          ; pc = 1
          ; fault_kind = Invalid_base
          ; phase = Fault
          } )
      ; ( "load in progress with a failed verify, a fetch fault, and a software claim"
        , { Status.halted_idle with
            load_active = 1
          ; verification_failed = 1
          ; fetch_fault = 1
          ; image_length = 256
          ; words_written = 255
          ; words_verified = 17
          ; software_claim = 0x80
          ; fault_kind = 9
          ; phase = 3
          }
        , { flags =
              [ Enabled
              ; Halted
              ; Engines_idle
              ; Load_active
              ; Verification_failed
              ; Fetch_fault
              ; Pin_claimed
              ]
          ; image_length = 256
          ; words_written = 255
          ; words_verified = 17
          ; pc = 0
          ; fault_kind = Mechanism_protocol
          ; phase = Extension_wait
          } )
      ]
    in
    List.iteri status_cases ~f:(fun index (what, status, expected) ->
      set_status t status;
      let tag = 0x60 + index in
      let exchange = transact ~board t ~tag Status in
      expect_response
        t
        ("STATUS " ^ what)
        ~expected:(response ~tag Status ~payload:(Status expected) Complete)
        exchange.response;
      expect_no_offers t ~since:exchange.started "STATUS is answered without an offer"))
;;

(* One accepted command: its request, response, and when LRDY rises after the offer.
   [readback] is the READBACK pulse's data and match flag for READ and VERIFY.
*)
type accepted_case =
  { what : string
  ; wire : Wire.Request.t
  ; request : Request.t
  ; expected : Wire.Response.t
  ; ready_after_offer : int
  ; readback : (int * bool) option
  ; prepare : Fixture.t -> unit
  }

let%test_unit "each shared command is offered once with its operands and completes on \
               time"
  =
  (* Contract-faithful: the responder accepts every offer, READBACK responds at item 5's
     cycle, and ABORT cleanup is visible after the accepting edge (item 6).
  *)
  Scoreboard.run ~scenario:"accepted commands" (fun t board ->
    let immediate = Latency.ready_after_offer in
    let readback = Latency.readback_after_offer + Latency.ready_after_completion in
    let abort = Latency.abort_clean_after_offer + Latency.ready_after_completion in
    let no_prep (_ : Fixture.t) = () in
    let cases =
      [ { what = "LOAD_START of one word"
        ; wire = Load_start { length = 1 }
        ; request = Load_start { length = 1 }
        ; expected = response ~tag:0x10 Load_start Complete
        ; ready_after_offer = immediate
        ; readback = None
        ; prepare = no_prep
        }
      ; { what = "LOAD_START of the whole memory"
        ; wire = Load_start { length = 256 }
        ; request = Load_start { length = 256 }
        ; expected = response ~tag:0x11 Load_start Complete
        ; ready_after_offer = immediate
        ; readback = None
        ; prepare = no_prep
        }
      ; { what = "WRITE_WORD at address 0"
        ; wire = Write_word { address = 0; word = 0xbeef }
        ; request = Load_write { address = 0; data = 0xbeef }
        ; expected = response ~tag:0x12 Write_word Complete
        ; ready_after_offer = immediate
        ; readback = None
        ; prepare = no_prep
        }
      ; { what = "WRITE_WORD at the last address"
        ; wire = Write_word { address = 255; word = 0x1234 }
        ; request = Load_write { address = 255; data = 0x1234 }
        ; expected = response ~tag:0x13 Write_word Complete
        ; ready_after_offer = immediate
        ; readback = None
        ; prepare = no_prep
        }
      ; { what = "READ_WORD"
        ; wire = Read_word { address = 7 }
        ; request = Read { address = 7 }
        ; expected = response ~tag:0x14 Read_word ~payload:(Word 0x0bad) Complete
        ; ready_after_offer = readback
        ; readback = Some (0x0bad, false)
        ; prepare = (fun t -> (Fixture.responder t).memory.(7) <- 0x0bad)
        }
      ; { what = "VERIFY_WORD that matches"
        ; wire = Verify_word { address = 9; expected = 0x5678 }
        ; request = Verify { address = 9; expected = 0x5678 }
        ; expected = response ~tag:0x15 Verify_word ~payload:(Word 0x5678) Complete
        ; ready_after_offer = readback
        ; readback = Some (0x5678, true)
        ; prepare = (fun t -> (Fixture.responder t).memory.(9) <- 0x5678)
        }
      ; { what = "LOAD_COMPLETE"
        ; wire = Load_complete
        ; request = Load_complete
        ; expected = response ~tag:0x16 Load_complete Complete
        ; ready_after_offer = immediate
        ; readback = None
        ; prepare = no_prep
        }
      ; { what = "RUN"
        ; wire = Run
        ; request = Run
        ; expected = response ~tag:0x17 Run Complete
        ; ready_after_offer = immediate
        ; readback = None
        ; prepare = no_prep
        }
      ; { what = "STOP while executing"
        ; wire = Stop
        ; request = Stop
        ; expected = response ~tag:0x18 Stop Accepted_pending
        ; ready_after_offer = immediate
        ; readback = None
        ; prepare = (fun t -> set_status t Status.running)
        }
      ; { what = "ABORT while an engine drives pin 1"
        ; wire = Abort
        ; request = Abort
        ; expected = response ~tag:0x19 Abort Complete
        ; ready_after_offer = abort
        ; readback = None
        ; prepare = (fun t -> set_status t Status.running)
        }
      ; { what = "STOP while halted"
        ; wire = Stop
        ; request = Stop
        ; expected = response ~tag:0x1a Stop Accepted_pending
        ; ready_after_offer = immediate
        ; readback = None
        ; prepare = no_prep
        }
      ]
    in
    List.iter cases ~f:(fun case ->
      case.prepare t;
      let exchange = transact ~board t ~tag:case.expected.tag case.wire in
      expect_response t case.what ~expected:case.expected exchange.response;
      expect_offered_once t exchange case.request ~accepted:true;
      let offered =
        Scoreboard.offer
          board
          ~deselected:exchange.request_deselected
          case.request
          ~accepted:true
      in
      Option.iter case.readback ~f:(fun (data, matches) ->
        Scoreboard.readback board ~offered ~data ~matches);
      let offer = exchange.request_deselected + Latency.offer_after_deselect in
      expect_int
        t
        (case.what ^ ": LRDY rises on time after the offer")
        ~expected:(offer + case.ready_after_offer)
        exchange.ready;
      (match case.request with
       | Read _ | Verify _ ->
         Fixture.check
           t
           ~phase:Post_run
           (case.what ^ ": one READBACK response, two cycles after the offer")
           [%sexp_of: int list]
           [%equal: int list]
           ~expected:[ offer + Latency.readback_after_offer ]
           (List.map (Fixture.responses ~since:exchange.started t) ~f:(fun r -> r.cycle))
       | _ -> ());
      expect_quiet t 200 (case.what ^ ": the command is never offered again")))
;;

(* One refused command and the result its status selects. *)
type refused_case =
  { status_name : string
  ; status : Status.t
  ; wire : Wire.Request.t
  ; request : Request.t
  ; result : Wire.Result_code.t
  }

let%test_unit "a refused command reports the status-derived class and has no side effect" =
  (* The responder refuses every offer. The classes are P3.5's results table applied to
     the status fields the HL3 record lists as refusal inputs: not halted gives
     [Active_execution], halted with an engine active gives [Engines_active], RUN with no
     image gives [No_verified_image], and anything else gives [Image_bounds].
     Program-request and RUN refusals are contract-faithful. A refused STOP or ABORT is a
     robustness probe: the real core accepts both whenever it is enabled and out of reset
     (item 4). Every case's host traffic is in contract, so the scoreboard also expects
     each frame, its committed read, and its refused offer, and no READBACK response.
  *)
  Scoreboard.run ~scenario:"refused commands" (fun t board ->
    (Fixture.responder t).accept <- (fun _ -> false);
    let busy_engine = { Status.halted_idle with engines_idle = 0; image_valid = 1 } in
    let with_image = { Status.halted_idle with image_valid = 1 } in
    let cases =
      [ { status_name = "executing"
        ; status = Status.running
        ; wire = Load_start { length = 1 }
        ; request = Load_start { length = 1 }
        ; result = Active_execution
        }
      ; { status_name = "executing"
        ; status = Status.running
        ; wire = Write_word { address = 1; word = 2 }
        ; request = Load_write { address = 1; data = 2 }
        ; result = Active_execution
        }
      ; { status_name = "executing"
        ; status = Status.running
        ; wire = Read_word { address = 0 }
        ; request = Read { address = 0 }
        ; result = Active_execution
        }
      ; { status_name = "executing"
        ; status = Status.running
        ; wire = Run
        ; request = Run
        ; result = Active_execution
        }
      ; { status_name = "halted, engine active"
        ; status = busy_engine
        ; wire = Verify_word { address = 3; expected = 4 }
        ; request = Verify { address = 3; expected = 4 }
        ; result = Engines_active
        }
      ; { status_name = "halted, engine active"
        ; status = busy_engine
        ; wire = Run
        ; request = Run
        ; result = Engines_active
        }
      ; { status_name = "halted, no image"
        ; status = Status.halted_idle
        ; wire = Run
        ; request = Run
        ; result = No_verified_image
        }
      ; { status_name = "halted, no image"
        ; status = Status.halted_idle
        ; wire = Load_complete
        ; request = Load_complete
        ; result = Image_bounds
        }
      ; { status_name = "halted, no image"
        ; status = Status.halted_idle
        ; wire = Write_word { address = 5; word = 6 }
        ; request = Load_write { address = 5; data = 6 }
        ; result = Image_bounds
        }
      ; { status_name = "halted, verified image"
        ; status = with_image
        ; wire = Run
        ; request = Run
        ; result = Image_bounds
        }
      ; { status_name = "robustness: STOP refused while halted"
        ; status = Status.halted_idle
        ; wire = Stop
        ; request = Stop
        ; result = Image_bounds
        }
      ; { status_name = "robustness: ABORT refused while executing"
        ; status = Status.running
        ; wire = Abort
        ; request = Abort
        ; result = Active_execution
        }
      ]
    in
    List.iteri cases ~f:(fun index case ->
      set_status t case.status;
      let tag = 0x20 + index in
      let exchange = transact ~board t ~tag case.wire in
      let what =
        sprintf
          "%s: %s"
          case.status_name
          (Sexp.to_string [%sexp (case.request : Request.t)])
      in
      expect_response
        t
        what
        ~expected:(response ~tag (Wire.Request.command case.wire) case.result)
        exchange.response;
      expect_offered_once t exchange case.request ~accepted:false;
      ignore
        (Scoreboard.offer
           board
           ~deselected:exchange.request_deselected
           case.request
           ~accepted:false
         : int);
      expect_int
        t
        (what ^ ": a refusal is answered at once")
        ~expected:
          (exchange.request_deselected
           + Latency.offer_after_deselect
           + Latency.ready_after_offer)
        exchange.ready;
      Fixture.check
        t
        ~phase:Post_run
        (what ^ ": no READBACK response follows a refusal")
        [%sexp_of: Response.t list]
        [%equal: Response.t list]
        ~expected:[]
        (Fixture.responses ~since:exchange.started t));
    Fixture.check
      t
      ~phase:Post_run
      "no refused command has an accepted side effect"
      [%sexp_of: Offer.t list]
      [%equal: Offer.t list]
      ~expected:[]
      (accepted t))
;;

let%test_unit "VERIFY reports a mismatch with the actual word; READ ignores the match \
               flag"
  =
  (* Contract-faithful. The responder drives the match flag low for READ, where it is
     meaningless (see [Control_port_agent.Responder]).
  *)
  Scoreboard.run ~scenario:"verify mismatch" (fun t board ->
    (Fixture.responder t).memory.(0) <- 0xbeef;
    let exchange =
      transact ~board t ~tag:0x43 (Verify_word { address = 0; expected = 0xcafe })
    in
    expect_response
      t
      "VERIFY mismatch carries the actual word"
      ~expected:
        (response ~tag:0x43 Verify_word ~payload:(Word 0xbeef) Verification_mismatch)
      exchange.response;
    let offered =
      Scoreboard.offer
        board
        ~deselected:exchange.request_deselected
        (Verify { address = 0; expected = 0xcafe })
        ~accepted:true
    in
    Scoreboard.readback board ~offered ~data:0xbeef ~matches:false;
    let exchange = transact ~board t ~tag:0x44 (Read_word { address = 0 }) in
    expect_response
      t
      "READ with a low match flag"
      ~expected:(response ~tag:0x44 Read_word ~payload:(Word 0xbeef) Complete)
      exchange.response;
    let offered =
      Scoreboard.offer
        board
        ~deselected:exchange.request_deselected
        (Read { address = 0 })
        ~accepted:true
    in
    Scoreboard.readback board ~offered ~data:0xbeef ~matches:false)
;;

let%test_unit "a selected request may pause for a long finite time between and within \
               bits"
  =
  (* Contract-faithful. P3.5 has no inactivity timeout; ten thousand cycles is a long
     finite pause, not a proof of an unbounded one.
  *)
  Scoreboard.run ~scenario:"request pause" (fun t board ->
    let driver = Fixture.driver t in
    let pause = 10_000 in
    let request = Wire.Request.Write_word { address = 0x42; word = 0xa1b2 } in
    let frame = Item.encode ~tag:0x31 request in
    let started = t.cycle in
    Driver.begin_frame driver;
    Driver.send driver (String.prefix frame 3);
    Fixture.hold t pause;
    Driver.send
      driver
      (String.sub frame ~pos:3 ~len:2)
      ~extra_bits:3
      ~extra_byte:frame.[5];
    Fixture.hold t pause;
    Driver.send_rest_of_byte driver frame.[5] ~bits:3;
    (* The last bit of byte 6 holds LCLK high for the pause. *)
    Driver.send driver "" ~extra_bits:7 ~extra_byte:frame.[6];
    let timing = Fixture.timing t in
    Fixture.set_timing t { timing with clock_high = pause };
    Driver.send_rest_of_byte driver frame.[6] ~bits:7;
    Fixture.set_timing t timing;
    Driver.send driver (String.drop_prefix frame 7);
    let request_deselected = Driver.end_frame driver in
    Fixture.hold t (Fixture.timing t).deselect_gap;
    Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
    let exchange =
      receive
        ~board
        t
        ~started
        ~request_deselected
        ~expected:(Wire.Request.correlation ~tag:0x31 request)
    in
    expect_response
      t
      "paused WRITE"
      ~expected:(response ~tag:0x31 Write_word Complete)
      exchange.response;
    expect_offered_once
      t
      exchange
      (Load_write { address = 0x42; data = 0xa1b2 })
      ~accepted:true;
    ignore
      (Scoreboard.offer
         board
         ~deselected:request_deselected
         (Load_write { address = 0x42; data = 0xa1b2 })
         ~accepted:true
       : int))
;;

let%test_unit "asymmetric and slower whole-cycle host timing keeps the same offer timing" =
  (* Contract-faithful. These are whole-cycle 4/5, 5/4, and slower hosts inside the P3.5
     envelope. The peer's all-phase and 3/3 or 1/1 sweeps are asynchronous and stay
     RTL-only.
  *)
  let slow =
    { Timing.clock_low = 9
    ; clock_high = 13
    ; select_lead = 7
    ; select_trail = 6
    ; deselect_gap = 11
    }
  in
  List.iter
    [ "4/5", { Timing.envelope with clock_high = 5 }
    ; "5/4", { Timing.envelope with clock_low = 5 }
    ; "slow", slow
    ]
    ~f:(fun (name, timing) ->
      Scoreboard.run ~timing ~scenario:("host timing " ^ name) (fun t board ->
        expect_info_works ~board t ~tag:0x10 ("INFO at " ^ name);
        let exchange =
          transact ~board t ~tag:0x11 (Write_word { address = 1; word = 0x0203 })
        in
        expect_response
          t
          ("WRITE at " ^ name)
          ~expected:(response ~tag:0x11 Write_word Complete)
          exchange.response;
        expect_offered_once
          t
          exchange
          (Load_write { address = 1; data = 0x0203 })
          ~accepted:true;
        ignore
          (Scoreboard.offer
             board
             ~deselected:exchange.request_deselected
             (Load_write { address = 1; data = 0x0203 })
             ~accepted:true
           : int);
        expect_int
          t
          ("WRITE at " ^ name ^ ": LRDY one cycle after the offer")
          ~expected:
            (exchange.request_deselected
             + Latency.offer_after_deselect
             + Latency.ready_after_offer)
          exchange.ready))
;;

let%test_unit "a selected response may pause for a long finite time and resume" =
  (* Contract-faithful. The pause is inside the payload, once after a fall with LCLK low
     and once after a sample with LCLK high.
  *)
  Scoreboard.run ~scenario:"response pause" (fun t board ->
    let status =
      { Status.halted_idle with image_valid = 1; image_length = 7; pc = 0x1234 }
    in
    let expected : Wire.Status.t =
      { flags = [ Enabled; Halted; Engines_idle; Image_valid ]
      ; image_length = 7
      ; words_written = 0
      ; words_verified = 0
      ; pc = 0x1234
      ; fault_kind = No_fault
      ; phase = Halted
      }
    in
    set_status t status;
    List.iteri [ false; true ] ~f:(fun index clock_high ->
      let tag = 0x20 + index in
      let pause = { Pause.after_bits = 77; cycles = 10_000; clock_high } in
      let exchange = transact ~board t ~tag ~pause Status in
      expect_response
        t
        (sprintf "STATUS paused with LCLK %s" (if clock_high then "high" else "low"))
        ~expected:(response ~tag Status ~payload:(Status expected) Complete)
        exchange.response))
;;

let%test_unit "an abandoned partial read replays from byte zero without re-offering" =
  (* Contract-faithful. RUN is the side-effecting command the peer uses for replay. The
     scoreboard expects the abandoned read as the driver reported it, then the commit.
  *)
  Scoreboard.run ~scenario:"partial read replay" (fun t board ->
    let driver = Fixture.driver t in
    set_status t { Status.halted_idle with image_valid = 1 };
    let frame = Item.encode ~tag:0x75 Run in
    let started = t.cycle in
    let request_deselected = Driver.send_frame driver frame in
    Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
    let ready = Driver.wait_ready driver ~since:request_deselected in
    let prefix, deselected = read_prefix ~board t ~bits:24 in
    Fixture.expect_retained t ~deselected ~cycles:200;
    let exchange =
      receive
        ~board
        t
        ~started
        ~request_deselected
        ~expected:(Wire.Request.correlation ~tag:0x75 Run)
    in
    expect_response
      t
      "replayed RUN"
      ~expected:(response ~tag:0x75 Run Complete)
      exchange.response;
    Fixture.check
      t
      ~phase:Host_sample
      "the abandoned read saw the first three bytes of the same frame"
      [%sexp_of: string]
      String.equal
      ~expected:(Item.hex (String.prefix exchange.bytes 3))
      (Item.hex prefix);
    expect_int
      t
      "LRDY rose once, before the abandoned read"
      ~expected:ready
      exchange.ready;
    expect_offered_once t exchange Run ~accepted:true;
    ignore
      (Scoreboard.offer board ~deselected:request_deselected Run ~accepted:true : int);
    expect_quiet t 200 "RUN is not offered again after replay and commit")
;;

let%test_unit "final-bit validation rejection retains the response; a later read commits" =
  (* Contract-faithful. As in the peer, the host rejects a frame it has received in full:
     it deselects with the final LCLK still high, so the final fall is absent. It rejects
     twice before committing.
  *)
  Scoreboard.run ~scenario:"reject then commit" (fun t board ->
    let driver = Fixture.driver t in
    set_status t { Status.halted_idle with image_valid = 1 };
    let expected = Wire.Request.correlation ~tag:0x76 Run in
    let frame = Item.encode ~tag:0x76 Run in
    let started = t.cycle in
    let request_deselected = Driver.send_frame driver frame in
    Scoreboard.request board ~selected:started ~deselected:request_deselected frame;
    ignore (Driver.wait_ready driver ~since:request_deselected : int);
    let reject () =
      let selected = t.cycle in
      let read = Driver.read_response driver ~expected ~decide:(fun _ -> Replay) () in
      Scoreboard.read board ~selected read;
      Fixture.check
        t
        ~phase:Host_sample
        "the rejected frame was complete and valid; the rejection is the host's"
        [%sexp_of: (Wire.Response.t, Wire.Codec.Response.Decode_error.t) Result.t]
        [%equal: (Wire.Response.t, Wire.Codec.Response.Decode_error.t) Result.t]
        ~expected:(Ok (response ~tag:0x76 Run Complete))
        read.decoded;
      Fixture.expect_retained t ~deselected:read.deselected ~cycles:200;
      read.bytes
    in
    let first = reject () in
    let second = reject () in
    let rejected = [ first; second ] in
    let exchange = receive ~board t ~started ~request_deselected ~expected in
    Fixture.check
      t
      ~phase:Host_sample
      "every read of the retained response returns the same frame"
      [%sexp_of: string list]
      [%equal: string list]
      ~expected:[ Item.hex exchange.bytes; Item.hex exchange.bytes ]
      (List.map rejected ~f:Item.hex);
    expect_offered_once t exchange Run ~accepted:true;
    ignore
      (Scoreboard.offer board ~deselected:request_deselected Run ~accepted:true : int);
    expect_quiet t 200 "RUN is offered once across two rejections and a commit")
;;

let%test_unit "a response selection arms only after four deselected cycles and with LRDY \
               high"
  =
  (* Characterization of the unsplit loader, fixed for HL4b. Each host here breaks the
     P3.5 envelope on purpose, by selecting too soon, to find the device-side boundary. A
     selection LSEL_N-low in cycle n is seen in cycle n + 2 and arms only if the loader
     has counted four deselected cycles and LRDY is high in that cycle. An armed read
     returns magic [0x5a] as its first byte; an ignored one returns zeros. Either way the
     retained response is then read in full.
  *)
  let first_byte t = fst (Driver.read_prefix (Fixture.driver t) ~bits:8) in
  List.iter
    [ 3, "\x00"; 4, "\x5a" ]
    ~f:(fun (gap, expected) ->
      Fixture.run ~scenario:(sprintf "INFO read after a %d-cycle gap" gap) (fun t ->
        let driver = Fixture.driver t in
        let started = t.cycle in
        Driver.begin_frame driver;
        Driver.send driver (Item.encode ~tag:0x51 Info);
        let request_deselected = Driver.end_frame driver in
        Fixture.hold t gap;
        Fixture.check
          t
          ~phase:Host_sample
          (sprintf "first response byte after a %d-cycle deselected gap" gap)
          [%sexp_of: string]
          String.equal
          ~expected:(Item.hex expected)
          (Item.hex (first_byte t));
        let exchange =
          receive
            t
            ~started
            ~request_deselected
            ~expected:(Wire.Request.correlation ~tag:0x51 Info)
        in
        expect_response
          t
          "INFO after the probe"
          ~expected:(response ~tag:0x51 Info ~payload:info_payload Complete)
          exchange.response));
  (* Robustness probe: a READ response delayed by 20 cycles makes the LRDY rise late
     enough that only the LRDY condition decides.
  *)
  let delay = 20 in
  List.iter
    [ 3, "\x00"; 2, "\x5a" ]
    ~f:(fun (early, expected) ->
      Fixture.run
        ~scenario:(sprintf "READ selected %d cycles before LRDY" early)
        (fun t ->
           let driver = Fixture.driver t in
           (Fixture.responder t).readback_completion <- Delayed delay;
           (Fixture.responder t).memory.(4) <- 0x4444;
           let started = t.cycle in
           Driver.begin_frame driver;
           Driver.send driver (Item.encode ~tag:0x52 (Read_word { address = 4 }));
           let request_deselected = Driver.end_frame driver in
           let ready =
             request_deselected
             + Latency.offer_after_deselect
             + Latency.readback_after_offer
             + delay
             + Latency.ready_after_completion
           in
           Fixture.hold t (ready - early - t.cycle);
           Fixture.check
             t
             ~phase:Host_sample
             (sprintf "first response byte, selected %d cycles before LRDY" early)
             [%sexp_of: string]
             String.equal
             ~expected:(Item.hex expected)
             (Item.hex (first_byte t));
           let exchange =
             receive
               t
               ~started
               ~request_deselected
               ~expected:(Wire.Request.correlation ~tag:0x52 (Read_word { address = 4 }))
           in
           expect_int
             t
             "LRDY rose where the delayed response put it"
             ~expected:ready
             exchange.ready;
           expect_response
             t
             "READ after the probe"
             ~expected:(response ~tag:0x52 Read_word ~payload:(Word 0x4444) Complete)
             exchange.response))
;;
