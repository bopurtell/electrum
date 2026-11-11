module executable_core (
    clock_i,
    reset_i,
    en_i,
    engines_idle_i,
    load_start_valid_i,
    load_length_i,
    load_write_valid_i,
    load_address_i,
    load_data_i,
    load_complete_valid_i,
    readback_valid_i,
    readback_address_i,
    readback_verify_i,
    readback_expected_i,
    run_valid_i,
    prog_mem_read_data_i,
    mechanism_accepted_i,
    mechanism_refused_i,
    mechanism_refusal_reason_i,
    mechanism_completion_valid_i,
    mechanism_completion_result_i,
    mechanism_completion_fault_i,
    mechanism_completion_reason_i,
    prog_mem_enable_o,
    prog_mem_write_enable_o,
    prog_mem_address_o,
    prog_mem_write_data_o,
    load_start_accepted_o,
    load_start_rejected_o,
    load_write_accepted_o,
    load_write_rejected_o,
    load_complete_accepted_o,
    load_complete_rejected_o,
    readback_accepted_o,
    readback_rejected_o,
    run_accepted_o,
    run_rejected_o,
    readback_response_valid_o,
    readback_response_data_o,
    readback_response_match_o,
    fetch_completion_valid_o,
    fetch_completion_data_o,
    fetch_response_valid_o,
    fetch_response_data_o,
    halted_o,
    image_valid_o,
    load_active_o,
    image_length_o,
    words_written_o,
    words_verified_o,
    verification_failed_o,
    fetch_fault_event_o,
    fetch_fault_o,
    mechanism_request_valid_o,
    mechanism_kind_o,
    mechanism_arg0_o,
    mechanism_arg1_o,
    mechanism_arg2_o,
    mechanism_timeout_enable_o,
    mechanism_descriptor_o,
    execution_active_o,
    normal_halt_o,
    execution_fault_o,
    fault_kind_o,
    fault_instruction_slot_o,
    fault_address_o,
    fault_reason_o,
    instruction_boundary_o,
    retired_o,
    pc_o,
    registers_o,
    zero_o,
    carry_o,
    negative_o,
    descriptor_o,
    phase_o,
    fetch_cycles_o,
    execute_cycles_o,
    stall_cycles_o,
    instruction_count_o,
    extension_fetches_o,
    total_cycles_o
);

    input clock_i;
    input reset_i;
    input en_i;
    input engines_idle_i;
    input load_start_valid_i;
    input [8:0] load_length_i;
    input load_write_valid_i;
    input [8:0] load_address_i;
    input [15:0] load_data_i;
    input load_complete_valid_i;
    input readback_valid_i;
    input [8:0] readback_address_i;
    input readback_verify_i;
    input [15:0] readback_expected_i;
    input run_valid_i;
    input [15:0] prog_mem_read_data_i;
    input mechanism_accepted_i;
    input mechanism_refused_i;
    input [7:0] mechanism_refusal_reason_i;
    input mechanism_completion_valid_i;
    input [15:0] mechanism_completion_result_i;
    input mechanism_completion_fault_i;
    input [7:0] mechanism_completion_reason_i;
    output prog_mem_enable_o;
    output prog_mem_write_enable_o;
    output [7:0] prog_mem_address_o;
    output [15:0] prog_mem_write_data_o;
    output load_start_accepted_o;
    output load_start_rejected_o;
    output load_write_accepted_o;
    output load_write_rejected_o;
    output load_complete_accepted_o;
    output load_complete_rejected_o;
    output readback_accepted_o;
    output readback_rejected_o;
    output run_accepted_o;
    output run_rejected_o;
    output readback_response_valid_o;
    output [15:0] readback_response_data_o;
    output readback_response_match_o;
    output fetch_completion_valid_o;
    output [15:0] fetch_completion_data_o;
    output fetch_response_valid_o;
    output [15:0] fetch_response_data_o;
    output halted_o;
    output image_valid_o;
    output load_active_o;
    output [8:0] image_length_o;
    output [8:0] words_written_o;
    output [8:0] words_verified_o;
    output verification_failed_o;
    output fetch_fault_event_o;
    output fetch_fault_o;
    output mechanism_request_valid_o;
    output [3:0] mechanism_kind_o;
    output [15:0] mechanism_arg0_o;
    output [15:0] mechanism_arg1_o;
    output [15:0] mechanism_arg2_o;
    output mechanism_timeout_enable_o;
    output [143:0] mechanism_descriptor_o;
    output execution_active_o;
    output normal_halt_o;
    output execution_fault_o;
    output [3:0] fault_kind_o;
    output [16:0] fault_instruction_slot_o;
    output [16:0] fault_address_o;
    output [7:0] fault_reason_o;
    output instruction_boundary_o;
    output retired_o;
    output [16:0] pc_o;
    output [127:0] registers_o;
    output zero_o;
    output carry_o;
    output negative_o;
    output [143:0] descriptor_o;
    output [2:0] phase_o;
    output [31:0] fetch_cycles_o;
    output [31:0] execute_cycles_o;
    output [31:0] stall_cycles_o;
    output [31:0] instruction_count_o;
    output [31:0] extension_fetches_o;
    output [31:0] total_cycles_o;

    wire [31:0] signal_const;
    wire [31:0] signal_add;
    wire [31:0] signal_add_1;
    wire [31:0] signal_add_2;
    wire [31:0] signal_const_3;
    wire [31:0] signal_mux;
    wire [31:0] signal_mux_1;
    wire [31:0] signal_mux_2;
    wire [31:0] signal_mux_3;
    wire [31:0] signal_mux_4;
    wire [31:0] signal_mux_5;
    wire [31:0] signal_wire;
    reg [31:0] execution$reg_total_cycles;
    wire [31:0] signal_add_3;
    wire [31:0] signal_mux_6;
    wire [31:0] signal_mux_7;
    wire [31:0] signal_mux_8;
    wire [31:0] signal_mux_9;
    wire [31:0] signal_mux_10;
    wire [31:0] signal_wire_1;
    reg [31:0] execution$reg_extension_fetches;
    wire [31:0] signal_add_4;
    wire [31:0] signal_mux_11;
    wire [31:0] signal_mux_12;
    wire [31:0] signal_mux_13;
    wire [31:0] signal_mux_14;
    wire [31:0] signal_wire_2;
    reg [31:0] execution$reg_instruction_count;
    wire [31:0] signal_add_5;
    wire [31:0] signal_mux_15;
    wire signal_not;
    wire signal_not_1;
    wire signal_and;
    wire signal_and_1;
    wire signal_or;
    wire [31:0] signal_mux_16;
    wire [31:0] signal_mux_17;
    wire [31:0] signal_mux_18;
    wire [31:0] signal_wire_3;
    reg [31:0] execution$reg_stall_cycles;
    wire [31:0] signal_add_6;
    wire [31:0] signal_mux_19;
    wire signal_or_1;
    wire signal_or_2;
    wire signal_or_3;
    wire [31:0] signal_mux_20;
    wire [31:0] signal_mux_21;
    wire [31:0] signal_mux_22;
    wire [31:0] signal_wire_4;
    reg [31:0] execution$reg_execute_cycles;
    wire [31:0] signal_add_7;
    wire [31:0] signal_mux_23;
    wire [31:0] signal_mux_24;
    wire [31:0] signal_mux_25;
    wire [31:0] signal_mux_26;
    wire [31:0] signal_wire_5;
    reg [31:0] execution$reg_fetch_cycles;
    wire [127:0] signal_cat;
    wire signal_const_14;
    wire signal_const_15;
    wire signal_mux_27;
    wire signal_mux_28;
    wire signal_mux_29;
    wire signal_mux_30;
    wire signal_wire_6;
    reg execution$reg_retired;
    wire signal_mux_31;
    wire signal_mux_32;
    wire signal_mux_33;
    wire signal_mux_34;
    wire signal_mux_35;
    wire signal_mux_36;
    wire signal_mux_37;
    wire signal_mux_38;
    wire signal_mux_39;
    wire signal_mux_40;
    wire signal_mux_41;
    wire signal_mux_42;
    wire signal_mux_43;
    wire signal_wire_7;
    reg execution$reg_boundary;
    wire [7:0] signal_wire_8;
    wire [7:0] signal_wire_9;
    wire [4:0] signal_const_29;
    wire [7:0] signal_cat_1;
    wire [2:0] signal_const_30;
    wire [2:0] signal_const_31;
    wire [2:0] signal_const_32;
    wire [2:0] signal_const_33;
    wire [2:0] signal_const_34;
    wire [2:0] signal_const_35;
    wire signal_not_2;
    wire signal_and_2;
    wire [2:0] signal_mux_44;
    wire signal_not_3;
    wire signal_and_3;
    wire [2:0] signal_mux_45;
    wire signal_not_4;
    wire [2:0] signal_mux_46;
    wire signal_not_5;
    wire signal_not_6;
    wire signal_or_4;
    wire [2:0] signal_mux_47;
    wire signal_not_7;
    wire [2:0] signal_mux_48;
    wire [7:0] signal_cat_2;
    wire [7:0] signal_const_37;
    wire [7:0] signal_mux_49;
    wire [7:0] signal_mux_50;
    wire [7:0] signal_mux_51;
    wire [7:0] signal_mux_52;
    wire [7:0] signal_mux_53;
    wire [7:0] signal_mux_54;
    wire [7:0] signal_mux_55;
    wire [7:0] signal_mux_56;
    wire [7:0] signal_mux_57;
    wire [7:0] signal_mux_58;
    wire [7:0] signal_mux_59;
    wire [7:0] signal_mux_60;
    wire [7:0] signal_wire_10;
    reg [7:0] execution$reg_fault_reason;
    wire [16:0] signal_const_41;
    wire [16:0] signal_mux_61;
    wire [16:0] signal_mux_62;
    wire [16:0] signal_mux_63;
    wire [16:0] signal_mux_64;
    wire [16:0] signal_mux_65;
    wire [16:0] signal_mux_66;
    wire [16:0] signal_mux_67;
    wire [16:0] signal_mux_68;
    wire [16:0] signal_mux_69;
    wire [16:0] signal_mux_70;
    wire [16:0] signal_mux_71;
    wire [16:0] signal_mux_72;
    wire [16:0] signal_wire_11;
    reg [16:0] execution$reg_fault_address;
    wire [16:0] signal_mux_73;
    wire signal_or_5;
    wire [16:0] signal_mux_74;
    wire [16:0] signal_mux_75;
    wire [16:0] signal_mux_76;
    wire [16:0] signal_wire_12;
    reg [16:0] execution$reg_last_instruction_slot;
    wire [16:0] signal_mux_77;
    wire [16:0] signal_mux_78;
    wire [16:0] signal_mux_79;
    wire [16:0] signal_mux_80;
    wire [16:0] signal_mux_81;
    wire [16:0] signal_mux_82;
    wire [16:0] signal_mux_83;
    wire [16:0] signal_mux_84;
    wire [16:0] signal_mux_85;
    wire [16:0] signal_mux_86;
    wire [16:0] signal_mux_87;
    wire [16:0] signal_mux_88;
    wire [16:0] signal_wire_13;
    reg [16:0] execution$reg_fault_instruction_slot;
    wire [3:0] signal_const_44;
    wire [3:0] signal_const_45;
    wire [3:0] signal_const_46;
    wire [3:0] signal_const_47;
    wire [3:0] signal_const_48;
    wire [3:0] signal_const_49;
    wire [3:0] signal_const_50;
    wire [3:0] signal_const_51;
    wire [3:0] signal_const_52;
    wire [3:0] signal_const_53;
    wire [3:0] signal_mux_89;
    wire [3:0] signal_mux_90;
    wire [3:0] signal_mux_91;
    wire [3:0] signal_mux_92;
    wire [3:0] signal_mux_93;
    wire [3:0] signal_mux_94;
    wire [3:0] signal_mux_95;
    wire [3:0] signal_mux_96;
    wire [3:0] signal_mux_97;
    wire [3:0] signal_mux_98;
    wire [3:0] signal_mux_99;
    wire [3:0] signal_mux_100;
    wire [3:0] signal_wire_14;
    reg [3:0] execution$reg_fault_kind;
    wire signal_mux_101;
    wire signal_mux_102;
    wire signal_mux_103;
    wire signal_mux_104;
    wire signal_mux_105;
    wire signal_mux_106;
    wire signal_mux_107;
    wire signal_mux_108;
    wire signal_mux_109;
    wire signal_mux_110;
    wire signal_mux_111;
    wire signal_mux_112;
    wire signal_wire_15;
    reg execution$reg_execution_fault;
    wire signal_mux_113;
    wire signal_mux_114;
    wire signal_mux_115;
    wire signal_mux_116;
    wire signal_mux_117;
    wire signal_mux_118;
    wire signal_mux_119;
    wire signal_mux_120;
    wire signal_mux_121;
    wire signal_mux_122;
    wire signal_mux_123;
    wire signal_mux_124;
    wire signal_mux_125;
    wire signal_wire_16;
    reg execution$reg_normal_halt;
    wire [2:0] signal_const_75;
    wire signal_eq;
    wire signal_not_8;
    wire signal_eq_1;
    wire signal_not_9;
    wire signal_and_4;
    wire [3:0] signal_select;
    wire signal_eq_2;
    wire [15:0] signal_mux_126;
    wire [15:0] signal_const_78;
    wire [15:0] signal_mux_127;
    wire [15:0] signal_mux_128;
    wire [15:0] signal_mux_129;
    wire [15:0] signal_mux_130;
    wire [15:0] signal_wire_17;
    reg [15:0] execution$reg_desc_control;
    wire [3:0] signal_select_1;
    wire signal_eq_3;
    wire [15:0] signal_mux_131;
    wire [15:0] signal_mux_132;
    wire [15:0] signal_mux_133;
    wire [15:0] signal_mux_134;
    wire [15:0] signal_mux_135;
    wire [15:0] signal_wire_18;
    reg [15:0] execution$reg_desc_bit_count;
    wire [3:0] signal_select_2;
    wire signal_eq_4;
    wire [15:0] signal_mux_136;
    wire [15:0] signal_mux_137;
    wire [15:0] signal_mux_138;
    wire [15:0] signal_mux_139;
    wire [15:0] signal_mux_140;
    wire [15:0] signal_wire_19;
    reg [15:0] execution$reg_desc_tx_value;
    wire [3:0] signal_select_3;
    wire signal_eq_5;
    wire [15:0] signal_mux_141;
    wire [15:0] signal_const_84;
    wire [15:0] signal_mux_142;
    wire [15:0] signal_mux_143;
    wire [15:0] signal_mux_144;
    wire [15:0] signal_mux_145;
    wire [15:0] signal_wire_20;
    reg [15:0] execution$reg_desc_output_pin;
    wire [3:0] signal_select_4;
    wire signal_eq_6;
    wire [15:0] signal_mux_146;
    wire [15:0] signal_mux_147;
    wire [15:0] signal_mux_148;
    wire [15:0] signal_mux_149;
    wire [15:0] signal_mux_150;
    wire [15:0] signal_wire_21;
    reg [15:0] execution$reg_desc_input_pin;
    wire [3:0] signal_select_5;
    wire signal_eq_7;
    wire [15:0] signal_mux_151;
    wire [15:0] signal_mux_152;
    wire [15:0] signal_mux_153;
    wire [15:0] signal_mux_154;
    wire [15:0] signal_mux_155;
    wire [15:0] signal_wire_22;
    reg [15:0] execution$reg_desc_clock_pin;
    wire [3:0] signal_select_6;
    wire signal_eq_8;
    wire [15:0] signal_mux_156;
    wire [15:0] signal_mux_157;
    wire [15:0] signal_mux_158;
    wire [15:0] signal_mux_159;
    wire [15:0] signal_mux_160;
    wire [15:0] signal_wire_23;
    reg [15:0] execution$reg_desc_initial_delay;
    wire [3:0] signal_select_7;
    wire signal_eq_9;
    wire [15:0] signal_mux_161;
    wire [15:0] signal_mux_162;
    wire [15:0] signal_mux_163;
    wire [15:0] signal_mux_164;
    wire [15:0] signal_mux_165;
    wire [15:0] signal_wire_24;
    reg [15:0] execution$reg_desc_half_period;
    wire [3:0] signal_select_8;
    wire signal_eq_10;
    wire [15:0] signal_mux_166;
    wire [15:0] signal_mux_167;
    wire [4:0] signal_const_95;
    wire signal_eq_11;
    wire signal_and_5;
    wire [15:0] signal_mux_168;
    wire [15:0] signal_mux_169;
    wire [15:0] signal_mux_170;
    wire [15:0] signal_wire_25;
    reg [15:0] execution$reg_desc_pacing;
    wire [143:0] signal_cat_3;
    wire signal_select_9;
    wire signal_select_10;
    wire [4:0] signal_const_96;
    wire signal_eq_12;
    wire signal_mux_171;
    wire [4:0] signal_const_97;
    wire signal_eq_13;
    wire signal_mux_172;
    wire [2:0] signal_select_11;
    reg [15:0] signal_mux_173;
    wire [2:0] signal_select_12;
    reg [15:0] signal_mux_174;
    reg [15:0] signal_mux_175;
    wire signal_select_13;
    wire [14:0] signal_const_130;
    wire [15:0] signal_cat_4;
    wire signal_select_14;
    wire [15:0] signal_cat_5;
    wire [1:0] signal_select_15;
    wire [13:0] signal_const_136;
    wire [15:0] signal_cat_6;
    wire signal_select_16;
    wire [15:0] signal_cat_7;
    wire [2:0] signal_select_17;
    reg [15:0] signal_mux_176;
    wire [7:0] signal_select_18;
    wire [15:0] signal_cat_8;
    wire signal_select_19;
    wire [15:0] signal_cat_9;
    reg [15:0] signal_mux_177;
    wire signal_select_20;
    wire [15:0] signal_cat_10;
    wire signal_select_21;
    wire [15:0] signal_cat_11;
    wire [2:0] signal_select_22;
    wire [12:0] signal_const_166;
    wire [15:0] signal_cat_12;
    wire [2:0] signal_select_23;
    wire [15:0] signal_cat_13;
    wire [2:0] signal_select_24;
    reg [15:0] signal_mux_178;
    wire signal_select_25;
    wire [15:0] signal_cat_14;
    wire signal_select_26;
    wire [15:0] signal_cat_15;
    wire [2:0] signal_select_27;
    wire [15:0] signal_cat_16;
    wire [5:0] signal_select_28;
    wire [9:0] signal_const_174;
    wire [15:0] signal_cat_17;
    wire [2:0] signal_select_29;
    wire [15:0] signal_cat_18;
    wire [2:0] signal_select_30;
    wire [15:0] signal_cat_19;
    reg [15:0] signal_mux_179;
    wire [3:0] signal_const_190;
    wire [3:0] signal_const_191;
    wire [3:0] signal_const_192;
    wire [3:0] signal_const_194;
    wire [3:0] signal_const_195;
    reg [3:0] signal_mux_180;
    wire signal_mux_181;
    wire signal_mux_182;
    wire signal_mux_183;
    wire signal_mux_184;
    wire signal_wire_26;
    reg signal_reg;
    wire [15:0] signal_mux_185;
    wire [15:0] signal_mux_186;
    wire [15:0] signal_wire_27;
    reg [15:0] signal_reg_1;
    wire signal_mux_187;
    wire signal_mux_188;
    wire signal_mux_189;
    wire signal_mux_190;
    wire signal_wire_28;
    reg signal_reg_2;
    wire signal_and_6;
    wire signal_mux_191;
    wire signal_mux_192;
    wire signal_wire_29;
    reg signal_reg_3;
    wire [15:0] signal_mux_193;
    wire [15:0] signal_mux_194;
    wire [15:0] signal_wire_30;
    reg [15:0] signal_reg_4;
    wire signal_mux_195;
    wire signal_mux_196;
    wire signal_mux_197;
    wire signal_mux_198;
    wire signal_wire_31;
    reg signal_reg_5;
    wire signal_not_10;
    wire signal_and_7;
    wire signal_not_11;
    wire signal_and_8;
    wire signal_not_12;
    wire signal_and_9;
    wire signal_not_13;
    wire signal_and_10;
    wire signal_not_14;
    wire signal_and_11;
    wire [15:0] signal_wire_32;
    wire [8:0] signal_mux_199;
    wire [8:0] signal_mux_200;
    wire [7:0] signal_select_31;
    wire signal_not_15;
    wire signal_and_12;
    wire signal_not_16;
    wire signal_or_6;
    wire signal_lt;
    wire [8:0] signal_wire_33;
    wire signal_eq_14;
    wire signal_not_17;
    wire signal_not_18;
    wire signal_wire_34;
    wire signal_mux_201;
    wire signal_mux_202;
    wire signal_not_19;
    wire signal_not_20;
    wire signal_and_13;
    wire signal_mux_203;
    wire signal_mux_204;
    wire signal_mux_205;
    wire signal_lt_1;
    wire [8:0] signal_const_248;
    wire [16:0] signal_const_249;
    wire [16:0] signal_add_8;
    wire [16:0] signal_mux_206;
    wire [8:0] signal_select_32;
    wire [8:0] signal_wire_35;
    wire signal_lt_2;
    wire signal_and_14;
    wire signal_wire_36;
    wire signal_or_7;
    wire signal_or_8;
    wire signal_or_9;
    wire signal_or_10;
    wire signal_or_11;
    wire signal_or_12;
    wire signal_or_13;
    wire signal_or_14;
    wire signal_eq_15;
    wire signal_not_21;
    wire signal_and_15;
    wire signal_not_22;
    wire [2:0] signal_mux_207;
    wire [2:0] signal_mux_208;
    wire [2:0] signal_mux_209;
    wire [2:0] signal_mux_210;
    wire [2:0] signal_mux_211;
    wire signal_not_23;
    wire signal_not_24;
    wire signal_and_16;
    wire signal_and_17;
    wire [2:0] signal_mux_212;
    wire signal_not_25;
    wire signal_and_18;
    wire [2:0] signal_mux_213;
    wire [2:0] signal_mux_214;
    wire signal_not_26;
    wire signal_and_19;
    wire [2:0] signal_mux_215;
    wire signal_and_20;
    wire [2:0] signal_mux_216;
    wire signal_and_21;
    wire [2:0] signal_mux_217;
    wire signal_not_27;
    wire signal_and_22;
    wire [2:0] signal_mux_218;
    wire [15:0] signal_const_271;
    wire signal_lt_3;
    wire signal_not_28;
    wire signal_eq_16;
    wire signal_not_29;
    wire signal_eq_17;
    wire signal_eq_18;
    wire [4:0] signal_const_275;
    wire signal_eq_19;
    wire [4:0] signal_const_276;
    wire signal_eq_20;
    wire signal_or_15;
    wire signal_or_16;
    wire signal_or_17;
    wire signal_mux_219;
    wire [4:0] signal_const_277;
    wire signal_eq_21;
    wire signal_mux_220;
    wire signal_mux_221;
    wire signal_mux_222;
    wire signal_mux_223;
    wire signal_mux_224;
    wire signal_mux_225;
    wire signal_wire_37;
    reg execution$reg_has_extension;
    wire signal_or_18;
    wire signal_and_23;
    wire signal_and_24;
    wire signal_or_19;
    wire signal_and_25;
    wire signal_not_30;
    wire signal_or_20;
    wire signal_and_26;
    wire signal_not_31;
    wire signal_and_27;
    wire [2:0] signal_mux_226;
    wire signal_not_32;
    wire signal_and_28;
    wire signal_and_29;
    wire [2:0] signal_mux_227;
    wire signal_or_21;
    wire signal_and_30;
    wire [2:0] signal_mux_228;
    wire signal_not_33;
    wire signal_not_34;
    wire signal_and_31;
    wire signal_and_32;
    wire signal_and_33;
    wire [2:0] signal_mux_229;
    wire signal_eq_22;
    wire signal_eq_23;
    wire [4:0] signal_const_284;
    wire signal_eq_24;
    wire [4:0] signal_const_285;
    wire signal_eq_25;
    wire [4:0] signal_const_286;
    wire signal_eq_26;
    wire [4:0] signal_const_287;
    wire signal_eq_27;
    wire [4:0] signal_const_288;
    wire signal_eq_28;
    wire [4:0] signal_const_289;
    wire signal_eq_29;
    wire [4:0] signal_const_290;
    wire signal_eq_30;
    wire [4:0] signal_const_291;
    wire signal_eq_31;
    wire [4:0] signal_const_292;
    wire signal_eq_32;
    wire [4:0] signal_const_293;
    wire signal_eq_33;
    wire [4:0] signal_const_294;
    wire signal_eq_34;
    wire [4:0] signal_const_295;
    wire signal_eq_35;
    wire [15:0] signal_mux_230;
    wire [15:0] signal_mux_231;
    wire [3:0] signal_select_33;
    wire signal_lt_4;
    wire [9:0] signal_select_34;
    wire signal_eq_36;
    wire signal_not_35;
    wire signal_select_35;
    wire signal_or_22;
    wire [3:0] signal_select_36;
    wire signal_eq_37;
    wire [3:0] signal_select_37;
    wire signal_eq_38;
    wire signal_not_36;
    wire signal_select_38;
    wire signal_mux_232;
    wire [3:0] signal_select_39;
    wire signal_eq_39;
    wire signal_select_40;
    wire signal_not_37;
    wire signal_and_34;
    wire signal_select_41;
    wire signal_mux_233;
    wire [1:0] signal_const_303;
    wire [1:0] signal_select_42;
    wire signal_lt_5;
    wire signal_and_35;
    wire [4:0] signal_select_43;
    wire signal_eq_40;
    wire [4:0] signal_select_44;
    wire signal_eq_41;
    wire signal_not_38;
    wire signal_select_45;
    wire signal_mux_234;
    wire [4:0] signal_select_46;
    wire signal_eq_42;
    wire signal_select_47;
    wire signal_not_39;
    wire signal_and_36;
    wire signal_select_48;
    wire signal_mux_235;
    wire [9:0] signal_select_49;
    wire signal_eq_43;
    wire signal_not_40;
    wire signal_select_50;
    wire signal_or_23;
    wire [2:0] signal_select_51;
    wire signal_lt_6;
    wire [3:0] signal_select_52;
    wire signal_eq_44;
    wire signal_not_41;
    wire [2:0] signal_select_53;
    wire signal_lt_7;
    wire [2:0] signal_select_54;
    wire signal_lt_8;
    reg signal_mux_236;
    wire [5:0] signal_const_312;
    wire [5:0] signal_select_55;
    wire signal_eq_45;
    wire signal_select_56;
    wire signal_not_42;
    wire signal_or_24;
    wire [9:0] signal_select_57;
    wire signal_eq_46;
    wire signal_select_58;
    wire signal_not_43;
    wire signal_or_25;
    wire [3:0] signal_select_59;
    wire signal_eq_47;
    wire signal_select_60;
    wire signal_not_44;
    wire signal_or_26;
    wire [4:0] signal_select_61;
    wire signal_eq_48;
    wire signal_select_62;
    wire signal_not_45;
    wire signal_or_27;
    wire [9:0] signal_select_63;
    wire signal_eq_49;
    wire signal_select_64;
    wire signal_not_46;
    wire signal_or_28;
    wire [6:0] signal_const_317;
    wire [6:0] signal_select_65;
    wire signal_eq_50;
    wire signal_select_66;
    wire signal_not_47;
    wire signal_or_29;
    wire [3:0] signal_select_67;
    wire signal_eq_51;
    wire signal_select_68;
    wire signal_not_48;
    wire signal_or_30;
    wire [6:0] signal_select_69;
    wire signal_eq_52;
    wire signal_select_70;
    wire signal_not_49;
    wire signal_or_31;
    reg signal_mux_237;
    wire [10:0] signal_const_320;
    wire [10:0] signal_const_322;
    wire [10:0] signal_const_324;
    wire [10:0] signal_const_326;
    wire [10:0] signal_const_334;
    wire [10:0] signal_const_335;
    wire [10:0] signal_const_340;
    wire [10:0] signal_const_343;
    wire [10:0] signal_const_345;
    reg [10:0] signal_mux_238;
    wire [10:0] signal_select_71;
    wire [10:0] signal_and_37;
    wire signal_eq_53;
    reg signal_mux_239;
    wire signal_and_38;
    wire signal_and_39;
    wire signal_and_40;
    wire signal_and_41;
    wire signal_and_42;
    wire [6:0] signal_select_72;
    wire signal_select_73;
    wire [1:0] signal_cat_20;
    wire [3:0] signal_cat_21;
    wire [7:0] signal_cat_22;
    wire [9:0] signal_cat_23;
    wire [16:0] signal_cat_24;
    wire [16:0] signal_add_9;
    wire [16:0] signal_add_10;
    wire signal_select_74;
    wire [4:0] signal_const_353;
    wire signal_eq_54;
    wire signal_and_43;
    wire [16:0] signal_mux_240;
    wire [10:0] signal_select_75;
    wire signal_select_76;
    wire [1:0] signal_cat_25;
    wire [3:0] signal_cat_26;
    wire [5:0] signal_cat_27;
    wire [16:0] signal_cat_28;
    wire [16:0] signal_add_11;
    wire [16:0] signal_add_12;
    wire [7:0] signal_select_77;
    wire signal_select_78;
    wire [1:0] signal_cat_29;
    wire [3:0] signal_cat_30;
    wire [7:0] signal_cat_31;
    wire [8:0] signal_cat_32;
    wire [16:0] signal_cat_33;
    wire [16:0] signal_add_13;
    wire [16:0] signal_add_14;
    wire signal_not_50;
    wire signal_select_79;
    wire signal_mux_241;
    wire signal_mux_242;
    wire signal_mux_243;
    wire signal_mux_244;
    wire signal_wire_38;
    reg execution$reg_negative;
    wire signal_not_51;
    wire signal_lt_9;
    wire signal_select_80;
    reg signal_mux_245;
    wire signal_lt_10;
    wire signal_select_81;
    reg signal_mux_246;
    wire signal_lt_11;
    wire signal_lt_12;
    wire signal_select_82;
    wire signal_select_83;
    wire signal_select_84;
    wire signal_select_85;
    wire signal_select_86;
    wire signal_select_87;
    wire signal_select_88;
    wire signal_select_89;
    wire signal_select_90;
    wire signal_select_91;
    wire signal_select_92;
    wire signal_select_93;
    wire signal_select_94;
    wire signal_select_95;
    wire signal_select_96;
    reg signal_mux_247;
    wire signal_select_97;
    wire signal_select_98;
    wire signal_select_99;
    wire signal_select_100;
    wire signal_select_101;
    wire signal_select_102;
    wire signal_select_103;
    wire signal_select_104;
    wire signal_select_105;
    wire signal_select_106;
    wire signal_select_107;
    wire signal_select_108;
    wire signal_select_109;
    wire signal_select_110;
    wire signal_select_111;
    reg signal_mux_248;
    wire signal_mux_249;
    wire signal_eq_55;
    wire signal_mux_250;
    wire signal_eq_56;
    wire signal_mux_251;
    wire signal_eq_57;
    wire signal_mux_252;
    wire signal_eq_58;
    wire signal_mux_253;
    wire signal_mux_254;
    wire signal_mux_255;
    wire signal_mux_256;
    wire signal_mux_257;
    wire signal_wire_39;
    reg execution$reg_carry;
    wire signal_not_52;
    wire [2:0] signal_select_112;
    reg [15:0] signal_mux_258;
    wire [2:0] signal_select_113;
    reg [15:0] signal_mux_259;
    wire [15:0] signal_sub;
    wire [2:0] signal_select_114;
    reg [15:0] signal_mux_260;
    wire [15:0] signal_sub_1;
    wire signal_eq_59;
    wire [15:0] signal_mux_261;
    wire signal_eq_60;
    wire [15:0] signal_mux_262;
    wire signal_eq_61;
    wire [15:0] signal_mux_263;
    wire signal_eq_62;
    wire [15:0] signal_mux_264;
    wire signal_eq_63;
    wire signal_mux_265;
    wire signal_eq_64;
    wire signal_eq_65;
    wire signal_eq_66;
    wire signal_eq_67;
    wire signal_eq_68;
    wire signal_or_32;
    wire signal_or_33;
    wire signal_or_34;
    wire signal_or_35;
    wire signal_and_44;
    wire signal_mux_266;
    wire signal_mux_267;
    wire signal_mux_268;
    wire signal_wire_40;
    reg execution$reg_zero;
    wire [2:0] signal_select_115;
    reg signal_mux_269;
    wire [16:0] signal_mux_270;
    wire [7:0] signal_select_116;
    wire signal_select_117;
    wire [1:0] signal_cat_34;
    wire [3:0] signal_cat_35;
    wire [7:0] signal_cat_36;
    wire [8:0] signal_cat_37;
    wire [16:0] signal_cat_38;
    wire [16:0] signal_add_15;
    wire [16:0] signal_add_16;
    wire signal_eq_69;
    wire signal_not_53;
    wire [16:0] signal_mux_271;
    wire [7:0] signal_select_118;
    wire signal_select_119;
    wire [1:0] signal_cat_39;
    wire [3:0] signal_cat_40;
    wire [7:0] signal_cat_41;
    wire [8:0] signal_cat_42;
    wire [16:0] signal_cat_43;
    wire [16:0] signal_add_17;
    wire [16:0] signal_add_18;
    wire [15:0] signal_wire_41;
    wire [2:0] signal_select_120;
    reg [15:0] signal_mux_272;
    wire [15:0] signal_xor;
    wire [15:0] signal_or_36;
    wire [15:0] signal_and_45;
    wire [15:0] signal_sub_2;
    wire [2:0] signal_select_121;
    reg [15:0] signal_mux_273;
    wire [16:0] signal_cat_44;
    reg [15:0] signal_mux_274;
    wire [16:0] signal_cat_45;
    wire [16:0] signal_add_19;
    wire [15:0] signal_select_122;
    wire [2:0] signal_select_123;
    reg [15:0] signal_mux_275;
    wire [15:0] signal_xor_1;
    wire [15:0] signal_or_37;
    wire [15:0] signal_and_46;
    wire [15:0] signal_sub_3;
    wire [15:0] signal_mux_276;
    wire signal_not_54;
    wire signal_and_47;
    wire signal_and_48;
    wire signal_and_49;
    wire [15:0] signal_mux_277;
    wire [15:0] signal_mux_278;
    wire [15:0] signal_mux_279;
    wire [15:0] signal_wire_42;
    reg [15:0] execution$reg_extension_word;
    wire signal_eq_70;
    wire [15:0] signal_mux_280;
    wire [5:0] signal_select_124;
    wire [15:0] signal_cat_46;
    wire [9:0] signal_select_125;
    wire [15:0] signal_cat_47;
    wire [3:0] signal_select_126;
    wire [11:0] signal_const_393;
    wire [15:0] signal_cat_48;
    wire [4:0] signal_select_127;
    wire [15:0] signal_cat_49;
    wire [9:0] signal_select_128;
    wire [15:0] signal_cat_50;
    wire [6:0] signal_select_129;
    wire [8:0] signal_const_407;
    wire [15:0] signal_cat_51;
    wire [3:0] signal_select_130;
    wire [15:0] signal_cat_52;
    wire [6:0] signal_select_131;
    wire [15:0] signal_cat_53;
    reg [15:0] signal_mux_281;
    wire [15:0] signal_mux_282;
    wire [16:0] signal_cat_54;
    reg [15:0] signal_mux_283;
    wire [16:0] signal_cat_55;
    wire [16:0] signal_add_20;
    wire [15:0] signal_select_132;
    wire [2:0] signal_select_133;
    reg [15:0] signal_mux_284;
    wire [7:0] signal_select_134;
    wire [15:0] signal_cat_56;
    wire [11:0] signal_select_135;
    wire [15:0] signal_cat_57;
    wire [13:0] signal_select_136;
    wire [1:0] signal_const_416;
    wire [15:0] signal_cat_58;
    wire [14:0] signal_select_137;
    wire [15:0] signal_cat_59;
    wire signal_select_138;
    wire [15:0] signal_mux_285;
    wire signal_select_139;
    wire [15:0] signal_mux_286;
    wire signal_select_140;
    wire [15:0] signal_mux_287;
    wire signal_select_141;
    wire [15:0] signal_mux_288;
    wire [7:0] signal_select_142;
    wire [15:0] signal_cat_60;
    wire [11:0] signal_select_143;
    wire [15:0] signal_cat_61;
    wire [13:0] signal_select_144;
    wire [15:0] signal_cat_62;
    wire [14:0] signal_select_145;
    wire [15:0] signal_cat_63;
    reg [15:0] signal_mux_289;
    wire signal_select_146;
    wire [15:0] signal_mux_290;
    wire signal_select_147;
    wire [15:0] signal_mux_291;
    wire signal_select_148;
    wire [15:0] signal_mux_292;
    wire [3:0] signal_select_149;
    wire signal_select_150;
    wire [15:0] signal_mux_293;
    wire signal_select_151;
    wire [15:0] signal_mux_294;
    wire [15:0] signal_const_422;
    wire [2:0] signal_const_423;
    wire signal_eq_71;
    wire [15:0] signal_mux_295;
    wire [15:0] signal_mux_296;
    wire [15:0] signal_mux_297;
    wire [15:0] signal_mux_298;
    wire [15:0] signal_mux_299;
    wire [15:0] signal_wire_43;
    reg [15:0] execution$reg_r7;
    wire signal_eq_72;
    wire [15:0] signal_mux_300;
    wire [15:0] signal_mux_301;
    wire [15:0] signal_mux_302;
    wire [15:0] signal_mux_303;
    wire [15:0] signal_mux_304;
    wire [15:0] signal_wire_44;
    reg [15:0] execution$reg_r6;
    wire signal_eq_73;
    wire [15:0] signal_mux_305;
    wire [15:0] signal_mux_306;
    wire [15:0] signal_mux_307;
    wire [15:0] signal_mux_308;
    wire [15:0] signal_mux_309;
    wire [15:0] signal_wire_45;
    reg [15:0] execution$reg_r5;
    wire signal_eq_74;
    wire [15:0] signal_mux_310;
    wire [15:0] signal_mux_311;
    wire [15:0] signal_mux_312;
    wire [15:0] signal_mux_313;
    wire [15:0] signal_mux_314;
    wire [15:0] signal_wire_46;
    reg [15:0] execution$reg_r4;
    wire signal_eq_75;
    wire [15:0] signal_mux_315;
    wire [15:0] signal_mux_316;
    wire [15:0] signal_mux_317;
    wire [15:0] signal_mux_318;
    wire [15:0] signal_mux_319;
    wire [15:0] signal_wire_47;
    reg [15:0] execution$reg_r3;
    wire signal_eq_76;
    wire [15:0] signal_mux_320;
    wire [15:0] signal_mux_321;
    wire [15:0] signal_mux_322;
    wire [15:0] signal_mux_323;
    wire [15:0] signal_mux_324;
    wire [15:0] signal_wire_48;
    reg [15:0] execution$reg_r2;
    wire signal_eq_77;
    wire [15:0] signal_mux_325;
    wire [15:0] signal_mux_326;
    wire [15:0] signal_mux_327;
    wire [15:0] signal_mux_328;
    wire [15:0] signal_mux_329;
    wire [15:0] signal_wire_49;
    reg [15:0] execution$reg_r1;
    reg [15:0] signal_mux_330;
    wire [15:0] signal_sub_4;
    wire [16:0] signal_add_21;
    wire [15:0] signal_select_152;
    wire signal_eq_78;
    wire [15:0] signal_mux_331;
    wire signal_eq_79;
    wire [15:0] signal_mux_332;
    wire signal_eq_80;
    wire [15:0] signal_mux_333;
    wire signal_eq_81;
    wire [15:0] signal_mux_334;
    wire signal_eq_82;
    wire [15:0] signal_mux_335;
    wire signal_eq_83;
    wire [15:0] signal_mux_336;
    wire [15:0] signal_mux_337;
    wire [2:0] signal_select_153;
    wire [2:0] signal_select_154;
    wire [2:0] signal_select_155;
    wire [4:0] signal_const_445;
    wire signal_eq_84;
    wire [2:0] signal_mux_338;
    wire [4:0] signal_const_446;
    wire signal_eq_85;
    wire [2:0] signal_mux_339;
    wire [2:0] signal_select_156;
    wire [2:0] signal_select_157;
    wire [2:0] signal_select_158;
    wire [2:0] signal_select_159;
    wire [2:0] signal_select_160;
    wire [2:0] signal_select_161;
    wire [2:0] signal_select_162;
    wire signal_eq_86;
    wire [2:0] signal_mux_340;
    wire signal_eq_87;
    wire [2:0] signal_mux_341;
    wire signal_eq_88;
    wire [2:0] signal_mux_342;
    wire signal_eq_89;
    wire [2:0] signal_mux_343;
    wire signal_eq_90;
    wire [2:0] signal_mux_344;
    wire signal_eq_91;
    wire [2:0] signal_mux_345;
    wire [2:0] signal_mux_346;
    wire signal_eq_92;
    wire [15:0] signal_mux_347;
    wire [15:0] signal_mux_348;
    wire [4:0] signal_const_454;
    wire signal_eq_93;
    wire signal_eq_94;
    wire signal_eq_95;
    wire signal_or_38;
    wire signal_or_39;
    wire signal_and_50;
    wire signal_eq_96;
    wire signal_eq_97;
    wire signal_eq_98;
    wire signal_eq_99;
    wire signal_eq_100;
    wire signal_eq_101;
    wire signal_eq_102;
    wire signal_or_40;
    wire signal_or_41;
    wire signal_or_42;
    wire signal_or_43;
    wire signal_or_44;
    wire signal_or_45;
    wire signal_and_51;
    wire signal_or_46;
    wire [15:0] signal_mux_349;
    wire [15:0] signal_mux_350;
    wire [15:0] signal_mux_351;
    wire [15:0] signal_wire_50;
    reg [15:0] execution$reg_r0;
    wire [2:0] signal_select_163;
    reg [15:0] signal_mux_352;
    wire [16:0] signal_cat_64;
    wire [16:0] signal_const_464;
    wire signal_select_164;
    wire signal_select_165;
    wire signal_select_166;
    wire signal_select_167;
    wire signal_select_168;
    wire vdd;
    wire signal_select_169;
    wire signal_select_170;
    wire signal_select_171;
    wire gnd;
    reg signal_mux_353;
    wire [16:0] signal_mux_354;
    wire [16:0] signal_add_22;
    wire signal_eq_103;
    wire [16:0] signal_mux_355;
    wire signal_eq_104;
    wire [16:0] signal_mux_356;
    wire signal_eq_105;
    wire [16:0] signal_mux_357;
    wire signal_eq_106;
    wire [16:0] signal_mux_358;
    wire signal_eq_107;
    wire [16:0] signal_mux_359;
    wire signal_not_55;
    wire signal_mux_360;
    wire signal_not_56;
    wire signal_not_57;
    wire [8:0] signal_const_477;
    wire [8:0] signal_add_23;
    wire [8:0] signal_mux_361;
    wire [8:0] signal_mux_362;
    wire signal_not_58;
    wire signal_not_59;
    wire signal_not_60;
    wire signal_mux_363;
    wire signal_mux_364;
    wire signal_mux_365;
    wire signal_lt_13;
    wire signal_eq_108;
    wire [15:0] signal_wire_51;
    wire [15:0] signal_mux_366;
    wire [15:0] signal_mux_367;
    wire [15:0] signal_wire_52;
    reg [15:0] signal_reg_6;
    wire [15:0] signal_wire_53;
    wire signal_eq_109;
    wire signal_mux_368;
    wire signal_mux_369;
    wire signal_mux_370;
    wire signal_wire_54;
    reg signal_reg_7;
    wire signal_mux_371;
    wire signal_mux_372;
    wire signal_mux_373;
    wire signal_mux_374;
    wire signal_wire_55;
    reg signal_reg_8;
    wire signal_not_61;
    wire signal_eq_110;
    wire signal_and_52;
    wire signal_and_53;
    wire signal_and_54;
    wire signal_and_55;
    wire [8:0] signal_mux_375;
    wire [8:0] signal_wire_56;
    wire signal_lt_14;
    wire signal_or_47;
    wire signal_and_56;
    wire signal_wire_57;
    wire signal_mux_376;
    wire signal_not_62;
    wire signal_and_57;
    wire signal_and_58;
    wire signal_and_59;
    wire signal_and_60;
    wire signal_mux_377;
    wire signal_mux_378;
    wire signal_wire_58;
    reg signal_reg_9;
    wire signal_and_61;
    wire signal_and_62;
    wire signal_and_63;
    wire signal_and_64;
    wire [8:0] signal_mux_379;
    wire [8:0] signal_mux_380;
    wire [8:0] signal_mux_381;
    wire [8:0] signal_wire_59;
    reg [8:0] signal_reg_10;
    wire signal_eq_111;
    wire [8:0] signal_mux_382;
    wire [8:0] signal_mux_383;
    wire [8:0] signal_wire_60;
    reg [8:0] signal_reg_11;
    wire [8:0] signal_add_24;
    wire [8:0] signal_mux_384;
    wire [8:0] signal_mux_385;
    wire [8:0] signal_mux_386;
    wire [8:0] signal_wire_61;
    reg [8:0] signal_reg_12;
    wire signal_eq_112;
    wire signal_wire_62;
    wire signal_lt_15;
    wire signal_not_63;
    wire [8:0] signal_wire_63;
    wire signal_lt_16;
    wire signal_and_65;
    wire signal_and_66;
    wire signal_and_67;
    wire signal_mux_387;
    wire signal_mux_388;
    wire signal_mux_389;
    wire signal_wire_64;
    reg signal_reg_13;
    wire signal_and_68;
    wire signal_and_69;
    wire signal_and_70;
    wire signal_and_71;
    wire signal_and_72;
    wire signal_and_73;
    wire signal_and_74;
    wire signal_mux_390;
    wire signal_mux_391;
    wire signal_wire_65;
    reg signal_reg_14;
    wire signal_wire_66;
    wire signal_not_64;
    wire signal_wire_67;
    wire signal_not_65;
    wire signal_wire_68;
    wire signal_not_66;
    wire signal_wire_69;
    wire signal_not_67;
    wire signal_wire_70;
    wire signal_not_68;
    wire signal_and_75;
    wire signal_and_76;
    wire signal_and_77;
    wire signal_and_78;
    wire signal_and_79;
    wire signal_and_80;
    wire signal_and_81;
    wire signal_and_82;
    wire [16:0] signal_mux_392;
    wire signal_eq_113;
    wire signal_not_69;
    wire signal_and_83;
    wire [16:0] signal_mux_393;
    wire signal_wire_71;
    wire signal_not_70;
    wire signal_eq_114;
    wire signal_not_71;
    wire signal_and_84;
    wire signal_and_85;
    wire signal_and_86;
    wire signal_wire_72;
    wire signal_wire_73;
    wire signal_not_72;
    wire signal_wire_74;
    wire signal_and_87;
    wire signal_and_88;
    wire signal_and_89;
    wire signal_or_48;
    wire signal_and_90;
    wire [16:0] signal_mux_394;
    wire [16:0] signal_mux_395;
    wire [16:0] signal_mux_396;
    wire [16:0] signal_wire_75;
    reg [16:0] execution$reg_pc;
    wire [7:0] signal_select_172;
    wire signal_eq_115;
    wire signal_eq_116;
    wire signal_and_91;
    wire signal_or_49;
    wire signal_and_92;
    wire [15:0] signal_mux_397;
    wire [15:0] signal_mux_398;
    wire [15:0] signal_mux_399;
    wire [15:0] signal_mux_400;
    wire [15:0] signal_wire_76;
    reg [15:0] execution$reg_base_word;
    wire [15:0] signal_mux_401;
    wire [4:0] signal_select_173;
    wire signal_eq_117;
    wire signal_or_50;
    wire signal_or_51;
    wire signal_or_52;
    wire signal_or_53;
    wire signal_or_54;
    wire signal_or_55;
    wire signal_or_56;
    wire signal_or_57;
    wire signal_or_58;
    wire signal_or_59;
    wire signal_or_60;
    wire signal_or_61;
    wire signal_or_62;
    wire signal_not_73;
    wire signal_and_93;
    wire signal_or_63;
    wire signal_and_94;
    wire signal_and_95;
    wire signal_and_96;
    wire [2:0] signal_mux_402;
    wire signal_not_74;
    wire [2:0] signal_mux_403;
    wire [2:0] signal_mux_404;
    wire [2:0] signal_wire_77;
    reg [2:0] execution$reg_phase;
    wire signal_eq_118;
    wire signal_and_97;
    wire signal_and_98;
    wire signal_and_99;
    wire signal_or_64;
    wire signal_and_100;
    wire signal_and_101;
    wire signal_and_102;
    wire signal_or_65;
    wire signal_wire_78;
    wire signal_not_75;
    wire signal_and_103;
    wire signal_and_104;
    wire signal_and_105;
    wire signal_mux_405;
    wire signal_mux_406;
    wire signal_wire_79;
    reg signal_reg_15;
    wire signal_not_76;
    wire signal_or_66;
    wire signal_wire_80;
    wire signal_not_77;
    wire signal_and_106;
    wire signal_and_107;
    wire signal_and_108;
    wire signal_and_109;
    wire signal_and_110;
    wire signal_mux_407;
    wire signal_not_78;
    wire signal_mux_408;
    wire signal_wire_81;
    reg signal_reg_16;
    wire signal_not_79;
    wire signal_wire_82;
    wire signal_and_111;
    wire signal_and_112;
    wire signal_and_113;
    wire signal_and_114;
    wire signal_and_115;
    wire signal_and_116;
    wire signal_and_117;
    wire signal_and_118;
    wire signal_and_119;
    wire signal_or_67;
    wire signal_and_120;
    assign signal_const = 32'b00000000000000000000000000000001;
    assign signal_add = execution$reg_total_cycles + signal_const;
    assign signal_add_1 = execution$reg_total_cycles + signal_const;
    assign signal_add_2 = execution$reg_total_cycles + signal_const;
    assign signal_const_3 = 32'b00000000000000000000000000000000;
    assign signal_mux = signal_and_82 ? signal_const_3 : execution$reg_total_cycles;
    assign signal_mux_1 = signal_and_92 ? signal_add_2 : signal_mux;
    assign signal_mux_2 = signal_or_3 ? signal_add_1 : signal_mux_1;
    assign signal_mux_3 = signal_or ? signal_add : signal_mux_2;
    assign signal_mux_4 = signal_not_74 ? execution$reg_total_cycles : signal_mux_3;
    assign signal_mux_5 = signal_wire_80 ? signal_const_3 : signal_mux_4;
    assign signal_wire = signal_mux_5;
    always @(posedge signal_wire_62) begin
        execution$reg_total_cycles <= signal_wire;
    end
    assign signal_add_3 = execution$reg_extension_fetches + signal_const;
    assign signal_mux_6 = signal_and_42 ? signal_add_3 : signal_mux_7;
    assign signal_mux_7 = signal_and_82 ? signal_const_3 : execution$reg_extension_fetches;
    assign signal_mux_8 = signal_and_92 ? signal_mux_6 : signal_mux_7;
    assign signal_mux_9 = signal_not_74 ? execution$reg_extension_fetches : signal_mux_8;
    assign signal_mux_10 = signal_wire_80 ? signal_const_3 : signal_mux_9;
    assign signal_wire_1 = signal_mux_10;
    always @(posedge signal_wire_62) begin
        execution$reg_extension_fetches <= signal_wire_1;
    end
    assign signal_add_4 = execution$reg_instruction_count + signal_const;
    assign signal_mux_11 = signal_and_82 ? signal_const_3 : execution$reg_instruction_count;
    assign signal_mux_12 = signal_or_5 ? signal_add_4 : signal_mux_11;
    assign signal_mux_13 = signal_not_74 ? execution$reg_instruction_count : signal_mux_12;
    assign signal_mux_14 = signal_wire_80 ? signal_const_3 : signal_mux_13;
    assign signal_wire_2 = signal_mux_14;
    always @(posedge signal_wire_62) begin
        execution$reg_instruction_count <= signal_wire_2;
    end
    assign signal_add_5 = execution$reg_stall_cycles + signal_const;
    assign signal_mux_15 = signal_and_82 ? signal_const_3 : execution$reg_stall_cycles;
    assign signal_not = ~ signal_wire_73;
    assign signal_not_1 = ~ signal_wire_74;
    assign signal_and = signal_and_94 & signal_not_1;
    assign signal_and_1 = signal_and & signal_not;
    assign signal_or = signal_and_1 | signal_eq_114;
    assign signal_mux_16 = signal_or ? signal_add_5 : signal_mux_15;
    assign signal_mux_17 = signal_not_74 ? execution$reg_stall_cycles : signal_mux_16;
    assign signal_mux_18 = signal_wire_80 ? signal_const_3 : signal_mux_17;
    assign signal_wire_3 = signal_mux_18;
    always @(posedge signal_wire_62) begin
        execution$reg_stall_cycles <= signal_wire_3;
    end
    assign signal_add_6 = execution$reg_execute_cycles + signal_const;
    assign signal_mux_19 = signal_and_82 ? signal_const_3 : execution$reg_execute_cycles;
    assign signal_or_1 = signal_and_96 | signal_and_88;
    assign signal_or_2 = signal_or_1 | signal_and_29;
    assign signal_or_3 = signal_and_101 | signal_or_2;
    assign signal_mux_20 = signal_or_3 ? signal_add_6 : signal_mux_19;
    assign signal_mux_21 = signal_not_74 ? execution$reg_execute_cycles : signal_mux_20;
    assign signal_mux_22 = signal_wire_80 ? signal_const_3 : signal_mux_21;
    assign signal_wire_4 = signal_mux_22;
    always @(posedge signal_wire_62) begin
        execution$reg_execute_cycles <= signal_wire_4;
    end
    assign signal_add_7 = execution$reg_fetch_cycles + signal_const;
    assign signal_mux_23 = signal_and_82 ? signal_const_3 : execution$reg_fetch_cycles;
    assign signal_mux_24 = signal_and_92 ? signal_add_7 : signal_mux_23;
    assign signal_mux_25 = signal_not_74 ? execution$reg_fetch_cycles : signal_mux_24;
    assign signal_mux_26 = signal_wire_80 ? signal_const_3 : signal_mux_25;
    assign signal_wire_5 = signal_mux_26;
    always @(posedge signal_wire_62) begin
        execution$reg_fetch_cycles <= signal_wire_5;
    end
    assign signal_cat = { execution$reg_r7,
                          execution$reg_r6,
                          execution$reg_r5,
                          execution$reg_r4,
                          execution$reg_r3,
                          execution$reg_r2,
                          execution$reg_r1,
                          execution$reg_r0 };
    assign signal_const_14 = 1'b1;
    assign signal_const_15 = 1'b0;
    assign signal_mux_27 = signal_and_82 ? signal_const_15 : signal_const_15;
    assign signal_mux_28 = signal_or_5 ? signal_const_14 : signal_mux_27;
    assign signal_mux_29 = signal_not_74 ? signal_const_15 : signal_mux_28;
    assign signal_mux_30 = signal_wire_80 ? signal_const_15 : signal_mux_29;
    assign signal_wire_6 = signal_mux_30;
    always @(posedge signal_wire_62) begin
        execution$reg_retired <= signal_wire_6;
    end
    assign signal_mux_31 = signal_and_82 ? signal_const_15 : signal_const_15;
    assign signal_mux_32 = signal_or_5 ? signal_const_14 : signal_mux_31;
    assign signal_mux_33 = signal_and_19 ? signal_const_14 : signal_mux_32;
    assign signal_mux_34 = signal_and_20 ? signal_const_14 : signal_mux_33;
    assign signal_mux_35 = signal_and_21 ? signal_const_14 : signal_mux_34;
    assign signal_mux_36 = signal_and_22 ? signal_const_14 : signal_mux_35;
    assign signal_mux_37 = signal_and_27 ? signal_const_14 : signal_mux_36;
    assign signal_mux_38 = signal_and_29 ? signal_const_14 : signal_mux_37;
    assign signal_mux_39 = signal_and_30 ? signal_const_14 : signal_mux_38;
    assign signal_mux_40 = signal_and_33 ? signal_const_14 : signal_mux_39;
    assign signal_mux_41 = signal_and_96 ? signal_const_14 : signal_mux_40;
    assign signal_mux_42 = signal_not_74 ? signal_const_15 : signal_mux_41;
    assign signal_mux_43 = signal_wire_80 ? signal_const_15 : signal_mux_42;
    assign signal_wire_7 = signal_mux_43;
    always @(posedge signal_wire_62) begin
        execution$reg_boundary <= signal_wire_7;
    end
    assign signal_wire_8 = mechanism_completion_reason_i;
    assign signal_wire_9 = mechanism_refusal_reason_i;
    assign signal_const_29 = 5'b00000;
    assign signal_cat_1 = { signal_const_29,
                            signal_mux_48 };
    assign signal_const_30 = 3'b001;
    assign signal_const_31 = 3'b010;
    assign signal_const_32 = 3'b011;
    assign signal_const_33 = 3'b100;
    assign signal_const_34 = 3'b101;
    assign signal_const_35 = 3'b000;
    assign signal_not_2 = ~ signal_mux_220;
    assign signal_and_2 = signal_mux_353 & signal_not_2;
    assign signal_mux_44 = signal_and_2 ? signal_const_34 : signal_const_35;
    assign signal_not_3 = ~ signal_or_19;
    assign signal_and_3 = signal_mux_353 & signal_not_3;
    assign signal_mux_45 = signal_and_3 ? signal_const_33 : signal_mux_44;
    assign signal_not_4 = ~ signal_mux_236;
    assign signal_mux_46 = signal_not_4 ? signal_const_32 : signal_mux_45;
    assign signal_not_5 = ~ signal_mux_237;
    assign signal_not_6 = ~ signal_eq_53;
    assign signal_or_4 = signal_not_6 | signal_not_5;
    assign signal_mux_47 = signal_or_4 ? signal_const_31 : signal_mux_46;
    assign signal_not_7 = ~ signal_mux_239;
    assign signal_mux_48 = signal_not_7 ? signal_const_30 : signal_mux_47;
    assign signal_cat_2 = { signal_const_29,
                            signal_mux_48 };
    assign signal_const_37 = 8'b00000000;
    assign signal_mux_49 = signal_and_82 ? signal_const_37 : execution$reg_fault_reason;
    assign signal_mux_50 = signal_and_19 ? signal_const_37 : signal_mux_49;
    assign signal_mux_51 = signal_and_20 ? signal_const_37 : signal_mux_50;
    assign signal_mux_52 = signal_and_21 ? signal_const_37 : signal_mux_51;
    assign signal_mux_53 = signal_and_22 ? signal_cat_2 : signal_mux_52;
    assign signal_mux_54 = signal_and_27 ? signal_cat_1 : signal_mux_53;
    assign signal_mux_55 = signal_and_29 ? signal_wire_9 : signal_mux_54;
    assign signal_mux_56 = signal_and_30 ? signal_wire_8 : signal_mux_55;
    assign signal_mux_57 = signal_and_33 ? signal_wire_8 : signal_mux_56;
    assign signal_mux_58 = signal_and_96 ? signal_wire_9 : signal_mux_57;
    assign signal_mux_59 = signal_not_74 ? execution$reg_fault_reason : signal_mux_58;
    assign signal_mux_60 = signal_wire_80 ? signal_const_37 : signal_mux_59;
    assign signal_wire_10 = signal_mux_60;
    always @(posedge signal_wire_62) begin
        execution$reg_fault_reason <= signal_wire_10;
    end
    assign signal_const_41 = 17'b00000000000000000;
    assign signal_mux_61 = signal_and_82 ? signal_const_41 : execution$reg_fault_address;
    assign signal_mux_62 = signal_and_19 ? execution$reg_pc : signal_mux_61;
    assign signal_mux_63 = signal_and_20 ? execution$reg_pc : signal_mux_62;
    assign signal_mux_64 = signal_and_21 ? signal_add_8 : signal_mux_63;
    assign signal_mux_65 = signal_and_22 ? execution$reg_pc : signal_mux_64;
    assign signal_mux_66 = signal_and_27 ? signal_add_8 : signal_mux_65;
    assign signal_mux_67 = signal_and_29 ? execution$reg_pc : signal_mux_66;
    assign signal_mux_68 = signal_and_30 ? execution$reg_pc : signal_mux_67;
    assign signal_mux_69 = signal_and_33 ? execution$reg_pc : signal_mux_68;
    assign signal_mux_70 = signal_and_96 ? execution$reg_pc : signal_mux_69;
    assign signal_mux_71 = signal_not_74 ? execution$reg_fault_address : signal_mux_70;
    assign signal_mux_72 = signal_wire_80 ? signal_const_41 : signal_mux_71;
    assign signal_wire_11 = signal_mux_72;
    always @(posedge signal_wire_62) begin
        execution$reg_fault_address <= signal_wire_11;
    end
    assign signal_mux_73 = signal_and_82 ? signal_const_41 : execution$reg_last_instruction_slot;
    assign signal_or_5 = signal_and_101 | signal_and_90;
    assign signal_mux_74 = signal_or_5 ? execution$reg_pc : signal_mux_73;
    assign signal_mux_75 = signal_not_74 ? execution$reg_last_instruction_slot : signal_mux_74;
    assign signal_mux_76 = signal_wire_80 ? signal_const_41 : signal_mux_75;
    assign signal_wire_12 = signal_mux_76;
    always @(posedge signal_wire_62) begin
        execution$reg_last_instruction_slot <= signal_wire_12;
    end
    assign signal_mux_77 = signal_and_82 ? signal_const_41 : execution$reg_fault_instruction_slot;
    assign signal_mux_78 = signal_and_19 ? execution$reg_last_instruction_slot : signal_mux_77;
    assign signal_mux_79 = signal_and_20 ? execution$reg_last_instruction_slot : signal_mux_78;
    assign signal_mux_80 = signal_and_21 ? execution$reg_pc : signal_mux_79;
    assign signal_mux_81 = signal_and_22 ? execution$reg_pc : signal_mux_80;
    assign signal_mux_82 = signal_and_27 ? execution$reg_pc : signal_mux_81;
    assign signal_mux_83 = signal_and_29 ? execution$reg_pc : signal_mux_82;
    assign signal_mux_84 = signal_and_30 ? execution$reg_pc : signal_mux_83;
    assign signal_mux_85 = signal_and_33 ? execution$reg_pc : signal_mux_84;
    assign signal_mux_86 = signal_and_96 ? execution$reg_pc : signal_mux_85;
    assign signal_mux_87 = signal_not_74 ? execution$reg_fault_instruction_slot : signal_mux_86;
    assign signal_mux_88 = signal_wire_80 ? signal_const_41 : signal_mux_87;
    assign signal_wire_13 = signal_mux_88;
    always @(posedge signal_wire_62) begin
        execution$reg_fault_instruction_slot <= signal_wire_13;
    end
    assign signal_const_44 = 4'b1001;
    assign signal_const_45 = 4'b1000;
    assign signal_const_46 = 4'b0111;
    assign signal_const_47 = 4'b0110;
    assign signal_const_48 = 4'b0010;
    assign signal_const_49 = 4'b0001;
    assign signal_const_50 = 4'b0100;
    assign signal_const_51 = 4'b0011;
    assign signal_const_52 = 4'b0101;
    assign signal_const_53 = 4'b0000;
    assign signal_mux_89 = signal_and_82 ? signal_const_53 : execution$reg_fault_kind;
    assign signal_mux_90 = signal_and_19 ? signal_const_52 : signal_mux_89;
    assign signal_mux_91 = signal_and_20 ? signal_const_51 : signal_mux_90;
    assign signal_mux_92 = signal_and_21 ? signal_const_50 : signal_mux_91;
    assign signal_mux_93 = signal_and_22 ? signal_const_49 : signal_mux_92;
    assign signal_mux_94 = signal_and_27 ? signal_const_48 : signal_mux_93;
    assign signal_mux_95 = signal_and_29 ? signal_const_47 : signal_mux_94;
    assign signal_mux_96 = signal_and_30 ? signal_const_46 : signal_mux_95;
    assign signal_mux_97 = signal_and_33 ? signal_const_45 : signal_mux_96;
    assign signal_mux_98 = signal_and_96 ? signal_const_44 : signal_mux_97;
    assign signal_mux_99 = signal_not_74 ? execution$reg_fault_kind : signal_mux_98;
    assign signal_mux_100 = signal_wire_80 ? signal_const_53 : signal_mux_99;
    assign signal_wire_14 = signal_mux_100;
    always @(posedge signal_wire_62) begin
        execution$reg_fault_kind <= signal_wire_14;
    end
    assign signal_mux_101 = signal_and_82 ? signal_const_15 : execution$reg_execution_fault;
    assign signal_mux_102 = signal_and_19 ? signal_const_14 : signal_mux_101;
    assign signal_mux_103 = signal_and_20 ? signal_const_14 : signal_mux_102;
    assign signal_mux_104 = signal_and_21 ? signal_const_14 : signal_mux_103;
    assign signal_mux_105 = signal_and_22 ? signal_const_14 : signal_mux_104;
    assign signal_mux_106 = signal_and_27 ? signal_const_14 : signal_mux_105;
    assign signal_mux_107 = signal_and_29 ? signal_const_14 : signal_mux_106;
    assign signal_mux_108 = signal_and_30 ? signal_const_14 : signal_mux_107;
    assign signal_mux_109 = signal_and_33 ? signal_const_14 : signal_mux_108;
    assign signal_mux_110 = signal_and_96 ? signal_const_14 : signal_mux_109;
    assign signal_mux_111 = signal_not_74 ? execution$reg_execution_fault : signal_mux_110;
    assign signal_mux_112 = signal_wire_80 ? signal_const_15 : signal_mux_111;
    assign signal_wire_15 = signal_mux_112;
    always @(posedge signal_wire_62) begin
        execution$reg_execution_fault <= signal_wire_15;
    end
    assign signal_mux_113 = signal_and_82 ? signal_const_15 : execution$reg_normal_halt;
    assign signal_mux_114 = signal_and_102 ? signal_const_14 : signal_mux_113;
    assign signal_mux_115 = signal_and_19 ? signal_const_15 : signal_mux_114;
    assign signal_mux_116 = signal_and_20 ? signal_const_15 : signal_mux_115;
    assign signal_mux_117 = signal_and_21 ? signal_const_15 : signal_mux_116;
    assign signal_mux_118 = signal_and_22 ? signal_const_15 : signal_mux_117;
    assign signal_mux_119 = signal_and_27 ? signal_const_15 : signal_mux_118;
    assign signal_mux_120 = signal_and_29 ? signal_const_15 : signal_mux_119;
    assign signal_mux_121 = signal_and_30 ? signal_const_15 : signal_mux_120;
    assign signal_mux_122 = signal_and_33 ? signal_const_15 : signal_mux_121;
    assign signal_mux_123 = signal_and_96 ? signal_const_15 : signal_mux_122;
    assign signal_mux_124 = signal_not_74 ? execution$reg_normal_halt : signal_mux_123;
    assign signal_mux_125 = signal_wire_80 ? signal_const_15 : signal_mux_124;
    assign signal_wire_16 = signal_mux_125;
    always @(posedge signal_wire_62) begin
        execution$reg_normal_halt <= signal_wire_16;
    end
    assign signal_const_75 = 3'b110;
    assign signal_eq = execution$reg_phase == signal_const_75;
    assign signal_not_8 = ~ signal_eq;
    assign signal_eq_1 = execution$reg_phase == signal_const_35;
    assign signal_not_9 = ~ signal_eq_1;
    assign signal_and_4 = signal_not_9 & signal_not_8;
    assign signal_select = signal_mux_401[10:7];
    assign signal_eq_2 = signal_select == signal_const_53;
    assign signal_mux_126 = signal_eq_2 ? signal_mux_282 : signal_mux_127;
    assign signal_const_78 = 16'b0000000000000000;
    assign signal_mux_127 = signal_and_82 ? signal_const_78 : execution$reg_desc_control;
    assign signal_mux_128 = signal_and_5 ? signal_mux_126 : signal_mux_127;
    assign signal_mux_129 = signal_not_74 ? execution$reg_desc_control : signal_mux_128;
    assign signal_mux_130 = signal_wire_80 ? signal_const_78 : signal_mux_129;
    assign signal_wire_17 = signal_mux_130;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_control <= signal_wire_17;
    end
    assign signal_select_1 = signal_mux_401[10:7];
    assign signal_eq_3 = signal_select_1 == signal_const_49;
    assign signal_mux_131 = signal_eq_3 ? signal_mux_282 : signal_mux_132;
    assign signal_mux_132 = signal_and_82 ? signal_const_78 : execution$reg_desc_bit_count;
    assign signal_mux_133 = signal_and_5 ? signal_mux_131 : signal_mux_132;
    assign signal_mux_134 = signal_not_74 ? execution$reg_desc_bit_count : signal_mux_133;
    assign signal_mux_135 = signal_wire_80 ? signal_const_78 : signal_mux_134;
    assign signal_wire_18 = signal_mux_135;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_bit_count <= signal_wire_18;
    end
    assign signal_select_2 = signal_mux_401[10:7];
    assign signal_eq_4 = signal_select_2 == signal_const_48;
    assign signal_mux_136 = signal_eq_4 ? signal_mux_282 : signal_mux_137;
    assign signal_mux_137 = signal_and_82 ? signal_const_78 : execution$reg_desc_tx_value;
    assign signal_mux_138 = signal_and_5 ? signal_mux_136 : signal_mux_137;
    assign signal_mux_139 = signal_not_74 ? execution$reg_desc_tx_value : signal_mux_138;
    assign signal_mux_140 = signal_wire_80 ? signal_const_78 : signal_mux_139;
    assign signal_wire_19 = signal_mux_140;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_tx_value <= signal_wire_19;
    end
    assign signal_select_3 = signal_mux_401[10:7];
    assign signal_eq_5 = signal_select_3 == signal_const_51;
    assign signal_mux_141 = signal_eq_5 ? signal_mux_282 : signal_mux_142;
    assign signal_const_84 = 16'b0000000000001001;
    assign signal_mux_142 = signal_and_82 ? signal_const_84 : execution$reg_desc_output_pin;
    assign signal_mux_143 = signal_and_5 ? signal_mux_141 : signal_mux_142;
    assign signal_mux_144 = signal_not_74 ? execution$reg_desc_output_pin : signal_mux_143;
    assign signal_mux_145 = signal_wire_80 ? signal_const_84 : signal_mux_144;
    assign signal_wire_20 = signal_mux_145;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_output_pin <= signal_wire_20;
    end
    assign signal_select_4 = signal_mux_401[10:7];
    assign signal_eq_6 = signal_select_4 == signal_const_50;
    assign signal_mux_146 = signal_eq_6 ? signal_mux_282 : signal_mux_147;
    assign signal_mux_147 = signal_and_82 ? signal_const_84 : execution$reg_desc_input_pin;
    assign signal_mux_148 = signal_and_5 ? signal_mux_146 : signal_mux_147;
    assign signal_mux_149 = signal_not_74 ? execution$reg_desc_input_pin : signal_mux_148;
    assign signal_mux_150 = signal_wire_80 ? signal_const_84 : signal_mux_149;
    assign signal_wire_21 = signal_mux_150;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_input_pin <= signal_wire_21;
    end
    assign signal_select_5 = signal_mux_401[10:7];
    assign signal_eq_7 = signal_select_5 == signal_const_52;
    assign signal_mux_151 = signal_eq_7 ? signal_mux_282 : signal_mux_152;
    assign signal_mux_152 = signal_and_82 ? signal_const_84 : execution$reg_desc_clock_pin;
    assign signal_mux_153 = signal_and_5 ? signal_mux_151 : signal_mux_152;
    assign signal_mux_154 = signal_not_74 ? execution$reg_desc_clock_pin : signal_mux_153;
    assign signal_mux_155 = signal_wire_80 ? signal_const_84 : signal_mux_154;
    assign signal_wire_22 = signal_mux_155;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_clock_pin <= signal_wire_22;
    end
    assign signal_select_6 = signal_mux_401[10:7];
    assign signal_eq_8 = signal_select_6 == signal_const_47;
    assign signal_mux_156 = signal_eq_8 ? signal_mux_282 : signal_mux_157;
    assign signal_mux_157 = signal_and_82 ? signal_const_78 : execution$reg_desc_initial_delay;
    assign signal_mux_158 = signal_and_5 ? signal_mux_156 : signal_mux_157;
    assign signal_mux_159 = signal_not_74 ? execution$reg_desc_initial_delay : signal_mux_158;
    assign signal_mux_160 = signal_wire_80 ? signal_const_78 : signal_mux_159;
    assign signal_wire_23 = signal_mux_160;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_initial_delay <= signal_wire_23;
    end
    assign signal_select_7 = signal_mux_401[10:7];
    assign signal_eq_9 = signal_select_7 == signal_const_46;
    assign signal_mux_161 = signal_eq_9 ? signal_mux_282 : signal_mux_162;
    assign signal_mux_162 = signal_and_82 ? signal_const_78 : execution$reg_desc_half_period;
    assign signal_mux_163 = signal_and_5 ? signal_mux_161 : signal_mux_162;
    assign signal_mux_164 = signal_not_74 ? execution$reg_desc_half_period : signal_mux_163;
    assign signal_mux_165 = signal_wire_80 ? signal_const_78 : signal_mux_164;
    assign signal_wire_24 = signal_mux_165;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_half_period <= signal_wire_24;
    end
    assign signal_select_8 = signal_mux_401[10:7];
    assign signal_eq_10 = signal_select_8 == signal_const_45;
    assign signal_mux_166 = signal_eq_10 ? signal_mux_282 : signal_mux_167;
    assign signal_mux_167 = signal_and_82 ? signal_const_78 : execution$reg_desc_pacing;
    assign signal_const_95 = 5'b10111;
    assign signal_eq_11 = signal_select_173 == signal_const_95;
    assign signal_and_5 = signal_and_101 & signal_eq_11;
    assign signal_mux_168 = signal_and_5 ? signal_mux_166 : signal_mux_167;
    assign signal_mux_169 = signal_not_74 ? execution$reg_desc_pacing : signal_mux_168;
    assign signal_mux_170 = signal_wire_80 ? signal_const_78 : signal_mux_169;
    assign signal_wire_25 = signal_mux_170;
    always @(posedge signal_wire_62) begin
        execution$reg_desc_pacing <= signal_wire_25;
    end
    assign signal_cat_3 = { execution$reg_desc_pacing,
                            execution$reg_desc_half_period,
                            execution$reg_desc_initial_delay,
                            execution$reg_desc_clock_pin,
                            execution$reg_desc_input_pin,
                            execution$reg_desc_output_pin,
                            execution$reg_desc_tx_value,
                            execution$reg_desc_bit_count,
                            execution$reg_desc_control };
    assign signal_select_9 = signal_mux_401[6:6];
    assign signal_select_10 = signal_mux_401[5:5];
    assign signal_const_96 = 5'b10100;
    assign signal_eq_12 = signal_select_173 == signal_const_96;
    assign signal_mux_171 = signal_eq_12 ? signal_select_10 : gnd;
    assign signal_const_97 = 5'b10011;
    assign signal_eq_13 = signal_select_173 == signal_const_97;
    assign signal_mux_172 = signal_eq_13 ? signal_select_9 : signal_mux_171;
    assign signal_select_11 = signal_mux_401[8:6];
    always @* begin
        case (signal_select_11)
        0:
            signal_mux_173 <= execution$reg_r0;
        1:
            signal_mux_173 <= execution$reg_r1;
        2:
            signal_mux_173 <= execution$reg_r2;
        3:
            signal_mux_173 <= execution$reg_r3;
        4:
            signal_mux_173 <= execution$reg_r4;
        5:
            signal_mux_173 <= execution$reg_r5;
        6:
            signal_mux_173 <= execution$reg_r6;
        default:
            signal_mux_173 <= execution$reg_r7;
        endcase
    end
    assign signal_select_12 = signal_mux_401[6:4];
    always @* begin
        case (signal_select_12)
        0:
            signal_mux_174 <= execution$reg_r0;
        1:
            signal_mux_174 <= execution$reg_r1;
        2:
            signal_mux_174 <= execution$reg_r2;
        3:
            signal_mux_174 <= execution$reg_r3;
        4:
            signal_mux_174 <= execution$reg_r4;
        5:
            signal_mux_174 <= execution$reg_r5;
        6:
            signal_mux_174 <= execution$reg_r6;
        default:
            signal_mux_174 <= execution$reg_r7;
        endcase
    end
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_175 <= signal_const_78;
        1:
            signal_mux_175 <= signal_const_78;
        2:
            signal_mux_175 <= signal_const_78;
        3:
            signal_mux_175 <= signal_const_78;
        4:
            signal_mux_175 <= signal_const_78;
        5:
            signal_mux_175 <= signal_const_78;
        6:
            signal_mux_175 <= signal_const_78;
        7:
            signal_mux_175 <= signal_const_78;
        8:
            signal_mux_175 <= signal_const_78;
        9:
            signal_mux_175 <= signal_const_78;
        10:
            signal_mux_175 <= signal_const_78;
        11:
            signal_mux_175 <= signal_const_78;
        12:
            signal_mux_175 <= signal_const_78;
        13:
            signal_mux_175 <= signal_const_78;
        14:
            signal_mux_175 <= signal_const_78;
        15:
            signal_mux_175 <= signal_mux_282;
        16:
            signal_mux_175 <= signal_mux_174;
        17:
            signal_mux_175 <= signal_const_78;
        18:
            signal_mux_175 <= signal_const_78;
        19:
            signal_mux_175 <= signal_mux_282;
        20:
            signal_mux_175 <= signal_mux_282;
        21:
            signal_mux_175 <= signal_const_78;
        22:
            signal_mux_175 <= signal_const_78;
        23:
            signal_mux_175 <= signal_const_78;
        24:
            signal_mux_175 <= signal_const_78;
        25:
            signal_mux_175 <= signal_mux_173;
        26:
            signal_mux_175 <= signal_const_78;
        27:
            signal_mux_175 <= signal_const_78;
        28:
            signal_mux_175 <= signal_const_78;
        29:
            signal_mux_175 <= signal_const_78;
        30:
            signal_mux_175 <= signal_const_78;
        default:
            signal_mux_175 <= signal_const_78;
        endcase
    end
    assign signal_select_13 = signal_mux_401[9:9];
    assign signal_const_130 = 15'b000000000000000;
    assign signal_cat_4 = { signal_const_130,
                            signal_select_13 };
    assign signal_select_14 = signal_mux_401[9:9];
    assign signal_cat_5 = { signal_const_130,
                            signal_select_14 };
    assign signal_select_15 = signal_mux_401[7:6];
    assign signal_const_136 = 14'b00000000000000;
    assign signal_cat_6 = { signal_const_136,
                            signal_select_15 };
    assign signal_select_16 = signal_mux_401[7:7];
    assign signal_cat_7 = { signal_const_130,
                            signal_select_16 };
    assign signal_select_17 = signal_mux_401[9:7];
    always @* begin
        case (signal_select_17)
        0:
            signal_mux_176 <= execution$reg_r0;
        1:
            signal_mux_176 <= execution$reg_r1;
        2:
            signal_mux_176 <= execution$reg_r2;
        3:
            signal_mux_176 <= execution$reg_r3;
        4:
            signal_mux_176 <= execution$reg_r4;
        5:
            signal_mux_176 <= execution$reg_r5;
        6:
            signal_mux_176 <= execution$reg_r6;
        default:
            signal_mux_176 <= execution$reg_r7;
        endcase
    end
    assign signal_select_18 = signal_mux_401[9:2];
    assign signal_cat_8 = { signal_const_37,
                            signal_select_18 };
    assign signal_select_19 = signal_mux_401[7:7];
    assign signal_cat_9 = { signal_const_130,
                            signal_select_19 };
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_177 <= signal_const_78;
        1:
            signal_mux_177 <= signal_const_78;
        2:
            signal_mux_177 <= signal_const_78;
        3:
            signal_mux_177 <= signal_const_78;
        4:
            signal_mux_177 <= signal_const_78;
        5:
            signal_mux_177 <= signal_const_78;
        6:
            signal_mux_177 <= signal_const_78;
        7:
            signal_mux_177 <= signal_const_78;
        8:
            signal_mux_177 <= signal_const_78;
        9:
            signal_mux_177 <= signal_const_78;
        10:
            signal_mux_177 <= signal_const_78;
        11:
            signal_mux_177 <= signal_const_78;
        12:
            signal_mux_177 <= signal_const_78;
        13:
            signal_mux_177 <= signal_cat_9;
        14:
            signal_mux_177 <= signal_const_78;
        15:
            signal_mux_177 <= signal_cat_8;
        16:
            signal_mux_177 <= signal_mux_176;
        17:
            signal_mux_177 <= signal_const_78;
        18:
            signal_mux_177 <= signal_const_78;
        19:
            signal_mux_177 <= signal_cat_7;
        20:
            signal_mux_177 <= signal_cat_6;
        21:
            signal_mux_177 <= signal_const_78;
        22:
            signal_mux_177 <= signal_const_78;
        23:
            signal_mux_177 <= signal_const_78;
        24:
            signal_mux_177 <= signal_const_78;
        25:
            signal_mux_177 <= signal_cat_5;
        26:
            signal_mux_177 <= signal_cat_4;
        27:
            signal_mux_177 <= signal_const_78;
        28:
            signal_mux_177 <= signal_const_78;
        29:
            signal_mux_177 <= signal_const_78;
        30:
            signal_mux_177 <= signal_const_78;
        default:
            signal_mux_177 <= signal_const_78;
        endcase
    end
    assign signal_select_20 = signal_mux_401[10:10];
    assign signal_cat_10 = { signal_const_130,
                             signal_select_20 };
    assign signal_select_21 = signal_mux_401[10:10];
    assign signal_cat_11 = { signal_const_130,
                             signal_select_21 };
    assign signal_select_22 = signal_mux_401[10:8];
    assign signal_const_166 = 13'b0000000000000;
    assign signal_cat_12 = { signal_const_166,
                             signal_select_22 };
    assign signal_select_23 = signal_mux_401[10:8];
    assign signal_cat_13 = { signal_const_166,
                             signal_select_23 };
    assign signal_select_24 = signal_mux_401[10:8];
    always @* begin
        case (signal_select_24)
        0:
            signal_mux_178 <= execution$reg_r0;
        1:
            signal_mux_178 <= execution$reg_r1;
        2:
            signal_mux_178 <= execution$reg_r2;
        3:
            signal_mux_178 <= execution$reg_r3;
        4:
            signal_mux_178 <= execution$reg_r4;
        5:
            signal_mux_178 <= execution$reg_r5;
        6:
            signal_mux_178 <= execution$reg_r6;
        default:
            signal_mux_178 <= execution$reg_r7;
        endcase
    end
    assign signal_select_25 = signal_mux_401[10:10];
    assign signal_cat_14 = { signal_const_130,
                             signal_select_25 };
    assign signal_select_26 = signal_mux_401[10:10];
    assign signal_cat_15 = { signal_const_130,
                             signal_select_26 };
    assign signal_select_27 = signal_mux_401[10:8];
    assign signal_cat_16 = { signal_const_166,
                             signal_select_27 };
    assign signal_select_28 = signal_mux_401[5:0];
    assign signal_const_174 = 10'b0000000000;
    assign signal_cat_17 = { signal_const_174,
                             signal_select_28 };
    assign signal_select_29 = signal_mux_401[10:8];
    assign signal_cat_18 = { signal_const_166,
                             signal_select_29 };
    assign signal_select_30 = signal_mux_401[10:8];
    assign signal_cat_19 = { signal_const_166,
                             signal_select_30 };
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_179 <= signal_const_78;
        1:
            signal_mux_179 <= signal_const_78;
        2:
            signal_mux_179 <= signal_const_78;
        3:
            signal_mux_179 <= signal_const_78;
        4:
            signal_mux_179 <= signal_const_78;
        5:
            signal_mux_179 <= signal_const_78;
        6:
            signal_mux_179 <= signal_const_78;
        7:
            signal_mux_179 <= signal_const_78;
        8:
            signal_mux_179 <= signal_cat_19;
        9:
            signal_mux_179 <= signal_cat_18;
        10:
            signal_mux_179 <= signal_cat_17;
        11:
            signal_mux_179 <= signal_const_78;
        12:
            signal_mux_179 <= signal_const_78;
        13:
            signal_mux_179 <= signal_cat_16;
        14:
            signal_mux_179 <= signal_const_78;
        15:
            signal_mux_179 <= signal_cat_15;
        16:
            signal_mux_179 <= signal_cat_14;
        17:
            signal_mux_179 <= signal_mux_282;
        18:
            signal_mux_179 <= signal_mux_178;
        19:
            signal_mux_179 <= signal_cat_13;
        20:
            signal_mux_179 <= signal_cat_12;
        21:
            signal_mux_179 <= signal_mux_282;
        22:
            signal_mux_179 <= signal_const_78;
        23:
            signal_mux_179 <= signal_const_78;
        24:
            signal_mux_179 <= signal_const_78;
        25:
            signal_mux_179 <= signal_cat_11;
        26:
            signal_mux_179 <= signal_cat_10;
        27:
            signal_mux_179 <= signal_const_78;
        28:
            signal_mux_179 <= signal_const_78;
        29:
            signal_mux_179 <= signal_const_78;
        30:
            signal_mux_179 <= signal_const_78;
        default:
            signal_mux_179 <= signal_const_78;
        endcase
    end
    assign signal_const_190 = 4'b1110;
    assign signal_const_191 = 4'b1101;
    assign signal_const_192 = 4'b1100;
    assign signal_const_194 = 4'b1011;
    assign signal_const_195 = 4'b1010;
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_180 <= signal_const_53;
        1:
            signal_mux_180 <= signal_const_53;
        2:
            signal_mux_180 <= signal_const_53;
        3:
            signal_mux_180 <= signal_const_53;
        4:
            signal_mux_180 <= signal_const_53;
        5:
            signal_mux_180 <= signal_const_53;
        6:
            signal_mux_180 <= signal_const_53;
        7:
            signal_mux_180 <= signal_const_53;
        8:
            signal_mux_180 <= signal_const_53;
        9:
            signal_mux_180 <= signal_const_49;
        10:
            signal_mux_180 <= signal_const_48;
        11:
            signal_mux_180 <= signal_const_53;
        12:
            signal_mux_180 <= signal_const_53;
        13:
            signal_mux_180 <= signal_const_51;
        14:
            signal_mux_180 <= signal_const_53;
        15:
            signal_mux_180 <= signal_const_50;
        16:
            signal_mux_180 <= signal_const_52;
        17:
            signal_mux_180 <= signal_const_47;
        18:
            signal_mux_180 <= signal_const_46;
        19:
            signal_mux_180 <= signal_const_45;
        20:
            signal_mux_180 <= signal_const_44;
        21:
            signal_mux_180 <= signal_const_195;
        22:
            signal_mux_180 <= signal_const_194;
        23:
            signal_mux_180 <= signal_const_53;
        24:
            signal_mux_180 <= signal_const_192;
        25:
            signal_mux_180 <= signal_const_191;
        26:
            signal_mux_180 <= signal_const_190;
        27:
            signal_mux_180 <= signal_const_53;
        28:
            signal_mux_180 <= signal_const_53;
        29:
            signal_mux_180 <= signal_const_53;
        30:
            signal_mux_180 <= signal_const_53;
        default:
            signal_mux_180 <= signal_const_53;
        endcase
    end
    assign signal_mux_181 = signal_and_67 ? signal_const_15 : signal_reg;
    assign signal_mux_182 = signal_and_82 ? signal_const_15 : signal_mux_181;
    assign signal_mux_183 = signal_and_110 ? signal_const_14 : signal_mux_182;
    assign signal_mux_184 = signal_not_78 ? signal_reg : signal_mux_183;
    assign signal_wire_26 = signal_mux_184;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg <= signal_const_15;
        else
            signal_reg <= signal_wire_26;
    end
    assign signal_mux_185 = signal_and_13 ? signal_wire_53 : signal_reg_1;
    assign signal_mux_186 = signal_not_78 ? signal_reg_1 : signal_mux_185;
    assign signal_wire_27 = signal_mux_186;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_1 <= signal_const_78;
        else
            signal_reg_1 <= signal_wire_27;
    end
    assign signal_mux_187 = signal_and_13 ? signal_const_14 : signal_const_15;
    assign signal_mux_188 = signal_wire_78 ? signal_const_15 : signal_mux_187;
    assign signal_mux_189 = signal_and_110 ? signal_const_15 : signal_mux_188;
    assign signal_mux_190 = signal_not_78 ? signal_const_15 : signal_mux_189;
    assign signal_wire_28 = signal_mux_190;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_2 <= signal_const_15;
        else
            signal_reg_2 <= signal_wire_28;
    end
    assign signal_and_6 = signal_reg_7 & signal_eq_109;
    assign signal_mux_191 = signal_and_64 ? signal_and_6 : signal_const_15;
    assign signal_mux_192 = signal_not_78 ? signal_const_15 : signal_mux_191;
    assign signal_wire_29 = signal_mux_192;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_3 <= signal_const_15;
        else
            signal_reg_3 <= signal_wire_29;
    end
    assign signal_mux_193 = signal_and_64 ? signal_wire_53 : signal_reg_4;
    assign signal_mux_194 = signal_not_78 ? signal_reg_4 : signal_mux_193;
    assign signal_wire_30 = signal_mux_194;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_4 <= signal_const_78;
        else
            signal_reg_4 <= signal_wire_30;
    end
    assign signal_mux_195 = signal_and_64 ? signal_const_14 : signal_const_15;
    assign signal_mux_196 = signal_wire_78 ? signal_const_15 : signal_mux_195;
    assign signal_mux_197 = signal_and_67 ? signal_const_15 : signal_mux_196;
    assign signal_mux_198 = signal_not_78 ? signal_const_15 : signal_mux_197;
    assign signal_wire_31 = signal_mux_198;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_5 <= signal_const_15;
        else
            signal_reg_5 <= signal_wire_31;
    end
    assign signal_not_10 = ~ signal_and_82;
    assign signal_and_7 = signal_wire_66 & signal_not_10;
    assign signal_not_11 = ~ signal_and_60;
    assign signal_and_8 = signal_wire_68 & signal_not_11;
    assign signal_not_12 = ~ signal_and_74;
    assign signal_and_9 = signal_wire_67 & signal_not_12;
    assign signal_not_13 = ~ signal_and_119;
    assign signal_and_10 = signal_wire_69 & signal_not_13;
    assign signal_not_14 = ~ signal_and_67;
    assign signal_and_11 = signal_wire_70 & signal_not_14;
    assign signal_wire_32 = load_data_i;
    assign signal_mux_199 = signal_and_60 ? signal_wire_56 : signal_wire_35;
    assign signal_mux_200 = signal_and_119 ? signal_wire_33 : signal_mux_199;
    assign signal_select_31 = signal_mux_200[7:0];
    assign signal_not_15 = ~ signal_wire_80;
    assign signal_and_12 = signal_and_119 & signal_not_15;
    assign signal_not_16 = ~ signal_wire_80;
    assign signal_or_6 = signal_and_60 | signal_and_105;
    assign signal_lt = signal_wire_33 < signal_reg_11;
    assign signal_wire_33 = load_address_i;
    assign signal_eq_14 = signal_wire_33 == signal_reg_12;
    assign signal_not_17 = ~ signal_wire_78;
    assign signal_not_18 = ~ signal_wire_80;
    assign signal_wire_34 = engines_idle_i;
    assign signal_mux_201 = signal_wire_78 ? signal_const_15 : signal_reg_16;
    assign signal_mux_202 = signal_and_82 ? signal_const_14 : signal_mux_201;
    assign signal_not_19 = ~ signal_and_14;
    assign signal_not_20 = ~ signal_wire_78;
    assign signal_and_13 = signal_and_48 & signal_not_20;
    assign signal_mux_203 = signal_and_13 ? signal_const_15 : signal_reg_15;
    assign signal_mux_204 = signal_wire_78 ? signal_const_15 : signal_mux_203;
    assign signal_mux_205 = signal_and_110 ? signal_const_15 : signal_mux_204;
    assign signal_lt_1 = signal_wire_35 < signal_reg_11;
    assign signal_const_248 = 9'b100000000;
    assign signal_const_249 = 17'b00000000000000001;
    assign signal_add_8 = execution$reg_pc + signal_const_249;
    assign signal_mux_206 = signal_and_42 ? signal_add_8 : execution$reg_pc;
    assign signal_select_32 = signal_mux_206[8:0];
    assign signal_wire_35 = signal_select_32;
    assign signal_lt_2 = signal_wire_35 < signal_const_248;
    assign signal_and_14 = signal_lt_2 & signal_lt_1;
    assign signal_wire_36 = signal_or_49;
    assign signal_or_7 = signal_and_19 | signal_and_20;
    assign signal_or_8 = signal_or_7 | signal_and_21;
    assign signal_or_9 = signal_or_8 | signal_and_22;
    assign signal_or_10 = signal_or_9 | signal_and_27;
    assign signal_or_11 = signal_or_10 | signal_and_29;
    assign signal_or_12 = signal_or_11 | signal_and_30;
    assign signal_or_13 = signal_or_12 | signal_and_33;
    assign signal_or_14 = signal_or_13 | signal_and_96;
    assign signal_eq_15 = signal_select_173 == signal_const_29;
    assign signal_not_21 = ~ signal_wire_72;
    assign signal_and_15 = signal_and_49 & signal_and_26;
    assign signal_not_22 = ~ signal_mux_353;
    assign signal_mux_207 = signal_and_42 ? signal_const_32 : signal_const_31;
    assign signal_mux_208 = signal_and_82 ? signal_const_30 : execution$reg_phase;
    assign signal_mux_209 = signal_and_92 ? signal_mux_207 : signal_mux_208;
    assign signal_mux_210 = signal_and_83 ? signal_const_30 : signal_mux_209;
    assign signal_mux_211 = signal_and_102 ? signal_const_35 : signal_mux_210;
    assign signal_not_23 = ~ signal_wire_73;
    assign signal_not_24 = ~ signal_wire_74;
    assign signal_and_16 = signal_and_93 & signal_not_24;
    assign signal_and_17 = signal_and_16 & signal_not_23;
    assign signal_mux_212 = signal_and_17 ? signal_const_33 : signal_mux_211;
    assign signal_not_25 = ~ signal_wire_72;
    assign signal_and_18 = signal_and_88 & signal_not_25;
    assign signal_mux_213 = signal_and_18 ? signal_const_34 : signal_mux_212;
    assign signal_mux_214 = signal_and_90 ? signal_const_30 : signal_mux_213;
    assign signal_not_26 = ~ signal_eq_115;
    assign signal_and_19 = signal_eq_116 & signal_not_26;
    assign signal_mux_215 = signal_and_19 ? signal_const_75 : signal_mux_214;
    assign signal_and_20 = signal_and_91 & signal_and_110;
    assign signal_mux_216 = signal_and_20 ? signal_const_75 : signal_mux_215;
    assign signal_and_21 = signal_and_42 & signal_and_110;
    assign signal_mux_217 = signal_and_21 ? signal_const_75 : signal_mux_216;
    assign signal_not_27 = ~ signal_and_40;
    assign signal_and_22 = signal_and_97 & signal_not_27;
    assign signal_mux_218 = signal_and_22 ? signal_const_75 : signal_mux_217;
    assign signal_const_271 = 16'b0000000011111111;
    assign signal_lt_3 = signal_const_271 < signal_mux_280;
    assign signal_not_28 = ~ signal_lt_3;
    assign signal_eq_16 = signal_mux_280 == signal_const_78;
    assign signal_not_29 = ~ signal_eq_16;
    assign signal_eq_17 = signal_select_173 == signal_const_96;
    assign signal_eq_18 = signal_select_173 == signal_const_97;
    assign signal_const_275 = 5'b10101;
    assign signal_eq_19 = signal_select_173 == signal_const_275;
    assign signal_const_276 = 5'b10001;
    assign signal_eq_20 = signal_select_173 == signal_const_276;
    assign signal_or_15 = signal_eq_20 | signal_eq_19;
    assign signal_or_16 = signal_or_15 | signal_eq_18;
    assign signal_or_17 = signal_or_16 | signal_eq_17;
    assign signal_mux_219 = signal_or_17 ? signal_not_29 : vdd;
    assign signal_const_277 = 5'b01111;
    assign signal_eq_21 = signal_select_173 == signal_const_277;
    assign signal_mux_220 = signal_eq_21 ? signal_not_28 : signal_mux_219;
    assign signal_mux_221 = signal_and_42 ? signal_const_14 : signal_const_15;
    assign signal_mux_222 = signal_and_82 ? signal_const_15 : execution$reg_has_extension;
    assign signal_mux_223 = signal_and_92 ? signal_mux_221 : signal_mux_222;
    assign signal_mux_224 = signal_not_74 ? signal_const_15 : signal_mux_223;
    assign signal_mux_225 = signal_wire_80 ? signal_const_15 : signal_mux_224;
    assign signal_wire_37 = signal_mux_225;
    always @(posedge signal_wire_62) begin
        execution$reg_has_extension <= signal_wire_37;
    end
    assign signal_or_18 = signal_eq_22 | signal_eq_114;
    assign signal_and_23 = signal_or_18 & execution$reg_has_extension;
    assign signal_and_24 = signal_eq_70 & signal_and_48;
    assign signal_or_19 = signal_and_24 | signal_and_23;
    assign signal_and_25 = signal_or_19 & signal_mux_220;
    assign signal_not_30 = ~ signal_mux_353;
    assign signal_or_20 = signal_not_30 | signal_and_25;
    assign signal_and_26 = signal_and_40 & signal_or_20;
    assign signal_not_31 = ~ signal_and_26;
    assign signal_and_27 = signal_and_49 & signal_not_31;
    assign signal_mux_226 = signal_and_27 ? signal_const_75 : signal_mux_218;
    assign signal_not_32 = ~ signal_wire_74;
    assign signal_and_28 = signal_and_94 & signal_wire_73;
    assign signal_and_29 = signal_and_28 & signal_not_32;
    assign signal_mux_227 = signal_and_29 ? signal_const_75 : signal_mux_226;
    assign signal_or_21 = signal_and_89 | signal_and_86;
    assign signal_and_30 = signal_or_21 & signal_wire_71;
    assign signal_mux_228 = signal_and_30 ? signal_const_75 : signal_mux_227;
    assign signal_not_33 = ~ signal_and_86;
    assign signal_not_34 = ~ signal_and_89;
    assign signal_and_31 = signal_and_84 & signal_wire_72;
    assign signal_and_32 = signal_and_31 & signal_not_34;
    assign signal_and_33 = signal_and_32 & signal_not_33;
    assign signal_mux_229 = signal_and_33 ? signal_const_75 : signal_mux_228;
    assign signal_eq_22 = execution$reg_phase == signal_const_33;
    assign signal_eq_23 = signal_select_173 == signal_const_95;
    assign signal_const_284 = 5'b11100;
    assign signal_eq_24 = signal_select_173 == signal_const_284;
    assign signal_const_285 = 5'b11011;
    assign signal_eq_25 = signal_select_173 == signal_const_285;
    assign signal_const_286 = 5'b01110;
    assign signal_eq_26 = signal_select_173 == signal_const_286;
    assign signal_const_287 = 5'b01100;
    assign signal_eq_27 = signal_select_173 == signal_const_287;
    assign signal_const_288 = 5'b01011;
    assign signal_eq_28 = signal_select_173 == signal_const_288;
    assign signal_const_289 = 5'b00111;
    assign signal_eq_29 = signal_select_173 == signal_const_289;
    assign signal_const_290 = 5'b00110;
    assign signal_eq_30 = signal_select_173 == signal_const_290;
    assign signal_const_291 = 5'b00101;
    assign signal_eq_31 = signal_select_173 == signal_const_291;
    assign signal_const_292 = 5'b00100;
    assign signal_eq_32 = signal_select_173 == signal_const_292;
    assign signal_const_293 = 5'b00011;
    assign signal_eq_33 = signal_select_173 == signal_const_293;
    assign signal_const_294 = 5'b00010;
    assign signal_eq_34 = signal_select_173 == signal_const_294;
    assign signal_const_295 = 5'b00001;
    assign signal_eq_35 = signal_select_173 == signal_const_295;
    assign signal_mux_230 = signal_and_42 ? signal_wire_53 : signal_mux_231;
    assign signal_mux_231 = signal_and_82 ? signal_const_78 : execution$reg_base_word;
    assign signal_select_33 = signal_mux_401[10:7];
    assign signal_lt_4 = signal_select_33 < signal_const_44;
    assign signal_select_34 = signal_mux_401[9:0];
    assign signal_eq_36 = signal_select_34 == signal_const_174;
    assign signal_not_35 = ~ signal_eq_36;
    assign signal_select_35 = signal_mux_401[10:10];
    assign signal_or_22 = signal_select_35 | signal_not_35;
    assign signal_select_36 = signal_mux_401[3:0];
    assign signal_eq_37 = signal_select_36 == signal_const_53;
    assign signal_select_37 = signal_mux_401[3:0];
    assign signal_eq_38 = signal_select_37 == signal_const_53;
    assign signal_not_36 = ~ signal_eq_38;
    assign signal_select_38 = signal_mux_401[4:4];
    assign signal_mux_232 = signal_select_38 ? signal_eq_37 : signal_not_36;
    assign signal_select_39 = signal_mux_401[3:0];
    assign signal_eq_39 = signal_select_39 == signal_const_53;
    assign signal_select_40 = signal_mux_401[4:4];
    assign signal_not_37 = ~ signal_select_40;
    assign signal_and_34 = signal_not_37 & signal_eq_39;
    assign signal_select_41 = signal_mux_401[5:5];
    assign signal_mux_233 = signal_select_41 ? signal_mux_232 : signal_and_34;
    assign signal_const_303 = 2'b11;
    assign signal_select_42 = signal_mux_401[7:6];
    assign signal_lt_5 = signal_select_42 < signal_const_303;
    assign signal_and_35 = signal_lt_5 & signal_mux_233;
    assign signal_select_43 = signal_mux_401[4:0];
    assign signal_eq_40 = signal_select_43 == signal_const_29;
    assign signal_select_44 = signal_mux_401[4:0];
    assign signal_eq_41 = signal_select_44 == signal_const_29;
    assign signal_not_38 = ~ signal_eq_41;
    assign signal_select_45 = signal_mux_401[5:5];
    assign signal_mux_234 = signal_select_45 ? signal_eq_40 : signal_not_38;
    assign signal_select_46 = signal_mux_401[4:0];
    assign signal_eq_42 = signal_select_46 == signal_const_29;
    assign signal_select_47 = signal_mux_401[5:5];
    assign signal_not_39 = ~ signal_select_47;
    assign signal_and_36 = signal_not_39 & signal_eq_42;
    assign signal_select_48 = signal_mux_401[6:6];
    assign signal_mux_235 = signal_select_48 ? signal_mux_234 : signal_and_36;
    assign signal_select_49 = signal_mux_401[9:0];
    assign signal_eq_43 = signal_select_49 == signal_const_174;
    assign signal_not_40 = ~ signal_eq_43;
    assign signal_select_50 = signal_mux_401[10:10];
    assign signal_or_23 = signal_select_50 | signal_not_40;
    assign signal_select_51 = signal_mux_401[10:8];
    assign signal_lt_6 = signal_select_51 < signal_const_75;
    assign signal_select_52 = signal_mux_401[6:3];
    assign signal_eq_44 = signal_select_52 == signal_const_53;
    assign signal_not_41 = ~ signal_eq_44;
    assign signal_select_53 = signal_mux_401[10:8];
    assign signal_lt_7 = signal_select_53 < signal_const_34;
    assign signal_select_54 = signal_mux_401[10:8];
    assign signal_lt_8 = signal_select_54 < signal_const_34;
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_236 <= vdd;
        1:
            signal_mux_236 <= vdd;
        2:
            signal_mux_236 <= vdd;
        3:
            signal_mux_236 <= signal_lt_8;
        4:
            signal_mux_236 <= signal_lt_7;
        5:
            signal_mux_236 <= vdd;
        6:
            signal_mux_236 <= vdd;
        7:
            signal_mux_236 <= signal_not_41;
        8:
            signal_mux_236 <= vdd;
        9:
            signal_mux_236 <= vdd;
        10:
            signal_mux_236 <= vdd;
        11:
            signal_mux_236 <= vdd;
        12:
            signal_mux_236 <= signal_lt_6;
        13:
            signal_mux_236 <= vdd;
        14:
            signal_mux_236 <= vdd;
        15:
            signal_mux_236 <= vdd;
        16:
            signal_mux_236 <= vdd;
        17:
            signal_mux_236 <= signal_or_23;
        18:
            signal_mux_236 <= vdd;
        19:
            signal_mux_236 <= signal_mux_235;
        20:
            signal_mux_236 <= signal_and_35;
        21:
            signal_mux_236 <= signal_or_22;
        22:
            signal_mux_236 <= vdd;
        23:
            signal_mux_236 <= signal_lt_4;
        24:
            signal_mux_236 <= vdd;
        25:
            signal_mux_236 <= vdd;
        26:
            signal_mux_236 <= vdd;
        27:
            signal_mux_236 <= vdd;
        28:
            signal_mux_236 <= vdd;
        29:
            signal_mux_236 <= vdd;
        30:
            signal_mux_236 <= vdd;
        default:
            signal_mux_236 <= vdd;
        endcase
    end
    assign signal_const_312 = 6'b000000;
    assign signal_select_55 = signal_mux_401[5:0];
    assign signal_eq_45 = signal_select_55 == signal_const_312;
    assign signal_select_56 = signal_mux_401[6:6];
    assign signal_not_42 = ~ signal_select_56;
    assign signal_or_24 = signal_not_42 | signal_eq_45;
    assign signal_select_57 = signal_mux_401[9:0];
    assign signal_eq_46 = signal_select_57 == signal_const_174;
    assign signal_select_58 = signal_mux_401[10:10];
    assign signal_not_43 = ~ signal_select_58;
    assign signal_or_25 = signal_not_43 | signal_eq_46;
    assign signal_select_59 = signal_mux_401[3:0];
    assign signal_eq_47 = signal_select_59 == signal_const_53;
    assign signal_select_60 = signal_mux_401[4:4];
    assign signal_not_44 = ~ signal_select_60;
    assign signal_or_26 = signal_not_44 | signal_eq_47;
    assign signal_select_61 = signal_mux_401[4:0];
    assign signal_eq_48 = signal_select_61 == signal_const_29;
    assign signal_select_62 = signal_mux_401[5:5];
    assign signal_not_45 = ~ signal_select_62;
    assign signal_or_27 = signal_not_45 | signal_eq_48;
    assign signal_select_63 = signal_mux_401[9:0];
    assign signal_eq_49 = signal_select_63 == signal_const_174;
    assign signal_select_64 = signal_mux_401[10:10];
    assign signal_not_46 = ~ signal_select_64;
    assign signal_or_28 = signal_not_46 | signal_eq_49;
    assign signal_const_317 = 7'b0000000;
    assign signal_select_65 = signal_mux_401[6:0];
    assign signal_eq_50 = signal_select_65 == signal_const_317;
    assign signal_select_66 = signal_mux_401[7:7];
    assign signal_not_47 = ~ signal_select_66;
    assign signal_or_29 = signal_not_47 | signal_eq_50;
    assign signal_select_67 = signal_mux_401[3:0];
    assign signal_eq_51 = signal_select_67 == signal_const_53;
    assign signal_select_68 = signal_mux_401[4:4];
    assign signal_not_48 = ~ signal_select_68;
    assign signal_or_30 = signal_not_48 | signal_eq_51;
    assign signal_select_69 = signal_mux_401[6:0];
    assign signal_eq_52 = signal_select_69 == signal_const_317;
    assign signal_select_70 = signal_mux_401[7:7];
    assign signal_not_49 = ~ signal_select_70;
    assign signal_or_31 = signal_not_49 | signal_eq_52;
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_237 <= vdd;
        1:
            signal_mux_237 <= signal_or_31;
        2:
            signal_mux_237 <= vdd;
        3:
            signal_mux_237 <= vdd;
        4:
            signal_mux_237 <= signal_or_30;
        5:
            signal_mux_237 <= vdd;
        6:
            signal_mux_237 <= signal_or_29;
        7:
            signal_mux_237 <= vdd;
        8:
            signal_mux_237 <= vdd;
        9:
            signal_mux_237 <= vdd;
        10:
            signal_mux_237 <= vdd;
        11:
            signal_mux_237 <= vdd;
        12:
            signal_mux_237 <= vdd;
        13:
            signal_mux_237 <= vdd;
        14:
            signal_mux_237 <= vdd;
        15:
            signal_mux_237 <= vdd;
        16:
            signal_mux_237 <= vdd;
        17:
            signal_mux_237 <= signal_or_28;
        18:
            signal_mux_237 <= vdd;
        19:
            signal_mux_237 <= signal_or_27;
        20:
            signal_mux_237 <= signal_or_26;
        21:
            signal_mux_237 <= signal_or_25;
        22:
            signal_mux_237 <= vdd;
        23:
            signal_mux_237 <= signal_or_24;
        24:
            signal_mux_237 <= vdd;
        25:
            signal_mux_237 <= vdd;
        26:
            signal_mux_237 <= vdd;
        27:
            signal_mux_237 <= vdd;
        28:
            signal_mux_237 <= vdd;
        29:
            signal_mux_237 <= gnd;
        30:
            signal_mux_237 <= gnd;
        default:
            signal_mux_237 <= gnd;
        endcase
    end
    assign signal_const_320 = 11'b00000000000;
    assign signal_const_322 = 11'b00011111111;
    assign signal_const_324 = 11'b00000111111;
    assign signal_const_326 = 11'b11111111111;
    assign signal_const_334 = 11'b00000001111;
    assign signal_const_335 = 11'b00000000011;
    assign signal_const_340 = 11'b11111000000;
    assign signal_const_343 = 11'b00000000111;
    assign signal_const_345 = 11'b00000011111;
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_238 <= signal_const_326;
        1:
            signal_mux_238 <= signal_const_320;
        2:
            signal_mux_238 <= signal_const_345;
        3:
            signal_mux_238 <= signal_const_335;
        4:
            signal_mux_238 <= signal_const_320;
        5:
            signal_mux_238 <= signal_const_345;
        6:
            signal_mux_238 <= signal_const_320;
        7:
            signal_mux_238 <= signal_const_343;
        8:
            signal_mux_238 <= signal_const_322;
        9:
            signal_mux_238 <= signal_const_322;
        10:
            signal_mux_238 <= signal_const_340;
        11:
            signal_mux_238 <= signal_const_320;
        12:
            signal_mux_238 <= signal_const_320;
        13:
            signal_mux_238 <= signal_const_320;
        14:
            signal_mux_238 <= signal_const_320;
        15:
            signal_mux_238 <= signal_const_335;
        16:
            signal_mux_238 <= signal_const_334;
        17:
            signal_mux_238 <= signal_const_320;
        18:
            signal_mux_238 <= signal_const_322;
        19:
            signal_mux_238 <= signal_const_320;
        20:
            signal_mux_238 <= signal_const_320;
        21:
            signal_mux_238 <= signal_const_320;
        22:
            signal_mux_238 <= signal_const_326;
        23:
            signal_mux_238 <= signal_const_320;
        24:
            signal_mux_238 <= signal_const_326;
        25:
            signal_mux_238 <= signal_const_324;
        26:
            signal_mux_238 <= signal_const_324;
        27:
            signal_mux_238 <= signal_const_320;
        28:
            signal_mux_238 <= signal_const_322;
        29:
            signal_mux_238 <= signal_const_320;
        30:
            signal_mux_238 <= signal_const_320;
        default:
            signal_mux_238 <= signal_const_320;
        endcase
    end
    assign signal_select_71 = signal_mux_401[10:0];
    assign signal_and_37 = signal_select_71 & signal_mux_238;
    assign signal_eq_53 = signal_and_37 == signal_const_320;
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_239 <= vdd;
        1:
            signal_mux_239 <= vdd;
        2:
            signal_mux_239 <= vdd;
        3:
            signal_mux_239 <= vdd;
        4:
            signal_mux_239 <= vdd;
        5:
            signal_mux_239 <= vdd;
        6:
            signal_mux_239 <= vdd;
        7:
            signal_mux_239 <= vdd;
        8:
            signal_mux_239 <= vdd;
        9:
            signal_mux_239 <= vdd;
        10:
            signal_mux_239 <= vdd;
        11:
            signal_mux_239 <= vdd;
        12:
            signal_mux_239 <= vdd;
        13:
            signal_mux_239 <= vdd;
        14:
            signal_mux_239 <= vdd;
        15:
            signal_mux_239 <= vdd;
        16:
            signal_mux_239 <= vdd;
        17:
            signal_mux_239 <= vdd;
        18:
            signal_mux_239 <= vdd;
        19:
            signal_mux_239 <= vdd;
        20:
            signal_mux_239 <= vdd;
        21:
            signal_mux_239 <= vdd;
        22:
            signal_mux_239 <= vdd;
        23:
            signal_mux_239 <= vdd;
        24:
            signal_mux_239 <= vdd;
        25:
            signal_mux_239 <= vdd;
        26:
            signal_mux_239 <= vdd;
        27:
            signal_mux_239 <= vdd;
        28:
            signal_mux_239 <= vdd;
        29:
            signal_mux_239 <= gnd;
        30:
            signal_mux_239 <= gnd;
        default:
            signal_mux_239 <= gnd;
        endcase
    end
    assign signal_and_38 = signal_mux_239 & signal_eq_53;
    assign signal_and_39 = signal_and_38 & signal_mux_237;
    assign signal_and_40 = signal_and_39 & signal_mux_236;
    assign signal_and_41 = signal_and_97 & signal_and_40;
    assign signal_and_42 = signal_and_41 & signal_mux_353;
    assign signal_select_72 = signal_mux_401[6:0];
    assign signal_select_73 = signal_select_72[6:6];
    assign signal_cat_20 = { signal_select_73,
                             signal_select_73 };
    assign signal_cat_21 = { signal_cat_20,
                             signal_cat_20 };
    assign signal_cat_22 = { signal_cat_21,
                             signal_cat_21 };
    assign signal_cat_23 = { signal_cat_22,
                             signal_cat_20 };
    assign signal_cat_24 = { signal_cat_23,
                             signal_select_72 };
    assign signal_add_9 = execution$reg_pc + signal_const_249;
    assign signal_add_10 = signal_add_9 + signal_cat_24;
    assign signal_select_74 = signal_wire_41[0:0];
    assign signal_const_353 = 5'b01101;
    assign signal_eq_54 = signal_select_173 == signal_const_353;
    assign signal_and_43 = signal_eq_54 & signal_select_74;
    assign signal_mux_240 = signal_and_43 ? signal_add_10 : signal_add_22;
    assign signal_select_75 = signal_mux_401[10:0];
    assign signal_select_76 = signal_select_75[10:10];
    assign signal_cat_25 = { signal_select_76,
                             signal_select_76 };
    assign signal_cat_26 = { signal_cat_25,
                             signal_cat_25 };
    assign signal_cat_27 = { signal_cat_26,
                             signal_cat_25 };
    assign signal_cat_28 = { signal_cat_27,
                             signal_select_75 };
    assign signal_add_11 = execution$reg_pc + signal_const_249;
    assign signal_add_12 = signal_add_11 + signal_cat_28;
    assign signal_select_77 = signal_mux_401[7:0];
    assign signal_select_78 = signal_select_77[7:7];
    assign signal_cat_29 = { signal_select_78,
                             signal_select_78 };
    assign signal_cat_30 = { signal_cat_29,
                             signal_cat_29 };
    assign signal_cat_31 = { signal_cat_30,
                             signal_cat_30 };
    assign signal_cat_32 = { signal_cat_31,
                             signal_select_78 };
    assign signal_cat_33 = { signal_cat_32,
                             signal_select_77 };
    assign signal_add_13 = execution$reg_pc + signal_const_249;
    assign signal_add_14 = signal_add_13 + signal_cat_33;
    assign signal_not_50 = ~ execution$reg_negative;
    assign signal_select_79 = signal_mux_264[15:15];
    assign signal_mux_241 = signal_and_82 ? signal_const_15 : execution$reg_negative;
    assign signal_mux_242 = signal_and_44 ? signal_select_79 : signal_mux_241;
    assign signal_mux_243 = signal_not_74 ? execution$reg_negative : signal_mux_242;
    assign signal_mux_244 = signal_wire_80 ? signal_const_15 : signal_mux_243;
    assign signal_wire_38 = signal_mux_244;
    always @(posedge signal_wire_62) begin
        execution$reg_negative <= signal_wire_38;
    end
    assign signal_not_51 = ~ execution$reg_carry;
    assign signal_lt_9 = signal_mux_274 < signal_mux_273;
    assign signal_select_80 = signal_add_19[16:16];
    always @* begin
        case (signal_select_123)
        0:
            signal_mux_245 <= signal_select_80;
        1:
            signal_mux_245 <= signal_lt_9;
        2:
            signal_mux_245 <= gnd;
        3:
            signal_mux_245 <= gnd;
        4:
            signal_mux_245 <= gnd;
        5:
            signal_mux_245 <= gnd;
        6:
            signal_mux_245 <= gnd;
        default:
            signal_mux_245 <= gnd;
        endcase
    end
    assign signal_lt_10 = signal_mux_283 < signal_mux_282;
    assign signal_select_81 = signal_add_20[16:16];
    always @* begin
        case (signal_select_133)
        0:
            signal_mux_246 <= signal_select_81;
        1:
            signal_mux_246 <= signal_lt_10;
        2:
            signal_mux_246 <= gnd;
        3:
            signal_mux_246 <= gnd;
        4:
            signal_mux_246 <= gnd;
        5:
            signal_mux_246 <= gnd;
        6:
            signal_mux_246 <= gnd;
        default:
            signal_mux_246 <= gnd;
        endcase
    end
    assign signal_lt_11 = signal_mux_259 < signal_mux_258;
    assign signal_lt_12 = signal_mux_260 < signal_mux_282;
    assign signal_select_82 = signal_mux_289[14:14];
    assign signal_select_83 = signal_mux_289[13:13];
    assign signal_select_84 = signal_mux_289[12:12];
    assign signal_select_85 = signal_mux_289[11:11];
    assign signal_select_86 = signal_mux_289[10:10];
    assign signal_select_87 = signal_mux_289[9:9];
    assign signal_select_88 = signal_mux_289[8:8];
    assign signal_select_89 = signal_mux_289[7:7];
    assign signal_select_90 = signal_mux_289[6:6];
    assign signal_select_91 = signal_mux_289[5:5];
    assign signal_select_92 = signal_mux_289[4:4];
    assign signal_select_93 = signal_mux_289[3:3];
    assign signal_select_94 = signal_mux_289[2:2];
    assign signal_select_95 = signal_mux_289[1:1];
    assign signal_select_96 = signal_mux_289[0:0];
    always @* begin
        case (signal_select_149)
        0:
            signal_mux_247 <= gnd;
        1:
            signal_mux_247 <= signal_select_96;
        2:
            signal_mux_247 <= signal_select_95;
        3:
            signal_mux_247 <= signal_select_94;
        4:
            signal_mux_247 <= signal_select_93;
        5:
            signal_mux_247 <= signal_select_92;
        6:
            signal_mux_247 <= signal_select_91;
        7:
            signal_mux_247 <= signal_select_90;
        8:
            signal_mux_247 <= signal_select_89;
        9:
            signal_mux_247 <= signal_select_88;
        10:
            signal_mux_247 <= signal_select_87;
        11:
            signal_mux_247 <= signal_select_86;
        12:
            signal_mux_247 <= signal_select_85;
        13:
            signal_mux_247 <= signal_select_84;
        14:
            signal_mux_247 <= signal_select_83;
        default:
            signal_mux_247 <= signal_select_82;
        endcase
    end
    assign signal_select_97 = signal_mux_289[1:1];
    assign signal_select_98 = signal_mux_289[2:2];
    assign signal_select_99 = signal_mux_289[3:3];
    assign signal_select_100 = signal_mux_289[4:4];
    assign signal_select_101 = signal_mux_289[5:5];
    assign signal_select_102 = signal_mux_289[6:6];
    assign signal_select_103 = signal_mux_289[7:7];
    assign signal_select_104 = signal_mux_289[8:8];
    assign signal_select_105 = signal_mux_289[9:9];
    assign signal_select_106 = signal_mux_289[10:10];
    assign signal_select_107 = signal_mux_289[11:11];
    assign signal_select_108 = signal_mux_289[12:12];
    assign signal_select_109 = signal_mux_289[13:13];
    assign signal_select_110 = signal_mux_289[14:14];
    assign signal_select_111 = signal_mux_289[15:15];
    always @* begin
        case (signal_select_149)
        0:
            signal_mux_248 <= gnd;
        1:
            signal_mux_248 <= signal_select_111;
        2:
            signal_mux_248 <= signal_select_110;
        3:
            signal_mux_248 <= signal_select_109;
        4:
            signal_mux_248 <= signal_select_108;
        5:
            signal_mux_248 <= signal_select_107;
        6:
            signal_mux_248 <= signal_select_106;
        7:
            signal_mux_248 <= signal_select_105;
        8:
            signal_mux_248 <= signal_select_104;
        9:
            signal_mux_248 <= signal_select_103;
        10:
            signal_mux_248 <= signal_select_102;
        11:
            signal_mux_248 <= signal_select_101;
        12:
            signal_mux_248 <= signal_select_100;
        13:
            signal_mux_248 <= signal_select_99;
        14:
            signal_mux_248 <= signal_select_98;
        default:
            signal_mux_248 <= signal_select_97;
        endcase
    end
    assign signal_mux_249 = signal_select_151 ? signal_mux_247 : signal_mux_248;
    assign signal_eq_55 = signal_select_173 == signal_const_290;
    assign signal_mux_250 = signal_eq_55 ? signal_lt_12 : signal_mux_249;
    assign signal_eq_56 = signal_select_173 == signal_const_291;
    assign signal_mux_251 = signal_eq_56 ? signal_lt_11 : signal_mux_250;
    assign signal_eq_57 = signal_select_173 == signal_const_292;
    assign signal_mux_252 = signal_eq_57 ? signal_mux_246 : signal_mux_251;
    assign signal_eq_58 = signal_select_173 == signal_const_293;
    assign signal_mux_253 = signal_eq_58 ? signal_mux_245 : signal_mux_252;
    assign signal_mux_254 = signal_and_82 ? signal_const_15 : execution$reg_carry;
    assign signal_mux_255 = signal_and_44 ? signal_mux_253 : signal_mux_254;
    assign signal_mux_256 = signal_not_74 ? execution$reg_carry : signal_mux_255;
    assign signal_mux_257 = signal_wire_80 ? signal_const_15 : signal_mux_256;
    assign signal_wire_39 = signal_mux_257;
    always @(posedge signal_wire_62) begin
        execution$reg_carry <= signal_wire_39;
    end
    assign signal_not_52 = ~ execution$reg_zero;
    assign signal_select_112 = signal_mux_401[7:5];
    always @* begin
        case (signal_select_112)
        0:
            signal_mux_258 <= execution$reg_r0;
        1:
            signal_mux_258 <= execution$reg_r1;
        2:
            signal_mux_258 <= execution$reg_r2;
        3:
            signal_mux_258 <= execution$reg_r3;
        4:
            signal_mux_258 <= execution$reg_r4;
        5:
            signal_mux_258 <= execution$reg_r5;
        6:
            signal_mux_258 <= execution$reg_r6;
        default:
            signal_mux_258 <= execution$reg_r7;
        endcase
    end
    assign signal_select_113 = signal_mux_401[10:8];
    always @* begin
        case (signal_select_113)
        0:
            signal_mux_259 <= execution$reg_r0;
        1:
            signal_mux_259 <= execution$reg_r1;
        2:
            signal_mux_259 <= execution$reg_r2;
        3:
            signal_mux_259 <= execution$reg_r3;
        4:
            signal_mux_259 <= execution$reg_r4;
        5:
            signal_mux_259 <= execution$reg_r5;
        6:
            signal_mux_259 <= execution$reg_r6;
        default:
            signal_mux_259 <= execution$reg_r7;
        endcase
    end
    assign signal_sub = signal_mux_259 - signal_mux_258;
    assign signal_select_114 = signal_mux_401[10:8];
    always @* begin
        case (signal_select_114)
        0:
            signal_mux_260 <= execution$reg_r0;
        1:
            signal_mux_260 <= execution$reg_r1;
        2:
            signal_mux_260 <= execution$reg_r2;
        3:
            signal_mux_260 <= execution$reg_r3;
        4:
            signal_mux_260 <= execution$reg_r4;
        5:
            signal_mux_260 <= execution$reg_r5;
        6:
            signal_mux_260 <= execution$reg_r6;
        default:
            signal_mux_260 <= execution$reg_r7;
        endcase
    end
    assign signal_sub_1 = signal_mux_260 - signal_mux_282;
    assign signal_eq_59 = signal_select_173 == signal_const_290;
    assign signal_mux_261 = signal_eq_59 ? signal_sub_1 : signal_mux_294;
    assign signal_eq_60 = signal_select_173 == signal_const_291;
    assign signal_mux_262 = signal_eq_60 ? signal_sub : signal_mux_261;
    assign signal_eq_61 = signal_select_173 == signal_const_292;
    assign signal_mux_263 = signal_eq_61 ? signal_mux_284 : signal_mux_262;
    assign signal_eq_62 = signal_select_173 == signal_const_293;
    assign signal_mux_264 = signal_eq_62 ? signal_mux_275 : signal_mux_263;
    assign signal_eq_63 = signal_mux_264 == signal_const_78;
    assign signal_mux_265 = signal_and_82 ? signal_const_15 : execution$reg_zero;
    assign signal_eq_64 = signal_select_173 == signal_const_289;
    assign signal_eq_65 = signal_select_173 == signal_const_290;
    assign signal_eq_66 = signal_select_173 == signal_const_291;
    assign signal_eq_67 = signal_select_173 == signal_const_292;
    assign signal_eq_68 = signal_select_173 == signal_const_293;
    assign signal_or_32 = signal_eq_68 | signal_eq_67;
    assign signal_or_33 = signal_or_32 | signal_eq_66;
    assign signal_or_34 = signal_or_33 | signal_eq_65;
    assign signal_or_35 = signal_or_34 | signal_eq_64;
    assign signal_and_44 = signal_and_101 & signal_or_35;
    assign signal_mux_266 = signal_and_44 ? signal_eq_63 : signal_mux_265;
    assign signal_mux_267 = signal_not_74 ? execution$reg_zero : signal_mux_266;
    assign signal_mux_268 = signal_wire_80 ? signal_const_15 : signal_mux_267;
    assign signal_wire_40 = signal_mux_268;
    always @(posedge signal_wire_62) begin
        execution$reg_zero <= signal_wire_40;
    end
    assign signal_select_115 = signal_mux_401[10:8];
    always @* begin
        case (signal_select_115)
        0:
            signal_mux_269 <= execution$reg_zero;
        1:
            signal_mux_269 <= signal_not_52;
        2:
            signal_mux_269 <= execution$reg_carry;
        3:
            signal_mux_269 <= signal_not_51;
        4:
            signal_mux_269 <= execution$reg_negative;
        5:
            signal_mux_269 <= signal_not_50;
        6:
            signal_mux_269 <= gnd;
        default:
            signal_mux_269 <= gnd;
        endcase
    end
    assign signal_mux_270 = signal_mux_269 ? signal_add_14 : signal_add_22;
    assign signal_select_116 = signal_mux_401[7:0];
    assign signal_select_117 = signal_select_116[7:7];
    assign signal_cat_34 = { signal_select_117,
                             signal_select_117 };
    assign signal_cat_35 = { signal_cat_34,
                             signal_cat_34 };
    assign signal_cat_36 = { signal_cat_35,
                             signal_cat_35 };
    assign signal_cat_37 = { signal_cat_36,
                             signal_select_117 };
    assign signal_cat_38 = { signal_cat_37,
                             signal_select_116 };
    assign signal_add_15 = execution$reg_pc + signal_const_249;
    assign signal_add_16 = signal_add_15 + signal_cat_38;
    assign signal_eq_69 = signal_sub_4 == signal_const_78;
    assign signal_not_53 = ~ signal_eq_69;
    assign signal_mux_271 = signal_not_53 ? signal_add_16 : signal_add_22;
    assign signal_select_118 = signal_mux_401[7:0];
    assign signal_select_119 = signal_select_118[7:7];
    assign signal_cat_39 = { signal_select_119,
                             signal_select_119 };
    assign signal_cat_40 = { signal_cat_39,
                             signal_cat_39 };
    assign signal_cat_41 = { signal_cat_40,
                             signal_cat_40 };
    assign signal_cat_42 = { signal_cat_41,
                             signal_select_119 };
    assign signal_cat_43 = { signal_cat_42,
                             signal_select_118 };
    assign signal_add_17 = execution$reg_pc + signal_const_249;
    assign signal_add_18 = signal_add_17 + signal_cat_43;
    assign signal_wire_41 = mechanism_completion_result_i;
    assign signal_select_120 = signal_mux_401[7:5];
    always @* begin
        case (signal_select_120)
        0:
            signal_mux_272 <= execution$reg_r0;
        1:
            signal_mux_272 <= execution$reg_r1;
        2:
            signal_mux_272 <= execution$reg_r2;
        3:
            signal_mux_272 <= execution$reg_r3;
        4:
            signal_mux_272 <= execution$reg_r4;
        5:
            signal_mux_272 <= execution$reg_r5;
        6:
            signal_mux_272 <= execution$reg_r6;
        default:
            signal_mux_272 <= execution$reg_r7;
        endcase
    end
    assign signal_xor = signal_mux_274 ^ signal_mux_273;
    assign signal_or_36 = signal_mux_274 | signal_mux_273;
    assign signal_and_45 = signal_mux_274 & signal_mux_273;
    assign signal_sub_2 = signal_mux_274 - signal_mux_273;
    assign signal_select_121 = signal_mux_401[4:2];
    always @* begin
        case (signal_select_121)
        0:
            signal_mux_273 <= execution$reg_r0;
        1:
            signal_mux_273 <= execution$reg_r1;
        2:
            signal_mux_273 <= execution$reg_r2;
        3:
            signal_mux_273 <= execution$reg_r3;
        4:
            signal_mux_273 <= execution$reg_r4;
        5:
            signal_mux_273 <= execution$reg_r5;
        6:
            signal_mux_273 <= execution$reg_r6;
        default:
            signal_mux_273 <= execution$reg_r7;
        endcase
    end
    assign signal_cat_44 = { gnd,
                             signal_mux_273 };
    always @* begin
        case (signal_select_157)
        0:
            signal_mux_274 <= execution$reg_r0;
        1:
            signal_mux_274 <= execution$reg_r1;
        2:
            signal_mux_274 <= execution$reg_r2;
        3:
            signal_mux_274 <= execution$reg_r3;
        4:
            signal_mux_274 <= execution$reg_r4;
        5:
            signal_mux_274 <= execution$reg_r5;
        6:
            signal_mux_274 <= execution$reg_r6;
        default:
            signal_mux_274 <= execution$reg_r7;
        endcase
    end
    assign signal_cat_45 = { gnd,
                             signal_mux_274 };
    assign signal_add_19 = signal_cat_45 + signal_cat_44;
    assign signal_select_122 = signal_add_19[15:0];
    assign signal_select_123 = signal_mux_401[10:8];
    always @* begin
        case (signal_select_123)
        0:
            signal_mux_275 <= signal_select_122;
        1:
            signal_mux_275 <= signal_sub_2;
        2:
            signal_mux_275 <= signal_and_45;
        3:
            signal_mux_275 <= signal_or_36;
        4:
            signal_mux_275 <= signal_xor;
        5:
            signal_mux_275 <= signal_const_78;
        6:
            signal_mux_275 <= signal_const_78;
        default:
            signal_mux_275 <= signal_const_78;
        endcase
    end
    assign signal_xor_1 = signal_mux_283 ^ signal_mux_282;
    assign signal_or_37 = signal_mux_283 | signal_mux_282;
    assign signal_and_46 = signal_mux_283 & signal_mux_282;
    assign signal_sub_3 = signal_mux_283 - signal_mux_282;
    assign signal_mux_276 = signal_and_82 ? signal_const_78 : execution$reg_extension_word;
    assign signal_not_54 = ~ signal_wire_80;
    assign signal_and_47 = signal_wire_82 & signal_reg_15;
    assign signal_and_48 = signal_and_47 & signal_not_54;
    assign signal_and_49 = signal_eq_70 & signal_and_48;
    assign signal_mux_277 = signal_and_49 ? signal_wire_53 : signal_mux_276;
    assign signal_mux_278 = signal_not_74 ? execution$reg_extension_word : signal_mux_277;
    assign signal_mux_279 = signal_wire_80 ? signal_const_78 : signal_mux_278;
    assign signal_wire_42 = signal_mux_279;
    always @(posedge signal_wire_62) begin
        execution$reg_extension_word <= signal_wire_42;
    end
    assign signal_eq_70 = execution$reg_phase == signal_const_32;
    assign signal_mux_280 = signal_eq_70 ? signal_wire_53 : execution$reg_extension_word;
    assign signal_select_124 = signal_mux_401[5:0];
    assign signal_cat_46 = { signal_const_174,
                             signal_select_124 };
    assign signal_select_125 = signal_mux_401[9:0];
    assign signal_cat_47 = { signal_const_312,
                             signal_select_125 };
    assign signal_select_126 = signal_mux_401[3:0];
    assign signal_const_393 = 12'b000000000000;
    assign signal_cat_48 = { signal_const_393,
                             signal_select_126 };
    assign signal_select_127 = signal_mux_401[4:0];
    assign signal_cat_49 = { signal_const_320,
                             signal_select_127 };
    assign signal_select_128 = signal_mux_401[9:0];
    assign signal_cat_50 = { signal_const_312,
                             signal_select_128 };
    assign signal_select_129 = signal_mux_401[6:0];
    assign signal_const_407 = 9'b000000000;
    assign signal_cat_51 = { signal_const_407,
                             signal_select_129 };
    assign signal_select_130 = signal_mux_401[3:0];
    assign signal_cat_52 = { signal_const_393,
                             signal_select_130 };
    assign signal_select_131 = signal_mux_401[6:0];
    assign signal_cat_53 = { signal_const_407,
                             signal_select_131 };
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_281 <= signal_const_78;
        1:
            signal_mux_281 <= signal_cat_53;
        2:
            signal_mux_281 <= signal_const_78;
        3:
            signal_mux_281 <= signal_const_78;
        4:
            signal_mux_281 <= signal_cat_52;
        5:
            signal_mux_281 <= signal_const_78;
        6:
            signal_mux_281 <= signal_cat_51;
        7:
            signal_mux_281 <= signal_const_78;
        8:
            signal_mux_281 <= signal_const_78;
        9:
            signal_mux_281 <= signal_const_78;
        10:
            signal_mux_281 <= signal_const_78;
        11:
            signal_mux_281 <= signal_const_78;
        12:
            signal_mux_281 <= signal_const_78;
        13:
            signal_mux_281 <= signal_const_78;
        14:
            signal_mux_281 <= signal_const_78;
        15:
            signal_mux_281 <= signal_const_78;
        16:
            signal_mux_281 <= signal_const_78;
        17:
            signal_mux_281 <= signal_cat_50;
        18:
            signal_mux_281 <= signal_const_78;
        19:
            signal_mux_281 <= signal_cat_49;
        20:
            signal_mux_281 <= signal_cat_48;
        21:
            signal_mux_281 <= signal_cat_47;
        22:
            signal_mux_281 <= signal_const_78;
        23:
            signal_mux_281 <= signal_cat_46;
        24:
            signal_mux_281 <= signal_const_78;
        25:
            signal_mux_281 <= signal_const_78;
        26:
            signal_mux_281 <= signal_const_78;
        27:
            signal_mux_281 <= signal_const_78;
        28:
            signal_mux_281 <= signal_const_78;
        29:
            signal_mux_281 <= signal_const_78;
        30:
            signal_mux_281 <= signal_const_78;
        default:
            signal_mux_281 <= signal_const_78;
        endcase
    end
    assign signal_mux_282 = signal_mux_353 ? signal_mux_280 : signal_mux_281;
    assign signal_cat_54 = { gnd,
                             signal_mux_282 };
    always @* begin
        case (signal_select_158)
        0:
            signal_mux_283 <= execution$reg_r0;
        1:
            signal_mux_283 <= execution$reg_r1;
        2:
            signal_mux_283 <= execution$reg_r2;
        3:
            signal_mux_283 <= execution$reg_r3;
        4:
            signal_mux_283 <= execution$reg_r4;
        5:
            signal_mux_283 <= execution$reg_r5;
        6:
            signal_mux_283 <= execution$reg_r6;
        default:
            signal_mux_283 <= execution$reg_r7;
        endcase
    end
    assign signal_cat_55 = { gnd,
                             signal_mux_283 };
    assign signal_add_20 = signal_cat_55 + signal_cat_54;
    assign signal_select_132 = signal_add_20[15:0];
    assign signal_select_133 = signal_mux_401[10:8];
    always @* begin
        case (signal_select_133)
        0:
            signal_mux_284 <= signal_select_132;
        1:
            signal_mux_284 <= signal_sub_3;
        2:
            signal_mux_284 <= signal_and_46;
        3:
            signal_mux_284 <= signal_or_37;
        4:
            signal_mux_284 <= signal_xor_1;
        5:
            signal_mux_284 <= signal_const_78;
        6:
            signal_mux_284 <= signal_const_78;
        default:
            signal_mux_284 <= signal_const_78;
        endcase
    end
    assign signal_select_134 = signal_mux_287[15:8];
    assign signal_cat_56 = { signal_const_37,
                             signal_select_134 };
    assign signal_select_135 = signal_mux_286[15:4];
    assign signal_cat_57 = { signal_const_53,
                             signal_select_135 };
    assign signal_select_136 = signal_mux_285[15:2];
    assign signal_const_416 = 2'b00;
    assign signal_cat_58 = { signal_const_416,
                             signal_select_136 };
    assign signal_select_137 = signal_mux_289[15:1];
    assign signal_cat_59 = { signal_const_15,
                             signal_select_137 };
    assign signal_select_138 = signal_select_149[0:0];
    assign signal_mux_285 = signal_select_138 ? signal_cat_59 : signal_mux_289;
    assign signal_select_139 = signal_select_149[1:1];
    assign signal_mux_286 = signal_select_139 ? signal_cat_58 : signal_mux_285;
    assign signal_select_140 = signal_select_149[2:2];
    assign signal_mux_287 = signal_select_140 ? signal_cat_57 : signal_mux_286;
    assign signal_select_141 = signal_select_149[3:3];
    assign signal_mux_288 = signal_select_141 ? signal_cat_56 : signal_mux_287;
    assign signal_select_142 = signal_mux_292[7:0];
    assign signal_cat_60 = { signal_select_142,
                             signal_const_37 };
    assign signal_select_143 = signal_mux_291[11:0];
    assign signal_cat_61 = { signal_select_143,
                             signal_const_53 };
    assign signal_select_144 = signal_mux_290[13:0];
    assign signal_cat_62 = { signal_select_144,
                             signal_const_416 };
    assign signal_select_145 = signal_mux_289[14:0];
    assign signal_cat_63 = { signal_select_145,
                             signal_const_15 };
    always @* begin
        case (signal_select_159)
        0:
            signal_mux_289 <= execution$reg_r0;
        1:
            signal_mux_289 <= execution$reg_r1;
        2:
            signal_mux_289 <= execution$reg_r2;
        3:
            signal_mux_289 <= execution$reg_r3;
        4:
            signal_mux_289 <= execution$reg_r4;
        5:
            signal_mux_289 <= execution$reg_r5;
        6:
            signal_mux_289 <= execution$reg_r6;
        default:
            signal_mux_289 <= execution$reg_r7;
        endcase
    end
    assign signal_select_146 = signal_select_149[0:0];
    assign signal_mux_290 = signal_select_146 ? signal_cat_63 : signal_mux_289;
    assign signal_select_147 = signal_select_149[1:1];
    assign signal_mux_291 = signal_select_147 ? signal_cat_62 : signal_mux_290;
    assign signal_select_148 = signal_select_149[2:2];
    assign signal_mux_292 = signal_select_148 ? signal_cat_61 : signal_mux_291;
    assign signal_select_149 = signal_mux_401[6:3];
    assign signal_select_150 = signal_select_149[3:3];
    assign signal_mux_293 = signal_select_150 ? signal_cat_60 : signal_mux_292;
    assign signal_select_151 = signal_mux_401[10:10];
    assign signal_mux_294 = signal_select_151 ? signal_mux_288 : signal_mux_293;
    assign signal_const_422 = 16'b0000000000000001;
    assign signal_const_423 = 3'b111;
    assign signal_eq_71 = signal_mux_346 == signal_const_423;
    assign signal_mux_295 = signal_eq_71 ? signal_mux_337 : signal_mux_296;
    assign signal_mux_296 = signal_and_82 ? signal_const_78 : execution$reg_r7;
    assign signal_mux_297 = signal_or_46 ? signal_mux_295 : signal_mux_296;
    assign signal_mux_298 = signal_not_74 ? execution$reg_r7 : signal_mux_297;
    assign signal_mux_299 = signal_wire_80 ? signal_const_78 : signal_mux_298;
    assign signal_wire_43 = signal_mux_299;
    always @(posedge signal_wire_62) begin
        execution$reg_r7 <= signal_wire_43;
    end
    assign signal_eq_72 = signal_mux_346 == signal_const_75;
    assign signal_mux_300 = signal_eq_72 ? signal_mux_337 : signal_mux_301;
    assign signal_mux_301 = signal_and_82 ? signal_const_78 : execution$reg_r6;
    assign signal_mux_302 = signal_or_46 ? signal_mux_300 : signal_mux_301;
    assign signal_mux_303 = signal_not_74 ? execution$reg_r6 : signal_mux_302;
    assign signal_mux_304 = signal_wire_80 ? signal_const_78 : signal_mux_303;
    assign signal_wire_44 = signal_mux_304;
    always @(posedge signal_wire_62) begin
        execution$reg_r6 <= signal_wire_44;
    end
    assign signal_eq_73 = signal_mux_346 == signal_const_34;
    assign signal_mux_305 = signal_eq_73 ? signal_mux_337 : signal_mux_306;
    assign signal_mux_306 = signal_and_82 ? signal_const_78 : execution$reg_r5;
    assign signal_mux_307 = signal_or_46 ? signal_mux_305 : signal_mux_306;
    assign signal_mux_308 = signal_not_74 ? execution$reg_r5 : signal_mux_307;
    assign signal_mux_309 = signal_wire_80 ? signal_const_78 : signal_mux_308;
    assign signal_wire_45 = signal_mux_309;
    always @(posedge signal_wire_62) begin
        execution$reg_r5 <= signal_wire_45;
    end
    assign signal_eq_74 = signal_mux_346 == signal_const_33;
    assign signal_mux_310 = signal_eq_74 ? signal_mux_337 : signal_mux_311;
    assign signal_mux_311 = signal_and_82 ? signal_const_78 : execution$reg_r4;
    assign signal_mux_312 = signal_or_46 ? signal_mux_310 : signal_mux_311;
    assign signal_mux_313 = signal_not_74 ? execution$reg_r4 : signal_mux_312;
    assign signal_mux_314 = signal_wire_80 ? signal_const_78 : signal_mux_313;
    assign signal_wire_46 = signal_mux_314;
    always @(posedge signal_wire_62) begin
        execution$reg_r4 <= signal_wire_46;
    end
    assign signal_eq_75 = signal_mux_346 == signal_const_32;
    assign signal_mux_315 = signal_eq_75 ? signal_mux_337 : signal_mux_316;
    assign signal_mux_316 = signal_and_82 ? signal_const_78 : execution$reg_r3;
    assign signal_mux_317 = signal_or_46 ? signal_mux_315 : signal_mux_316;
    assign signal_mux_318 = signal_not_74 ? execution$reg_r3 : signal_mux_317;
    assign signal_mux_319 = signal_wire_80 ? signal_const_78 : signal_mux_318;
    assign signal_wire_47 = signal_mux_319;
    always @(posedge signal_wire_62) begin
        execution$reg_r3 <= signal_wire_47;
    end
    assign signal_eq_76 = signal_mux_346 == signal_const_31;
    assign signal_mux_320 = signal_eq_76 ? signal_mux_337 : signal_mux_321;
    assign signal_mux_321 = signal_and_82 ? signal_const_78 : execution$reg_r2;
    assign signal_mux_322 = signal_or_46 ? signal_mux_320 : signal_mux_321;
    assign signal_mux_323 = signal_not_74 ? execution$reg_r2 : signal_mux_322;
    assign signal_mux_324 = signal_wire_80 ? signal_const_78 : signal_mux_323;
    assign signal_wire_48 = signal_mux_324;
    always @(posedge signal_wire_62) begin
        execution$reg_r2 <= signal_wire_48;
    end
    assign signal_eq_77 = signal_mux_346 == signal_const_30;
    assign signal_mux_325 = signal_eq_77 ? signal_mux_337 : signal_mux_326;
    assign signal_mux_326 = signal_and_82 ? signal_const_78 : execution$reg_r1;
    assign signal_mux_327 = signal_or_46 ? signal_mux_325 : signal_mux_326;
    assign signal_mux_328 = signal_not_74 ? execution$reg_r1 : signal_mux_327;
    assign signal_mux_329 = signal_wire_80 ? signal_const_78 : signal_mux_328;
    assign signal_wire_49 = signal_mux_329;
    always @(posedge signal_wire_62) begin
        execution$reg_r1 <= signal_wire_49;
    end
    always @* begin
        case (signal_select_160)
        0:
            signal_mux_330 <= execution$reg_r0;
        1:
            signal_mux_330 <= execution$reg_r1;
        2:
            signal_mux_330 <= execution$reg_r2;
        3:
            signal_mux_330 <= execution$reg_r3;
        4:
            signal_mux_330 <= execution$reg_r4;
        5:
            signal_mux_330 <= execution$reg_r5;
        6:
            signal_mux_330 <= execution$reg_r6;
        default:
            signal_mux_330 <= execution$reg_r7;
        endcase
    end
    assign signal_sub_4 = signal_mux_330 - signal_const_422;
    assign signal_add_21 = execution$reg_pc + signal_const_249;
    assign signal_select_152 = signal_add_21[15:0];
    assign signal_eq_78 = signal_select_173 == signal_const_286;
    assign signal_mux_331 = signal_eq_78 ? signal_sub_4 : signal_select_152;
    assign signal_eq_79 = signal_select_173 == signal_const_289;
    assign signal_mux_332 = signal_eq_79 ? signal_mux_294 : signal_mux_331;
    assign signal_eq_80 = signal_select_173 == signal_const_292;
    assign signal_mux_333 = signal_eq_80 ? signal_mux_284 : signal_mux_332;
    assign signal_eq_81 = signal_select_173 == signal_const_293;
    assign signal_mux_334 = signal_eq_81 ? signal_mux_275 : signal_mux_333;
    assign signal_eq_82 = signal_select_173 == signal_const_294;
    assign signal_mux_335 = signal_eq_82 ? signal_mux_272 : signal_mux_334;
    assign signal_eq_83 = signal_select_173 == signal_const_295;
    assign signal_mux_336 = signal_eq_83 ? signal_mux_282 : signal_mux_335;
    assign signal_mux_337 = signal_and_50 ? signal_wire_41 : signal_mux_336;
    assign signal_select_153 = signal_mux_401[10:8];
    assign signal_select_154 = signal_mux_401[10:8];
    assign signal_select_155 = signal_mux_401[8:6];
    assign signal_const_445 = 5'b01001;
    assign signal_eq_84 = signal_select_173 == signal_const_445;
    assign signal_mux_338 = signal_eq_84 ? signal_select_154 : signal_select_155;
    assign signal_const_446 = 5'b01000;
    assign signal_eq_85 = signal_select_173 == signal_const_446;
    assign signal_mux_339 = signal_eq_85 ? signal_select_153 : signal_mux_338;
    assign signal_select_156 = signal_mux_401[10:8];
    assign signal_select_157 = signal_mux_401[7:5];
    assign signal_select_158 = signal_mux_401[7:5];
    assign signal_select_159 = signal_mux_401[9:7];
    assign signal_select_160 = signal_mux_401[10:8];
    assign signal_select_161 = signal_mux_401[10:8];
    assign signal_select_162 = signal_mux_401[10:8];
    assign signal_eq_86 = signal_select_173 == signal_const_285;
    assign signal_mux_340 = signal_eq_86 ? signal_select_161 : signal_select_162;
    assign signal_eq_87 = signal_select_173 == signal_const_286;
    assign signal_mux_341 = signal_eq_87 ? signal_select_160 : signal_mux_340;
    assign signal_eq_88 = signal_select_173 == signal_const_289;
    assign signal_mux_342 = signal_eq_88 ? signal_select_159 : signal_mux_341;
    assign signal_eq_89 = signal_select_173 == signal_const_292;
    assign signal_mux_343 = signal_eq_89 ? signal_select_158 : signal_mux_342;
    assign signal_eq_90 = signal_select_173 == signal_const_293;
    assign signal_mux_344 = signal_eq_90 ? signal_select_157 : signal_mux_343;
    assign signal_eq_91 = signal_select_173 == signal_const_294;
    assign signal_mux_345 = signal_eq_91 ? signal_select_156 : signal_mux_344;
    assign signal_mux_346 = signal_and_50 ? signal_mux_339 : signal_mux_345;
    assign signal_eq_92 = signal_mux_346 == signal_const_35;
    assign signal_mux_347 = signal_eq_92 ? signal_mux_337 : signal_mux_348;
    assign signal_mux_348 = signal_and_82 ? signal_const_78 : execution$reg_r0;
    assign signal_const_454 = 5'b11010;
    assign signal_eq_93 = signal_select_173 == signal_const_454;
    assign signal_eq_94 = signal_select_173 == signal_const_445;
    assign signal_eq_95 = signal_select_173 == signal_const_446;
    assign signal_or_38 = signal_eq_95 | signal_eq_94;
    assign signal_or_39 = signal_or_38 | signal_eq_93;
    assign signal_and_50 = signal_and_90 & signal_or_39;
    assign signal_eq_96 = signal_select_173 == signal_const_285;
    assign signal_eq_97 = signal_select_173 == signal_const_286;
    assign signal_eq_98 = signal_select_173 == signal_const_289;
    assign signal_eq_99 = signal_select_173 == signal_const_292;
    assign signal_eq_100 = signal_select_173 == signal_const_293;
    assign signal_eq_101 = signal_select_173 == signal_const_294;
    assign signal_eq_102 = signal_select_173 == signal_const_295;
    assign signal_or_40 = signal_eq_102 | signal_eq_101;
    assign signal_or_41 = signal_or_40 | signal_eq_100;
    assign signal_or_42 = signal_or_41 | signal_eq_99;
    assign signal_or_43 = signal_or_42 | signal_eq_98;
    assign signal_or_44 = signal_or_43 | signal_eq_97;
    assign signal_or_45 = signal_or_44 | signal_eq_96;
    assign signal_and_51 = signal_and_101 & signal_or_45;
    assign signal_or_46 = signal_and_51 | signal_and_50;
    assign signal_mux_349 = signal_or_46 ? signal_mux_347 : signal_mux_348;
    assign signal_mux_350 = signal_not_74 ? execution$reg_r0 : signal_mux_349;
    assign signal_mux_351 = signal_wire_80 ? signal_const_78 : signal_mux_350;
    assign signal_wire_50 = signal_mux_351;
    always @(posedge signal_wire_62) begin
        execution$reg_r0 <= signal_wire_50;
    end
    assign signal_select_163 = signal_mux_401[10:8];
    always @* begin
        case (signal_select_163)
        0:
            signal_mux_352 <= execution$reg_r0;
        1:
            signal_mux_352 <= execution$reg_r1;
        2:
            signal_mux_352 <= execution$reg_r2;
        3:
            signal_mux_352 <= execution$reg_r3;
        4:
            signal_mux_352 <= execution$reg_r4;
        5:
            signal_mux_352 <= execution$reg_r5;
        6:
            signal_mux_352 <= execution$reg_r6;
        default:
            signal_mux_352 <= execution$reg_r7;
        endcase
    end
    assign signal_cat_64 = { gnd,
                             signal_mux_352 };
    assign signal_const_464 = 17'b00000000000000010;
    assign signal_select_164 = signal_mux_401[6:6];
    assign signal_select_165 = signal_mux_401[10:10];
    assign signal_select_166 = signal_mux_401[4:4];
    assign signal_select_167 = signal_mux_401[5:5];
    assign signal_select_168 = signal_mux_401[10:10];
    assign vdd = 1'b1;
    assign signal_select_169 = signal_mux_401[7:7];
    assign signal_select_170 = signal_mux_401[4:4];
    assign signal_select_171 = signal_mux_401[7:7];
    assign gnd = 1'b0;
    always @* begin
        case (signal_select_173)
        0:
            signal_mux_353 <= gnd;
        1:
            signal_mux_353 <= signal_select_171;
        2:
            signal_mux_353 <= gnd;
        3:
            signal_mux_353 <= gnd;
        4:
            signal_mux_353 <= signal_select_170;
        5:
            signal_mux_353 <= gnd;
        6:
            signal_mux_353 <= signal_select_169;
        7:
            signal_mux_353 <= gnd;
        8:
            signal_mux_353 <= gnd;
        9:
            signal_mux_353 <= gnd;
        10:
            signal_mux_353 <= gnd;
        11:
            signal_mux_353 <= gnd;
        12:
            signal_mux_353 <= gnd;
        13:
            signal_mux_353 <= gnd;
        14:
            signal_mux_353 <= gnd;
        15:
            signal_mux_353 <= vdd;
        16:
            signal_mux_353 <= gnd;
        17:
            signal_mux_353 <= signal_select_168;
        18:
            signal_mux_353 <= gnd;
        19:
            signal_mux_353 <= signal_select_167;
        20:
            signal_mux_353 <= signal_select_166;
        21:
            signal_mux_353 <= signal_select_165;
        22:
            signal_mux_353 <= gnd;
        23:
            signal_mux_353 <= signal_select_164;
        24:
            signal_mux_353 <= gnd;
        25:
            signal_mux_353 <= gnd;
        26:
            signal_mux_353 <= gnd;
        27:
            signal_mux_353 <= gnd;
        28:
            signal_mux_353 <= gnd;
        29:
            signal_mux_353 <= gnd;
        30:
            signal_mux_353 <= gnd;
        default:
            signal_mux_353 <= gnd;
        endcase
    end
    assign signal_mux_354 = signal_mux_353 ? signal_const_464 : signal_const_249;
    assign signal_add_22 = execution$reg_pc + signal_mux_354;
    assign signal_eq_103 = signal_select_173 == signal_const_284;
    assign signal_mux_355 = signal_eq_103 ? signal_cat_64 : signal_add_22;
    assign signal_eq_104 = signal_select_173 == signal_const_285;
    assign signal_mux_356 = signal_eq_104 ? signal_add_18 : signal_mux_355;
    assign signal_eq_105 = signal_select_173 == signal_const_286;
    assign signal_mux_357 = signal_eq_105 ? signal_mux_271 : signal_mux_356;
    assign signal_eq_106 = signal_select_173 == signal_const_287;
    assign signal_mux_358 = signal_eq_106 ? signal_mux_270 : signal_mux_357;
    assign signal_eq_107 = signal_select_173 == signal_const_288;
    assign signal_mux_359 = signal_eq_107 ? signal_add_12 : signal_mux_358;
    assign signal_not_55 = ~ signal_reg_9;
    assign signal_mux_360 = signal_and_67 ? signal_const_15 : signal_reg_14;
    assign signal_not_56 = ~ signal_reg_9;
    assign signal_not_57 = ~ signal_reg_8;
    assign signal_const_477 = 9'b000000001;
    assign signal_add_23 = signal_reg_10 + signal_const_477;
    assign signal_mux_361 = signal_eq_109 ? signal_add_23 : signal_reg_10;
    assign signal_mux_362 = signal_reg_7 ? signal_mux_361 : signal_reg_10;
    assign signal_not_58 = ~ signal_wire_78;
    assign signal_not_59 = ~ signal_wire_80;
    assign signal_not_60 = ~ signal_and_67;
    assign signal_mux_363 = signal_and_64 ? signal_const_15 : signal_reg_9;
    assign signal_mux_364 = signal_wire_78 ? signal_const_15 : signal_mux_363;
    assign signal_mux_365 = signal_and_67 ? signal_const_15 : signal_mux_364;
    assign signal_lt_13 = signal_wire_56 < signal_reg_11;
    assign signal_eq_108 = signal_wire_56 == signal_reg_10;
    assign signal_wire_51 = readback_expected_i;
    assign signal_mux_366 = signal_and_60 ? signal_wire_51 : signal_reg_6;
    assign signal_mux_367 = signal_not_78 ? signal_reg_6 : signal_mux_366;
    assign signal_wire_52 = signal_mux_367;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_6 <= signal_const_78;
        else
            signal_reg_6 <= signal_wire_52;
    end
    assign signal_wire_53 = prog_mem_read_data_i;
    assign signal_eq_109 = signal_wire_53 == signal_reg_6;
    assign signal_mux_368 = signal_eq_109 ? signal_reg_8 : signal_const_14;
    assign signal_mux_369 = signal_and_60 ? signal_wire_57 : signal_reg_7;
    assign signal_mux_370 = signal_not_78 ? signal_reg_7 : signal_mux_369;
    assign signal_wire_54 = signal_mux_370;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_7 <= signal_const_15;
        else
            signal_reg_7 <= signal_wire_54;
    end
    assign signal_mux_371 = signal_reg_7 ? signal_mux_368 : signal_reg_8;
    assign signal_mux_372 = signal_and_64 ? signal_mux_371 : signal_reg_8;
    assign signal_mux_373 = signal_and_67 ? signal_const_15 : signal_mux_372;
    assign signal_mux_374 = signal_not_78 ? signal_reg_8 : signal_mux_373;
    assign signal_wire_55 = signal_mux_374;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_8 <= signal_const_15;
        else
            signal_reg_8 <= signal_wire_55;
    end
    assign signal_not_61 = ~ signal_reg_8;
    assign signal_eq_110 = signal_reg_12 == signal_reg_11;
    assign signal_and_52 = signal_reg_13 & signal_eq_110;
    assign signal_and_53 = signal_and_52 & signal_not_61;
    assign signal_and_54 = signal_and_53 & signal_eq_108;
    assign signal_and_55 = signal_and_54 & signal_lt_13;
    assign signal_mux_375 = signal_reg_13 ? signal_reg_12 : signal_reg_11;
    assign signal_wire_56 = readback_address_i;
    assign signal_lt_14 = signal_wire_56 < signal_mux_375;
    assign signal_or_47 = signal_reg_13 | signal_reg_14;
    assign signal_and_56 = signal_or_47 & signal_lt_14;
    assign signal_wire_57 = readback_verify_i;
    assign signal_mux_376 = signal_wire_57 ? signal_and_55 : signal_and_56;
    assign signal_not_62 = ~ signal_reg_9;
    assign signal_and_57 = signal_and_114 & signal_and_75;
    assign signal_and_58 = signal_and_57 & signal_wire_68;
    assign signal_and_59 = signal_and_58 & signal_not_62;
    assign signal_and_60 = signal_and_59 & signal_mux_376;
    assign signal_mux_377 = signal_and_60 ? signal_const_14 : signal_mux_365;
    assign signal_mux_378 = signal_not_78 ? signal_const_15 : signal_mux_377;
    assign signal_wire_58 = signal_mux_378;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_9 <= signal_const_15;
        else
            signal_reg_9 <= signal_wire_58;
    end
    assign signal_and_61 = signal_wire_82 & signal_reg_9;
    assign signal_and_62 = signal_and_61 & signal_not_60;
    assign signal_and_63 = signal_and_62 & signal_not_59;
    assign signal_and_64 = signal_and_63 & signal_not_58;
    assign signal_mux_379 = signal_and_64 ? signal_mux_362 : signal_reg_10;
    assign signal_mux_380 = signal_and_67 ? signal_const_407 : signal_mux_379;
    assign signal_mux_381 = signal_not_78 ? signal_reg_10 : signal_mux_380;
    assign signal_wire_59 = signal_mux_381;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_10 <= signal_const_407;
        else
            signal_reg_10 <= signal_wire_59;
    end
    assign signal_eq_111 = signal_reg_10 == signal_reg_11;
    assign signal_mux_382 = signal_and_67 ? signal_wire_63 : signal_reg_11;
    assign signal_mux_383 = signal_not_78 ? signal_reg_11 : signal_mux_382;
    assign signal_wire_60 = signal_mux_383;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_11 <= signal_const_407;
        else
            signal_reg_11 <= signal_wire_60;
    end
    assign signal_add_24 = signal_reg_12 + signal_const_477;
    assign signal_mux_384 = signal_and_67 ? signal_const_407 : signal_reg_12;
    assign signal_mux_385 = signal_and_119 ? signal_add_24 : signal_mux_384;
    assign signal_mux_386 = signal_not_78 ? signal_reg_12 : signal_mux_385;
    assign signal_wire_61 = signal_mux_386;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_12 <= signal_const_407;
        else
            signal_reg_12 <= signal_wire_61;
    end
    assign signal_eq_112 = signal_reg_12 == signal_reg_11;
    assign signal_wire_62 = clock_i;
    assign signal_lt_15 = signal_const_248 < signal_wire_63;
    assign signal_not_63 = ~ signal_lt_15;
    assign signal_wire_63 = load_length_i;
    assign signal_lt_16 = signal_const_407 < signal_wire_63;
    assign signal_and_65 = signal_lt_16 & signal_not_63;
    assign signal_and_66 = signal_and_114 & signal_wire_70;
    assign signal_and_67 = signal_and_66 & signal_and_65;
    assign signal_mux_387 = signal_and_67 ? signal_const_14 : signal_reg_13;
    assign signal_mux_388 = signal_and_74 ? signal_const_15 : signal_mux_387;
    assign signal_mux_389 = signal_not_78 ? signal_const_15 : signal_mux_388;
    assign signal_wire_64 = signal_mux_389;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_13 <= signal_const_15;
        else
            signal_reg_13 <= signal_wire_64;
    end
    assign signal_and_68 = signal_and_114 & signal_and_76;
    assign signal_and_69 = signal_and_68 & signal_wire_67;
    assign signal_and_70 = signal_and_69 & signal_reg_13;
    assign signal_and_71 = signal_and_70 & signal_eq_112;
    assign signal_and_72 = signal_and_71 & signal_eq_111;
    assign signal_and_73 = signal_and_72 & signal_not_57;
    assign signal_and_74 = signal_and_73 & signal_not_56;
    assign signal_mux_390 = signal_and_74 ? signal_const_14 : signal_mux_360;
    assign signal_mux_391 = signal_not_78 ? signal_reg_14 : signal_mux_390;
    assign signal_wire_65 = signal_mux_391;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_14 <= signal_const_15;
        else
            signal_reg_14 <= signal_wire_65;
    end
    assign signal_wire_66 = run_valid_i;
    assign signal_not_64 = ~ signal_wire_78;
    assign signal_wire_67 = load_complete_valid_i;
    assign signal_not_65 = ~ signal_wire_67;
    assign signal_wire_68 = readback_valid_i;
    assign signal_not_66 = ~ signal_wire_68;
    assign signal_wire_69 = load_write_valid_i;
    assign signal_not_67 = ~ signal_wire_69;
    assign signal_wire_70 = load_start_valid_i;
    assign signal_not_68 = ~ signal_wire_70;
    assign signal_and_75 = signal_not_68 & signal_not_67;
    assign signal_and_76 = signal_and_75 & signal_not_66;
    assign signal_and_77 = signal_and_76 & signal_not_65;
    assign signal_and_78 = signal_and_114 & signal_and_77;
    assign signal_and_79 = signal_and_78 & signal_not_64;
    assign signal_and_80 = signal_and_79 & signal_wire_66;
    assign signal_and_81 = signal_and_80 & signal_reg_14;
    assign signal_and_82 = signal_and_81 & signal_not_55;
    assign signal_mux_392 = signal_and_82 ? signal_const_41 : execution$reg_pc;
    assign signal_eq_113 = signal_select_173 == signal_const_29;
    assign signal_not_69 = ~ signal_eq_113;
    assign signal_and_83 = signal_and_101 & signal_not_69;
    assign signal_mux_393 = signal_and_83 ? signal_mux_359 : signal_mux_392;
    assign signal_wire_71 = mechanism_completion_fault_i;
    assign signal_not_70 = ~ signal_wire_71;
    assign signal_eq_114 = execution$reg_phase == signal_const_34;
    assign signal_not_71 = ~ signal_wire_80;
    assign signal_and_84 = signal_wire_82 & signal_not_71;
    assign signal_and_85 = signal_and_84 & signal_eq_114;
    assign signal_and_86 = signal_and_85 & signal_wire_72;
    assign signal_wire_72 = mechanism_completion_valid_i;
    assign signal_wire_73 = mechanism_refused_i;
    assign signal_not_72 = ~ signal_wire_73;
    assign signal_wire_74 = mechanism_accepted_i;
    assign signal_and_87 = signal_and_94 & signal_wire_74;
    assign signal_and_88 = signal_and_87 & signal_not_72;
    assign signal_and_89 = signal_and_88 & signal_wire_72;
    assign signal_or_48 = signal_and_89 | signal_and_86;
    assign signal_and_90 = signal_or_48 & signal_not_70;
    assign signal_mux_394 = signal_and_90 ? signal_mux_240 : signal_mux_393;
    assign signal_mux_395 = signal_not_74 ? execution$reg_pc : signal_mux_394;
    assign signal_mux_396 = signal_wire_80 ? signal_const_41 : signal_mux_395;
    assign signal_wire_75 = signal_mux_396;
    always @(posedge signal_wire_62) begin
        execution$reg_pc <= signal_wire_75;
    end
    assign signal_select_172 = execution$reg_pc[16:9];
    assign signal_eq_115 = signal_select_172 == signal_const_37;
    assign signal_eq_116 = execution$reg_phase == signal_const_30;
    assign signal_and_91 = signal_eq_116 & signal_eq_115;
    assign signal_or_49 = signal_and_91 | signal_and_42;
    assign signal_and_92 = signal_or_49 & signal_and_105;
    assign signal_mux_397 = signal_and_92 ? signal_mux_230 : signal_mux_231;
    assign signal_mux_398 = signal_and_97 ? signal_wire_53 : signal_mux_397;
    assign signal_mux_399 = signal_not_74 ? execution$reg_base_word : signal_mux_398;
    assign signal_mux_400 = signal_wire_80 ? signal_const_78 : signal_mux_399;
    assign signal_wire_76 = signal_mux_400;
    always @(posedge signal_wire_62) begin
        execution$reg_base_word <= signal_wire_76;
    end
    assign signal_mux_401 = signal_eq_118 ? signal_wire_53 : execution$reg_base_word;
    assign signal_select_173 = signal_mux_401[15:11];
    assign signal_eq_117 = signal_select_173 == signal_const_29;
    assign signal_or_50 = signal_eq_117 | signal_eq_35;
    assign signal_or_51 = signal_or_50 | signal_eq_34;
    assign signal_or_52 = signal_or_51 | signal_eq_33;
    assign signal_or_53 = signal_or_52 | signal_eq_32;
    assign signal_or_54 = signal_or_53 | signal_eq_31;
    assign signal_or_55 = signal_or_54 | signal_eq_30;
    assign signal_or_56 = signal_or_55 | signal_eq_29;
    assign signal_or_57 = signal_or_56 | signal_eq_28;
    assign signal_or_58 = signal_or_57 | signal_eq_27;
    assign signal_or_59 = signal_or_58 | signal_eq_26;
    assign signal_or_60 = signal_or_59 | signal_eq_25;
    assign signal_or_61 = signal_or_60 | signal_eq_24;
    assign signal_or_62 = signal_or_61 | signal_eq_23;
    assign signal_not_73 = ~ signal_or_62;
    assign signal_and_93 = signal_or_64 & signal_not_73;
    assign signal_or_63 = signal_and_93 | signal_eq_22;
    assign signal_and_94 = signal_or_63 & signal_and_84;
    assign signal_and_95 = signal_and_94 & signal_wire_74;
    assign signal_and_96 = signal_and_95 & signal_wire_73;
    assign signal_mux_402 = signal_and_96 ? signal_const_75 : signal_mux_229;
    assign signal_not_74 = ~ signal_wire_82;
    assign signal_mux_403 = signal_not_74 ? signal_const_35 : signal_mux_402;
    assign signal_mux_404 = signal_wire_80 ? signal_const_35 : signal_mux_403;
    assign signal_wire_77 = signal_mux_404;
    always @(posedge signal_wire_62) begin
        execution$reg_phase <= signal_wire_77;
    end
    assign signal_eq_118 = execution$reg_phase == signal_const_31;
    assign signal_and_97 = signal_eq_118 & signal_and_48;
    assign signal_and_98 = signal_and_97 & signal_and_40;
    assign signal_and_99 = signal_and_98 & signal_not_22;
    assign signal_or_64 = signal_and_99 | signal_and_15;
    assign signal_and_100 = signal_or_64 & signal_or_62;
    assign signal_and_101 = signal_and_100 & signal_not_21;
    assign signal_and_102 = signal_and_101 & signal_eq_15;
    assign signal_or_65 = signal_and_102 | signal_or_14;
    assign signal_wire_78 = signal_or_65;
    assign signal_not_75 = ~ signal_wire_78;
    assign signal_and_103 = signal_and_108 & signal_not_75;
    assign signal_and_104 = signal_and_103 & signal_wire_36;
    assign signal_and_105 = signal_and_104 & signal_and_14;
    assign signal_mux_405 = signal_and_105 ? signal_const_14 : signal_mux_205;
    assign signal_mux_406 = signal_not_78 ? signal_const_15 : signal_mux_405;
    assign signal_wire_79 = signal_mux_406;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_15 <= signal_const_15;
        else
            signal_reg_15 <= signal_wire_79;
    end
    assign signal_not_76 = ~ signal_reg_15;
    assign signal_or_66 = signal_not_76 | signal_and_48;
    assign signal_wire_80 = reset_i;
    assign signal_not_77 = ~ signal_wire_80;
    assign signal_and_106 = signal_wire_82 & signal_reg_16;
    assign signal_and_107 = signal_and_106 & signal_not_77;
    assign signal_and_108 = signal_and_107 & signal_or_66;
    assign signal_and_109 = signal_and_108 & signal_wire_36;
    assign signal_and_110 = signal_and_109 & signal_not_19;
    assign signal_mux_407 = signal_and_110 ? signal_const_15 : signal_mux_202;
    assign signal_not_78 = ~ signal_wire_82;
    assign signal_mux_408 = signal_not_78 ? signal_const_15 : signal_mux_407;
    assign signal_wire_81 = signal_mux_408;
    always @(posedge signal_wire_62) begin
        if (signal_wire_80)
            signal_reg_16 <= signal_const_15;
        else
            signal_reg_16 <= signal_wire_81;
    end
    assign signal_not_79 = ~ signal_reg_16;
    assign signal_wire_82 = en_i;
    assign signal_and_111 = signal_wire_82 & signal_not_79;
    assign signal_and_112 = signal_and_111 & signal_wire_34;
    assign signal_and_113 = signal_and_112 & signal_not_18;
    assign signal_and_114 = signal_and_113 & signal_not_17;
    assign signal_and_115 = signal_and_114 & signal_not_68;
    assign signal_and_116 = signal_and_115 & signal_wire_69;
    assign signal_and_117 = signal_and_116 & signal_reg_13;
    assign signal_and_118 = signal_and_117 & signal_eq_14;
    assign signal_and_119 = signal_and_118 & signal_lt;
    assign signal_or_67 = signal_and_119 | signal_or_6;
    assign signal_and_120 = signal_or_67 & signal_not_16;
    assign prog_mem_enable_o = signal_and_120;
    assign prog_mem_write_enable_o = signal_and_12;
    assign prog_mem_address_o = signal_select_31;
    assign prog_mem_write_data_o = signal_wire_32;
    assign load_start_accepted_o = signal_and_67;
    assign load_start_rejected_o = signal_and_11;
    assign load_write_accepted_o = signal_and_119;
    assign load_write_rejected_o = signal_and_10;
    assign load_complete_accepted_o = signal_and_74;
    assign load_complete_rejected_o = signal_and_9;
    assign readback_accepted_o = signal_and_60;
    assign readback_rejected_o = signal_and_8;
    assign run_accepted_o = signal_and_82;
    assign run_rejected_o = signal_and_7;
    assign readback_response_valid_o = signal_reg_5;
    assign readback_response_data_o = signal_reg_4;
    assign readback_response_match_o = signal_reg_3;
    assign fetch_completion_valid_o = signal_and_48;
    assign fetch_completion_data_o = signal_wire_53;
    assign fetch_response_valid_o = signal_reg_2;
    assign fetch_response_data_o = signal_reg_1;
    assign halted_o = signal_not_79;
    assign image_valid_o = signal_reg_14;
    assign load_active_o = signal_reg_13;
    assign image_length_o = signal_reg_11;
    assign words_written_o = signal_reg_12;
    assign words_verified_o = signal_reg_10;
    assign verification_failed_o = signal_reg_8;
    assign fetch_fault_event_o = signal_and_110;
    assign fetch_fault_o = signal_reg;
    assign mechanism_request_valid_o = signal_and_94;
    assign mechanism_kind_o = signal_mux_180;
    assign mechanism_arg0_o = signal_mux_179;
    assign mechanism_arg1_o = signal_mux_177;
    assign mechanism_arg2_o = signal_mux_175;
    assign mechanism_timeout_enable_o = signal_mux_172;
    assign mechanism_descriptor_o = signal_cat_3;
    assign execution_active_o = signal_and_4;
    assign normal_halt_o = execution$reg_normal_halt;
    assign execution_fault_o = execution$reg_execution_fault;
    assign fault_kind_o = execution$reg_fault_kind;
    assign fault_instruction_slot_o = execution$reg_fault_instruction_slot;
    assign fault_address_o = execution$reg_fault_address;
    assign fault_reason_o = execution$reg_fault_reason;
    assign instruction_boundary_o = execution$reg_boundary;
    assign retired_o = execution$reg_retired;
    assign pc_o = execution$reg_pc;
    assign registers_o = signal_cat;
    assign zero_o = execution$reg_zero;
    assign carry_o = execution$reg_carry;
    assign negative_o = execution$reg_negative;
    assign descriptor_o = signal_cat_3;
    assign phase_o = execution$reg_phase;
    assign fetch_cycles_o = execution$reg_fetch_cycles;
    assign execute_cycles_o = execution$reg_execute_cycles;
    assign stall_cycles_o = execution$reg_stall_cycles;
    assign instruction_count_o = execution$reg_instruction_count;
    assign extension_fetches_o = execution$reg_extension_fetches;
    assign total_cycles_o = execution$reg_total_cycles;

endmodule
