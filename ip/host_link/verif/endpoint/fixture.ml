(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "fixture.ml" *)
(* The Host_link endpoint fixture: the real composed [Host_link] in Cyclesim, an active
   serial-host agent on its three serial pins, and a Control_port agent in responder mode
   behind its [Control_port], under one scheduler.

   The fixture owns the environment: the simulator, the scheduler ([cycle], [hold]), reset
   and enable, both agents with their pin and port adapters and the serial driver's hooks,
   the transcript, and failure reporting ([fail], [check], [Harness_failure]). A test owns
   a fresh instance through [run], which builds everything, runs the scenario, and
   finishes the instance. Scenario intent, expected values, and composite checks belong to
   the test; [Scoreboard] is the opt-in end-of-scenario check over both monitors. The
   endpoint suite in this directory is written against the fixture directly; the frozen
   HL4a archive reaches it through its compatibility shim
   test/host_link/archived/hl4a/hardware_loader_testbench.ml (docs/serial_host_pilot.md,
   SP4 and SP5).

   This is synchronous digital evidence. Every pin change happens at a cycle boundary, so
   the fixture establishes nothing about asynchronous phase, metastability, board timing,
   or physical setup/hold margins. The independent emitted-RTL peer
   tinytapeout/test/p3_loader_tb.v and physical evidence own those. The Control_port
   monitor's offers and responses are evidence about loader dispatch only, never about RAM
   writes, core cleanup, or pins.

   Scheduling contract (docs/host_link_hl4a_record.md records the same contract):

   1. Time. The unit is one system clock cycle. Cycle n is the interval before edge n. A
      reset, enable, pin, or status value set for cycle n is applied before that cycle's
      settle and sampled at edge n. [cycle] is the only function that advances the
      simulator. Host steps call it in sequence, through the serial driver's [step] hook,
      and the responder runs inside it; neither advances time on its own.
   2. Within a cycle: apply reset/enable, the serial pins, the responder's status, and its
      registered READBACK response; settle; read the offered request; apply the
      responder's combinational decision; settle again and check that the request did not
      change; pass the Control_port records to that agent's monitor and log the offer and
      response it observed; take the pre-edge observation (LRDY, LDO, busy) and pass the
      serial pins to the serial agent's monitor; clock the edge; then do the responder's
      post-edge work (accepted side effects, completions, cancellation).
   3. Host pins follow the P3.5 envelope in whole cycles (see [Timing]). The host samples
      LDO in the cycle in which it raises LCLK, before that cycle's edge. This matches the
      peer's sample 1 ps after its rise.
   4. A response is read as 7 header bytes, then the length they declare, up to the final
      bit. The host samples that bit on its rise and validates the frame while LCLK stays
      high. Commit then supplies the final fall, waits [select_trail] and raises LSEL_N.
      Replay raises LSEL_N with LCLK high, and lowers LCLK [clock_high] cycles later.
   5. Every wait has a finite cycle budget. An exhausted budget or a failed check raises
      [Harness_failure] with the scenario, cycle, sampling phase, what was checked, the
      expected and actual values, and a bounded transcript of recent public-boundary
      events.
*)

open! Core
open! Hardcaml
open! Electrum_mechanisms
open! Electrum_core
open! Electrum_host_link
module Wire = Host_link_protocol
module Sim = Cyclesim.With_interface (Host_link.I) (Host_link.O)
module Serial_host = Electrum_serial_host_agent
module Control_port_agent = Electrum_control_port_agent
module Timing = Serial_host.Config.Timing
module Outcome = Serial_host.Item.Outcome
module Request = Control_port_agent.Item.Request
module Status = Control_port_agent.Item.Status
module Offer = Control_port_agent.Item.Offer
module Response = Control_port_agent.Item.Response

module Phase = struct
  type t =
    | Settle (* between the two settles of a cycle *)
    | Pre_edge
    | Host_sample (* the host's LDO sample, pre-edge in its LCLK rise cycle *)
    | Post_run (* a check made by the test between cycles *)
  [@@deriving sexp_of]
end

(* Public-boundary events, logged in the cycle they are driven or observed. *)
module Event = struct
  type t =
    | Reset of bool
    | Enable of bool
    | Select of bool (* host drives LSEL_N low when true *)
    | Sent of
        { bytes : string
        ; extra_bits : int
        }
    | Offer of
        { request : Request.t
        ; accepted : bool
        }
    | Readback_response of
        { data : int
        ; matches : bool
        }
    | Status of (string * int) list
    | Ready of bool
    | Busy of bool
    | Response_read of
        { bytes : string
        ; outcome : Outcome.t
        }
    | Note of string
  [@@deriving sexp_of]
end

(* The fixture's state. [serial_host] and [control_port] are the two agents; the responder
   is [control_port]'s. [select_n], [clock] and [data] are the host pins the driver last
   set through the adapter, applied by [cycle]. [finished] is set when [run] ends.

   The last two fields exist only for the HL4a shim, whose unedited tests read them as
   record fields, which cannot be computed: [stub] is [control_port]'s responder, and
   [timing] mirrors the serial driver's timing, kept equal by [set_timing]. Nothing in
   this fixture reads either; [responder] and [timing] are the accessors.
*)
type t =
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
  ; mutable ldi_fault : int -> bool (* test-only: invert the applied LDI in cycle n *)
  ; mutable ready : bool (* pre-edge LRDY of the last cycle *)
  ; mutable ldo : bool (* pre-edge LDO of the last cycle *)
  ; mutable busy : bool
  ; mutable ready_changes : (int * bool) list (* newest first *)
  ; mutable last_status : Status.t
  ; transcript : (int * Event.t) Queue.t
  ; transcript_limit : int
  ; mutable omitted : int
  ; mutable finished : bool
  ; stub : Control_port_agent.Responder.t (* HL4a shim only *)
  ; mutable timing : Timing.t (* HL4a shim only *)
  }

let log t ?(cycle = t.cycle) event =
  Queue.enqueue t.transcript (cycle, event);
  while Queue.length t.transcript > t.transcript_limit do
    ignore (Queue.dequeue_exn t.transcript : int * Event.t);
    t.omitted <- t.omitted + 1
  done
;;

let note t message = log t (Note message)

let transcript t =
  let events = Queue.to_list t.transcript in
  if t.omitted = 0
  then [%sexp (events : (int * Event.t) list)]
  else
    [%sexp { earlier_events_omitted = (t.omitted : int); events : (int * Event.t) list }]
;;

(* A failed check, as [Harness_failure] reports it. *)
module Report = struct
  type t =
    { scenario : string
    ; cycle : int
    ; phase : Phase.t
    ; what : string
    ; expected : Sexp.t option
    ; actual : Sexp.t option
    ; transcript : Sexp.t
    }
  [@@deriving sexp_of]
end

exception Harness_failure of Report.t

(* The name a report prints. The HL4a baseline's expect output records the exception under
   the file that first defined it, and the endpoint pilots must print the same reports, so
   the converter is written here with that name instead of derived from this file's path.
   It prints the report's fields exactly as [@@deriving sexp_of] on the original inline
   record did. Renaming it is an expect change, and the owner's decision.
*)
let harness_failure_name = "test/host_link/hardware_loader_testbench.ml.Harness_failure"

let () =
  Sexplib0.Sexp_conv.Exn_converter.add [%extension_constructor Harness_failure] (function
    | Harness_failure report ->
      (match Report.sexp_of_t report with
       | List fields -> List (Atom harness_failure_name :: fields)
       | Atom _ as atom -> atom)
    | _ -> assert false)
;;

let fail t ?(cycle = t.cycle - 1) ?expected ?actual ~phase what =
  raise
    (Harness_failure
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

(* [Some failure] when [f] raises [Harness_failure]. Used by the negative checks. *)
let failure_of f =
  match f () with
  | (_ : unit) -> None
  | exception (Harness_failure _ as failure) -> Some [%sexp (failure : exn)]
;;

let set_int port value = port := Bits.of_int_trunc ~width:(Bits.width !port) value
let set_bool port value = port := Bits.of_bool value

(* Serial-host pin adapter, port side: the logical serial pins in one cycle, as applied to
   and read from the [Host_link] ports pre-edge. Reading the host pins back from the
   inputs means the monitor sees what the DUT saw, including an injected LDI fault.
*)
let serial_pins (i : Bits.t ref Host_link.I.t) (o : Bits.t ref Host_link.O.t)
  : Serial_host.Monitor.Sample.t
  =
  { select_n = Bits.to_bool !(i.serial_select_n_i)
  ; clock = Bits.to_bool !(i.serial_clock_i)
  ; ldi = Bits.to_bool !(i.serial_data_i)
  ; ldo = Bits.to_bool !(o.serial_data_o)
  ; ready = Bits.to_bool !(o.serial_ready_o)
  }
;;

(* Control_port adapter: the port records in one cycle as [int]s, read back from the
   [Host_link] ports pre-edge, so the monitor sees the decision and status the DUT saw.
*)
let control_port_sample (i : Bits.t ref Host_link.I.t) (o : Bits.t ref Host_link.O.t)
  : Control_port_agent.Monitor.Sample.t
  =
  let value port = Bits.to_int_trunc !port in
  { request = Control_port.Request.map o.control_request_o ~f:value
  ; decision = Control_port.Decision.map i.control_decision_i ~f:value
  ; status = Control_port.Status.map i.control_status_i ~f:value
  }
;;

let responder t = Control_port_agent.Agent.responder_exn t.control_port

(* Logs, in the current cycle, the Control_port monitor's items from position [from] on:
   the offer and READBACK response that crossed the port.
*)
let log_port_items t ~from =
  let observed = Control_port_agent.Agent.observed t.control_port in
  for index = from to Queue.length observed - 1 do
    match Queue.get observed index with
    | Offer { request; accepted; cycle = _ } -> log t (Offer { request; accepted })
    | Response { data; matches; cycle = _ } -> log t (Readback_response { data; matches })
  done
;;

(* The single owner of simulator advancement; see item 2 of the contract. *)
let cycle t =
  if t.finished
  then
    raise_s
      [%message
        "the endpoint fixture is used after its scoped run"
          ~scenario:(t.scenario : string)];
  let sim = t.sim in
  let i = Cyclesim.inputs sim in
  let o = Cyclesim.outputs ~clock_edge:Before sim in
  let responder = responder t in
  if not (Control_port.Status.equal Int.equal responder.status t.last_status)
  then (
    log t (Status (Status.summary responder.status));
    t.last_status <- responder.status);
  set_bool i.reset_i t.reset;
  set_bool i.enable_i t.enable;
  set_bool i.serial_select_n_i t.select_n;
  set_bool i.serial_clock_i t.clock;
  set_bool i.serial_data_i (Bool.( <> ) t.data (t.ldi_fault t.cycle));
  Control_port.Status.iter2 i.control_status_i responder.status ~f:set_int;
  let drive_decision offer =
    Control_port.Decision.iter2
      i.control_decision_i
      (Control_port_agent.Responder.decision responder ~cycle:t.cycle ~offer)
      ~f:set_int
  in
  drive_decision None;
  Cyclesim.cycle_check sim;
  Cyclesim.cycle_before_clock_edge sim;
  let request () = Control_port.Request.map o.control_request_o ~f:( ! ) in
  let offered = request () in
  let offer =
    match Request.of_port (Control_port.Request.map offered ~f:Bits.to_int_trunc) with
    | [] -> None
    | [ request ] ->
      Some
        ( request
        , Control_port_agent.Responder.decide
            responder
            ~reset:t.reset
            ~enable:t.enable
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
    [%sexp_of: Bits.t Control_port.Request.t]
    (Control_port.Request.equal Bits.equal)
    ~expected:offered
    (request ());
  let from = Queue.length (Control_port_agent.Agent.observed t.control_port) in
  Control_port_agent.Agent.sample t.control_port ~cycle:t.cycle (control_port_sample i o);
  log_port_items t ~from;
  let ready = Bits.to_bool !(o.serial_ready_o) in
  if Bool.( <> ) ready t.ready
  then (
    t.ready_changes <- (t.cycle, ready) :: t.ready_changes;
    log t (Ready ready));
  let busy = Bits.to_bool !(o.busy_o) in
  if Bool.( <> ) busy t.busy then log t (Busy busy);
  t.ready <- ready;
  t.busy <- busy;
  t.ldo <- Bits.to_bool !(o.serial_data_o);
  Serial_host.Agent.sample t.serial_host ~cycle:t.cycle (serial_pins i o);
  Cyclesim.cycle_at_clock_edge sim;
  Cyclesim.cycle_after_clock_edge sim;
  Control_port_agent.Responder.edge
    responder
    ~cycle:t.cycle
    ~reset:t.reset
    ~enable:t.enable
    ~offer;
  t.cycle <- t.cycle + 1
;;

let hold t cycles =
  for _ = 1 to cycles do
    cycle t
  done
;;

let set_reset t value =
  t.reset <- value;
  log t (Reset value)
;;

let set_enable t value =
  t.enable <- value;
  log t (Enable value)
;;

(* Sampled LRDY changes at or after [since], oldest first. *)
let ready_changes ?(since = 0) t =
  List.rev t.ready_changes |> List.filter ~f:(fun (cycle, _) -> cycle >= since)
;;

(* Serial-host pin adapter and environment hooks, driver side. Host pins land in [t] for
   [cycle] to apply; LDO and the LRDY history are [cycle]'s pre-edge samples. Driver
   events and failures map one to one onto [Event] and [Phase], so transcripts and reports
   keep the HL4a format. [self] is [t] once [create] has built it.
*)
let serial_host_hooks (self : t Set_once.t) =
  let t () = Set_once.get_exn self in
  let phase : Serial_host.Driver.Failure.Kind.t -> Phase.t = function
    | Host_sample -> Host_sample
    | Ready_wait -> Pre_edge
  in
  let pins : Serial_host.Driver.Pins.t =
    { set_select_n = (fun value -> (t ()).select_n <- value)
    ; set_clock = (fun value -> (t ()).clock <- value)
    ; set_data = (fun value -> (t ()).data <- value)
    ; ldo = (fun () -> (t ()).ldo)
    ; ready_changes = (fun ~since -> ready_changes ~since (t ()))
    }
  in
  let env : Serial_host.Driver.Env.t =
    { step = (fun () -> cycle (t ()))
    ; now = (fun () -> (t ()).cycle)
    ; log =
        (fun event ->
          log
            (t ())
            (match event with
             | Select selected -> Select selected
             | Sent { bytes; extra_bits } ->
               Sent { bytes = Serial_host.Item.hex bytes; extra_bits }
             | Response_read { bytes; outcome } ->
               Response_read { bytes = Serial_host.Item.hex bytes; outcome }))
    ; fail =
        (fun { kind; what; expected; actual } ->
          fail (t ()) ~phase:(phase kind) what ~expected ~actual)
    }
  in
  pins, env
;;

(* Pins idle, reset held for four cycles, then four idle cycles. The loader's
   deselected-cycle count therefore already qualifies a response selection. The serial
   agent is active and the Control_port agent a responder with the [Outstanding] injection
   policy (see [Control_port_agent.Config.Injection]), each with its monitor sampled in
   every cycle from the first. [timing] is validated before the simulator is built.

   Prefer [run], which also finishes the instance; [create] remains for the HL4a shim.
*)
let create ?(timing = Timing.envelope) ?(transcript_limit = 48) scenario =
  let self = Set_once.create () in
  let serial_host =
    Serial_host.Agent.create
      ~host:(serial_host_hooks self)
      (Serial_host.Config.active ~timing ())
  in
  let sim = Sim.create (Host_link.create (Scope.create ~flatten_design:true ())) in
  let control_port =
    Control_port_agent.Agent.create
      (Control_port_agent.Config.responder ~injection:Outstanding)
  in
  let stub = Control_port_agent.Agent.responder_exn control_port in
  let t =
    { scenario
    ; sim
    ; serial_host
    ; control_port
    ; cycle = 0
    ; reset = false
    ; enable = true
    ; select_n = true
    ; clock = false
    ; data = false
    ; ldi_fault = Fn.const false
    ; ready = false
    ; ldo = false
    ; busy = false
    ; ready_changes = []
    ; last_status = stub.status
    ; transcript = Queue.create ()
    ; transcript_limit
    ; omitted = 0
    ; finished = false
    ; stub
    ; timing
    }
  in
  Set_once.set_exn self t;
  set_reset t true;
  hold t 4;
  set_reset t false;
  hold t 4;
  t
;;

(* The scoped entry point: a fresh simulator, agents, monitors, responder policy, and
   transcript for [scenario], passed to [f]. The instance is finished when [f] returns or
   raises, and [cycle] on it raises afterwards, so a handle that escapes cannot advance a
   later scenario's time.
*)
let run ?timing ?transcript_limit ~scenario f =
  let t = create ?timing ?transcript_limit scenario in
  Exn.protect ~f:(fun () -> f t) ~finally:(fun () -> t.finished <- true)
;;

let driver t = Serial_host.Agent.driver_exn t.serial_host

(* The host timing has one source, the serial driver. *)
let timing t = Serial_host.Driver.timing (driver t)

let set_timing t timing =
  Serial_host.Driver.set_timing (driver t) timing;
  t.timing <- timing
;;

(* The two monitors' items, oldest first. A checker dequeues what it compares; [offers]
   and [responses] read without dequeuing.
*)
let serial_observed t = Serial_host.Agent.observed t.serial_host
let control_port_observed t = Control_port_agent.Agent.observed t.control_port

(* Offers and delivered READBACK responses as the Control_port monitor observed them,
   oldest first.
*)
let offers ?(since = 0) t =
  Queue.to_list (control_port_observed t)
  |> List.filter_map ~f:Control_port_agent.Item.Observed.offer
  |> List.filter ~f:(fun (offer : Offer.t) -> offer.cycle >= since)
;;

let responses ?(since = 0) t =
  Queue.to_list (control_port_observed t)
  |> List.filter_map ~f:Control_port_agent.Item.Observed.response
  |> List.filter ~f:(fun (response : Response.t) -> response.cycle >= since)
;;

(* Response lifecycle checks on LRDY. *)

(* A committed response clears LRDY [Latency.ready_cleared_after_deselect] cycles after
   the host deselects, and LRDY does not change otherwise in between.
*)
let expect_ready_cleared t ~deselected =
  hold t (Int.max 0 (deselected + Latency.ready_cleared_after_deselect + 1 - t.cycle));
  check
    t
    ~phase:Pre_edge
    ~cycle:(deselected + Latency.ready_cleared_after_deselect)
    "committed response clears LRDY"
    [%sexp_of: (int * bool) list]
    [%equal: (int * bool) list]
    ~expected:[ deselected + Latency.ready_cleared_after_deselect, false ]
    (ready_changes ~since:deselected t)
;;

(* A retained response keeps LRDY high for [cycles] after the host deselects. *)
let expect_retained t ~deselected ~cycles =
  hold t (Int.max 0 (deselected + cycles - t.cycle));
  check
    t
    ~phase:Pre_edge
    (sprintf "retained response keeps LRDY high for %d cycles" cycles)
    [%sexp_of: (int * bool) list * bool]
    [%equal: (int * bool) list * bool]
    ~expected:([], true)
    (ready_changes ~since:deselected t, t.ready)
;;
