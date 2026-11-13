(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "endpoint_lifecycle_tests.ml" *)
(* SP4: each [Fixture.run] is a fresh endpoint. Two scoped runs in one test share no
   monitor items, transcript, offers, or responder policy, and a handle that escapes its
   run cannot advance time. See docs/serial_host_pilot.md, SP4.
*)

open! Core
module Serial_host = Electrum_serial_host_agent
module Driver = Serial_host.Driver
module Control_port_agent = Electrum_control_port_agent
module Responder = Control_port_agent.Responder
module Status = Control_port_agent.Item.Status
module Offer = Control_port_agent.Item.Offer
module Endpoint = Electrum_host_link_endpoint
module Fixture = Endpoint.Fixture

(* What one scenario could leak into the next: the fixture's time and transcript, both
   monitors' items, and the responder's policy and memory.
*)
module State = struct
  type t =
    { cycle : int
    ; transcript : Sexp.t
    ; serial_items : int
    ; port_items : int
    ; offers : Offer.t list
    ; accepts_write : bool
    ; memory : int array
    ; status : Status.t
    ; readback_completion : Control_port_agent.Item.Completion.t
    }
  [@@deriving sexp_of]

  let equal a b = Sexp.equal (sexp_of_t a) (sexp_of_t b)

  (* The fields in which [a] and [b] agree. *)
  let unchanged a b =
    let field name sexp_of get = name, Sexp.equal (sexp_of (get a)) (sexp_of (get b)) in
    [ field "cycle" [%sexp_of: int] (fun t -> t.cycle)
    ; field "transcript" Fn.id (fun t -> t.transcript)
    ; field "serial_items" [%sexp_of: int] (fun t -> t.serial_items)
    ; field "port_items" [%sexp_of: int] (fun t -> t.port_items)
    ; field "offers" [%sexp_of: Offer.t list] (fun t -> t.offers)
    ; field "accepts_write" [%sexp_of: bool] (fun t -> t.accepts_write)
    ; field "memory" [%sexp_of: int array] (fun t -> t.memory)
    ; field "status" [%sexp_of: Status.t] (fun t -> t.status)
    ; field
        "readback_completion"
        [%sexp_of: Control_port_agent.Item.Completion.t]
        (fun t -> t.readback_completion)
    ]
    |> List.filter_map ~f:(fun (name, same) -> Option.some_if same name)
  ;;

  let of_fixture (t : Fixture.t) =
    let responder = Fixture.responder t in
    { cycle = t.cycle
    ; transcript = Fixture.transcript t
    ; serial_items = Queue.length (Fixture.serial_observed t)
    ; port_items = Queue.length (Fixture.control_port_observed t)
    ; offers = Fixture.offers t
    ; accepts_write = responder.accept (Load_write { address = 0; data = 0 })
    ; memory = Array.copy responder.memory
    ; status = responder.status
    ; readback_completion = responder.readback_completion
    }
  ;;
end

let%test_unit "two scoped runs share no monitor items, transcript, offers, or responder \
               policy"
  =
  (* The first run changes every piece of responder policy it can and leaves a refused
     offer, a request item, and transcript events behind; the second must start as an
     endpoint fresh from reset does. The first run's handle escapes, and using it
     afterwards raises.
  *)
  let first, left =
    Fixture.run ~scenario:"isolation: first" (fun t ->
      let responder = Fixture.responder t in
      responder.accept <- (fun _ -> false);
      responder.memory.(0) <- 0x1234;
      responder.status <- Status.running;
      responder.readback_completion <- Never;
      let deselected =
        Driver.send_frame
          (Fixture.driver t)
          (Serial_host.Item.encode ~tag:0x21 (Write_word { address = 0; word = 0x5678 }))
      in
      ignore (Driver.wait_ready (Fixture.driver t) ~since:deselected : int);
      t, State.of_fixture t)
  in
  Fixture.run ~scenario:"isolation: second" (fun t ->
    let fresh : State.t =
      { cycle = 8
      ; transcript =
          [%sexp ([ 0, Reset true; 4, Reset false ] : (int * Fixture.Event.t) list)]
      ; serial_items = 0
      ; port_items = 0
      ; offers = []
      ; accepts_write = true
      ; memory = Responder.default_memory ()
      ; status = Status.halted_idle
      ; readback_completion = Contract
      }
    in
    (* The first run did leave state behind, so the comparison below is not vacuous. *)
    Fixture.check
      t
      ~phase:Post_run
      "the first run changed every compared field"
      [%sexp_of: string list]
      [%equal: string list]
      ~expected:[]
      (State.unchanged fresh left);
    Fixture.check
      t
      ~phase:Post_run
      "a second scoped run starts fresh"
      [%sexp_of: State.t]
      State.equal
      ~expected:fresh
      (State.of_fixture t));
  match Fixture.cycle first with
  | () -> raise_s [%message "a finished fixture advanced time"]
  | exception _ -> ()
;;
