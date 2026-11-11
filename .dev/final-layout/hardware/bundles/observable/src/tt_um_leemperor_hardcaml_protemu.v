module tt_um_leemperor_hardcaml_protemu (
    ui_in,
    ena,
    clk,
    rst_n,
    uio_in,
    uo_out,
    uio_out,
    uio_oe
);

    input [7:0] ui_in;
    input ena;
    input clk;
    input rst_n;
    input [7:0] uio_in;
    output [7:0] uo_out;
    output [7:0] uio_out;
    output [7:0] uio_oe;

    wire [7:0] signal_const;
    wire signal_select;
    wire [6:0] signal_const_3;
    wire [7:0] signal_cat;
    wire [7:0] signal_mux;
    wire [7:0] signal_mux_1;
    wire [7:0] signal_mux_2;
    wire [7:0] signal_mux_3;
    wire [7:0] signal_wire;
    reg [7:0] reg_pending_pin_oe;
    wire [7:0] signal_mux_4;
    wire [7:0] signal_mux_5;
    wire [7:0] signal_mux_6;
    wire [7:0] signal_wire_1;
    reg [7:0] reg_pin_oe;
    wire [7:0] signal_mux_7;
    wire signal_select_1;
    wire [7:0] signal_cat_1;
    wire [7:0] signal_mux_8;
    wire [7:0] signal_mux_9;
    wire [7:0] signal_mux_10;
    wire [7:0] signal_mux_11;
    wire [7:0] signal_wire_2;
    reg [7:0] reg_pending_pin_value;
    wire [7:0] signal_mux_12;
    wire [7:0] signal_mux_13;
    wire [7:0] signal_mux_14;
    wire [7:0] signal_wire_3;
    reg [7:0] reg_pins;
    wire [7:0] signal_mux_15;
    wire signal_not;
    wire signal_and;
    wire signal_const_10;
    wire signal_const_11;
    wire signal_mux_16;
    wire signal_mux_17;
    wire signal_mux_18;
    wire signal_wire_4;
    reg reg_done_;
    wire signal_mux_19;
    wire signal_mux_20;
    wire [3:0] signal_const_19;
    wire [3:0] signal_const_20;
    wire [3:0] signal_sub;
    wire [3:0] signal_mux_21;
    wire [3:0] signal_mux_22;
    wire [3:0] signal_mux_23;
    wire [3:0] signal_mux_24;
    wire [3:0] signal_mux_25;
    wire [3:0] signal_wire_5;
    reg [3:0] reg_timer;
    wire signal_eq;
    wire signal_mux_26;
    wire [3:0] signal_select_2;
    wire signal_eq_1;
    wire signal_mux_27;
    wire signal_not_1;
    wire [7:0] signal_wire_6;
    wire signal_select_3;
    wire signal_and_1;
    wire signal_mux_28;
    wire signal_mux_29;
    wire signal_mux_30;
    wire signal_wire_7;
    reg reg_busy;
    wire signal_mux_31;
    wire signal_not_2;
    wire signal_mux_32;
    wire signal_wire_8;
    reg reg_rejected;
    wire [7:0] signal_cat_2;
    wire [1:0] signal_const_27;
    wire signal_not_3;
    wire signal_wire_9;
    wire signal_select_4;
    wire [1:0] signal_cat_3;
    wire [1:0] signal_wire_10;
    reg [1:0] signal_reg;
    wire signal_select_5;
    wire signal_not_4;
    wire signal_wire_11;
    wire signal_wire_12;
    wire signal_and_2;
    wire signal_and_3;
    wire [7:0] signal_mux_33;
    assign signal_const = 8'b00000000;
    assign signal_select = signal_wire_6[5:5];
    assign signal_const_3 = 7'b0000000;
    assign signal_cat = { signal_const_3,
                          signal_select };
    assign signal_mux = signal_eq_1 ? reg_pending_pin_oe : signal_cat;
    assign signal_mux_1 = signal_and_1 ? signal_mux : reg_pending_pin_oe;
    assign signal_mux_2 = reg_busy ? reg_pending_pin_oe : signal_mux_1;
    assign signal_mux_3 = signal_not_2 ? reg_pending_pin_oe : signal_mux_2;
    assign signal_wire = signal_mux_3;
    always @(posedge signal_wire_9) begin
        if (signal_select_5)
            reg_pending_pin_oe <= signal_const;
        else
            reg_pending_pin_oe <= signal_wire;
    end
    assign signal_mux_4 = signal_eq ? reg_pending_pin_oe : reg_pin_oe;
    assign signal_mux_5 = reg_busy ? signal_mux_4 : reg_pin_oe;
    assign signal_mux_6 = signal_not_2 ? signal_const : signal_mux_5;
    assign signal_wire_1 = signal_mux_6;
    always @(posedge signal_wire_9) begin
        if (signal_select_5)
            reg_pin_oe <= signal_const;
        else
            reg_pin_oe <= signal_wire_1;
    end
    assign signal_mux_7 = signal_and_2 ? reg_pin_oe : signal_const;
    assign signal_select_1 = signal_wire_6[4:4];
    assign signal_cat_1 = { signal_const_3,
                            signal_select_1 };
    assign signal_mux_8 = signal_eq_1 ? reg_pending_pin_value : signal_cat_1;
    assign signal_mux_9 = signal_and_1 ? signal_mux_8 : reg_pending_pin_value;
    assign signal_mux_10 = reg_busy ? reg_pending_pin_value : signal_mux_9;
    assign signal_mux_11 = signal_not_2 ? reg_pending_pin_value : signal_mux_10;
    assign signal_wire_2 = signal_mux_11;
    always @(posedge signal_wire_9) begin
        if (signal_select_5)
            reg_pending_pin_value <= signal_const;
        else
            reg_pending_pin_value <= signal_wire_2;
    end
    assign signal_mux_12 = signal_eq ? reg_pending_pin_value : reg_pins;
    assign signal_mux_13 = reg_busy ? signal_mux_12 : reg_pins;
    assign signal_mux_14 = signal_not_2 ? signal_const : signal_mux_13;
    assign signal_wire_3 = signal_mux_14;
    always @(posedge signal_wire_9) begin
        if (signal_select_5)
            reg_pins <= signal_const;
        else
            reg_pins <= signal_wire_3;
    end
    assign signal_mux_15 = signal_and_2 ? reg_pins : signal_const;
    assign signal_not = ~ reg_busy;
    assign signal_and = signal_wire_11 & signal_not;
    assign signal_const_10 = 1'b0;
    assign signal_const_11 = 1'b1;
    assign signal_mux_16 = signal_eq ? signal_const_11 : signal_const_10;
    assign signal_mux_17 = reg_busy ? signal_mux_16 : signal_const_10;
    assign signal_mux_18 = signal_not_2 ? signal_const_10 : signal_mux_17;
    assign signal_wire_4 = signal_mux_18;
    always @(posedge signal_wire_9) begin
        if (signal_select_5)
            reg_done_ <= signal_const_10;
        else
            reg_done_ <= signal_wire_4;
    end
    assign signal_mux_19 = signal_eq_1 ? signal_const_11 : signal_const_10;
    assign signal_mux_20 = signal_and_1 ? signal_mux_19 : signal_const_10;
    assign signal_const_19 = 4'b0001;
    assign signal_const_20 = 4'b0000;
    assign signal_sub = reg_timer - signal_const_19;
    assign signal_mux_21 = signal_eq ? signal_const_20 : signal_sub;
    assign signal_mux_22 = signal_eq_1 ? reg_timer : signal_select_2;
    assign signal_mux_23 = signal_and_1 ? signal_mux_22 : reg_timer;
    assign signal_mux_24 = reg_busy ? signal_mux_21 : signal_mux_23;
    assign signal_mux_25 = signal_not_2 ? signal_const_20 : signal_mux_24;
    assign signal_wire_5 = signal_mux_25;
    always @(posedge signal_wire_9) begin
        if (signal_select_5)
            reg_timer <= signal_const_20;
        else
            reg_timer <= signal_wire_5;
    end
    assign signal_eq = reg_timer == signal_const_19;
    assign signal_mux_26 = signal_eq ? signal_const_10 : reg_busy;
    assign signal_select_2 = signal_wire_6[3:0];
    assign signal_eq_1 = signal_select_2 == signal_const_20;
    assign signal_mux_27 = signal_eq_1 ? reg_busy : signal_const_11;
    assign signal_not_1 = ~ reg_busy;
    assign signal_wire_6 = ui_in;
    assign signal_select_3 = signal_wire_6[6:6];
    assign signal_and_1 = signal_select_3 & signal_not_1;
    assign signal_mux_28 = signal_and_1 ? signal_mux_27 : reg_busy;
    assign signal_mux_29 = reg_busy ? signal_mux_26 : signal_mux_28;
    assign signal_mux_30 = signal_not_2 ? signal_const_10 : signal_mux_29;
    assign signal_wire_7 = signal_mux_30;
    always @(posedge signal_wire_9) begin
        if (signal_select_5)
            reg_busy <= signal_const_10;
        else
            reg_busy <= signal_wire_7;
    end
    assign signal_mux_31 = reg_busy ? signal_const_10 : signal_mux_20;
    assign signal_not_2 = ~ signal_wire_11;
    assign signal_mux_32 = signal_not_2 ? signal_const_10 : signal_mux_31;
    assign signal_wire_8 = signal_mux_32;
    always @(posedge signal_wire_9) begin
        if (signal_select_5)
            reg_rejected <= signal_const_10;
        else
            reg_rejected <= signal_wire_8;
    end
    assign signal_cat_2 = { reg_rejected,
                            reg_done_,
                            reg_busy,
                            signal_and,
                            reg_timer };
    assign signal_const_27 = 2'b11;
    assign signal_not_3 = ~ signal_wire_12;
    assign signal_wire_9 = clk;
    assign signal_select_4 = signal_reg[0:0];
    assign signal_cat_3 = { signal_select_4,
                            signal_const_10 };
    assign signal_wire_10 = signal_cat_3;
    always @(posedge signal_wire_9 or posedge signal_not_3) begin
        if (signal_not_3)
            signal_reg <= signal_const_27;
        else
            signal_reg <= signal_wire_10;
    end
    assign signal_select_5 = signal_reg[1:1];
    assign signal_not_4 = ~ signal_select_5;
    assign signal_wire_11 = ena;
    assign signal_wire_12 = rst_n;
    assign signal_and_2 = signal_wire_12 & signal_wire_11;
    assign signal_and_3 = signal_and_2 & signal_not_4;
    assign signal_mux_33 = signal_and_3 ? signal_cat_2 : signal_const;
    assign uo_out = signal_mux_33;
    assign uio_out = signal_mux_15;
    assign uio_oe = signal_mux_7;

endmodule
