module observed_transfer_bank (
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
    software_claim_valid_i,
    software_claim_mask_i,
    software_release_valid_i,
    software_release_mask_i,
    software_write_valid_i,
    software_write_mask_i,
    software_write_value_i,
    software_write_open_drain_i,
    software_write_oe_i,
    idle_clock_i,
    arm_ready_o,
    transaction_done_o,
    transaction_rejected_o,
    software_rejected_o,
    snapshot_o,
    start_edge_o,
    pacing_edge_o,
    cancel_edge_o,
    armed_o,
    busy_o,
    lane_claim_o,
    lane_pin_value_o,
    lane_pin_oe_o,
    done_o,
    rx_valid_o,
    rx_data_o,
    rejected_o,
    underrun_o,
    overrun_o,
    pins_o,
    pin_oe_o,
    software_claim_o,
    engine_claim_o,
    bank_rejected_o,
    bank_conflict_o
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
    input software_claim_valid_i;
    input [7:0] software_claim_mask_i;
    input software_release_valid_i;
    input [7:0] software_release_mask_i;
    input software_write_valid_i;
    input [7:0] software_write_mask_i;
    input [7:0] software_write_value_i;
    input software_write_open_drain_i;
    input [7:0] software_write_oe_i;
    input idle_clock_i;
    output arm_ready_o;
    output transaction_done_o;
    output transaction_rejected_o;
    output software_rejected_o;
    output [7:0] snapshot_o;
    output start_edge_o;
    output pacing_edge_o;
    output cancel_edge_o;
    output armed_o;
    output busy_o;
    output [7:0] lane_claim_o;
    output [7:0] lane_pin_value_o;
    output [7:0] lane_pin_oe_o;
    output done_o;
    output rx_valid_o;
    output [31:0] rx_data_o;
    output rejected_o;
    output underrun_o;
    output overrun_o;
    output [7:0] pins_o;
    output [7:0] pin_oe_o;
    output [7:0] software_claim_o;
    output [7:0] engine_claim_o;
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
    wire [7:0] signal_const_2;
    wire [7:0] signal_wire_1;
    wire [7:0] signal_mux_3;
    wire [7:0] signal_mux_4;
    wire [7:0] signal_and_2;
    wire [7:0] signal_not;
    wire [7:0] signal_and_3;
    wire [7:0] signal_or_1;
    wire [7:0] signal_mux_5;
    wire [7:0] signal_mux_6;
    wire [7:0] signal_mux_7;
    wire [7:0] signal_wire_2;
    reg [7:0] bank$reg_pin_oe;
    wire [7:0] signal_wire_3;
    wire [7:0] signal_mux_8;
    wire [7:0] signal_mux_9;
    wire signal_wire_4;
    wire signal_and_4;
    wire signal_and_5;
    wire [7:0] signal_mux_10;
    wire [7:0] signal_and_6;
    wire [7:0] signal_not_1;
    wire [7:0] signal_and_7;
    wire [7:0] signal_or_2;
    wire [7:0] signal_mux_11;
    wire [7:0] signal_mux_12;
    wire [7:0] signal_mux_13;
    wire [7:0] signal_wire_5;
    reg [7:0] bank$reg_pins;
    wire [31:0] signal_const_9;
    wire [31:0] signal_mux_14;
    wire [31:0] signal_mux_15;
    wire signal_select;
    wire signal_select_1;
    wire signal_select_2;
    wire signal_select_3;
    wire signal_select_4;
    wire signal_select_5;
    wire signal_select_6;
    wire signal_select_7;
    wire [2:0] signal_const_13;
    wire [2:0] signal_mux_16;
    wire [2:0] signal_mux_17;
    wire [2:0] signal_mux_18;
    wire [2:0] signal_mux_19;
    wire [2:0] signal_wire_6;
    reg [2:0] transfer$lane$reg_input_pin;
    reg signal_mux_20;
    wire [31:0] signal_mux_21;
    wire [31:0] signal_const_14;
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
    reg [31:0] signal_mux_22;
    wire [31:0] signal_not_2;
    wire [31:0] signal_and_8;
    wire [31:0] signal_or_3;
    wire [31:0] signal_mux_23;
    wire [31:0] signal_mux_24;
    wire [31:0] signal_mux_25;
    wire [31:0] signal_mux_26;
    wire [31:0] signal_mux_27;
    wire [31:0] signal_wire_7;
    reg [31:0] transfer$lane$reg_rx_value;
    wire signal_mux_28;
    wire signal_mux_29;
    wire signal_mux_30;
    wire signal_mux_31;
    wire signal_wire_8;
    reg transfer$lane$reg_sample_trailing;
    wire signal_eq;
    wire [31:0] signal_mux_32;
    wire [31:0] signal_mux_33;
    wire [31:0] signal_mux_34;
    wire [31:0] signal_mux_35;
    wire [31:0] signal_mux_36;
    wire [31:0] signal_mux_37;
    wire [31:0] signal_mux_38;
    wire [31:0] signal_mux_39;
    wire [31:0] signal_wire_9;
    reg [31:0] transfer$lane$reg_rx_data;
    wire signal_mux_40;
    wire signal_mux_41;
    wire signal_mux_42;
    wire signal_mux_43;
    wire signal_mux_44;
    wire signal_mux_45;
    wire signal_mux_46;
    wire signal_wire_10;
    reg transfer$lane$reg_rx_valid;
    wire [7:0] signal_mux_47;
    wire [7:0] signal_mux_48;
    wire [7:0] signal_mux_49;
    wire [7:0] signal_mux_50;
    wire [7:0] signal_mux_51;
    wire [7:0] signal_mux_52;
    wire [7:0] signal_mux_53;
    wire [7:0] signal_mux_54;
    wire [7:0] signal_mux_55;
    wire [7:0] signal_wire_11;
    reg [7:0] transfer$lane$reg_pin_oe;
    wire [7:0] signal_mux_56;
    wire [7:0] signal_mux_57;
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
    wire [31:0] signal_mux_58;
    wire [31:0] signal_mux_59;
    wire [31:0] signal_mux_60;
    wire [31:0] signal_mux_61;
    wire [31:0] signal_wire_12;
    reg [31:0] transfer$lane$reg_tx_value;
    wire signal_select_39;
    wire [5:0] signal_const_59;
    wire [5:0] signal_add;
    wire [5:0] signal_const_60;
    wire [5:0] signal_sub;
    wire [5:0] signal_sub_1;
    wire [5:0] signal_mux_62;
    wire [5:0] signal_sub_2;
    wire [5:0] signal_sub_3;
    wire signal_mux_63;
    wire signal_mux_64;
    wire signal_mux_65;
    wire signal_mux_66;
    wire signal_wire_13;
    reg transfer$lane$reg_lsb_first;
    wire [5:0] signal_mux_67;
    wire [5:0] signal_mux_68;
    reg signal_mux_69;
    wire [7:0] signal_mux_70;
    wire [7:0] signal_const_63;
    wire [7:0] signal_const_64;
    wire [7:0] signal_const_65;
    wire [7:0] signal_const_66;
    wire [7:0] signal_const_67;
    wire [7:0] signal_const_68;
    wire [7:0] signal_const_69;
    wire [7:0] signal_const_70;
    wire [2:0] signal_mux_71;
    wire [2:0] signal_mux_72;
    wire [2:0] signal_mux_73;
    wire [2:0] signal_mux_74;
    wire [2:0] signal_wire_14;
    reg [2:0] transfer$lane$reg_output_pin;
    reg [7:0] signal_mux_75;
    wire [7:0] signal_not_3;
    wire [7:0] signal_and_9;
    wire [7:0] signal_or_4;
    wire [2:0] signal_mux_76;
    wire [2:0] signal_mux_77;
    wire [2:0] signal_mux_78;
    wire [2:0] signal_mux_79;
    wire [2:0] signal_wire_15;
    reg [2:0] transfer$lane$reg_clock_pin;
    reg [7:0] signal_mux_80;
    wire [7:0] signal_xor;
    wire gnd;
    wire signal_mux_81;
    wire signal_mux_82;
    wire signal_mux_83;
    wire signal_mux_84;
    wire signal_wire_16;
    reg transfer$lane$reg_clock_enable;
    wire [7:0] signal_mux_85;
    wire signal_not_4;
    wire signal_mux_86;
    wire signal_mux_87;
    wire signal_mux_88;
    wire signal_mux_89;
    wire signal_wire_17;
    reg transfer$lane$reg_tx_enable;
    wire signal_mux_90;
    wire signal_mux_91;
    wire signal_mux_92;
    wire signal_mux_93;
    wire signal_wire_18;
    reg transfer$lane$reg_launch_trailing;
    wire signal_eq_1;
    wire signal_and_10;
    wire signal_and_11;
    wire [7:0] signal_mux_94;
    wire [7:0] signal_mux_95;
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
    wire [5:0] signal_const_87;
    wire [5:0] signal_sub_4;
    wire signal_wire_19;
    wire [5:0] signal_mux_96;
    reg signal_mux_97;
    wire [7:0] signal_mux_98;
    wire signal_wire_20;
    wire [7:0] signal_mux_99;
    wire [7:0] signal_mux_100;
    wire [7:0] signal_mux_101;
    wire [7:0] signal_mux_102;
    wire [7:0] signal_mux_103;
    wire [7:0] signal_mux_104;
    wire [7:0] signal_mux_105;
    wire [7:0] signal_wire_21;
    reg [7:0] transfer$lane$reg_prepared_pin_value;
    wire [7:0] signal_mux_106;
    wire [7:0] signal_mux_107;
    wire [7:0] signal_mux_108;
    wire [7:0] signal_mux_109;
    wire [7:0] signal_mux_110;
    wire [7:0] signal_wire_22;
    reg [7:0] transfer$lane$reg_pin_value;
    wire [7:0] signal_mux_111;
    wire [7:0] signal_mux_112;
    wire [7:0] signal_mux_113;
    wire [7:0] signal_mux_114;
    wire [7:0] signal_mux_115;
    wire [7:0] signal_mux_116;
    wire [7:0] signal_mux_117;
    wire [7:0] signal_mux_118;
    wire [7:0] signal_mux_119;
    wire [7:0] signal_wire_23;
    reg [7:0] transfer$lane$reg_claim_mask;
    wire signal_or_5;
    wire signal_or_6;
    wire signal_and_12;
    wire signal_wire_24;
    reg reg_software_rejected;
    wire signal_mux_120;
    wire signal_mux_121;
    reg signal_cases;
    wire signal_mux_122;
    wire wire_transaction_rejected;
    wire signal_wire_25;
    reg reg_transaction_rejected;
    reg signal_cases_1;
    wire signal_mux_123;
    wire wire_transaction_done;
    wire signal_not_5;
    wire [1:0] signal_const_104;
    wire [1:0] signal_mux_124;
    wire [1:0] signal_const_176;
    wire signal_or_7;
    wire signal_or_8;
    wire signal_or_9;
    wire signal_or_10;
    wire [1:0] signal_mux_125;
    wire signal_wire_26;
    reg reg_internal_pending;
    wire signal_or_11;
    wire [7:0] signal_mux_126;
    wire [7:0] signal_wire_27;
    wire signal_or_12;
    wire [7:0] signal_mux_127;
    wire [7:0] signal_and_13;
    wire signal_eq_2;
    wire signal_not_6;
    wire signal_and_14;
    wire [7:0] signal_mux_128;
    wire [7:0] signal_not_7;
    wire [7:0] signal_and_15;
    wire signal_eq_3;
    wire signal_not_8;
    wire signal_and_16;
    wire [7:0] signal_not_9;
    wire [7:0] signal_and_17;
    wire [7:0] signal_mux_129;
    wire [7:0] signal_or_13;
    wire [7:0] signal_mux_130;
    wire [7:0] signal_mux_131;
    wire [7:0] signal_mux_132;
    wire [7:0] signal_mux_133;
    wire [7:0] signal_mux_134;
    wire [7:0] signal_wire_28;
    reg [7:0] bank$reg_engine_claim;
    wire [7:0] signal_mux_135;
    wire [7:0] signal_and_18;
    wire signal_eq_4;
    wire signal_not_10;
    wire signal_and_19;
    wire signal_and_20;
    wire signal_wire_29;
    wire signal_and_21;
    wire signal_or_14;
    wire signal_or_15;
    wire signal_or_16;
    wire signal_wire_30;
    wire signal_wire_31;
    reg reg_claim_pending;
    wire signal_and_22;
    wire signal_not_11;
    wire signal_and_23;
    wire signal_mux_136;
    wire signal_mux_137;
    wire signal_mux_138;
    wire signal_mux_139;
    wire signal_mux_140;
    wire signal_mux_141;
    reg signal_cases_2;
    wire signal_mux_142;
    wire wire_clear;
    wire signal_and_24;
    wire signal_mux_143;
    wire signal_mux_144;
    wire signal_mux_145;
    wire signal_mux_146;
    wire signal_mux_147;
    wire signal_mux_148;
    wire signal_mux_149;
    wire signal_wire_32;
    reg transfer$lane$reg_done_;
    wire signal_or_17;
    wire signal_mux_150;
    wire signal_wire_33;
    wire signal_not_12;
    wire signal_mux_151;
    wire signal_mux_152;
    wire signal_mux_153;
    wire signal_mux_154;
    wire signal_wire_34;
    reg transfer$lane$reg_rx_enable;
    wire signal_and_25;
    wire signal_mux_155;
    wire signal_mux_156;
    wire signal_mux_157;
    wire signal_mux_158;
    wire signal_mux_159;
    wire signal_mux_160;
    wire signal_wire_35;
    reg transfer$lane$reg_overrun;
    wire signal_mux_161;
    wire signal_mux_162;
    wire signal_mux_163;
    wire signal_mux_164;
    wire signal_wire_36;
    reg transfer$lane$reg_underrun;
    wire signal_mux_165;
    wire signal_mux_166;
    wire signal_mux_167;
    wire signal_mux_168;
    wire signal_select_72;
    wire signal_select_73;
    wire signal_select_74;
    wire signal_select_75;
    wire signal_select_76;
    wire signal_select_77;
    wire signal_select_78;
    wire [7:0] signal_or_18;
    wire [1:0] signal_mux_169;
    wire [1:0] signal_wire_37;
    reg [1:0] transfer$config_cancel_edge_kind;
    reg [7:0] signal_mux_170;
    wire signal_select_79;
    wire [2:0] signal_wire_38;
    wire [2:0] signal_mux_171;
    wire [2:0] signal_wire_39;
    reg [2:0] transfer$config_cancel_pin;
    reg signal_mux_172;
    wire signal_mux_173;
    wire signal_wire_40;
    reg transfer$config_cancel_enable;
    wire signal_mux_174;
    wire signal_mux_175;
    wire signal_mux_176;
    wire signal_not_13;
    wire signal_mux_177;
    wire signal_mux_178;
    wire [5:0] signal_mux_179;
    wire [5:0] signal_mux_180;
    wire [5:0] signal_mux_181;
    wire [5:0] signal_mux_182;
    wire [5:0] signal_wire_41;
    reg [5:0] transfer$lane$reg_bit_count;
    wire [5:0] signal_sub_5;
    wire [5:0] signal_mux_183;
    wire [5:0] signal_mux_184;
    wire [5:0] signal_add_1;
    wire [5:0] signal_mux_185;
    wire [5:0] signal_mux_186;
    wire [5:0] signal_mux_187;
    wire [5:0] signal_mux_188;
    wire [5:0] signal_mux_189;
    wire [5:0] signal_mux_190;
    wire [5:0] signal_wire_42;
    reg [5:0] transfer$lane$reg_bit_index;
    wire signal_eq_5;
    wire signal_mux_191;
    wire signal_mux_192;
    wire signal_mux_193;
    wire signal_mux_194;
    wire signal_mux_195;
    wire signal_mux_196;
    wire signal_mux_197;
    wire signal_mux_198;
    wire signal_wire_43;
    reg transfer$lane$reg_trailing;
    wire signal_and_26;
    wire signal_mux_199;
    wire signal_select_80;
    wire signal_select_81;
    wire signal_select_82;
    wire signal_select_83;
    wire signal_select_84;
    wire signal_select_85;
    wire signal_select_86;
    wire [7:0] signal_or_19;
    wire [1:0] signal_mux_200;
    wire [1:0] signal_wire_44;
    reg [1:0] transfer$config_pacing_edge_kind;
    reg [7:0] signal_mux_201;
    wire signal_select_87;
    wire [2:0] signal_mux_202;
    wire [2:0] signal_wire_45;
    reg [2:0] transfer$config_pacing_pin;
    reg signal_mux_203;
    wire [15:0] signal_const_160;
    wire [15:0] signal_const_161;
    wire [15:0] signal_mux_204;
    wire [15:0] signal_mux_205;
    wire [15:0] signal_mux_206;
    wire [15:0] signal_mux_207;
    wire [15:0] signal_mux_208;
    wire [15:0] signal_mux_209;
    wire [15:0] signal_wire_46;
    reg [15:0] transfer$lane$reg_half_period;
    wire signal_not_14;
    wire [15:0] signal_mux_210;
    wire [15:0] signal_sub_6;
    wire signal_not_15;
    wire signal_not_16;
    wire signal_and_27;
    wire [15:0] signal_mux_211;
    wire [15:0] signal_mux_212;
    wire [15:0] signal_mux_213;
    wire [15:0] signal_mux_214;
    wire [15:0] signal_mux_215;
    wire [15:0] signal_wire_47;
    reg [15:0] transfer$lane$reg_remaining;
    wire signal_eq_6;
    wire vdd;
    wire signal_mux_216;
    wire signal_mux_217;
    wire signal_mux_218;
    wire signal_mux_219;
    wire signal_wire_48;
    reg transfer$lane$reg_observed;
    wire signal_mux_220;
    wire signal_and_28;
    wire signal_mux_221;
    wire [7:0] signal_wire_49;
    wire [7:0] signal_mux_222;
    wire [7:0] signal_not_17;
    wire [7:0] signal_and_29;
    wire [7:0] signal_mux_223;
    wire [7:0] signal_wire_50;
    wire [7:0] signal_mux_224;
    wire [7:0] signal_or_20;
    wire [7:0] signal_mux_225;
    wire [7:0] signal_mux_226;
    wire signal_wire_51;
    wire signal_and_30;
    wire [7:0] signal_mux_227;
    reg [7:0] signal_cases_3;
    wire [7:0] signal_wire_52;
    reg [7:0] reg_claim_mask;
    wire signal_eq_7;
    wire signal_not_18;
    wire signal_mux_228;
    reg signal_cases_4;
    wire signal_mux_229;
    wire wire_release;
    wire signal_or_21;
    wire [7:0] signal_mux_230;
    wire [7:0] signal_mux_231;
    wire [7:0] signal_mux_232;
    wire [7:0] signal_wire_53;
    reg [7:0] bank$reg_software_claim;
    wire [7:0] signal_wire_54;
    wire [7:0] signal_wire_55;
    wire [7:0] signal_or_22;
    reg [7:0] signal_mux_233;
    wire [7:0] signal_mux_234;
    wire signal_not_19;
    wire signal_and_31;
    wire [7:0] signal_mux_235;
    wire signal_not_20;
    wire signal_not_21;
    wire signal_and_32;
    wire signal_eq_8;
    wire [15:0] signal_select_88;
    wire [31:0] signal_cat;
    wire [23:0] signal_select_89;
    wire [31:0] signal_cat_1;
    wire [27:0] signal_select_90;
    wire [3:0] signal_const_191;
    wire [31:0] signal_cat_2;
    wire [29:0] signal_select_91;
    wire [31:0] signal_cat_3;
    wire [30:0] signal_select_92;
    wire [31:0] signal_cat_4;
    wire signal_select_93;
    wire [31:0] signal_mux_236;
    wire signal_select_94;
    wire [31:0] signal_mux_237;
    wire signal_select_95;
    wire [31:0] signal_mux_238;
    wire signal_select_96;
    wire [31:0] signal_mux_239;
    wire signal_select_97;
    wire [31:0] signal_mux_240;
    wire signal_select_98;
    wire [31:0] signal_mux_241;
    wire signal_eq_9;
    wire signal_not_22;
    wire [5:0] signal_const_194;
    wire signal_lt;
    wire signal_or_23;
    wire [5:0] signal_mux_242;
    wire signal_eq_10;
    wire signal_or_24;
    wire signal_or_25;
    wire signal_or_26;
    wire signal_or_27;
    wire [7:0] signal_mux_243;
    wire [7:0] signal_mux_244;
    wire [7:0] signal_mux_245;
    wire [7:0] signal_wire_56;
    reg [7:0] transfer$lane$reg_prepared_mask;
    wire [7:0] signal_and_33;
    wire signal_eq_11;
    wire signal_not_23;
    wire signal_mux_246;
    wire signal_select_99;
    wire signal_select_100;
    wire signal_select_101;
    wire signal_select_102;
    wire signal_select_103;
    wire signal_select_104;
    wire signal_select_105;
    wire [7:0] signal_or_28;
    wire [7:0] signal_not_24;
    wire [7:0] signal_and_34;
    wire [7:0] signal_wire_57;
    reg [7:0] transfer$front$reg_previous;
    wire [7:0] signal_not_25;
    wire [7:0] signal_wire_58;
    wire [7:0] signal_wire_59;
    reg [7:0] transfer$front$reg_stage0;
    wire [7:0] signal_wire_60;
    reg [7:0] transfer$front$reg_stage1;
    wire [7:0] signal_and_35;
    wire [1:0] signal_mux_247;
    wire [1:0] signal_wire_61;
    reg [1:0] transfer$config_start_edge_kind;
    reg [7:0] signal_mux_248;
    wire signal_select_106;
    wire signal_wire_62;
    wire signal_wire_63;
    wire [2:0] signal_wire_64;
    wire signal_wire_65;
    wire signal_not_26;
    wire signal_and_36;
    wire signal_not_27;
    wire signal_not_28;
    wire signal_and_37;
    wire signal_wire_66;
    wire signal_wire_67;
    wire signal_eq_12;
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
    wire [31:0] signal_wire_68;
    wire signal_select_112;
    wire [31:0] signal_mux_249;
    wire signal_select_113;
    wire [31:0] signal_mux_250;
    wire signal_select_114;
    wire [31:0] signal_mux_251;
    wire signal_select_115;
    wire [31:0] signal_mux_252;
    wire signal_select_116;
    wire [31:0] signal_mux_253;
    wire signal_select_117;
    wire [31:0] signal_mux_254;
    wire signal_eq_13;
    wire signal_not_29;
    wire signal_lt_1;
    wire [5:0] signal_wire_69;
    wire signal_eq_14;
    wire [2:0] signal_wire_70;
    wire signal_eq_15;
    wire signal_wire_71;
    wire signal_and_38;
    wire [2:0] signal_wire_72;
    wire signal_eq_16;
    wire signal_and_39;
    wire signal_or_29;
    wire [1:0] signal_const_212;
    wire [1:0] signal_wire_73;
    wire signal_eq_17;
    wire signal_wire_74;
    wire signal_and_40;
    wire [1:0] signal_wire_75;
    wire signal_eq_18;
    wire [1:0] signal_wire_76;
    wire signal_eq_19;
    wire signal_or_30;
    wire signal_or_31;
    wire signal_or_32;
    wire signal_or_33;
    wire signal_or_34;
    wire signal_or_35;
    wire signal_or_36;
    wire signal_or_37;
    wire signal_or_38;
    wire signal_not_30;
    wire signal_not_31;
    wire signal_not_32;
    wire signal_not_33;
    wire signal_and_41;
    wire signal_and_42;
    wire signal_and_43;
    wire signal_and_44;
    wire signal_and_45;
    wire [2:0] signal_mux_255;
    wire [2:0] signal_wire_77;
    reg [2:0] transfer$config_start_pin;
    reg signal_mux_256;
    wire signal_and_46;
    wire signal_mux_257;
    wire signal_mux_258;
    wire signal_mux_259;
    wire signal_mux_260;
    wire signal_wire_78;
    reg transfer$lane$reg_busy;
    wire signal_not_34;
    wire signal_and_47;
    wire signal_and_48;
    wire signal_mux_261;
    wire signal_mux_262;
    wire signal_wire_79;
    reg transfer$lane$reg_armed;
    wire signal_or_39;
    wire signal_wire_80;
    wire signal_and_49;
    wire signal_and_50;
    wire signal_mux_263;
    wire signal_mux_264;
    reg signal_cases_5;
    wire signal_mux_265;
    wire wire_local_abort;
    wire signal_or_40;
    wire signal_or_41;
    wire signal_not_35;
    wire signal_or_42;
    wire signal_mux_266;
    wire signal_wire_81;
    reg transfer$lane$reg_rejected;
    wire signal_or_43;
    wire signal_or_44;
    wire signal_mux_267;
    wire signal_mux_268;
    reg signal_cases_6;
    wire signal_mux_269;
    wire wire_write;
    wire signal_or_45;
    wire signal_or_46;
    wire signal_or_47;
    wire signal_not_36;
    wire signal_and_51;
    wire [2:0] signal_wire_82;
    reg [7:0] signal_mux_270;
    wire signal_wire_83;
    wire [7:0] signal_mux_271;
    wire signal_eq_20;
    wire signal_not_37;
    wire signal_mux_272;
    wire signal_mux_273;
    reg signal_cases_7;
    wire signal_mux_274;
    wire wire_claim;
    wire signal_or_48;
    wire signal_and_52;
    wire signal_or_49;
    wire signal_or_50;
    wire signal_or_51;
    wire signal_or_52;
    wire signal_mux_275;
    wire signal_not_38;
    wire signal_or_53;
    wire signal_mux_276;
    wire signal_wire_84;
    reg bank$reg_rejected;
    wire signal_and_53;
    wire [1:0] signal_mux_277;
    wire [1:0] signal_const_232;
    wire signal_wire_85;
    wire signal_and_54;
    wire [1:0] signal_mux_278;
    reg [1:0] signal_cases_8;
    wire signal_wire_86;
    wire signal_wire_87;
    wire signal_not_39;
    wire signal_or_54;
    wire [1:0] signal_mux_279;
    wire [1:0] signal_wire_88;
    (* fsm_encoding="one_hot" *)
    reg [1:0] signal_reg;
    wire signal_eq_21;
    wire signal_and_55;
    assign signal_const = 1'b0;
    assign signal_const_1 = 1'b1;
    assign signal_and = signal_or_15 & signal_not_6;
    assign signal_and_1 = signal_or_48 & signal_not_10;
    assign signal_or = signal_and_1 | signal_and;
    assign signal_mux = signal_or ? signal_const_1 : bank$reg_conflict;
    assign signal_mux_1 = signal_or_52 ? signal_mux : bank$reg_conflict;
    assign signal_mux_2 = signal_or_53 ? bank$reg_conflict : signal_mux_1;
    assign signal_wire = signal_mux_2;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            bank$reg_conflict <= signal_const;
        else
            bank$reg_conflict <= signal_wire;
    end
    assign signal_const_2 = 8'b00000000;
    assign signal_wire_1 = software_write_oe_i;
    assign signal_mux_3 = wire_clear ? signal_const_2 : signal_wire_1;
    assign signal_mux_4 = wire_write ? transfer$lane$reg_pin_oe : signal_mux_3;
    assign signal_and_2 = signal_mux_4 & signal_mux_127;
    assign signal_not = ~ signal_mux_127;
    assign signal_and_3 = bank$reg_pin_oe & signal_not;
    assign signal_or_1 = signal_and_3 | signal_and_2;
    assign signal_mux_5 = signal_or_15 ? signal_or_1 : bank$reg_pin_oe;
    assign signal_mux_6 = signal_or_52 ? bank$reg_pin_oe : signal_mux_5;
    assign signal_mux_7 = signal_or_53 ? signal_const_2 : signal_mux_6;
    assign signal_wire_2 = signal_mux_7;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            bank$reg_pin_oe <= signal_const_2;
        else
            bank$reg_pin_oe <= signal_wire_2;
    end
    assign signal_wire_3 = software_write_value_i;
    assign signal_mux_8 = wire_clear ? signal_const_2 : signal_wire_3;
    assign signal_mux_9 = wire_write ? transfer$lane$reg_pin_value : signal_mux_8;
    assign signal_wire_4 = software_write_open_drain_i;
    assign signal_and_4 = signal_not_36 & signal_wire_29;
    assign signal_and_5 = signal_and_4 & signal_wire_4;
    assign signal_mux_10 = signal_and_5 ? signal_const_2 : signal_mux_9;
    assign signal_and_6 = signal_mux_10 & signal_mux_127;
    assign signal_not_1 = ~ signal_mux_127;
    assign signal_and_7 = bank$reg_pins & signal_not_1;
    assign signal_or_2 = signal_and_7 | signal_and_6;
    assign signal_mux_11 = signal_or_15 ? signal_or_2 : bank$reg_pins;
    assign signal_mux_12 = signal_or_52 ? bank$reg_pins : signal_mux_11;
    assign signal_mux_13 = signal_or_53 ? signal_const_2 : signal_mux_12;
    assign signal_wire_5 = signal_mux_13;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            bank$reg_pins <= signal_const_2;
        else
            bank$reg_pins <= signal_wire_5;
    end
    assign signal_const_9 = 32'b00000000000000000000000000000000;
    assign signal_mux_14 = signal_and_31 ? transfer$lane$reg_rx_value : signal_const_9;
    assign signal_mux_15 = signal_or_27 ? transfer$lane$reg_rx_value : signal_mux_14;
    assign signal_select = transfer$front$reg_stage1[7:7];
    assign signal_select_1 = transfer$front$reg_stage1[6:6];
    assign signal_select_2 = transfer$front$reg_stage1[5:5];
    assign signal_select_3 = transfer$front$reg_stage1[4:4];
    assign signal_select_4 = transfer$front$reg_stage1[3:3];
    assign signal_select_5 = transfer$front$reg_stage1[2:2];
    assign signal_select_6 = transfer$front$reg_stage1[1:1];
    assign signal_select_7 = transfer$front$reg_stage1[0:0];
    assign signal_const_13 = 3'b000;
    assign signal_mux_16 = signal_and_31 ? transfer$lane$reg_input_pin : signal_wire_70;
    assign signal_mux_17 = signal_or_27 ? transfer$lane$reg_input_pin : signal_mux_16;
    assign signal_mux_18 = signal_and_48 ? signal_mux_17 : transfer$lane$reg_input_pin;
    assign signal_mux_19 = signal_or_42 ? transfer$lane$reg_input_pin : signal_mux_18;
    assign signal_wire_6 = signal_mux_19;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_input_pin <= signal_const_13;
        else
            transfer$lane$reg_input_pin <= signal_wire_6;
    end
    always @* begin
        case (transfer$lane$reg_input_pin)
        0:
            signal_mux_20 <= signal_select_7;
        1:
            signal_mux_20 <= signal_select_6;
        2:
            signal_mux_20 <= signal_select_5;
        3:
            signal_mux_20 <= signal_select_4;
        4:
            signal_mux_20 <= signal_select_3;
        5:
            signal_mux_20 <= signal_select_2;
        6:
            signal_mux_20 <= signal_select_1;
        default:
            signal_mux_20 <= signal_select;
        endcase
    end
    assign signal_mux_21 = signal_mux_20 ? signal_mux_22 : signal_const_9;
    assign signal_const_14 = 32'b10000000000000000000000000000000;
    assign signal_const_15 = 32'b01000000000000000000000000000000;
    assign signal_const_16 = 32'b00100000000000000000000000000000;
    assign signal_const_17 = 32'b00010000000000000000000000000000;
    assign signal_const_18 = 32'b00001000000000000000000000000000;
    assign signal_const_19 = 32'b00000100000000000000000000000000;
    assign signal_const_20 = 32'b00000010000000000000000000000000;
    assign signal_const_21 = 32'b00000001000000000000000000000000;
    assign signal_const_22 = 32'b00000000100000000000000000000000;
    assign signal_const_23 = 32'b00000000010000000000000000000000;
    assign signal_const_24 = 32'b00000000001000000000000000000000;
    assign signal_const_25 = 32'b00000000000100000000000000000000;
    assign signal_const_26 = 32'b00000000000010000000000000000000;
    assign signal_const_27 = 32'b00000000000001000000000000000000;
    assign signal_const_28 = 32'b00000000000000100000000000000000;
    assign signal_const_29 = 32'b00000000000000010000000000000000;
    assign signal_const_30 = 32'b00000000000000001000000000000000;
    assign signal_const_31 = 32'b00000000000000000100000000000000;
    assign signal_const_32 = 32'b00000000000000000010000000000000;
    assign signal_const_33 = 32'b00000000000000000001000000000000;
    assign signal_const_34 = 32'b00000000000000000000100000000000;
    assign signal_const_35 = 32'b00000000000000000000010000000000;
    assign signal_const_36 = 32'b00000000000000000000001000000000;
    assign signal_const_37 = 32'b00000000000000000000000100000000;
    assign signal_const_38 = 32'b00000000000000000000000010000000;
    assign signal_const_39 = 32'b00000000000000000000000001000000;
    assign signal_const_40 = 32'b00000000000000000000000000100000;
    assign signal_const_41 = 32'b00000000000000000000000000010000;
    assign signal_const_42 = 32'b00000000000000000000000000001000;
    assign signal_const_43 = 32'b00000000000000000000000000000100;
    assign signal_const_44 = 32'b00000000000000000000000000000010;
    assign signal_const_45 = 32'b00000000000000000000000000000001;
    always @* begin
        case (signal_mux_67)
        0:
            signal_mux_22 <= signal_const_45;
        1:
            signal_mux_22 <= signal_const_44;
        2:
            signal_mux_22 <= signal_const_43;
        3:
            signal_mux_22 <= signal_const_42;
        4:
            signal_mux_22 <= signal_const_41;
        5:
            signal_mux_22 <= signal_const_40;
        6:
            signal_mux_22 <= signal_const_39;
        7:
            signal_mux_22 <= signal_const_38;
        8:
            signal_mux_22 <= signal_const_37;
        9:
            signal_mux_22 <= signal_const_36;
        10:
            signal_mux_22 <= signal_const_35;
        11:
            signal_mux_22 <= signal_const_34;
        12:
            signal_mux_22 <= signal_const_33;
        13:
            signal_mux_22 <= signal_const_32;
        14:
            signal_mux_22 <= signal_const_31;
        15:
            signal_mux_22 <= signal_const_30;
        16:
            signal_mux_22 <= signal_const_29;
        17:
            signal_mux_22 <= signal_const_28;
        18:
            signal_mux_22 <= signal_const_27;
        19:
            signal_mux_22 <= signal_const_26;
        20:
            signal_mux_22 <= signal_const_25;
        21:
            signal_mux_22 <= signal_const_24;
        22:
            signal_mux_22 <= signal_const_23;
        23:
            signal_mux_22 <= signal_const_22;
        24:
            signal_mux_22 <= signal_const_21;
        25:
            signal_mux_22 <= signal_const_20;
        26:
            signal_mux_22 <= signal_const_19;
        27:
            signal_mux_22 <= signal_const_18;
        28:
            signal_mux_22 <= signal_const_17;
        29:
            signal_mux_22 <= signal_const_16;
        30:
            signal_mux_22 <= signal_const_15;
        default:
            signal_mux_22 <= signal_const_14;
        endcase
    end
    assign signal_not_2 = ~ signal_mux_22;
    assign signal_and_8 = transfer$lane$reg_rx_value & signal_not_2;
    assign signal_or_3 = signal_and_8 | signal_mux_21;
    assign signal_mux_23 = signal_eq ? signal_or_3 : transfer$lane$reg_rx_value;
    assign signal_mux_24 = signal_and_28 ? signal_mux_23 : transfer$lane$reg_rx_value;
    assign signal_mux_25 = transfer$lane$reg_busy ? signal_mux_24 : transfer$lane$reg_rx_value;
    assign signal_mux_26 = signal_and_48 ? signal_mux_15 : signal_mux_25;
    assign signal_mux_27 = signal_or_42 ? transfer$lane$reg_rx_value : signal_mux_26;
    assign signal_wire_7 = signal_mux_27;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_rx_value <= signal_const_9;
        else
            transfer$lane$reg_rx_value <= signal_wire_7;
    end
    assign signal_mux_28 = signal_and_31 ? transfer$lane$reg_sample_trailing : signal_wire_66;
    assign signal_mux_29 = signal_or_27 ? transfer$lane$reg_sample_trailing : signal_mux_28;
    assign signal_mux_30 = signal_and_48 ? signal_mux_29 : transfer$lane$reg_sample_trailing;
    assign signal_mux_31 = signal_or_42 ? transfer$lane$reg_sample_trailing : signal_mux_30;
    assign signal_wire_8 = signal_mux_31;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_sample_trailing <= signal_const;
        else
            transfer$lane$reg_sample_trailing <= signal_wire_8;
    end
    assign signal_eq = transfer$lane$reg_trailing == transfer$lane$reg_sample_trailing;
    assign signal_mux_32 = signal_eq ? signal_or_3 : transfer$lane$reg_rx_value;
    assign signal_mux_33 = transfer$lane$reg_rx_enable ? signal_mux_32 : transfer$lane$reg_rx_data;
    assign signal_mux_34 = signal_and_25 ? transfer$lane$reg_rx_data : signal_mux_33;
    assign signal_mux_35 = signal_and_26 ? signal_mux_34 : transfer$lane$reg_rx_data;
    assign signal_mux_36 = signal_and_28 ? signal_mux_35 : transfer$lane$reg_rx_data;
    assign signal_mux_37 = transfer$lane$reg_busy ? signal_mux_36 : transfer$lane$reg_rx_data;
    assign signal_mux_38 = signal_and_48 ? transfer$lane$reg_rx_data : signal_mux_37;
    assign signal_mux_39 = signal_or_42 ? transfer$lane$reg_rx_data : signal_mux_38;
    assign signal_wire_9 = signal_mux_39;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_rx_data <= signal_const_9;
        else
            transfer$lane$reg_rx_data <= signal_wire_9;
    end
    assign signal_mux_40 = transfer$lane$reg_rx_enable ? signal_const_1 : signal_const;
    assign signal_mux_41 = signal_and_25 ? signal_const : signal_mux_40;
    assign signal_mux_42 = signal_and_26 ? signal_mux_41 : signal_const;
    assign signal_mux_43 = signal_and_28 ? signal_mux_42 : signal_const;
    assign signal_mux_44 = transfer$lane$reg_busy ? signal_mux_43 : signal_const;
    assign signal_mux_45 = signal_and_48 ? signal_const : signal_mux_44;
    assign signal_mux_46 = signal_or_42 ? signal_const : signal_mux_45;
    assign signal_wire_10 = signal_mux_46;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_rx_valid <= signal_const;
        else
            transfer$lane$reg_rx_valid <= signal_wire_10;
    end
    assign signal_mux_47 = signal_and_31 ? transfer$lane$reg_pin_oe : signal_const_2;
    assign signal_mux_48 = signal_or_27 ? transfer$lane$reg_pin_oe : signal_mux_47;
    assign signal_mux_49 = signal_and_26 ? signal_const_2 : signal_mux_52;
    assign signal_mux_50 = signal_and_28 ? signal_mux_49 : signal_mux_52;
    assign signal_mux_51 = signal_not_23 ? transfer$lane$reg_pin_oe : transfer$lane$reg_prepared_mask;
    assign signal_mux_52 = signal_and_46 ? signal_mux_51 : transfer$lane$reg_pin_oe;
    assign signal_mux_53 = transfer$lane$reg_busy ? signal_mux_50 : signal_mux_52;
    assign signal_mux_54 = signal_and_48 ? signal_mux_48 : signal_mux_53;
    assign signal_mux_55 = signal_or_42 ? signal_const_2 : signal_mux_54;
    assign signal_wire_11 = signal_mux_55;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_pin_oe <= signal_const_2;
        else
            transfer$lane$reg_pin_oe <= signal_wire_11;
    end
    assign signal_mux_56 = signal_and_31 ? transfer$lane$reg_pin_value : signal_const_2;
    assign signal_mux_57 = signal_or_27 ? transfer$lane$reg_pin_value : signal_mux_56;
    assign signal_select_8 = transfer$lane$reg_tx_value[31:31];
    assign signal_select_9 = transfer$lane$reg_tx_value[30:30];
    assign signal_select_10 = transfer$lane$reg_tx_value[29:29];
    assign signal_select_11 = transfer$lane$reg_tx_value[28:28];
    assign signal_select_12 = transfer$lane$reg_tx_value[27:27];
    assign signal_select_13 = transfer$lane$reg_tx_value[26:26];
    assign signal_select_14 = transfer$lane$reg_tx_value[25:25];
    assign signal_select_15 = transfer$lane$reg_tx_value[24:24];
    assign signal_select_16 = transfer$lane$reg_tx_value[23:23];
    assign signal_select_17 = transfer$lane$reg_tx_value[22:22];
    assign signal_select_18 = transfer$lane$reg_tx_value[21:21];
    assign signal_select_19 = transfer$lane$reg_tx_value[20:20];
    assign signal_select_20 = transfer$lane$reg_tx_value[19:19];
    assign signal_select_21 = transfer$lane$reg_tx_value[18:18];
    assign signal_select_22 = transfer$lane$reg_tx_value[17:17];
    assign signal_select_23 = transfer$lane$reg_tx_value[16:16];
    assign signal_select_24 = transfer$lane$reg_tx_value[15:15];
    assign signal_select_25 = transfer$lane$reg_tx_value[14:14];
    assign signal_select_26 = transfer$lane$reg_tx_value[13:13];
    assign signal_select_27 = transfer$lane$reg_tx_value[12:12];
    assign signal_select_28 = transfer$lane$reg_tx_value[11:11];
    assign signal_select_29 = transfer$lane$reg_tx_value[10:10];
    assign signal_select_30 = transfer$lane$reg_tx_value[9:9];
    assign signal_select_31 = transfer$lane$reg_tx_value[8:8];
    assign signal_select_32 = transfer$lane$reg_tx_value[7:7];
    assign signal_select_33 = transfer$lane$reg_tx_value[6:6];
    assign signal_select_34 = transfer$lane$reg_tx_value[5:5];
    assign signal_select_35 = transfer$lane$reg_tx_value[4:4];
    assign signal_select_36 = transfer$lane$reg_tx_value[3:3];
    assign signal_select_37 = transfer$lane$reg_tx_value[2:2];
    assign signal_select_38 = transfer$lane$reg_tx_value[1:1];
    assign signal_mux_58 = signal_and_31 ? transfer$lane$reg_tx_value : signal_wire_68;
    assign signal_mux_59 = signal_or_27 ? transfer$lane$reg_tx_value : signal_mux_58;
    assign signal_mux_60 = signal_and_48 ? signal_mux_59 : transfer$lane$reg_tx_value;
    assign signal_mux_61 = signal_or_42 ? transfer$lane$reg_tx_value : signal_mux_60;
    assign signal_wire_12 = signal_mux_61;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_tx_value <= signal_const_9;
        else
            transfer$lane$reg_tx_value <= signal_wire_12;
    end
    assign signal_select_39 = transfer$lane$reg_tx_value[0:0];
    assign signal_const_59 = 6'b000001;
    assign signal_add = transfer$lane$reg_bit_index + signal_const_59;
    assign signal_const_60 = 6'b000010;
    assign signal_sub = transfer$lane$reg_bit_count - signal_const_60;
    assign signal_sub_1 = signal_sub - transfer$lane$reg_bit_index;
    assign signal_mux_62 = transfer$lane$reg_lsb_first ? signal_add : signal_sub_1;
    assign signal_sub_2 = transfer$lane$reg_bit_count - signal_const_59;
    assign signal_sub_3 = signal_sub_2 - transfer$lane$reg_bit_index;
    assign signal_mux_63 = signal_and_31 ? transfer$lane$reg_lsb_first : signal_wire_19;
    assign signal_mux_64 = signal_or_27 ? transfer$lane$reg_lsb_first : signal_mux_63;
    assign signal_mux_65 = signal_and_48 ? signal_mux_64 : transfer$lane$reg_lsb_first;
    assign signal_mux_66 = signal_or_42 ? transfer$lane$reg_lsb_first : signal_mux_65;
    assign signal_wire_13 = signal_mux_66;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_lsb_first <= signal_const;
        else
            transfer$lane$reg_lsb_first <= signal_wire_13;
    end
    assign signal_mux_67 = transfer$lane$reg_lsb_first ? transfer$lane$reg_bit_index : signal_sub_3;
    assign signal_mux_68 = transfer$lane$reg_launch_trailing ? signal_mux_62 : signal_mux_67;
    always @* begin
        case (signal_mux_68)
        0:
            signal_mux_69 <= signal_select_39;
        1:
            signal_mux_69 <= signal_select_38;
        2:
            signal_mux_69 <= signal_select_37;
        3:
            signal_mux_69 <= signal_select_36;
        4:
            signal_mux_69 <= signal_select_35;
        5:
            signal_mux_69 <= signal_select_34;
        6:
            signal_mux_69 <= signal_select_33;
        7:
            signal_mux_69 <= signal_select_32;
        8:
            signal_mux_69 <= signal_select_31;
        9:
            signal_mux_69 <= signal_select_30;
        10:
            signal_mux_69 <= signal_select_29;
        11:
            signal_mux_69 <= signal_select_28;
        12:
            signal_mux_69 <= signal_select_27;
        13:
            signal_mux_69 <= signal_select_26;
        14:
            signal_mux_69 <= signal_select_25;
        15:
            signal_mux_69 <= signal_select_24;
        16:
            signal_mux_69 <= signal_select_23;
        17:
            signal_mux_69 <= signal_select_22;
        18:
            signal_mux_69 <= signal_select_21;
        19:
            signal_mux_69 <= signal_select_20;
        20:
            signal_mux_69 <= signal_select_19;
        21:
            signal_mux_69 <= signal_select_18;
        22:
            signal_mux_69 <= signal_select_17;
        23:
            signal_mux_69 <= signal_select_16;
        24:
            signal_mux_69 <= signal_select_15;
        25:
            signal_mux_69 <= signal_select_14;
        26:
            signal_mux_69 <= signal_select_13;
        27:
            signal_mux_69 <= signal_select_12;
        28:
            signal_mux_69 <= signal_select_11;
        29:
            signal_mux_69 <= signal_select_10;
        30:
            signal_mux_69 <= signal_select_9;
        default:
            signal_mux_69 <= signal_select_8;
        endcase
    end
    assign signal_mux_70 = signal_mux_69 ? signal_mux_75 : signal_const_2;
    assign signal_const_63 = 8'b10000000;
    assign signal_const_64 = 8'b01000000;
    assign signal_const_65 = 8'b00100000;
    assign signal_const_66 = 8'b00010000;
    assign signal_const_67 = 8'b00001000;
    assign signal_const_68 = 8'b00000100;
    assign signal_const_69 = 8'b00000010;
    assign signal_const_70 = 8'b00000001;
    assign signal_mux_71 = signal_and_31 ? transfer$lane$reg_output_pin : signal_wire_82;
    assign signal_mux_72 = signal_or_27 ? transfer$lane$reg_output_pin : signal_mux_71;
    assign signal_mux_73 = signal_and_48 ? signal_mux_72 : transfer$lane$reg_output_pin;
    assign signal_mux_74 = signal_or_42 ? transfer$lane$reg_output_pin : signal_mux_73;
    assign signal_wire_14 = signal_mux_74;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_output_pin <= signal_const_13;
        else
            transfer$lane$reg_output_pin <= signal_wire_14;
    end
    always @* begin
        case (transfer$lane$reg_output_pin)
        0:
            signal_mux_75 <= signal_const_70;
        1:
            signal_mux_75 <= signal_const_69;
        2:
            signal_mux_75 <= signal_const_68;
        3:
            signal_mux_75 <= signal_const_67;
        4:
            signal_mux_75 <= signal_const_66;
        5:
            signal_mux_75 <= signal_const_65;
        6:
            signal_mux_75 <= signal_const_64;
        default:
            signal_mux_75 <= signal_const_63;
        endcase
    end
    assign signal_not_3 = ~ signal_mux_75;
    assign signal_and_9 = signal_mux_85 & signal_not_3;
    assign signal_or_4 = signal_and_9 | signal_mux_70;
    assign signal_mux_76 = signal_and_31 ? transfer$lane$reg_clock_pin : signal_const_13;
    assign signal_mux_77 = signal_or_27 ? transfer$lane$reg_clock_pin : signal_mux_76;
    assign signal_mux_78 = signal_and_48 ? signal_mux_77 : transfer$lane$reg_clock_pin;
    assign signal_mux_79 = signal_or_42 ? transfer$lane$reg_clock_pin : signal_mux_78;
    assign signal_wire_15 = signal_mux_79;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_clock_pin <= signal_const_13;
        else
            transfer$lane$reg_clock_pin <= signal_wire_15;
    end
    always @* begin
        case (transfer$lane$reg_clock_pin)
        0:
            signal_mux_80 <= signal_const_70;
        1:
            signal_mux_80 <= signal_const_69;
        2:
            signal_mux_80 <= signal_const_68;
        3:
            signal_mux_80 <= signal_const_67;
        4:
            signal_mux_80 <= signal_const_66;
        5:
            signal_mux_80 <= signal_const_65;
        6:
            signal_mux_80 <= signal_const_64;
        default:
            signal_mux_80 <= signal_const_63;
        endcase
    end
    assign signal_xor = transfer$lane$reg_pin_value ^ signal_mux_80;
    assign gnd = 1'b0;
    assign signal_mux_81 = signal_and_31 ? transfer$lane$reg_clock_enable : gnd;
    assign signal_mux_82 = signal_or_27 ? transfer$lane$reg_clock_enable : signal_mux_81;
    assign signal_mux_83 = signal_and_48 ? signal_mux_82 : transfer$lane$reg_clock_enable;
    assign signal_mux_84 = signal_or_42 ? transfer$lane$reg_clock_enable : signal_mux_83;
    assign signal_wire_16 = signal_mux_84;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_clock_enable <= signal_const;
        else
            transfer$lane$reg_clock_enable <= signal_wire_16;
    end
    assign signal_mux_85 = transfer$lane$reg_clock_enable ? signal_xor : transfer$lane$reg_pin_value;
    assign signal_not_4 = ~ signal_and_26;
    assign signal_mux_86 = signal_and_31 ? transfer$lane$reg_tx_enable : signal_wire_83;
    assign signal_mux_87 = signal_or_27 ? transfer$lane$reg_tx_enable : signal_mux_86;
    assign signal_mux_88 = signal_and_48 ? signal_mux_87 : transfer$lane$reg_tx_enable;
    assign signal_mux_89 = signal_or_42 ? transfer$lane$reg_tx_enable : signal_mux_88;
    assign signal_wire_17 = signal_mux_89;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_tx_enable <= signal_const;
        else
            transfer$lane$reg_tx_enable <= signal_wire_17;
    end
    assign signal_mux_90 = signal_and_31 ? transfer$lane$reg_launch_trailing : signal_wire_67;
    assign signal_mux_91 = signal_or_27 ? transfer$lane$reg_launch_trailing : signal_mux_90;
    assign signal_mux_92 = signal_and_48 ? signal_mux_91 : transfer$lane$reg_launch_trailing;
    assign signal_mux_93 = signal_or_42 ? transfer$lane$reg_launch_trailing : signal_mux_92;
    assign signal_wire_18 = signal_mux_93;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_launch_trailing <= signal_const;
        else
            transfer$lane$reg_launch_trailing <= signal_wire_18;
    end
    assign signal_eq_1 = transfer$lane$reg_trailing == transfer$lane$reg_launch_trailing;
    assign signal_and_10 = signal_eq_1 & transfer$lane$reg_tx_enable;
    assign signal_and_11 = signal_and_10 & signal_not_4;
    assign signal_mux_94 = signal_and_11 ? signal_or_4 : signal_mux_85;
    assign signal_mux_95 = signal_and_28 ? signal_mux_94 : signal_mux_107;
    assign signal_select_40 = signal_wire_68[31:31];
    assign signal_select_41 = signal_wire_68[30:30];
    assign signal_select_42 = signal_wire_68[29:29];
    assign signal_select_43 = signal_wire_68[28:28];
    assign signal_select_44 = signal_wire_68[27:27];
    assign signal_select_45 = signal_wire_68[26:26];
    assign signal_select_46 = signal_wire_68[25:25];
    assign signal_select_47 = signal_wire_68[24:24];
    assign signal_select_48 = signal_wire_68[23:23];
    assign signal_select_49 = signal_wire_68[22:22];
    assign signal_select_50 = signal_wire_68[21:21];
    assign signal_select_51 = signal_wire_68[20:20];
    assign signal_select_52 = signal_wire_68[19:19];
    assign signal_select_53 = signal_wire_68[18:18];
    assign signal_select_54 = signal_wire_68[17:17];
    assign signal_select_55 = signal_wire_68[16:16];
    assign signal_select_56 = signal_wire_68[15:15];
    assign signal_select_57 = signal_wire_68[14:14];
    assign signal_select_58 = signal_wire_68[13:13];
    assign signal_select_59 = signal_wire_68[12:12];
    assign signal_select_60 = signal_wire_68[11:11];
    assign signal_select_61 = signal_wire_68[10:10];
    assign signal_select_62 = signal_wire_68[9:9];
    assign signal_select_63 = signal_wire_68[8:8];
    assign signal_select_64 = signal_wire_68[7:7];
    assign signal_select_65 = signal_wire_68[6:6];
    assign signal_select_66 = signal_wire_68[5:5];
    assign signal_select_67 = signal_wire_68[4:4];
    assign signal_select_68 = signal_wire_68[3:3];
    assign signal_select_69 = signal_wire_68[2:2];
    assign signal_select_70 = signal_wire_68[1:1];
    assign signal_select_71 = signal_wire_68[0:0];
    assign signal_const_87 = 6'b000000;
    assign signal_sub_4 = signal_mux_242 - signal_const_59;
    assign signal_wire_19 = lsb_first_i;
    assign signal_mux_96 = signal_wire_19 ? signal_const_87 : signal_sub_4;
    always @* begin
        case (signal_mux_96)
        0:
            signal_mux_97 <= signal_select_71;
        1:
            signal_mux_97 <= signal_select_70;
        2:
            signal_mux_97 <= signal_select_69;
        3:
            signal_mux_97 <= signal_select_68;
        4:
            signal_mux_97 <= signal_select_67;
        5:
            signal_mux_97 <= signal_select_66;
        6:
            signal_mux_97 <= signal_select_65;
        7:
            signal_mux_97 <= signal_select_64;
        8:
            signal_mux_97 <= signal_select_63;
        9:
            signal_mux_97 <= signal_select_62;
        10:
            signal_mux_97 <= signal_select_61;
        11:
            signal_mux_97 <= signal_select_60;
        12:
            signal_mux_97 <= signal_select_59;
        13:
            signal_mux_97 <= signal_select_58;
        14:
            signal_mux_97 <= signal_select_57;
        15:
            signal_mux_97 <= signal_select_56;
        16:
            signal_mux_97 <= signal_select_55;
        17:
            signal_mux_97 <= signal_select_54;
        18:
            signal_mux_97 <= signal_select_53;
        19:
            signal_mux_97 <= signal_select_52;
        20:
            signal_mux_97 <= signal_select_51;
        21:
            signal_mux_97 <= signal_select_50;
        22:
            signal_mux_97 <= signal_select_49;
        23:
            signal_mux_97 <= signal_select_48;
        24:
            signal_mux_97 <= signal_select_47;
        25:
            signal_mux_97 <= signal_select_46;
        26:
            signal_mux_97 <= signal_select_45;
        27:
            signal_mux_97 <= signal_select_44;
        28:
            signal_mux_97 <= signal_select_43;
        29:
            signal_mux_97 <= signal_select_42;
        30:
            signal_mux_97 <= signal_select_41;
        default:
            signal_mux_97 <= signal_select_40;
        endcase
    end
    assign signal_mux_98 = signal_mux_97 ? signal_mux_233 : signal_const_2;
    assign signal_wire_20 = idle_output_i;
    assign signal_mux_99 = signal_wire_20 ? signal_mux_233 : signal_const_2;
    assign signal_mux_100 = signal_wire_67 ? signal_mux_98 : signal_mux_99;
    assign signal_mux_101 = signal_wire_83 ? signal_mux_100 : signal_const_2;
    assign signal_mux_102 = signal_and_31 ? transfer$lane$reg_prepared_pin_value : signal_mux_101;
    assign signal_mux_103 = signal_or_27 ? transfer$lane$reg_prepared_pin_value : signal_mux_102;
    assign signal_mux_104 = signal_and_48 ? signal_mux_103 : transfer$lane$reg_prepared_pin_value;
    assign signal_mux_105 = signal_or_42 ? transfer$lane$reg_prepared_pin_value : signal_mux_104;
    assign signal_wire_21 = signal_mux_105;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_prepared_pin_value <= signal_const_2;
        else
            transfer$lane$reg_prepared_pin_value <= signal_wire_21;
    end
    assign signal_mux_106 = signal_not_23 ? transfer$lane$reg_pin_value : transfer$lane$reg_prepared_pin_value;
    assign signal_mux_107 = signal_and_46 ? signal_mux_106 : transfer$lane$reg_pin_value;
    assign signal_mux_108 = transfer$lane$reg_busy ? signal_mux_95 : signal_mux_107;
    assign signal_mux_109 = signal_and_48 ? signal_mux_57 : signal_mux_108;
    assign signal_mux_110 = signal_or_42 ? signal_const_2 : signal_mux_109;
    assign signal_wire_22 = signal_mux_110;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_pin_value <= signal_const_2;
        else
            transfer$lane$reg_pin_value <= signal_wire_22;
    end
    assign signal_mux_111 = signal_and_31 ? transfer$lane$reg_claim_mask : signal_const_2;
    assign signal_mux_112 = signal_or_27 ? transfer$lane$reg_claim_mask : signal_mux_111;
    assign signal_mux_113 = signal_and_26 ? signal_const_2 : signal_mux_116;
    assign signal_mux_114 = signal_and_28 ? signal_mux_113 : signal_mux_116;
    assign signal_mux_115 = signal_not_23 ? transfer$lane$reg_claim_mask : transfer$lane$reg_prepared_mask;
    assign signal_mux_116 = signal_and_46 ? signal_mux_115 : transfer$lane$reg_claim_mask;
    assign signal_mux_117 = transfer$lane$reg_busy ? signal_mux_114 : signal_mux_116;
    assign signal_mux_118 = signal_and_48 ? signal_mux_112 : signal_mux_117;
    assign signal_mux_119 = signal_or_42 ? signal_const_2 : signal_mux_118;
    assign signal_wire_23 = signal_mux_119;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_claim_mask <= signal_const_2;
        else
            transfer$lane$reg_claim_mask <= signal_wire_23;
    end
    assign signal_or_5 = signal_wire_30 | signal_wire_51;
    assign signal_or_6 = signal_or_5 | signal_wire_29;
    assign signal_and_12 = signal_or_47 & signal_or_6;
    assign signal_wire_24 = signal_and_12;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            reg_software_rejected <= signal_const;
        else
            reg_software_rejected <= signal_wire_24;
    end
    assign signal_mux_120 = signal_or_44 ? signal_const_1 : signal_const;
    assign signal_mux_121 = signal_and_53 ? signal_const_1 : signal_mux_120;
    always @* begin
        case (signal_reg)
        2'b01:
            signal_cases <= signal_mux_121;
        default:
            signal_cases <= signal_const;
        endcase
    end
    assign signal_mux_122 = signal_or_54 ? signal_const : signal_cases;
    assign wire_transaction_rejected = signal_mux_122;
    assign signal_wire_25 = wire_transaction_rejected;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            reg_transaction_rejected <= signal_const;
        else
            reg_transaction_rejected <= signal_wire_25;
    end
    always @* begin
        case (signal_reg)
        2'b10:
            signal_cases_1 <= signal_const_1;
        default:
            signal_cases_1 <= signal_const;
        endcase
    end
    assign signal_mux_123 = signal_or_54 ? signal_const : signal_cases_1;
    assign wire_transaction_done = signal_mux_123;
    assign signal_not_5 = ~ signal_or_54;
    assign signal_const_104 = 2'b00;
    assign signal_mux_124 = signal_and_22 ? signal_const_104 : signal_const_176;
    assign signal_const_176 = 2'b10;
    assign signal_or_7 = transfer$lane$reg_rejected | transfer$lane$reg_underrun;
    assign signal_or_8 = signal_or_7 | transfer$lane$reg_overrun;
    assign signal_or_9 = signal_or_8 | signal_and_50;
    assign signal_or_10 = signal_or_9 | transfer$lane$reg_done_;
    assign signal_mux_125 = signal_or_10 ? signal_const_176 : signal_const_232;
    assign signal_wire_26 = signal_or_47;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            reg_internal_pending <= signal_const;
        else
            reg_internal_pending <= signal_wire_26;
    end
    assign signal_or_11 = wire_write | wire_clear;
    assign signal_mux_126 = signal_or_11 ? bank$reg_software_claim : bank$reg_engine_claim;
    assign signal_wire_27 = software_write_mask_i;
    assign signal_or_12 = wire_write | wire_clear;
    assign signal_mux_127 = signal_or_12 ? reg_claim_mask : signal_wire_27;
    assign signal_and_13 = signal_mux_127 & signal_mux_126;
    assign signal_eq_2 = signal_and_13 == signal_const_2;
    assign signal_not_6 = ~ signal_eq_2;
    assign signal_and_14 = signal_or_15 & signal_not_6;
    assign signal_mux_128 = wire_release ? bank$reg_engine_claim : bank$reg_software_claim;
    assign signal_not_7 = ~ signal_mux_128;
    assign signal_and_15 = signal_mux_222 & signal_not_7;
    assign signal_eq_3 = signal_and_15 == signal_const_2;
    assign signal_not_8 = ~ signal_eq_3;
    assign signal_and_16 = signal_or_21 & signal_not_8;
    assign signal_not_9 = ~ signal_mux_222;
    assign signal_and_17 = bank$reg_engine_claim & signal_not_9;
    assign signal_mux_129 = wire_release ? signal_and_17 : signal_mux_131;
    assign signal_or_13 = bank$reg_engine_claim | signal_mux_224;
    assign signal_mux_130 = wire_claim ? signal_or_13 : bank$reg_engine_claim;
    assign signal_mux_131 = signal_or_48 ? signal_mux_130 : bank$reg_engine_claim;
    assign signal_mux_132 = signal_or_21 ? signal_mux_129 : signal_mux_131;
    assign signal_mux_133 = signal_or_52 ? bank$reg_engine_claim : signal_mux_132;
    assign signal_mux_134 = signal_or_53 ? signal_const_2 : signal_mux_133;
    assign signal_wire_28 = signal_mux_134;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            bank$reg_engine_claim <= signal_const_2;
        else
            bank$reg_engine_claim <= signal_wire_28;
    end
    assign signal_mux_135 = wire_claim ? bank$reg_software_claim : bank$reg_engine_claim;
    assign signal_and_18 = signal_mux_224 & signal_mux_135;
    assign signal_eq_4 = signal_and_18 == signal_const_2;
    assign signal_not_10 = ~ signal_eq_4;
    assign signal_and_19 = signal_or_48 & signal_not_10;
    assign signal_and_20 = signal_or_21 & signal_or_15;
    assign signal_wire_29 = software_write_valid_i;
    assign signal_and_21 = signal_not_36 & signal_wire_29;
    assign signal_or_14 = wire_write | wire_clear;
    assign signal_or_15 = signal_or_14 | signal_and_21;
    assign signal_or_16 = signal_or_21 | signal_or_15;
    assign signal_wire_30 = software_claim_valid_i;
    assign signal_wire_31 = wire_claim;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            reg_claim_pending <= signal_const;
        else
            reg_claim_pending <= signal_wire_31;
    end
    assign signal_and_22 = signal_and_53 & reg_claim_pending;
    assign signal_not_11 = ~ signal_and_22;
    assign signal_and_23 = signal_not_11 & signal_not_18;
    assign signal_mux_136 = signal_and_23 ? signal_const_1 : signal_const;
    assign signal_mux_137 = signal_not_18 ? signal_const_1 : signal_const;
    assign signal_mux_138 = signal_not_18 ? signal_const_1 : signal_const;
    assign signal_mux_139 = signal_or_17 ? signal_mux_138 : signal_const;
    assign signal_mux_140 = signal_or_44 ? signal_mux_137 : signal_mux_139;
    assign signal_mux_141 = signal_and_53 ? signal_mux_136 : signal_mux_140;
    always @* begin
        case (signal_reg)
        2'b01:
            signal_cases_2 <= signal_mux_141;
        default:
            signal_cases_2 <= signal_const;
        endcase
    end
    assign signal_mux_142 = signal_or_54 ? signal_const : signal_cases_2;
    assign wire_clear = signal_mux_142;
    assign signal_and_24 = transfer$lane$reg_busy & signal_not_18;
    assign signal_mux_143 = signal_and_24 ? signal_const_1 : signal_const;
    assign signal_mux_144 = signal_and_25 ? signal_const : signal_const_1;
    assign signal_mux_145 = signal_and_26 ? signal_mux_144 : signal_const;
    assign signal_mux_146 = signal_and_28 ? signal_mux_145 : signal_const;
    assign signal_mux_147 = transfer$lane$reg_busy ? signal_mux_146 : signal_const;
    assign signal_mux_148 = signal_and_48 ? signal_const : signal_mux_147;
    assign signal_mux_149 = signal_or_42 ? signal_const : signal_mux_148;
    assign signal_wire_32 = signal_mux_149;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_done_ <= signal_const;
        else
            transfer$lane$reg_done_ <= signal_wire_32;
    end
    assign signal_or_17 = signal_and_50 | transfer$lane$reg_done_;
    assign signal_mux_150 = signal_or_17 ? signal_const : signal_mux_143;
    assign signal_wire_33 = rx_ready_i;
    assign signal_not_12 = ~ signal_wire_33;
    assign signal_mux_151 = signal_and_31 ? transfer$lane$reg_rx_enable : signal_wire_71;
    assign signal_mux_152 = signal_or_27 ? transfer$lane$reg_rx_enable : signal_mux_151;
    assign signal_mux_153 = signal_and_48 ? signal_mux_152 : transfer$lane$reg_rx_enable;
    assign signal_mux_154 = signal_or_42 ? transfer$lane$reg_rx_enable : signal_mux_153;
    assign signal_wire_34 = signal_mux_154;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_rx_enable <= signal_const;
        else
            transfer$lane$reg_rx_enable <= signal_wire_34;
    end
    assign signal_and_25 = transfer$lane$reg_rx_enable & signal_not_12;
    assign signal_mux_155 = signal_and_25 ? signal_const_1 : signal_const;
    assign signal_mux_156 = signal_and_26 ? signal_mux_155 : signal_const;
    assign signal_mux_157 = signal_and_28 ? signal_mux_156 : signal_const;
    assign signal_mux_158 = transfer$lane$reg_busy ? signal_mux_157 : signal_const;
    assign signal_mux_159 = signal_and_48 ? signal_const : signal_mux_158;
    assign signal_mux_160 = signal_or_42 ? signal_const : signal_mux_159;
    assign signal_wire_35 = signal_mux_160;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_overrun <= signal_const;
        else
            transfer$lane$reg_overrun <= signal_wire_35;
    end
    assign signal_mux_161 = signal_and_31 ? signal_const_1 : signal_const;
    assign signal_mux_162 = signal_or_27 ? signal_const : signal_mux_161;
    assign signal_mux_163 = signal_and_48 ? signal_mux_162 : signal_const;
    assign signal_mux_164 = signal_or_42 ? signal_const : signal_mux_163;
    assign signal_wire_36 = signal_mux_164;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_underrun <= signal_const;
        else
            transfer$lane$reg_underrun <= signal_wire_36;
    end
    assign signal_mux_165 = signal_or_27 ? signal_const_1 : signal_const;
    assign signal_mux_166 = signal_not_23 ? signal_const_1 : signal_const;
    assign signal_mux_167 = signal_and_46 ? signal_mux_166 : signal_const;
    assign signal_mux_168 = signal_and_48 ? signal_mux_165 : signal_mux_167;
    assign signal_select_72 = signal_mux_170[7:7];
    assign signal_select_73 = signal_mux_170[6:6];
    assign signal_select_74 = signal_mux_170[5:5];
    assign signal_select_75 = signal_mux_170[4:4];
    assign signal_select_76 = signal_mux_170[3:3];
    assign signal_select_77 = signal_mux_170[2:2];
    assign signal_select_78 = signal_mux_170[1:1];
    assign signal_or_18 = signal_and_35 | signal_and_34;
    assign signal_mux_169 = signal_and_45 ? signal_wire_73 : transfer$config_cancel_edge_kind;
    assign signal_wire_37 = signal_mux_169;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$config_cancel_edge_kind <= signal_const_104;
        else
            transfer$config_cancel_edge_kind <= signal_wire_37;
    end
    always @* begin
        case (transfer$config_cancel_edge_kind)
        0:
            signal_mux_170 <= signal_and_35;
        1:
            signal_mux_170 <= signal_and_34;
        2:
            signal_mux_170 <= signal_or_18;
        default:
            signal_mux_170 <= signal_const_2;
        endcase
    end
    assign signal_select_79 = signal_mux_170[0:0];
    assign signal_wire_38 = cancel_pin_i;
    assign signal_mux_171 = signal_and_45 ? signal_wire_38 : transfer$config_cancel_pin;
    assign signal_wire_39 = signal_mux_171;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$config_cancel_pin <= signal_const_13;
        else
            transfer$config_cancel_pin <= signal_wire_39;
    end
    always @* begin
        case (transfer$config_cancel_pin)
        0:
            signal_mux_172 <= signal_select_79;
        1:
            signal_mux_172 <= signal_select_78;
        2:
            signal_mux_172 <= signal_select_77;
        3:
            signal_mux_172 <= signal_select_76;
        4:
            signal_mux_172 <= signal_select_75;
        5:
            signal_mux_172 <= signal_select_74;
        6:
            signal_mux_172 <= signal_select_73;
        default:
            signal_mux_172 <= signal_select_72;
        endcase
    end
    assign signal_mux_173 = signal_and_45 ? signal_wire_74 : transfer$config_cancel_enable;
    assign signal_wire_40 = signal_mux_173;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$config_cancel_enable <= signal_const;
        else
            transfer$config_cancel_enable <= signal_wire_40;
    end
    assign signal_mux_174 = signal_and_31 ? transfer$lane$reg_armed : vdd;
    assign signal_mux_175 = signal_or_27 ? transfer$lane$reg_armed : signal_mux_174;
    assign signal_mux_176 = signal_and_46 ? signal_const : transfer$lane$reg_armed;
    assign signal_not_13 = ~ transfer$lane$reg_armed;
    assign signal_mux_177 = signal_and_31 ? transfer$lane$reg_busy : signal_const;
    assign signal_mux_178 = signal_or_27 ? transfer$lane$reg_busy : signal_mux_177;
    assign signal_mux_179 = signal_and_31 ? transfer$lane$reg_bit_count : signal_mux_242;
    assign signal_mux_180 = signal_or_27 ? transfer$lane$reg_bit_count : signal_mux_179;
    assign signal_mux_181 = signal_and_48 ? signal_mux_180 : transfer$lane$reg_bit_count;
    assign signal_mux_182 = signal_or_42 ? transfer$lane$reg_bit_count : signal_mux_181;
    assign signal_wire_41 = signal_mux_182;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_bit_count <= signal_const_87;
        else
            transfer$lane$reg_bit_count <= signal_wire_41;
    end
    assign signal_sub_5 = transfer$lane$reg_bit_count - signal_const_59;
    assign signal_mux_183 = signal_and_31 ? transfer$lane$reg_bit_index : signal_const_87;
    assign signal_mux_184 = signal_or_27 ? transfer$lane$reg_bit_index : signal_mux_183;
    assign signal_add_1 = transfer$lane$reg_bit_index + signal_const_59;
    assign signal_mux_185 = transfer$lane$reg_trailing ? signal_add_1 : transfer$lane$reg_bit_index;
    assign signal_mux_186 = signal_and_26 ? transfer$lane$reg_bit_index : signal_mux_185;
    assign signal_mux_187 = signal_and_28 ? signal_mux_186 : transfer$lane$reg_bit_index;
    assign signal_mux_188 = transfer$lane$reg_busy ? signal_mux_187 : transfer$lane$reg_bit_index;
    assign signal_mux_189 = signal_and_48 ? signal_mux_184 : signal_mux_188;
    assign signal_mux_190 = signal_or_42 ? transfer$lane$reg_bit_index : signal_mux_189;
    assign signal_wire_42 = signal_mux_190;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_bit_index <= signal_const_87;
        else
            transfer$lane$reg_bit_index <= signal_wire_42;
    end
    assign signal_eq_5 = transfer$lane$reg_bit_index == signal_sub_5;
    assign signal_mux_191 = signal_and_31 ? transfer$lane$reg_trailing : signal_const;
    assign signal_mux_192 = signal_or_27 ? transfer$lane$reg_trailing : signal_mux_191;
    assign signal_mux_193 = transfer$lane$reg_trailing ? signal_const : signal_const_1;
    assign signal_mux_194 = signal_and_26 ? transfer$lane$reg_trailing : signal_mux_193;
    assign signal_mux_195 = signal_and_28 ? signal_mux_194 : transfer$lane$reg_trailing;
    assign signal_mux_196 = transfer$lane$reg_busy ? signal_mux_195 : transfer$lane$reg_trailing;
    assign signal_mux_197 = signal_and_48 ? signal_mux_192 : signal_mux_196;
    assign signal_mux_198 = signal_or_42 ? transfer$lane$reg_trailing : signal_mux_197;
    assign signal_wire_43 = signal_mux_198;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_trailing <= signal_const;
        else
            transfer$lane$reg_trailing <= signal_wire_43;
    end
    assign signal_and_26 = transfer$lane$reg_trailing & signal_eq_5;
    assign signal_mux_199 = signal_and_26 ? signal_const : signal_mux_257;
    assign signal_select_80 = signal_mux_201[7:7];
    assign signal_select_81 = signal_mux_201[6:6];
    assign signal_select_82 = signal_mux_201[5:5];
    assign signal_select_83 = signal_mux_201[4:4];
    assign signal_select_84 = signal_mux_201[3:3];
    assign signal_select_85 = signal_mux_201[2:2];
    assign signal_select_86 = signal_mux_201[1:1];
    assign signal_or_19 = signal_and_35 | signal_and_34;
    assign signal_mux_200 = signal_and_45 ? signal_wire_75 : transfer$config_pacing_edge_kind;
    assign signal_wire_44 = signal_mux_200;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$config_pacing_edge_kind <= signal_const_104;
        else
            transfer$config_pacing_edge_kind <= signal_wire_44;
    end
    always @* begin
        case (transfer$config_pacing_edge_kind)
        0:
            signal_mux_201 <= signal_and_35;
        1:
            signal_mux_201 <= signal_and_34;
        2:
            signal_mux_201 <= signal_or_19;
        default:
            signal_mux_201 <= signal_const_2;
        endcase
    end
    assign signal_select_87 = signal_mux_201[0:0];
    assign signal_mux_202 = signal_and_45 ? signal_wire_72 : transfer$config_pacing_pin;
    assign signal_wire_45 = signal_mux_202;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$config_pacing_pin <= signal_const_13;
        else
            transfer$config_pacing_pin <= signal_wire_45;
    end
    always @* begin
        case (transfer$config_pacing_pin)
        0:
            signal_mux_203 <= signal_select_87;
        1:
            signal_mux_203 <= signal_select_86;
        2:
            signal_mux_203 <= signal_select_85;
        3:
            signal_mux_203 <= signal_select_84;
        4:
            signal_mux_203 <= signal_select_83;
        5:
            signal_mux_203 <= signal_select_82;
        6:
            signal_mux_203 <= signal_select_81;
        default:
            signal_mux_203 <= signal_select_80;
        endcase
    end
    assign signal_const_160 = 16'b0000000000000001;
    assign signal_const_161 = 16'b0000000000000000;
    assign signal_mux_204 = signal_and_31 ? transfer$lane$reg_remaining : signal_const_160;
    assign signal_mux_205 = signal_or_27 ? transfer$lane$reg_remaining : signal_mux_204;
    assign signal_mux_206 = signal_and_31 ? transfer$lane$reg_half_period : signal_const_160;
    assign signal_mux_207 = signal_or_27 ? transfer$lane$reg_half_period : signal_mux_206;
    assign signal_mux_208 = signal_and_48 ? signal_mux_207 : transfer$lane$reg_half_period;
    assign signal_mux_209 = signal_or_42 ? transfer$lane$reg_half_period : signal_mux_208;
    assign signal_wire_46 = signal_mux_209;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_half_period <= signal_const_161;
        else
            transfer$lane$reg_half_period <= signal_wire_46;
    end
    assign signal_not_14 = ~ transfer$lane$reg_observed;
    assign signal_mux_210 = signal_not_14 ? transfer$lane$reg_half_period : signal_mux_211;
    assign signal_sub_6 = transfer$lane$reg_remaining - signal_const_160;
    assign signal_not_15 = ~ signal_and_28;
    assign signal_not_16 = ~ transfer$lane$reg_observed;
    assign signal_and_27 = signal_not_16 & signal_not_15;
    assign signal_mux_211 = signal_and_27 ? signal_sub_6 : transfer$lane$reg_remaining;
    assign signal_mux_212 = signal_and_28 ? signal_mux_210 : signal_mux_211;
    assign signal_mux_213 = transfer$lane$reg_busy ? signal_mux_212 : transfer$lane$reg_remaining;
    assign signal_mux_214 = signal_and_48 ? signal_mux_205 : signal_mux_213;
    assign signal_mux_215 = signal_or_42 ? signal_const_161 : signal_mux_214;
    assign signal_wire_47 = signal_mux_215;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_remaining <= signal_const_161;
        else
            transfer$lane$reg_remaining <= signal_wire_47;
    end
    assign signal_eq_6 = transfer$lane$reg_remaining == signal_const_160;
    assign vdd = 1'b1;
    assign signal_mux_216 = signal_and_31 ? transfer$lane$reg_observed : vdd;
    assign signal_mux_217 = signal_or_27 ? transfer$lane$reg_observed : signal_mux_216;
    assign signal_mux_218 = signal_and_48 ? signal_mux_217 : transfer$lane$reg_observed;
    assign signal_mux_219 = signal_or_42 ? transfer$lane$reg_observed : signal_mux_218;
    assign signal_wire_48 = signal_mux_219;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_observed <= signal_const;
        else
            transfer$lane$reg_observed <= signal_wire_48;
    end
    assign signal_mux_220 = transfer$lane$reg_observed ? signal_mux_203 : signal_eq_6;
    assign signal_and_28 = transfer$lane$reg_busy & signal_mux_220;
    assign signal_mux_221 = signal_and_28 ? signal_mux_199 : signal_mux_257;
    assign signal_wire_49 = software_release_mask_i;
    assign signal_mux_222 = wire_release ? reg_claim_mask : signal_wire_49;
    assign signal_not_17 = ~ signal_mux_222;
    assign signal_and_29 = bank$reg_software_claim & signal_not_17;
    assign signal_mux_223 = wire_release ? signal_mux_226 : signal_and_29;
    assign signal_wire_50 = software_claim_mask_i;
    assign signal_mux_224 = wire_claim ? signal_mux_271 : signal_wire_50;
    assign signal_or_20 = bank$reg_software_claim | signal_mux_224;
    assign signal_mux_225 = wire_claim ? bank$reg_software_claim : signal_or_20;
    assign signal_mux_226 = signal_or_48 ? signal_mux_225 : bank$reg_software_claim;
    assign signal_wire_51 = software_release_valid_i;
    assign signal_and_30 = signal_not_36 & signal_wire_51;
    assign signal_mux_227 = signal_and_54 ? signal_mux_271 : reg_claim_mask;
    always @* begin
        case (signal_reg)
        2'b00:
            signal_cases_3 <= signal_mux_227;
        default:
            signal_cases_3 <= reg_claim_mask;
        endcase
    end
    assign signal_wire_52 = signal_cases_3;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            reg_claim_mask <= signal_const_2;
        else
            reg_claim_mask <= signal_wire_52;
    end
    assign signal_eq_7 = reg_claim_mask == signal_const_2;
    assign signal_not_18 = ~ signal_eq_7;
    assign signal_mux_228 = signal_not_18 ? signal_const_1 : signal_const;
    always @* begin
        case (signal_reg)
        2'b10:
            signal_cases_4 <= signal_mux_228;
        default:
            signal_cases_4 <= signal_const;
        endcase
    end
    assign signal_mux_229 = signal_or_54 ? signal_const : signal_cases_4;
    assign wire_release = signal_mux_229;
    assign signal_or_21 = wire_release | signal_and_30;
    assign signal_mux_230 = signal_or_21 ? signal_mux_223 : signal_mux_226;
    assign signal_mux_231 = signal_or_52 ? bank$reg_software_claim : signal_mux_230;
    assign signal_mux_232 = signal_or_53 ? signal_const_2 : signal_mux_231;
    assign signal_wire_53 = signal_mux_232;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            bank$reg_software_claim <= signal_const_2;
        else
            bank$reg_software_claim <= signal_wire_53;
    end
    assign signal_wire_54 = bank$reg_software_claim;
    assign signal_wire_55 = occupied_i;
    assign signal_or_22 = signal_wire_55 | signal_wire_54;
    always @* begin
        case (signal_wire_82)
        0:
            signal_mux_233 <= signal_const_70;
        1:
            signal_mux_233 <= signal_const_69;
        2:
            signal_mux_233 <= signal_const_68;
        3:
            signal_mux_233 <= signal_const_67;
        4:
            signal_mux_233 <= signal_const_66;
        5:
            signal_mux_233 <= signal_const_65;
        6:
            signal_mux_233 <= signal_const_64;
        default:
            signal_mux_233 <= signal_const_63;
        endcase
    end
    assign signal_mux_234 = signal_wire_83 ? signal_mux_233 : signal_const_2;
    assign signal_not_19 = ~ signal_wire_65;
    assign signal_and_31 = signal_wire_83 & signal_not_19;
    assign signal_mux_235 = signal_and_31 ? transfer$lane$reg_prepared_mask : signal_mux_234;
    assign signal_not_20 = ~ signal_wire_71;
    assign signal_not_21 = ~ signal_wire_83;
    assign signal_and_32 = signal_not_21 & signal_not_20;
    assign signal_eq_8 = signal_wire_67 == signal_wire_66;
    assign signal_select_88 = signal_mux_239[31:16];
    assign signal_cat = { signal_const_161,
                          signal_select_88 };
    assign signal_select_89 = signal_mux_238[31:8];
    assign signal_cat_1 = { signal_const_2,
                            signal_select_89 };
    assign signal_select_90 = signal_mux_237[31:4];
    assign signal_const_191 = 4'b0000;
    assign signal_cat_2 = { signal_const_191,
                            signal_select_90 };
    assign signal_select_91 = signal_mux_236[31:2];
    assign signal_cat_3 = { signal_const_104,
                            signal_select_91 };
    assign signal_select_92 = signal_wire_68[31:1];
    assign signal_cat_4 = { signal_const,
                            signal_select_92 };
    assign signal_select_93 = signal_mux_242[0:0];
    assign signal_mux_236 = signal_select_93 ? signal_cat_4 : signal_wire_68;
    assign signal_select_94 = signal_mux_242[1:1];
    assign signal_mux_237 = signal_select_94 ? signal_cat_3 : signal_mux_236;
    assign signal_select_95 = signal_mux_242[2:2];
    assign signal_mux_238 = signal_select_95 ? signal_cat_2 : signal_mux_237;
    assign signal_select_96 = signal_mux_242[3:3];
    assign signal_mux_239 = signal_select_96 ? signal_cat_1 : signal_mux_238;
    assign signal_select_97 = signal_mux_242[4:4];
    assign signal_mux_240 = signal_select_97 ? signal_cat : signal_mux_239;
    assign signal_select_98 = signal_mux_242[5:5];
    assign signal_mux_241 = signal_select_98 ? signal_const_9 : signal_mux_240;
    assign signal_eq_9 = signal_mux_241 == signal_const_9;
    assign signal_not_22 = ~ signal_eq_9;
    assign signal_const_194 = 6'b100000;
    assign signal_lt = signal_const_194 < signal_mux_242;
    assign signal_or_23 = signal_or_31 | signal_or_29;
    assign signal_mux_242 = signal_or_23 ? signal_const_87 : signal_wire_69;
    assign signal_eq_10 = signal_mux_242 == signal_const_87;
    assign signal_or_24 = signal_eq_10 | signal_lt;
    assign signal_or_25 = signal_or_24 | signal_not_22;
    assign signal_or_26 = signal_or_25 | signal_eq_8;
    assign signal_or_27 = signal_or_26 | signal_and_32;
    assign signal_mux_243 = signal_or_27 ? transfer$lane$reg_prepared_mask : signal_mux_235;
    assign signal_mux_244 = signal_and_48 ? signal_mux_243 : transfer$lane$reg_prepared_mask;
    assign signal_mux_245 = signal_or_42 ? transfer$lane$reg_prepared_mask : signal_mux_244;
    assign signal_wire_56 = signal_mux_245;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_prepared_mask <= signal_const_2;
        else
            transfer$lane$reg_prepared_mask <= signal_wire_56;
    end
    assign signal_and_33 = transfer$lane$reg_prepared_mask & signal_or_22;
    assign signal_eq_11 = signal_and_33 == signal_const_2;
    assign signal_not_23 = ~ signal_eq_11;
    assign signal_mux_246 = signal_not_23 ? transfer$lane$reg_busy : signal_const_1;
    assign signal_select_99 = signal_mux_248[7:7];
    assign signal_select_100 = signal_mux_248[6:6];
    assign signal_select_101 = signal_mux_248[5:5];
    assign signal_select_102 = signal_mux_248[4:4];
    assign signal_select_103 = signal_mux_248[3:3];
    assign signal_select_104 = signal_mux_248[2:2];
    assign signal_select_105 = signal_mux_248[1:1];
    assign signal_or_28 = signal_and_35 | signal_and_34;
    assign signal_not_24 = ~ transfer$front$reg_stage1;
    assign signal_and_34 = signal_not_24 & transfer$front$reg_previous;
    assign signal_wire_57 = transfer$front$reg_stage1;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$front$reg_previous <= signal_const_2;
        else
            transfer$front$reg_previous <= signal_wire_57;
    end
    assign signal_not_25 = ~ transfer$front$reg_previous;
    assign signal_wire_58 = pin_async_i;
    assign signal_wire_59 = signal_wire_58;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$front$reg_stage0 <= signal_const_2;
        else
            transfer$front$reg_stage0 <= signal_wire_59;
    end
    assign signal_wire_60 = transfer$front$reg_stage0;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$front$reg_stage1 <= signal_const_2;
        else
            transfer$front$reg_stage1 <= signal_wire_60;
    end
    assign signal_and_35 = transfer$front$reg_stage1 & signal_not_25;
    assign signal_mux_247 = signal_and_45 ? signal_wire_76 : transfer$config_start_edge_kind;
    assign signal_wire_61 = signal_mux_247;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$config_start_edge_kind <= signal_const_104;
        else
            transfer$config_start_edge_kind <= signal_wire_61;
    end
    always @* begin
        case (transfer$config_start_edge_kind)
        0:
            signal_mux_248 <= signal_and_35;
        1:
            signal_mux_248 <= signal_and_34;
        2:
            signal_mux_248 <= signal_or_28;
        default:
            signal_mux_248 <= signal_const_2;
        endcase
    end
    assign signal_select_106 = signal_mux_248[0:0];
    assign signal_wire_62 = reset_i;
    assign signal_wire_63 = clock_i;
    assign signal_wire_64 = start_pin_i;
    assign signal_wire_65 = tx_valid_i;
    assign signal_not_26 = ~ signal_wire_65;
    assign signal_and_36 = signal_wire_83 & signal_not_26;
    assign signal_not_27 = ~ signal_wire_71;
    assign signal_not_28 = ~ signal_wire_83;
    assign signal_and_37 = signal_not_28 & signal_not_27;
    assign signal_wire_66 = sample_trailing_i;
    assign signal_wire_67 = launch_trailing_i;
    assign signal_eq_12 = signal_wire_67 == signal_wire_66;
    assign signal_select_107 = signal_mux_252[31:16];
    assign signal_cat_5 = { signal_const_161,
                            signal_select_107 };
    assign signal_select_108 = signal_mux_251[31:8];
    assign signal_cat_6 = { signal_const_2,
                            signal_select_108 };
    assign signal_select_109 = signal_mux_250[31:4];
    assign signal_cat_7 = { signal_const_191,
                            signal_select_109 };
    assign signal_select_110 = signal_mux_249[31:2];
    assign signal_cat_8 = { signal_const_104,
                            signal_select_110 };
    assign signal_select_111 = signal_wire_68[31:1];
    assign signal_cat_9 = { signal_const,
                            signal_select_111 };
    assign signal_wire_68 = tx_value_i;
    assign signal_select_112 = signal_wire_69[0:0];
    assign signal_mux_249 = signal_select_112 ? signal_cat_9 : signal_wire_68;
    assign signal_select_113 = signal_wire_69[1:1];
    assign signal_mux_250 = signal_select_113 ? signal_cat_8 : signal_mux_249;
    assign signal_select_114 = signal_wire_69[2:2];
    assign signal_mux_251 = signal_select_114 ? signal_cat_7 : signal_mux_250;
    assign signal_select_115 = signal_wire_69[3:3];
    assign signal_mux_252 = signal_select_115 ? signal_cat_6 : signal_mux_251;
    assign signal_select_116 = signal_wire_69[4:4];
    assign signal_mux_253 = signal_select_116 ? signal_cat_5 : signal_mux_252;
    assign signal_select_117 = signal_wire_69[5:5];
    assign signal_mux_254 = signal_select_117 ? signal_const_9 : signal_mux_253;
    assign signal_eq_13 = signal_mux_254 == signal_const_9;
    assign signal_not_29 = ~ signal_eq_13;
    assign signal_lt_1 = signal_const_194 < signal_wire_69;
    assign signal_wire_69 = bit_count_i;
    assign signal_eq_14 = signal_wire_69 == signal_const_87;
    assign signal_wire_70 = input_pin_i;
    assign signal_eq_15 = signal_wire_72 == signal_wire_70;
    assign signal_wire_71 = rx_enable_i;
    assign signal_and_38 = signal_wire_71 & signal_eq_15;
    assign signal_wire_72 = pacing_pin_i;
    assign signal_eq_16 = signal_wire_72 == signal_wire_82;
    assign signal_and_39 = signal_wire_83 & signal_eq_16;
    assign signal_or_29 = signal_and_39 | signal_and_38;
    assign signal_const_212 = 2'b11;
    assign signal_wire_73 = cancel_edge_kind_i;
    assign signal_eq_17 = signal_wire_73 == signal_const_212;
    assign signal_wire_74 = cancel_enable_i;
    assign signal_and_40 = signal_wire_74 & signal_eq_17;
    assign signal_wire_75 = pacing_edge_kind_i;
    assign signal_eq_18 = signal_wire_75 == signal_const_212;
    assign signal_wire_76 = start_edge_kind_i;
    assign signal_eq_19 = signal_wire_76 == signal_const_212;
    assign signal_or_30 = signal_eq_19 | signal_eq_18;
    assign signal_or_31 = signal_or_30 | signal_and_40;
    assign signal_or_32 = signal_or_31 | signal_or_29;
    assign signal_or_33 = signal_or_32 | signal_eq_14;
    assign signal_or_34 = signal_or_33 | signal_lt_1;
    assign signal_or_35 = signal_or_34 | signal_not_29;
    assign signal_or_36 = signal_or_35 | signal_eq_12;
    assign signal_or_37 = signal_or_36 | signal_and_37;
    assign signal_or_38 = signal_or_37 | signal_and_36;
    assign signal_not_30 = ~ signal_or_38;
    assign signal_not_31 = ~ signal_or_40;
    assign signal_not_32 = ~ transfer$lane$reg_armed;
    assign signal_not_33 = ~ transfer$lane$reg_busy;
    assign signal_and_41 = signal_wire_87 & signal_not_33;
    assign signal_and_42 = signal_and_41 & signal_not_32;
    assign signal_and_43 = signal_and_54 & signal_and_42;
    assign signal_and_44 = signal_and_43 & signal_not_31;
    assign signal_and_45 = signal_and_44 & signal_not_30;
    assign signal_mux_255 = signal_and_45 ? signal_wire_64 : transfer$config_start_pin;
    assign signal_wire_77 = signal_mux_255;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$config_start_pin <= signal_const_13;
        else
            transfer$config_start_pin <= signal_wire_77;
    end
    always @* begin
        case (transfer$config_start_pin)
        0:
            signal_mux_256 <= signal_select_106;
        1:
            signal_mux_256 <= signal_select_105;
        2:
            signal_mux_256 <= signal_select_104;
        3:
            signal_mux_256 <= signal_select_103;
        4:
            signal_mux_256 <= signal_select_102;
        5:
            signal_mux_256 <= signal_select_101;
        6:
            signal_mux_256 <= signal_select_100;
        default:
            signal_mux_256 <= signal_select_99;
        endcase
    end
    assign signal_and_46 = transfer$lane$reg_armed & signal_mux_256;
    assign signal_mux_257 = signal_and_46 ? signal_mux_246 : transfer$lane$reg_busy;
    assign signal_mux_258 = transfer$lane$reg_busy ? signal_mux_221 : signal_mux_257;
    assign signal_mux_259 = signal_and_48 ? signal_mux_178 : signal_mux_258;
    assign signal_mux_260 = signal_or_42 ? signal_const : signal_mux_259;
    assign signal_wire_78 = signal_mux_260;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_busy <= signal_const;
        else
            transfer$lane$reg_busy <= signal_wire_78;
    end
    assign signal_not_34 = ~ transfer$lane$reg_busy;
    assign signal_and_47 = signal_and_54 & signal_not_34;
    assign signal_and_48 = signal_and_47 & signal_not_13;
    assign signal_mux_261 = signal_and_48 ? signal_mux_175 : signal_mux_176;
    assign signal_mux_262 = signal_or_42 ? signal_const : signal_mux_261;
    assign signal_wire_79 = signal_mux_262;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_armed <= signal_const;
        else
            transfer$lane$reg_armed <= signal_wire_79;
    end
    assign signal_or_39 = transfer$lane$reg_armed | transfer$lane$reg_busy;
    assign signal_wire_80 = signal_or_39;
    assign signal_and_49 = signal_wire_80 & transfer$config_cancel_enable;
    assign signal_and_50 = signal_and_49 & signal_mux_172;
    assign signal_mux_263 = signal_or_44 ? signal_const_1 : signal_const;
    assign signal_mux_264 = signal_and_53 ? signal_const_1 : signal_mux_263;
    always @* begin
        case (signal_reg)
        2'b01:
            signal_cases_5 <= signal_mux_264;
        default:
            signal_cases_5 <= signal_const;
        endcase
    end
    assign signal_mux_265 = signal_or_54 ? signal_const : signal_cases_5;
    assign wire_local_abort = signal_mux_265;
    assign signal_or_40 = signal_wire_86 | wire_local_abort;
    assign signal_or_41 = signal_or_40 | signal_and_50;
    assign signal_not_35 = ~ signal_wire_87;
    assign signal_or_42 = signal_not_35 | signal_or_41;
    assign signal_mux_266 = signal_or_42 ? signal_const : signal_mux_168;
    assign signal_wire_81 = signal_mux_266;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            transfer$lane$reg_rejected <= signal_const;
        else
            transfer$lane$reg_rejected <= signal_wire_81;
    end
    assign signal_or_43 = transfer$lane$reg_rejected | transfer$lane$reg_underrun;
    assign signal_or_44 = signal_or_43 | transfer$lane$reg_overrun;
    assign signal_mux_267 = signal_or_44 ? signal_const : signal_mux_150;
    assign signal_mux_268 = signal_and_53 ? signal_const : signal_mux_267;
    always @* begin
        case (signal_reg)
        2'b01:
            signal_cases_6 <= signal_mux_268;
        default:
            signal_cases_6 <= signal_const;
        endcase
    end
    assign signal_mux_269 = signal_or_54 ? signal_const : signal_cases_6;
    assign wire_write = signal_mux_269;
    assign signal_or_45 = wire_claim | wire_write;
    assign signal_or_46 = signal_or_45 | wire_clear;
    assign signal_or_47 = signal_or_46 | wire_release;
    assign signal_not_36 = ~ signal_or_47;
    assign signal_and_51 = signal_not_36 & signal_wire_30;
    assign signal_wire_82 = output_pin_i;
    always @* begin
        case (signal_wire_82)
        0:
            signal_mux_270 <= signal_const_70;
        1:
            signal_mux_270 <= signal_const_69;
        2:
            signal_mux_270 <= signal_const_68;
        3:
            signal_mux_270 <= signal_const_67;
        4:
            signal_mux_270 <= signal_const_66;
        5:
            signal_mux_270 <= signal_const_65;
        6:
            signal_mux_270 <= signal_const_64;
        default:
            signal_mux_270 <= signal_const_63;
        endcase
    end
    assign signal_wire_83 = tx_enable_i;
    assign signal_mux_271 = signal_wire_83 ? signal_mux_270 : signal_const_2;
    assign signal_eq_20 = signal_mux_271 == signal_const_2;
    assign signal_not_37 = ~ signal_eq_20;
    assign signal_mux_272 = signal_not_37 ? signal_const_1 : signal_const;
    assign signal_mux_273 = signal_and_54 ? signal_mux_272 : signal_const;
    always @* begin
        case (signal_reg)
        2'b00:
            signal_cases_7 <= signal_mux_273;
        default:
            signal_cases_7 <= signal_const;
        endcase
    end
    assign signal_mux_274 = signal_or_54 ? signal_const : signal_cases_7;
    assign wire_claim = signal_mux_274;
    assign signal_or_48 = wire_claim | signal_and_51;
    assign signal_and_52 = signal_or_48 & signal_or_16;
    assign signal_or_49 = signal_and_52 | signal_and_20;
    assign signal_or_50 = signal_or_49 | signal_and_19;
    assign signal_or_51 = signal_or_50 | signal_and_16;
    assign signal_or_52 = signal_or_51 | signal_and_14;
    assign signal_mux_275 = signal_or_52 ? signal_const_1 : signal_const;
    assign signal_not_38 = ~ signal_wire_87;
    assign signal_or_53 = signal_not_38 | signal_wire_86;
    assign signal_mux_276 = signal_or_53 ? signal_const : signal_mux_275;
    assign signal_wire_84 = signal_mux_276;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            bank$reg_rejected <= signal_const;
        else
            bank$reg_rejected <= signal_wire_84;
    end
    assign signal_and_53 = bank$reg_rejected & reg_internal_pending;
    assign signal_mux_277 = signal_and_53 ? signal_mux_124 : signal_mux_125;
    assign signal_const_232 = 2'b01;
    assign signal_wire_85 = arm_valid_i;
    assign signal_and_54 = signal_wire_85 & signal_and_55;
    assign signal_mux_278 = signal_and_54 ? signal_const_232 : signal_reg;
    always @* begin
        case (signal_reg)
        2'b00:
            signal_cases_8 <= signal_mux_278;
        2'b01:
            signal_cases_8 <= signal_mux_277;
        2'b10:
            signal_cases_8 <= signal_const_104;
        default:
            signal_cases_8 <= signal_reg;
        endcase
    end
    assign signal_wire_86 = abort_i;
    assign signal_wire_87 = enable_i;
    assign signal_not_39 = ~ signal_wire_87;
    assign signal_or_54 = signal_not_39 | signal_wire_86;
    assign signal_mux_279 = signal_or_54 ? signal_const_104 : signal_cases_8;
    assign signal_wire_88 = signal_mux_279;
    always @(posedge signal_wire_63) begin
        if (signal_wire_62)
            signal_reg <= signal_const_104;
        else
            signal_reg <= signal_wire_88;
    end
    assign signal_eq_21 = signal_const_104 == signal_reg;
    assign signal_and_55 = signal_eq_21 & signal_not_5;
    assign arm_ready_o = signal_and_55;
    assign transaction_done_o = wire_transaction_done;
    assign transaction_rejected_o = reg_transaction_rejected;
    assign software_rejected_o = reg_software_rejected;
    assign snapshot_o = transfer$front$reg_stage1;
    assign start_edge_o = signal_mux_256;
    assign pacing_edge_o = signal_mux_203;
    assign cancel_edge_o = signal_and_50;
    assign armed_o = transfer$lane$reg_armed;
    assign busy_o = transfer$lane$reg_busy;
    assign lane_claim_o = transfer$lane$reg_claim_mask;
    assign lane_pin_value_o = transfer$lane$reg_pin_value;
    assign lane_pin_oe_o = transfer$lane$reg_pin_oe;
    assign done_o = transfer$lane$reg_done_;
    assign rx_valid_o = transfer$lane$reg_rx_valid;
    assign rx_data_o = transfer$lane$reg_rx_data;
    assign rejected_o = transfer$lane$reg_rejected;
    assign underrun_o = transfer$lane$reg_underrun;
    assign overrun_o = transfer$lane$reg_overrun;
    assign pins_o = bank$reg_pins;
    assign pin_oe_o = bank$reg_pin_oe;
    assign software_claim_o = bank$reg_software_claim;
    assign engine_claim_o = bank$reg_engine_claim;
    assign bank_rejected_o = bank$reg_rejected;
    assign bank_conflict_o = bank$reg_conflict;

endmodule
