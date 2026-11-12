`timescale 1ns/1ps
// Observation-only harness around the unchanged PT3b bench. No RTL instrumentation.
// Public package/serial/pin signals only; no flop or vendor macro internals dumped.
// The adapter retains this full trace and exports a labelled initial-window
// exact byte prefix for bounded embedded viewing. No sampling or DUT changes.
module pt3b_trace;
  p3_loader_tb bench();
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, bench.clock_i, bench.reset_i, bench.enable_i,
      bench.serial_select_n_i, bench.serial_clock_i, bench.serial_data_i,
      bench.serial_data_o, bench.serial_ready_o, bench.pin_async_i,
      bench.pins_o, bench.pin_oe_o);
  end
endmodule
