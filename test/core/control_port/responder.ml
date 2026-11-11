(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "responder.ml" *)
(* The Control_port responder: a test-only stand-in for [Emulator_core] behind the port,
   answering a producer's offers. It is a reactive (slave) driver, not a RAM or execution
   model: acceptance comes from [accept], READBACK data from [memory], and status from
   [status], all set by the test. It never inspects the producer's refusal or dispatch
   logic, and it records nothing; [Monitor] observes what crossed the port.

   The scheduler calls it inside its cycle phases and it never advances time. In cycle n:

   1. [decision ~offer:None] before the first settle, which drives the registered READBACK
      response visible in n with every offer decision low;
   2. [decide] on the one request offered in n, if any, after that settle;
   3. [decision ~offer] with that request and its acceptance, before the second settle;
   4. [edge] after edge n, for the accepted side effects, completions, and cancellation.

   Contract-faithful behavior, from control_port.ml:

   - decisions are combinational in the offer cycle; with no offer both are low, and a
     refusal is [valid & ~accepted] (item 3);
   - reset or disable refuses every offer and cancels a pending READBACK response and
     ABORT cleanup (item 8);
   - an accepted READBACK has its response valid only in the cycle [readback_latency]
     after the offer (item 5); a second READBACK is refused while it is outstanding; an
     accepted ABORT or LOAD_START cancels it;
   - an accepted ABORT makes [Status.cleaned] visible from the cycle after its edge (item
     6);
   - [readback_response_match] compares the word with the expected operand for VERIFY and
     is low for READ, where it is meaningless.

   Robustness probes, each labelled where a test uses it: [Completion.Delayed] and
   [Never]; [inject_readback_response], an unsolicited pulse whose interaction with
   READBACK is the [Config.Injection] policy; [read_match], which drives the meaningless
   READ match high; [rejected], which drives every rejected signal to a fixed level
   whatever the offer; and an [accept] that refuses STOP or ABORT, which the real core
   accepts whenever enabled and out of reset.
*)

open! Core
open! Hardcaml_protemu
module Completion = Item.Completion
module Request = Item.Request
module Response = Item.Response
module Status = Item.Status

(* Contract item 5: an offer accepted at edge E has its response valid in the cycle
   between E+1 and E+2, two cycles after the offer cycle.
*)
let readback_latency = 2

(* Contract item 6: cleanup completes at the accepting edge, so it is visible from the
   cycle after the offer.
*)
let abort_cleanup_latency = 0

(* Program memory as the responder reports it: one word per address, initially a fixed
   pattern so that distinct addresses read distinct words.
*)
let default_memory () =
  Array.init Program_memory_controller.Config.program_depth ~f:(fun address ->
    address * 0x0101 lxor 0xa55a)
;;

(* The policy fields, set by tests, come first; the rest is the responder's own state.
   [pending_response] is the response of the last accepted READBACK or an [Outstanding]
   injection, and makes a READBACK outstanding; [injected] holds [Independent] injections,
   which never do.
*)
type t =
  { mutable status : Status.t
  ; mutable accept : Request.t -> bool
  ; memory : int array
  ; mutable readback_completion : Completion.t
  ; mutable abort_completion : Completion.t
  ; mutable read_match : bool (* robustness only *)
  ; mutable rejected : bool option (* robustness only *)
  ; injection : Config.Injection.t
  ; mutable pending_response : Response.t option
  ; mutable injected : Response.t list
  ; mutable pending_cleanup : int option (* edge after which cleanup is visible *)
  }

let create ~injection =
  { status = Status.halted_idle
  ; accept = (fun _ -> true)
  ; memory = default_memory ()
  ; readback_completion = Contract
  ; abort_completion = Contract
  ; read_match = false
  ; rejected = None
  ; injection
  ; pending_response = None
  ; injected = []
  ; pending_cleanup = None
  }
;;

(* The registered response visible in [cycle], if any: an accepted READBACK's, else an
   injected one.
*)
let response t ~cycle =
  let at (response : Response.t) = response.cycle = cycle in
  match Option.filter t.pending_response ~f:at with
  | Some response -> Some response
  | None -> List.find t.injected ~f:at
;;

(* Robustness only: a response pulse in [cycle] that no accepted READBACK requested.
   Whether it counts as outstanding is [t.injection]; see [Config.Injection].
*)
let inject_readback_response t ~cycle ~data ~matches =
  let response = { Response.cycle; data; matches } in
  match t.injection with
  | Outstanding -> t.pending_response <- Some response
  | Independent -> t.injected <- response :: t.injected
;;

(* Acceptance of [request], offered in the current cycle under [reset] and [enable]. *)
let decide t ~reset ~enable request =
  let outstanding =
    match request, t.pending_response with
    | (Request.Read _ | Verify _), Some _ -> true
    | _ -> false
  in
  enable && (not reset) && (not outstanding) && t.accept request
;;

(* The decision record for [cycle]: the registered response visible then, and the decision
   on [offer], a request with its acceptance, if any.
*)
let decision t ~cycle ~offer : int Control_port.Decision.t =
  let d = Control_port.Decision.map Control_port.Decision.port_widths ~f:(fun _ -> 0) in
  let d =
    match response t ~cycle with
    | None -> d
    | Some response ->
      { d with
        readback_response_valid = 1
      ; readback_response_data = response.data
      ; readback_response_match = Bool.to_int response.matches
      }
  in
  let d =
    match offer with
    | None -> d
    | Some (request, accepted) ->
      let a = Bool.to_int accepted in
      let r = Bool.to_int (not accepted) in
      (match (request : Request.t) with
       | Load_start _ -> { d with load_start_accepted = a; load_start_rejected = r }
       | Load_write _ -> { d with load_write_accepted = a; load_write_rejected = r }
       | Load_complete ->
         { d with load_complete_accepted = a; load_complete_rejected = r }
       | Read _ | Verify _ -> { d with readback_accepted = a; readback_rejected = r }
       | Run -> { d with run_accepted = a; run_rejected = r }
       | Stop -> { d with stop_accepted = a; stop_rejected = r }
       | Abort -> { d with abort_accepted = a; abort_rejected = r })
  in
  match t.rejected with
  | None -> d
  | Some level ->
    let r = Bool.to_int level in
    { d with
      load_start_rejected = r
    ; load_write_rejected = r
    ; load_complete_rejected = r
    ; readback_rejected = r
    ; run_rejected = r
    ; stop_rejected = r
    ; abort_rejected = r
    }
;;

let schedule completion ~contract =
  match (completion : Completion.t) with
  | Contract -> Some contract
  | Delayed extra -> Some (contract + extra)
  | Never -> None
;;

(* Post-edge work for the edge that ends [cycle]:

   1. a response whose cycle has come expires, delivered or not;
   2. reset or disable cancels the pending response and cleanup;
   3. an accepted READBACK schedules its response, an accepted ABORT cancels the pending
      response and schedules cleanup, and an accepted LOAD_START cancels the pending
      response;
   4. cleanup due at this edge makes [Status.cleaned] visible from the next cycle.
*)
let edge t ~cycle ~reset ~enable ~offer =
  let future (response : Response.t) = response.cycle > cycle in
  t.pending_response <- Option.filter t.pending_response ~f:future;
  t.injected <- List.filter t.injected ~f:future;
  if reset || not enable
  then (
    t.pending_response <- None;
    t.pending_cleanup <- None);
  (match offer with
   | Some (((Request.Read { address } | Verify { address; _ }) as request), true) ->
     let data = t.memory.(address) in
     let matches =
       match request with
       | Verify { expected; _ } -> expected = data
       | _ -> t.read_match
     in
     t.pending_response
     <- Option.map
          (schedule t.readback_completion ~contract:readback_latency)
          ~f:(fun latency -> { Response.cycle = cycle + latency; data; matches })
   | Some (Abort, true) ->
     t.pending_response <- None;
     t.pending_cleanup
     <- Option.map
          (schedule t.abort_completion ~contract:abort_cleanup_latency)
          ~f:(fun latency -> cycle + latency)
   | Some (Load_start _, true) -> t.pending_response <- None
   | _ -> ());
  match t.pending_cleanup with
  | Some at when at = cycle ->
    t.status <- Status.cleaned t.status;
    t.pending_cleanup <- None
  | _ -> ()
;;
