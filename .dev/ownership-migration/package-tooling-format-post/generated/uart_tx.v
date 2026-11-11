module uart_tx (
    clock_i,
    reset_i,
    enable_i,
    abort_i,
    byte_valid_i,
    byte_i,
    half_period_i,
    tx_pin_i,
    byte_ready_o,
    pins_o,
    pin_oe_o,
    busy_o,
    done_o,
    rejected_o
);

    input clock_i;
    input reset_i;
    input enable_i;
    input abort_i;
    input byte_valid_i;
    input [7:0] byte_i;
    input [15:0] half_period_i;
    input [2:0] tx_pin_i;
    output byte_ready_o;
    output [7:0] pins_o;
    output [7:0] pin_oe_o;
    output busy_o;
    output done_o;
    output rejected_o;

    wire signal_const;
    wire signal_const_1;
    wire signal_mux;
    wire signal_mux_1;
    wire signal_mux_2;
    wire signal_wire;
    reg lane$reg_rejected;
    wire signal_mux_3;
    wire signal_mux_4;
    wire signal_mux_5;
    wire signal_mux_6;
    wire signal_mux_7;
    wire signal_wire_1;
    reg lane$reg_done_;
    wire [7:0] signal_const_6;
    wire [7:0] signal_mux_8;
    wire [7:0] signal_mux_9;
    wire [7:0] signal_mux_10;
    wire [7:0] signal_mux_11;
    wire [7:0] signal_mux_12;
    wire [7:0] signal_mux_13;
    wire [7:0] signal_wire_2;
    reg [7:0] lane$reg_pin_oe;
    wire [7:0] signal_mux_14;
    wire [7:0] signal_mux_15;
    wire [7:0] signal_const_12;
    wire [7:0] signal_const_13;
    wire [7:0] signal_const_14;
    wire [7:0] signal_const_15;
    wire [7:0] signal_const_16;
    wire [7:0] signal_const_17;
    wire [7:0] signal_const_18;
    wire [7:0] signal_const_19;
    reg [7:0] signal_mux_16;
    wire signal_select;
    wire [7:0] signal_mux_17;
    wire [7:0] signal_mux_18;
    wire signal_select_1;
    wire signal_select_2;
    wire signal_select_3;
    wire signal_select_4;
    wire signal_select_5;
    wire signal_select_6;
    wire signal_select_7;
    wire signal_select_8;
    wire signal_select_9;
    wire signal_select_10;
    wire signal_select_11;
    wire signal_select_12;
    wire signal_select_13;
    wire signal_select_14;
    wire signal_select_15;
    wire signal_select_16;
    wire signal_select_17;
    wire signal_select_18;
    wire signal_select_19;
    wire signal_select_20;
    wire signal_select_21;
    wire signal_select_22;
    wire signal_select_23;
    wire signal_select_24;
    wire signal_select_25;
    wire signal_select_26;
    wire signal_select_27;
    wire signal_select_28;
    wire signal_select_29;
    wire signal_select_30;
    wire signal_select_31;
    wire [31:0] signal_const_22;
    wire [31:0] signal_mux_19;
    wire [31:0] signal_mux_20;
    wire [31:0] signal_mux_21;
    wire [31:0] signal_wire_3;
    reg [31:0] lane$reg_tx_value;
    wire signal_select_32;
    wire [5:0] signal_const_23;
    wire [5:0] signal_add;
    wire [5:0] signal_const_24;
    wire [5:0] signal_sub;
    wire [5:0] signal_sub_1;
    wire [5:0] signal_mux_22;
    wire [5:0] signal_sub_2;
    wire [5:0] signal_sub_3;
    wire signal_mux_23;
    wire signal_mux_24;
    wire signal_mux_25;
    wire signal_wire_4;
    reg lane$reg_lsb_first;
    wire [5:0] signal_mux_26;
    wire [5:0] signal_mux_27;
    reg signal_mux_28;
    wire [7:0] signal_mux_29;
    wire [2:0] signal_const_35;
    wire [2:0] signal_mux_30;
    wire [2:0] signal_mux_31;
    wire [2:0] signal_mux_32;
    wire [2:0] signal_wire_5;
    reg [2:0] lane$reg_output_pin;
    reg [7:0] signal_mux_33;
    wire [7:0] signal_not;
    wire [7:0] signal_and;
    wire [7:0] signal_or;
    wire [2:0] signal_mux_34;
    wire [2:0] signal_mux_35;
    wire [2:0] signal_mux_36;
    wire [2:0] signal_wire_6;
    reg [2:0] lane$reg_clock_pin;
    reg [7:0] signal_mux_37;
    wire [7:0] signal_xor;
    wire signal_mux_38;
    wire signal_mux_39;
    wire signal_mux_40;
    wire signal_wire_7;
    reg lane$reg_clock_enable;
    wire [7:0] signal_mux_41;
    wire signal_not_1;
    wire signal_mux_42;
    wire signal_mux_43;
    wire signal_mux_44;
    wire signal_wire_8;
    reg lane$reg_tx_enable;
    wire vdd;
    wire signal_mux_45;
    wire signal_mux_46;
    wire signal_mux_47;
    wire signal_wire_9;
    reg lane$reg_launch_trailing;
    wire signal_eq;
    wire signal_and_1;
    wire signal_and_2;
    wire [7:0] signal_mux_48;
    wire [7:0] signal_mux_49;
    wire [7:0] signal_mux_50;
    wire [7:0] signal_mux_51;
    wire [7:0] signal_mux_52;
    wire [7:0] signal_wire_10;
    reg [7:0] lane$reg_pin_value;
    wire [2:0] signal_wire_11;
    reg [7:0] signal_mux_53;
    wire [7:0] signal_mux_54;
    wire signal_not_2;
    wire signal_not_3;
    wire signal_and_3;
    wire signal_and_4;
    wire [7:0] signal_mux_55;
    wire signal_not_4;
    wire signal_mux_56;
    wire [5:0] signal_const_63;
    wire [5:0] signal_const_64;
    wire [5:0] signal_mux_57;
    wire [5:0] signal_mux_58;
    wire [5:0] signal_mux_59;
    wire [5:0] signal_wire_12;
    reg [5:0] lane$reg_bit_count;
    wire [5:0] signal_sub_4;
    wire [5:0] signal_mux_60;
    wire [5:0] signal_add_1;
    wire [5:0] signal_mux_61;
    wire [5:0] signal_mux_62;
    wire [5:0] signal_mux_63;
    wire [5:0] signal_mux_64;
    wire [5:0] signal_mux_65;
    wire [5:0] signal_mux_66;
    wire [5:0] signal_wire_13;
    reg [5:0] lane$reg_bit_index;
    wire signal_eq_1;
    wire signal_mux_67;
    wire signal_mux_68;
    wire signal_mux_69;
    wire signal_mux_70;
    wire signal_mux_71;
    wire signal_mux_72;
    wire signal_mux_73;
    wire signal_wire_14;
    reg lane$reg_trailing;
    wire signal_and_5;
    wire signal_mux_74;
    wire [15:0] signal_const_72;
    wire [15:0] signal_const_73;
    wire [15:0] signal_mux_75;
    wire [15:0] signal_mux_76;
    wire [15:0] signal_mux_77;
    wire [15:0] signal_mux_78;
    wire [15:0] signal_wire_15;
    reg [15:0] lane$reg_half_period;
    wire signal_not_5;
    wire [15:0] signal_mux_79;
    wire [15:0] signal_sub_5;
    wire signal_not_6;
    wire signal_not_7;
    wire signal_and_6;
    wire [15:0] signal_mux_80;
    wire [15:0] signal_mux_81;
    wire [15:0] signal_mux_82;
    wire [15:0] signal_mux_83;
    wire [15:0] signal_mux_84;
    wire [15:0] signal_wire_16;
    reg [15:0] lane$reg_remaining;
    wire signal_eq_2;
    wire signal_mux_85;
    wire signal_mux_86;
    wire signal_mux_87;
    wire signal_wire_17;
    reg lane$reg_observed;
    wire signal_mux_88;
    wire signal_and_7;
    wire signal_mux_89;
    wire signal_mux_90;
    wire signal_wire_18;
    wire signal_wire_19;
    wire [15:0] signal_wire_20;
    wire signal_eq_3;
    wire gnd;
    wire [7:0] signal_wire_21;
    wire [22:0] signal_const_82;
    wire [31:0] signal_cat;
    wire [29:0] signal_select_33;
    wire [1:0] signal_const_83;
    wire [31:0] signal_cat_1;
    wire [23:0] signal_select_34;
    wire [31:0] signal_cat_2;
    wire signal_eq_4;
    wire signal_not_8;
    wire signal_or_1;
    wire signal_mux_91;
    wire signal_mux_92;
    wire signal_mux_93;
    wire signal_wire_22;
    reg lane$reg_armed;
    wire signal_not_9;
    wire signal_not_10;
    wire signal_wire_23;
    wire signal_and_8;
    wire signal_and_9;
    wire signal_mux_94;
    wire signal_wire_24;
    wire signal_not_11;
    wire signal_or_2;
    wire signal_mux_95;
    wire signal_wire_25;
    reg lane$reg_busy;
    wire signal_not_12;
    wire signal_wire_26;
    wire signal_and_10;
    wire signal_and_11;
    assign signal_const = 1'b0;
    assign signal_const_1 = 1'b1;
    assign signal_mux = signal_or_1 ? signal_const_1 : signal_const;
    assign signal_mux_1 = signal_and_9 ? signal_mux : signal_const;
    assign signal_mux_2 = signal_or_2 ? signal_const : signal_mux_1;
    assign signal_wire = signal_mux_2;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_rejected <= signal_const;
        else
            lane$reg_rejected <= signal_wire;
    end
    assign signal_mux_3 = signal_and_5 ? signal_const_1 : signal_const;
    assign signal_mux_4 = signal_and_7 ? signal_mux_3 : signal_const;
    assign signal_mux_5 = lane$reg_busy ? signal_mux_4 : signal_const;
    assign signal_mux_6 = signal_and_9 ? signal_const : signal_mux_5;
    assign signal_mux_7 = signal_or_2 ? signal_const : signal_mux_6;
    assign signal_wire_1 = signal_mux_7;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_done_ <= signal_const;
        else
            lane$reg_done_ <= signal_wire_1;
    end
    assign signal_const_6 = 8'b00000000;
    assign signal_mux_8 = signal_or_1 ? lane$reg_pin_oe : signal_mux_16;
    assign signal_mux_9 = signal_and_5 ? signal_const_6 : lane$reg_pin_oe;
    assign signal_mux_10 = signal_and_7 ? signal_mux_9 : lane$reg_pin_oe;
    assign signal_mux_11 = lane$reg_busy ? signal_mux_10 : lane$reg_pin_oe;
    assign signal_mux_12 = signal_and_9 ? signal_mux_8 : signal_mux_11;
    assign signal_mux_13 = signal_or_2 ? signal_const_6 : signal_mux_12;
    assign signal_wire_2 = signal_mux_13;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_pin_oe <= signal_const_6;
        else
            lane$reg_pin_oe <= signal_wire_2;
    end
    assign signal_mux_14 = lane$reg_busy ? lane$reg_pin_oe : signal_mux_53;
    assign signal_mux_15 = signal_and_4 ? signal_mux_14 : signal_const_6;
    assign signal_const_12 = 8'b10000000;
    assign signal_const_13 = 8'b01000000;
    assign signal_const_14 = 8'b00100000;
    assign signal_const_15 = 8'b00010000;
    assign signal_const_16 = 8'b00001000;
    assign signal_const_17 = 8'b00000100;
    assign signal_const_18 = 8'b00000010;
    assign signal_const_19 = 8'b00000001;
    always @* begin
        case (signal_wire_11)
        0:
            signal_mux_16 <= signal_const_19;
        1:
            signal_mux_16 <= signal_const_18;
        2:
            signal_mux_16 <= signal_const_17;
        3:
            signal_mux_16 <= signal_const_16;
        4:
            signal_mux_16 <= signal_const_15;
        5:
            signal_mux_16 <= signal_const_14;
        6:
            signal_mux_16 <= signal_const_13;
        default:
            signal_mux_16 <= signal_const_12;
        endcase
    end
    assign signal_select = signal_cat[0:0];
    assign signal_mux_17 = signal_select ? signal_mux_16 : signal_const_6;
    assign signal_mux_18 = signal_or_1 ? lane$reg_pin_value : signal_mux_17;
    assign signal_select_1 = lane$reg_tx_value[31:31];
    assign signal_select_2 = lane$reg_tx_value[30:30];
    assign signal_select_3 = lane$reg_tx_value[29:29];
    assign signal_select_4 = lane$reg_tx_value[28:28];
    assign signal_select_5 = lane$reg_tx_value[27:27];
    assign signal_select_6 = lane$reg_tx_value[26:26];
    assign signal_select_7 = lane$reg_tx_value[25:25];
    assign signal_select_8 = lane$reg_tx_value[24:24];
    assign signal_select_9 = lane$reg_tx_value[23:23];
    assign signal_select_10 = lane$reg_tx_value[22:22];
    assign signal_select_11 = lane$reg_tx_value[21:21];
    assign signal_select_12 = lane$reg_tx_value[20:20];
    assign signal_select_13 = lane$reg_tx_value[19:19];
    assign signal_select_14 = lane$reg_tx_value[18:18];
    assign signal_select_15 = lane$reg_tx_value[17:17];
    assign signal_select_16 = lane$reg_tx_value[16:16];
    assign signal_select_17 = lane$reg_tx_value[15:15];
    assign signal_select_18 = lane$reg_tx_value[14:14];
    assign signal_select_19 = lane$reg_tx_value[13:13];
    assign signal_select_20 = lane$reg_tx_value[12:12];
    assign signal_select_21 = lane$reg_tx_value[11:11];
    assign signal_select_22 = lane$reg_tx_value[10:10];
    assign signal_select_23 = lane$reg_tx_value[9:9];
    assign signal_select_24 = lane$reg_tx_value[8:8];
    assign signal_select_25 = lane$reg_tx_value[7:7];
    assign signal_select_26 = lane$reg_tx_value[6:6];
    assign signal_select_27 = lane$reg_tx_value[5:5];
    assign signal_select_28 = lane$reg_tx_value[4:4];
    assign signal_select_29 = lane$reg_tx_value[3:3];
    assign signal_select_30 = lane$reg_tx_value[2:2];
    assign signal_select_31 = lane$reg_tx_value[1:1];
    assign signal_const_22 = 32'b00000000000000000000000000000000;
    assign signal_mux_19 = signal_or_1 ? lane$reg_tx_value : signal_cat;
    assign signal_mux_20 = signal_and_9 ? signal_mux_19 : lane$reg_tx_value;
    assign signal_mux_21 = signal_or_2 ? lane$reg_tx_value : signal_mux_20;
    assign signal_wire_3 = signal_mux_21;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_tx_value <= signal_const_22;
        else
            lane$reg_tx_value <= signal_wire_3;
    end
    assign signal_select_32 = lane$reg_tx_value[0:0];
    assign signal_const_23 = 6'b000001;
    assign signal_add = lane$reg_bit_index + signal_const_23;
    assign signal_const_24 = 6'b000010;
    assign signal_sub = lane$reg_bit_count - signal_const_24;
    assign signal_sub_1 = signal_sub - lane$reg_bit_index;
    assign signal_mux_22 = lane$reg_lsb_first ? signal_add : signal_sub_1;
    assign signal_sub_2 = lane$reg_bit_count - signal_const_23;
    assign signal_sub_3 = signal_sub_2 - lane$reg_bit_index;
    assign signal_mux_23 = signal_or_1 ? lane$reg_lsb_first : vdd;
    assign signal_mux_24 = signal_and_9 ? signal_mux_23 : lane$reg_lsb_first;
    assign signal_mux_25 = signal_or_2 ? lane$reg_lsb_first : signal_mux_24;
    assign signal_wire_4 = signal_mux_25;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_lsb_first <= signal_const;
        else
            lane$reg_lsb_first <= signal_wire_4;
    end
    assign signal_mux_26 = lane$reg_lsb_first ? lane$reg_bit_index : signal_sub_3;
    assign signal_mux_27 = lane$reg_launch_trailing ? signal_mux_22 : signal_mux_26;
    always @* begin
        case (signal_mux_27)
        0:
            signal_mux_28 <= signal_select_32;
        1:
            signal_mux_28 <= signal_select_31;
        2:
            signal_mux_28 <= signal_select_30;
        3:
            signal_mux_28 <= signal_select_29;
        4:
            signal_mux_28 <= signal_select_28;
        5:
            signal_mux_28 <= signal_select_27;
        6:
            signal_mux_28 <= signal_select_26;
        7:
            signal_mux_28 <= signal_select_25;
        8:
            signal_mux_28 <= signal_select_24;
        9:
            signal_mux_28 <= signal_select_23;
        10:
            signal_mux_28 <= signal_select_22;
        11:
            signal_mux_28 <= signal_select_21;
        12:
            signal_mux_28 <= signal_select_20;
        13:
            signal_mux_28 <= signal_select_19;
        14:
            signal_mux_28 <= signal_select_18;
        15:
            signal_mux_28 <= signal_select_17;
        16:
            signal_mux_28 <= signal_select_16;
        17:
            signal_mux_28 <= signal_select_15;
        18:
            signal_mux_28 <= signal_select_14;
        19:
            signal_mux_28 <= signal_select_13;
        20:
            signal_mux_28 <= signal_select_12;
        21:
            signal_mux_28 <= signal_select_11;
        22:
            signal_mux_28 <= signal_select_10;
        23:
            signal_mux_28 <= signal_select_9;
        24:
            signal_mux_28 <= signal_select_8;
        25:
            signal_mux_28 <= signal_select_7;
        26:
            signal_mux_28 <= signal_select_6;
        27:
            signal_mux_28 <= signal_select_5;
        28:
            signal_mux_28 <= signal_select_4;
        29:
            signal_mux_28 <= signal_select_3;
        30:
            signal_mux_28 <= signal_select_2;
        default:
            signal_mux_28 <= signal_select_1;
        endcase
    end
    assign signal_mux_29 = signal_mux_28 ? signal_mux_33 : signal_const_6;
    assign signal_const_35 = 3'b000;
    assign signal_mux_30 = signal_or_1 ? lane$reg_output_pin : signal_wire_11;
    assign signal_mux_31 = signal_and_9 ? signal_mux_30 : lane$reg_output_pin;
    assign signal_mux_32 = signal_or_2 ? lane$reg_output_pin : signal_mux_31;
    assign signal_wire_5 = signal_mux_32;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_output_pin <= signal_const_35;
        else
            lane$reg_output_pin <= signal_wire_5;
    end
    always @* begin
        case (lane$reg_output_pin)
        0:
            signal_mux_33 <= signal_const_19;
        1:
            signal_mux_33 <= signal_const_18;
        2:
            signal_mux_33 <= signal_const_17;
        3:
            signal_mux_33 <= signal_const_16;
        4:
            signal_mux_33 <= signal_const_15;
        5:
            signal_mux_33 <= signal_const_14;
        6:
            signal_mux_33 <= signal_const_13;
        default:
            signal_mux_33 <= signal_const_12;
        endcase
    end
    assign signal_not = ~ signal_mux_33;
    assign signal_and = signal_mux_41 & signal_not;
    assign signal_or = signal_and | signal_mux_29;
    assign signal_mux_34 = signal_or_1 ? lane$reg_clock_pin : signal_const_35;
    assign signal_mux_35 = signal_and_9 ? signal_mux_34 : lane$reg_clock_pin;
    assign signal_mux_36 = signal_or_2 ? lane$reg_clock_pin : signal_mux_35;
    assign signal_wire_6 = signal_mux_36;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_clock_pin <= signal_const_35;
        else
            lane$reg_clock_pin <= signal_wire_6;
    end
    always @* begin
        case (lane$reg_clock_pin)
        0:
            signal_mux_37 <= signal_const_19;
        1:
            signal_mux_37 <= signal_const_18;
        2:
            signal_mux_37 <= signal_const_17;
        3:
            signal_mux_37 <= signal_const_16;
        4:
            signal_mux_37 <= signal_const_15;
        5:
            signal_mux_37 <= signal_const_14;
        6:
            signal_mux_37 <= signal_const_13;
        default:
            signal_mux_37 <= signal_const_12;
        endcase
    end
    assign signal_xor = lane$reg_pin_value ^ signal_mux_37;
    assign signal_mux_38 = signal_or_1 ? lane$reg_clock_enable : gnd;
    assign signal_mux_39 = signal_and_9 ? signal_mux_38 : lane$reg_clock_enable;
    assign signal_mux_40 = signal_or_2 ? lane$reg_clock_enable : signal_mux_39;
    assign signal_wire_7 = signal_mux_40;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_clock_enable <= signal_const;
        else
            lane$reg_clock_enable <= signal_wire_7;
    end
    assign signal_mux_41 = lane$reg_clock_enable ? signal_xor : lane$reg_pin_value;
    assign signal_not_1 = ~ signal_and_5;
    assign signal_mux_42 = signal_or_1 ? lane$reg_tx_enable : vdd;
    assign signal_mux_43 = signal_and_9 ? signal_mux_42 : lane$reg_tx_enable;
    assign signal_mux_44 = signal_or_2 ? lane$reg_tx_enable : signal_mux_43;
    assign signal_wire_8 = signal_mux_44;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_tx_enable <= signal_const;
        else
            lane$reg_tx_enable <= signal_wire_8;
    end
    assign vdd = 1'b1;
    assign signal_mux_45 = signal_or_1 ? lane$reg_launch_trailing : vdd;
    assign signal_mux_46 = signal_and_9 ? signal_mux_45 : lane$reg_launch_trailing;
    assign signal_mux_47 = signal_or_2 ? lane$reg_launch_trailing : signal_mux_46;
    assign signal_wire_9 = signal_mux_47;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_launch_trailing <= signal_const;
        else
            lane$reg_launch_trailing <= signal_wire_9;
    end
    assign signal_eq = lane$reg_trailing == lane$reg_launch_trailing;
    assign signal_and_1 = signal_eq & lane$reg_tx_enable;
    assign signal_and_2 = signal_and_1 & signal_not_1;
    assign signal_mux_48 = signal_and_2 ? signal_or : signal_mux_41;
    assign signal_mux_49 = signal_and_7 ? signal_mux_48 : lane$reg_pin_value;
    assign signal_mux_50 = lane$reg_busy ? signal_mux_49 : lane$reg_pin_value;
    assign signal_mux_51 = signal_and_9 ? signal_mux_18 : signal_mux_50;
    assign signal_mux_52 = signal_or_2 ? signal_const_6 : signal_mux_51;
    assign signal_wire_10 = signal_mux_52;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_pin_value <= signal_const_6;
        else
            lane$reg_pin_value <= signal_wire_10;
    end
    assign signal_wire_11 = tx_pin_i;
    always @* begin
        case (signal_wire_11)
        0:
            signal_mux_53 <= signal_const_19;
        1:
            signal_mux_53 <= signal_const_18;
        2:
            signal_mux_53 <= signal_const_17;
        3:
            signal_mux_53 <= signal_const_16;
        4:
            signal_mux_53 <= signal_const_15;
        5:
            signal_mux_53 <= signal_const_14;
        6:
            signal_mux_53 <= signal_const_13;
        default:
            signal_mux_53 <= signal_const_12;
        endcase
    end
    assign signal_mux_54 = lane$reg_busy ? lane$reg_pin_value : signal_mux_53;
    assign signal_not_2 = ~ signal_wire_24;
    assign signal_not_3 = ~ signal_wire_18;
    assign signal_and_3 = signal_wire_26 & signal_not_3;
    assign signal_and_4 = signal_and_3 & signal_not_2;
    assign signal_mux_55 = signal_and_4 ? signal_mux_54 : signal_const_6;
    assign signal_not_4 = ~ lane$reg_armed;
    assign signal_mux_56 = signal_or_1 ? lane$reg_busy : signal_const_1;
    assign signal_const_63 = 6'b000000;
    assign signal_const_64 = 6'b001010;
    assign signal_mux_57 = signal_or_1 ? lane$reg_bit_count : signal_const_64;
    assign signal_mux_58 = signal_and_9 ? signal_mux_57 : lane$reg_bit_count;
    assign signal_mux_59 = signal_or_2 ? lane$reg_bit_count : signal_mux_58;
    assign signal_wire_12 = signal_mux_59;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_bit_count <= signal_const_63;
        else
            lane$reg_bit_count <= signal_wire_12;
    end
    assign signal_sub_4 = lane$reg_bit_count - signal_const_23;
    assign signal_mux_60 = signal_or_1 ? lane$reg_bit_index : signal_const_63;
    assign signal_add_1 = lane$reg_bit_index + signal_const_23;
    assign signal_mux_61 = lane$reg_trailing ? signal_add_1 : lane$reg_bit_index;
    assign signal_mux_62 = signal_and_5 ? lane$reg_bit_index : signal_mux_61;
    assign signal_mux_63 = signal_and_7 ? signal_mux_62 : lane$reg_bit_index;
    assign signal_mux_64 = lane$reg_busy ? signal_mux_63 : lane$reg_bit_index;
    assign signal_mux_65 = signal_and_9 ? signal_mux_60 : signal_mux_64;
    assign signal_mux_66 = signal_or_2 ? lane$reg_bit_index : signal_mux_65;
    assign signal_wire_13 = signal_mux_66;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_bit_index <= signal_const_63;
        else
            lane$reg_bit_index <= signal_wire_13;
    end
    assign signal_eq_1 = lane$reg_bit_index == signal_sub_4;
    assign signal_mux_67 = signal_or_1 ? lane$reg_trailing : signal_const;
    assign signal_mux_68 = lane$reg_trailing ? signal_const : signal_const_1;
    assign signal_mux_69 = signal_and_5 ? lane$reg_trailing : signal_mux_68;
    assign signal_mux_70 = signal_and_7 ? signal_mux_69 : lane$reg_trailing;
    assign signal_mux_71 = lane$reg_busy ? signal_mux_70 : lane$reg_trailing;
    assign signal_mux_72 = signal_and_9 ? signal_mux_67 : signal_mux_71;
    assign signal_mux_73 = signal_or_2 ? lane$reg_trailing : signal_mux_72;
    assign signal_wire_14 = signal_mux_73;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_trailing <= signal_const;
        else
            lane$reg_trailing <= signal_wire_14;
    end
    assign signal_and_5 = lane$reg_trailing & signal_eq_1;
    assign signal_mux_74 = signal_and_5 ? signal_const : lane$reg_busy;
    assign signal_const_72 = 16'b0000000000000001;
    assign signal_const_73 = 16'b0000000000000000;
    assign signal_mux_75 = signal_or_1 ? lane$reg_remaining : signal_wire_20;
    assign signal_mux_76 = signal_or_1 ? lane$reg_half_period : signal_wire_20;
    assign signal_mux_77 = signal_and_9 ? signal_mux_76 : lane$reg_half_period;
    assign signal_mux_78 = signal_or_2 ? lane$reg_half_period : signal_mux_77;
    assign signal_wire_15 = signal_mux_78;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_half_period <= signal_const_73;
        else
            lane$reg_half_period <= signal_wire_15;
    end
    assign signal_not_5 = ~ lane$reg_observed;
    assign signal_mux_79 = signal_not_5 ? lane$reg_half_period : signal_mux_80;
    assign signal_sub_5 = lane$reg_remaining - signal_const_72;
    assign signal_not_6 = ~ signal_and_7;
    assign signal_not_7 = ~ lane$reg_observed;
    assign signal_and_6 = signal_not_7 & signal_not_6;
    assign signal_mux_80 = signal_and_6 ? signal_sub_5 : lane$reg_remaining;
    assign signal_mux_81 = signal_and_7 ? signal_mux_79 : signal_mux_80;
    assign signal_mux_82 = lane$reg_busy ? signal_mux_81 : lane$reg_remaining;
    assign signal_mux_83 = signal_and_9 ? signal_mux_75 : signal_mux_82;
    assign signal_mux_84 = signal_or_2 ? signal_const_73 : signal_mux_83;
    assign signal_wire_16 = signal_mux_84;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_remaining <= signal_const_73;
        else
            lane$reg_remaining <= signal_wire_16;
    end
    assign signal_eq_2 = lane$reg_remaining == signal_const_72;
    assign signal_mux_85 = signal_or_1 ? lane$reg_observed : gnd;
    assign signal_mux_86 = signal_and_9 ? signal_mux_85 : lane$reg_observed;
    assign signal_mux_87 = signal_or_2 ? lane$reg_observed : signal_mux_86;
    assign signal_wire_17 = signal_mux_87;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_observed <= signal_const;
        else
            lane$reg_observed <= signal_wire_17;
    end
    assign signal_mux_88 = lane$reg_observed ? gnd : signal_eq_2;
    assign signal_and_7 = lane$reg_busy & signal_mux_88;
    assign signal_mux_89 = signal_and_7 ? signal_mux_74 : lane$reg_busy;
    assign signal_mux_90 = lane$reg_busy ? signal_mux_89 : lane$reg_busy;
    assign signal_wire_18 = reset_i;
    assign signal_wire_19 = clock_i;
    assign signal_wire_20 = half_period_i;
    assign signal_eq_3 = signal_wire_20 == signal_const_73;
    assign gnd = 1'b0;
    assign signal_wire_21 = byte_i;
    assign signal_const_82 = 23'b00000000000000000000001;
    assign signal_cat = { signal_const_82,
                          signal_wire_21,
                          gnd };
    assign signal_select_33 = signal_cat[31:2];
    assign signal_const_83 = 2'b00;
    assign signal_cat_1 = { signal_const_83,
                            signal_select_33 };
    assign signal_select_34 = signal_cat_1[31:8];
    assign signal_cat_2 = { signal_const_6,
                            signal_select_34 };
    assign signal_eq_4 = signal_cat_2 == signal_const_22;
    assign signal_not_8 = ~ signal_eq_4;
    assign signal_or_1 = signal_not_8 | signal_eq_3;
    assign signal_mux_91 = signal_or_1 ? lane$reg_armed : gnd;
    assign signal_mux_92 = signal_and_9 ? signal_mux_91 : lane$reg_armed;
    assign signal_mux_93 = signal_or_2 ? signal_const : signal_mux_92;
    assign signal_wire_22 = signal_mux_93;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_armed <= signal_const;
        else
            lane$reg_armed <= signal_wire_22;
    end
    assign signal_not_9 = ~ lane$reg_armed;
    assign signal_not_10 = ~ lane$reg_busy;
    assign signal_wire_23 = byte_valid_i;
    assign signal_and_8 = signal_wire_23 & signal_not_10;
    assign signal_and_9 = signal_and_8 & signal_not_9;
    assign signal_mux_94 = signal_and_9 ? signal_mux_56 : signal_mux_90;
    assign signal_wire_24 = abort_i;
    assign signal_not_11 = ~ signal_wire_26;
    assign signal_or_2 = signal_not_11 | signal_wire_24;
    assign signal_mux_95 = signal_or_2 ? signal_const : signal_mux_94;
    assign signal_wire_25 = signal_mux_95;
    always @(posedge signal_wire_19) begin
        if (signal_wire_18)
            lane$reg_busy <= signal_const;
        else
            lane$reg_busy <= signal_wire_25;
    end
    assign signal_not_12 = ~ lane$reg_busy;
    assign signal_wire_26 = enable_i;
    assign signal_and_10 = signal_wire_26 & signal_not_12;
    assign signal_and_11 = signal_and_10 & signal_not_4;
    assign byte_ready_o = signal_and_11;
    assign pins_o = signal_mux_55;
    assign pin_oe_o = signal_mux_15;
    assign busy_o = lane$reg_busy;
    assign done_o = lane$reg_done_;
    assign rejected_o = lane$reg_rejected;

endmodule
