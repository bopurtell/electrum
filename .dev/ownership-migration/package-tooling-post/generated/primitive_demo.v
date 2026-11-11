module primitive_demo (
    clock_i,
    reset_i,
    enable_i,
    abort_i,
    wait_valid_i,
    wait_delay_i,
    transfer_valid_i,
    transfer_count_i,
    transfer_data_i,
    half_period_i,
    wait_busy_o,
    wait_complete_o,
    transfer_busy_o,
    transfer_done_o,
    pins_o,
    pin_oe_o
);

    input clock_i;
    input reset_i;
    input enable_i;
    input abort_i;
    input wait_valid_i;
    input [15:0] wait_delay_i;
    input transfer_valid_i;
    input [5:0] transfer_count_i;
    input [31:0] transfer_data_i;
    input [15:0] half_period_i;
    output wait_busy_o;
    output wait_complete_o;
    output transfer_busy_o;
    output transfer_done_o;
    output [7:0] pins_o;
    output [7:0] pin_oe_o;

    wire [7:0] signal_const;
    wire [7:0] signal_const_2;
    wire [7:0] signal_mux;
    wire [7:0] signal_mux_1;
    wire [7:0] signal_mux_2;
    wire [7:0] signal_mux_3;
    wire [7:0] signal_mux_4;
    wire [7:0] signal_mux_5;
    wire [7:0] signal_wire;
    reg [7:0] lane$reg_pin_oe;
    wire signal_select;
    wire [7:0] signal_mux_6;
    wire [7:0] signal_mux_7;
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
    wire [31:0] signal_const_9;
    wire [31:0] signal_mux_8;
    wire [31:0] signal_mux_9;
    wire [31:0] signal_mux_10;
    wire [31:0] signal_wire_1;
    reg [31:0] lane$reg_tx_value;
    wire signal_select_32;
    wire [5:0] signal_const_10;
    wire [5:0] signal_add;
    wire [5:0] signal_const_11;
    wire [5:0] signal_sub;
    wire [5:0] signal_sub_1;
    wire [5:0] signal_mux_11;
    wire [5:0] signal_sub_2;
    wire [5:0] signal_sub_3;
    wire signal_const_13;
    wire signal_mux_12;
    wire signal_mux_13;
    wire signal_mux_14;
    wire signal_wire_2;
    reg lane$reg_lsb_first;
    wire [5:0] signal_mux_15;
    wire [5:0] signal_mux_16;
    reg signal_mux_17;
    wire [7:0] signal_mux_18;
    wire [7:0] signal_const_14;
    wire [7:0] signal_const_15;
    wire [7:0] signal_const_16;
    wire [7:0] signal_const_17;
    wire [7:0] signal_const_18;
    wire [7:0] signal_const_19;
    wire [7:0] signal_const_20;
    wire [2:0] signal_const_22;
    wire [2:0] signal_mux_19;
    wire [2:0] signal_mux_20;
    wire [2:0] signal_mux_21;
    wire [2:0] signal_wire_3;
    reg [2:0] lane$reg_output_pin;
    reg [7:0] signal_mux_22;
    wire [7:0] signal_not;
    wire [7:0] signal_and;
    wire [7:0] signal_or;
    wire [2:0] signal_mux_23;
    wire [2:0] signal_mux_24;
    wire [2:0] signal_mux_25;
    wire [2:0] signal_wire_4;
    reg [2:0] lane$reg_clock_pin;
    reg [7:0] signal_mux_26;
    wire [7:0] signal_xor;
    wire signal_mux_27;
    wire signal_mux_28;
    wire signal_mux_29;
    wire signal_wire_5;
    reg lane$reg_clock_enable;
    wire [7:0] signal_mux_30;
    wire signal_not_1;
    wire signal_mux_31;
    wire signal_mux_32;
    wire signal_mux_33;
    wire signal_wire_6;
    reg lane$reg_tx_enable;
    wire vdd;
    wire signal_mux_34;
    wire signal_mux_35;
    wire signal_mux_36;
    wire signal_wire_7;
    reg lane$reg_launch_trailing;
    wire signal_eq;
    wire signal_and_1;
    wire signal_and_2;
    wire [7:0] signal_mux_37;
    wire [7:0] signal_mux_38;
    wire [7:0] signal_mux_39;
    wire [7:0] signal_mux_40;
    wire [7:0] signal_mux_41;
    wire [7:0] signal_wire_8;
    reg [7:0] lane$reg_pin_value;
    wire signal_const_38;
    wire signal_mux_42;
    wire signal_mux_43;
    wire signal_mux_44;
    wire signal_mux_45;
    wire signal_mux_46;
    wire signal_wire_9;
    reg lane$reg_done_;
    wire signal_mux_47;
    wire [5:0] signal_const_45;
    wire [5:0] signal_mux_48;
    wire [5:0] signal_mux_49;
    wire [5:0] signal_mux_50;
    wire [5:0] signal_wire_10;
    reg [5:0] lane$reg_bit_count;
    wire [5:0] signal_sub_4;
    wire [5:0] signal_mux_51;
    wire [5:0] signal_add_1;
    wire [5:0] signal_mux_52;
    wire [5:0] signal_mux_53;
    wire [5:0] signal_mux_54;
    wire [5:0] signal_mux_55;
    wire [5:0] signal_mux_56;
    wire [5:0] signal_mux_57;
    wire [5:0] signal_wire_11;
    reg [5:0] lane$reg_bit_index;
    wire signal_eq_1;
    wire signal_mux_58;
    wire signal_mux_59;
    wire signal_mux_60;
    wire signal_mux_61;
    wire signal_mux_62;
    wire signal_mux_63;
    wire signal_mux_64;
    wire signal_wire_12;
    reg lane$reg_trailing;
    wire signal_and_3;
    wire signal_mux_65;
    wire [15:0] signal_const_53;
    wire [15:0] signal_const_54;
    wire [15:0] signal_mux_66;
    wire [15:0] signal_mux_67;
    wire [15:0] signal_mux_68;
    wire [15:0] signal_mux_69;
    wire [15:0] signal_wire_13;
    reg [15:0] lane$reg_half_period;
    wire signal_not_2;
    wire [15:0] signal_mux_70;
    wire [15:0] signal_sub_5;
    wire signal_not_3;
    wire signal_not_4;
    wire signal_and_4;
    wire [15:0] signal_mux_71;
    wire [15:0] signal_mux_72;
    wire [15:0] signal_mux_73;
    wire [15:0] signal_mux_74;
    wire [15:0] signal_mux_75;
    wire [15:0] signal_wire_14;
    reg [15:0] lane$reg_remaining;
    wire signal_eq_2;
    wire signal_mux_76;
    wire signal_mux_77;
    wire signal_mux_78;
    wire signal_wire_15;
    reg lane$reg_observed;
    wire signal_mux_79;
    wire signal_and_5;
    wire signal_mux_80;
    wire signal_mux_81;
    wire [15:0] signal_wire_16;
    wire signal_eq_3;
    wire [15:0] signal_select_33;
    wire [31:0] signal_cat;
    wire [23:0] signal_select_34;
    wire [31:0] signal_cat_1;
    wire [27:0] signal_select_35;
    wire [3:0] signal_const_66;
    wire [31:0] signal_cat_2;
    wire [29:0] signal_select_36;
    wire [1:0] signal_const_67;
    wire [31:0] signal_cat_3;
    wire [30:0] signal_select_37;
    wire [31:0] signal_cat_4;
    wire [31:0] signal_wire_17;
    wire signal_select_38;
    wire [31:0] signal_mux_82;
    wire signal_select_39;
    wire [31:0] signal_mux_83;
    wire signal_select_40;
    wire [31:0] signal_mux_84;
    wire signal_select_41;
    wire [31:0] signal_mux_85;
    wire signal_select_42;
    wire [31:0] signal_mux_86;
    wire signal_select_43;
    wire [31:0] signal_mux_87;
    wire signal_eq_4;
    wire signal_not_5;
    wire [5:0] signal_const_69;
    wire signal_lt;
    wire [5:0] signal_wire_18;
    wire signal_eq_5;
    wire signal_or_1;
    wire signal_or_2;
    wire signal_or_3;
    wire signal_mux_88;
    wire signal_mux_89;
    wire signal_mux_90;
    wire signal_wire_19;
    reg lane$reg_armed;
    wire signal_not_6;
    wire signal_not_7;
    wire signal_wire_20;
    wire signal_and_6;
    wire signal_and_7;
    wire signal_mux_91;
    wire signal_not_8;
    wire signal_or_4;
    wire signal_mux_92;
    wire signal_wire_21;
    reg lane$reg_busy;
    wire signal_eq_6;
    wire signal_mux_93;
    wire signal_mux_94;
    wire signal_mux_95;
    wire signal_mux_96;
    wire signal_mux_97;
    wire signal_wire_22;
    reg timing$reg_complete;
    wire [15:0] signal_sub_6;
    wire signal_eq_7;
    wire signal_or_5;
    wire [15:0] signal_mux_98;
    wire [15:0] signal_mux_99;
    wire [15:0] signal_mux_100;
    wire [15:0] signal_mux_101;
    wire [15:0] signal_mux_102;
    wire [15:0] signal_mux_103;
    wire [15:0] signal_mux_104;
    wire [15:0] signal_wire_23;
    reg [15:0] timing$reg_remaining;
    wire signal_eq_8;
    wire signal_mux_105;
    wire signal_mux_106;
    wire signal_mux_107;
    wire signal_mux_108;
    wire signal_wire_24;
    reg timing$reg_timeout_enable;
    wire signal_eq_9;
    wire signal_or_6;
    wire signal_and_8;
    wire signal_mux_109;
    reg signal_mux_110;
    reg signal_mux_111;
    wire signal_mux_112;
    wire signal_mux_113;
    wire signal_mux_114;
    wire signal_mux_115;
    wire signal_wire_25;
    reg timing$reg_level;
    wire [2:0] signal_mux_116;
    wire [2:0] signal_mux_117;
    wire [2:0] signal_mux_118;
    wire [2:0] signal_mux_119;
    wire [2:0] signal_wire_26;
    reg [2:0] timing$reg_pin;
    reg signal_mux_120;
    wire signal_eq_10;
    wire gnd;
    wire signal_wire_27;
    wire signal_wire_28;
    wire [1:0] signal_mux_121;
    wire [1:0] signal_mux_122;
    wire [1:0] signal_mux_123;
    wire [1:0] signal_mux_124;
    wire [1:0] signal_wire_29;
    reg [1:0] timing$reg_kind;
    reg signal_mux_125;
    wire signal_mux_126;
    wire [15:0] signal_wire_30;
    wire signal_eq_11;
    wire signal_mux_127;
    wire signal_wire_31;
    wire signal_mux_128;
    wire signal_mux_129;
    wire signal_wire_32;
    wire signal_wire_33;
    wire signal_not_9;
    wire signal_or_7;
    wire signal_mux_130;
    wire signal_wire_34;
    reg timing$reg_busy;
    assign signal_const = 8'b00000000;
    assign signal_const_2 = 8'b00000001;
    assign signal_mux = signal_or_3 ? lane$reg_pin_oe : signal_const_2;
    assign signal_mux_1 = signal_and_3 ? signal_const : lane$reg_pin_oe;
    assign signal_mux_2 = signal_and_5 ? signal_mux_1 : lane$reg_pin_oe;
    assign signal_mux_3 = lane$reg_busy ? signal_mux_2 : lane$reg_pin_oe;
    assign signal_mux_4 = signal_and_7 ? signal_mux : signal_mux_3;
    assign signal_mux_5 = signal_or_4 ? signal_const : signal_mux_4;
    assign signal_wire = signal_mux_5;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_pin_oe <= signal_const;
        else
            lane$reg_pin_oe <= signal_wire;
    end
    assign signal_select = signal_wire_17[0:0];
    assign signal_mux_6 = signal_select ? signal_const_2 : signal_const;
    assign signal_mux_7 = signal_or_3 ? lane$reg_pin_value : signal_mux_6;
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
    assign signal_const_9 = 32'b00000000000000000000000000000000;
    assign signal_mux_8 = signal_or_3 ? lane$reg_tx_value : signal_wire_17;
    assign signal_mux_9 = signal_and_7 ? signal_mux_8 : lane$reg_tx_value;
    assign signal_mux_10 = signal_or_4 ? lane$reg_tx_value : signal_mux_9;
    assign signal_wire_1 = signal_mux_10;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_tx_value <= signal_const_9;
        else
            lane$reg_tx_value <= signal_wire_1;
    end
    assign signal_select_32 = lane$reg_tx_value[0:0];
    assign signal_const_10 = 6'b000001;
    assign signal_add = lane$reg_bit_index + signal_const_10;
    assign signal_const_11 = 6'b000010;
    assign signal_sub = lane$reg_bit_count - signal_const_11;
    assign signal_sub_1 = signal_sub - lane$reg_bit_index;
    assign signal_mux_11 = lane$reg_lsb_first ? signal_add : signal_sub_1;
    assign signal_sub_2 = lane$reg_bit_count - signal_const_10;
    assign signal_sub_3 = signal_sub_2 - lane$reg_bit_index;
    assign signal_const_13 = 1'b0;
    assign signal_mux_12 = signal_or_3 ? lane$reg_lsb_first : vdd;
    assign signal_mux_13 = signal_and_7 ? signal_mux_12 : lane$reg_lsb_first;
    assign signal_mux_14 = signal_or_4 ? lane$reg_lsb_first : signal_mux_13;
    assign signal_wire_2 = signal_mux_14;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_lsb_first <= signal_const_13;
        else
            lane$reg_lsb_first <= signal_wire_2;
    end
    assign signal_mux_15 = lane$reg_lsb_first ? lane$reg_bit_index : signal_sub_3;
    assign signal_mux_16 = lane$reg_launch_trailing ? signal_mux_11 : signal_mux_15;
    always @* begin
        case (signal_mux_16)
        0:
            signal_mux_17 <= signal_select_32;
        1:
            signal_mux_17 <= signal_select_31;
        2:
            signal_mux_17 <= signal_select_30;
        3:
            signal_mux_17 <= signal_select_29;
        4:
            signal_mux_17 <= signal_select_28;
        5:
            signal_mux_17 <= signal_select_27;
        6:
            signal_mux_17 <= signal_select_26;
        7:
            signal_mux_17 <= signal_select_25;
        8:
            signal_mux_17 <= signal_select_24;
        9:
            signal_mux_17 <= signal_select_23;
        10:
            signal_mux_17 <= signal_select_22;
        11:
            signal_mux_17 <= signal_select_21;
        12:
            signal_mux_17 <= signal_select_20;
        13:
            signal_mux_17 <= signal_select_19;
        14:
            signal_mux_17 <= signal_select_18;
        15:
            signal_mux_17 <= signal_select_17;
        16:
            signal_mux_17 <= signal_select_16;
        17:
            signal_mux_17 <= signal_select_15;
        18:
            signal_mux_17 <= signal_select_14;
        19:
            signal_mux_17 <= signal_select_13;
        20:
            signal_mux_17 <= signal_select_12;
        21:
            signal_mux_17 <= signal_select_11;
        22:
            signal_mux_17 <= signal_select_10;
        23:
            signal_mux_17 <= signal_select_9;
        24:
            signal_mux_17 <= signal_select_8;
        25:
            signal_mux_17 <= signal_select_7;
        26:
            signal_mux_17 <= signal_select_6;
        27:
            signal_mux_17 <= signal_select_5;
        28:
            signal_mux_17 <= signal_select_4;
        29:
            signal_mux_17 <= signal_select_3;
        30:
            signal_mux_17 <= signal_select_2;
        default:
            signal_mux_17 <= signal_select_1;
        endcase
    end
    assign signal_mux_18 = signal_mux_17 ? signal_mux_22 : signal_const;
    assign signal_const_14 = 8'b10000000;
    assign signal_const_15 = 8'b01000000;
    assign signal_const_16 = 8'b00100000;
    assign signal_const_17 = 8'b00010000;
    assign signal_const_18 = 8'b00001000;
    assign signal_const_19 = 8'b00000100;
    assign signal_const_20 = 8'b00000010;
    assign signal_const_22 = 3'b000;
    assign signal_mux_19 = signal_or_3 ? lane$reg_output_pin : signal_const_22;
    assign signal_mux_20 = signal_and_7 ? signal_mux_19 : lane$reg_output_pin;
    assign signal_mux_21 = signal_or_4 ? lane$reg_output_pin : signal_mux_20;
    assign signal_wire_3 = signal_mux_21;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_output_pin <= signal_const_22;
        else
            lane$reg_output_pin <= signal_wire_3;
    end
    always @* begin
        case (lane$reg_output_pin)
        0:
            signal_mux_22 <= signal_const_2;
        1:
            signal_mux_22 <= signal_const_20;
        2:
            signal_mux_22 <= signal_const_19;
        3:
            signal_mux_22 <= signal_const_18;
        4:
            signal_mux_22 <= signal_const_17;
        5:
            signal_mux_22 <= signal_const_16;
        6:
            signal_mux_22 <= signal_const_15;
        default:
            signal_mux_22 <= signal_const_14;
        endcase
    end
    assign signal_not = ~ signal_mux_22;
    assign signal_and = signal_mux_30 & signal_not;
    assign signal_or = signal_and | signal_mux_18;
    assign signal_mux_23 = signal_or_3 ? lane$reg_clock_pin : signal_const_22;
    assign signal_mux_24 = signal_and_7 ? signal_mux_23 : lane$reg_clock_pin;
    assign signal_mux_25 = signal_or_4 ? lane$reg_clock_pin : signal_mux_24;
    assign signal_wire_4 = signal_mux_25;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_clock_pin <= signal_const_22;
        else
            lane$reg_clock_pin <= signal_wire_4;
    end
    always @* begin
        case (lane$reg_clock_pin)
        0:
            signal_mux_26 <= signal_const_2;
        1:
            signal_mux_26 <= signal_const_20;
        2:
            signal_mux_26 <= signal_const_19;
        3:
            signal_mux_26 <= signal_const_18;
        4:
            signal_mux_26 <= signal_const_17;
        5:
            signal_mux_26 <= signal_const_16;
        6:
            signal_mux_26 <= signal_const_15;
        default:
            signal_mux_26 <= signal_const_14;
        endcase
    end
    assign signal_xor = lane$reg_pin_value ^ signal_mux_26;
    assign signal_mux_27 = signal_or_3 ? lane$reg_clock_enable : gnd;
    assign signal_mux_28 = signal_and_7 ? signal_mux_27 : lane$reg_clock_enable;
    assign signal_mux_29 = signal_or_4 ? lane$reg_clock_enable : signal_mux_28;
    assign signal_wire_5 = signal_mux_29;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_clock_enable <= signal_const_13;
        else
            lane$reg_clock_enable <= signal_wire_5;
    end
    assign signal_mux_30 = lane$reg_clock_enable ? signal_xor : lane$reg_pin_value;
    assign signal_not_1 = ~ signal_and_3;
    assign signal_mux_31 = signal_or_3 ? lane$reg_tx_enable : vdd;
    assign signal_mux_32 = signal_and_7 ? signal_mux_31 : lane$reg_tx_enable;
    assign signal_mux_33 = signal_or_4 ? lane$reg_tx_enable : signal_mux_32;
    assign signal_wire_6 = signal_mux_33;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_tx_enable <= signal_const_13;
        else
            lane$reg_tx_enable <= signal_wire_6;
    end
    assign vdd = 1'b1;
    assign signal_mux_34 = signal_or_3 ? lane$reg_launch_trailing : vdd;
    assign signal_mux_35 = signal_and_7 ? signal_mux_34 : lane$reg_launch_trailing;
    assign signal_mux_36 = signal_or_4 ? lane$reg_launch_trailing : signal_mux_35;
    assign signal_wire_7 = signal_mux_36;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_launch_trailing <= signal_const_13;
        else
            lane$reg_launch_trailing <= signal_wire_7;
    end
    assign signal_eq = lane$reg_trailing == lane$reg_launch_trailing;
    assign signal_and_1 = signal_eq & lane$reg_tx_enable;
    assign signal_and_2 = signal_and_1 & signal_not_1;
    assign signal_mux_37 = signal_and_2 ? signal_or : signal_mux_30;
    assign signal_mux_38 = signal_and_5 ? signal_mux_37 : lane$reg_pin_value;
    assign signal_mux_39 = lane$reg_busy ? signal_mux_38 : lane$reg_pin_value;
    assign signal_mux_40 = signal_and_7 ? signal_mux_7 : signal_mux_39;
    assign signal_mux_41 = signal_or_4 ? signal_const : signal_mux_40;
    assign signal_wire_8 = signal_mux_41;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_pin_value <= signal_const;
        else
            lane$reg_pin_value <= signal_wire_8;
    end
    assign signal_const_38 = 1'b1;
    assign signal_mux_42 = signal_and_3 ? signal_const_38 : signal_const_13;
    assign signal_mux_43 = signal_and_5 ? signal_mux_42 : signal_const_13;
    assign signal_mux_44 = lane$reg_busy ? signal_mux_43 : signal_const_13;
    assign signal_mux_45 = signal_and_7 ? signal_const_13 : signal_mux_44;
    assign signal_mux_46 = signal_or_4 ? signal_const_13 : signal_mux_45;
    assign signal_wire_9 = signal_mux_46;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_done_ <= signal_const_13;
        else
            lane$reg_done_ <= signal_wire_9;
    end
    assign signal_mux_47 = signal_or_3 ? lane$reg_busy : signal_const_38;
    assign signal_const_45 = 6'b000000;
    assign signal_mux_48 = signal_or_3 ? lane$reg_bit_count : signal_wire_18;
    assign signal_mux_49 = signal_and_7 ? signal_mux_48 : lane$reg_bit_count;
    assign signal_mux_50 = signal_or_4 ? lane$reg_bit_count : signal_mux_49;
    assign signal_wire_10 = signal_mux_50;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_bit_count <= signal_const_45;
        else
            lane$reg_bit_count <= signal_wire_10;
    end
    assign signal_sub_4 = lane$reg_bit_count - signal_const_10;
    assign signal_mux_51 = signal_or_3 ? lane$reg_bit_index : signal_const_45;
    assign signal_add_1 = lane$reg_bit_index + signal_const_10;
    assign signal_mux_52 = lane$reg_trailing ? signal_add_1 : lane$reg_bit_index;
    assign signal_mux_53 = signal_and_3 ? lane$reg_bit_index : signal_mux_52;
    assign signal_mux_54 = signal_and_5 ? signal_mux_53 : lane$reg_bit_index;
    assign signal_mux_55 = lane$reg_busy ? signal_mux_54 : lane$reg_bit_index;
    assign signal_mux_56 = signal_and_7 ? signal_mux_51 : signal_mux_55;
    assign signal_mux_57 = signal_or_4 ? lane$reg_bit_index : signal_mux_56;
    assign signal_wire_11 = signal_mux_57;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_bit_index <= signal_const_45;
        else
            lane$reg_bit_index <= signal_wire_11;
    end
    assign signal_eq_1 = lane$reg_bit_index == signal_sub_4;
    assign signal_mux_58 = signal_or_3 ? lane$reg_trailing : signal_const_13;
    assign signal_mux_59 = lane$reg_trailing ? signal_const_13 : signal_const_38;
    assign signal_mux_60 = signal_and_3 ? lane$reg_trailing : signal_mux_59;
    assign signal_mux_61 = signal_and_5 ? signal_mux_60 : lane$reg_trailing;
    assign signal_mux_62 = lane$reg_busy ? signal_mux_61 : lane$reg_trailing;
    assign signal_mux_63 = signal_and_7 ? signal_mux_58 : signal_mux_62;
    assign signal_mux_64 = signal_or_4 ? lane$reg_trailing : signal_mux_63;
    assign signal_wire_12 = signal_mux_64;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_trailing <= signal_const_13;
        else
            lane$reg_trailing <= signal_wire_12;
    end
    assign signal_and_3 = lane$reg_trailing & signal_eq_1;
    assign signal_mux_65 = signal_and_3 ? signal_const_13 : lane$reg_busy;
    assign signal_const_53 = 16'b0000000000000001;
    assign signal_const_54 = 16'b0000000000000000;
    assign signal_mux_66 = signal_or_3 ? lane$reg_remaining : signal_wire_16;
    assign signal_mux_67 = signal_or_3 ? lane$reg_half_period : signal_wire_16;
    assign signal_mux_68 = signal_and_7 ? signal_mux_67 : lane$reg_half_period;
    assign signal_mux_69 = signal_or_4 ? lane$reg_half_period : signal_mux_68;
    assign signal_wire_13 = signal_mux_69;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_half_period <= signal_const_54;
        else
            lane$reg_half_period <= signal_wire_13;
    end
    assign signal_not_2 = ~ lane$reg_observed;
    assign signal_mux_70 = signal_not_2 ? lane$reg_half_period : signal_mux_71;
    assign signal_sub_5 = lane$reg_remaining - signal_const_53;
    assign signal_not_3 = ~ signal_and_5;
    assign signal_not_4 = ~ lane$reg_observed;
    assign signal_and_4 = signal_not_4 & signal_not_3;
    assign signal_mux_71 = signal_and_4 ? signal_sub_5 : lane$reg_remaining;
    assign signal_mux_72 = signal_and_5 ? signal_mux_70 : signal_mux_71;
    assign signal_mux_73 = lane$reg_busy ? signal_mux_72 : lane$reg_remaining;
    assign signal_mux_74 = signal_and_7 ? signal_mux_66 : signal_mux_73;
    assign signal_mux_75 = signal_or_4 ? signal_const_54 : signal_mux_74;
    assign signal_wire_14 = signal_mux_75;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_remaining <= signal_const_54;
        else
            lane$reg_remaining <= signal_wire_14;
    end
    assign signal_eq_2 = lane$reg_remaining == signal_const_53;
    assign signal_mux_76 = signal_or_3 ? lane$reg_observed : gnd;
    assign signal_mux_77 = signal_and_7 ? signal_mux_76 : lane$reg_observed;
    assign signal_mux_78 = signal_or_4 ? lane$reg_observed : signal_mux_77;
    assign signal_wire_15 = signal_mux_78;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_observed <= signal_const_13;
        else
            lane$reg_observed <= signal_wire_15;
    end
    assign signal_mux_79 = lane$reg_observed ? gnd : signal_eq_2;
    assign signal_and_5 = lane$reg_busy & signal_mux_79;
    assign signal_mux_80 = signal_and_5 ? signal_mux_65 : lane$reg_busy;
    assign signal_mux_81 = lane$reg_busy ? signal_mux_80 : lane$reg_busy;
    assign signal_wire_16 = half_period_i;
    assign signal_eq_3 = signal_wire_16 == signal_const_54;
    assign signal_select_33 = signal_mux_85[31:16];
    assign signal_cat = { signal_const_54,
                          signal_select_33 };
    assign signal_select_34 = signal_mux_84[31:8];
    assign signal_cat_1 = { signal_const,
                            signal_select_34 };
    assign signal_select_35 = signal_mux_83[31:4];
    assign signal_const_66 = 4'b0000;
    assign signal_cat_2 = { signal_const_66,
                            signal_select_35 };
    assign signal_select_36 = signal_mux_82[31:2];
    assign signal_const_67 = 2'b00;
    assign signal_cat_3 = { signal_const_67,
                            signal_select_36 };
    assign signal_select_37 = signal_wire_17[31:1];
    assign signal_cat_4 = { signal_const_13,
                            signal_select_37 };
    assign signal_wire_17 = transfer_data_i;
    assign signal_select_38 = signal_wire_18[0:0];
    assign signal_mux_82 = signal_select_38 ? signal_cat_4 : signal_wire_17;
    assign signal_select_39 = signal_wire_18[1:1];
    assign signal_mux_83 = signal_select_39 ? signal_cat_3 : signal_mux_82;
    assign signal_select_40 = signal_wire_18[2:2];
    assign signal_mux_84 = signal_select_40 ? signal_cat_2 : signal_mux_83;
    assign signal_select_41 = signal_wire_18[3:3];
    assign signal_mux_85 = signal_select_41 ? signal_cat_1 : signal_mux_84;
    assign signal_select_42 = signal_wire_18[4:4];
    assign signal_mux_86 = signal_select_42 ? signal_cat : signal_mux_85;
    assign signal_select_43 = signal_wire_18[5:5];
    assign signal_mux_87 = signal_select_43 ? signal_const_9 : signal_mux_86;
    assign signal_eq_4 = signal_mux_87 == signal_const_9;
    assign signal_not_5 = ~ signal_eq_4;
    assign signal_const_69 = 6'b100000;
    assign signal_lt = signal_const_69 < signal_wire_18;
    assign signal_wire_18 = transfer_count_i;
    assign signal_eq_5 = signal_wire_18 == signal_const_45;
    assign signal_or_1 = signal_eq_5 | signal_lt;
    assign signal_or_2 = signal_or_1 | signal_not_5;
    assign signal_or_3 = signal_or_2 | signal_eq_3;
    assign signal_mux_88 = signal_or_3 ? lane$reg_armed : gnd;
    assign signal_mux_89 = signal_and_7 ? signal_mux_88 : lane$reg_armed;
    assign signal_mux_90 = signal_or_4 ? signal_const_13 : signal_mux_89;
    assign signal_wire_19 = signal_mux_90;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_armed <= signal_const_13;
        else
            lane$reg_armed <= signal_wire_19;
    end
    assign signal_not_6 = ~ lane$reg_armed;
    assign signal_not_7 = ~ lane$reg_busy;
    assign signal_wire_20 = transfer_valid_i;
    assign signal_and_6 = signal_wire_20 & signal_not_7;
    assign signal_and_7 = signal_and_6 & signal_not_6;
    assign signal_mux_91 = signal_and_7 ? signal_mux_47 : signal_mux_81;
    assign signal_not_8 = ~ signal_wire_33;
    assign signal_or_4 = signal_not_8 | signal_wire_32;
    assign signal_mux_92 = signal_or_4 ? signal_const_13 : signal_mux_91;
    assign signal_wire_21 = signal_mux_92;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            lane$reg_busy <= signal_const_13;
        else
            lane$reg_busy <= signal_wire_21;
    end
    assign signal_eq_6 = timing$reg_kind == signal_const_67;
    assign signal_mux_93 = signal_eq_6 ? signal_const_38 : signal_const_13;
    assign signal_mux_94 = signal_and_8 ? signal_mux_93 : signal_const_13;
    assign signal_mux_95 = signal_mux_125 ? signal_const_38 : signal_mux_94;
    assign signal_mux_96 = timing$reg_busy ? signal_mux_95 : signal_const_13;
    assign signal_mux_97 = signal_or_7 ? signal_const_13 : signal_mux_96;
    assign signal_wire_22 = signal_mux_97;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            timing$reg_complete <= signal_const_13;
        else
            timing$reg_complete <= signal_wire_22;
    end
    assign signal_sub_6 = timing$reg_remaining - signal_const_53;
    assign signal_eq_7 = timing$reg_kind == signal_const_67;
    assign signal_or_5 = signal_eq_7 | timing$reg_timeout_enable;
    assign signal_mux_98 = signal_or_5 ? signal_sub_6 : timing$reg_remaining;
    assign signal_mux_99 = signal_and_8 ? signal_const_54 : signal_mux_98;
    assign signal_mux_100 = signal_mux_125 ? signal_const_54 : signal_mux_99;
    assign signal_mux_101 = signal_eq_11 ? timing$reg_remaining : signal_wire_30;
    assign signal_mux_102 = signal_wire_31 ? signal_mux_101 : timing$reg_remaining;
    assign signal_mux_103 = timing$reg_busy ? signal_mux_100 : signal_mux_102;
    assign signal_mux_104 = signal_or_7 ? signal_const_54 : signal_mux_103;
    assign signal_wire_23 = signal_mux_104;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            timing$reg_remaining <= signal_const_54;
        else
            timing$reg_remaining <= signal_wire_23;
    end
    assign signal_eq_8 = timing$reg_remaining == signal_const_53;
    assign signal_mux_105 = signal_eq_11 ? timing$reg_timeout_enable : gnd;
    assign signal_mux_106 = signal_wire_31 ? signal_mux_105 : timing$reg_timeout_enable;
    assign signal_mux_107 = timing$reg_busy ? timing$reg_timeout_enable : signal_mux_106;
    assign signal_mux_108 = signal_or_7 ? timing$reg_timeout_enable : signal_mux_107;
    assign signal_wire_24 = signal_mux_108;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            timing$reg_timeout_enable <= signal_const_13;
        else
            timing$reg_timeout_enable <= signal_wire_24;
    end
    assign signal_eq_9 = timing$reg_kind == signal_const_67;
    assign signal_or_6 = signal_eq_9 | timing$reg_timeout_enable;
    assign signal_and_8 = signal_or_6 & signal_eq_8;
    assign signal_mux_109 = signal_and_8 ? signal_const_13 : timing$reg_busy;
    always @* begin
        case (timing$reg_pin)
        0:
            signal_mux_110 <= signal_const_13;
        1:
            signal_mux_110 <= signal_const_13;
        2:
            signal_mux_110 <= signal_const_13;
        3:
            signal_mux_110 <= signal_const_13;
        4:
            signal_mux_110 <= signal_const_13;
        5:
            signal_mux_110 <= signal_const_13;
        6:
            signal_mux_110 <= signal_const_13;
        default:
            signal_mux_110 <= signal_const_13;
        endcase
    end
    always @* begin
        case (timing$reg_pin)
        0:
            signal_mux_111 <= signal_const_13;
        1:
            signal_mux_111 <= signal_const_13;
        2:
            signal_mux_111 <= signal_const_13;
        3:
            signal_mux_111 <= signal_const_13;
        4:
            signal_mux_111 <= signal_const_13;
        5:
            signal_mux_111 <= signal_const_13;
        6:
            signal_mux_111 <= signal_const_13;
        default:
            signal_mux_111 <= signal_const_13;
        endcase
    end
    assign signal_mux_112 = signal_eq_11 ? timing$reg_level : gnd;
    assign signal_mux_113 = signal_wire_31 ? signal_mux_112 : timing$reg_level;
    assign signal_mux_114 = timing$reg_busy ? timing$reg_level : signal_mux_113;
    assign signal_mux_115 = signal_or_7 ? timing$reg_level : signal_mux_114;
    assign signal_wire_25 = signal_mux_115;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            timing$reg_level <= signal_const_13;
        else
            timing$reg_level <= signal_wire_25;
    end
    assign signal_mux_116 = signal_eq_11 ? timing$reg_pin : signal_const_22;
    assign signal_mux_117 = signal_wire_31 ? signal_mux_116 : timing$reg_pin;
    assign signal_mux_118 = timing$reg_busy ? timing$reg_pin : signal_mux_117;
    assign signal_mux_119 = signal_or_7 ? timing$reg_pin : signal_mux_118;
    assign signal_wire_26 = signal_mux_119;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            timing$reg_pin <= signal_const_22;
        else
            timing$reg_pin <= signal_wire_26;
    end
    always @* begin
        case (timing$reg_pin)
        0:
            signal_mux_120 <= signal_const_13;
        1:
            signal_mux_120 <= signal_const_13;
        2:
            signal_mux_120 <= signal_const_13;
        3:
            signal_mux_120 <= signal_const_13;
        4:
            signal_mux_120 <= signal_const_13;
        5:
            signal_mux_120 <= signal_const_13;
        6:
            signal_mux_120 <= signal_const_13;
        default:
            signal_mux_120 <= signal_const_13;
        endcase
    end
    assign signal_eq_10 = signal_mux_120 == timing$reg_level;
    assign gnd = 1'b0;
    assign signal_wire_27 = reset_i;
    assign signal_wire_28 = clock_i;
    assign signal_mux_121 = signal_eq_11 ? timing$reg_kind : signal_const_67;
    assign signal_mux_122 = signal_wire_31 ? signal_mux_121 : timing$reg_kind;
    assign signal_mux_123 = timing$reg_busy ? timing$reg_kind : signal_mux_122;
    assign signal_mux_124 = signal_or_7 ? timing$reg_kind : signal_mux_123;
    assign signal_wire_29 = signal_mux_124;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            timing$reg_kind <= signal_const_67;
        else
            timing$reg_kind <= signal_wire_29;
    end
    always @* begin
        case (timing$reg_kind)
        0:
            signal_mux_125 <= gnd;
        1:
            signal_mux_125 <= signal_eq_10;
        2:
            signal_mux_125 <= signal_mux_111;
        default:
            signal_mux_125 <= signal_mux_110;
        endcase
    end
    assign signal_mux_126 = signal_mux_125 ? signal_const_13 : signal_mux_109;
    assign signal_wire_30 = wait_delay_i;
    assign signal_eq_11 = signal_wire_30 == signal_const_54;
    assign signal_mux_127 = signal_eq_11 ? timing$reg_busy : signal_const_38;
    assign signal_wire_31 = wait_valid_i;
    assign signal_mux_128 = signal_wire_31 ? signal_mux_127 : timing$reg_busy;
    assign signal_mux_129 = timing$reg_busy ? signal_mux_126 : signal_mux_128;
    assign signal_wire_32 = abort_i;
    assign signal_wire_33 = enable_i;
    assign signal_not_9 = ~ signal_wire_33;
    assign signal_or_7 = signal_not_9 | signal_wire_32;
    assign signal_mux_130 = signal_or_7 ? signal_const_13 : signal_mux_129;
    assign signal_wire_34 = signal_mux_130;
    always @(posedge signal_wire_28) begin
        if (signal_wire_27)
            timing$reg_busy <= signal_const_13;
        else
            timing$reg_busy <= signal_wire_34;
    end
    assign wait_busy_o = timing$reg_busy;
    assign wait_complete_o = timing$reg_complete;
    assign transfer_busy_o = lane$reg_busy;
    assign transfer_done_o = lane$reg_done_;
    assign pins_o = lane$reg_pin_value;
    assign pin_oe_o = lane$reg_pin_oe;

endmodule
