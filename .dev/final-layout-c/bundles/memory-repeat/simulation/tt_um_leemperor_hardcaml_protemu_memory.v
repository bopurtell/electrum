module tt_um_leemperor_hardcaml_protemu_memory (
    ui_in,
    uio_in,
    ena,
    clk,
    rst_n,
    uo_out,
    uio_out,
    uio_oe
);

    input [7:0] ui_in;
    input [7:0] uio_in;
    input ena;
    input clk;
    input rst_n;
    output [7:0] uo_out;
    output [7:0] uio_out;
    output [7:0] uio_oe;

    wire [1:0] signal_cat;
    wire [3:0] signal_cat_1;
    wire [7:0] signal_cat_2;
    wire [7:0] signal_const;
    wire [7:0] signal_mux;
    wire [7:0] signal_select;
    wire signal_and;
    wire [7:0] signal_mux_1;
    wire [15:0] signal_const_2;
    wire [15:0] signal_mux_2;
    wire [15:0] signal_mux_3;
    wire [15:0] signal_wire;
    reg [15:0] signal_reg;
    wire [15:0] signal_mux_4;
    wire [15:0] signal_mux_5;
    wire [15:0] signal_wire_1;
    reg [15:0] signal_reg_1;
    wire [15:0] signal_mux_6;
    wire [7:0] signal_select_1;
    wire signal_or;
    wire signal_or_1;
    wire signal_or_2;
    wire signal_not;
    wire signal_and_1;
    wire signal_not_1;
    wire signal_and_2;
    wire signal_not_2;
    wire signal_and_3;
    wire signal_not_3;
    wire signal_and_4;
    wire signal_or_3;
    wire signal_or_4;
    wire signal_or_5;
    wire signal_const_4;
    wire signal_and_5;
    wire signal_mux_7;
    wire signal_mux_8;
    wire signal_wire_2;
    reg signal_reg_2;
    wire signal_mux_9;
    wire signal_mux_10;
    wire signal_wire_3;
    reg signal_reg_3;
    wire [7:0] signal_cat_3;
    wire signal_const_10;
    wire signal_not_4;
    wire signal_mux_11;
    wire signal_mux_12;
    wire signal_wire_4;
    reg signal_reg_4;
    wire signal_and_6;
    wire signal_and_7;
    wire signal_mux_13;
    wire signal_mux_14;
    wire signal_wire_5;
    reg signal_reg_5;
    wire signal_not_5;
    wire signal_not_6;
    wire signal_mux_15;
    wire signal_mux_16;
    wire signal_lt;
    wire signal_eq;
    wire signal_not_7;
    wire signal_eq_1;
    wire signal_and_8;
    wire signal_and_9;
    wire signal_and_10;
    wire signal_and_11;
    wire [8:0] signal_mux_17;
    wire signal_lt_1;
    wire signal_mux_18;
    wire signal_mux_19;
    wire signal_mux_20;
    wire signal_wire_6;
    reg signal_reg_6;
    wire signal_mux_21;
    wire signal_not_8;
    wire signal_mux_22;
    wire signal_mux_23;
    wire signal_mux_24;
    wire signal_mux_25;
    wire signal_mux_26;
    wire signal_wire_7;
    reg signal_reg_7;
    wire signal_not_9;
    wire [8:0] signal_const_35;
    wire [8:0] signal_const_37;
    wire [8:0] signal_add;
    wire [15:0] signal_mux_27;
    wire [15:0] signal_mux_28;
    wire [15:0] signal_wire_8;
    reg [15:0] signal_reg_8;
    wire [15:0] signal_const_39;
    wire signal_not_10;
    wire signal_or_6;
    wire signal_and_12;
    wire signal_and_13;
    wire [2:0] signal_const_40;
    wire signal_eq_2;
    reg [7:0] signal_reg_9;
    wire [2:0] signal_const_42;
    wire signal_eq_3;
    reg [7:0] signal_reg_10;
    wire [15:0] signal_cat_4;
    reg [15:0] program_behavioral[0:255];
    wire [8:0] signal_mux_29;
    wire [8:0] signal_mux_30;
    wire [7:0] signal_select_2;
    wire [15:0] signal_mem_read_port;
    wire signal_not_11;
    wire signal_and_14;
    wire [15:0] signal_mux_31;
    reg [15:0] signal_reg_11;
    wire [15:0] signal_wire_9;
    wire signal_eq_4;
    wire [8:0] signal_mux_32;
    wire signal_mux_33;
    wire signal_mux_34;
    wire signal_wire_10;
    reg signal_reg_12;
    wire [8:0] signal_mux_35;
    wire [8:0] signal_mux_36;
    wire [8:0] signal_mux_37;
    wire [8:0] signal_mux_38;
    wire [8:0] signal_wire_11;
    reg [8:0] signal_reg_13;
    wire signal_eq_5;
    wire [8:0] signal_add_1;
    wire [8:0] signal_mux_39;
    wire [8:0] signal_mux_40;
    wire [8:0] signal_mux_41;
    wire [8:0] signal_wire_12;
    reg [8:0] signal_reg_14;
    wire signal_lt_2;
    wire signal_eq_6;
    wire signal_and_15;
    wire signal_and_16;
    wire signal_and_17;
    wire signal_and_18;
    wire signal_and_19;
    wire [8:0] signal_mux_42;
    wire [8:0] signal_mux_43;
    wire [8:0] signal_wire_13;
    reg [8:0] signal_reg_15;
    wire signal_eq_7;
    wire [2:0] signal_const_49;
    wire signal_eq_8;
    wire signal_not_12;
    wire signal_and_20;
    wire signal_and_21;
    wire signal_and_22;
    wire signal_and_23;
    wire signal_and_24;
    wire signal_and_25;
    wire signal_and_26;
    wire signal_and_27;
    wire signal_mux_44;
    wire signal_mux_45;
    wire signal_wire_14;
    reg signal_reg_16;
    wire signal_or_7;
    wire signal_and_28;
    wire [2:0] signal_const_50;
    wire signal_eq_9;
    wire signal_mux_46;
    wire signal_not_13;
    wire signal_eq_10;
    wire [2:0] signal_const_52;
    wire signal_eq_11;
    wire signal_or_8;
    wire [2:0] signal_const_53;
    wire signal_eq_12;
    wire signal_not_14;
    wire signal_not_15;
    wire signal_and_29;
    wire signal_and_30;
    wire signal_and_31;
    wire signal_and_32;
    wire signal_and_33;
    wire signal_mux_47;
    wire signal_mux_48;
    wire signal_wire_15;
    reg signal_reg_17;
    wire signal_and_34;
    wire signal_and_35;
    wire signal_and_36;
    wire signal_mux_49;
    wire [8:0] signal_const_54;
    wire signal_lt_3;
    wire signal_not_16;
    wire gnd;
    wire [8:0] signal_cat_5;
    wire [7:0] signal_wire_16;
    wire signal_eq_13;
    wire [8:0] signal_mux_50;
    wire signal_lt_4;
    wire signal_and_37;
    wire [2:0] signal_const_58;
    wire [7:0] signal_wire_17;
    wire [2:0] signal_select_3;
    wire signal_eq_14;
    wire signal_not_17;
    wire signal_mux_51;
    wire signal_wire_18;
    reg signal_reg_18;
    wire signal_not_18;
    wire signal_and_38;
    wire signal_and_39;
    wire signal_and_40;
    wire signal_and_41;
    wire signal_mux_52;
    wire signal_not_19;
    wire signal_mux_53;
    wire signal_wire_19;
    reg signal_reg_19;
    wire signal_or_9;
    wire [7:0] signal_mux_54;
    wire [1:0] signal_const_62;
    wire signal_not_20;
    wire signal_wire_20;
    wire signal_select_4;
    wire [1:0] signal_cat_6;
    wire [1:0] signal_wire_21;
    reg [1:0] signal_reg_20;
    wire signal_select_5;
    wire signal_not_21;
    wire signal_wire_22;
    wire signal_wire_23;
    wire signal_and_42;
    wire signal_and_43;
    wire [7:0] signal_mux_55;
    assign signal_cat = { signal_or_9,
                          signal_or_9 };
    assign signal_cat_1 = { signal_cat,
                            signal_cat };
    assign signal_cat_2 = { signal_cat_1,
                            signal_cat_1 };
    assign signal_const = 8'b00000000;
    assign signal_mux = signal_and_43 ? signal_cat_2 : signal_const;
    assign signal_select = signal_mux_6[7:0];
    assign signal_and = signal_and_43 & signal_or_9;
    assign signal_mux_1 = signal_and ? signal_select : signal_const;
    assign signal_const_2 = 16'b0000000000000000;
    assign signal_mux_2 = signal_and_36 ? signal_wire_9 : signal_reg;
    assign signal_mux_3 = signal_not_19 ? signal_reg : signal_mux_2;
    assign signal_wire = signal_mux_3;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg <= signal_const_2;
        else
            signal_reg <= signal_wire;
    end
    assign signal_mux_4 = signal_and_7 ? signal_wire_9 : signal_reg_1;
    assign signal_mux_5 = signal_not_19 ? signal_reg_1 : signal_mux_4;
    assign signal_wire_1 = signal_mux_5;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_1 <= signal_const_2;
        else
            signal_reg_1 <= signal_wire_1;
    end
    assign signal_mux_6 = signal_reg_19 ? signal_reg : signal_reg_1;
    assign signal_select_1 = signal_mux_6[15:8];
    assign signal_or = signal_and_41 | signal_and_19;
    assign signal_or_1 = signal_or | signal_and_27;
    assign signal_or_2 = signal_or_1 | signal_and_33;
    assign signal_not = ~ signal_and_33;
    assign signal_and_1 = signal_or_8 & signal_not;
    assign signal_not_1 = ~ signal_and_27;
    assign signal_and_2 = signal_eq_8 & signal_not_1;
    assign signal_not_2 = ~ signal_and_19;
    assign signal_and_3 = signal_eq_12 & signal_not_2;
    assign signal_not_3 = ~ signal_and_41;
    assign signal_and_4 = signal_eq_14 & signal_not_3;
    assign signal_or_3 = signal_and_4 | signal_and_3;
    assign signal_or_4 = signal_or_3 | signal_and_2;
    assign signal_or_5 = signal_or_4 | signal_and_1;
    assign signal_const_4 = 1'b0;
    assign signal_and_5 = signal_reg_12 & signal_eq_4;
    assign signal_mux_7 = signal_and_36 ? signal_and_5 : signal_const_4;
    assign signal_mux_8 = signal_not_19 ? signal_const_4 : signal_mux_7;
    assign signal_wire_2 = signal_mux_8;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_2 <= signal_const_4;
        else
            signal_reg_2 <= signal_wire_2;
    end
    assign signal_mux_9 = signal_and_41 ? signal_const_4 : signal_reg_3;
    assign signal_mux_10 = signal_not_19 ? signal_reg_3 : signal_mux_9;
    assign signal_wire_3 = signal_mux_10;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_3 <= signal_const_4;
        else
            signal_reg_3 <= signal_wire_3;
    end
    assign signal_cat_3 = { signal_reg_3,
                            signal_reg_7,
                            signal_reg_6,
                            signal_reg_16,
                            signal_or_9,
                            signal_reg_2,
                            signal_or_5,
                            signal_or_2 };
    assign signal_const_10 = 1'b1;
    assign signal_not_4 = ~ signal_select_5;
    assign signal_mux_11 = signal_and_7 ? signal_const_4 : signal_reg_4;
    assign signal_mux_12 = signal_not_19 ? signal_const_4 : signal_mux_11;
    assign signal_wire_4 = signal_mux_12;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_4 <= signal_const_4;
        else
            signal_reg_4 <= signal_wire_4;
    end
    assign signal_and_6 = signal_wire_22 & signal_reg_4;
    assign signal_and_7 = signal_and_6 & signal_not_4;
    assign signal_mux_13 = signal_and_7 ? signal_const_10 : signal_const_4;
    assign signal_mux_14 = signal_not_19 ? signal_const_4 : signal_mux_13;
    assign signal_wire_5 = signal_mux_14;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_5 <= signal_const_4;
        else
            signal_reg_5 <= signal_wire_5;
    end
    assign signal_not_5 = ~ signal_select_5;
    assign signal_not_6 = ~ signal_and_41;
    assign signal_mux_15 = signal_and_36 ? signal_const_4 : signal_reg_17;
    assign signal_mux_16 = signal_and_41 ? signal_const_4 : signal_mux_15;
    assign signal_lt = signal_cat_5 < signal_reg_14;
    assign signal_eq = signal_cat_5 == signal_reg_13;
    assign signal_not_7 = ~ signal_reg_7;
    assign signal_eq_1 = signal_reg_15 == signal_reg_14;
    assign signal_and_8 = signal_reg_16 & signal_eq_1;
    assign signal_and_9 = signal_and_8 & signal_not_7;
    assign signal_and_10 = signal_and_9 & signal_eq;
    assign signal_and_11 = signal_and_10 & signal_lt;
    assign signal_mux_17 = signal_reg_16 ? signal_reg_15 : signal_reg_14;
    assign signal_lt_1 = signal_cat_5 < signal_mux_17;
    assign signal_mux_18 = signal_and_41 ? signal_const_4 : signal_reg_6;
    assign signal_mux_19 = signal_and_27 ? signal_const_10 : signal_mux_18;
    assign signal_mux_20 = signal_not_19 ? signal_reg_6 : signal_mux_19;
    assign signal_wire_6 = signal_mux_20;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_6 <= signal_const_4;
        else
            signal_reg_6 <= signal_wire_6;
    end
    assign signal_mux_21 = signal_and_41 ? signal_const_10 : signal_reg_16;
    assign signal_not_8 = ~ signal_reg_17;
    assign signal_mux_22 = signal_eq_4 ? signal_reg_7 : signal_const_10;
    assign signal_mux_23 = signal_reg_12 ? signal_mux_22 : signal_reg_7;
    assign signal_mux_24 = signal_and_36 ? signal_mux_23 : signal_reg_7;
    assign signal_mux_25 = signal_and_41 ? signal_const_4 : signal_mux_24;
    assign signal_mux_26 = signal_not_19 ? signal_reg_7 : signal_mux_25;
    assign signal_wire_7 = signal_mux_26;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_7 <= signal_const_4;
        else
            signal_reg_7 <= signal_wire_7;
    end
    assign signal_not_9 = ~ signal_reg_7;
    assign signal_const_35 = 9'b000000000;
    assign signal_const_37 = 9'b000000001;
    assign signal_add = signal_reg_13 + signal_const_37;
    assign signal_mux_27 = signal_and_33 ? signal_cat_4 : signal_reg_8;
    assign signal_mux_28 = signal_not_19 ? signal_reg_8 : signal_mux_27;
    assign signal_wire_8 = signal_mux_28;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_8 <= signal_const_2;
        else
            signal_reg_8 <= signal_wire_8;
    end
    assign signal_const_39 = 16'b0101010101010101;
    assign signal_not_10 = ~ signal_select_5;
    assign signal_or_6 = signal_and_19 | signal_and_33;
    assign signal_and_12 = signal_or_6 & signal_not_10;
    assign signal_and_13 = signal_and_12 & signal_and_14;
    assign signal_const_40 = 3'b110;
    assign signal_eq_2 = signal_select_3 == signal_const_40;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_9 <= signal_const;
        else
            if (signal_eq_2)
                signal_reg_9 <= signal_wire_16;
    end
    assign signal_const_42 = 3'b111;
    assign signal_eq_3 = signal_select_3 == signal_const_42;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_10 <= signal_const;
        else
            if (signal_eq_3)
                signal_reg_10 <= signal_wire_16;
    end
    assign signal_cat_4 = { signal_reg_10,
                            signal_reg_9 };
    always @(posedge signal_wire_20) begin
        if (signal_and_13)
            program_behavioral[signal_select_2] <= signal_cat_4;
    end
    initial begin
        program_behavioral[0] <= 16'b0101010101010101;
        program_behavioral[1] <= 16'b1010101010101010;
        program_behavioral[2] <= 16'b0101010101010101;
        program_behavioral[3] <= 16'b1010101010101010;
        program_behavioral[4] <= 16'b0101010101010101;
        program_behavioral[5] <= 16'b1010101010101010;
        program_behavioral[6] <= 16'b0101010101010101;
        program_behavioral[7] <= 16'b1010101010101010;
        program_behavioral[8] <= 16'b0101010101010101;
        program_behavioral[9] <= 16'b1010101010101010;
        program_behavioral[10] <= 16'b0101010101010101;
        program_behavioral[11] <= 16'b1010101010101010;
        program_behavioral[12] <= 16'b0101010101010101;
        program_behavioral[13] <= 16'b1010101010101010;
        program_behavioral[14] <= 16'b0101010101010101;
        program_behavioral[15] <= 16'b1010101010101010;
        program_behavioral[16] <= 16'b0101010101010101;
        program_behavioral[17] <= 16'b1010101010101010;
        program_behavioral[18] <= 16'b0101010101010101;
        program_behavioral[19] <= 16'b1010101010101010;
        program_behavioral[20] <= 16'b0101010101010101;
        program_behavioral[21] <= 16'b1010101010101010;
        program_behavioral[22] <= 16'b0101010101010101;
        program_behavioral[23] <= 16'b1010101010101010;
        program_behavioral[24] <= 16'b0101010101010101;
        program_behavioral[25] <= 16'b1010101010101010;
        program_behavioral[26] <= 16'b0101010101010101;
        program_behavioral[27] <= 16'b1010101010101010;
        program_behavioral[28] <= 16'b0101010101010101;
        program_behavioral[29] <= 16'b1010101010101010;
        program_behavioral[30] <= 16'b0101010101010101;
        program_behavioral[31] <= 16'b1010101010101010;
        program_behavioral[32] <= 16'b0101010101010101;
        program_behavioral[33] <= 16'b1010101010101010;
        program_behavioral[34] <= 16'b0101010101010101;
        program_behavioral[35] <= 16'b1010101010101010;
        program_behavioral[36] <= 16'b0101010101010101;
        program_behavioral[37] <= 16'b1010101010101010;
        program_behavioral[38] <= 16'b0101010101010101;
        program_behavioral[39] <= 16'b1010101010101010;
        program_behavioral[40] <= 16'b0101010101010101;
        program_behavioral[41] <= 16'b1010101010101010;
        program_behavioral[42] <= 16'b0101010101010101;
        program_behavioral[43] <= 16'b1010101010101010;
        program_behavioral[44] <= 16'b0101010101010101;
        program_behavioral[45] <= 16'b1010101010101010;
        program_behavioral[46] <= 16'b0101010101010101;
        program_behavioral[47] <= 16'b1010101010101010;
        program_behavioral[48] <= 16'b0101010101010101;
        program_behavioral[49] <= 16'b1010101010101010;
        program_behavioral[50] <= 16'b0101010101010101;
        program_behavioral[51] <= 16'b1010101010101010;
        program_behavioral[52] <= 16'b0101010101010101;
        program_behavioral[53] <= 16'b1010101010101010;
        program_behavioral[54] <= 16'b0101010101010101;
        program_behavioral[55] <= 16'b1010101010101010;
        program_behavioral[56] <= 16'b0101010101010101;
        program_behavioral[57] <= 16'b1010101010101010;
        program_behavioral[58] <= 16'b0101010101010101;
        program_behavioral[59] <= 16'b1010101010101010;
        program_behavioral[60] <= 16'b0101010101010101;
        program_behavioral[61] <= 16'b1010101010101010;
        program_behavioral[62] <= 16'b0101010101010101;
        program_behavioral[63] <= 16'b1010101010101010;
        program_behavioral[64] <= 16'b0101010101010101;
        program_behavioral[65] <= 16'b1010101010101010;
        program_behavioral[66] <= 16'b0101010101010101;
        program_behavioral[67] <= 16'b1010101010101010;
        program_behavioral[68] <= 16'b0101010101010101;
        program_behavioral[69] <= 16'b1010101010101010;
        program_behavioral[70] <= 16'b0101010101010101;
        program_behavioral[71] <= 16'b1010101010101010;
        program_behavioral[72] <= 16'b0101010101010101;
        program_behavioral[73] <= 16'b1010101010101010;
        program_behavioral[74] <= 16'b0101010101010101;
        program_behavioral[75] <= 16'b1010101010101010;
        program_behavioral[76] <= 16'b0101010101010101;
        program_behavioral[77] <= 16'b1010101010101010;
        program_behavioral[78] <= 16'b0101010101010101;
        program_behavioral[79] <= 16'b1010101010101010;
        program_behavioral[80] <= 16'b0101010101010101;
        program_behavioral[81] <= 16'b1010101010101010;
        program_behavioral[82] <= 16'b0101010101010101;
        program_behavioral[83] <= 16'b1010101010101010;
        program_behavioral[84] <= 16'b0101010101010101;
        program_behavioral[85] <= 16'b1010101010101010;
        program_behavioral[86] <= 16'b0101010101010101;
        program_behavioral[87] <= 16'b1010101010101010;
        program_behavioral[88] <= 16'b0101010101010101;
        program_behavioral[89] <= 16'b1010101010101010;
        program_behavioral[90] <= 16'b0101010101010101;
        program_behavioral[91] <= 16'b1010101010101010;
        program_behavioral[92] <= 16'b0101010101010101;
        program_behavioral[93] <= 16'b1010101010101010;
        program_behavioral[94] <= 16'b0101010101010101;
        program_behavioral[95] <= 16'b1010101010101010;
        program_behavioral[96] <= 16'b0101010101010101;
        program_behavioral[97] <= 16'b1010101010101010;
        program_behavioral[98] <= 16'b0101010101010101;
        program_behavioral[99] <= 16'b1010101010101010;
        program_behavioral[100] <= 16'b0101010101010101;
        program_behavioral[101] <= 16'b1010101010101010;
        program_behavioral[102] <= 16'b0101010101010101;
        program_behavioral[103] <= 16'b1010101010101010;
        program_behavioral[104] <= 16'b0101010101010101;
        program_behavioral[105] <= 16'b1010101010101010;
        program_behavioral[106] <= 16'b0101010101010101;
        program_behavioral[107] <= 16'b1010101010101010;
        program_behavioral[108] <= 16'b0101010101010101;
        program_behavioral[109] <= 16'b1010101010101010;
        program_behavioral[110] <= 16'b0101010101010101;
        program_behavioral[111] <= 16'b1010101010101010;
        program_behavioral[112] <= 16'b0101010101010101;
        program_behavioral[113] <= 16'b1010101010101010;
        program_behavioral[114] <= 16'b0101010101010101;
        program_behavioral[115] <= 16'b1010101010101010;
        program_behavioral[116] <= 16'b0101010101010101;
        program_behavioral[117] <= 16'b1010101010101010;
        program_behavioral[118] <= 16'b0101010101010101;
        program_behavioral[119] <= 16'b1010101010101010;
        program_behavioral[120] <= 16'b0101010101010101;
        program_behavioral[121] <= 16'b1010101010101010;
        program_behavioral[122] <= 16'b0101010101010101;
        program_behavioral[123] <= 16'b1010101010101010;
        program_behavioral[124] <= 16'b0101010101010101;
        program_behavioral[125] <= 16'b1010101010101010;
        program_behavioral[126] <= 16'b0101010101010101;
        program_behavioral[127] <= 16'b1010101010101010;
        program_behavioral[128] <= 16'b0101010101010101;
        program_behavioral[129] <= 16'b1010101010101010;
        program_behavioral[130] <= 16'b0101010101010101;
        program_behavioral[131] <= 16'b1010101010101010;
        program_behavioral[132] <= 16'b0101010101010101;
        program_behavioral[133] <= 16'b1010101010101010;
        program_behavioral[134] <= 16'b0101010101010101;
        program_behavioral[135] <= 16'b1010101010101010;
        program_behavioral[136] <= 16'b0101010101010101;
        program_behavioral[137] <= 16'b1010101010101010;
        program_behavioral[138] <= 16'b0101010101010101;
        program_behavioral[139] <= 16'b1010101010101010;
        program_behavioral[140] <= 16'b0101010101010101;
        program_behavioral[141] <= 16'b1010101010101010;
        program_behavioral[142] <= 16'b0101010101010101;
        program_behavioral[143] <= 16'b1010101010101010;
        program_behavioral[144] <= 16'b0101010101010101;
        program_behavioral[145] <= 16'b1010101010101010;
        program_behavioral[146] <= 16'b0101010101010101;
        program_behavioral[147] <= 16'b1010101010101010;
        program_behavioral[148] <= 16'b0101010101010101;
        program_behavioral[149] <= 16'b1010101010101010;
        program_behavioral[150] <= 16'b0101010101010101;
        program_behavioral[151] <= 16'b1010101010101010;
        program_behavioral[152] <= 16'b0101010101010101;
        program_behavioral[153] <= 16'b1010101010101010;
        program_behavioral[154] <= 16'b0101010101010101;
        program_behavioral[155] <= 16'b1010101010101010;
        program_behavioral[156] <= 16'b0101010101010101;
        program_behavioral[157] <= 16'b1010101010101010;
        program_behavioral[158] <= 16'b0101010101010101;
        program_behavioral[159] <= 16'b1010101010101010;
        program_behavioral[160] <= 16'b0101010101010101;
        program_behavioral[161] <= 16'b1010101010101010;
        program_behavioral[162] <= 16'b0101010101010101;
        program_behavioral[163] <= 16'b1010101010101010;
        program_behavioral[164] <= 16'b0101010101010101;
        program_behavioral[165] <= 16'b1010101010101010;
        program_behavioral[166] <= 16'b0101010101010101;
        program_behavioral[167] <= 16'b1010101010101010;
        program_behavioral[168] <= 16'b0101010101010101;
        program_behavioral[169] <= 16'b1010101010101010;
        program_behavioral[170] <= 16'b0101010101010101;
        program_behavioral[171] <= 16'b1010101010101010;
        program_behavioral[172] <= 16'b0101010101010101;
        program_behavioral[173] <= 16'b1010101010101010;
        program_behavioral[174] <= 16'b0101010101010101;
        program_behavioral[175] <= 16'b1010101010101010;
        program_behavioral[176] <= 16'b0101010101010101;
        program_behavioral[177] <= 16'b1010101010101010;
        program_behavioral[178] <= 16'b0101010101010101;
        program_behavioral[179] <= 16'b1010101010101010;
        program_behavioral[180] <= 16'b0101010101010101;
        program_behavioral[181] <= 16'b1010101010101010;
        program_behavioral[182] <= 16'b0101010101010101;
        program_behavioral[183] <= 16'b1010101010101010;
        program_behavioral[184] <= 16'b0101010101010101;
        program_behavioral[185] <= 16'b1010101010101010;
        program_behavioral[186] <= 16'b0101010101010101;
        program_behavioral[187] <= 16'b1010101010101010;
        program_behavioral[188] <= 16'b0101010101010101;
        program_behavioral[189] <= 16'b1010101010101010;
        program_behavioral[190] <= 16'b0101010101010101;
        program_behavioral[191] <= 16'b1010101010101010;
        program_behavioral[192] <= 16'b0101010101010101;
        program_behavioral[193] <= 16'b1010101010101010;
        program_behavioral[194] <= 16'b0101010101010101;
        program_behavioral[195] <= 16'b1010101010101010;
        program_behavioral[196] <= 16'b0101010101010101;
        program_behavioral[197] <= 16'b1010101010101010;
        program_behavioral[198] <= 16'b0101010101010101;
        program_behavioral[199] <= 16'b1010101010101010;
        program_behavioral[200] <= 16'b0101010101010101;
        program_behavioral[201] <= 16'b1010101010101010;
        program_behavioral[202] <= 16'b0101010101010101;
        program_behavioral[203] <= 16'b1010101010101010;
        program_behavioral[204] <= 16'b0101010101010101;
        program_behavioral[205] <= 16'b1010101010101010;
        program_behavioral[206] <= 16'b0101010101010101;
        program_behavioral[207] <= 16'b1010101010101010;
        program_behavioral[208] <= 16'b0101010101010101;
        program_behavioral[209] <= 16'b1010101010101010;
        program_behavioral[210] <= 16'b0101010101010101;
        program_behavioral[211] <= 16'b1010101010101010;
        program_behavioral[212] <= 16'b0101010101010101;
        program_behavioral[213] <= 16'b1010101010101010;
        program_behavioral[214] <= 16'b0101010101010101;
        program_behavioral[215] <= 16'b1010101010101010;
        program_behavioral[216] <= 16'b0101010101010101;
        program_behavioral[217] <= 16'b1010101010101010;
        program_behavioral[218] <= 16'b0101010101010101;
        program_behavioral[219] <= 16'b1010101010101010;
        program_behavioral[220] <= 16'b0101010101010101;
        program_behavioral[221] <= 16'b1010101010101010;
        program_behavioral[222] <= 16'b0101010101010101;
        program_behavioral[223] <= 16'b1010101010101010;
        program_behavioral[224] <= 16'b0101010101010101;
        program_behavioral[225] <= 16'b1010101010101010;
        program_behavioral[226] <= 16'b0101010101010101;
        program_behavioral[227] <= 16'b1010101010101010;
        program_behavioral[228] <= 16'b0101010101010101;
        program_behavioral[229] <= 16'b1010101010101010;
        program_behavioral[230] <= 16'b0101010101010101;
        program_behavioral[231] <= 16'b1010101010101010;
        program_behavioral[232] <= 16'b0101010101010101;
        program_behavioral[233] <= 16'b1010101010101010;
        program_behavioral[234] <= 16'b0101010101010101;
        program_behavioral[235] <= 16'b1010101010101010;
        program_behavioral[236] <= 16'b0101010101010101;
        program_behavioral[237] <= 16'b1010101010101010;
        program_behavioral[238] <= 16'b0101010101010101;
        program_behavioral[239] <= 16'b1010101010101010;
        program_behavioral[240] <= 16'b0101010101010101;
        program_behavioral[241] <= 16'b1010101010101010;
        program_behavioral[242] <= 16'b0101010101010101;
        program_behavioral[243] <= 16'b1010101010101010;
        program_behavioral[244] <= 16'b0101010101010101;
        program_behavioral[245] <= 16'b1010101010101010;
        program_behavioral[246] <= 16'b0101010101010101;
        program_behavioral[247] <= 16'b1010101010101010;
        program_behavioral[248] <= 16'b0101010101010101;
        program_behavioral[249] <= 16'b1010101010101010;
        program_behavioral[250] <= 16'b0101010101010101;
        program_behavioral[251] <= 16'b1010101010101010;
        program_behavioral[252] <= 16'b0101010101010101;
        program_behavioral[253] <= 16'b1010101010101010;
        program_behavioral[254] <= 16'b0101010101010101;
        program_behavioral[255] <= 16'b1010101010101010;
    end
    assign signal_mux_29 = signal_and_33 ? signal_cat_5 : signal_cat_5;
    assign signal_mux_30 = signal_and_19 ? signal_cat_5 : signal_mux_29;
    assign signal_select_2 = signal_mux_30[7:0];
    assign signal_mem_read_port = program_behavioral[signal_select_2];
    assign signal_not_11 = ~ signal_select_5;
    assign signal_and_14 = signal_and_19 & signal_not_11;
    assign signal_mux_31 = signal_and_14 ? signal_const_39 : signal_mem_read_port;
    always @(posedge signal_wire_20) begin
        if (signal_and_12)
            signal_reg_11 <= signal_mux_31;
    end
    assign signal_wire_9 = signal_reg_11;
    assign signal_eq_4 = signal_wire_9 == signal_reg_8;
    assign signal_mux_32 = signal_eq_4 ? signal_add : signal_reg_13;
    assign signal_mux_33 = signal_and_33 ? signal_eq_9 : signal_reg_12;
    assign signal_mux_34 = signal_not_19 ? signal_reg_12 : signal_mux_33;
    assign signal_wire_10 = signal_mux_34;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_12 <= signal_const_4;
        else
            signal_reg_12 <= signal_wire_10;
    end
    assign signal_mux_35 = signal_reg_12 ? signal_mux_32 : signal_reg_13;
    assign signal_mux_36 = signal_and_36 ? signal_mux_35 : signal_reg_13;
    assign signal_mux_37 = signal_and_41 ? signal_const_35 : signal_mux_36;
    assign signal_mux_38 = signal_not_19 ? signal_reg_13 : signal_mux_37;
    assign signal_wire_11 = signal_mux_38;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_13 <= signal_const_35;
        else
            signal_reg_13 <= signal_wire_11;
    end
    assign signal_eq_5 = signal_reg_13 == signal_reg_14;
    assign signal_add_1 = signal_reg_15 + signal_const_37;
    assign signal_mux_39 = signal_and_41 ? signal_const_35 : signal_reg_15;
    assign signal_mux_40 = signal_and_41 ? signal_mux_50 : signal_reg_14;
    assign signal_mux_41 = signal_not_19 ? signal_reg_14 : signal_mux_40;
    assign signal_wire_12 = signal_mux_41;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_14 <= signal_const_35;
        else
            signal_reg_14 <= signal_wire_12;
    end
    assign signal_lt_2 = signal_cat_5 < signal_reg_14;
    assign signal_eq_6 = signal_cat_5 == signal_reg_15;
    assign signal_and_15 = signal_and_39 & signal_not_15;
    assign signal_and_16 = signal_and_15 & signal_eq_12;
    assign signal_and_17 = signal_and_16 & signal_reg_16;
    assign signal_and_18 = signal_and_17 & signal_eq_6;
    assign signal_and_19 = signal_and_18 & signal_lt_2;
    assign signal_mux_42 = signal_and_19 ? signal_add_1 : signal_mux_39;
    assign signal_mux_43 = signal_not_19 ? signal_reg_15 : signal_mux_42;
    assign signal_wire_13 = signal_mux_43;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_15 <= signal_const_35;
        else
            signal_reg_15 <= signal_wire_13;
    end
    assign signal_eq_7 = signal_reg_15 == signal_reg_14;
    assign signal_const_49 = 3'b100;
    assign signal_eq_8 = signal_select_3 == signal_const_49;
    assign signal_not_12 = ~ signal_or_8;
    assign signal_and_20 = signal_and_29 & signal_not_12;
    assign signal_and_21 = signal_and_39 & signal_and_20;
    assign signal_and_22 = signal_and_21 & signal_eq_8;
    assign signal_and_23 = signal_and_22 & signal_reg_16;
    assign signal_and_24 = signal_and_23 & signal_eq_7;
    assign signal_and_25 = signal_and_24 & signal_eq_5;
    assign signal_and_26 = signal_and_25 & signal_not_9;
    assign signal_and_27 = signal_and_26 & signal_not_8;
    assign signal_mux_44 = signal_and_27 ? signal_const_4 : signal_mux_21;
    assign signal_mux_45 = signal_not_19 ? signal_const_4 : signal_mux_44;
    assign signal_wire_14 = signal_mux_45;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_16 <= signal_const_4;
        else
            signal_reg_16 <= signal_wire_14;
    end
    assign signal_or_7 = signal_reg_16 | signal_reg_6;
    assign signal_and_28 = signal_or_7 & signal_lt_1;
    assign signal_const_50 = 3'b011;
    assign signal_eq_9 = signal_select_3 == signal_const_50;
    assign signal_mux_46 = signal_eq_9 ? signal_and_11 : signal_and_28;
    assign signal_not_13 = ~ signal_reg_17;
    assign signal_eq_10 = signal_select_3 == signal_const_50;
    assign signal_const_52 = 3'b101;
    assign signal_eq_11 = signal_select_3 == signal_const_52;
    assign signal_or_8 = signal_eq_11 | signal_eq_10;
    assign signal_const_53 = 3'b010;
    assign signal_eq_12 = signal_select_3 == signal_const_53;
    assign signal_not_14 = ~ signal_eq_12;
    assign signal_not_15 = ~ signal_eq_14;
    assign signal_and_29 = signal_not_15 & signal_not_14;
    assign signal_and_30 = signal_and_39 & signal_and_29;
    assign signal_and_31 = signal_and_30 & signal_or_8;
    assign signal_and_32 = signal_and_31 & signal_not_13;
    assign signal_and_33 = signal_and_32 & signal_mux_46;
    assign signal_mux_47 = signal_and_33 ? signal_const_10 : signal_mux_16;
    assign signal_mux_48 = signal_not_19 ? signal_const_4 : signal_mux_47;
    assign signal_wire_15 = signal_mux_48;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_17 <= signal_const_4;
        else
            signal_reg_17 <= signal_wire_15;
    end
    assign signal_and_34 = signal_wire_22 & signal_reg_17;
    assign signal_and_35 = signal_and_34 & signal_not_6;
    assign signal_and_36 = signal_and_35 & signal_not_5;
    assign signal_mux_49 = signal_and_36 ? signal_const_10 : signal_const_4;
    assign signal_const_54 = 9'b100000000;
    assign signal_lt_3 = signal_const_54 < signal_mux_50;
    assign signal_not_16 = ~ signal_lt_3;
    assign gnd = 1'b0;
    assign signal_cat_5 = { gnd,
                            signal_wire_16 };
    assign signal_wire_16 = ui_in;
    assign signal_eq_13 = signal_wire_16 == signal_const;
    assign signal_mux_50 = signal_eq_13 ? signal_const_54 : signal_cat_5;
    assign signal_lt_4 = signal_const_35 < signal_mux_50;
    assign signal_and_37 = signal_lt_4 & signal_not_16;
    assign signal_const_58 = 3'b001;
    assign signal_wire_17 = uio_in;
    assign signal_select_3 = signal_wire_17[7:5];
    assign signal_eq_14 = signal_select_3 == signal_const_58;
    assign signal_not_17 = ~ signal_select_5;
    assign signal_mux_51 = signal_not_19 ? signal_const_4 : signal_reg_18;
    assign signal_wire_18 = signal_mux_51;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_18 <= signal_const_4;
        else
            signal_reg_18 <= signal_wire_18;
    end
    assign signal_not_18 = ~ signal_reg_18;
    assign signal_and_38 = signal_wire_22 & signal_not_18;
    assign signal_and_39 = signal_and_38 & signal_not_17;
    assign signal_and_40 = signal_and_39 & signal_eq_14;
    assign signal_and_41 = signal_and_40 & signal_and_37;
    assign signal_mux_52 = signal_and_41 ? signal_const_4 : signal_mux_49;
    assign signal_not_19 = ~ signal_wire_22;
    assign signal_mux_53 = signal_not_19 ? signal_const_4 : signal_mux_52;
    assign signal_wire_19 = signal_mux_53;
    always @(posedge signal_wire_20) begin
        if (signal_select_5)
            signal_reg_19 <= signal_const_4;
        else
            signal_reg_19 <= signal_wire_19;
    end
    assign signal_or_9 = signal_reg_19 | signal_reg_5;
    assign signal_mux_54 = signal_or_9 ? signal_select_1 : signal_cat_3;
    assign signal_const_62 = 2'b11;
    assign signal_not_20 = ~ signal_wire_23;
    assign signal_wire_20 = clk;
    assign signal_select_4 = signal_reg_20[0:0];
    assign signal_cat_6 = { signal_select_4,
                            signal_const_4 };
    assign signal_wire_21 = signal_cat_6;
    always @(posedge signal_wire_20 or posedge signal_not_20) begin
        if (signal_not_20)
            signal_reg_20 <= signal_const_62;
        else
            signal_reg_20 <= signal_wire_21;
    end
    assign signal_select_5 = signal_reg_20[1:1];
    assign signal_not_21 = ~ signal_select_5;
    assign signal_wire_22 = ena;
    assign signal_wire_23 = rst_n;
    assign signal_and_42 = signal_wire_23 & signal_wire_22;
    assign signal_and_43 = signal_and_42 & signal_not_21;
    assign signal_mux_55 = signal_and_43 ? signal_mux_54 : signal_const;
    assign uo_out = signal_mux_55;
    assign uio_out = signal_mux_1;
    assign uio_oe = signal_mux;

endmodule
