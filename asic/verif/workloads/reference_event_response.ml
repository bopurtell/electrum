(* University of Florida *)
(* Author: Bohdan Purtell *)
(* Module: "reference_event_response.ml" *)
(* Execute the existing independent model scenario. Its schedule is a functional
   reference, NOT a substitute for the RTL phase-sweep latency measurement. *)
open! Core
open! Electrum_isa
open! Electrum_f_model

let checked = function Ok x -> x | Error _ -> failwith "reference scenario rejected"

let () =
  let program = Program.create ~name:"wait_start_then_drive"
    [Instr (Write_pins_imm {mode=Push_pull; mask=1; value=0});
     Instr (Wait_edge {pin=3; edge=Rising; timeout=None});
     Instr (Write_pins_imm {mode=Push_pull; mask=1; value=1}); Instr Halt]
    |> checked in
  let assembled = Assembler.assemble ~memory:Assembler.Memory.word16 program
    |> checked in
  let machine = Machine.create () in
  let pins = Pin_bank.claim machine.pins ~owner:Kinds.Owner.Software ~mask:1
    |> checked in
  let board = {Firmware.Board.initial=0;
    next=(fun edge _ -> let edge = edge + 1 in edge, if edge >= 7 then 8 else 0)} in
  let trace = Control_core.run ~max_cycles:256 ~machine:{machine with pins} board program
    |> checked in
  let halted = match trace.outcome with Control_core.Outcome.Halted -> true | _ -> false in
  let wave = Control_core.Trace.wave trace ~pin:0 in
  let words = Array.to_list assembled.image.words in
  let result = `Assoc ["schema", `String "electrum.event-response-reference";
    "version", `Int 1; "halted", `Bool halted;
    "image_words", `List (List.map words ~f:(fun x -> `Int x));
    "pin0_wave", `String wave; "cycles", `Int trace.counts.cycles;
    "fetch_cycles", `Int trace.counts.fetch_cycles;
    "instructions", `Int trace.counts.instructions;
    "extension_fetches", `Int trace.counts.extension_fetches] in
  printf "%s\n%!" (Yojson.Safe.to_string result);
  if not halted then Stdlib.exit 1
