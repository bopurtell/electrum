module observed_transfer (
    clock_i,
    reset_i,
    enable_i,
    abort_i,
    pin_async_i,
    arm_valid_i,
    start_pin_i,
    start_edge_kind_i,
    pacing_pin_i,
    pacing_edge_kind_i,
    cancel_enable_i,
    cancel_pin_i,
    cancel_edge_kind_i,
    bit_count_i,
    tx_value_i,
    tx_valid_i,
    rx_ready_i,
    tx_enable_i,
    rx_enable_i,
    lsb_first_i,
    output_pin_i,
    input_pin_i,
    idle_output_i,
    launch_trailing_i,
    sample_trailing_i,
    occupied_i,
    idle_clock_i,
    snapshot_o,
    start_edge_o,
    pacing_edge_o,
    cancel_edge_o,
    armed_o,
    busy_o,
    claim_mask_o,
    pin_value_o,
    pin_oe_o,
    done_o,
    rx_valid_o,
    rx_data_o,
    rejected_o,
    underrun_o,
    overrun_o
);

    input clock_i;
    input reset_i;
    input enable_i;
    input abort_i;
    input [7:0] pin_async_i;
    input arm_valid_i;
    input [2:0] start_pin_i;
    input [1:0] start_edge_kind_i;
    input [2:0] pacing_pin_i;
    input [1:0] pacing_edge_kind_i;
    input cancel_enable_i;
    input [2:0] cancel_pin_i;
    input [1:0] cancel_edge_kind_i;
    input [5:0] bit_count_i;
    input [31:0] tx_value_i;
    input tx_valid_i;
    input rx_ready_i;
    input tx_enable_i;
    input rx_enable_i;
    input lsb_first_i;
    input [2:0] output_pin_i;
    input [2:0] input_pin_i;
    input idle_output_i;
    input launch_trailing_i;
    input sample_trailing_i;
    input [7:0] occupied_i;
    input idle_clock_i;
    output [7:0] snapshot_o;
    output start_edge_o;
    output pacing_edge_o;
    output cancel_edge_o;
    output armed_o;
    output busy_o;
    output [7:0] claim_mask_o;
    output [7:0] pin_value_o;
    output [7:0] pin_oe_o;
    output done_o;
    output rx_valid_o;
    output [31:0] rx_data_o;
    output rejected_o;
    output underrun_o;
    output overrun_o;

    wire signal_const;
    wire signal_const_1;
    wire signal_mux;
    wire signal_mux_1;
    wire signal_mux_2;
    wire signal_mux_3;
    wire signal_mux_4;
    wire signal_mux_5;
    wire signal_wire;
    reg lane$reg_overrun;
    wire signal_mux_6;
    wire signal_mux_7;
    wire signal_mux_8;
    wire signal_mux_9;
    wire signal_wire_1;
    reg lane$reg_underrun;
    wire signal_mux_10;
    wire signal_mux_11;
    wire signal_mux_12;
    wire signal_mux_13;
    wire signal_mux_14;
    wire signal_wire_2;
    reg lane$reg_rejected;
    wire [31:0] signal_const_10;
    wire [31:0] signal_mux_15;
    wire [31:0] signal_mux_16;
    wire signal_select;
    wire signal_select_1;
    wire signal_select_2;
    wire signal_select_3;
    wire signal_select_4;
    wire signal_select_5;
    wire signal_select_6;
    wire signal_select_7;
    wire [2:0] signal_const_14;
    wire [2:0] signal_mux_17;
    wire [2:0] signal_mux_18;
    wire [2:0] signal_mux_19;
    wire [2:0] signal_mux_20;
    wire [2:0] signal_wire_3;
    reg [2:0] lane$reg_input_pin;
    reg signal_mux_21;
    wire [31:0] signal_mux_22;
    wire [31:0] signal_const_15;
    wire [31:0] signal_const_16;
    wire [31:0] signal_const_17;
    wire [31:0] signal_const_18;
    wire [31:0] signal_const_19;
    wire [31:0] signal_const_20;
    wire [31:0] signal_const_21;
    wire [31:0] signal_const_22;
    wire [31:0] signal_const_23;
    wire [31:0] signal_const_24;
    wire [31:0] signal_const_25;
    wire [31:0] signal_const_26;
    wire [31:0] signal_const_27;
    wire [31:0] signal_const_28;
    wire [31:0] signal_const_29;
    wire [31:0] signal_const_30;
    wire [31:0] signal_const_31;
    wire [31:0] signal_const_32;
    wire [31:0] signal_const_33;
    wire [31:0] signal_const_34;
    wire [31:0] signal_const_35;
    wire [31:0] signal_const_36;
    wire [31:0] signal_const_37;
    wire [31:0] signal_const_38;
    wire [31:0] signal_const_39;
    wire [31:0] signal_const_40;
    wire [31:0] signal_const_41;
    wire [31:0] signal_const_42;
    wire [31:0] signal_const_43;
    wire [31:0] signal_const_44;
    wire [31:0] signal_const_45;
    wire [31:0] signal_const_46;
    reg [31:0] signal_mux_23;
    wire [31:0] signal_not;
    wire [31:0] signal_and;
    wire [31:0] signal_or;
    wire [31:0] signal_mux_24;
    wire [31:0] signal_mux_25;
    wire [31:0] signal_mux_26;
    wire [31:0] signal_mux_27;
    wire [31:0] signal_mux_28;
    wire [31:0] signal_wire_4;
    reg [31:0] lane$reg_rx_value;
    wire signal_mux_29;
    wire signal_mux_30;
    wire signal_mux_31;
    wire signal_mux_32;
    wire signal_wire_5;
    reg lane$reg_sample_trailing;
    wire signal_eq;
    wire [31:0] signal_mux_33;
    wire [31:0] signal_mux_34;
    wire [31:0] signal_mux_35;
    wire [31:0] signal_mux_36;
    wire [31:0] signal_mux_37;
    wire [31:0] signal_mux_38;
    wire [31:0] signal_mux_39;
    wire [31:0] signal_mux_40;
    wire [31:0] signal_wire_6;
    reg [31:0] lane$reg_rx_data;
    wire signal_mux_41;
    wire signal_mux_42;
    wire signal_mux_43;
    wire signal_mux_44;
    wire signal_mux_45;
    wire signal_mux_46;
    wire signal_mux_47;
    wire signal_wire_7;
    reg lane$reg_rx_valid;
    wire signal_wire_8;
    wire signal_not_1;
    wire signal_mux_48;
    wire signal_mux_49;
    wire signal_mux_50;
    wire signal_mux_51;
    wire signal_wire_9;
    reg lane$reg_rx_enable;
    wire signal_and_1;
    wire signal_mux_52;
    wire signal_mux_53;
    wire signal_mux_54;
    wire signal_mux_55;
    wire signal_mux_56;
    wire signal_mux_57;
    wire signal_wire_10;
    reg lane$reg_done_;
    wire [7:0] signal_const_55;
    wire [7:0] signal_mux_58;
    wire [7:0] signal_mux_59;
    wire [7:0] signal_mux_60;
    wire [7:0] signal_mux_61;
    wire [7:0] signal_mux_62;
    wire [7:0] signal_mux_63;
    wire [7:0] signal_mux_64;
    wire [7:0] signal_mux_65;
    wire [7:0] signal_mux_66;
    wire [7:0] signal_wire_11;
    reg [7:0] lane$reg_pin_oe;
    wire [7:0] signal_mux_67;
    wire [7:0] signal_mux_68;
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
    wire signal_select_32;
    wire signal_select_33;
    wire signal_select_34;
    wire signal_select_35;
    wire signal_select_36;
    wire signal_select_37;
    wire signal_select_38;
    wire [31:0] signal_mux_69;
    wire [31:0] signal_mux_70;
    wire [31:0] signal_mux_71;
    wire [31:0] signal_mux_72;
    wire [31:0] signal_wire_12;
    reg [31:0] lane$reg_tx_value;
    wire signal_select_39;
    wire [5:0] signal_const_64;
    wire [5:0] signal_add;
    wire [5:0] signal_const_65;
    wire [5:0] signal_sub;
    wire [5:0] signal_sub_1;
    wire [5:0] signal_mux_73;
    wire [5:0] signal_sub_2;
    wire [5:0] signal_sub_3;
    wire signal_mux_74;
    wire signal_mux_75;
    wire signal_mux_76;
    wire signal_mux_77;
    wire signal_wire_13;
    reg lane$reg_lsb_first;
    wire [5:0] signal_mux_78;
    wire [5:0] signal_mux_79;
    reg signal_mux_80;
    wire [7:0] signal_mux_81;
    wire [7:0] signal_const_68;
    wire [7:0] signal_const_69;
    wire [7:0] signal_const_70;
    wire [7:0] signal_const_71;
    wire [7:0] signal_const_72;
    wire [7:0] signal_const_73;
    wire [7:0] signal_const_74;
    wire [7:0] signal_const_75;
    wire [2:0] signal_mux_82;
    wire [2:0] signal_mux_83;
    wire [2:0] signal_mux_84;
    wire [2:0] signal_mux_85;
    wire [2:0] signal_wire_14;
    reg [2:0] lane$reg_output_pin;
    reg [7:0] signal_mux_86;
    wire [7:0] signal_not_2;
    wire [7:0] signal_and_2;
    wire [7:0] signal_or_1;
    wire [2:0] signal_mux_87;
    wire [2:0] signal_mux_88;
    wire [2:0] signal_mux_89;
    wire [2:0] signal_mux_90;
    wire [2:0] signal_wire_15;
    reg [2:0] lane$reg_clock_pin;
    reg [7:0] signal_mux_91;
    wire [7:0] signal_xor;
    wire gnd;
    wire signal_mux_92;
    wire signal_mux_93;
    wire signal_mux_94;
    wire signal_mux_95;
    wire signal_wire_16;
    reg lane$reg_clock_enable;
    wire [7:0] signal_mux_96;
    wire signal_not_3;
    wire signal_mux_97;
    wire signal_mux_98;
    wire signal_mux_99;
    wire signal_mux_100;
    wire signal_wire_17;
    reg lane$reg_tx_enable;
    wire signal_mux_101;
    wire signal_mux_102;
    wire signal_mux_103;
    wire signal_mux_104;
    wire signal_wire_18;
    reg lane$reg_launch_trailing;
    wire signal_eq_1;
    wire signal_and_3;
    wire signal_and_4;
    wire [7:0] signal_mux_105;
    wire [7:0] signal_mux_106;
    wire signal_select_40;
    wire signal_select_41;
    wire signal_select_42;
    wire signal_select_43;
    wire signal_select_44;
    wire signal_select_45;
    wire signal_select_46;
    wire signal_select_47;
    wire signal_select_48;
    wire signal_select_49;
    wire signal_select_50;
    wire signal_select_51;
    wire signal_select_52;
    wire signal_select_53;
    wire signal_select_54;
    wire signal_select_55;
    wire signal_select_56;
    wire signal_select_57;
    wire signal_select_58;
    wire signal_select_59;
    wire signal_select_60;
    wire signal_select_61;
    wire signal_select_62;
    wire signal_select_63;
    wire signal_select_64;
    wire signal_select_65;
    wire signal_select_66;
    wire signal_select_67;
    wire signal_select_68;
    wire signal_select_69;
    wire signal_select_70;
    wire signal_select_71;
    wire [5:0] signal_const_92;
    wire [5:0] signal_sub_4;
    wire signal_wire_19;
    wire [5:0] signal_mux_107;
    reg signal_mux_108;
    wire [7:0] signal_mux_109;
    wire signal_wire_20;
    wire [7:0] signal_mux_110;
    wire [7:0] signal_mux_111;
    wire [7:0] signal_mux_112;
    wire [7:0] signal_mux_113;
    wire [7:0] signal_mux_114;
    wire [7:0] signal_mux_115;
    wire [7:0] signal_mux_116;
    wire [7:0] signal_wire_21;
    reg [7:0] lane$reg_prepared_pin_value;
    wire [7:0] signal_mux_117;
    wire [7:0] signal_mux_118;
    wire [7:0] signal_mux_119;
    wire [7:0] signal_mux_120;
    wire [7:0] signal_mux_121;
    wire [7:0] signal_wire_22;
    reg [7:0] lane$reg_pin_value;
    wire [7:0] signal_mux_122;
    wire [7:0] signal_mux_123;
    wire [7:0] signal_mux_124;
    wire [7:0] signal_mux_125;
    wire [7:0] signal_mux_126;
    wire [7:0] signal_mux_127;
    wire [7:0] signal_mux_128;
    wire [7:0] signal_mux_129;
    wire [7:0] signal_mux_130;
    wire [7:0] signal_wire_23;
    reg [7:0] lane$reg_claim_mask;
    wire signal_select_72;
    wire signal_select_73;
    wire signal_select_74;
    wire signal_select_75;
    wire signal_select_76;
    wire signal_select_77;
    wire signal_select_78;
    wire [7:0] signal_or_2;
    wire [1:0] signal_const_101;
    wire [1:0] signal_mux_131;
    wire [1:0] signal_wire_24;
    reg [1:0] config_start_edge_kind;
    reg [7:0] signal_mux_132;
    wire signal_select_79;
    wire [2:0] signal_wire_25;
    wire signal_not_4;
    wire signal_and_5;
    wire signal_not_5;
    wire signal_not_6;
    wire signal_and_6;
    wire signal_eq_2;
    wire [15:0] signal_select_80;
    wire [15:0] signal_const_105;
    wire [31:0] signal_cat;
    wire [23:0] signal_select_81;
    wire [31:0] signal_cat_1;
    wire [27:0] signal_select_82;
    wire [3:0] signal_const_107;
    wire [31:0] signal_cat_2;
    wire [29:0] signal_select_83;
    wire [31:0] signal_cat_3;
    wire [30:0] signal_select_84;
    wire [31:0] signal_cat_4;
    wire signal_select_85;
    wire [31:0] signal_mux_133;
    wire signal_select_86;
    wire [31:0] signal_mux_134;
    wire signal_select_87;
    wire [31:0] signal_mux_135;
    wire signal_select_88;
    wire [31:0] signal_mux_136;
    wire signal_select_89;
    wire [31:0] signal_mux_137;
    wire signal_select_90;
    wire [31:0] signal_mux_138;
    wire signal_eq_3;
    wire signal_not_7;
    wire [5:0] signal_const_110;
    wire signal_lt;
    wire signal_eq_4;
    wire signal_or_3;
    wire signal_or_4;
    wire signal_or_5;
    wire signal_or_6;
    wire signal_or_7;
    wire signal_or_8;
    wire signal_or_9;
    wire signal_not_8;
    wire signal_not_9;
    wire signal_not_10;
    wire signal_mux_139;
    wire signal_mux_140;
    wire [5:0] signal_mux_141;
    wire [5:0] signal_mux_142;
    wire [5:0] signal_mux_143;
    wire [5:0] signal_mux_144;
    wire [5:0] signal_wire_26;
    reg [5:0] lane$reg_bit_count;
    wire [5:0] signal_sub_5;
    wire [5:0] signal_mux_145;
    wire [5:0] signal_mux_146;
    wire [5:0] signal_add_1;
    wire [5:0] signal_mux_147;
    wire [5:0] signal_mux_148;
    wire [5:0] signal_mux_149;
    wire [5:0] signal_mux_150;
    wire [5:0] signal_mux_151;
    wire [5:0] signal_mux_152;
    wire [5:0] signal_wire_27;
    reg [5:0] lane$reg_bit_index;
    wire signal_eq_5;
    wire signal_mux_153;
    wire signal_mux_154;
    wire signal_mux_155;
    wire signal_mux_156;
    wire signal_mux_157;
    wire signal_mux_158;
    wire signal_mux_159;
    wire signal_mux_160;
    wire signal_wire_28;
    reg lane$reg_trailing;
    wire signal_and_7;
    wire signal_mux_161;
    wire signal_select_91;
    wire signal_select_92;
    wire signal_select_93;
    wire signal_select_94;
    wire signal_select_95;
    wire signal_select_96;
    wire signal_select_97;
    wire [7:0] signal_or_10;
    wire [1:0] signal_mux_162;
    wire [1:0] signal_wire_29;
    reg [1:0] config_pacing_edge_kind;
    reg [7:0] signal_mux_163;
    wire signal_select_98;
    wire [2:0] signal_mux_164;
    wire [2:0] signal_wire_30;
    reg [2:0] config_pacing_pin;
    reg signal_mux_165;
    wire [15:0] signal_const_128;
    wire [15:0] signal_mux_166;
    wire [15:0] signal_mux_167;
    wire [15:0] signal_mux_168;
    wire [15:0] signal_mux_169;
    wire [15:0] signal_mux_170;
    wire [15:0] signal_mux_171;
    wire [15:0] signal_wire_31;
    reg [15:0] lane$reg_half_period;
    wire signal_not_11;
    wire [15:0] signal_mux_172;
    wire [15:0] signal_sub_6;
    wire signal_not_12;
    wire signal_not_13;
    wire signal_and_8;
    wire [15:0] signal_mux_173;
    wire [15:0] signal_mux_174;
    wire [15:0] signal_mux_175;
    wire [15:0] signal_mux_176;
    wire [15:0] signal_mux_177;
    wire [15:0] signal_wire_32;
    reg [15:0] lane$reg_remaining;
    wire signal_eq_6;
    wire signal_mux_178;
    wire signal_mux_179;
    wire signal_mux_180;
    wire signal_mux_181;
    wire signal_wire_33;
    reg lane$reg_observed;
    wire signal_mux_182;
    wire signal_and_9;
    wire signal_mux_183;
    wire [7:0] signal_wire_34;
    reg [7:0] signal_mux_184;
    wire [7:0] signal_mux_185;
    wire [7:0] signal_mux_186;
    wire [7:0] signal_mux_187;
    wire [7:0] signal_mux_188;
    wire [7:0] signal_mux_189;
    wire [7:0] signal_wire_35;
    reg [7:0] lane$reg_prepared_mask;
    wire [7:0] signal_and_10;
    wire signal_eq_7;
    wire signal_not_14;
    wire signal_mux_190;
    wire signal_mux_191;
    wire signal_mux_192;
    wire signal_mux_193;
    wire signal_select_99;
    wire signal_select_100;
    wire signal_select_101;
    wire signal_select_102;
    wire signal_select_103;
    wire signal_select_104;
    wire signal_select_105;
    wire [7:0] signal_or_11;
    wire [7:0] signal_not_15;
    wire [7:0] signal_and_11;
    wire [7:0] signal_wire_36;
    reg [7:0] front$reg_previous;
    wire [7:0] signal_not_16;
    wire [7:0] signal_and_12;
    wire [1:0] signal_mux_194;
    wire [1:0] signal_wire_37;
    reg [1:0] config_cancel_edge_kind;
    reg [7:0] signal_mux_195;
    wire signal_select_106;
    wire [2:0] signal_wire_38;
    wire [2:0] signal_mux_196;
    wire [2:0] signal_wire_39;
    reg [2:0] config_cancel_pin;
    reg signal_mux_197;
    wire signal_mux_198;
    wire signal_wire_40;
    reg config_cancel_enable;
    wire vdd;
    wire signal_wire_41;
    wire signal_not_17;
    wire signal_and_13;
    wire signal_mux_199;
    wire signal_not_18;
    wire signal_not_19;
    wire signal_and_14;
    wire signal_wire_42;
    wire signal_wire_43;
    wire signal_eq_8;
    wire [15:0] signal_select_107;
    wire [31:0] signal_cat_5;
    wire [23:0] signal_select_108;
    wire [31:0] signal_cat_6;
    wire [27:0] signal_select_109;
    wire [31:0] signal_cat_7;
    wire [29:0] signal_select_110;
    wire [31:0] signal_cat_8;
    wire [30:0] signal_select_111;
    wire [31:0] signal_cat_9;
    wire [31:0] signal_wire_44;
    wire signal_select_112;
    wire [31:0] signal_mux_200;
    wire signal_select_113;
    wire [31:0] signal_mux_201;
    wire signal_select_114;
    wire [31:0] signal_mux_202;
    wire signal_select_115;
    wire [31:0] signal_mux_203;
    wire signal_select_116;
    wire [31:0] signal_mux_204;
    wire signal_select_117;
    wire [31:0] signal_mux_205;
    wire signal_eq_9;
    wire signal_not_20;
    wire signal_lt_1;
    wire [5:0] signal_wire_45;
    wire [2:0] signal_wire_46;
    wire signal_eq_10;
    wire signal_wire_47;
    wire signal_and_15;
    wire [2:0] signal_wire_48;
    wire [2:0] signal_wire_49;
    wire signal_eq_11;
    wire signal_wire_50;
    wire signal_and_16;
    wire signal_or_12;
    wire [1:0] signal_const_164;
    wire [1:0] signal_wire_51;
    wire signal_eq_12;
    wire signal_wire_52;
    wire signal_and_17;
    wire [1:0] signal_wire_53;
    wire signal_eq_13;
    wire [1:0] signal_wire_54;
    wire signal_eq_14;
    wire signal_or_13;
    wire signal_or_14;
    wire signal_or_15;
    wire [5:0] signal_mux_206;
    wire signal_eq_15;
    wire signal_or_16;
    wire signal_or_17;
    wire signal_or_18;
    wire signal_or_19;
    wire signal_mux_207;
    wire signal_and_18;
    wire signal_mux_208;
    wire signal_not_21;
    wire signal_not_22;
    wire signal_and_19;
    wire signal_and_20;
    wire signal_mux_209;
    wire signal_mux_210;
    wire signal_wire_55;
    reg lane$reg_armed;
    wire signal_or_20;
    wire signal_wire_56;
    wire signal_and_21;
    wire signal_and_22;
    wire signal_wire_57;
    wire signal_or_21;
    wire signal_not_23;
    wire signal_or_22;
    wire signal_mux_211;
    wire signal_wire_58;
    reg lane$reg_busy;
    wire signal_not_24;
    wire signal_wire_59;
    wire signal_and_23;
    wire signal_and_24;
    wire signal_wire_60;
    wire signal_and_25;
    wire signal_and_26;
    wire signal_and_27;
    wire [2:0] signal_mux_212;
    wire [2:0] signal_wire_61;
    reg [2:0] config_start_pin;
    reg signal_mux_213;
    wire signal_wire_62;
    wire signal_wire_63;
    wire [7:0] signal_wire_64;
    wire [7:0] signal_wire_65;
    reg [7:0] front$reg_stage0;
    wire [7:0] signal_wire_66;
    reg [7:0] front$reg_stage1;
    assign signal_const = 1'b0;
    assign signal_const_1 = 1'b1;
    assign signal_mux = signal_and_1 ? signal_const_1 : signal_const;
    assign signal_mux_1 = signal_and_7 ? signal_mux : signal_const;
    assign signal_mux_2 = signal_and_9 ? signal_mux_1 : signal_const;
    assign signal_mux_3 = lane$reg_busy ? signal_mux_2 : signal_const;
    assign signal_mux_4 = signal_and_20 ? signal_const : signal_mux_3;
    assign signal_mux_5 = signal_or_22 ? signal_const : signal_mux_4;
    assign signal_wire = signal_mux_5;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_overrun <= signal_const;
        else
            lane$reg_overrun <= signal_wire;
    end
    assign signal_mux_6 = signal_and_13 ? signal_const_1 : signal_const;
    assign signal_mux_7 = signal_or_19 ? signal_const : signal_mux_6;
    assign signal_mux_8 = signal_and_20 ? signal_mux_7 : signal_const;
    assign signal_mux_9 = signal_or_22 ? signal_const : signal_mux_8;
    assign signal_wire_1 = signal_mux_9;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_underrun <= signal_const;
        else
            lane$reg_underrun <= signal_wire_1;
    end
    assign signal_mux_10 = signal_or_19 ? signal_const_1 : signal_const;
    assign signal_mux_11 = signal_not_14 ? signal_const_1 : signal_const;
    assign signal_mux_12 = signal_and_18 ? signal_mux_11 : signal_const;
    assign signal_mux_13 = signal_and_20 ? signal_mux_10 : signal_mux_12;
    assign signal_mux_14 = signal_or_22 ? signal_const : signal_mux_13;
    assign signal_wire_2 = signal_mux_14;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_rejected <= signal_const;
        else
            lane$reg_rejected <= signal_wire_2;
    end
    assign signal_const_10 = 32'b00000000000000000000000000000000;
    assign signal_mux_15 = signal_and_13 ? lane$reg_rx_value : signal_const_10;
    assign signal_mux_16 = signal_or_19 ? lane$reg_rx_value : signal_mux_15;
    assign signal_select = front$reg_stage1[7:7];
    assign signal_select_1 = front$reg_stage1[6:6];
    assign signal_select_2 = front$reg_stage1[5:5];
    assign signal_select_3 = front$reg_stage1[4:4];
    assign signal_select_4 = front$reg_stage1[3:3];
    assign signal_select_5 = front$reg_stage1[2:2];
    assign signal_select_6 = front$reg_stage1[1:1];
    assign signal_select_7 = front$reg_stage1[0:0];
    assign signal_const_14 = 3'b000;
    assign signal_mux_17 = signal_and_13 ? lane$reg_input_pin : signal_wire_46;
    assign signal_mux_18 = signal_or_19 ? lane$reg_input_pin : signal_mux_17;
    assign signal_mux_19 = signal_and_20 ? signal_mux_18 : lane$reg_input_pin;
    assign signal_mux_20 = signal_or_22 ? lane$reg_input_pin : signal_mux_19;
    assign signal_wire_3 = signal_mux_20;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_input_pin <= signal_const_14;
        else
            lane$reg_input_pin <= signal_wire_3;
    end
    always @* begin
        case (lane$reg_input_pin)
        0:
            signal_mux_21 <= signal_select_7;
        1:
            signal_mux_21 <= signal_select_6;
        2:
            signal_mux_21 <= signal_select_5;
        3:
            signal_mux_21 <= signal_select_4;
        4:
            signal_mux_21 <= signal_select_3;
        5:
            signal_mux_21 <= signal_select_2;
        6:
            signal_mux_21 <= signal_select_1;
        default:
            signal_mux_21 <= signal_select;
        endcase
    end
    assign signal_mux_22 = signal_mux_21 ? signal_mux_23 : signal_const_10;
    assign signal_const_15 = 32'b10000000000000000000000000000000;
    assign signal_const_16 = 32'b01000000000000000000000000000000;
    assign signal_const_17 = 32'b00100000000000000000000000000000;
    assign signal_const_18 = 32'b00010000000000000000000000000000;
    assign signal_const_19 = 32'b00001000000000000000000000000000;
    assign signal_const_20 = 32'b00000100000000000000000000000000;
    assign signal_const_21 = 32'b00000010000000000000000000000000;
    assign signal_const_22 = 32'b00000001000000000000000000000000;
    assign signal_const_23 = 32'b00000000100000000000000000000000;
    assign signal_const_24 = 32'b00000000010000000000000000000000;
    assign signal_const_25 = 32'b00000000001000000000000000000000;
    assign signal_const_26 = 32'b00000000000100000000000000000000;
    assign signal_const_27 = 32'b00000000000010000000000000000000;
    assign signal_const_28 = 32'b00000000000001000000000000000000;
    assign signal_const_29 = 32'b00000000000000100000000000000000;
    assign signal_const_30 = 32'b00000000000000010000000000000000;
    assign signal_const_31 = 32'b00000000000000001000000000000000;
    assign signal_const_32 = 32'b00000000000000000100000000000000;
    assign signal_const_33 = 32'b00000000000000000010000000000000;
    assign signal_const_34 = 32'b00000000000000000001000000000000;
    assign signal_const_35 = 32'b00000000000000000000100000000000;
    assign signal_const_36 = 32'b00000000000000000000010000000000;
    assign signal_const_37 = 32'b00000000000000000000001000000000;
    assign signal_const_38 = 32'b00000000000000000000000100000000;
    assign signal_const_39 = 32'b00000000000000000000000010000000;
    assign signal_const_40 = 32'b00000000000000000000000001000000;
    assign signal_const_41 = 32'b00000000000000000000000000100000;
    assign signal_const_42 = 32'b00000000000000000000000000010000;
    assign signal_const_43 = 32'b00000000000000000000000000001000;
    assign signal_const_44 = 32'b00000000000000000000000000000100;
    assign signal_const_45 = 32'b00000000000000000000000000000010;
    assign signal_const_46 = 32'b00000000000000000000000000000001;
    always @* begin
        case (signal_mux_78)
        0:
            signal_mux_23 <= signal_const_46;
        1:
            signal_mux_23 <= signal_const_45;
        2:
            signal_mux_23 <= signal_const_44;
        3:
            signal_mux_23 <= signal_const_43;
        4:
            signal_mux_23 <= signal_const_42;
        5:
            signal_mux_23 <= signal_const_41;
        6:
            signal_mux_23 <= signal_const_40;
        7:
            signal_mux_23 <= signal_const_39;
        8:
            signal_mux_23 <= signal_const_38;
        9:
            signal_mux_23 <= signal_const_37;
        10:
            signal_mux_23 <= signal_const_36;
        11:
            signal_mux_23 <= signal_const_35;
        12:
            signal_mux_23 <= signal_const_34;
        13:
            signal_mux_23 <= signal_const_33;
        14:
            signal_mux_23 <= signal_const_32;
        15:
            signal_mux_23 <= signal_const_31;
        16:
            signal_mux_23 <= signal_const_30;
        17:
            signal_mux_23 <= signal_const_29;
        18:
            signal_mux_23 <= signal_const_28;
        19:
            signal_mux_23 <= signal_const_27;
        20:
            signal_mux_23 <= signal_const_26;
        21:
            signal_mux_23 <= signal_const_25;
        22:
            signal_mux_23 <= signal_const_24;
        23:
            signal_mux_23 <= signal_const_23;
        24:
            signal_mux_23 <= signal_const_22;
        25:
            signal_mux_23 <= signal_const_21;
        26:
            signal_mux_23 <= signal_const_20;
        27:
            signal_mux_23 <= signal_const_19;
        28:
            signal_mux_23 <= signal_const_18;
        29:
            signal_mux_23 <= signal_const_17;
        30:
            signal_mux_23 <= signal_const_16;
        default:
            signal_mux_23 <= signal_const_15;
        endcase
    end
    assign signal_not = ~ signal_mux_23;
    assign signal_and = lane$reg_rx_value & signal_not;
    assign signal_or = signal_and | signal_mux_22;
    assign signal_mux_24 = signal_eq ? signal_or : lane$reg_rx_value;
    assign signal_mux_25 = signal_and_9 ? signal_mux_24 : lane$reg_rx_value;
    assign signal_mux_26 = lane$reg_busy ? signal_mux_25 : lane$reg_rx_value;
    assign signal_mux_27 = signal_and_20 ? signal_mux_16 : signal_mux_26;
    assign signal_mux_28 = signal_or_22 ? lane$reg_rx_value : signal_mux_27;
    assign signal_wire_4 = signal_mux_28;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_rx_value <= signal_const_10;
        else
            lane$reg_rx_value <= signal_wire_4;
    end
    assign signal_mux_29 = signal_and_13 ? lane$reg_sample_trailing : signal_wire_42;
    assign signal_mux_30 = signal_or_19 ? lane$reg_sample_trailing : signal_mux_29;
    assign signal_mux_31 = signal_and_20 ? signal_mux_30 : lane$reg_sample_trailing;
    assign signal_mux_32 = signal_or_22 ? lane$reg_sample_trailing : signal_mux_31;
    assign signal_wire_5 = signal_mux_32;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_sample_trailing <= signal_const;
        else
            lane$reg_sample_trailing <= signal_wire_5;
    end
    assign signal_eq = lane$reg_trailing == lane$reg_sample_trailing;
    assign signal_mux_33 = signal_eq ? signal_or : lane$reg_rx_value;
    assign signal_mux_34 = lane$reg_rx_enable ? signal_mux_33 : lane$reg_rx_data;
    assign signal_mux_35 = signal_and_1 ? lane$reg_rx_data : signal_mux_34;
    assign signal_mux_36 = signal_and_7 ? signal_mux_35 : lane$reg_rx_data;
    assign signal_mux_37 = signal_and_9 ? signal_mux_36 : lane$reg_rx_data;
    assign signal_mux_38 = lane$reg_busy ? signal_mux_37 : lane$reg_rx_data;
    assign signal_mux_39 = signal_and_20 ? lane$reg_rx_data : signal_mux_38;
    assign signal_mux_40 = signal_or_22 ? lane$reg_rx_data : signal_mux_39;
    assign signal_wire_6 = signal_mux_40;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_rx_data <= signal_const_10;
        else
            lane$reg_rx_data <= signal_wire_6;
    end
    assign signal_mux_41 = lane$reg_rx_enable ? signal_const_1 : signal_const;
    assign signal_mux_42 = signal_and_1 ? signal_const : signal_mux_41;
    assign signal_mux_43 = signal_and_7 ? signal_mux_42 : signal_const;
    assign signal_mux_44 = signal_and_9 ? signal_mux_43 : signal_const;
    assign signal_mux_45 = lane$reg_busy ? signal_mux_44 : signal_const;
    assign signal_mux_46 = signal_and_20 ? signal_const : signal_mux_45;
    assign signal_mux_47 = signal_or_22 ? signal_const : signal_mux_46;
    assign signal_wire_7 = signal_mux_47;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_rx_valid <= signal_const;
        else
            lane$reg_rx_valid <= signal_wire_7;
    end
    assign signal_wire_8 = rx_ready_i;
    assign signal_not_1 = ~ signal_wire_8;
    assign signal_mux_48 = signal_and_13 ? lane$reg_rx_enable : signal_wire_47;
    assign signal_mux_49 = signal_or_19 ? lane$reg_rx_enable : signal_mux_48;
    assign signal_mux_50 = signal_and_20 ? signal_mux_49 : lane$reg_rx_enable;
    assign signal_mux_51 = signal_or_22 ? lane$reg_rx_enable : signal_mux_50;
    assign signal_wire_9 = signal_mux_51;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_rx_enable <= signal_const;
        else
            lane$reg_rx_enable <= signal_wire_9;
    end
    assign signal_and_1 = lane$reg_rx_enable & signal_not_1;
    assign signal_mux_52 = signal_and_1 ? signal_const : signal_const_1;
    assign signal_mux_53 = signal_and_7 ? signal_mux_52 : signal_const;
    assign signal_mux_54 = signal_and_9 ? signal_mux_53 : signal_const;
    assign signal_mux_55 = lane$reg_busy ? signal_mux_54 : signal_const;
    assign signal_mux_56 = signal_and_20 ? signal_const : signal_mux_55;
    assign signal_mux_57 = signal_or_22 ? signal_const : signal_mux_56;
    assign signal_wire_10 = signal_mux_57;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_done_ <= signal_const;
        else
            lane$reg_done_ <= signal_wire_10;
    end
    assign signal_const_55 = 8'b00000000;
    assign signal_mux_58 = signal_and_13 ? lane$reg_pin_oe : signal_const_55;
    assign signal_mux_59 = signal_or_19 ? lane$reg_pin_oe : signal_mux_58;
    assign signal_mux_60 = signal_and_7 ? signal_const_55 : signal_mux_63;
    assign signal_mux_61 = signal_and_9 ? signal_mux_60 : signal_mux_63;
    assign signal_mux_62 = signal_not_14 ? lane$reg_pin_oe : lane$reg_prepared_mask;
    assign signal_mux_63 = signal_and_18 ? signal_mux_62 : lane$reg_pin_oe;
    assign signal_mux_64 = lane$reg_busy ? signal_mux_61 : signal_mux_63;
    assign signal_mux_65 = signal_and_20 ? signal_mux_59 : signal_mux_64;
    assign signal_mux_66 = signal_or_22 ? signal_const_55 : signal_mux_65;
    assign signal_wire_11 = signal_mux_66;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_pin_oe <= signal_const_55;
        else
            lane$reg_pin_oe <= signal_wire_11;
    end
    assign signal_mux_67 = signal_and_13 ? lane$reg_pin_value : signal_const_55;
    assign signal_mux_68 = signal_or_19 ? lane$reg_pin_value : signal_mux_67;
    assign signal_select_8 = lane$reg_tx_value[31:31];
    assign signal_select_9 = lane$reg_tx_value[30:30];
    assign signal_select_10 = lane$reg_tx_value[29:29];
    assign signal_select_11 = lane$reg_tx_value[28:28];
    assign signal_select_12 = lane$reg_tx_value[27:27];
    assign signal_select_13 = lane$reg_tx_value[26:26];
    assign signal_select_14 = lane$reg_tx_value[25:25];
    assign signal_select_15 = lane$reg_tx_value[24:24];
    assign signal_select_16 = lane$reg_tx_value[23:23];
    assign signal_select_17 = lane$reg_tx_value[22:22];
    assign signal_select_18 = lane$reg_tx_value[21:21];
    assign signal_select_19 = lane$reg_tx_value[20:20];
    assign signal_select_20 = lane$reg_tx_value[19:19];
    assign signal_select_21 = lane$reg_tx_value[18:18];
    assign signal_select_22 = lane$reg_tx_value[17:17];
    assign signal_select_23 = lane$reg_tx_value[16:16];
    assign signal_select_24 = lane$reg_tx_value[15:15];
    assign signal_select_25 = lane$reg_tx_value[14:14];
    assign signal_select_26 = lane$reg_tx_value[13:13];
    assign signal_select_27 = lane$reg_tx_value[12:12];
    assign signal_select_28 = lane$reg_tx_value[11:11];
    assign signal_select_29 = lane$reg_tx_value[10:10];
    assign signal_select_30 = lane$reg_tx_value[9:9];
    assign signal_select_31 = lane$reg_tx_value[8:8];
    assign signal_select_32 = lane$reg_tx_value[7:7];
    assign signal_select_33 = lane$reg_tx_value[6:6];
    assign signal_select_34 = lane$reg_tx_value[5:5];
    assign signal_select_35 = lane$reg_tx_value[4:4];
    assign signal_select_36 = lane$reg_tx_value[3:3];
    assign signal_select_37 = lane$reg_tx_value[2:2];
    assign signal_select_38 = lane$reg_tx_value[1:1];
    assign signal_mux_69 = signal_and_13 ? lane$reg_tx_value : signal_wire_44;
    assign signal_mux_70 = signal_or_19 ? lane$reg_tx_value : signal_mux_69;
    assign signal_mux_71 = signal_and_20 ? signal_mux_70 : lane$reg_tx_value;
    assign signal_mux_72 = signal_or_22 ? lane$reg_tx_value : signal_mux_71;
    assign signal_wire_12 = signal_mux_72;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_tx_value <= signal_const_10;
        else
            lane$reg_tx_value <= signal_wire_12;
    end
    assign signal_select_39 = lane$reg_tx_value[0:0];
    assign signal_const_64 = 6'b000001;
    assign signal_add = lane$reg_bit_index + signal_const_64;
    assign signal_const_65 = 6'b000010;
    assign signal_sub = lane$reg_bit_count - signal_const_65;
    assign signal_sub_1 = signal_sub - lane$reg_bit_index;
    assign signal_mux_73 = lane$reg_lsb_first ? signal_add : signal_sub_1;
    assign signal_sub_2 = lane$reg_bit_count - signal_const_64;
    assign signal_sub_3 = signal_sub_2 - lane$reg_bit_index;
    assign signal_mux_74 = signal_and_13 ? lane$reg_lsb_first : signal_wire_19;
    assign signal_mux_75 = signal_or_19 ? lane$reg_lsb_first : signal_mux_74;
    assign signal_mux_76 = signal_and_20 ? signal_mux_75 : lane$reg_lsb_first;
    assign signal_mux_77 = signal_or_22 ? lane$reg_lsb_first : signal_mux_76;
    assign signal_wire_13 = signal_mux_77;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_lsb_first <= signal_const;
        else
            lane$reg_lsb_first <= signal_wire_13;
    end
    assign signal_mux_78 = lane$reg_lsb_first ? lane$reg_bit_index : signal_sub_3;
    assign signal_mux_79 = lane$reg_launch_trailing ? signal_mux_73 : signal_mux_78;
    always @* begin
        case (signal_mux_79)
        0:
            signal_mux_80 <= signal_select_39;
        1:
            signal_mux_80 <= signal_select_38;
        2:
            signal_mux_80 <= signal_select_37;
        3:
            signal_mux_80 <= signal_select_36;
        4:
            signal_mux_80 <= signal_select_35;
        5:
            signal_mux_80 <= signal_select_34;
        6:
            signal_mux_80 <= signal_select_33;
        7:
            signal_mux_80 <= signal_select_32;
        8:
            signal_mux_80 <= signal_select_31;
        9:
            signal_mux_80 <= signal_select_30;
        10:
            signal_mux_80 <= signal_select_29;
        11:
            signal_mux_80 <= signal_select_28;
        12:
            signal_mux_80 <= signal_select_27;
        13:
            signal_mux_80 <= signal_select_26;
        14:
            signal_mux_80 <= signal_select_25;
        15:
            signal_mux_80 <= signal_select_24;
        16:
            signal_mux_80 <= signal_select_23;
        17:
            signal_mux_80 <= signal_select_22;
        18:
            signal_mux_80 <= signal_select_21;
        19:
            signal_mux_80 <= signal_select_20;
        20:
            signal_mux_80 <= signal_select_19;
        21:
            signal_mux_80 <= signal_select_18;
        22:
            signal_mux_80 <= signal_select_17;
        23:
            signal_mux_80 <= signal_select_16;
        24:
            signal_mux_80 <= signal_select_15;
        25:
            signal_mux_80 <= signal_select_14;
        26:
            signal_mux_80 <= signal_select_13;
        27:
            signal_mux_80 <= signal_select_12;
        28:
            signal_mux_80 <= signal_select_11;
        29:
            signal_mux_80 <= signal_select_10;
        30:
            signal_mux_80 <= signal_select_9;
        default:
            signal_mux_80 <= signal_select_8;
        endcase
    end
    assign signal_mux_81 = signal_mux_80 ? signal_mux_86 : signal_const_55;
    assign signal_const_68 = 8'b10000000;
    assign signal_const_69 = 8'b01000000;
    assign signal_const_70 = 8'b00100000;
    assign signal_const_71 = 8'b00010000;
    assign signal_const_72 = 8'b00001000;
    assign signal_const_73 = 8'b00000100;
    assign signal_const_74 = 8'b00000010;
    assign signal_const_75 = 8'b00000001;
    assign signal_mux_82 = signal_and_13 ? lane$reg_output_pin : signal_wire_48;
    assign signal_mux_83 = signal_or_19 ? lane$reg_output_pin : signal_mux_82;
    assign signal_mux_84 = signal_and_20 ? signal_mux_83 : lane$reg_output_pin;
    assign signal_mux_85 = signal_or_22 ? lane$reg_output_pin : signal_mux_84;
    assign signal_wire_14 = signal_mux_85;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_output_pin <= signal_const_14;
        else
            lane$reg_output_pin <= signal_wire_14;
    end
    always @* begin
        case (lane$reg_output_pin)
        0:
            signal_mux_86 <= signal_const_75;
        1:
            signal_mux_86 <= signal_const_74;
        2:
            signal_mux_86 <= signal_const_73;
        3:
            signal_mux_86 <= signal_const_72;
        4:
            signal_mux_86 <= signal_const_71;
        5:
            signal_mux_86 <= signal_const_70;
        6:
            signal_mux_86 <= signal_const_69;
        default:
            signal_mux_86 <= signal_const_68;
        endcase
    end
    assign signal_not_2 = ~ signal_mux_86;
    assign signal_and_2 = signal_mux_96 & signal_not_2;
    assign signal_or_1 = signal_and_2 | signal_mux_81;
    assign signal_mux_87 = signal_and_13 ? lane$reg_clock_pin : signal_const_14;
    assign signal_mux_88 = signal_or_19 ? lane$reg_clock_pin : signal_mux_87;
    assign signal_mux_89 = signal_and_20 ? signal_mux_88 : lane$reg_clock_pin;
    assign signal_mux_90 = signal_or_22 ? lane$reg_clock_pin : signal_mux_89;
    assign signal_wire_15 = signal_mux_90;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_clock_pin <= signal_const_14;
        else
            lane$reg_clock_pin <= signal_wire_15;
    end
    always @* begin
        case (lane$reg_clock_pin)
        0:
            signal_mux_91 <= signal_const_75;
        1:
            signal_mux_91 <= signal_const_74;
        2:
            signal_mux_91 <= signal_const_73;
        3:
            signal_mux_91 <= signal_const_72;
        4:
            signal_mux_91 <= signal_const_71;
        5:
            signal_mux_91 <= signal_const_70;
        6:
            signal_mux_91 <= signal_const_69;
        default:
            signal_mux_91 <= signal_const_68;
        endcase
    end
    assign signal_xor = lane$reg_pin_value ^ signal_mux_91;
    assign gnd = 1'b0;
    assign signal_mux_92 = signal_and_13 ? lane$reg_clock_enable : gnd;
    assign signal_mux_93 = signal_or_19 ? lane$reg_clock_enable : signal_mux_92;
    assign signal_mux_94 = signal_and_20 ? signal_mux_93 : lane$reg_clock_enable;
    assign signal_mux_95 = signal_or_22 ? lane$reg_clock_enable : signal_mux_94;
    assign signal_wire_16 = signal_mux_95;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_clock_enable <= signal_const;
        else
            lane$reg_clock_enable <= signal_wire_16;
    end
    assign signal_mux_96 = lane$reg_clock_enable ? signal_xor : lane$reg_pin_value;
    assign signal_not_3 = ~ signal_and_7;
    assign signal_mux_97 = signal_and_13 ? lane$reg_tx_enable : signal_wire_50;
    assign signal_mux_98 = signal_or_19 ? lane$reg_tx_enable : signal_mux_97;
    assign signal_mux_99 = signal_and_20 ? signal_mux_98 : lane$reg_tx_enable;
    assign signal_mux_100 = signal_or_22 ? lane$reg_tx_enable : signal_mux_99;
    assign signal_wire_17 = signal_mux_100;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_tx_enable <= signal_const;
        else
            lane$reg_tx_enable <= signal_wire_17;
    end
    assign signal_mux_101 = signal_and_13 ? lane$reg_launch_trailing : signal_wire_43;
    assign signal_mux_102 = signal_or_19 ? lane$reg_launch_trailing : signal_mux_101;
    assign signal_mux_103 = signal_and_20 ? signal_mux_102 : lane$reg_launch_trailing;
    assign signal_mux_104 = signal_or_22 ? lane$reg_launch_trailing : signal_mux_103;
    assign signal_wire_18 = signal_mux_104;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_launch_trailing <= signal_const;
        else
            lane$reg_launch_trailing <= signal_wire_18;
    end
    assign signal_eq_1 = lane$reg_trailing == lane$reg_launch_trailing;
    assign signal_and_3 = signal_eq_1 & lane$reg_tx_enable;
    assign signal_and_4 = signal_and_3 & signal_not_3;
    assign signal_mux_105 = signal_and_4 ? signal_or_1 : signal_mux_96;
    assign signal_mux_106 = signal_and_9 ? signal_mux_105 : signal_mux_118;
    assign signal_select_40 = signal_wire_44[31:31];
    assign signal_select_41 = signal_wire_44[30:30];
    assign signal_select_42 = signal_wire_44[29:29];
    assign signal_select_43 = signal_wire_44[28:28];
    assign signal_select_44 = signal_wire_44[27:27];
    assign signal_select_45 = signal_wire_44[26:26];
    assign signal_select_46 = signal_wire_44[25:25];
    assign signal_select_47 = signal_wire_44[24:24];
    assign signal_select_48 = signal_wire_44[23:23];
    assign signal_select_49 = signal_wire_44[22:22];
    assign signal_select_50 = signal_wire_44[21:21];
    assign signal_select_51 = signal_wire_44[20:20];
    assign signal_select_52 = signal_wire_44[19:19];
    assign signal_select_53 = signal_wire_44[18:18];
    assign signal_select_54 = signal_wire_44[17:17];
    assign signal_select_55 = signal_wire_44[16:16];
    assign signal_select_56 = signal_wire_44[15:15];
    assign signal_select_57 = signal_wire_44[14:14];
    assign signal_select_58 = signal_wire_44[13:13];
    assign signal_select_59 = signal_wire_44[12:12];
    assign signal_select_60 = signal_wire_44[11:11];
    assign signal_select_61 = signal_wire_44[10:10];
    assign signal_select_62 = signal_wire_44[9:9];
    assign signal_select_63 = signal_wire_44[8:8];
    assign signal_select_64 = signal_wire_44[7:7];
    assign signal_select_65 = signal_wire_44[6:6];
    assign signal_select_66 = signal_wire_44[5:5];
    assign signal_select_67 = signal_wire_44[4:4];
    assign signal_select_68 = signal_wire_44[3:3];
    assign signal_select_69 = signal_wire_44[2:2];
    assign signal_select_70 = signal_wire_44[1:1];
    assign signal_select_71 = signal_wire_44[0:0];
    assign signal_const_92 = 6'b000000;
    assign signal_sub_4 = signal_mux_206 - signal_const_64;
    assign signal_wire_19 = lsb_first_i;
    assign signal_mux_107 = signal_wire_19 ? signal_const_92 : signal_sub_4;
    always @* begin
        case (signal_mux_107)
        0:
            signal_mux_108 <= signal_select_71;
        1:
            signal_mux_108 <= signal_select_70;
        2:
            signal_mux_108 <= signal_select_69;
        3:
            signal_mux_108 <= signal_select_68;
        4:
            signal_mux_108 <= signal_select_67;
        5:
            signal_mux_108 <= signal_select_66;
        6:
            signal_mux_108 <= signal_select_65;
        7:
            signal_mux_108 <= signal_select_64;
        8:
            signal_mux_108 <= signal_select_63;
        9:
            signal_mux_108 <= signal_select_62;
        10:
            signal_mux_108 <= signal_select_61;
        11:
            signal_mux_108 <= signal_select_60;
        12:
            signal_mux_108 <= signal_select_59;
        13:
            signal_mux_108 <= signal_select_58;
        14:
            signal_mux_108 <= signal_select_57;
        15:
            signal_mux_108 <= signal_select_56;
        16:
            signal_mux_108 <= signal_select_55;
        17:
            signal_mux_108 <= signal_select_54;
        18:
            signal_mux_108 <= signal_select_53;
        19:
            signal_mux_108 <= signal_select_52;
        20:
            signal_mux_108 <= signal_select_51;
        21:
            signal_mux_108 <= signal_select_50;
        22:
            signal_mux_108 <= signal_select_49;
        23:
            signal_mux_108 <= signal_select_48;
        24:
            signal_mux_108 <= signal_select_47;
        25:
            signal_mux_108 <= signal_select_46;
        26:
            signal_mux_108 <= signal_select_45;
        27:
            signal_mux_108 <= signal_select_44;
        28:
            signal_mux_108 <= signal_select_43;
        29:
            signal_mux_108 <= signal_select_42;
        30:
            signal_mux_108 <= signal_select_41;
        default:
            signal_mux_108 <= signal_select_40;
        endcase
    end
    assign signal_mux_109 = signal_mux_108 ? signal_mux_184 : signal_const_55;
    assign signal_wire_20 = idle_output_i;
    assign signal_mux_110 = signal_wire_20 ? signal_mux_184 : signal_const_55;
    assign signal_mux_111 = signal_wire_43 ? signal_mux_109 : signal_mux_110;
    assign signal_mux_112 = signal_wire_50 ? signal_mux_111 : signal_const_55;
    assign signal_mux_113 = signal_and_13 ? lane$reg_prepared_pin_value : signal_mux_112;
    assign signal_mux_114 = signal_or_19 ? lane$reg_prepared_pin_value : signal_mux_113;
    assign signal_mux_115 = signal_and_20 ? signal_mux_114 : lane$reg_prepared_pin_value;
    assign signal_mux_116 = signal_or_22 ? lane$reg_prepared_pin_value : signal_mux_115;
    assign signal_wire_21 = signal_mux_116;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_prepared_pin_value <= signal_const_55;
        else
            lane$reg_prepared_pin_value <= signal_wire_21;
    end
    assign signal_mux_117 = signal_not_14 ? lane$reg_pin_value : lane$reg_prepared_pin_value;
    assign signal_mux_118 = signal_and_18 ? signal_mux_117 : lane$reg_pin_value;
    assign signal_mux_119 = lane$reg_busy ? signal_mux_106 : signal_mux_118;
    assign signal_mux_120 = signal_and_20 ? signal_mux_68 : signal_mux_119;
    assign signal_mux_121 = signal_or_22 ? signal_const_55 : signal_mux_120;
    assign signal_wire_22 = signal_mux_121;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_pin_value <= signal_const_55;
        else
            lane$reg_pin_value <= signal_wire_22;
    end
    assign signal_mux_122 = signal_and_13 ? lane$reg_claim_mask : signal_const_55;
    assign signal_mux_123 = signal_or_19 ? lane$reg_claim_mask : signal_mux_122;
    assign signal_mux_124 = signal_and_7 ? signal_const_55 : signal_mux_127;
    assign signal_mux_125 = signal_and_9 ? signal_mux_124 : signal_mux_127;
    assign signal_mux_126 = signal_not_14 ? lane$reg_claim_mask : lane$reg_prepared_mask;
    assign signal_mux_127 = signal_and_18 ? signal_mux_126 : lane$reg_claim_mask;
    assign signal_mux_128 = lane$reg_busy ? signal_mux_125 : signal_mux_127;
    assign signal_mux_129 = signal_and_20 ? signal_mux_123 : signal_mux_128;
    assign signal_mux_130 = signal_or_22 ? signal_const_55 : signal_mux_129;
    assign signal_wire_23 = signal_mux_130;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_claim_mask <= signal_const_55;
        else
            lane$reg_claim_mask <= signal_wire_23;
    end
    assign signal_select_72 = signal_mux_132[7:7];
    assign signal_select_73 = signal_mux_132[6:6];
    assign signal_select_74 = signal_mux_132[5:5];
    assign signal_select_75 = signal_mux_132[4:4];
    assign signal_select_76 = signal_mux_132[3:3];
    assign signal_select_77 = signal_mux_132[2:2];
    assign signal_select_78 = signal_mux_132[1:1];
    assign signal_or_2 = signal_and_12 | signal_and_11;
    assign signal_const_101 = 2'b00;
    assign signal_mux_131 = signal_and_27 ? signal_wire_54 : config_start_edge_kind;
    assign signal_wire_24 = signal_mux_131;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            config_start_edge_kind <= signal_const_101;
        else
            config_start_edge_kind <= signal_wire_24;
    end
    always @* begin
        case (config_start_edge_kind)
        0:
            signal_mux_132 <= signal_and_12;
        1:
            signal_mux_132 <= signal_and_11;
        2:
            signal_mux_132 <= signal_or_2;
        default:
            signal_mux_132 <= signal_const_55;
        endcase
    end
    assign signal_select_79 = signal_mux_132[0:0];
    assign signal_wire_25 = start_pin_i;
    assign signal_not_4 = ~ signal_wire_41;
    assign signal_and_5 = signal_wire_50 & signal_not_4;
    assign signal_not_5 = ~ signal_wire_47;
    assign signal_not_6 = ~ signal_wire_50;
    assign signal_and_6 = signal_not_6 & signal_not_5;
    assign signal_eq_2 = signal_wire_43 == signal_wire_42;
    assign signal_select_80 = signal_mux_136[31:16];
    assign signal_const_105 = 16'b0000000000000000;
    assign signal_cat = { signal_const_105,
                          signal_select_80 };
    assign signal_select_81 = signal_mux_135[31:8];
    assign signal_cat_1 = { signal_const_55,
                            signal_select_81 };
    assign signal_select_82 = signal_mux_134[31:4];
    assign signal_const_107 = 4'b0000;
    assign signal_cat_2 = { signal_const_107,
                            signal_select_82 };
    assign signal_select_83 = signal_mux_133[31:2];
    assign signal_cat_3 = { signal_const_101,
                            signal_select_83 };
    assign signal_select_84 = signal_wire_44[31:1];
    assign signal_cat_4 = { signal_const,
                            signal_select_84 };
    assign signal_select_85 = signal_wire_45[0:0];
    assign signal_mux_133 = signal_select_85 ? signal_cat_4 : signal_wire_44;
    assign signal_select_86 = signal_wire_45[1:1];
    assign signal_mux_134 = signal_select_86 ? signal_cat_3 : signal_mux_133;
    assign signal_select_87 = signal_wire_45[2:2];
    assign signal_mux_135 = signal_select_87 ? signal_cat_2 : signal_mux_134;
    assign signal_select_88 = signal_wire_45[3:3];
    assign signal_mux_136 = signal_select_88 ? signal_cat_1 : signal_mux_135;
    assign signal_select_89 = signal_wire_45[4:4];
    assign signal_mux_137 = signal_select_89 ? signal_cat : signal_mux_136;
    assign signal_select_90 = signal_wire_45[5:5];
    assign signal_mux_138 = signal_select_90 ? signal_const_10 : signal_mux_137;
    assign signal_eq_3 = signal_mux_138 == signal_const_10;
    assign signal_not_7 = ~ signal_eq_3;
    assign signal_const_110 = 6'b100000;
    assign signal_lt = signal_const_110 < signal_wire_45;
    assign signal_eq_4 = signal_wire_45 == signal_const_92;
    assign signal_or_3 = signal_or_14 | signal_or_12;
    assign signal_or_4 = signal_or_3 | signal_eq_4;
    assign signal_or_5 = signal_or_4 | signal_lt;
    assign signal_or_6 = signal_or_5 | signal_not_7;
    assign signal_or_7 = signal_or_6 | signal_eq_2;
    assign signal_or_8 = signal_or_7 | signal_and_6;
    assign signal_or_9 = signal_or_8 | signal_and_5;
    assign signal_not_8 = ~ signal_or_9;
    assign signal_not_9 = ~ signal_wire_57;
    assign signal_not_10 = ~ lane$reg_armed;
    assign signal_mux_139 = signal_and_13 ? lane$reg_busy : signal_const;
    assign signal_mux_140 = signal_or_19 ? lane$reg_busy : signal_mux_139;
    assign signal_mux_141 = signal_and_13 ? lane$reg_bit_count : signal_mux_206;
    assign signal_mux_142 = signal_or_19 ? lane$reg_bit_count : signal_mux_141;
    assign signal_mux_143 = signal_and_20 ? signal_mux_142 : lane$reg_bit_count;
    assign signal_mux_144 = signal_or_22 ? lane$reg_bit_count : signal_mux_143;
    assign signal_wire_26 = signal_mux_144;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_bit_count <= signal_const_92;
        else
            lane$reg_bit_count <= signal_wire_26;
    end
    assign signal_sub_5 = lane$reg_bit_count - signal_const_64;
    assign signal_mux_145 = signal_and_13 ? lane$reg_bit_index : signal_const_92;
    assign signal_mux_146 = signal_or_19 ? lane$reg_bit_index : signal_mux_145;
    assign signal_add_1 = lane$reg_bit_index + signal_const_64;
    assign signal_mux_147 = lane$reg_trailing ? signal_add_1 : lane$reg_bit_index;
    assign signal_mux_148 = signal_and_7 ? lane$reg_bit_index : signal_mux_147;
    assign signal_mux_149 = signal_and_9 ? signal_mux_148 : lane$reg_bit_index;
    assign signal_mux_150 = lane$reg_busy ? signal_mux_149 : lane$reg_bit_index;
    assign signal_mux_151 = signal_and_20 ? signal_mux_146 : signal_mux_150;
    assign signal_mux_152 = signal_or_22 ? lane$reg_bit_index : signal_mux_151;
    assign signal_wire_27 = signal_mux_152;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_bit_index <= signal_const_92;
        else
            lane$reg_bit_index <= signal_wire_27;
    end
    assign signal_eq_5 = lane$reg_bit_index == signal_sub_5;
    assign signal_mux_153 = signal_and_13 ? lane$reg_trailing : signal_const;
    assign signal_mux_154 = signal_or_19 ? lane$reg_trailing : signal_mux_153;
    assign signal_mux_155 = lane$reg_trailing ? signal_const : signal_const_1;
    assign signal_mux_156 = signal_and_7 ? lane$reg_trailing : signal_mux_155;
    assign signal_mux_157 = signal_and_9 ? signal_mux_156 : lane$reg_trailing;
    assign signal_mux_158 = lane$reg_busy ? signal_mux_157 : lane$reg_trailing;
    assign signal_mux_159 = signal_and_20 ? signal_mux_154 : signal_mux_158;
    assign signal_mux_160 = signal_or_22 ? lane$reg_trailing : signal_mux_159;
    assign signal_wire_28 = signal_mux_160;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_trailing <= signal_const;
        else
            lane$reg_trailing <= signal_wire_28;
    end
    assign signal_and_7 = lane$reg_trailing & signal_eq_5;
    assign signal_mux_161 = signal_and_7 ? signal_const : signal_mux_191;
    assign signal_select_91 = signal_mux_163[7:7];
    assign signal_select_92 = signal_mux_163[6:6];
    assign signal_select_93 = signal_mux_163[5:5];
    assign signal_select_94 = signal_mux_163[4:4];
    assign signal_select_95 = signal_mux_163[3:3];
    assign signal_select_96 = signal_mux_163[2:2];
    assign signal_select_97 = signal_mux_163[1:1];
    assign signal_or_10 = signal_and_12 | signal_and_11;
    assign signal_mux_162 = signal_and_27 ? signal_wire_53 : config_pacing_edge_kind;
    assign signal_wire_29 = signal_mux_162;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            config_pacing_edge_kind <= signal_const_101;
        else
            config_pacing_edge_kind <= signal_wire_29;
    end
    always @* begin
        case (config_pacing_edge_kind)
        0:
            signal_mux_163 <= signal_and_12;
        1:
            signal_mux_163 <= signal_and_11;
        2:
            signal_mux_163 <= signal_or_10;
        default:
            signal_mux_163 <= signal_const_55;
        endcase
    end
    assign signal_select_98 = signal_mux_163[0:0];
    assign signal_mux_164 = signal_and_27 ? signal_wire_49 : config_pacing_pin;
    assign signal_wire_30 = signal_mux_164;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            config_pacing_pin <= signal_const_14;
        else
            config_pacing_pin <= signal_wire_30;
    end
    always @* begin
        case (config_pacing_pin)
        0:
            signal_mux_165 <= signal_select_98;
        1:
            signal_mux_165 <= signal_select_97;
        2:
            signal_mux_165 <= signal_select_96;
        3:
            signal_mux_165 <= signal_select_95;
        4:
            signal_mux_165 <= signal_select_94;
        5:
            signal_mux_165 <= signal_select_93;
        6:
            signal_mux_165 <= signal_select_92;
        default:
            signal_mux_165 <= signal_select_91;
        endcase
    end
    assign signal_const_128 = 16'b0000000000000001;
    assign signal_mux_166 = signal_and_13 ? lane$reg_remaining : signal_const_128;
    assign signal_mux_167 = signal_or_19 ? lane$reg_remaining : signal_mux_166;
    assign signal_mux_168 = signal_and_13 ? lane$reg_half_period : signal_const_128;
    assign signal_mux_169 = signal_or_19 ? lane$reg_half_period : signal_mux_168;
    assign signal_mux_170 = signal_and_20 ? signal_mux_169 : lane$reg_half_period;
    assign signal_mux_171 = signal_or_22 ? lane$reg_half_period : signal_mux_170;
    assign signal_wire_31 = signal_mux_171;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_half_period <= signal_const_105;
        else
            lane$reg_half_period <= signal_wire_31;
    end
    assign signal_not_11 = ~ lane$reg_observed;
    assign signal_mux_172 = signal_not_11 ? lane$reg_half_period : signal_mux_173;
    assign signal_sub_6 = lane$reg_remaining - signal_const_128;
    assign signal_not_12 = ~ signal_and_9;
    assign signal_not_13 = ~ lane$reg_observed;
    assign signal_and_8 = signal_not_13 & signal_not_12;
    assign signal_mux_173 = signal_and_8 ? signal_sub_6 : lane$reg_remaining;
    assign signal_mux_174 = signal_and_9 ? signal_mux_172 : signal_mux_173;
    assign signal_mux_175 = lane$reg_busy ? signal_mux_174 : lane$reg_remaining;
    assign signal_mux_176 = signal_and_20 ? signal_mux_167 : signal_mux_175;
    assign signal_mux_177 = signal_or_22 ? signal_const_105 : signal_mux_176;
    assign signal_wire_32 = signal_mux_177;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_remaining <= signal_const_105;
        else
            lane$reg_remaining <= signal_wire_32;
    end
    assign signal_eq_6 = lane$reg_remaining == signal_const_128;
    assign signal_mux_178 = signal_and_13 ? lane$reg_observed : vdd;
    assign signal_mux_179 = signal_or_19 ? lane$reg_observed : signal_mux_178;
    assign signal_mux_180 = signal_and_20 ? signal_mux_179 : lane$reg_observed;
    assign signal_mux_181 = signal_or_22 ? lane$reg_observed : signal_mux_180;
    assign signal_wire_33 = signal_mux_181;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_observed <= signal_const;
        else
            lane$reg_observed <= signal_wire_33;
    end
    assign signal_mux_182 = lane$reg_observed ? signal_mux_165 : signal_eq_6;
    assign signal_and_9 = lane$reg_busy & signal_mux_182;
    assign signal_mux_183 = signal_and_9 ? signal_mux_161 : signal_mux_191;
    assign signal_wire_34 = occupied_i;
    always @* begin
        case (signal_wire_48)
        0:
            signal_mux_184 <= signal_const_75;
        1:
            signal_mux_184 <= signal_const_74;
        2:
            signal_mux_184 <= signal_const_73;
        3:
            signal_mux_184 <= signal_const_72;
        4:
            signal_mux_184 <= signal_const_71;
        5:
            signal_mux_184 <= signal_const_70;
        6:
            signal_mux_184 <= signal_const_69;
        default:
            signal_mux_184 <= signal_const_68;
        endcase
    end
    assign signal_mux_185 = signal_wire_50 ? signal_mux_184 : signal_const_55;
    assign signal_mux_186 = signal_and_13 ? lane$reg_prepared_mask : signal_mux_185;
    assign signal_mux_187 = signal_or_19 ? lane$reg_prepared_mask : signal_mux_186;
    assign signal_mux_188 = signal_and_20 ? signal_mux_187 : lane$reg_prepared_mask;
    assign signal_mux_189 = signal_or_22 ? lane$reg_prepared_mask : signal_mux_188;
    assign signal_wire_35 = signal_mux_189;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_prepared_mask <= signal_const_55;
        else
            lane$reg_prepared_mask <= signal_wire_35;
    end
    assign signal_and_10 = lane$reg_prepared_mask & signal_wire_34;
    assign signal_eq_7 = signal_and_10 == signal_const_55;
    assign signal_not_14 = ~ signal_eq_7;
    assign signal_mux_190 = signal_not_14 ? lane$reg_busy : signal_const_1;
    assign signal_mux_191 = signal_and_18 ? signal_mux_190 : lane$reg_busy;
    assign signal_mux_192 = lane$reg_busy ? signal_mux_183 : signal_mux_191;
    assign signal_mux_193 = signal_and_20 ? signal_mux_140 : signal_mux_192;
    assign signal_select_99 = signal_mux_195[7:7];
    assign signal_select_100 = signal_mux_195[6:6];
    assign signal_select_101 = signal_mux_195[5:5];
    assign signal_select_102 = signal_mux_195[4:4];
    assign signal_select_103 = signal_mux_195[3:3];
    assign signal_select_104 = signal_mux_195[2:2];
    assign signal_select_105 = signal_mux_195[1:1];
    assign signal_or_11 = signal_and_12 | signal_and_11;
    assign signal_not_15 = ~ front$reg_stage1;
    assign signal_and_11 = signal_not_15 & front$reg_previous;
    assign signal_wire_36 = front$reg_stage1;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            front$reg_previous <= signal_const_55;
        else
            front$reg_previous <= signal_wire_36;
    end
    assign signal_not_16 = ~ front$reg_previous;
    assign signal_and_12 = front$reg_stage1 & signal_not_16;
    assign signal_mux_194 = signal_and_27 ? signal_wire_51 : config_cancel_edge_kind;
    assign signal_wire_37 = signal_mux_194;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            config_cancel_edge_kind <= signal_const_101;
        else
            config_cancel_edge_kind <= signal_wire_37;
    end
    always @* begin
        case (config_cancel_edge_kind)
        0:
            signal_mux_195 <= signal_and_12;
        1:
            signal_mux_195 <= signal_and_11;
        2:
            signal_mux_195 <= signal_or_11;
        default:
            signal_mux_195 <= signal_const_55;
        endcase
    end
    assign signal_select_106 = signal_mux_195[0:0];
    assign signal_wire_38 = cancel_pin_i;
    assign signal_mux_196 = signal_and_27 ? signal_wire_38 : config_cancel_pin;
    assign signal_wire_39 = signal_mux_196;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            config_cancel_pin <= signal_const_14;
        else
            config_cancel_pin <= signal_wire_39;
    end
    always @* begin
        case (config_cancel_pin)
        0:
            signal_mux_197 <= signal_select_106;
        1:
            signal_mux_197 <= signal_select_105;
        2:
            signal_mux_197 <= signal_select_104;
        3:
            signal_mux_197 <= signal_select_103;
        4:
            signal_mux_197 <= signal_select_102;
        5:
            signal_mux_197 <= signal_select_101;
        6:
            signal_mux_197 <= signal_select_100;
        default:
            signal_mux_197 <= signal_select_99;
        endcase
    end
    assign signal_mux_198 = signal_and_27 ? signal_wire_52 : config_cancel_enable;
    assign signal_wire_40 = signal_mux_198;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            config_cancel_enable <= signal_const;
        else
            config_cancel_enable <= signal_wire_40;
    end
    assign vdd = 1'b1;
    assign signal_wire_41 = tx_valid_i;
    assign signal_not_17 = ~ signal_wire_41;
    assign signal_and_13 = signal_wire_50 & signal_not_17;
    assign signal_mux_199 = signal_and_13 ? lane$reg_armed : vdd;
    assign signal_not_18 = ~ signal_wire_47;
    assign signal_not_19 = ~ signal_wire_50;
    assign signal_and_14 = signal_not_19 & signal_not_18;
    assign signal_wire_42 = sample_trailing_i;
    assign signal_wire_43 = launch_trailing_i;
    assign signal_eq_8 = signal_wire_43 == signal_wire_42;
    assign signal_select_107 = signal_mux_203[31:16];
    assign signal_cat_5 = { signal_const_105,
                            signal_select_107 };
    assign signal_select_108 = signal_mux_202[31:8];
    assign signal_cat_6 = { signal_const_55,
                            signal_select_108 };
    assign signal_select_109 = signal_mux_201[31:4];
    assign signal_cat_7 = { signal_const_107,
                            signal_select_109 };
    assign signal_select_110 = signal_mux_200[31:2];
    assign signal_cat_8 = { signal_const_101,
                            signal_select_110 };
    assign signal_select_111 = signal_wire_44[31:1];
    assign signal_cat_9 = { signal_const,
                            signal_select_111 };
    assign signal_wire_44 = tx_value_i;
    assign signal_select_112 = signal_mux_206[0:0];
    assign signal_mux_200 = signal_select_112 ? signal_cat_9 : signal_wire_44;
    assign signal_select_113 = signal_mux_206[1:1];
    assign signal_mux_201 = signal_select_113 ? signal_cat_8 : signal_mux_200;
    assign signal_select_114 = signal_mux_206[2:2];
    assign signal_mux_202 = signal_select_114 ? signal_cat_7 : signal_mux_201;
    assign signal_select_115 = signal_mux_206[3:3];
    assign signal_mux_203 = signal_select_115 ? signal_cat_6 : signal_mux_202;
    assign signal_select_116 = signal_mux_206[4:4];
    assign signal_mux_204 = signal_select_116 ? signal_cat_5 : signal_mux_203;
    assign signal_select_117 = signal_mux_206[5:5];
    assign signal_mux_205 = signal_select_117 ? signal_const_10 : signal_mux_204;
    assign signal_eq_9 = signal_mux_205 == signal_const_10;
    assign signal_not_20 = ~ signal_eq_9;
    assign signal_lt_1 = signal_const_110 < signal_mux_206;
    assign signal_wire_45 = bit_count_i;
    assign signal_wire_46 = input_pin_i;
    assign signal_eq_10 = signal_wire_49 == signal_wire_46;
    assign signal_wire_47 = rx_enable_i;
    assign signal_and_15 = signal_wire_47 & signal_eq_10;
    assign signal_wire_48 = output_pin_i;
    assign signal_wire_49 = pacing_pin_i;
    assign signal_eq_11 = signal_wire_49 == signal_wire_48;
    assign signal_wire_50 = tx_enable_i;
    assign signal_and_16 = signal_wire_50 & signal_eq_11;
    assign signal_or_12 = signal_and_16 | signal_and_15;
    assign signal_const_164 = 2'b11;
    assign signal_wire_51 = cancel_edge_kind_i;
    assign signal_eq_12 = signal_wire_51 == signal_const_164;
    assign signal_wire_52 = cancel_enable_i;
    assign signal_and_17 = signal_wire_52 & signal_eq_12;
    assign signal_wire_53 = pacing_edge_kind_i;
    assign signal_eq_13 = signal_wire_53 == signal_const_164;
    assign signal_wire_54 = start_edge_kind_i;
    assign signal_eq_14 = signal_wire_54 == signal_const_164;
    assign signal_or_13 = signal_eq_14 | signal_eq_13;
    assign signal_or_14 = signal_or_13 | signal_and_17;
    assign signal_or_15 = signal_or_14 | signal_or_12;
    assign signal_mux_206 = signal_or_15 ? signal_const_92 : signal_wire_45;
    assign signal_eq_15 = signal_mux_206 == signal_const_92;
    assign signal_or_16 = signal_eq_15 | signal_lt_1;
    assign signal_or_17 = signal_or_16 | signal_not_20;
    assign signal_or_18 = signal_or_17 | signal_eq_8;
    assign signal_or_19 = signal_or_18 | signal_and_14;
    assign signal_mux_207 = signal_or_19 ? lane$reg_armed : signal_mux_199;
    assign signal_and_18 = lane$reg_armed & signal_mux_213;
    assign signal_mux_208 = signal_and_18 ? signal_const : lane$reg_armed;
    assign signal_not_21 = ~ lane$reg_armed;
    assign signal_not_22 = ~ lane$reg_busy;
    assign signal_and_19 = signal_wire_60 & signal_not_22;
    assign signal_and_20 = signal_and_19 & signal_not_21;
    assign signal_mux_209 = signal_and_20 ? signal_mux_207 : signal_mux_208;
    assign signal_mux_210 = signal_or_22 ? signal_const : signal_mux_209;
    assign signal_wire_55 = signal_mux_210;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_armed <= signal_const;
        else
            lane$reg_armed <= signal_wire_55;
    end
    assign signal_or_20 = lane$reg_armed | lane$reg_busy;
    assign signal_wire_56 = signal_or_20;
    assign signal_and_21 = signal_wire_56 & config_cancel_enable;
    assign signal_and_22 = signal_and_21 & signal_mux_197;
    assign signal_wire_57 = abort_i;
    assign signal_or_21 = signal_wire_57 | signal_and_22;
    assign signal_not_23 = ~ signal_wire_59;
    assign signal_or_22 = signal_not_23 | signal_or_21;
    assign signal_mux_211 = signal_or_22 ? signal_const : signal_mux_193;
    assign signal_wire_58 = signal_mux_211;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            lane$reg_busy <= signal_const;
        else
            lane$reg_busy <= signal_wire_58;
    end
    assign signal_not_24 = ~ lane$reg_busy;
    assign signal_wire_59 = enable_i;
    assign signal_and_23 = signal_wire_59 & signal_not_24;
    assign signal_and_24 = signal_and_23 & signal_not_10;
    assign signal_wire_60 = arm_valid_i;
    assign signal_and_25 = signal_wire_60 & signal_and_24;
    assign signal_and_26 = signal_and_25 & signal_not_9;
    assign signal_and_27 = signal_and_26 & signal_not_8;
    assign signal_mux_212 = signal_and_27 ? signal_wire_25 : config_start_pin;
    assign signal_wire_61 = signal_mux_212;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            config_start_pin <= signal_const_14;
        else
            config_start_pin <= signal_wire_61;
    end
    always @* begin
        case (config_start_pin)
        0:
            signal_mux_213 <= signal_select_79;
        1:
            signal_mux_213 <= signal_select_78;
        2:
            signal_mux_213 <= signal_select_77;
        3:
            signal_mux_213 <= signal_select_76;
        4:
            signal_mux_213 <= signal_select_75;
        5:
            signal_mux_213 <= signal_select_74;
        6:
            signal_mux_213 <= signal_select_73;
        default:
            signal_mux_213 <= signal_select_72;
        endcase
    end
    assign signal_wire_62 = reset_i;
    assign signal_wire_63 = clock_i;
    assign signal_wire_64 = pin_async_i;
    assign signal_wire_65 = signal_wire_64;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            front$reg_stage0 <= signal_const_55;
        else
            front$reg_stage0 <= signal_wire_65;
    end
    assign signal_wire_66 = front$reg_stage0;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            front$reg_stage1 <= signal_const_55;
        else
            front$reg_stage1 <= signal_wire_66;
    end
    assign snapshot_o = front$reg_stage1;
    assign start_edge_o = signal_mux_213;
    assign pacing_edge_o = signal_mux_165;
    assign cancel_edge_o = signal_and_22;
    assign armed_o = lane$reg_armed;
    assign busy_o = lane$reg_busy;
    assign claim_mask_o = lane$reg_claim_mask;
    assign pin_value_o = lane$reg_pin_value;
    assign pin_oe_o = lane$reg_pin_oe;
    assign done_o = lane$reg_done_;
    assign rx_valid_o = lane$reg_rx_valid;
    assign rx_data_o = lane$reg_rx_data;
    assign rejected_o = lane$reg_rejected;
    assign underrun_o = lane$reg_underrun;
    assign overrun_o = lane$reg_overrun;

endmodule
