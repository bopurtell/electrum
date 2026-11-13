open! Core
open! Hardcaml
open! Hardcaml_asic
open! Electrum_controller
module I = Tt_cmos5l.I
module O = Tt_cmos5l.O

let name = "tt_um_leemperor_electrum_memory"

(* P0.7 test protocol: uio_in[7:5] selects one request and ui_in carries an address/length
   (zero denotes length 256 for load-start only). Opcodes 7 and 6 stage the high and low
   word bytes before a write or verification request. Read responses return the high byte
   on uo_out and low byte on uio_out. *)
let create context (i : _ I.t) =
  let open Signal in
  let core_reset = Tt_cmos5l.synchronised_reset ~clock:i.clk ~rst_n:i.rst_n () in
  let request = select i.uio_in ~high:7 ~low:5 in
  let request_is value = request ==:. value in
  let request_address = uresize i.ui_in ~width:9 in
  let request_length =
    mux2 (i.ui_in ==:. 0) (of_int_trunc ~width:9 256) request_address
  in
  let adapter_spec = Reg_spec.create ~clock:i.clk ~clear:core_reset () in
  let staged_high = reg adapter_spec ~enable:(request_is 7) i.ui_in in
  let staged_low = reg adapter_spec ~enable:(request_is 6) i.ui_in in
  let request_word = concat_msb [ staged_high; staged_low ] in
  let memory_read_data = wire Program_memory_controller.Config.program_width in
  let core =
    Program_memory_controller.create
      (Elaboration.Context.scope context)
      { Program_memory_controller.I.clock_i = i.clk
      ; reset_i = core_reset
      ; en_i = i.ena
      ; engines_idle_i = vdd
      ; load_start_valid_i = request_is 1
      ; load_length_i = request_length
      ; load_write_valid_i = request_is 2
      ; load_address_i = request_address
      ; load_data_i = request_word
      ; load_complete_valid_i = request_is 4
      ; readback_valid_i = request_is 5 |: request_is 3
      ; readback_address_i = request_address
      ; readback_verify_i = request_is 3
      ; readback_expected_i = request_word
      ; run_valid_i = gnd
      ; execution_halt_i = gnd
      ; fetch_valid_i = gnd
      ; fetch_address_i = request_address
      ; prog_mem_read_data_i = memory_read_data
      }
  in
  let ram_read_data =
    Program_memory.create
      context
      ~clock:i.clk
      ~enable:core.prog_mem_enable_o
      ~write_enable:core.prog_mem_write_enable_o
      ~address:core.prog_mem_address_o
      ~write_data:core.prog_mem_write_data_o
  in
  assign memory_read_data ram_read_data;
  let response_valid = core.readback_response_valid_o |: core.fetch_response_valid_o in
  let response_data =
    mux2
      core.readback_response_valid_o
      core.readback_response_data_o
      core.fetch_response_data_o
  in
  let accepted =
    core.load_start_accepted_o
    |: core.load_write_accepted_o
    |: core.load_complete_accepted_o
    |: core.readback_accepted_o
    |: core.run_accepted_o
    |: core.fetch_accepted_o
  in
  let rejected =
    core.load_start_rejected_o
    |: core.load_write_rejected_o
    |: core.load_complete_rejected_o
    |: core.readback_rejected_o
    |: core.run_rejected_o
    |: core.fetch_rejected_o
  in
  let status =
    concat_msb
      [ core.fetch_fault_o
      ; core.verification_failed_o
      ; core.image_valid_o
      ; core.load_active_o
      ; response_valid
      ; core.readback_response_match_o
      ; rejected
      ; accepted
      ]
  in
  let pads_enabled = i.rst_n &: i.ena &: ~:core_reset in
  { O.uo_out =
      Tt_cmos5l.gate
        ~enable:pads_enabled
        (mux2 response_valid (select response_data ~high:15 ~low:8) status)
  ; uio_out =
      Tt_cmos5l.gate
        ~enable:(pads_enabled &: response_valid)
        (select response_data ~high:7 ~low:0)
  ; uio_oe = Tt_cmos5l.gate ~enable:pads_enabled (repeat response_valid ~count:8)
  }
;;
