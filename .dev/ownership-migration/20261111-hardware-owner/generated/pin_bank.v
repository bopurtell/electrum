module pin_bank (
    clock_i,
    reset_i,
    enable_i,
    abort_i,
    claim_valid_i,
    claim_engine_i,
    claim_mask_i,
    release_valid_i,
    release_engine_i,
    release_mask_i,
    write_valid_i,
    write_engine_i,
    write_mask_i,
    write_value_i,
    write_open_drain_i,
    write_oe_i,
    pins_o,
    pin_oe_o,
    software_claim_o,
    engine_claim_o,
    rejected_o,
    conflict_o
);

    input clock_i;
    input reset_i;
    input enable_i;
    input abort_i;
    input claim_valid_i;
    input claim_engine_i;
    input [7:0] claim_mask_i;
    input release_valid_i;
    input release_engine_i;
    input [7:0] release_mask_i;
    input write_valid_i;
    input write_engine_i;
    input [7:0] write_mask_i;
    input [7:0] write_value_i;
    input write_open_drain_i;
    input [7:0] write_oe_i;
    output [7:0] pins_o;
    output [7:0] pin_oe_o;
    output [7:0] software_claim_o;
    output [7:0] engine_claim_o;
    output rejected_o;
    output conflict_o;

    wire signal_const;
    wire signal_const_1;
    wire signal_and;
    wire signal_and_1;
    wire signal_or;
    wire signal_mux;
    wire signal_mux_1;
    wire signal_mux_2;
    wire signal_wire;
    reg reg_conflict;
    wire signal_mux_3;
    wire signal_mux_4;
    wire signal_wire_1;
    reg reg_rejected;
    wire [7:0] signal_const_5;
    wire [7:0] signal_wire_2;
    wire [7:0] signal_and_2;
    wire [7:0] signal_not;
    wire [7:0] signal_and_3;
    wire [7:0] signal_or_1;
    wire [7:0] signal_mux_5;
    wire [7:0] signal_mux_6;
    wire [7:0] signal_mux_7;
    wire [7:0] signal_wire_3;
    reg [7:0] reg_pin_oe;
    wire [7:0] signal_wire_4;
    wire signal_wire_5;
    wire [7:0] signal_mux_8;
    wire [7:0] signal_and_4;
    wire [7:0] signal_not_1;
    wire [7:0] signal_and_5;
    wire [7:0] signal_or_2;
    wire [7:0] signal_mux_9;
    wire signal_wire_6;
    wire [7:0] signal_mux_10;
    wire [7:0] signal_wire_7;
    wire [7:0] signal_and_6;
    wire signal_eq;
    wire signal_not_2;
    wire signal_and_7;
    wire [7:0] signal_mux_11;
    wire [7:0] signal_not_3;
    wire [7:0] signal_and_8;
    wire signal_eq_1;
    wire signal_not_4;
    wire signal_and_9;
    wire [7:0] signal_not_5;
    wire [7:0] signal_and_10;
    wire [7:0] signal_mux_12;
    wire [7:0] signal_or_3;
    wire [7:0] signal_mux_13;
    wire [7:0] signal_mux_14;
    wire [7:0] signal_mux_15;
    wire [7:0] signal_mux_16;
    wire [7:0] signal_mux_17;
    wire [7:0] signal_wire_8;
    reg [7:0] reg_software_claim;
    wire signal_wire_9;
    wire signal_wire_10;
    wire [7:0] signal_wire_11;
    wire [7:0] signal_not_6;
    wire [7:0] signal_and_11;
    wire signal_wire_12;
    wire [7:0] signal_mux_18;
    wire [7:0] signal_or_4;
    wire [7:0] signal_mux_19;
    wire [7:0] signal_mux_20;
    wire [7:0] signal_mux_21;
    wire [7:0] signal_mux_22;
    wire [7:0] signal_mux_23;
    wire [7:0] signal_wire_13;
    reg [7:0] reg_engine_claim;
    wire signal_wire_14;
    wire [7:0] signal_mux_24;
    wire [7:0] signal_wire_15;
    wire [7:0] signal_and_12;
    wire signal_eq_2;
    wire signal_not_7;
    wire signal_and_13;
    wire signal_and_14;
    wire signal_wire_16;
    wire signal_wire_17;
    wire signal_or_5;
    wire signal_wire_18;
    wire signal_and_15;
    wire signal_or_6;
    wire signal_or_7;
    wire signal_or_8;
    wire signal_or_9;
    wire [7:0] signal_mux_25;
    wire signal_wire_19;
    wire signal_wire_20;
    wire signal_not_8;
    wire signal_or_10;
    wire [7:0] signal_mux_26;
    wire [7:0] signal_wire_21;
    reg [7:0] reg_pins;
    assign signal_const = 1'b0;
    assign signal_const_1 = 1'b1;
    assign signal_and = signal_wire_16 & signal_not_2;
    assign signal_and_1 = signal_wire_18 & signal_not_7;
    assign signal_or = signal_and_1 | signal_and;
    assign signal_mux = signal_or ? signal_const_1 : reg_conflict;
    assign signal_mux_1 = signal_or_9 ? signal_mux : reg_conflict;
    assign signal_mux_2 = signal_or_10 ? reg_conflict : signal_mux_1;
    assign signal_wire = signal_mux_2;
    always @(posedge signal_wire_10) begin
        if (signal_wire_9)
            reg_conflict <= signal_const;
        else
            reg_conflict <= signal_wire;
    end
    assign signal_mux_3 = signal_or_9 ? signal_const_1 : signal_const;
    assign signal_mux_4 = signal_or_10 ? signal_const : signal_mux_3;
    assign signal_wire_1 = signal_mux_4;
    always @(posedge signal_wire_10) begin
        if (signal_wire_9)
            reg_rejected <= signal_const;
        else
            reg_rejected <= signal_wire_1;
    end
    assign signal_const_5 = 8'b00000000;
    assign signal_wire_2 = write_oe_i;
    assign signal_and_2 = signal_wire_2 & signal_wire_7;
    assign signal_not = ~ signal_wire_7;
    assign signal_and_3 = reg_pin_oe & signal_not;
    assign signal_or_1 = signal_and_3 | signal_and_2;
    assign signal_mux_5 = signal_wire_16 ? signal_or_1 : reg_pin_oe;
    assign signal_mux_6 = signal_or_9 ? reg_pin_oe : signal_mux_5;
    assign signal_mux_7 = signal_or_10 ? signal_const_5 : signal_mux_6;
    assign signal_wire_3 = signal_mux_7;
    always @(posedge signal_wire_10) begin
        if (signal_wire_9)
            reg_pin_oe <= signal_const_5;
        else
            reg_pin_oe <= signal_wire_3;
    end
    assign signal_wire_4 = write_value_i;
    assign signal_wire_5 = write_open_drain_i;
    assign signal_mux_8 = signal_wire_5 ? signal_const_5 : signal_wire_4;
    assign signal_and_4 = signal_mux_8 & signal_wire_7;
    assign signal_not_1 = ~ signal_wire_7;
    assign signal_and_5 = reg_pins & signal_not_1;
    assign signal_or_2 = signal_and_5 | signal_and_4;
    assign signal_mux_9 = signal_wire_16 ? signal_or_2 : reg_pins;
    assign signal_wire_6 = write_engine_i;
    assign signal_mux_10 = signal_wire_6 ? reg_software_claim : reg_engine_claim;
    assign signal_wire_7 = write_mask_i;
    assign signal_and_6 = signal_wire_7 & signal_mux_10;
    assign signal_eq = signal_and_6 == signal_const_5;
    assign signal_not_2 = ~ signal_eq;
    assign signal_and_7 = signal_wire_16 & signal_not_2;
    assign signal_mux_11 = signal_wire_12 ? reg_engine_claim : reg_software_claim;
    assign signal_not_3 = ~ signal_mux_11;
    assign signal_and_8 = signal_wire_11 & signal_not_3;
    assign signal_eq_1 = signal_and_8 == signal_const_5;
    assign signal_not_4 = ~ signal_eq_1;
    assign signal_and_9 = signal_wire_17 & signal_not_4;
    assign signal_not_5 = ~ signal_wire_11;
    assign signal_and_10 = reg_software_claim & signal_not_5;
    assign signal_mux_12 = signal_wire_12 ? signal_mux_14 : signal_and_10;
    assign signal_or_3 = reg_software_claim | signal_wire_15;
    assign signal_mux_13 = signal_wire_14 ? reg_software_claim : signal_or_3;
    assign signal_mux_14 = signal_wire_18 ? signal_mux_13 : reg_software_claim;
    assign signal_mux_15 = signal_wire_17 ? signal_mux_12 : signal_mux_14;
    assign signal_mux_16 = signal_or_9 ? reg_software_claim : signal_mux_15;
    assign signal_mux_17 = signal_or_10 ? signal_const_5 : signal_mux_16;
    assign signal_wire_8 = signal_mux_17;
    always @(posedge signal_wire_10) begin
        if (signal_wire_9)
            reg_software_claim <= signal_const_5;
        else
            reg_software_claim <= signal_wire_8;
    end
    assign signal_wire_9 = reset_i;
    assign signal_wire_10 = clock_i;
    assign signal_wire_11 = release_mask_i;
    assign signal_not_6 = ~ signal_wire_11;
    assign signal_and_11 = reg_engine_claim & signal_not_6;
    assign signal_wire_12 = release_engine_i;
    assign signal_mux_18 = signal_wire_12 ? signal_and_11 : signal_mux_20;
    assign signal_or_4 = reg_engine_claim | signal_wire_15;
    assign signal_mux_19 = signal_wire_14 ? signal_or_4 : reg_engine_claim;
    assign signal_mux_20 = signal_wire_18 ? signal_mux_19 : reg_engine_claim;
    assign signal_mux_21 = signal_wire_17 ? signal_mux_18 : signal_mux_20;
    assign signal_mux_22 = signal_or_9 ? reg_engine_claim : signal_mux_21;
    assign signal_mux_23 = signal_or_10 ? signal_const_5 : signal_mux_22;
    assign signal_wire_13 = signal_mux_23;
    always @(posedge signal_wire_10) begin
        if (signal_wire_9)
            reg_engine_claim <= signal_const_5;
        else
            reg_engine_claim <= signal_wire_13;
    end
    assign signal_wire_14 = claim_engine_i;
    assign signal_mux_24 = signal_wire_14 ? reg_software_claim : reg_engine_claim;
    assign signal_wire_15 = claim_mask_i;
    assign signal_and_12 = signal_wire_15 & signal_mux_24;
    assign signal_eq_2 = signal_and_12 == signal_const_5;
    assign signal_not_7 = ~ signal_eq_2;
    assign signal_and_13 = signal_wire_18 & signal_not_7;
    assign signal_and_14 = signal_wire_17 & signal_wire_16;
    assign signal_wire_16 = write_valid_i;
    assign signal_wire_17 = release_valid_i;
    assign signal_or_5 = signal_wire_17 | signal_wire_16;
    assign signal_wire_18 = claim_valid_i;
    assign signal_and_15 = signal_wire_18 & signal_or_5;
    assign signal_or_6 = signal_and_15 | signal_and_14;
    assign signal_or_7 = signal_or_6 | signal_and_13;
    assign signal_or_8 = signal_or_7 | signal_and_9;
    assign signal_or_9 = signal_or_8 | signal_and_7;
    assign signal_mux_25 = signal_or_9 ? reg_pins : signal_mux_9;
    assign signal_wire_19 = abort_i;
    assign signal_wire_20 = enable_i;
    assign signal_not_8 = ~ signal_wire_20;
    assign signal_or_10 = signal_not_8 | signal_wire_19;
    assign signal_mux_26 = signal_or_10 ? signal_const_5 : signal_mux_25;
    assign signal_wire_21 = signal_mux_26;
    always @(posedge signal_wire_10) begin
        if (signal_wire_9)
            reg_pins <= signal_const_5;
        else
            reg_pins <= signal_wire_21;
    end
    assign pins_o = reg_pins;
    assign pin_oe_o = reg_pin_oe;
    assign software_claim_o = reg_software_claim;
    assign engine_claim_o = reg_engine_claim;
    assign rejected_o = reg_rejected;
    assign conflict_o = reg_conflict;

endmodule
