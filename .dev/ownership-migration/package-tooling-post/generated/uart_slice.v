module uart_slice (
    clock_i,
    reset_i,
    enable_i,
    abort_i,
    start_i,
    byte_i,
    half_period_i,
    tx_pin_i,
    ready_o,
    busy_o,
    frame_done_o,
    gap_busy_o,
    pins_o,
    pin_oe_o,
    engine_claim_o,
    software_claim_o,
    bank_rejected_o,
    bank_conflict_o
);

    input clock_i;
    input reset_i;
    input enable_i;
    input abort_i;
    input start_i;
    input [7:0] byte_i;
    input [15:0] half_period_i;
    input [2:0] tx_pin_i;
    output ready_o;
    output busy_o;
    output frame_done_o;
    output gap_busy_o;
    output [7:0] pins_o;
    output [7:0] pin_oe_o;
    output [7:0] engine_claim_o;
    output [7:0] software_claim_o;
    output bank_rejected_o;
    output bank_conflict_o;

    wire signal_const;
    wire signal_const_1;
    wire signal_and;
    wire signal_and_1;
    wire signal_or;
    wire signal_mux;
    wire signal_mux_1;
    wire signal_mux_2;
    wire signal_wire;
    reg bank$reg_conflict;
    wire signal_mux_3;
    wire signal_mux_4;
    wire signal_wire_1;
    reg bank$reg_rejected;
    wire [7:0] signal_const_5;
    wire [7:0] signal_mux_5;
    wire [7:0] signal_mux_6;
    wire [7:0] signal_mux_7;
    wire [7:0] signal_mux_8;
    wire [7:0] signal_mux_9;
    wire [7:0] signal_mux_10;
    wire [7:0] signal_wire_2;
    reg [7:0] uart$lane$reg_pin_oe;
    wire [7:0] signal_mux_11;
    wire [7:0] signal_mux_12;
    wire [7:0] signal_and_2;
    wire [7:0] signal_not;
    wire [7:0] signal_and_3;
    wire [7:0] signal_or_1;
    wire [7:0] signal_mux_13;
    wire [7:0] signal_mux_14;
    wire [7:0] signal_mux_15;
    wire [7:0] signal_wire_3;
    reg [7:0] bank$reg_pin_oe;
    wire [7:0] signal_const_15;
    wire [7:0] signal_const_16;
    wire [7:0] signal_const_17;
    wire [7:0] signal_const_18;
    wire [7:0] signal_const_19;
    wire [7:0] signal_const_20;
    wire [7:0] signal_const_21;
    wire [7:0] signal_const_22;
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
    wire [31:0] signal_const_25;
    wire [31:0] signal_mux_19;
    wire [31:0] signal_mux_20;
    wire [31:0] signal_mux_21;
    wire [31:0] signal_wire_4;
    reg [31:0] uart$lane$reg_tx_value;
    wire signal_select_32;
    wire [5:0] signal_const_26;
    wire [5:0] signal_add;
    wire [5:0] signal_const_27;
    wire [5:0] signal_sub;
    wire [5:0] signal_sub_1;
    wire [5:0] signal_mux_22;
    wire [5:0] signal_sub_2;
    wire [5:0] signal_sub_3;
    wire signal_mux_23;
    wire signal_mux_24;
    wire signal_mux_25;
    wire signal_wire_5;
    reg uart$lane$reg_lsb_first;
    wire [5:0] signal_mux_26;
    wire [5:0] signal_mux_27;
    reg signal_mux_28;
    wire [7:0] signal_mux_29;
    wire [2:0] signal_const_38;
    wire [2:0] signal_mux_30;
    wire [2:0] signal_mux_31;
    wire [2:0] signal_mux_32;
    wire [2:0] signal_wire_6;
    reg [2:0] uart$lane$reg_output_pin;
    reg [7:0] signal_mux_33;
    wire [7:0] signal_not_1;
    wire [7:0] signal_and_4;
    wire [7:0] signal_or_2;
    wire [2:0] signal_mux_34;
    wire [2:0] signal_mux_35;
    wire [2:0] signal_mux_36;
    wire [2:0] signal_wire_7;
    reg [2:0] uart$lane$reg_clock_pin;
    reg [7:0] signal_mux_37;
    wire [7:0] signal_xor;
    wire signal_mux_38;
    wire signal_mux_39;
    wire signal_mux_40;
    wire signal_wire_8;
    reg uart$lane$reg_clock_enable;
    wire [7:0] signal_mux_41;
    wire signal_not_2;
    wire signal_mux_42;
    wire signal_mux_43;
    wire signal_mux_44;
    wire signal_wire_9;
    reg uart$lane$reg_tx_enable;
    wire vdd;
    wire signal_mux_45;
    wire signal_mux_46;
    wire signal_mux_47;
    wire signal_wire_10;
    reg uart$lane$reg_launch_trailing;
    wire signal_eq;
    wire signal_and_5;
    wire signal_and_6;
    wire [7:0] signal_mux_48;
    wire [7:0] signal_mux_49;
    wire [7:0] signal_mux_50;
    wire [7:0] signal_mux_51;
    wire [7:0] signal_mux_52;
    wire [7:0] signal_wire_11;
    reg [7:0] uart$lane$reg_pin_value;
    reg [7:0] signal_mux_53;
    wire [7:0] signal_mux_54;
    wire signal_not_3;
    wire signal_not_4;
    wire signal_and_7;
    wire signal_and_8;
    wire [7:0] signal_mux_55;
    wire [7:0] signal_and_9;
    wire [7:0] signal_not_5;
    wire [7:0] signal_and_10;
    wire [7:0] signal_or_3;
    wire [7:0] signal_mux_56;
    wire [7:0] signal_and_11;
    wire signal_eq_1;
    wire signal_not_6;
    wire signal_and_12;
    wire [7:0] signal_not_7;
    wire [7:0] signal_and_13;
    wire [7:0] signal_or_4;
    wire [7:0] signal_mux_57;
    wire [7:0] signal_mux_58;
    wire [7:0] signal_mux_59;
    wire [7:0] signal_mux_60;
    wire [7:0] signal_wire_12;
    reg [7:0] bank$reg_engine_claim;
    wire [7:0] signal_not_8;
    wire [2:0] signal_mux_61;
    reg [2:0] signal_cases;
    wire [2:0] signal_wire_13;
    reg [2:0] reg_tx_pin;
    reg [7:0] signal_mux_62;
    wire [7:0] signal_and_14;
    wire signal_eq_2;
    wire signal_not_9;
    wire signal_and_15;
    wire [7:0] signal_mux_63;
    wire [7:0] signal_mux_64;
    wire [7:0] signal_mux_65;
    wire [7:0] signal_mux_66;
    wire [7:0] signal_wire_14;
    reg [7:0] bank$reg_software_claim;
    wire [2:0] signal_wire_15;
    reg [7:0] signal_mux_67;
    wire [7:0] signal_and_16;
    wire signal_eq_3;
    wire signal_not_10;
    wire signal_and_17;
    wire signal_and_18;
    reg signal_cases_1;
    wire signal_mux_68;
    wire wire_write_valid;
    reg signal_cases_2;
    wire signal_mux_69;
    wire wire_release_valid;
    wire signal_or_5;
    wire signal_mux_70;
    reg signal_cases_3;
    wire signal_mux_71;
    wire wire_claim_valid;
    wire signal_and_19;
    wire signal_or_6;
    wire signal_or_7;
    wire signal_or_8;
    wire signal_or_9;
    wire [7:0] signal_mux_72;
    wire signal_not_11;
    wire signal_or_10;
    wire [7:0] signal_mux_73;
    wire [7:0] signal_wire_16;
    reg [7:0] bank$reg_pins;
    reg signal_cases_4;
    wire signal_mux_74;
    wire wire_frame_done;
    wire signal_eq_4;
    wire signal_not_12;
    wire [2:0] signal_const_103;
    wire signal_mux_75;
    wire signal_mux_76;
    wire signal_mux_77;
    wire signal_mux_78;
    wire signal_mux_79;
    wire signal_mux_80;
    wire signal_wire_17;
    reg uart$lane$reg_armed;
    wire signal_not_13;
    wire signal_mux_81;
    wire [5:0] signal_const_114;
    wire [5:0] signal_const_115;
    wire [5:0] signal_mux_82;
    wire [5:0] signal_mux_83;
    wire [5:0] signal_mux_84;
    wire [5:0] signal_wire_18;
    reg [5:0] uart$lane$reg_bit_count;
    wire [5:0] signal_sub_4;
    wire [5:0] signal_mux_85;
    wire [5:0] signal_add_1;
    wire [5:0] signal_mux_86;
    wire [5:0] signal_mux_87;
    wire [5:0] signal_mux_88;
    wire [5:0] signal_mux_89;
    wire [5:0] signal_mux_90;
    wire [5:0] signal_mux_91;
    wire [5:0] signal_wire_19;
    reg [5:0] uart$lane$reg_bit_index;
    wire signal_eq_5;
    wire signal_mux_92;
    wire signal_mux_93;
    wire signal_mux_94;
    wire signal_mux_95;
    wire signal_mux_96;
    wire signal_mux_97;
    wire signal_mux_98;
    wire signal_wire_20;
    reg uart$lane$reg_trailing;
    wire signal_and_20;
    wire signal_mux_99;
    wire [15:0] signal_const_123;
    wire [15:0] signal_const_124;
    wire [15:0] signal_mux_100;
    wire [15:0] signal_mux_101;
    wire [15:0] signal_mux_102;
    wire [15:0] signal_mux_103;
    wire [15:0] signal_wire_21;
    reg [15:0] uart$lane$reg_half_period;
    wire signal_not_14;
    wire [15:0] signal_mux_104;
    wire [15:0] signal_sub_5;
    wire signal_not_15;
    wire signal_not_16;
    wire signal_and_21;
    wire [15:0] signal_mux_105;
    wire [15:0] signal_mux_106;
    wire [15:0] signal_mux_107;
    wire [15:0] signal_mux_108;
    wire [15:0] signal_mux_109;
    wire [15:0] signal_wire_22;
    reg [15:0] uart$lane$reg_remaining;
    wire signal_eq_6;
    wire signal_eq_7;
    wire [7:0] signal_wire_23;
    wire [7:0] signal_mux_110;
    reg [7:0] signal_cases_5;
    wire [7:0] signal_wire_24;
    reg [7:0] reg_byte;
    wire [22:0] signal_const_132;
    wire [31:0] signal_cat;
    wire [29:0] signal_select_33;
    wire [1:0] signal_const_133;
    wire [31:0] signal_cat_1;
    wire [23:0] signal_select_34;
    wire [31:0] signal_cat_2;
    wire signal_eq_8;
    wire signal_not_17;
    wire signal_or_11;
    wire signal_mux_111;
    wire signal_mux_112;
    wire signal_mux_113;
    wire signal_wire_25;
    reg uart$lane$reg_observed;
    wire signal_mux_114;
    wire signal_and_22;
    wire signal_mux_115;
    wire signal_mux_116;
    wire signal_mux_117;
    wire signal_mux_118;
    wire signal_wire_26;
    reg uart$lane$reg_busy;
    wire signal_not_18;
    reg signal_cases_6;
    wire signal_mux_119;
    wire wire_byte_valid;
    wire signal_and_23;
    wire signal_and_24;
    wire signal_mux_120;
    wire signal_not_19;
    wire signal_or_12;
    wire signal_mux_121;
    wire signal_wire_27;
    reg uart$lane$reg_done_;
    wire [2:0] signal_mux_122;
    wire [2:0] signal_const_138;
    wire [2:0] signal_const_139;
    wire signal_eq_9;
    wire signal_mux_123;
    wire signal_mux_124;
    wire signal_mux_125;
    wire [15:0] signal_sub_6;
    wire signal_eq_10;
    wire signal_or_13;
    wire [15:0] signal_mux_126;
    wire [15:0] signal_mux_127;
    wire [15:0] signal_mux_128;
    wire [15:0] signal_mux_129;
    wire [15:0] signal_mux_130;
    wire [15:0] signal_mux_131;
    wire [15:0] signal_mux_132;
    wire [15:0] signal_wire_28;
    reg [15:0] timing$reg_remaining;
    wire signal_eq_11;
    wire signal_mux_133;
    wire signal_mux_134;
    wire signal_mux_135;
    wire signal_mux_136;
    wire signal_wire_29;
    reg timing$reg_timeout_enable;
    wire signal_eq_12;
    wire signal_or_14;
    wire signal_and_25;
    wire signal_mux_137;
    reg signal_mux_138;
    reg signal_mux_139;
    wire signal_mux_140;
    wire signal_mux_141;
    wire signal_mux_142;
    wire signal_mux_143;
    wire signal_wire_30;
    reg timing$reg_level;
    wire [2:0] signal_mux_144;
    wire [2:0] signal_mux_145;
    wire [2:0] signal_mux_146;
    wire [2:0] signal_mux_147;
    wire [2:0] signal_wire_31;
    reg [2:0] timing$reg_pin;
    reg signal_mux_148;
    wire signal_eq_13;
    wire [1:0] signal_mux_149;
    wire [1:0] signal_mux_150;
    wire [1:0] signal_mux_151;
    wire [1:0] signal_mux_152;
    wire [1:0] signal_wire_32;
    reg [1:0] timing$reg_kind;
    reg signal_mux_153;
    wire signal_mux_154;
    wire gnd;
    wire signal_wire_33;
    wire signal_wire_34;
    wire [15:0] signal_wire_35;
    wire [15:0] signal_mux_155;
    reg [15:0] signal_cases_7;
    wire [15:0] signal_wire_36;
    reg [15:0] reg_half_period;
    wire [14:0] signal_select_35;
    wire [15:0] signal_cat_3;
    wire signal_eq_14;
    wire signal_mux_156;
    reg signal_cases_8;
    wire signal_mux_157;
    wire wire_wait_valid;
    wire signal_mux_158;
    wire signal_mux_159;
    wire signal_mux_160;
    wire signal_wire_37;
    reg timing$reg_busy;
    wire signal_mux_161;
    wire signal_not_20;
    wire signal_or_15;
    wire signal_mux_162;
    wire signal_wire_38;
    reg timing$reg_complete;
    wire [2:0] signal_mux_163;
    wire [2:0] signal_const_193;
    wire [2:0] signal_const_194;
    wire signal_not_21;
    wire signal_wire_39;
    wire signal_and_26;
    wire [2:0] signal_mux_164;
    reg [2:0] signal_cases_9;
    wire [2:0] signal_mux_165;
    wire [2:0] signal_wire_40;
    (* fsm_encoding="one_hot" *)
    reg [2:0] signal_reg;
    reg signal_cases_10;
    wire signal_wire_41;
    wire signal_wire_42;
    wire signal_not_22;
    wire signal_or_16;
    wire signal_mux_166;
    wire wire_ready;
    assign signal_const = 1'b0;
    assign signal_const_1 = 1'b1;
    assign signal_and = wire_write_valid & signal_not_6;
    assign signal_and_1 = wire_claim_valid & signal_not_10;
    assign signal_or = signal_and_1 | signal_and;
    assign signal_mux = signal_or ? signal_const_1 : bank$reg_conflict;
    assign signal_mux_1 = signal_or_9 ? signal_mux : bank$reg_conflict;
    assign signal_mux_2 = signal_or_10 ? bank$reg_conflict : signal_mux_1;
    assign signal_wire = signal_mux_2;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            bank$reg_conflict <= signal_const;
        else
            bank$reg_conflict <= signal_wire;
    end
    assign signal_mux_3 = signal_or_9 ? signal_const_1 : signal_const;
    assign signal_mux_4 = signal_or_10 ? signal_const : signal_mux_3;
    assign signal_wire_1 = signal_mux_4;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            bank$reg_rejected <= signal_const;
        else
            bank$reg_rejected <= signal_wire_1;
    end
    assign signal_const_5 = 8'b00000000;
    assign signal_mux_5 = signal_or_11 ? uart$lane$reg_pin_oe : signal_mux_16;
    assign signal_mux_6 = signal_and_20 ? signal_const_5 : uart$lane$reg_pin_oe;
    assign signal_mux_7 = signal_and_22 ? signal_mux_6 : uart$lane$reg_pin_oe;
    assign signal_mux_8 = uart$lane$reg_busy ? signal_mux_7 : uart$lane$reg_pin_oe;
    assign signal_mux_9 = signal_and_24 ? signal_mux_5 : signal_mux_8;
    assign signal_mux_10 = signal_or_12 ? signal_const_5 : signal_mux_9;
    assign signal_wire_2 = signal_mux_10;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_pin_oe <= signal_const_5;
        else
            uart$lane$reg_pin_oe <= signal_wire_2;
    end
    assign signal_mux_11 = uart$lane$reg_busy ? uart$lane$reg_pin_oe : signal_mux_53;
    assign signal_mux_12 = signal_and_8 ? signal_mux_11 : signal_const_5;
    assign signal_and_2 = signal_mux_12 & signal_mux_62;
    assign signal_not = ~ signal_mux_62;
    assign signal_and_3 = bank$reg_pin_oe & signal_not;
    assign signal_or_1 = signal_and_3 | signal_and_2;
    assign signal_mux_13 = wire_write_valid ? signal_or_1 : bank$reg_pin_oe;
    assign signal_mux_14 = signal_or_9 ? bank$reg_pin_oe : signal_mux_13;
    assign signal_mux_15 = signal_or_10 ? signal_const_5 : signal_mux_14;
    assign signal_wire_3 = signal_mux_15;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            bank$reg_pin_oe <= signal_const_5;
        else
            bank$reg_pin_oe <= signal_wire_3;
    end
    assign signal_const_15 = 8'b10000000;
    assign signal_const_16 = 8'b01000000;
    assign signal_const_17 = 8'b00100000;
    assign signal_const_18 = 8'b00010000;
    assign signal_const_19 = 8'b00001000;
    assign signal_const_20 = 8'b00000100;
    assign signal_const_21 = 8'b00000010;
    assign signal_const_22 = 8'b00000001;
    always @* begin
        case (reg_tx_pin)
        0:
            signal_mux_16 <= signal_const_22;
        1:
            signal_mux_16 <= signal_const_21;
        2:
            signal_mux_16 <= signal_const_20;
        3:
            signal_mux_16 <= signal_const_19;
        4:
            signal_mux_16 <= signal_const_18;
        5:
            signal_mux_16 <= signal_const_17;
        6:
            signal_mux_16 <= signal_const_16;
        default:
            signal_mux_16 <= signal_const_15;
        endcase
    end
    assign signal_select = signal_cat[0:0];
    assign signal_mux_17 = signal_select ? signal_mux_16 : signal_const_5;
    assign signal_mux_18 = signal_or_11 ? uart$lane$reg_pin_value : signal_mux_17;
    assign signal_select_1 = uart$lane$reg_tx_value[31:31];
    assign signal_select_2 = uart$lane$reg_tx_value[30:30];
    assign signal_select_3 = uart$lane$reg_tx_value[29:29];
    assign signal_select_4 = uart$lane$reg_tx_value[28:28];
    assign signal_select_5 = uart$lane$reg_tx_value[27:27];
    assign signal_select_6 = uart$lane$reg_tx_value[26:26];
    assign signal_select_7 = uart$lane$reg_tx_value[25:25];
    assign signal_select_8 = uart$lane$reg_tx_value[24:24];
    assign signal_select_9 = uart$lane$reg_tx_value[23:23];
    assign signal_select_10 = uart$lane$reg_tx_value[22:22];
    assign signal_select_11 = uart$lane$reg_tx_value[21:21];
    assign signal_select_12 = uart$lane$reg_tx_value[20:20];
    assign signal_select_13 = uart$lane$reg_tx_value[19:19];
    assign signal_select_14 = uart$lane$reg_tx_value[18:18];
    assign signal_select_15 = uart$lane$reg_tx_value[17:17];
    assign signal_select_16 = uart$lane$reg_tx_value[16:16];
    assign signal_select_17 = uart$lane$reg_tx_value[15:15];
    assign signal_select_18 = uart$lane$reg_tx_value[14:14];
    assign signal_select_19 = uart$lane$reg_tx_value[13:13];
    assign signal_select_20 = uart$lane$reg_tx_value[12:12];
    assign signal_select_21 = uart$lane$reg_tx_value[11:11];
    assign signal_select_22 = uart$lane$reg_tx_value[10:10];
    assign signal_select_23 = uart$lane$reg_tx_value[9:9];
    assign signal_select_24 = uart$lane$reg_tx_value[8:8];
    assign signal_select_25 = uart$lane$reg_tx_value[7:7];
    assign signal_select_26 = uart$lane$reg_tx_value[6:6];
    assign signal_select_27 = uart$lane$reg_tx_value[5:5];
    assign signal_select_28 = uart$lane$reg_tx_value[4:4];
    assign signal_select_29 = uart$lane$reg_tx_value[3:3];
    assign signal_select_30 = uart$lane$reg_tx_value[2:2];
    assign signal_select_31 = uart$lane$reg_tx_value[1:1];
    assign signal_const_25 = 32'b00000000000000000000000000000000;
    assign signal_mux_19 = signal_or_11 ? uart$lane$reg_tx_value : signal_cat;
    assign signal_mux_20 = signal_and_24 ? signal_mux_19 : uart$lane$reg_tx_value;
    assign signal_mux_21 = signal_or_12 ? uart$lane$reg_tx_value : signal_mux_20;
    assign signal_wire_4 = signal_mux_21;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_tx_value <= signal_const_25;
        else
            uart$lane$reg_tx_value <= signal_wire_4;
    end
    assign signal_select_32 = uart$lane$reg_tx_value[0:0];
    assign signal_const_26 = 6'b000001;
    assign signal_add = uart$lane$reg_bit_index + signal_const_26;
    assign signal_const_27 = 6'b000010;
    assign signal_sub = uart$lane$reg_bit_count - signal_const_27;
    assign signal_sub_1 = signal_sub - uart$lane$reg_bit_index;
    assign signal_mux_22 = uart$lane$reg_lsb_first ? signal_add : signal_sub_1;
    assign signal_sub_2 = uart$lane$reg_bit_count - signal_const_26;
    assign signal_sub_3 = signal_sub_2 - uart$lane$reg_bit_index;
    assign signal_mux_23 = signal_or_11 ? uart$lane$reg_lsb_first : vdd;
    assign signal_mux_24 = signal_and_24 ? signal_mux_23 : uart$lane$reg_lsb_first;
    assign signal_mux_25 = signal_or_12 ? uart$lane$reg_lsb_first : signal_mux_24;
    assign signal_wire_5 = signal_mux_25;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_lsb_first <= signal_const;
        else
            uart$lane$reg_lsb_first <= signal_wire_5;
    end
    assign signal_mux_26 = uart$lane$reg_lsb_first ? uart$lane$reg_bit_index : signal_sub_3;
    assign signal_mux_27 = uart$lane$reg_launch_trailing ? signal_mux_22 : signal_mux_26;
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
    assign signal_mux_29 = signal_mux_28 ? signal_mux_33 : signal_const_5;
    assign signal_const_38 = 3'b000;
    assign signal_mux_30 = signal_or_11 ? uart$lane$reg_output_pin : reg_tx_pin;
    assign signal_mux_31 = signal_and_24 ? signal_mux_30 : uart$lane$reg_output_pin;
    assign signal_mux_32 = signal_or_12 ? uart$lane$reg_output_pin : signal_mux_31;
    assign signal_wire_6 = signal_mux_32;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_output_pin <= signal_const_38;
        else
            uart$lane$reg_output_pin <= signal_wire_6;
    end
    always @* begin
        case (uart$lane$reg_output_pin)
        0:
            signal_mux_33 <= signal_const_22;
        1:
            signal_mux_33 <= signal_const_21;
        2:
            signal_mux_33 <= signal_const_20;
        3:
            signal_mux_33 <= signal_const_19;
        4:
            signal_mux_33 <= signal_const_18;
        5:
            signal_mux_33 <= signal_const_17;
        6:
            signal_mux_33 <= signal_const_16;
        default:
            signal_mux_33 <= signal_const_15;
        endcase
    end
    assign signal_not_1 = ~ signal_mux_33;
    assign signal_and_4 = signal_mux_41 & signal_not_1;
    assign signal_or_2 = signal_and_4 | signal_mux_29;
    assign signal_mux_34 = signal_or_11 ? uart$lane$reg_clock_pin : signal_const_38;
    assign signal_mux_35 = signal_and_24 ? signal_mux_34 : uart$lane$reg_clock_pin;
    assign signal_mux_36 = signal_or_12 ? uart$lane$reg_clock_pin : signal_mux_35;
    assign signal_wire_7 = signal_mux_36;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_clock_pin <= signal_const_38;
        else
            uart$lane$reg_clock_pin <= signal_wire_7;
    end
    always @* begin
        case (uart$lane$reg_clock_pin)
        0:
            signal_mux_37 <= signal_const_22;
        1:
            signal_mux_37 <= signal_const_21;
        2:
            signal_mux_37 <= signal_const_20;
        3:
            signal_mux_37 <= signal_const_19;
        4:
            signal_mux_37 <= signal_const_18;
        5:
            signal_mux_37 <= signal_const_17;
        6:
            signal_mux_37 <= signal_const_16;
        default:
            signal_mux_37 <= signal_const_15;
        endcase
    end
    assign signal_xor = uart$lane$reg_pin_value ^ signal_mux_37;
    assign signal_mux_38 = signal_or_11 ? uart$lane$reg_clock_enable : gnd;
    assign signal_mux_39 = signal_and_24 ? signal_mux_38 : uart$lane$reg_clock_enable;
    assign signal_mux_40 = signal_or_12 ? uart$lane$reg_clock_enable : signal_mux_39;
    assign signal_wire_8 = signal_mux_40;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_clock_enable <= signal_const;
        else
            uart$lane$reg_clock_enable <= signal_wire_8;
    end
    assign signal_mux_41 = uart$lane$reg_clock_enable ? signal_xor : uart$lane$reg_pin_value;
    assign signal_not_2 = ~ signal_and_20;
    assign signal_mux_42 = signal_or_11 ? uart$lane$reg_tx_enable : vdd;
    assign signal_mux_43 = signal_and_24 ? signal_mux_42 : uart$lane$reg_tx_enable;
    assign signal_mux_44 = signal_or_12 ? uart$lane$reg_tx_enable : signal_mux_43;
    assign signal_wire_9 = signal_mux_44;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_tx_enable <= signal_const;
        else
            uart$lane$reg_tx_enable <= signal_wire_9;
    end
    assign vdd = 1'b1;
    assign signal_mux_45 = signal_or_11 ? uart$lane$reg_launch_trailing : vdd;
    assign signal_mux_46 = signal_and_24 ? signal_mux_45 : uart$lane$reg_launch_trailing;
    assign signal_mux_47 = signal_or_12 ? uart$lane$reg_launch_trailing : signal_mux_46;
    assign signal_wire_10 = signal_mux_47;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_launch_trailing <= signal_const;
        else
            uart$lane$reg_launch_trailing <= signal_wire_10;
    end
    assign signal_eq = uart$lane$reg_trailing == uart$lane$reg_launch_trailing;
    assign signal_and_5 = signal_eq & uart$lane$reg_tx_enable;
    assign signal_and_6 = signal_and_5 & signal_not_2;
    assign signal_mux_48 = signal_and_6 ? signal_or_2 : signal_mux_41;
    assign signal_mux_49 = signal_and_22 ? signal_mux_48 : uart$lane$reg_pin_value;
    assign signal_mux_50 = uart$lane$reg_busy ? signal_mux_49 : uart$lane$reg_pin_value;
    assign signal_mux_51 = signal_and_24 ? signal_mux_18 : signal_mux_50;
    assign signal_mux_52 = signal_or_12 ? signal_const_5 : signal_mux_51;
    assign signal_wire_11 = signal_mux_52;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_pin_value <= signal_const_5;
        else
            uart$lane$reg_pin_value <= signal_wire_11;
    end
    always @* begin
        case (reg_tx_pin)
        0:
            signal_mux_53 <= signal_const_22;
        1:
            signal_mux_53 <= signal_const_21;
        2:
            signal_mux_53 <= signal_const_20;
        3:
            signal_mux_53 <= signal_const_19;
        4:
            signal_mux_53 <= signal_const_18;
        5:
            signal_mux_53 <= signal_const_17;
        6:
            signal_mux_53 <= signal_const_16;
        default:
            signal_mux_53 <= signal_const_15;
        endcase
    end
    assign signal_mux_54 = uart$lane$reg_busy ? uart$lane$reg_pin_value : signal_mux_53;
    assign signal_not_3 = ~ signal_wire_41;
    assign signal_not_4 = ~ signal_wire_33;
    assign signal_and_7 = signal_wire_42 & signal_not_4;
    assign signal_and_8 = signal_and_7 & signal_not_3;
    assign signal_mux_55 = signal_and_8 ? signal_mux_54 : signal_const_5;
    assign signal_and_9 = signal_mux_55 & signal_mux_62;
    assign signal_not_5 = ~ signal_mux_62;
    assign signal_and_10 = bank$reg_pins & signal_not_5;
    assign signal_or_3 = signal_and_10 | signal_and_9;
    assign signal_mux_56 = wire_write_valid ? signal_or_3 : bank$reg_pins;
    assign signal_and_11 = signal_mux_62 & bank$reg_software_claim;
    assign signal_eq_1 = signal_and_11 == signal_const_5;
    assign signal_not_6 = ~ signal_eq_1;
    assign signal_and_12 = wire_write_valid & signal_not_6;
    assign signal_not_7 = ~ signal_mux_62;
    assign signal_and_13 = bank$reg_engine_claim & signal_not_7;
    assign signal_or_4 = bank$reg_engine_claim | signal_mux_67;
    assign signal_mux_57 = wire_claim_valid ? signal_or_4 : bank$reg_engine_claim;
    assign signal_mux_58 = wire_release_valid ? signal_and_13 : signal_mux_57;
    assign signal_mux_59 = signal_or_9 ? bank$reg_engine_claim : signal_mux_58;
    assign signal_mux_60 = signal_or_10 ? signal_const_5 : signal_mux_59;
    assign signal_wire_12 = signal_mux_60;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            bank$reg_engine_claim <= signal_const_5;
        else
            bank$reg_engine_claim <= signal_wire_12;
    end
    assign signal_not_8 = ~ bank$reg_engine_claim;
    assign signal_mux_61 = signal_and_26 ? signal_wire_15 : reg_tx_pin;
    always @* begin
        case (signal_reg)
        3'b000:
            signal_cases <= signal_mux_61;
        default:
            signal_cases <= reg_tx_pin;
        endcase
    end
    assign signal_wire_13 = signal_cases;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            reg_tx_pin <= signal_const_38;
        else
            reg_tx_pin <= signal_wire_13;
    end
    always @* begin
        case (reg_tx_pin)
        0:
            signal_mux_62 <= signal_const_22;
        1:
            signal_mux_62 <= signal_const_21;
        2:
            signal_mux_62 <= signal_const_20;
        3:
            signal_mux_62 <= signal_const_19;
        4:
            signal_mux_62 <= signal_const_18;
        5:
            signal_mux_62 <= signal_const_17;
        6:
            signal_mux_62 <= signal_const_16;
        default:
            signal_mux_62 <= signal_const_15;
        endcase
    end
    assign signal_and_14 = signal_mux_62 & signal_not_8;
    assign signal_eq_2 = signal_and_14 == signal_const_5;
    assign signal_not_9 = ~ signal_eq_2;
    assign signal_and_15 = wire_release_valid & signal_not_9;
    assign signal_mux_63 = wire_claim_valid ? bank$reg_software_claim : bank$reg_software_claim;
    assign signal_mux_64 = wire_release_valid ? signal_mux_63 : signal_mux_63;
    assign signal_mux_65 = signal_or_9 ? bank$reg_software_claim : signal_mux_64;
    assign signal_mux_66 = signal_or_10 ? signal_const_5 : signal_mux_65;
    assign signal_wire_14 = signal_mux_66;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            bank$reg_software_claim <= signal_const_5;
        else
            bank$reg_software_claim <= signal_wire_14;
    end
    assign signal_wire_15 = tx_pin_i;
    always @* begin
        case (signal_wire_15)
        0:
            signal_mux_67 <= signal_const_22;
        1:
            signal_mux_67 <= signal_const_21;
        2:
            signal_mux_67 <= signal_const_20;
        3:
            signal_mux_67 <= signal_const_19;
        4:
            signal_mux_67 <= signal_const_18;
        5:
            signal_mux_67 <= signal_const_17;
        6:
            signal_mux_67 <= signal_const_16;
        default:
            signal_mux_67 <= signal_const_15;
        endcase
    end
    assign signal_and_16 = signal_mux_67 & bank$reg_software_claim;
    assign signal_eq_3 = signal_and_16 == signal_const_5;
    assign signal_not_10 = ~ signal_eq_3;
    assign signal_and_17 = wire_claim_valid & signal_not_10;
    assign signal_and_18 = wire_release_valid & wire_write_valid;
    always @* begin
        case (signal_reg)
        3'b001:
            signal_cases_1 <= signal_const_1;
        3'b011:
            signal_cases_1 <= signal_const_1;
        3'b100:
            signal_cases_1 <= signal_const_1;
        default:
            signal_cases_1 <= signal_const;
        endcase
    end
    assign signal_mux_68 = signal_or_16 ? signal_const : signal_cases_1;
    assign wire_write_valid = signal_mux_68;
    always @* begin
        case (signal_reg)
        3'b101:
            signal_cases_2 <= signal_const_1;
        default:
            signal_cases_2 <= signal_const;
        endcase
    end
    assign signal_mux_69 = signal_or_16 ? signal_const : signal_cases_2;
    assign wire_release_valid = signal_mux_69;
    assign signal_or_5 = wire_release_valid | wire_write_valid;
    assign signal_mux_70 = signal_and_26 ? signal_const_1 : signal_const;
    always @* begin
        case (signal_reg)
        3'b000:
            signal_cases_3 <= signal_mux_70;
        default:
            signal_cases_3 <= signal_const;
        endcase
    end
    assign signal_mux_71 = signal_or_16 ? signal_const : signal_cases_3;
    assign wire_claim_valid = signal_mux_71;
    assign signal_and_19 = wire_claim_valid & signal_or_5;
    assign signal_or_6 = signal_and_19 | signal_and_18;
    assign signal_or_7 = signal_or_6 | signal_and_17;
    assign signal_or_8 = signal_or_7 | signal_and_15;
    assign signal_or_9 = signal_or_8 | signal_and_12;
    assign signal_mux_72 = signal_or_9 ? bank$reg_pins : signal_mux_56;
    assign signal_not_11 = ~ signal_wire_42;
    assign signal_or_10 = signal_not_11 | signal_wire_41;
    assign signal_mux_73 = signal_or_10 ? signal_const_5 : signal_mux_72;
    assign signal_wire_16 = signal_mux_73;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            bank$reg_pins <= signal_const_5;
        else
            bank$reg_pins <= signal_wire_16;
    end
    always @* begin
        case (signal_reg)
        3'b101:
            signal_cases_4 <= signal_const_1;
        default:
            signal_cases_4 <= signal_const;
        endcase
    end
    assign signal_mux_74 = signal_or_16 ? signal_const : signal_cases_4;
    assign wire_frame_done = signal_mux_74;
    assign signal_eq_4 = signal_const_38 == signal_reg;
    assign signal_not_12 = ~ signal_eq_4;
    assign signal_const_103 = 3'b101;
    assign signal_mux_75 = signal_and_20 ? signal_const_1 : signal_const;
    assign signal_mux_76 = signal_and_22 ? signal_mux_75 : signal_const;
    assign signal_mux_77 = uart$lane$reg_busy ? signal_mux_76 : signal_const;
    assign signal_mux_78 = signal_or_11 ? uart$lane$reg_armed : gnd;
    assign signal_mux_79 = signal_and_24 ? signal_mux_78 : uart$lane$reg_armed;
    assign signal_mux_80 = signal_or_12 ? signal_const : signal_mux_79;
    assign signal_wire_17 = signal_mux_80;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_armed <= signal_const;
        else
            uart$lane$reg_armed <= signal_wire_17;
    end
    assign signal_not_13 = ~ uart$lane$reg_armed;
    assign signal_mux_81 = signal_or_11 ? uart$lane$reg_busy : signal_const_1;
    assign signal_const_114 = 6'b000000;
    assign signal_const_115 = 6'b001010;
    assign signal_mux_82 = signal_or_11 ? uart$lane$reg_bit_count : signal_const_115;
    assign signal_mux_83 = signal_and_24 ? signal_mux_82 : uart$lane$reg_bit_count;
    assign signal_mux_84 = signal_or_12 ? uart$lane$reg_bit_count : signal_mux_83;
    assign signal_wire_18 = signal_mux_84;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_bit_count <= signal_const_114;
        else
            uart$lane$reg_bit_count <= signal_wire_18;
    end
    assign signal_sub_4 = uart$lane$reg_bit_count - signal_const_26;
    assign signal_mux_85 = signal_or_11 ? uart$lane$reg_bit_index : signal_const_114;
    assign signal_add_1 = uart$lane$reg_bit_index + signal_const_26;
    assign signal_mux_86 = uart$lane$reg_trailing ? signal_add_1 : uart$lane$reg_bit_index;
    assign signal_mux_87 = signal_and_20 ? uart$lane$reg_bit_index : signal_mux_86;
    assign signal_mux_88 = signal_and_22 ? signal_mux_87 : uart$lane$reg_bit_index;
    assign signal_mux_89 = uart$lane$reg_busy ? signal_mux_88 : uart$lane$reg_bit_index;
    assign signal_mux_90 = signal_and_24 ? signal_mux_85 : signal_mux_89;
    assign signal_mux_91 = signal_or_12 ? uart$lane$reg_bit_index : signal_mux_90;
    assign signal_wire_19 = signal_mux_91;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_bit_index <= signal_const_114;
        else
            uart$lane$reg_bit_index <= signal_wire_19;
    end
    assign signal_eq_5 = uart$lane$reg_bit_index == signal_sub_4;
    assign signal_mux_92 = signal_or_11 ? uart$lane$reg_trailing : signal_const;
    assign signal_mux_93 = uart$lane$reg_trailing ? signal_const : signal_const_1;
    assign signal_mux_94 = signal_and_20 ? uart$lane$reg_trailing : signal_mux_93;
    assign signal_mux_95 = signal_and_22 ? signal_mux_94 : uart$lane$reg_trailing;
    assign signal_mux_96 = uart$lane$reg_busy ? signal_mux_95 : uart$lane$reg_trailing;
    assign signal_mux_97 = signal_and_24 ? signal_mux_92 : signal_mux_96;
    assign signal_mux_98 = signal_or_12 ? uart$lane$reg_trailing : signal_mux_97;
    assign signal_wire_20 = signal_mux_98;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_trailing <= signal_const;
        else
            uart$lane$reg_trailing <= signal_wire_20;
    end
    assign signal_and_20 = uart$lane$reg_trailing & signal_eq_5;
    assign signal_mux_99 = signal_and_20 ? signal_const : uart$lane$reg_busy;
    assign signal_const_123 = 16'b0000000000000001;
    assign signal_const_124 = 16'b0000000000000000;
    assign signal_mux_100 = signal_or_11 ? uart$lane$reg_remaining : reg_half_period;
    assign signal_mux_101 = signal_or_11 ? uart$lane$reg_half_period : reg_half_period;
    assign signal_mux_102 = signal_and_24 ? signal_mux_101 : uart$lane$reg_half_period;
    assign signal_mux_103 = signal_or_12 ? uart$lane$reg_half_period : signal_mux_102;
    assign signal_wire_21 = signal_mux_103;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_half_period <= signal_const_124;
        else
            uart$lane$reg_half_period <= signal_wire_21;
    end
    assign signal_not_14 = ~ uart$lane$reg_observed;
    assign signal_mux_104 = signal_not_14 ? uart$lane$reg_half_period : signal_mux_105;
    assign signal_sub_5 = uart$lane$reg_remaining - signal_const_123;
    assign signal_not_15 = ~ signal_and_22;
    assign signal_not_16 = ~ uart$lane$reg_observed;
    assign signal_and_21 = signal_not_16 & signal_not_15;
    assign signal_mux_105 = signal_and_21 ? signal_sub_5 : uart$lane$reg_remaining;
    assign signal_mux_106 = signal_and_22 ? signal_mux_104 : signal_mux_105;
    assign signal_mux_107 = uart$lane$reg_busy ? signal_mux_106 : uart$lane$reg_remaining;
    assign signal_mux_108 = signal_and_24 ? signal_mux_100 : signal_mux_107;
    assign signal_mux_109 = signal_or_12 ? signal_const_124 : signal_mux_108;
    assign signal_wire_22 = signal_mux_109;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_remaining <= signal_const_124;
        else
            uart$lane$reg_remaining <= signal_wire_22;
    end
    assign signal_eq_6 = uart$lane$reg_remaining == signal_const_123;
    assign signal_eq_7 = reg_half_period == signal_const_124;
    assign signal_wire_23 = byte_i;
    assign signal_mux_110 = signal_and_26 ? signal_wire_23 : reg_byte;
    always @* begin
        case (signal_reg)
        3'b000:
            signal_cases_5 <= signal_mux_110;
        default:
            signal_cases_5 <= reg_byte;
        endcase
    end
    assign signal_wire_24 = signal_cases_5;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            reg_byte <= signal_const_5;
        else
            reg_byte <= signal_wire_24;
    end
    assign signal_const_132 = 23'b00000000000000000000001;
    assign signal_cat = { signal_const_132,
                          reg_byte,
                          gnd };
    assign signal_select_33 = signal_cat[31:2];
    assign signal_const_133 = 2'b00;
    assign signal_cat_1 = { signal_const_133,
                            signal_select_33 };
    assign signal_select_34 = signal_cat_1[31:8];
    assign signal_cat_2 = { signal_const_5,
                            signal_select_34 };
    assign signal_eq_8 = signal_cat_2 == signal_const_25;
    assign signal_not_17 = ~ signal_eq_8;
    assign signal_or_11 = signal_not_17 | signal_eq_7;
    assign signal_mux_111 = signal_or_11 ? uart$lane$reg_observed : gnd;
    assign signal_mux_112 = signal_and_24 ? signal_mux_111 : uart$lane$reg_observed;
    assign signal_mux_113 = signal_or_12 ? uart$lane$reg_observed : signal_mux_112;
    assign signal_wire_25 = signal_mux_113;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_observed <= signal_const;
        else
            uart$lane$reg_observed <= signal_wire_25;
    end
    assign signal_mux_114 = uart$lane$reg_observed ? gnd : signal_eq_6;
    assign signal_and_22 = uart$lane$reg_busy & signal_mux_114;
    assign signal_mux_115 = signal_and_22 ? signal_mux_99 : uart$lane$reg_busy;
    assign signal_mux_116 = uart$lane$reg_busy ? signal_mux_115 : uart$lane$reg_busy;
    assign signal_mux_117 = signal_and_24 ? signal_mux_81 : signal_mux_116;
    assign signal_mux_118 = signal_or_12 ? signal_const : signal_mux_117;
    assign signal_wire_26 = signal_mux_118;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_busy <= signal_const;
        else
            uart$lane$reg_busy <= signal_wire_26;
    end
    assign signal_not_18 = ~ uart$lane$reg_busy;
    always @* begin
        case (signal_reg)
        3'b011:
            signal_cases_6 <= signal_const_1;
        default:
            signal_cases_6 <= signal_const;
        endcase
    end
    assign signal_mux_119 = signal_or_16 ? signal_const : signal_cases_6;
    assign wire_byte_valid = signal_mux_119;
    assign signal_and_23 = wire_byte_valid & signal_not_18;
    assign signal_and_24 = signal_and_23 & signal_not_13;
    assign signal_mux_120 = signal_and_24 ? signal_const : signal_mux_77;
    assign signal_not_19 = ~ signal_wire_42;
    assign signal_or_12 = signal_not_19 | signal_wire_41;
    assign signal_mux_121 = signal_or_12 ? signal_const : signal_mux_120;
    assign signal_wire_27 = signal_mux_121;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            uart$lane$reg_done_ <= signal_const;
        else
            uart$lane$reg_done_ <= signal_wire_27;
    end
    assign signal_mux_122 = uart$lane$reg_done_ ? signal_const_103 : signal_const_138;
    assign signal_const_138 = 3'b100;
    assign signal_const_139 = 3'b011;
    assign signal_eq_9 = timing$reg_kind == signal_const_133;
    assign signal_mux_123 = signal_eq_9 ? signal_const_1 : signal_const;
    assign signal_mux_124 = signal_and_25 ? signal_mux_123 : signal_const;
    assign signal_mux_125 = signal_mux_153 ? signal_const_1 : signal_mux_124;
    assign signal_sub_6 = timing$reg_remaining - signal_const_123;
    assign signal_eq_10 = timing$reg_kind == signal_const_133;
    assign signal_or_13 = signal_eq_10 | timing$reg_timeout_enable;
    assign signal_mux_126 = signal_or_13 ? signal_sub_6 : timing$reg_remaining;
    assign signal_mux_127 = signal_and_25 ? signal_const_124 : signal_mux_126;
    assign signal_mux_128 = signal_mux_153 ? signal_const_124 : signal_mux_127;
    assign signal_mux_129 = signal_eq_14 ? timing$reg_remaining : signal_cat_3;
    assign signal_mux_130 = wire_wait_valid ? signal_mux_129 : timing$reg_remaining;
    assign signal_mux_131 = timing$reg_busy ? signal_mux_128 : signal_mux_130;
    assign signal_mux_132 = signal_or_15 ? signal_const_124 : signal_mux_131;
    assign signal_wire_28 = signal_mux_132;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            timing$reg_remaining <= signal_const_124;
        else
            timing$reg_remaining <= signal_wire_28;
    end
    assign signal_eq_11 = timing$reg_remaining == signal_const_123;
    assign signal_mux_133 = signal_eq_14 ? timing$reg_timeout_enable : gnd;
    assign signal_mux_134 = wire_wait_valid ? signal_mux_133 : timing$reg_timeout_enable;
    assign signal_mux_135 = timing$reg_busy ? timing$reg_timeout_enable : signal_mux_134;
    assign signal_mux_136 = signal_or_15 ? timing$reg_timeout_enable : signal_mux_135;
    assign signal_wire_29 = signal_mux_136;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            timing$reg_timeout_enable <= signal_const;
        else
            timing$reg_timeout_enable <= signal_wire_29;
    end
    assign signal_eq_12 = timing$reg_kind == signal_const_133;
    assign signal_or_14 = signal_eq_12 | timing$reg_timeout_enable;
    assign signal_and_25 = signal_or_14 & signal_eq_11;
    assign signal_mux_137 = signal_and_25 ? signal_const : timing$reg_busy;
    always @* begin
        case (timing$reg_pin)
        0:
            signal_mux_138 <= signal_const;
        1:
            signal_mux_138 <= signal_const;
        2:
            signal_mux_138 <= signal_const;
        3:
            signal_mux_138 <= signal_const;
        4:
            signal_mux_138 <= signal_const;
        5:
            signal_mux_138 <= signal_const;
        6:
            signal_mux_138 <= signal_const;
        default:
            signal_mux_138 <= signal_const;
        endcase
    end
    always @* begin
        case (timing$reg_pin)
        0:
            signal_mux_139 <= signal_const;
        1:
            signal_mux_139 <= signal_const;
        2:
            signal_mux_139 <= signal_const;
        3:
            signal_mux_139 <= signal_const;
        4:
            signal_mux_139 <= signal_const;
        5:
            signal_mux_139 <= signal_const;
        6:
            signal_mux_139 <= signal_const;
        default:
            signal_mux_139 <= signal_const;
        endcase
    end
    assign signal_mux_140 = signal_eq_14 ? timing$reg_level : gnd;
    assign signal_mux_141 = wire_wait_valid ? signal_mux_140 : timing$reg_level;
    assign signal_mux_142 = timing$reg_busy ? timing$reg_level : signal_mux_141;
    assign signal_mux_143 = signal_or_15 ? timing$reg_level : signal_mux_142;
    assign signal_wire_30 = signal_mux_143;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            timing$reg_level <= signal_const;
        else
            timing$reg_level <= signal_wire_30;
    end
    assign signal_mux_144 = signal_eq_14 ? timing$reg_pin : signal_const_38;
    assign signal_mux_145 = wire_wait_valid ? signal_mux_144 : timing$reg_pin;
    assign signal_mux_146 = timing$reg_busy ? timing$reg_pin : signal_mux_145;
    assign signal_mux_147 = signal_or_15 ? timing$reg_pin : signal_mux_146;
    assign signal_wire_31 = signal_mux_147;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            timing$reg_pin <= signal_const_38;
        else
            timing$reg_pin <= signal_wire_31;
    end
    always @* begin
        case (timing$reg_pin)
        0:
            signal_mux_148 <= signal_const;
        1:
            signal_mux_148 <= signal_const;
        2:
            signal_mux_148 <= signal_const;
        3:
            signal_mux_148 <= signal_const;
        4:
            signal_mux_148 <= signal_const;
        5:
            signal_mux_148 <= signal_const;
        6:
            signal_mux_148 <= signal_const;
        default:
            signal_mux_148 <= signal_const;
        endcase
    end
    assign signal_eq_13 = signal_mux_148 == timing$reg_level;
    assign signal_mux_149 = signal_eq_14 ? timing$reg_kind : signal_const_133;
    assign signal_mux_150 = wire_wait_valid ? signal_mux_149 : timing$reg_kind;
    assign signal_mux_151 = timing$reg_busy ? timing$reg_kind : signal_mux_150;
    assign signal_mux_152 = signal_or_15 ? timing$reg_kind : signal_mux_151;
    assign signal_wire_32 = signal_mux_152;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            timing$reg_kind <= signal_const_133;
        else
            timing$reg_kind <= signal_wire_32;
    end
    always @* begin
        case (timing$reg_kind)
        0:
            signal_mux_153 <= gnd;
        1:
            signal_mux_153 <= signal_eq_13;
        2:
            signal_mux_153 <= signal_mux_139;
        default:
            signal_mux_153 <= signal_mux_138;
        endcase
    end
    assign signal_mux_154 = signal_mux_153 ? signal_const : signal_mux_137;
    assign gnd = 1'b0;
    assign signal_wire_33 = reset_i;
    assign signal_wire_34 = clock_i;
    assign signal_wire_35 = half_period_i;
    assign signal_mux_155 = signal_and_26 ? signal_wire_35 : reg_half_period;
    always @* begin
        case (signal_reg)
        3'b000:
            signal_cases_7 <= signal_mux_155;
        default:
            signal_cases_7 <= reg_half_period;
        endcase
    end
    assign signal_wire_36 = signal_cases_7;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            reg_half_period <= signal_const_124;
        else
            reg_half_period <= signal_wire_36;
    end
    assign signal_select_35 = reg_half_period[14:0];
    assign signal_cat_3 = { signal_select_35,
                            gnd };
    assign signal_eq_14 = signal_cat_3 == signal_const_124;
    assign signal_mux_156 = signal_eq_14 ? timing$reg_busy : signal_const_1;
    always @* begin
        case (signal_reg)
        3'b001:
            signal_cases_8 <= signal_const_1;
        default:
            signal_cases_8 <= signal_const;
        endcase
    end
    assign signal_mux_157 = signal_or_16 ? signal_const : signal_cases_8;
    assign wire_wait_valid = signal_mux_157;
    assign signal_mux_158 = wire_wait_valid ? signal_mux_156 : timing$reg_busy;
    assign signal_mux_159 = timing$reg_busy ? signal_mux_154 : signal_mux_158;
    assign signal_mux_160 = signal_or_15 ? signal_const : signal_mux_159;
    assign signal_wire_37 = signal_mux_160;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            timing$reg_busy <= signal_const;
        else
            timing$reg_busy <= signal_wire_37;
    end
    assign signal_mux_161 = timing$reg_busy ? signal_mux_125 : signal_const;
    assign signal_not_20 = ~ signal_wire_42;
    assign signal_or_15 = signal_not_20 | signal_wire_41;
    assign signal_mux_162 = signal_or_15 ? signal_const : signal_mux_161;
    assign signal_wire_38 = signal_mux_162;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            timing$reg_complete <= signal_const;
        else
            timing$reg_complete <= signal_wire_38;
    end
    assign signal_mux_163 = timing$reg_complete ? signal_const_139 : signal_const_193;
    assign signal_const_193 = 3'b010;
    assign signal_const_194 = 3'b001;
    assign signal_not_21 = ~ signal_or_16;
    assign signal_wire_39 = start_i;
    assign signal_and_26 = signal_wire_39 & signal_not_21;
    assign signal_mux_164 = signal_and_26 ? signal_const_194 : signal_reg;
    always @* begin
        case (signal_reg)
        3'b000:
            signal_cases_9 <= signal_mux_164;
        3'b001:
            signal_cases_9 <= signal_const_193;
        3'b010:
            signal_cases_9 <= signal_mux_163;
        3'b011:
            signal_cases_9 <= signal_const_138;
        3'b100:
            signal_cases_9 <= signal_mux_122;
        3'b101:
            signal_cases_9 <= signal_const_38;
        default:
            signal_cases_9 <= signal_reg;
        endcase
    end
    assign signal_mux_165 = signal_or_16 ? signal_const_38 : signal_cases_9;
    assign signal_wire_40 = signal_mux_165;
    always @(posedge signal_wire_34) begin
        if (signal_wire_33)
            signal_reg <= signal_const_38;
        else
            signal_reg <= signal_wire_40;
    end
    always @* begin
        case (signal_reg)
        3'b000:
            signal_cases_10 <= signal_const_1;
        default:
            signal_cases_10 <= signal_const;
        endcase
    end
    assign signal_wire_41 = abort_i;
    assign signal_wire_42 = enable_i;
    assign signal_not_22 = ~ signal_wire_42;
    assign signal_or_16 = signal_not_22 | signal_wire_41;
    assign signal_mux_166 = signal_or_16 ? signal_const : signal_cases_10;
    assign wire_ready = signal_mux_166;
    assign ready_o = wire_ready;
    assign busy_o = signal_not_12;
    assign frame_done_o = wire_frame_done;
    assign gap_busy_o = timing$reg_busy;
    assign pins_o = bank$reg_pins;
    assign pin_oe_o = bank$reg_pin_oe;
    assign engine_claim_o = bank$reg_engine_claim;
    assign software_claim_o = bank$reg_software_claim;
    assign bank_rejected_o = bank$reg_rejected;
    assign bank_conflict_o = bank$reg_conflict;

endmodule
