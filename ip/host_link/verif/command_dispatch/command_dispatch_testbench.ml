(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "command_dispatch_testbench.ml" *)
(* HL4c focused Cyclesim testbench for [Command_dispatch].

   The dispatcher is driven only through its public ports: [Frame_rx]'s handoff (the
   one-cycle [frame_end_i] with its validation result, echo flag, and retained fields) and
   the Control_port agent (ip/emulator_core/verif/control_port/), whose responder,
   [t.stub], drives the [Control_port] decision and status records. Every observation is a
   public output: the offered [Control_port.Request], [busy_o], and the published response
   frame. The agent's passive monitor records the offers that crossed the port. Expected
   offers, operands, responses, and cycles are written by hand in the tests from the P3.5
   record, control_port.ml, and docs/host_link_hl4b3_record.md; none is computed from the
   dispatcher. [Wire.Codec.Request.encode] builds legal handoffs and
   [Wire.Codec.Response.decode] reads published frames with the software CRC, which shares
   nothing with the hardware CRC.

   Scheduling contract:

   1. Time. The unit is one system clock cycle. Cycle n is the interval before edge n.
      Inputs set before [cycle] runs cycle n are applied for the whole of cycle n and
      sampled at edge n. [cycle] is the only function that advances the simulator; the
      stub runs inside it.
   2. Levels (reset, enable, the handoff's result, echo flag, and fields, and the stub's
      status) keep their value until a test changes them. [frame_end_i] is an event: it
      lasts one cycle and [cycle] clears it after the edge.
   3. Within a cycle: apply the inputs, the stub's status, and the stub's registered
      READBACK response with every decision low; settle; read the offer (more than one
      valid is a failure); apply the stub's combinational decision; settle again and check
      that the offer did not change; pass the Control_port records to the agent's monitor;
      take the pre-edge sample (the observation for cycle n); clock the edge; take the
      post-edge sample; do the stub's post-edge work.
   4. [busy_o] is a function of the dispatcher's registers, so its post-edge sample of
      edge n must equal the pre-edge sample of cycle n+1; [cycle] checks this every cycle.
      The offer and the publication are combinational in the handoff, decision, and status
      inputs by design.
   5. Every wait has a finite cycle budget. An exhausted budget or a failed check raises
      [Dispatch_failure] with the scenario, cycle, sampling phase, what was checked, the
      expected and actual values, and the inputs and outputs of recent cycles.

   Contract-faithful stimulus follows what the composed loader and the real core present:
   a handoff only while the dispatcher is idle, with the retained fields stable from the
   handoff until the response is published, and core behavior as the responder
   ([Control_port_agent.Responder]) describes. Anything else is a labelled robustness
   probe. A dispatcher test establishes nothing about the core's own arbitration, RAM
   contents, or cleanup timing.
*)

open! Core
open! Hardcaml
open! Electrum_core
open! Electrum_host_link
module Wire = Host_link_protocol
module Sim = Cyclesim.With_interface (Command_dispatch.I) (Command_dispatch.O)
module Control_port_agent = Electrum_control_port_agent

let hex bytes =
  String.to_list bytes
  |> List.map ~f:(fun byte -> sprintf "%02x" (Char.to_int byte))
  |> String.concat ~sep:" "
;;

(* Cycle latencies at this boundary, written from the recorded timing contract. [h] is the
   handoff cycle ([frame_end_i] high), which is s + 2 in the HL4a convention.
*)
module Latency = struct
  (* A framing error is published in the handoff cycle itself (stored at edge h). *)
  let framing_error = 0

  (* A valid frame arms dispatch at edge h and is offered in h + 1. *)
  let offer_after_handoff = 1

  (* An immediate response is published in the offer cycle (stored at edge h + 1). *)
  let immediate_after_handoff = 1

  (* Contract item 5: a READBACK accepted at edge E has its response valid in the cycle
     between E+1 and E+2, which is offer + 2.
  *)
  let readback_after_offer = 2

  (* Contract item 6: cleanup is visible in the first cycle after the accepting edge. *)
  let abort_clean_after_offer = 1
end

(* Decoded offers come from the Control_port agent's [Item]. *)
module Request = Control_port_agent.Item.Request

(* The whole request record as integers, for exact operand checks. *)
module Port = struct
  type t = int Control_port.Request.t

  let sexp_of_t (t : t) = Control_port.Request.sexp_of_t Int.sexp_of_t t
  let equal = Control_port.Request.equal Int.equal
  let idle : t = Control_port.Request.map Control_port.Request.port_widths ~f:(fun _ -> 0)
end

(* Core status from the Control_port agent's [Item], with this suite's one-line summary
   for the transcript.
*)
module Status = struct
  include Control_port_agent.Item.Status

  (* Nonzero fields only, as [name=hex] joined by commas. *)
  let summary (t : t) =
    summary t
    |> List.map ~f:(fun (name, value) -> sprintf "%s=%x" name value)
    |> String.concat ~sep:","
  ;;
end

(* What [Frame_rx] presents: the validation result (a [Wire.Result_code] as its byte), the
   echo flag, and the retained fields.
*)
module Handoff = struct
  type t =
    { result : int
    ; echo_valid : bool
    ; tag : int
    ; command : int
    ; payload_length : int
    ; payload : int
    }
  [@@deriving sexp_of, equal]

  (* What [Frame_rx] presents after reset, disable, or a start: [Incomplete], no echo, and
     cleared fields.
  *)
  let cleared =
    { result = Wire.Result_code.to_int Incomplete
    ; echo_valid = false
    ; tag = 0
    ; command = 0
    ; payload_length = 0
    ; payload = 0
    }
  ;;

  (* A complete frame as [Frame_rx] hands it off: [Complete], echo, and the positional
     payload register, which holds bytes 6 to 9 little-endian and so includes the CRC byte
     after a payload shorter than four (docs/host_link_hl4b2_record.md).
  *)
  let of_frame bytes =
    let byte index = Char.to_int bytes.[index] in
    let last = Int.min (String.length bytes - 1) 9 in
    let payload =
      List.range 6 (last + 1)
      |> List.fold_right ~init:0 ~f:(fun index acc -> (acc lsl 8) lor byte index)
    in
    { result = Wire.Result_code.to_int Complete
    ; echo_valid = true
    ; tag = byte 2
    ; command = byte 3
    ; payload_length = byte 4 lor (byte 5 lsl 8)
    ; payload
    }
  ;;

  let encode ~tag request =
    Wire.Codec.Request.encode ~tag request |> Result.ok |> Option.value_exn
  ;;

  let request ~tag request = of_frame (encode ~tag request)

  (* A complete frame with raw header values the codec will not build: an unknown command,
     a wrong fixed length. [payload] is the positional register value.
  *)
  let raw ~tag ~command ~payload_length ~payload =
    { result = Wire.Result_code.to_int Complete
    ; echo_valid = true
    ; tag
    ; command
    ; payload_length
    ; payload
    }
  ;;

  (* A framing error with the fields [Frame_rx] retained. *)
  let error ?(echo_valid = true) ?(payload_length = 0) ?(payload = 0) result ~tag ~command
    =
    { result = Wire.Result_code.to_int result
    ; echo_valid
    ; tag
    ; command
    ; payload_length
    ; payload
    }
  ;;

  let summary t =
    sprintf
      "result=%02x echo=%d tag=%02x command=%02x length=%04x payload=%08x"
      t.result
      (if t.echo_valid then 1 else 0)
      t.tag
      t.command
      t.payload_length
      t.payload
  ;;
end

(* The dispatch suite's name for the Control_port agent's responder
   (ip/emulator_core/verif/control_port/), kept as a shim so the spelling
   ([t.stub.accept], [t.stub.memory.(i)], [t.stub.read_match], [t.stub.rejected],
   [Core_stub.Offer.t], [Core_stub.inject_readback_response], ...) is unchanged. The
   responder's header lists its contract-faithful behavior and its robustness probes, each
   labelled where a test uses it. This suite uses the [Independent] injection policy: an
   injected pulse never makes a READBACK outstanding, so it cannot cause a refusal.
*)
module Core_stub = struct
  module Completion = Control_port_agent.Item.Completion
  module Offer = Control_port_agent.Item.Offer
  module Response = Control_port_agent.Item.Response

  type t = Control_port_agent.Responder.t

  let inject_readback_response = Control_port_agent.Responder.inject_readback_response
end

(* The inputs applied for one cycle, other than the stub's. *)
module Inputs = struct
  type t =
    { reset : bool
    ; enable : bool
    ; frame_end : bool
    ; handoff : Handoff.t
    }
  [@@deriving sexp_of]

  let summary t =
    let bit b = if b then 1 else 0 in
    sprintf
      "rst=%d en=%d%s %s"
      (bit t.reset)
      (bit t.enable)
      (if t.frame_end then " FRAME_END" else "")
      (Handoff.summary t.handoff)
  ;;
end

(* One pre-edge sample of every output, with the stub's view of that cycle. *)
module Sample = struct
  type t =
    { request : Port.t
    ; busy : bool
    ; publish : bool
    ; frame : string (* every byte of [response_frame_o] *)
    ; length : int
    ; accepted : bool option (* the stub's decision on the offer, if any *)
    ; readback_response : bool
    ; status : string
    }
  [@@deriving sexp_of]

  (* The bytes the frame declares; the rest is padding. *)
  let published t = String.prefix t.frame t.length

  let summary t =
    let offer =
      match Request.of_port t.request, t.accepted with
      | [ request ], Some accepted ->
        sprintf
          " offer=%s%s"
          (Sexp.to_string [%sexp (request : Request.t)])
          (if accepted then "" else " refused")
      | _ -> ""
    in
    sprintf
      "%s%s%s%s status=%s"
      (if t.busy then "busy" else "idle")
      offer
      (if t.readback_response then " readback_response" else "")
      (if t.publish then " PUBLISH " ^ hex (published t) else "")
      t.status
  ;;
end

module Phase = struct
  type t =
    | Settle (* between the two settles of a cycle *)
    | Pre_edge (* the observation of a cycle, before its edge *)
    | Post_run (* a check made by the test between cycles *)
  [@@deriving sexp_of]
end

type t =
  { scenario : string
  ; sim : Sim.t
  ; stub : Core_stub.t (* the Control_port agent's responder *)
  ; core : Control_port_agent.Agent.t
  ; mutable inputs : Inputs.t (* applied to the next cycle *)
  ; mutable cycle : int (* the next cycle to run *)
  ; mutable settled_busy : bool option (* post-edge [busy_o] of the last edge *)
  ; applied : Inputs.t Queue.t (* index = cycle *)
  ; observed : Sample.t Queue.t (* pre-edge samples; index = cycle *)
  ; transcript_cycles : int
  }

exception
  Dispatch_failure of
    { scenario : string
    ; cycle : int
    ; phase : Phase.t
    ; what : string
    ; expected : Sexp.t option
    ; actual : Sexp.t option
    ; transcript : Sexp.t
    }
[@@deriving sexp_of]

(* The inputs and outputs of the last [transcript_cycles] cycles run. *)
let transcript t =
  let first = Int.max 0 (Queue.length t.observed - t.transcript_cycles) in
  List.range first (Queue.length t.observed)
  |> List.map ~f:(fun cycle ->
    [%sexp
      (cycle : int)
      , (Inputs.summary (Queue.get t.applied cycle) : string)
      , (Sample.summary (Queue.get t.observed cycle) : string)])
  |> Sexp.List
;;

let fail t ?(cycle = t.cycle - 1) ?expected ?actual ~phase what =
  raise
    (Dispatch_failure
       { scenario = t.scenario
       ; cycle
       ; phase
       ; what
       ; expected
       ; actual
       ; transcript = transcript t
       })
;;

let check t ?cycle ~phase what sexp_of equal ~expected actual =
  if not (equal expected actual)
  then fail t ?cycle ~phase what ~expected:(sexp_of expected) ~actual:(sexp_of actual)
;;

let set_int port value = port := Bits.of_int_trunc ~width:(Bits.width !port) value
let set_bool port value = port := Bits.of_bool value

let frame_bytes bits =
  Bits.split_msb ~part_width:8 bits
  |> List.map ~f:(fun byte -> Char.of_int_exn (Bits.to_int_trunc byte))
  |> String.of_char_list
;;

(* Control_port adapter: the port records in one cycle as [int]s, read back from the
   [Command_dispatch] ports pre-edge, so the monitor sees the decision and status the DUT
   saw.
*)
let control_port_sample
  (i : Bits.t ref Command_dispatch.I.t)
  (before : Bits.t ref Command_dispatch.O.t)
  : Control_port_agent.Monitor.Sample.t
  =
  let value port = Bits.to_int_trunc !port in
  { request = Control_port.Request.map before.control_request_o ~f:value
  ; decision = Control_port.Decision.map i.control_decision_i ~f:value
  ; status = Control_port.Status.map i.control_status_i ~f:value
  }
;;

(* The single owner of simulator advancement; see items 1 to 4 of the contract. *)
let cycle t =
  let sim = t.sim in
  let i = Cyclesim.inputs sim in
  let before = Cyclesim.outputs ~clock_edge:Before sim in
  let after = Cyclesim.outputs ~clock_edge:After sim in
  let stub = t.stub in
  let inputs = t.inputs in
  let h = inputs.handoff in
  set_bool i.reset_i inputs.reset;
  set_bool i.enable_i inputs.enable;
  set_bool i.frame_end_i inputs.frame_end;
  set_int i.result_i h.result;
  set_bool i.echo_valid_i h.echo_valid;
  set_int i.tag_i h.tag;
  set_int i.command_i h.command;
  set_int i.payload_length_i h.payload_length;
  set_int i.payload_i h.payload;
  Control_port.Status.iter2 i.control_status_i stub.status ~f:set_int;
  let drive_decision offer =
    Control_port.Decision.iter2
      i.control_decision_i
      (Control_port_agent.Responder.decision stub ~cycle:t.cycle ~offer)
      ~f:set_int
  in
  drive_decision None;
  Cyclesim.cycle_check sim;
  Cyclesim.cycle_before_clock_edge sim;
  let request () =
    Control_port.Request.map before.control_request_o ~f:(fun r -> Bits.to_int_trunc !r)
  in
  let offered = request () in
  let offer =
    match Request.of_port offered with
    | [] -> None
    | [ request ] ->
      Some
        ( request
        , Control_port_agent.Responder.decide
            stub
            ~reset:inputs.reset
            ~enable:inputs.enable
            request )
    | requests ->
      fail
        t
        ~cycle:t.cycle
        ~phase:Settle
        "at most one request is offered per cycle"
        ~actual:[%sexp (requests : Request.t list)]
  in
  drive_decision offer;
  Cyclesim.cycle_before_clock_edge sim;
  check
    t
    ~cycle:t.cycle
    ~phase:Settle
    "the offered request does not depend on the decision in the same cycle"
    [%sexp_of: Port.t]
    Port.equal
    ~expected:offered
    (request ());
  Control_port_agent.Agent.sample t.core ~cycle:t.cycle (control_port_sample i before);
  let sample =
    { Sample.request = offered
    ; busy = Bits.to_bool !(before.busy_o)
    ; publish = Bits.to_bool !(before.response_publish_o)
    ; frame = frame_bytes !(before.response_frame_o)
    ; length = Bits.to_int_trunc !(before.response_length_o)
    ; accepted = Option.map offer ~f:snd
    ; readback_response =
        Option.is_some (Control_port_agent.Responder.response stub ~cycle:t.cycle)
    ; status = Status.summary stub.status
    }
  in
  Queue.enqueue t.applied inputs;
  Queue.enqueue t.observed sample;
  Option.iter t.settled_busy ~f:(fun settled ->
    check
      t
      ~cycle:t.cycle
      ~phase:Pre_edge
      "busy_o after the new inputs settle equals the last edge's post-edge busy_o"
      [%sexp_of: bool]
      [%equal: bool]
      ~expected:settled
      sample.busy);
  Cyclesim.cycle_at_clock_edge sim;
  Cyclesim.cycle_after_clock_edge sim;
  t.settled_busy <- Some (Bits.to_bool !(after.busy_o));
  Control_port_agent.Responder.edge
    stub
    ~cycle:t.cycle
    ~reset:inputs.reset
    ~enable:inputs.enable
    ~offer;
  t.inputs <- { inputs with frame_end = false };
  t.cycle <- t.cycle + 1
;;

let run t cycles =
  for _ = 1 to cycles do
    cycle t
  done
;;

(* Set levels for the next cycle onward; unnamed levels keep their value. *)
let set ?reset ?enable ?handoff t =
  let keep value current = Option.value value ~default:current in
  t.inputs
  <- { t.inputs with
       reset = keep reset t.inputs.reset
     ; enable = keep enable t.inputs.enable
     ; handoff = keep handoff t.inputs.handoff
     }
;;

let set_status t status = t.stub.status <- status

(* Reset is high in cycles 0 and 1 with everything idle; [create] returns before cycle 2,
   the first cycle out of reset.
*)
let reset_cycles = 2

let create ?(transcript_cycles = 12) scenario =
  let sim = Sim.create (Command_dispatch.create (Scope.create ~flatten_design:true ())) in
  let core =
    Control_port_agent.Agent.create
      (Control_port_agent.Config.responder ~injection:Independent)
  in
  let t =
    { scenario
    ; sim
    ; stub = Control_port_agent.Agent.responder_exn core
    ; core
    ; inputs =
        { reset = true; enable = true; frame_end = false; handoff = Handoff.cleared }
    ; cycle = 0
    ; settled_busy = None
    ; applied = Queue.create ()
    ; observed = Queue.create ()
    ; transcript_cycles
    }
  in
  run t reset_cycles;
  set t ~reset:false;
  t
;;

(* The pre-edge observation of a cycle that has run. *)
let observed t cycle =
  if cycle < 0 || cycle >= t.cycle
  then
    fail
      t
      ~phase:Post_run
      "observation of a cycle that has run"
      ~actual:[%sexp { requested = (cycle : int); cycles_run = (t.cycle : int) }];
  Queue.get t.observed cycle
;;

(* Present [handoff] with [frame_end_i] for one cycle, run it, and return its cycle. The
   fields stay presented afterwards, as [Frame_rx]'s retained registers do.
*)
let handoff t handoff =
  let at = t.cycle in
  set t ~handoff;
  t.inputs <- { t.inputs with frame_end = true };
  cycle t;
  at
;;

(* Offers in [since, now) as the Control_port monitor observed them, oldest first. *)
let offers ?(since = 0) t =
  Queue.to_list (Control_port_agent.Agent.observed t.core)
  |> List.filter_map ~f:Control_port_agent.Item.Observed.offer
  |> List.filter ~f:(fun (offer : Core_stub.Offer.t) -> offer.cycle >= since)
;;

let expect_offers t ~since what expected =
  check
    t
    ~phase:Post_run
    (what ^ ": every offer since cycle " ^ Int.to_string since)
    [%sexp_of: Core_stub.Offer.t list]
    [%equal: Core_stub.Offer.t list]
    ~expected
    (offers ~since t)
;;

(* The full request record, operands included, in a cycle that has run. *)
let expect_request t ~cycle what expected =
  check
    t
    ~cycle
    ~phase:Pre_edge
    (what ^ ": the whole Control_port.Request record")
    [%sexp_of: Port.t]
    Port.equal
    ~expected
    (observed t cycle).request
;;

(* Cycles in [from, until) in which a sampled flag was high. *)
let high_cycles t ~from ~until ~f =
  List.range from until |> List.filter ~f:(fun cycle -> f (observed t cycle))
;;

let expect_busy t ?(until = t.cycle) ~from what expected =
  check
    t
    ~phase:Post_run
    (sprintf "%s: busy_o high in cycles [%d, %d)" what from until)
    [%sexp_of: int list]
    [%equal: int list]
    ~expected
    (high_cycles t ~from ~until ~f:(fun s -> s.busy))
;;

(* A published frame, decoded by [Wire]. A frame whose padding past its declared length is
   not zero is reported as such.
*)
module Published = struct
  type t =
    | Response of Wire.Response.t
    | Undecodable of
        { bytes : string
        ; error : Wire.Codec.Response.Decode_error.t
        }
    | Nonzero_padding of { frame : string }
  [@@deriving sexp_of, equal]

  let of_sample (s : Sample.t) =
    let padding = String.drop_prefix s.frame s.length in
    if not (String.for_all padding ~f:(Char.equal '\x00'))
    then Nonzero_padding { frame = hex s.frame }
    else (
      match Wire.Codec.Response.decode (Sample.published s) with
      | Ok response -> Response response
      | Error error -> Undecodable { bytes = hex (Sample.published s); error })
  ;;
end

let publications t ~from ~until =
  List.range from until
  |> List.filter_map ~f:(fun cycle ->
    let s = observed t cycle in
    Option.some_if s.publish (cycle, Published.of_sample s))
;;

(* Exactly these publications, at exactly these cycles, in [from, until). *)
let expect_publications t ?(until = t.cycle) ~from what expected =
  check
    t
    ~phase:Post_run
    (sprintf "%s: publications in cycles [%d, %d)" what from until)
    [%sexp_of: (int * Published.t) list]
    [%equal: (int * Published.t) list]
    ~expected:
      (List.map expected ~f:(fun (cycle, response) -> cycle, Published.Response response))
    (publications t ~from ~until)
;;

(* The raw published bytes in [cycle], for checks the decoder cannot express. *)
let expect_published_bytes t ~cycle what expected =
  let s = observed t cycle in
  check
    t
    ~cycle
    ~phase:Pre_edge
    (what ^ ": published frame bytes")
    [%sexp_of: bool * string]
    [%equal: bool * string]
    ~expected:(true, expected)
    (s.publish, hex (Sample.published s))
;;

let response ~tag command ?(payload = Wire.Response.Payload.Empty) result =
  { Wire.Response.tag; command = Wire.Command.to_int command; result; payload }
;;

(* A response to a raw command byte. *)
let raw_response ~tag ~command ?(payload = Wire.Response.Payload.Empty) result =
  { Wire.Response.tag; command; result; payload }
;;

(* Run until [f] holds for a cycle's pre-edge sample and return that cycle. Raises after
   [budget] cycles.
*)
let wait_for ?(budget = 100) t what ~f =
  let rec loop spent =
    if spent >= budget
    then
      fail
        t
        ~phase:Pre_edge
        ("wait for " ^ what)
        ~actual:[%sexp { budget_exhausted = (budget : int) }]
    else (
      cycle t;
      let seen = t.cycle - 1 in
      if f (observed t seen) then seen else loop (spent + 1))
  in
  loop 0
;;

(* No offer, publication, or busy cycle in [from, until). *)
let expect_quiet t ?(until = t.cycle) ~from what =
  expect_offers t ~since:from what [];
  expect_publications t ~until ~from what [];
  expect_busy t ~until ~from what []
;;

(* [Some failure] when [f] raises [Dispatch_failure]. Used by the negative checks. *)
let failure_of f =
  match f () with
  | (_ : unit) -> None
  | exception (Dispatch_failure _ as failure) ->
    (* Keep the diagnostic identity stable across the ownership move. *)
    (match [%sexp (failure : exn)] with
     | Sexp.List (_ :: fields) ->
       Some
         (Sexp.List
            (Sexp.Atom
               "test/host_link/command_dispatch/command_dispatch_testbench.ml.Dispatch_failure"
             :: fields))
     | sexp -> Some sexp)
;;
