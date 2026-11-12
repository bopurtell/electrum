`timescale 1ns/1ps
// Manual clock: inspect decisions before each edge, state 1ns after it.
// Async stimulus at an exact edge is driven before the #0 clock callback.
module event_response_tb;
  reg clock_i=0, reset_i=1, en_i=1;
  reg load_start_valid_i=0, load_write_valid_i=0, load_complete_valid_i=0;
  reg readback_valid_i=0, readback_verify_i=0, run_valid_i=0;
  reg [8:0] load_length_i=6, load_address_i=0, readback_address_i=0;
  reg [15:0] load_data_i=0, readback_expected_i=0;
  reg software_claim_valid_i=0;
  reg [7:0] pin_async_i=0;
  wire load_start_accepted_o, load_write_accepted_o, load_complete_accepted_o;
  wire readback_accepted_o, readback_response_valid_o, readback_response_match_o;
  wire [15:0] readback_response_data_o;
  wire run_accepted_o, image_valid_o, software_request_rejected_o;
  wire [8:0] image_length_o, words_written_o, words_verified_o;
  wire [7:0] software_claim_o, pins_o, pin_oe_o, rising_o;
  wire timing_busy_o, normal_halt_o, execution_fault_o, fetch_fault_o;
  wire mechanism_completion_valid_o, mechanism_request_valid_o, mechanism_accepted_o;
  wire [3:0] mechanism_kind_o;
  wire prog_mem_enable_o, prog_mem_write_enable_o;
  wire [7:0] prog_mem_address_o;
  wire [15:0] prog_mem_write_data_o;
  wire [31:0] fetch_cycles_o, instruction_count_o, extension_fetches_o;
  integer phase, edge_index, address, armed_label=-1, external_tick=-1;
  integer fd, decision_seen=0, decision_now, request_now;
  reg [15:0] words[0:5];
  reg [4095:0] trace_path, wave_path;
  protemu_event_response dut (
    .clock_i(clock_i), .reset_i(reset_i), .en_i(en_i),
    .load_start_valid_i(load_start_valid_i), .load_length_i(load_length_i),
    .load_write_valid_i(load_write_valid_i), .load_address_i(load_address_i), .load_data_i(load_data_i),
    .load_complete_valid_i(load_complete_valid_i), .readback_valid_i(readback_valid_i),
    .readback_address_i(readback_address_i), .readback_verify_i(readback_verify_i),
    .readback_expected_i(readback_expected_i), .run_valid_i(run_valid_i),
    .stop_valid_i(1'b0), .abort_valid_i(1'b0), .pin_async_i(pin_async_i),
    .software_claim_valid_i(software_claim_valid_i), .software_claim_mask_i(8'h01),
    .load_start_accepted_o(load_start_accepted_o), .load_write_accepted_o(load_write_accepted_o),
    .load_complete_accepted_o(load_complete_accepted_o), .readback_accepted_o(readback_accepted_o),
    .readback_response_valid_o(readback_response_valid_o), .readback_response_data_o(readback_response_data_o),
    .readback_response_match_o(readback_response_match_o), .run_accepted_o(run_accepted_o),
    .image_valid_o(image_valid_o), .image_length_o(image_length_o),
    .words_written_o(words_written_o), .words_verified_o(words_verified_o),
    .software_request_rejected_o(software_request_rejected_o), .software_claim_o(software_claim_o),
    .pins_o(pins_o), .pin_oe_o(pin_oe_o), .rising_o(rising_o), .timing_busy_o(timing_busy_o),
    .normal_halt_o(normal_halt_o), .execution_fault_o(execution_fault_o), .fetch_fault_o(fetch_fault_o),
    .mechanism_completion_valid_o(mechanism_completion_valid_o),
    .mechanism_request_valid_o(mechanism_request_valid_o), .mechanism_accepted_o(mechanism_accepted_o),
    .mechanism_kind_o(mechanism_kind_o), .prog_mem_enable_o(prog_mem_enable_o),
    .prog_mem_write_enable_o(prog_mem_write_enable_o), .prog_mem_address_o(prog_mem_address_o),
    .prog_mem_write_data_o(prog_mem_write_data_o), .fetch_cycles_o(fetch_cycles_o),
    .instruction_count_o(instruction_count_o), .extension_fetches_o(extension_fetches_o)
  );
  initial begin #10000; $fatal(1, "event response watchdog"); end
  initial begin
    if (!$value$plusargs("PHASE=%d", phase) || phase < -1 || phase > 9)
      $fatal(1, "PHASE=-1(calibration) or 0..9 required");
    if (!$value$plusargs("TRACE=%s", trace_path) || !$value$plusargs("VCD=%s", wave_path))
      $fatal(1, "TRACE and VCD paths required");
    fd=$fopen(trace_path,"w"); if (!fd) $fatal(1,"trace open");
    // Bounded real public signals; never dump the storage array/vendor hierarchy.
    $dumpfile(wave_path);
    $dumpvars(0, clock_i, reset_i, pin_async_i, load_start_valid_i, load_write_valid_i,
      readback_valid_i, run_valid_i, timing_busy_o, rising_o, mechanism_kind_o,
      mechanism_completion_valid_o, mechanism_request_valid_o, mechanism_accepted_o,
      pins_o, pin_oe_o, normal_halt_o, execution_fault_o, fetch_fault_o,
      prog_mem_enable_o, prog_mem_write_enable_o, prog_mem_address_o, prog_mem_write_data_o,
      fetch_cycles_o, instruction_count_o, extension_fetches_o);
    words[0]=16'h7804; words[1]=0; words[2]=16'ha300;
    words[3]=16'h7804; words[4]=1; words[5]=0;
    #3;
    for (edge_index=0; edge_index<48; edge_index=edge_index+1) begin
      software_claim_valid_i=(edge_index==1);
      load_start_valid_i=(edge_index==2);
      load_write_valid_i=(edge_index>=3 && edge_index<=8);
      if (load_write_valid_i) begin load_address_i=edge_index-3; load_data_i=words[edge_index-3]; end
      readback_valid_i=(edge_index>=9 && edge_index<=19 && edge_index%2==1);
      readback_verify_i=readback_valid_i;
      if (readback_valid_i) begin readback_address_i=(edge_index-9)/2; readback_expected_i=words[(edge_index-9)/2]; end
      load_complete_valid_i=(edge_index==21); run_valid_i=(edge_index==22);
      #2; #0;
      if (software_claim_valid_i && software_request_rejected_o !== 0) $fatal(1,"claim refused");
      if (load_start_valid_i && load_start_accepted_o !== 1) $fatal(1,"start refused");
      if (load_write_valid_i && load_write_accepted_o !== 1) $fatal(1,"write refused");
      if (readback_valid_i && readback_accepted_o !== 1) $fatal(1,"verify refused");
      if (load_complete_valid_i && load_complete_accepted_o !== 1) $fatal(1,"complete refused");
      if (run_valid_i && run_accepted_o !== 1) $fatal(1,"run refused");
      decision_now=(mechanism_completion_valid_o && mechanism_kind_o==9);
      if (decision_now) decision_seen=1;
      request_now=(decision_seen && mechanism_request_valid_o && mechanism_kind_o==4 && mechanism_accepted_o);
      $fdisplay(fd,"PRE %0d %0t %b %b %b %b %0d %0d %b",edge_index,$time,
        decision_now[0],request_now[0],prog_mem_enable_o,prog_mem_write_enable_o,
        prog_mem_address_o,prog_mem_write_data_o,
        {(software_claim_valid_i && !software_request_rejected_o),
         load_start_accepted_o,load_write_accepted_o,readback_accepted_o,
         load_complete_accepted_o,run_accepted_o});
      clock_i=1;
      #1;
      if (edge_index==0) reset_i=0;
      if (armed_label<0 && timing_busy_o===1) armed_label=5+10*edge_index;
      if (edge_index==1 && software_claim_o !== 1) $fatal(1,"claim absent");
      if (edge_index>=10 && edge_index<=20 && edge_index%2==0) begin
        address=(edge_index-10)/2;
        if (readback_response_valid_o !== 1 || readback_response_match_o !== 1 ||
            readback_response_data_o !== words[address]) $fatal(1,"readback mismatch");
      end
      if (edge_index==21 && (image_valid_o !== 1 || image_length_o !== 6 ||
          words_written_o !== 6 || words_verified_o !== 6)) $fatal(1,"image not verified");
      $fdisplay(fd,"POST %0d %0t %b %b %0d %0d %b %b %0d %0d %0d %b %0d %b %b %0d %0d %0d %0d",edge_index,$time,
        timing_busy_o,rising_o[3],pins_o,pin_oe_o,normal_halt_o,
        (execution_fault_o|fetch_fault_o),fetch_cycles_o,instruction_count_o,extension_fetches_o,
        readback_response_valid_o,readback_response_data_o,readback_response_match_o,
        image_valid_o,image_length_o,words_written_o,words_verified_o,software_claim_o);
      #4; clock_i=0; #3;
    end
    if (phase>=0 && normal_halt_o !== 1) $fatal(1,"not halted");
    $fdisplay(fd,"DONE %0d %0d",phase,external_tick); $fclose(fd);
    $display("EVENT_RESPONSE PASS phase=%0d",phase); $finish;
  end
  initial begin
    wait(armed_label>=0);
    if (phase>=0) begin
      #(9+phase); pin_async_i=8'h08; external_tick=armed_label+10+phase;
    end
  end
endmodule
