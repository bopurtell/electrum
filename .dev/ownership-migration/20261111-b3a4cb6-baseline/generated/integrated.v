module integrated_core (
    clock_i,
    reset_i,
    en_i,
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
    stop_valid_i,
    abort_valid_i,
    step_valid_i,
    prog_mem_read_data_i,
    pin_async_i,
    occupied_i,
    software_claim_valid_i,
    software_claim_mask_i,
    software_release_valid_i,
    software_release_mask_i,
    tx_ready_i,
    rx_valid_i,
    rx_data_i,
    transfer_rx_ready_i,
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
    readback_response_valid_o,
    readback_response_data_o,
    readback_response_match_o,
    run_accepted_o,
    run_rejected_o,
    stop_accepted_o,
    stop_rejected_o,
    abort_accepted_o,
    abort_rejected_o,
    step_accepted_o,
    step_rejected_o,
    halted_o,
    engines_idle_o,
    image_valid_o,
    load_active_o,
    image_length_o,
    words_written_o,
    words_verified_o,
    verification_failed_o,
    fetch_fault_o,
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
    total_cycles_o,
    mechanism_request_valid_o,
    mechanism_kind_o,
    mechanism_accepted_o,
    mechanism_refused_o,
    mechanism_completion_valid_o,
    snapshot_o,
    rising_o,
    falling_o,
    status_o,
    status_overflow_o,
    pins_o,
    pin_oe_o,
    software_claim_o,
    engine_claim_o,
    software_request_rejected_o,
    bank_conflict_o,
    timing_busy_o,
    transfer_busy_o,
    transfer_done_o,
    transfer_fault_o,
    transfer_rx_valid_o,
    transfer_rx_data_o,
    tx_valid_o,
    tx_data_o,
    rx_ready_o,
    tx_count_o,
    rx_count_o
);

    input clock_i;
    input reset_i;
    input en_i;
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
    input stop_valid_i;
    input abort_valid_i;
    input step_valid_i;
    input [15:0] prog_mem_read_data_i;
    input [7:0] pin_async_i;
    input [7:0] occupied_i;
    input software_claim_valid_i;
    input [7:0] software_claim_mask_i;
    input software_release_valid_i;
    input [7:0] software_release_mask_i;
    input tx_ready_i;
    input rx_valid_i;
    input [7:0] rx_data_i;
    input transfer_rx_ready_i;
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
    output readback_response_valid_o;
    output [15:0] readback_response_data_o;
    output readback_response_match_o;
    output run_accepted_o;
    output run_rejected_o;
    output stop_accepted_o;
    output stop_rejected_o;
    output abort_accepted_o;
    output abort_rejected_o;
    output step_accepted_o;
    output step_rejected_o;
    output halted_o;
    output engines_idle_o;
    output image_valid_o;
    output load_active_o;
    output [8:0] image_length_o;
    output [8:0] words_written_o;
    output [8:0] words_verified_o;
    output verification_failed_o;
    output fetch_fault_o;
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
    output mechanism_request_valid_o;
    output [3:0] mechanism_kind_o;
    output mechanism_accepted_o;
    output mechanism_refused_o;
    output mechanism_completion_valid_o;
    output [7:0] snapshot_o;
    output [7:0] rising_o;
    output [7:0] falling_o;
    output [5:0] status_o;
    output [5:0] status_overflow_o;
    output [7:0] pins_o;
    output [7:0] pin_oe_o;
    output [7:0] software_claim_o;
    output [7:0] engine_claim_o;
    output software_request_rejected_o;
    output bank_conflict_o;
    output timing_busy_o;
    output transfer_busy_o;
    output transfer_done_o;
    output transfer_fault_o;
    output transfer_rx_valid_o;
    output [31:0] transfer_rx_data_o;
    output tx_valid_o;
    output [7:0] tx_data_o;
    output rx_ready_o;
    output [4:0] tx_count_o;
    output [4:0] rx_count_o;

    wire signal_not;
    wire signal_and;
    wire signal_not_1;
    wire signal_and_1;
    wire [31:0] signal_const;
    wire [31:0] signal_mux;
    wire signal_select;
    wire signal_select_1;
    wire signal_select_2;
    wire signal_select_3;
    wire signal_select_4;
    wire signal_select_5;
    wire signal_select_6;
    wire signal_select_7;
    wire [2:0] signal_const_4;
    wire [2:0] signal_mux_1;
    wire [2:0] signal_mux_2;
    wire [2:0] signal_mux_3;
    wire [2:0] signal_wire;
    reg [2:0] mechanisms$lane$reg_input_pin;
    reg signal_mux_4;
    wire [31:0] signal_mux_5;
    wire [31:0] signal_const_5;
    wire [31:0] signal_const_6;
    wire [31:0] signal_const_7;
    wire [31:0] signal_const_8;
    wire [31:0] signal_const_9;
    wire [31:0] signal_const_10;
    wire [31:0] signal_const_11;
    wire [31:0] signal_const_12;
    wire [31:0] signal_const_13;
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
    reg [31:0] signal_mux_6;
    wire [31:0] signal_not_2;
    wire [31:0] signal_and_2;
    wire [31:0] signal_or;
    wire [31:0] signal_mux_7;
    wire [31:0] signal_mux_8;
    wire [31:0] signal_mux_9;
    wire [31:0] signal_mux_10;
    wire [31:0] signal_mux_11;
    wire [31:0] signal_wire_1;
    reg [31:0] mechanisms$lane$reg_rx_value;
    wire signal_const_37;
    wire signal_mux_12;
    wire signal_mux_13;
    wire signal_mux_14;
    wire signal_wire_2;
    reg mechanisms$lane$reg_sample_trailing;
    wire signal_eq;
    wire [31:0] signal_mux_15;
    wire [31:0] signal_mux_16;
    wire [31:0] signal_mux_17;
    wire [31:0] signal_mux_18;
    wire [31:0] signal_mux_19;
    wire [31:0] signal_mux_20;
    wire [31:0] signal_mux_21;
    wire [31:0] signal_mux_22;
    wire [31:0] signal_wire_3;
    reg [31:0] mechanisms$lane$reg_rx_data;
    wire signal_const_39;
    wire signal_mux_23;
    wire signal_mux_24;
    wire signal_mux_25;
    wire signal_mux_26;
    wire signal_mux_27;
    wire signal_mux_28;
    wire signal_mux_29;
    wire signal_wire_4;
    reg mechanisms$lane$reg_rx_valid;
    wire signal_not_3;
    wire signal_or_1;
    wire signal_or_2;
    wire signal_and_3;
    wire signal_and_4;
    wire signal_or_3;
    wire signal_mux_30;
    wire signal_mux_31;
    wire signal_mux_32;
    wire signal_wire_5;
    reg mechanisms$bank$reg_conflict;
    wire signal_and_5;
    wire [7:0] signal_const_43;
    wire [7:0] signal_not_4;
    wire [7:0] signal_and_6;
    wire signal_eq_1;
    wire signal_not_5;
    wire signal_and_7;
    wire [7:0] signal_and_8;
    wire signal_eq_2;
    wire signal_not_6;
    wire signal_and_9;
    wire signal_or_4;
    wire signal_or_5;
    wire signal_and_10;
    wire signal_not_7;
    wire signal_or_6;
    wire signal_and_11;
    wire signal_or_7;
    wire [7:0] signal_mux_33;
    wire [7:0] signal_mux_34;
    wire [7:0] signal_mux_35;
    wire [7:0] signal_mux_36;
    wire [7:0] signal_mux_37;
    wire [7:0] signal_mux_38;
    wire [7:0] signal_wire_6;
    reg [7:0] mechanisms$lane$reg_pin_oe;
    wire [7:0] signal_select_8;
    wire [7:0] signal_and_12;
    wire signal_select_9;
    wire [7:0] signal_mux_39;
    wire [7:0] signal_mux_40;
    wire [7:0] signal_mux_41;
    wire [7:0] signal_and_13;
    wire [7:0] signal_not_8;
    wire [7:0] signal_and_14;
    wire [7:0] signal_or_8;
    wire [7:0] signal_mux_42;
    wire [7:0] signal_mux_43;
    wire [7:0] signal_mux_44;
    wire [7:0] signal_wire_7;
    reg [7:0] mechanisms$bank$reg_pin_oe;
    wire signal_and_15;
    wire [7:0] signal_mux_45;
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
    wire signal_select_39;
    wire signal_select_40;
    wire signal_select_41;
    wire [5:0] signal_const_58;
    wire [5:0] signal_const_59;
    wire [5:0] signal_sub;
    wire [5:0] signal_mux_46;
    reg signal_mux_47;
    wire [7:0] signal_mux_48;
    wire signal_select_42;
    wire [7:0] signal_mux_49;
    wire [7:0] signal_mux_50;
    wire [7:0] signal_mux_51;
    wire [7:0] signal_or_9;
    wire [7:0] signal_mux_52;
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
    wire signal_select_72;
    wire signal_select_73;
    wire [31:0] signal_mux_53;
    wire [31:0] signal_mux_54;
    wire [31:0] signal_mux_55;
    wire [31:0] signal_wire_8;
    reg [31:0] mechanisms$lane$reg_tx_value;
    wire signal_select_74;
    wire [5:0] signal_add;
    wire [5:0] signal_const_65;
    wire [5:0] signal_sub_1;
    wire [5:0] signal_sub_2;
    wire [5:0] signal_mux_56;
    wire [5:0] signal_sub_3;
    wire [5:0] signal_sub_4;
    wire signal_select_75;
    wire signal_not_9;
    wire signal_mux_57;
    wire signal_mux_58;
    wire signal_mux_59;
    wire signal_wire_9;
    reg mechanisms$lane$reg_lsb_first;
    wire [5:0] signal_mux_60;
    wire [5:0] signal_mux_61;
    reg signal_mux_62;
    wire [7:0] signal_mux_63;
    wire [7:0] signal_const_68;
    wire [7:0] signal_const_69;
    wire [7:0] signal_const_70;
    wire [7:0] signal_const_71;
    wire [7:0] signal_const_72;
    wire [7:0] signal_const_73;
    wire [7:0] signal_const_74;
    wire [7:0] signal_const_75;
    wire [2:0] signal_mux_64;
    wire [2:0] signal_mux_65;
    wire [2:0] signal_mux_66;
    wire [2:0] signal_wire_10;
    reg [2:0] mechanisms$lane$reg_output_pin;
    reg [7:0] signal_mux_67;
    wire [7:0] signal_not_10;
    wire [7:0] signal_and_16;
    wire [7:0] signal_or_10;
    wire [2:0] signal_mux_68;
    wire [2:0] signal_mux_69;
    wire [2:0] signal_mux_70;
    wire [2:0] signal_wire_11;
    reg [2:0] mechanisms$lane$reg_clock_pin;
    reg [7:0] signal_mux_71;
    wire [7:0] signal_xor;
    wire signal_mux_72;
    wire signal_mux_73;
    wire signal_mux_74;
    wire signal_wire_12;
    reg mechanisms$lane$reg_clock_enable;
    wire [7:0] signal_mux_75;
    wire signal_not_11;
    wire signal_mux_76;
    wire signal_mux_77;
    wire signal_mux_78;
    wire signal_wire_13;
    reg mechanisms$lane$reg_tx_enable;
    wire signal_mux_79;
    wire signal_mux_80;
    wire signal_mux_81;
    wire signal_wire_14;
    reg mechanisms$lane$reg_launch_trailing;
    wire signal_eq_3;
    wire signal_and_17;
    wire signal_and_18;
    wire [7:0] signal_mux_82;
    wire [7:0] signal_mux_83;
    wire [7:0] signal_mux_84;
    wire [7:0] signal_mux_85;
    wire [7:0] signal_mux_86;
    wire [7:0] signal_wire_15;
    reg [7:0] mechanisms$lane$reg_pin_value;
    wire [7:0] signal_select_76;
    wire [7:0] signal_mux_87;
    wire [7:0] signal_mux_88;
    wire signal_select_77;
    wire signal_and_19;
    wire [7:0] signal_mux_89;
    wire [7:0] signal_and_20;
    wire [7:0] signal_not_12;
    wire [7:0] signal_and_21;
    wire [7:0] signal_or_11;
    wire [7:0] signal_mux_90;
    wire [7:0] signal_mux_91;
    wire [7:0] signal_mux_92;
    wire [7:0] signal_wire_16;
    reg [7:0] mechanisms$bank$reg_pins;
    wire [5:0] signal_not_13;
    wire [5:0] signal_and_22;
    wire [5:0] signal_and_23;
    wire [5:0] signal_not_14;
    wire [5:0] signal_and_24;
    wire [5:0] signal_or_12;
    wire [5:0] signal_wire_17;
    reg [5:0] mechanisms$events$reg_overflow;
    wire [31:0] signal_add_1;
    wire [31:0] signal_add_2;
    wire [31:0] signal_add_3;
    wire [31:0] signal_mux_93;
    wire [31:0] signal_mux_94;
    wire [31:0] signal_mux_95;
    wire [31:0] signal_mux_96;
    wire [31:0] signal_mux_97;
    wire [31:0] signal_mux_98;
    wire [31:0] signal_mux_99;
    wire [31:0] signal_mux_100;
    wire [31:0] signal_wire_18;
    reg [31:0] execution$reg_total_cycles;
    wire [31:0] signal_add_4;
    wire [31:0] signal_mux_101;
    wire [31:0] signal_mux_102;
    wire [31:0] signal_mux_103;
    wire [31:0] signal_mux_104;
    wire [31:0] signal_mux_105;
    wire [31:0] signal_mux_106;
    wire [31:0] signal_mux_107;
    wire [31:0] signal_wire_19;
    reg [31:0] execution$reg_extension_fetches;
    wire [31:0] signal_add_5;
    wire [31:0] signal_mux_108;
    wire [31:0] signal_mux_109;
    wire [31:0] signal_mux_110;
    wire [31:0] signal_mux_111;
    wire [31:0] signal_mux_112;
    wire [31:0] signal_mux_113;
    wire [31:0] signal_wire_20;
    reg [31:0] execution$reg_instruction_count;
    wire [31:0] signal_add_6;
    wire [31:0] signal_mux_114;
    wire signal_not_15;
    wire signal_not_16;
    wire signal_and_25;
    wire signal_and_26;
    wire signal_or_13;
    wire [31:0] signal_mux_115;
    wire [31:0] signal_mux_116;
    wire [31:0] signal_mux_117;
    wire [31:0] signal_mux_118;
    wire [31:0] signal_mux_119;
    wire [31:0] signal_wire_21;
    reg [31:0] execution$reg_stall_cycles;
    wire [31:0] signal_add_7;
    wire [31:0] signal_mux_120;
    wire signal_or_14;
    wire signal_or_15;
    wire signal_or_16;
    wire [31:0] signal_mux_121;
    wire [31:0] signal_mux_122;
    wire [31:0] signal_mux_123;
    wire [31:0] signal_mux_124;
    wire [31:0] signal_mux_125;
    wire [31:0] signal_wire_22;
    reg [31:0] execution$reg_execute_cycles;
    wire [31:0] signal_add_8;
    wire [31:0] signal_mux_126;
    wire [31:0] signal_mux_127;
    wire [31:0] signal_mux_128;
    wire [31:0] signal_mux_129;
    wire [31:0] signal_mux_130;
    wire [31:0] signal_mux_131;
    wire [31:0] signal_wire_23;
    reg [31:0] execution$reg_fetch_cycles;
    wire [127:0] signal_cat;
    wire signal_mux_132;
    wire signal_mux_133;
    wire signal_mux_134;
    wire signal_mux_135;
    wire signal_mux_136;
    wire signal_mux_137;
    wire signal_wire_24;
    reg execution$reg_retired;
    wire [7:0] signal_wire_25;
    wire [7:0] signal_const_109;
    wire [7:0] signal_const_111;
    wire [7:0] signal_const_112;
    wire [7:0] signal_mux_138;
    wire [7:0] signal_mux_139;
    wire signal_and_27;
    wire [7:0] signal_mux_140;
    wire signal_and_28;
    wire [7:0] signal_mux_141;
    wire signal_and_29;
    wire [7:0] signal_mux_142;
    wire [7:0] signal_mux_143;
    wire [7:0] signal_wire_26;
    wire [4:0] signal_const_116;
    wire [7:0] signal_cat_1;
    wire [2:0] signal_const_117;
    wire [2:0] signal_const_118;
    wire [2:0] signal_const_119;
    wire [2:0] signal_const_120;
    wire [2:0] signal_const_121;
    wire signal_not_17;
    wire signal_and_30;
    wire [2:0] signal_mux_144;
    wire signal_not_18;
    wire signal_and_31;
    wire [2:0] signal_mux_145;
    wire signal_not_19;
    wire [2:0] signal_mux_146;
    wire signal_not_20;
    wire signal_not_21;
    wire signal_or_17;
    wire [2:0] signal_mux_147;
    wire signal_not_22;
    wire [2:0] signal_mux_148;
    wire [7:0] signal_cat_2;
    wire [7:0] signal_mux_149;
    wire [7:0] signal_mux_150;
    wire [7:0] signal_mux_151;
    wire [7:0] signal_mux_152;
    wire [7:0] signal_mux_153;
    wire [7:0] signal_mux_154;
    wire [7:0] signal_mux_155;
    wire [7:0] signal_mux_156;
    wire [7:0] signal_mux_157;
    wire [7:0] signal_mux_158;
    wire [7:0] signal_mux_159;
    wire [7:0] signal_mux_160;
    wire [7:0] signal_mux_161;
    wire [7:0] signal_mux_162;
    wire [7:0] signal_wire_27;
    reg [7:0] execution$reg_fault_reason;
    wire [16:0] signal_const_128;
    wire [16:0] signal_mux_163;
    wire [16:0] signal_mux_164;
    wire [16:0] signal_mux_165;
    wire [16:0] signal_mux_166;
    wire [16:0] signal_mux_167;
    wire [16:0] signal_mux_168;
    wire [16:0] signal_mux_169;
    wire [16:0] signal_mux_170;
    wire [16:0] signal_mux_171;
    wire [16:0] signal_mux_172;
    wire [16:0] signal_mux_173;
    wire [16:0] signal_mux_174;
    wire [16:0] signal_mux_175;
    wire [16:0] signal_mux_176;
    wire [16:0] signal_wire_28;
    reg [16:0] execution$reg_fault_address;
    wire [16:0] signal_mux_177;
    wire [16:0] signal_mux_178;
    wire [16:0] signal_mux_179;
    wire [16:0] signal_mux_180;
    wire [16:0] signal_mux_181;
    wire [16:0] signal_mux_182;
    wire [16:0] signal_wire_29;
    reg [16:0] execution$reg_last_instruction_slot;
    wire [16:0] signal_mux_183;
    wire [16:0] signal_mux_184;
    wire [16:0] signal_mux_185;
    wire [16:0] signal_mux_186;
    wire [16:0] signal_mux_187;
    wire [16:0] signal_mux_188;
    wire [16:0] signal_mux_189;
    wire [16:0] signal_mux_190;
    wire [16:0] signal_mux_191;
    wire [16:0] signal_mux_192;
    wire [16:0] signal_mux_193;
    wire [16:0] signal_mux_194;
    wire [16:0] signal_mux_195;
    wire [16:0] signal_mux_196;
    wire [16:0] signal_wire_30;
    reg [16:0] execution$reg_fault_instruction_slot;
    wire [3:0] signal_const_131;
    wire [3:0] signal_const_132;
    wire [3:0] signal_const_133;
    wire [3:0] signal_const_134;
    wire [3:0] signal_const_135;
    wire [3:0] signal_const_136;
    wire [3:0] signal_const_137;
    wire [3:0] signal_const_138;
    wire [3:0] signal_const_139;
    wire [3:0] signal_const_140;
    wire [3:0] signal_mux_197;
    wire [3:0] signal_mux_198;
    wire [3:0] signal_mux_199;
    wire [3:0] signal_mux_200;
    wire [3:0] signal_mux_201;
    wire [3:0] signal_mux_202;
    wire [3:0] signal_mux_203;
    wire [3:0] signal_mux_204;
    wire [3:0] signal_mux_205;
    wire [3:0] signal_mux_206;
    wire [3:0] signal_mux_207;
    wire [3:0] signal_mux_208;
    wire [3:0] signal_mux_209;
    wire [3:0] signal_mux_210;
    wire [3:0] signal_mux_211;
    wire [3:0] signal_wire_31;
    reg [3:0] execution$reg_fault_kind;
    wire signal_mux_212;
    wire signal_mux_213;
    wire signal_mux_214;
    wire signal_mux_215;
    wire signal_wire_32;
    reg signal_reg;
    wire signal_not_23;
    wire signal_and_32;
    wire signal_not_24;
    wire signal_and_33;
    wire signal_not_25;
    wire signal_and_34;
    wire signal_not_26;
    wire signal_and_35;
    wire signal_and_36;
    wire signal_mux_216;
    wire signal_mux_217;
    wire signal_wire_33;
    reg signal_reg_1;
    wire [15:0] signal_const_148;
    wire [15:0] signal_mux_218;
    wire [15:0] signal_mux_219;
    wire [15:0] signal_wire_34;
    reg [15:0] signal_reg_2;
    wire signal_mux_220;
    wire signal_mux_221;
    wire signal_mux_222;
    wire signal_mux_223;
    wire signal_wire_35;
    reg signal_reg_3;
    wire signal_not_27;
    wire signal_and_37;
    wire signal_not_28;
    wire signal_and_38;
    wire signal_not_29;
    wire signal_and_39;
    wire signal_not_30;
    wire signal_and_40;
    wire [15:0] signal_wire_36;
    wire [8:0] signal_mux_224;
    wire [8:0] signal_mux_225;
    wire [7:0] signal_select_78;
    wire signal_not_31;
    wire signal_and_41;
    wire signal_not_32;
    wire signal_or_18;
    wire signal_lt;
    wire [8:0] signal_wire_37;
    wire signal_eq_4;
    wire signal_not_33;
    wire signal_not_34;
    wire signal_mux_226;
    wire signal_mux_227;
    wire signal_not_35;
    wire signal_not_36;
    wire signal_and_42;
    wire signal_mux_228;
    wire signal_mux_229;
    wire signal_mux_230;
    wire signal_lt_1;
    wire [8:0] signal_const_166;
    wire [16:0] signal_const_167;
    wire [16:0] signal_add_9;
    wire [16:0] signal_mux_231;
    wire [8:0] signal_select_79;
    wire [8:0] signal_wire_38;
    wire signal_lt_2;
    wire signal_and_43;
    wire signal_wire_39;
    wire signal_or_19;
    wire signal_or_20;
    wire signal_or_21;
    wire signal_or_22;
    wire signal_or_23;
    wire signal_or_24;
    wire signal_or_25;
    wire signal_or_26;
    wire signal_eq_5;
    wire signal_not_37;
    wire signal_and_44;
    wire signal_not_38;
    wire [2:0] signal_const_174;
    wire [2:0] signal_mux_232;
    wire [2:0] signal_mux_233;
    wire [2:0] signal_mux_234;
    wire [2:0] signal_mux_235;
    wire [2:0] signal_mux_236;
    wire [2:0] signal_mux_237;
    wire signal_not_39;
    wire signal_not_40;
    wire signal_and_45;
    wire signal_and_46;
    wire [2:0] signal_mux_238;
    wire signal_not_41;
    wire signal_and_47;
    wire [2:0] signal_mux_239;
    wire [2:0] signal_mux_240;
    wire [2:0] signal_mux_241;
    wire [2:0] signal_mux_242;
    wire [2:0] signal_mux_243;
    wire [2:0] signal_mux_244;
    wire [2:0] signal_mux_245;
    wire [2:0] signal_mux_246;
    wire [2:0] signal_mux_247;
    wire [2:0] signal_mux_248;
    wire [2:0] signal_mux_249;
    wire signal_mux_250;
    wire signal_mux_251;
    wire signal_mux_252;
    wire signal_wire_40;
    reg reg_stepping;
    wire signal_and_48;
    wire signal_mux_253;
    wire signal_or_27;
    wire signal_mux_254;
    wire signal_mux_255;
    wire signal_mux_256;
    wire signal_mux_257;
    wire signal_mux_258;
    wire signal_mux_259;
    wire signal_mux_260;
    wire signal_mux_261;
    wire signal_mux_262;
    wire signal_mux_263;
    wire signal_mux_264;
    wire signal_mux_265;
    wire signal_mux_266;
    wire signal_mux_267;
    wire signal_wire_41;
    reg execution$reg_boundary;
    wire signal_wire_42;
    wire signal_not_42;
    wire signal_and_49;
    wire signal_mux_268;
    wire signal_mux_269;
    wire signal_not_43;
    wire signal_not_44;
    wire signal_mux_270;
    wire signal_not_45;
    wire signal_not_46;
    wire [8:0] signal_const_215;
    wire [8:0] signal_const_217;
    wire [8:0] signal_add_10;
    wire [8:0] signal_mux_271;
    wire [8:0] signal_mux_272;
    wire signal_not_47;
    wire signal_not_48;
    wire signal_not_49;
    wire signal_mux_273;
    wire signal_mux_274;
    wire signal_mux_275;
    wire signal_lt_3;
    wire signal_eq_6;
    wire [15:0] signal_wire_43;
    wire [15:0] signal_mux_276;
    wire [15:0] signal_mux_277;
    wire [15:0] signal_wire_44;
    reg [15:0] signal_reg_4;
    wire signal_eq_7;
    wire signal_mux_278;
    wire signal_mux_279;
    wire signal_mux_280;
    wire signal_wire_45;
    reg signal_reg_5;
    wire signal_mux_281;
    wire signal_mux_282;
    wire signal_mux_283;
    wire signal_mux_284;
    wire signal_wire_46;
    reg signal_reg_6;
    wire signal_not_50;
    wire signal_eq_8;
    wire signal_and_50;
    wire signal_and_51;
    wire signal_and_52;
    wire signal_and_53;
    wire [8:0] signal_mux_285;
    wire [8:0] signal_wire_47;
    wire signal_lt_4;
    wire signal_or_28;
    wire signal_and_54;
    wire signal_wire_48;
    wire signal_mux_286;
    wire signal_not_51;
    wire signal_and_55;
    wire signal_and_56;
    wire signal_and_57;
    wire signal_and_58;
    wire signal_mux_287;
    wire signal_mux_288;
    wire signal_wire_49;
    reg signal_reg_7;
    wire signal_and_59;
    wire signal_and_60;
    wire signal_and_61;
    wire signal_and_62;
    wire [8:0] signal_mux_289;
    wire [8:0] signal_mux_290;
    wire [8:0] signal_mux_291;
    wire [8:0] signal_wire_50;
    reg [8:0] signal_reg_8;
    wire signal_eq_9;
    wire [8:0] signal_mux_292;
    wire [8:0] signal_mux_293;
    wire [8:0] signal_wire_51;
    reg [8:0] signal_reg_9;
    wire [8:0] signal_add_11;
    wire [8:0] signal_mux_294;
    wire [8:0] signal_mux_295;
    wire [8:0] signal_mux_296;
    wire [8:0] signal_wire_52;
    reg [8:0] signal_reg_10;
    wire signal_eq_10;
    wire signal_lt_5;
    wire signal_not_52;
    wire [8:0] signal_wire_53;
    wire signal_lt_6;
    wire signal_and_63;
    wire signal_and_64;
    wire signal_and_65;
    wire signal_mux_297;
    wire signal_mux_298;
    wire signal_mux_299;
    wire signal_wire_54;
    reg signal_reg_11;
    wire signal_and_66;
    wire signal_and_67;
    wire signal_and_68;
    wire signal_and_69;
    wire signal_and_70;
    wire signal_and_71;
    wire signal_and_72;
    wire signal_mux_300;
    wire signal_mux_301;
    wire signal_wire_55;
    reg signal_reg_12;
    wire signal_mux_302;
    wire signal_mux_303;
    wire signal_mux_304;
    wire signal_mux_305;
    wire signal_mux_306;
    wire signal_mux_307;
    wire signal_mux_308;
    wire signal_mux_309;
    wire signal_mux_310;
    wire signal_mux_311;
    wire signal_mux_312;
    wire signal_mux_313;
    wire signal_mux_314;
    wire signal_mux_315;
    wire signal_mux_316;
    wire signal_mux_317;
    wire signal_wire_56;
    reg execution$reg_normal_halt;
    wire signal_wire_57;
    wire signal_not_53;
    wire signal_and_73;
    wire signal_mux_318;
    wire signal_mux_319;
    wire signal_not_54;
    wire signal_and_74;
    wire signal_mux_320;
    wire signal_and_75;
    wire signal_mux_321;
    wire signal_and_76;
    wire signal_mux_322;
    wire signal_not_55;
    wire signal_and_77;
    wire signal_mux_323;
    wire [15:0] signal_const_262;
    wire signal_lt_7;
    wire signal_not_56;
    wire signal_eq_11;
    wire signal_not_57;
    wire [4:0] signal_const_264;
    wire signal_eq_12;
    wire [4:0] signal_const_265;
    wire signal_eq_13;
    wire [4:0] signal_const_266;
    wire signal_eq_14;
    wire [4:0] signal_const_267;
    wire signal_eq_15;
    wire signal_or_29;
    wire signal_or_30;
    wire signal_or_31;
    wire signal_mux_324;
    wire [4:0] signal_const_268;
    wire signal_eq_16;
    wire signal_mux_325;
    wire signal_mux_326;
    wire signal_mux_327;
    wire signal_mux_328;
    wire signal_mux_329;
    wire signal_mux_330;
    wire signal_mux_331;
    wire signal_mux_332;
    wire signal_wire_58;
    reg execution$reg_has_extension;
    wire signal_or_32;
    wire signal_and_78;
    wire signal_and_79;
    wire signal_or_33;
    wire signal_and_80;
    wire signal_not_58;
    wire signal_or_34;
    wire signal_and_81;
    wire signal_not_59;
    wire signal_and_82;
    wire signal_mux_333;
    wire signal_not_60;
    wire signal_and_83;
    wire signal_and_84;
    wire signal_mux_334;
    wire signal_or_35;
    wire signal_and_85;
    wire signal_mux_335;
    wire signal_not_61;
    wire signal_not_62;
    wire signal_and_86;
    wire signal_and_87;
    wire signal_and_88;
    wire signal_mux_336;
    wire signal_and_89;
    wire signal_and_90;
    wire signal_mux_337;
    wire signal_mux_338;
    wire signal_mux_339;
    wire signal_mux_340;
    wire signal_mux_341;
    wire signal_wire_59;
    reg execution$reg_execution_fault;
    wire signal_wire_60;
    wire signal_not_63;
    wire signal_not_64;
    wire signal_eq_17;
    wire signal_not_65;
    wire signal_not_66;
    wire [1:0] signal_const_276;
    wire signal_eq_18;
    wire signal_not_67;
    wire signal_not_68;
    wire signal_mux_342;
    wire signal_not_69;
    wire signal_not_70;
    wire signal_mux_343;
    wire signal_mux_344;
    wire signal_mux_345;
    wire signal_mux_346;
    wire signal_mux_347;
    wire signal_mux_348;
    wire signal_mux_349;
    wire signal_not_71;
    wire signal_eq_19;
    wire signal_and_91;
    wire signal_eq_20;
    wire signal_not_72;
    wire signal_not_73;
    wire signal_eq_21;
    wire [4:0] signal_const_293;
    wire signal_eq_22;
    wire [4:0] signal_const_294;
    wire signal_eq_23;
    wire [4:0] signal_const_295;
    wire signal_eq_24;
    wire [4:0] signal_const_296;
    wire signal_eq_25;
    wire [4:0] signal_const_297;
    wire signal_eq_26;
    wire [4:0] signal_const_298;
    wire signal_eq_27;
    wire [4:0] signal_const_299;
    wire signal_eq_28;
    wire [4:0] signal_const_300;
    wire signal_eq_29;
    wire [4:0] signal_const_301;
    wire signal_eq_30;
    wire [4:0] signal_const_302;
    wire signal_eq_31;
    wire [4:0] signal_const_303;
    wire signal_eq_32;
    wire [4:0] signal_const_304;
    wire signal_eq_33;
    wire [4:0] signal_const_305;
    wire signal_eq_34;
    wire [15:0] signal_mux_350;
    wire [15:0] signal_mux_351;
    wire [3:0] signal_select_80;
    wire signal_lt_8;
    wire [9:0] signal_const_309;
    wire [9:0] signal_select_81;
    wire signal_eq_35;
    wire signal_not_74;
    wire signal_select_82;
    wire signal_or_36;
    wire [3:0] signal_select_83;
    wire signal_eq_36;
    wire [3:0] signal_select_84;
    wire signal_eq_37;
    wire signal_not_75;
    wire signal_select_85;
    wire signal_mux_352;
    wire [3:0] signal_select_86;
    wire signal_eq_38;
    wire signal_select_87;
    wire signal_not_76;
    wire signal_and_92;
    wire signal_select_88;
    wire signal_mux_353;
    wire [1:0] signal_const_313;
    wire [1:0] signal_select_89;
    wire signal_lt_9;
    wire signal_and_93;
    wire [4:0] signal_select_90;
    wire signal_eq_39;
    wire [4:0] signal_select_91;
    wire signal_eq_40;
    wire signal_not_77;
    wire signal_select_92;
    wire signal_mux_354;
    wire [4:0] signal_select_93;
    wire signal_eq_41;
    wire signal_select_94;
    wire signal_not_78;
    wire signal_and_94;
    wire signal_select_95;
    wire signal_mux_355;
    wire [9:0] signal_select_96;
    wire signal_eq_42;
    wire signal_not_79;
    wire signal_select_97;
    wire signal_or_37;
    wire [2:0] signal_select_98;
    wire signal_lt_10;
    wire [3:0] signal_select_99;
    wire signal_eq_43;
    wire signal_not_80;
    wire [2:0] signal_select_100;
    wire signal_lt_11;
    wire [2:0] signal_select_101;
    wire signal_lt_12;
    reg signal_mux_356;
    wire [5:0] signal_select_102;
    wire signal_eq_44;
    wire signal_select_103;
    wire signal_not_81;
    wire signal_or_38;
    wire [9:0] signal_select_104;
    wire signal_eq_45;
    wire signal_select_105;
    wire signal_not_82;
    wire signal_or_39;
    wire [3:0] signal_select_106;
    wire signal_eq_46;
    wire signal_select_107;
    wire signal_not_83;
    wire signal_or_40;
    wire [4:0] signal_select_108;
    wire signal_eq_47;
    wire signal_select_109;
    wire signal_not_84;
    wire signal_or_41;
    wire [9:0] signal_select_110;
    wire signal_eq_48;
    wire signal_select_111;
    wire signal_not_85;
    wire signal_or_42;
    wire [6:0] signal_const_327;
    wire [6:0] signal_select_112;
    wire signal_eq_49;
    wire signal_select_113;
    wire signal_not_86;
    wire signal_or_43;
    wire [3:0] signal_select_114;
    wire signal_eq_50;
    wire signal_select_115;
    wire signal_not_87;
    wire signal_or_44;
    wire [6:0] signal_select_116;
    wire signal_eq_51;
    wire signal_select_117;
    wire signal_not_88;
    wire signal_or_45;
    reg signal_mux_357;
    wire [10:0] signal_const_330;
    wire [10:0] signal_const_332;
    wire [10:0] signal_const_334;
    wire [10:0] signal_const_336;
    wire [10:0] signal_const_344;
    wire [10:0] signal_const_345;
    wire [10:0] signal_const_350;
    wire [10:0] signal_const_353;
    wire [10:0] signal_const_355;
    reg [10:0] signal_mux_358;
    wire [10:0] signal_select_118;
    wire [10:0] signal_and_95;
    wire signal_eq_52;
    reg signal_mux_359;
    wire signal_and_96;
    wire signal_and_97;
    wire signal_and_98;
    wire signal_and_99;
    wire signal_and_100;
    wire [6:0] signal_select_119;
    wire signal_select_120;
    wire [1:0] signal_cat_3;
    wire [3:0] signal_cat_4;
    wire [7:0] signal_cat_5;
    wire [9:0] signal_cat_6;
    wire [16:0] signal_cat_7;
    wire [16:0] signal_add_12;
    wire [16:0] signal_add_13;
    wire signal_select_121;
    wire [4:0] signal_const_363;
    wire signal_eq_53;
    wire signal_and_101;
    wire [16:0] signal_mux_360;
    wire [10:0] signal_select_122;
    wire signal_select_123;
    wire [1:0] signal_cat_8;
    wire [3:0] signal_cat_9;
    wire [5:0] signal_cat_10;
    wire [16:0] signal_cat_11;
    wire [16:0] signal_add_14;
    wire [16:0] signal_add_15;
    wire [7:0] signal_select_124;
    wire signal_select_125;
    wire [1:0] signal_cat_12;
    wire [3:0] signal_cat_13;
    wire [7:0] signal_cat_14;
    wire [8:0] signal_cat_15;
    wire [16:0] signal_cat_16;
    wire [16:0] signal_add_16;
    wire [16:0] signal_add_17;
    wire signal_not_89;
    wire signal_select_126;
    wire signal_mux_361;
    wire signal_mux_362;
    wire signal_mux_363;
    wire signal_mux_364;
    wire signal_mux_365;
    wire signal_mux_366;
    wire signal_wire_61;
    reg execution$reg_negative;
    wire signal_not_90;
    wire signal_lt_13;
    wire signal_select_127;
    reg signal_mux_367;
    wire signal_lt_14;
    wire signal_select_128;
    reg signal_mux_368;
    wire signal_lt_15;
    wire signal_lt_16;
    wire signal_select_129;
    wire signal_select_130;
    wire signal_select_131;
    wire signal_select_132;
    wire signal_select_133;
    wire signal_select_134;
    wire signal_select_135;
    wire signal_select_136;
    wire signal_select_137;
    wire signal_select_138;
    wire signal_select_139;
    wire signal_select_140;
    wire signal_select_141;
    wire signal_select_142;
    wire signal_select_143;
    reg signal_mux_369;
    wire signal_select_144;
    wire signal_select_145;
    wire signal_select_146;
    wire signal_select_147;
    wire signal_select_148;
    wire signal_select_149;
    wire signal_select_150;
    wire signal_select_151;
    wire signal_select_152;
    wire signal_select_153;
    wire signal_select_154;
    wire signal_select_155;
    wire signal_select_156;
    wire signal_select_157;
    wire signal_select_158;
    reg signal_mux_370;
    wire signal_mux_371;
    wire signal_eq_54;
    wire signal_mux_372;
    wire signal_eq_55;
    wire signal_mux_373;
    wire signal_eq_56;
    wire signal_mux_374;
    wire signal_eq_57;
    wire signal_mux_375;
    wire signal_mux_376;
    wire signal_mux_377;
    wire signal_mux_378;
    wire signal_mux_379;
    wire signal_mux_380;
    wire signal_mux_381;
    wire signal_wire_62;
    reg execution$reg_carry;
    wire signal_not_91;
    wire [2:0] signal_select_159;
    reg [15:0] signal_mux_382;
    wire [2:0] signal_select_160;
    reg [15:0] signal_mux_383;
    wire [15:0] signal_sub_5;
    wire [2:0] signal_select_161;
    reg [15:0] signal_mux_384;
    wire [15:0] signal_sub_6;
    wire signal_eq_58;
    wire [15:0] signal_mux_385;
    wire signal_eq_59;
    wire [15:0] signal_mux_386;
    wire signal_eq_60;
    wire [15:0] signal_mux_387;
    wire signal_eq_61;
    wire [15:0] signal_mux_388;
    wire signal_eq_62;
    wire signal_mux_389;
    wire signal_eq_63;
    wire signal_eq_64;
    wire signal_eq_65;
    wire signal_eq_66;
    wire signal_eq_67;
    wire signal_or_46;
    wire signal_or_47;
    wire signal_or_48;
    wire signal_or_49;
    wire signal_and_102;
    wire signal_mux_390;
    wire signal_mux_391;
    wire signal_mux_392;
    wire signal_mux_393;
    wire signal_mux_394;
    wire signal_wire_63;
    reg execution$reg_zero;
    wire [2:0] signal_select_162;
    reg signal_mux_395;
    wire [16:0] signal_mux_396;
    wire [7:0] signal_select_163;
    wire signal_select_164;
    wire [1:0] signal_cat_17;
    wire [3:0] signal_cat_18;
    wire [7:0] signal_cat_19;
    wire [8:0] signal_cat_20;
    wire [16:0] signal_cat_21;
    wire [16:0] signal_add_18;
    wire [16:0] signal_add_19;
    wire signal_eq_68;
    wire signal_not_92;
    wire [16:0] signal_mux_397;
    wire [7:0] signal_select_165;
    wire signal_select_166;
    wire [1:0] signal_cat_22;
    wire [3:0] signal_cat_23;
    wire [7:0] signal_cat_24;
    wire [8:0] signal_cat_25;
    wire [16:0] signal_cat_26;
    wire [16:0] signal_add_20;
    wire [16:0] signal_add_21;
    wire [2:0] signal_select_167;
    reg [15:0] signal_mux_398;
    wire [16:0] signal_cat_27;
    wire [16:0] signal_const_386;
    wire [16:0] signal_mux_399;
    wire [16:0] signal_add_22;
    wire signal_eq_69;
    wire [16:0] signal_mux_400;
    wire signal_eq_70;
    wire [16:0] signal_mux_401;
    wire signal_eq_71;
    wire [16:0] signal_mux_402;
    wire signal_eq_72;
    wire [16:0] signal_mux_403;
    wire signal_eq_73;
    wire [16:0] signal_mux_404;
    wire [16:0] signal_mux_405;
    wire signal_eq_74;
    wire signal_not_93;
    wire signal_and_103;
    wire [16:0] signal_mux_406;
    wire signal_wire_64;
    wire signal_not_94;
    wire signal_eq_75;
    wire signal_not_95;
    wire signal_not_96;
    wire signal_not_97;
    wire signal_and_104;
    wire signal_and_105;
    wire signal_and_106;
    wire signal_and_107;
    wire signal_and_108;
    wire signal_or_50;
    wire signal_or_51;
    wire signal_wire_65;
    wire signal_not_98;
    wire signal_and_109;
    wire signal_not_99;
    wire signal_and_110;
    wire signal_or_52;
    wire signal_not_100;
    wire signal_and_111;
    wire signal_or_53;
    wire signal_not_101;
    wire signal_not_102;
    wire signal_or_54;
    wire signal_not_103;
    wire signal_not_104;
    wire signal_and_112;
    wire signal_and_113;
    wire signal_and_114;
    wire signal_and_115;
    wire signal_eq_76;
    wire signal_and_116;
    wire signal_not_105;
    wire signal_and_117;
    wire signal_wire_66;
    wire signal_not_106;
    wire signal_eq_77;
    wire signal_not_107;
    wire signal_not_108;
    wire signal_or_55;
    wire signal_eq_78;
    wire signal_not_109;
    wire signal_not_110;
    wire signal_or_56;
    wire signal_and_118;
    wire signal_not_111;
    wire signal_or_57;
    wire signal_or_58;
    wire signal_or_59;
    wire signal_and_119;
    wire signal_or_60;
    wire signal_or_61;
    wire signal_or_62;
    wire signal_or_63;
    wire signal_or_64;
    wire signal_or_65;
    wire signal_wire_67;
    wire signal_not_112;
    wire signal_or_66;
    wire signal_eq_79;
    wire signal_not_113;
    wire signal_and_120;
    wire signal_select_168;
    wire signal_select_169;
    wire signal_select_170;
    wire signal_select_171;
    wire signal_select_172;
    wire signal_select_173;
    wire signal_select_174;
    wire signal_select_175;
    wire signal_select_176;
    wire [2:0] signal_select_177;
    reg signal_mux_407;
    wire signal_eq_80;
    wire signal_and_121;
    wire signal_not_114;
    wire signal_not_115;
    wire signal_select_178;
    wire [14:0] signal_const_406;
    wire [15:0] signal_cat_28;
    wire signal_select_179;
    wire [15:0] signal_cat_29;
    wire [1:0] signal_select_180;
    wire [13:0] signal_const_412;
    wire [15:0] signal_cat_30;
    wire signal_select_181;
    wire [15:0] signal_cat_31;
    wire [7:0] signal_mux_408;
    wire [15:0] signal_cat_32;
    wire [15:0] signal_cat_33;
    wire [5:0] signal_const_419;
    wire signal_mux_409;
    wire signal_mux_410;
    wire signal_wire_68;
    reg mechanisms$bank$reg_rejected;
    wire [3:0] signal_wire_69;
    reg [3:0] mechanisms$reg_fifo_faults;
    wire [3:0] signal_not_116;
    wire signal_not_117;
    wire signal_and_122;
    wire signal_mux_411;
    wire signal_mux_412;
    wire signal_wire_70;
    reg mechanisms$tx_fifo$reg_overflow;
    wire signal_not_118;
    wire signal_and_123;
    wire signal_mux_413;
    wire signal_mux_414;
    wire signal_wire_71;
    reg mechanisms$tx_fifo$reg_starvation;
    wire signal_not_119;
    wire signal_and_124;
    wire signal_mux_415;
    wire signal_mux_416;
    wire signal_wire_72;
    reg mechanisms$rx_fifo$reg_overflow;
    wire signal_not_120;
    wire signal_and_125;
    wire signal_mux_417;
    wire signal_mux_418;
    wire signal_wire_73;
    reg mechanisms$rx_fifo$reg_starvation;
    wire [3:0] signal_cat_34;
    wire [3:0] signal_and_126;
    wire signal_eq_81;
    wire signal_not_121;
    wire signal_not_122;
    wire signal_and_127;
    wire signal_and_128;
    wire [7:0] signal_not_123;
    wire [7:0] signal_and_129;
    wire [7:0] signal_mux_419;
    wire [7:0] signal_or_67;
    wire [7:0] signal_mux_420;
    wire [7:0] signal_mux_421;
    wire [7:0] signal_mux_422;
    wire signal_or_68;
    wire [7:0] signal_mux_423;
    wire signal_or_69;
    wire [7:0] signal_mux_424;
    wire [7:0] signal_and_130;
    wire signal_eq_82;
    wire signal_not_124;
    wire signal_and_131;
    wire [7:0] signal_mux_425;
    wire [7:0] signal_not_125;
    wire [7:0] signal_and_132;
    wire signal_eq_83;
    wire signal_not_126;
    wire signal_and_133;
    wire [7:0] signal_mux_426;
    wire [7:0] signal_and_134;
    wire signal_eq_84;
    wire signal_not_127;
    wire signal_and_135;
    wire signal_and_136;
    wire signal_or_70;
    wire signal_or_71;
    wire signal_or_72;
    wire signal_wire_74;
    wire signal_and_137;
    wire signal_eq_85;
    wire signal_not_128;
    wire signal_not_129;
    wire signal_not_130;
    wire signal_and_138;
    wire signal_and_139;
    wire signal_wire_75;
    wire signal_eq_86;
    wire [7:0] signal_wire_76;
    wire [7:0] signal_mux_427;
    wire [7:0] signal_not_131;
    wire [7:0] signal_and_140;
    wire [7:0] signal_mux_428;
    wire [7:0] signal_wire_77;
    wire [7:0] signal_mux_429;
    wire [7:0] signal_or_73;
    wire [7:0] signal_mux_430;
    wire [7:0] signal_mux_431;
    wire signal_wire_78;
    wire signal_not_132;
    wire signal_eq_87;
    wire signal_not_133;
    wire signal_not_134;
    wire signal_and_141;
    wire signal_and_142;
    wire signal_and_143;
    wire signal_eq_88;
    wire signal_not_135;
    wire signal_and_144;
    wire signal_and_145;
    wire signal_or_74;
    wire signal_or_75;
    wire signal_or_76;
    wire signal_not_136;
    wire signal_and_146;
    wire signal_and_147;
    wire signal_eq_89;
    wire signal_not_137;
    wire [1:0] signal_const_448;
    wire [7:0] signal_mux_432;
    wire [7:0] signal_mux_433;
    wire [7:0] signal_mux_434;
    wire [7:0] signal_wire_79;
    reg [7:0] mechanisms$reg_bridge_claim;
    wire signal_eq_90;
    wire [1:0] signal_mux_435;
    wire [1:0] signal_const_458;
    wire [1:0] signal_mux_436;
    wire signal_mux_437;
    wire signal_mux_438;
    wire signal_mux_439;
    wire signal_mux_440;
    wire signal_mux_441;
    wire signal_mux_442;
    wire signal_wire_80;
    reg mechanisms$lane$reg_overrun;
    wire signal_mux_443;
    wire signal_mux_444;
    wire signal_mux_445;
    wire signal_wire_81;
    reg mechanisms$lane$reg_underrun;
    wire signal_mux_446;
    wire signal_mux_447;
    wire signal_mux_448;
    wire signal_wire_82;
    reg mechanisms$lane$reg_rejected;
    wire signal_or_77;
    wire signal_or_78;
    wire signal_wire_83;
    wire signal_not_138;
    wire signal_mux_449;
    wire signal_mux_450;
    wire signal_mux_451;
    wire signal_wire_84;
    reg mechanisms$lane$reg_rx_enable;
    wire signal_and_148;
    wire signal_mux_452;
    wire signal_mux_453;
    wire signal_mux_454;
    wire signal_mux_455;
    wire signal_mux_456;
    wire signal_mux_457;
    wire signal_mux_458;
    wire signal_wire_85;
    reg mechanisms$lane$reg_armed;
    wire signal_not_139;
    wire signal_mux_459;
    wire [5:0] signal_mux_460;
    wire [5:0] signal_mux_461;
    wire [5:0] signal_mux_462;
    wire [5:0] signal_wire_86;
    reg [5:0] mechanisms$lane$reg_bit_count;
    wire [5:0] signal_sub_7;
    wire [5:0] signal_mux_463;
    wire [5:0] signal_add_23;
    wire [5:0] signal_mux_464;
    wire [5:0] signal_mux_465;
    wire [5:0] signal_mux_466;
    wire [5:0] signal_mux_467;
    wire [5:0] signal_mux_468;
    wire [5:0] signal_mux_469;
    wire [5:0] signal_wire_87;
    reg [5:0] mechanisms$lane$reg_bit_index;
    wire signal_eq_91;
    wire signal_mux_470;
    wire signal_mux_471;
    wire signal_mux_472;
    wire signal_mux_473;
    wire signal_mux_474;
    wire signal_mux_475;
    wire signal_mux_476;
    wire signal_wire_88;
    reg mechanisms$lane$reg_trailing;
    wire signal_and_149;
    wire signal_mux_477;
    wire signal_select_182;
    wire signal_select_183;
    wire signal_select_184;
    wire signal_select_185;
    wire signal_select_186;
    wire signal_select_187;
    wire signal_select_188;
    wire [7:0] signal_or_79;
    wire [15:0] signal_const_514;
    wire signal_eq_92;
    wire [1:0] signal_mux_478;
    wire [15:0] signal_const_515;
    wire signal_eq_93;
    wire [1:0] signal_mux_479;
    wire [15:0] signal_const_516;
    wire signal_eq_94;
    wire [1:0] signal_mux_480;
    wire [15:0] signal_const_517;
    wire signal_eq_95;
    wire [1:0] signal_mux_481;
    wire [15:0] signal_const_518;
    wire signal_eq_96;
    wire [1:0] signal_mux_482;
    wire [15:0] signal_const_519;
    wire signal_eq_97;
    wire [1:0] signal_mux_483;
    wire [15:0] signal_const_520;
    wire signal_eq_98;
    wire [1:0] signal_mux_484;
    wire [15:0] signal_const_521;
    wire signal_eq_99;
    wire [1:0] signal_mux_485;
    wire [15:0] signal_const_522;
    wire signal_eq_100;
    wire [1:0] signal_mux_486;
    wire [15:0] signal_const_523;
    wire signal_eq_101;
    wire [1:0] signal_mux_487;
    wire [15:0] signal_const_524;
    wire signal_eq_102;
    wire [1:0] signal_mux_488;
    wire [15:0] signal_const_525;
    wire signal_eq_103;
    wire [1:0] signal_mux_489;
    wire [15:0] signal_const_526;
    wire signal_eq_104;
    wire [1:0] signal_mux_490;
    wire [15:0] signal_const_527;
    wire signal_eq_105;
    wire [1:0] signal_mux_491;
    wire [15:0] signal_const_528;
    wire signal_eq_106;
    wire [1:0] signal_mux_492;
    wire [15:0] signal_const_529;
    wire signal_eq_107;
    wire [1:0] signal_mux_493;
    wire [15:0] signal_const_530;
    wire signal_eq_108;
    wire [1:0] signal_mux_494;
    wire [15:0] signal_const_531;
    wire signal_eq_109;
    wire [1:0] signal_mux_495;
    wire [15:0] signal_const_532;
    wire signal_eq_110;
    wire [1:0] signal_mux_496;
    wire [15:0] signal_const_533;
    wire signal_eq_111;
    wire [1:0] signal_mux_497;
    wire [15:0] signal_const_534;
    wire signal_eq_112;
    wire [1:0] signal_mux_498;
    wire [15:0] signal_const_535;
    wire signal_eq_113;
    wire [1:0] signal_mux_499;
    wire [15:0] signal_const_536;
    wire signal_eq_114;
    wire [1:0] signal_mux_500;
    wire [15:0] signal_const_537;
    wire signal_eq_115;
    wire [1:0] signal_mux_501;
    wire [1:0] signal_wire_89;
    wire [1:0] signal_mux_502;
    wire [1:0] signal_mux_503;
    wire [1:0] signal_wire_90;
    reg [1:0] mechanisms$reg_bridge_pacing_edge;
    reg [7:0] signal_mux_504;
    wire signal_select_189;
    wire [2:0] signal_mux_505;
    wire [2:0] signal_mux_506;
    wire [2:0] signal_wire_91;
    reg [2:0] mechanisms$reg_bridge_pacing_pin;
    reg signal_mux_507;
    wire [15:0] signal_select_190;
    wire signal_eq_116;
    wire [15:0] signal_mux_508;
    wire [15:0] signal_mux_509;
    wire [15:0] signal_mux_510;
    wire [15:0] signal_mux_511;
    wire [15:0] signal_mux_512;
    wire [15:0] signal_wire_92;
    reg [15:0] mechanisms$lane$reg_half_period;
    wire signal_not_140;
    wire [15:0] signal_mux_513;
    wire [15:0] signal_sub_8;
    wire signal_not_141;
    wire signal_not_142;
    wire signal_and_150;
    wire [15:0] signal_mux_514;
    wire [15:0] signal_mux_515;
    wire [15:0] signal_mux_516;
    wire [15:0] signal_mux_517;
    wire [15:0] signal_mux_518;
    wire [15:0] signal_wire_93;
    reg [15:0] mechanisms$lane$reg_remaining;
    wire signal_eq_117;
    wire [7:0] signal_wire_94;
    wire [7:0] signal_or_80;
    reg [7:0] signal_mux_519;
    wire [7:0] signal_mux_520;
    reg [7:0] signal_mux_521;
    wire [7:0] signal_mux_522;
    wire [7:0] signal_or_81;
    wire [7:0] signal_and_151;
    wire signal_eq_118;
    wire signal_not_143;
    wire signal_not_144;
    wire signal_not_145;
    wire signal_and_152;
    wire signal_xor_1;
    wire signal_select_191;
    wire signal_xor_2;
    wire signal_eq_119;
    wire signal_eq_120;
    wire signal_not_146;
    wire signal_and_153;
    wire signal_and_154;
    wire [2:0] signal_select_192;
    wire signal_eq_121;
    wire signal_eq_122;
    wire signal_not_147;
    wire signal_and_155;
    wire signal_and_156;
    wire [2:0] signal_select_193;
    wire [2:0] signal_select_194;
    wire signal_eq_123;
    wire signal_not_148;
    wire signal_and_157;
    wire signal_and_158;
    wire signal_and_159;
    wire [15:0] signal_select_195;
    wire [31:0] signal_cat_35;
    wire [23:0] signal_select_196;
    wire [31:0] signal_cat_36;
    wire [27:0] signal_select_197;
    wire [31:0] signal_cat_37;
    wire [29:0] signal_select_198;
    wire [31:0] signal_cat_38;
    wire [30:0] signal_select_199;
    wire [31:0] signal_cat_39;
    wire [31:0] signal_cat_40;
    wire signal_select_200;
    wire [31:0] signal_mux_523;
    wire signal_select_201;
    wire [31:0] signal_mux_524;
    wire signal_select_202;
    wire [31:0] signal_mux_525;
    wire signal_select_203;
    wire [31:0] signal_mux_526;
    wire signal_select_204;
    wire [31:0] signal_mux_527;
    wire signal_select_205;
    wire [31:0] signal_mux_528;
    wire signal_eq_124;
    wire signal_not_149;
    wire signal_lt_17;
    wire [5:0] signal_select_206;
    wire signal_eq_125;
    wire signal_or_82;
    wire signal_or_83;
    wire signal_or_84;
    wire signal_or_85;
    wire signal_or_86;
    wire signal_or_87;
    wire signal_or_88;
    wire signal_or_89;
    wire signal_or_90;
    wire signal_mux_529;
    wire signal_mux_530;
    wire signal_mux_531;
    wire signal_wire_95;
    reg mechanisms$lane$reg_observed;
    wire signal_mux_532;
    wire signal_and_160;
    wire signal_mux_533;
    wire signal_mux_534;
    wire signal_mux_535;
    wire signal_mux_536;
    wire signal_wire_96;
    reg mechanisms$lane$reg_busy;
    wire signal_not_150;
    wire signal_and_161;
    wire signal_and_162;
    wire signal_mux_537;
    wire signal_not_151;
    wire signal_or_91;
    wire signal_mux_538;
    wire signal_wire_97;
    reg mechanisms$lane$reg_done_;
    wire signal_or_92;
    wire signal_eq_126;
    wire signal_and_163;
    wire [1:0] signal_mux_539;
    wire [1:0] signal_mux_540;
    wire [1:0] signal_mux_541;
    wire [1:0] signal_wire_98;
    reg [1:0] mechanisms$reg_bridge_state;
    wire signal_eq_127;
    wire signal_and_164;
    wire signal_or_93;
    wire [7:0] signal_mux_542;
    wire [7:0] signal_mux_543;
    wire [7:0] signal_mux_544;
    wire [7:0] signal_wire_99;
    reg [7:0] mechanisms$bank$reg_software_claim;
    wire [7:0] signal_wire_100;
    wire [7:0] signal_or_94;
    wire [2:0] signal_select_207;
    reg [7:0] signal_mux_545;
    wire [7:0] signal_mux_546;
    wire [2:0] signal_select_208;
    reg [7:0] signal_mux_547;
    wire signal_eq_128;
    wire signal_not_152;
    wire signal_and_165;
    wire [7:0] signal_mux_548;
    wire [7:0] signal_or_95;
    wire [7:0] signal_and_166;
    wire signal_eq_129;
    wire signal_not_153;
    wire signal_not_154;
    wire [15:0] signal_select_209;
    wire signal_eq_130;
    wire signal_not_155;
    wire signal_and_167;
    wire signal_and_168;
    wire signal_lt_18;
    wire signal_not_156;
    wire signal_not_157;
    wire signal_select_210;
    wire signal_select_211;
    wire signal_eq_131;
    wire [2:0] signal_select_212;
    wire signal_eq_132;
    wire signal_and_169;
    wire [2:0] signal_select_213;
    wire signal_eq_133;
    wire signal_and_170;
    wire [2:0] signal_const_600;
    wire signal_eq_134;
    wire [2:0] signal_mux_549;
    wire signal_eq_135;
    wire [2:0] signal_mux_550;
    wire signal_eq_136;
    wire [2:0] signal_mux_551;
    wire signal_eq_137;
    wire [2:0] signal_mux_552;
    wire signal_eq_138;
    wire [2:0] signal_mux_553;
    wire signal_eq_139;
    wire [2:0] signal_mux_554;
    wire signal_eq_140;
    wire [2:0] signal_mux_555;
    wire signal_eq_141;
    wire [2:0] signal_mux_556;
    wire signal_eq_142;
    wire [2:0] signal_mux_557;
    wire signal_eq_143;
    wire [2:0] signal_mux_558;
    wire signal_eq_144;
    wire [2:0] signal_mux_559;
    wire signal_eq_145;
    wire [2:0] signal_mux_560;
    wire signal_eq_146;
    wire [2:0] signal_mux_561;
    wire signal_eq_147;
    wire [2:0] signal_mux_562;
    wire signal_eq_148;
    wire [2:0] signal_mux_563;
    wire signal_eq_149;
    wire [2:0] signal_mux_564;
    wire signal_eq_150;
    wire [2:0] signal_mux_565;
    wire signal_eq_151;
    wire [2:0] signal_mux_566;
    wire signal_eq_152;
    wire [2:0] signal_mux_567;
    wire signal_eq_153;
    wire [2:0] signal_mux_568;
    wire signal_eq_154;
    wire [2:0] signal_mux_569;
    wire signal_eq_155;
    wire [2:0] signal_mux_570;
    wire signal_eq_156;
    wire [2:0] signal_mux_571;
    wire signal_eq_157;
    wire [2:0] signal_mux_572;
    wire [2:0] signal_wire_101;
    wire [2:0] signal_select_214;
    wire signal_eq_158;
    wire signal_and_171;
    wire signal_or_96;
    wire signal_or_97;
    wire [15:0] signal_select_215;
    wire signal_eq_159;
    wire signal_not_158;
    wire signal_and_172;
    wire signal_eq_160;
    wire signal_and_173;
    wire signal_and_174;
    wire signal_eq_161;
    wire [15:0] signal_select_216;
    wire signal_lt_19;
    wire signal_and_175;
    wire signal_and_176;
    wire signal_or_98;
    wire signal_or_99;
    wire signal_not_159;
    wire signal_not_160;
    wire signal_or_100;
    wire signal_not_161;
    wire signal_not_162;
    wire signal_or_101;
    wire signal_not_163;
    wire signal_or_102;
    wire [15:0] signal_select_217;
    wire signal_lt_20;
    wire [15:0] signal_select_218;
    wire signal_lt_21;
    wire signal_not_164;
    wire signal_or_103;
    wire [15:0] signal_select_219;
    wire [1:0] signal_select_220;
    reg signal_mux_573;
    wire [7:0] signal_select_221;
    wire [15:0] signal_cat_41;
    wire [11:0] signal_select_222;
    wire [15:0] signal_cat_42;
    wire [13:0] signal_select_223;
    wire [15:0] signal_cat_43;
    wire [14:0] signal_select_224;
    wire [15:0] signal_cat_44;
    wire [15:0] signal_select_225;
    wire signal_select_226;
    wire [15:0] signal_mux_574;
    wire signal_select_227;
    wire [15:0] signal_mux_575;
    wire signal_select_228;
    wire [15:0] signal_mux_576;
    wire [3:0] signal_select_229;
    wire signal_select_230;
    wire [15:0] signal_mux_577;
    wire signal_eq_162;
    wire signal_not_165;
    wire signal_lt_22;
    wire signal_and_177;
    wire [15:0] signal_const_659;
    wire signal_lt_23;
    wire [3:0] signal_select_231;
    wire signal_eq_163;
    wire [15:0] signal_mux_578;
    wire [15:0] signal_mux_579;
    wire [15:0] signal_mux_580;
    wire [15:0] signal_mux_581;
    wire [15:0] signal_mux_582;
    wire [15:0] signal_mux_583;
    wire [15:0] signal_mux_584;
    wire [15:0] signal_wire_102;
    reg [15:0] execution$reg_desc_control;
    wire [3:0] signal_select_232;
    wire signal_eq_164;
    wire [15:0] signal_mux_585;
    wire [15:0] signal_mux_586;
    wire [15:0] signal_mux_587;
    wire [15:0] signal_mux_588;
    wire [15:0] signal_mux_589;
    wire [15:0] signal_mux_590;
    wire [15:0] signal_mux_591;
    wire [15:0] signal_wire_103;
    reg [15:0] execution$reg_desc_bit_count;
    wire [3:0] signal_select_233;
    wire signal_eq_165;
    wire [15:0] signal_mux_592;
    wire [15:0] signal_mux_593;
    wire [15:0] signal_mux_594;
    wire [15:0] signal_mux_595;
    wire [15:0] signal_mux_596;
    wire [15:0] signal_mux_597;
    wire [15:0] signal_mux_598;
    wire [15:0] signal_wire_104;
    reg [15:0] execution$reg_desc_tx_value;
    wire [3:0] signal_select_234;
    wire signal_eq_166;
    wire [15:0] signal_mux_599;
    wire [15:0] signal_mux_600;
    wire [15:0] signal_mux_601;
    wire [15:0] signal_mux_602;
    wire [15:0] signal_mux_603;
    wire [15:0] signal_mux_604;
    wire [15:0] signal_mux_605;
    wire [15:0] signal_wire_105;
    reg [15:0] execution$reg_desc_output_pin;
    wire [3:0] signal_select_235;
    wire signal_eq_167;
    wire [15:0] signal_mux_606;
    wire [15:0] signal_mux_607;
    wire [15:0] signal_mux_608;
    wire [15:0] signal_mux_609;
    wire [15:0] signal_mux_610;
    wire [15:0] signal_mux_611;
    wire [15:0] signal_mux_612;
    wire [15:0] signal_wire_106;
    reg [15:0] execution$reg_desc_input_pin;
    wire [3:0] signal_select_236;
    wire signal_eq_168;
    wire [15:0] signal_mux_613;
    wire [15:0] signal_mux_614;
    wire [15:0] signal_mux_615;
    wire [15:0] signal_mux_616;
    wire [15:0] signal_mux_617;
    wire [15:0] signal_mux_618;
    wire [15:0] signal_mux_619;
    wire [15:0] signal_wire_107;
    reg [15:0] execution$reg_desc_clock_pin;
    wire [3:0] signal_select_237;
    wire signal_eq_169;
    wire [15:0] signal_mux_620;
    wire [15:0] signal_mux_621;
    wire [15:0] signal_mux_622;
    wire [15:0] signal_mux_623;
    wire [15:0] signal_mux_624;
    wire [15:0] signal_mux_625;
    wire [15:0] signal_mux_626;
    wire [15:0] signal_wire_108;
    reg [15:0] execution$reg_desc_initial_delay;
    wire [3:0] signal_select_238;
    wire signal_eq_170;
    wire [15:0] signal_mux_627;
    wire [15:0] signal_mux_628;
    wire [15:0] signal_mux_629;
    wire [15:0] signal_mux_630;
    wire [15:0] signal_mux_631;
    wire [15:0] signal_mux_632;
    wire [15:0] signal_mux_633;
    wire [15:0] signal_wire_109;
    reg [15:0] execution$reg_desc_half_period;
    wire [3:0] signal_select_239;
    wire signal_eq_171;
    wire [15:0] signal_mux_634;
    wire [15:0] signal_mux_635;
    wire signal_eq_172;
    wire signal_and_178;
    wire [15:0] signal_mux_636;
    wire [15:0] signal_mux_637;
    wire [15:0] signal_mux_638;
    wire [15:0] signal_mux_639;
    wire [15:0] signal_mux_640;
    wire [15:0] signal_wire_110;
    reg [15:0] execution$reg_desc_pacing;
    wire [143:0] signal_cat_45;
    wire [143:0] signal_wire_111;
    wire [15:0] signal_select_240;
    wire signal_eq_173;
    wire signal_or_104;
    wire signal_or_105;
    wire signal_or_106;
    wire signal_or_107;
    wire signal_or_108;
    wire signal_or_109;
    wire signal_or_110;
    wire signal_or_111;
    wire signal_not_166;
    wire [3:0] signal_const_680;
    wire signal_eq_174;
    wire signal_and_179;
    wire signal_and_180;
    wire signal_and_181;
    wire signal_and_182;
    wire signal_and_183;
    wire signal_and_184;
    wire signal_or_112;
    wire signal_and_185;
    wire signal_or_113;
    wire signal_or_114;
    wire signal_or_115;
    wire signal_or_116;
    wire [7:0] signal_mux_641;
    wire signal_not_167;
    wire signal_or_117;
    wire [7:0] signal_mux_642;
    wire [7:0] signal_wire_112;
    reg [7:0] mechanisms$bank$reg_engine_claim;
    wire [7:0] signal_wire_113;
    wire [7:0] signal_select_241;
    wire [7:0] signal_and_186;
    wire signal_eq_175;
    wire signal_not_168;
    wire signal_not_169;
    wire signal_or_118;
    wire signal_and_187;
    wire signal_and_188;
    wire signal_or_119;
    wire signal_or_120;
    wire signal_or_121;
    wire signal_or_122;
    wire [5:0] signal_mux_643;
    wire [5:0] signal_const_681;
    wire signal_not_170;
    wire signal_eq_176;
    wire signal_not_171;
    wire signal_eq_177;
    wire signal_not_172;
    wire signal_and_189;
    wire signal_wire_114;
    wire signal_or_123;
    wire signal_and_190;
    wire [5:0] signal_mux_644;
    wire [5:0] signal_const_685;
    wire [15:0] signal_mux_645;
    wire [15:0] signal_mux_646;
    wire [15:0] signal_mux_647;
    wire [15:0] signal_wire_115;
    reg [15:0] mechanisms$timing$reg_period;
    wire [15:0] signal_sub_9;
    wire [15:0] signal_mux_648;
    wire [15:0] signal_mux_649;
    wire [15:0] signal_mux_650;
    wire [15:0] signal_mux_651;
    wire [15:0] signal_mux_652;
    wire [15:0] signal_mux_653;
    wire [15:0] signal_wire_116;
    reg [15:0] mechanisms$timing$reg_phase;
    wire signal_eq_178;
    wire signal_mux_654;
    wire signal_not_173;
    wire signal_not_174;
    wire signal_eq_179;
    wire signal_mux_655;
    wire [3:0] signal_const_701;
    wire signal_eq_180;
    wire signal_and_191;
    wire signal_mux_656;
    wire signal_eq_181;
    wire signal_not_175;
    wire [3:0] signal_const_703;
    wire signal_eq_182;
    wire signal_and_192;
    wire signal_and_193;
    wire signal_mux_657;
    wire signal_mux_658;
    wire signal_wire_117;
    reg mechanisms$timing$reg_periodic_active;
    wire signal_and_194;
    wire signal_and_195;
    wire signal_mux_659;
    wire signal_mux_660;
    wire signal_wire_118;
    reg mechanisms$timing$reg_tick;
    wire signal_wire_119;
    wire [5:0] signal_mux_661;
    wire [5:0] signal_const_704;
    wire signal_eq_183;
    wire signal_mux_662;
    wire [15:0] signal_sub_10;
    wire signal_eq_184;
    wire signal_or_124;
    wire [15:0] signal_mux_663;
    wire [15:0] signal_mux_664;
    wire [15:0] signal_mux_665;
    wire [15:0] signal_mux_666;
    wire [15:0] signal_mux_667;
    wire [15:0] signal_mux_668;
    wire [15:0] signal_mux_669;
    wire [15:0] signal_mux_670;
    wire [15:0] signal_wire_120;
    reg [15:0] mechanisms$timing$reg_remaining;
    wire signal_eq_185;
    wire signal_mux_671;
    wire signal_mux_672;
    wire signal_mux_673;
    wire signal_mux_674;
    wire signal_mux_675;
    wire signal_wire_121;
    reg mechanisms$timing$reg_timeout_enable;
    wire signal_eq_186;
    wire signal_or_125;
    wire signal_and_196;
    wire signal_mux_676;
    wire signal_select_242;
    wire signal_select_243;
    wire signal_select_244;
    wire signal_select_245;
    wire signal_select_246;
    wire signal_select_247;
    wire signal_select_248;
    wire signal_select_249;
    reg signal_mux_677;
    wire signal_select_250;
    wire signal_select_251;
    wire signal_select_252;
    wire signal_select_253;
    wire signal_select_254;
    wire signal_select_255;
    wire signal_select_256;
    wire [7:0] signal_not_176;
    wire [7:0] signal_and_197;
    wire [7:0] signal_or_126;
    wire [7:0] signal_wire_122;
    reg [7:0] mechanisms$events$reg_previous;
    wire [7:0] signal_not_177;
    wire [7:0] signal_and_198;
    wire signal_mux_678;
    wire signal_wire_123;
    reg mechanisms$reg_wait_either;
    wire [7:0] signal_mux_679;
    wire signal_select_257;
    reg signal_mux_680;
    wire signal_mux_681;
    wire signal_mux_682;
    wire signal_mux_683;
    wire signal_mux_684;
    wire signal_mux_685;
    wire signal_wire_124;
    reg mechanisms$timing$reg_level;
    wire signal_select_258;
    wire signal_select_259;
    wire signal_select_260;
    wire signal_select_261;
    wire signal_select_262;
    wire signal_select_263;
    wire signal_select_264;
    wire signal_select_265;
    wire [2:0] signal_mux_686;
    wire [2:0] signal_mux_687;
    wire [2:0] signal_mux_688;
    wire [2:0] signal_mux_689;
    wire [2:0] signal_mux_690;
    wire [2:0] signal_wire_125;
    reg [2:0] mechanisms$timing$reg_pin;
    reg signal_mux_691;
    wire signal_eq_187;
    wire signal_select_266;
    wire signal_select_267;
    wire signal_select_268;
    wire signal_select_269;
    wire signal_select_270;
    wire signal_select_271;
    wire signal_select_272;
    wire signal_select_273;
    wire signal_select_274;
    wire [2:0] signal_select_275;
    reg signal_mux_692;
    wire signal_eq_188;
    wire signal_eq_189;
    wire signal_and_199;
    wire [1:0] signal_mux_693;
    wire [15:0] signal_mux_694;
    wire signal_eq_190;
    wire signal_select_276;
    wire signal_select_277;
    wire signal_eq_191;
    wire signal_mux_695;
    wire signal_eq_192;
    wire signal_mux_696;
    wire signal_wire_126;
    wire [1:0] signal_select_278;
    wire [1:0] signal_add_24;
    wire [1:0] signal_select_279;
    wire signal_eq_193;
    wire signal_eq_194;
    wire signal_and_200;
    wire signal_and_201;
    wire [1:0] signal_mux_697;
    wire signal_eq_195;
    wire signal_and_202;
    wire [1:0] signal_mux_698;
    wire [1:0] signal_mux_699;
    wire signal_eq_196;
    wire signal_or_127;
    wire signal_and_203;
    wire [1:0] signal_mux_700;
    wire [1:0] signal_mux_701;
    wire [1:0] signal_mux_702;
    wire [1:0] signal_mux_703;
    wire [1:0] signal_wire_127;
    reg [1:0] mechanisms$timing$reg_kind;
    reg signal_mux_704;
    wire signal_mux_705;
    wire signal_mux_706;
    wire signal_mux_707;
    wire signal_wire_128;
    reg mechanisms$timing$reg_timeout;
    wire signal_wire_129;
    wire signal_and_204;
    wire [5:0] signal_mux_708;
    wire signal_not_178;
    wire signal_and_205;
    wire signal_and_206;
    wire [5:0] signal_mux_709;
    wire signal_mux_710;
    wire signal_wire_130;
    reg mechanisms$reg_wait_is_delay;
    wire signal_and_207;
    wire signal_and_208;
    wire [5:0] signal_mux_711;
    wire [5:0] signal_or_128;
    wire [5:0] signal_or_129;
    wire [5:0] signal_or_130;
    wire [5:0] signal_or_131;
    wire [5:0] signal_or_132;
    wire [5:0] signal_wire_131;
    wire [5:0] signal_select_280;
    wire signal_and_209;
    wire [5:0] signal_mux_712;
    wire [5:0] signal_wire_132;
    wire [5:0] signal_not_179;
    wire [5:0] signal_and_210;
    wire [5:0] signal_or_133;
    wire [5:0] signal_wire_133;
    reg [5:0] mechanisms$events$reg_event;
    wire [15:0] signal_cat_46;
    wire signal_select_281;
    wire signal_select_282;
    wire signal_select_283;
    wire signal_select_284;
    wire signal_select_285;
    wire signal_select_286;
    wire signal_select_287;
    wire signal_select_288;
    wire signal_not_180;
    wire signal_or_134;
    wire [7:0] signal_wire_134;
    wire [7:0] signal_wire_135;
    reg [7:0] mechanisms$events$reg_stage0;
    wire [7:0] signal_wire_136;
    reg [7:0] mechanisms$events$reg_stage1;
    wire signal_select_289;
    wire [2:0] signal_select_290;
    reg signal_mux_713;
    wire signal_eq_197;
    wire [15:0] signal_cat_47;
    wire signal_eq_198;
    wire signal_and_211;
    reg [7:0] signal_reg_13;
    wire signal_eq_199;
    wire signal_and_212;
    reg [7:0] signal_reg_14;
    wire signal_eq_200;
    wire signal_and_213;
    reg [7:0] signal_reg_15;
    wire signal_eq_201;
    wire signal_and_214;
    reg [7:0] signal_reg_16;
    wire signal_eq_202;
    wire signal_and_215;
    reg [7:0] signal_reg_17;
    wire signal_eq_203;
    wire signal_and_216;
    reg [7:0] signal_reg_18;
    wire signal_eq_204;
    wire signal_and_217;
    reg [7:0] signal_reg_19;
    wire [3:0] signal_add_25;
    wire signal_eq_205;
    wire [3:0] signal_mux_714;
    wire [3:0] signal_mux_715;
    wire [3:0] signal_mux_716;
    wire [3:0] signal_wire_137;
    reg [3:0] mechanisms$rx_fifo$reg_write_index;
    wire signal_eq_206;
    wire signal_and_218;
    wire [7:0] signal_wire_138;
    wire [7:0] signal_mux_717;
    wire [7:0] signal_wire_139;
    reg [7:0] signal_reg_20;
    wire [3:0] signal_add_26;
    wire signal_eq_207;
    wire [3:0] signal_mux_718;
    wire [3:0] signal_mux_719;
    wire [3:0] signal_mux_720;
    wire [3:0] signal_wire_140;
    reg [3:0] mechanisms$rx_fifo$reg_read_index;
    reg [7:0] signal_mux_721;
    wire [7:0] signal_mux_722;
    wire signal_eq_208;
    wire signal_and_219;
    reg [7:0] signal_reg_21;
    wire signal_eq_209;
    wire signal_and_220;
    reg [7:0] signal_reg_22;
    wire signal_eq_210;
    wire signal_and_221;
    reg [7:0] signal_reg_23;
    wire signal_eq_211;
    wire signal_and_222;
    reg [7:0] signal_reg_24;
    wire signal_eq_212;
    wire signal_and_223;
    reg [7:0] signal_reg_25;
    wire signal_eq_213;
    wire signal_and_224;
    reg [7:0] signal_reg_26;
    wire signal_eq_214;
    wire signal_and_225;
    reg [7:0] signal_reg_27;
    wire [3:0] signal_add_27;
    wire signal_eq_215;
    wire [3:0] signal_mux_723;
    wire [3:0] signal_mux_724;
    wire [3:0] signal_mux_725;
    wire [3:0] signal_wire_141;
    reg [3:0] mechanisms$tx_fifo$reg_write_index;
    wire signal_eq_216;
    wire signal_and_226;
    wire [7:0] signal_select_291;
    wire [7:0] signal_mux_726;
    wire [7:0] signal_wire_142;
    reg [7:0] mechanisms$reg_fifo_data;
    wire [7:0] signal_select_292;
    wire [7:0] signal_mux_727;
    wire [7:0] signal_wire_143;
    reg [7:0] signal_reg_28;
    wire [3:0] signal_add_28;
    wire signal_eq_217;
    wire [3:0] signal_mux_728;
    wire [3:0] signal_mux_729;
    wire [3:0] signal_mux_730;
    wire [3:0] signal_wire_144;
    reg [3:0] mechanisms$tx_fifo$reg_read_index;
    reg [7:0] signal_mux_731;
    wire [7:0] signal_mux_732;
    wire [7:0] signal_mux_733;
    wire [15:0] signal_cat_48;
    wire [15:0] signal_mux_734;
    wire [15:0] signal_mux_735;
    wire [15:0] signal_mux_736;
    wire [15:0] signal_mux_737;
    wire signal_not_181;
    wire signal_mux_738;
    wire signal_not_182;
    wire signal_and_227;
    wire [4:0] signal_const_807;
    wire [4:0] signal_sub_11;
    wire [4:0] signal_add_29;
    wire signal_not_183;
    wire signal_and_228;
    wire [4:0] signal_mux_739;
    wire signal_not_184;
    wire signal_and_229;
    wire signal_wire_145;
    wire signal_and_230;
    wire signal_not_185;
    wire signal_not_186;
    wire signal_wire_146;
    wire signal_and_231;
    wire signal_not_187;
    wire signal_not_188;
    wire signal_mux_740;
    wire signal_mux_741;
    wire signal_wire_147;
    reg mechanisms$reg_fifo_push;
    wire signal_not_189;
    wire signal_and_232;
    wire signal_and_233;
    wire signal_and_234;
    wire [4:0] signal_sub_12;
    wire [4:0] signal_add_30;
    wire signal_not_190;
    wire signal_and_235;
    wire [4:0] signal_mux_742;
    wire signal_lt_24;
    wire signal_or_135;
    wire signal_and_236;
    wire signal_not_191;
    wire signal_wire_148;
    wire signal_and_237;
    wire signal_not_192;
    wire signal_and_238;
    wire signal_and_239;
    wire signal_or_136;
    wire signal_and_240;
    wire signal_or_137;
    wire signal_wire_149;
    wire signal_and_241;
    wire signal_not_193;
    wire signal_mux_743;
    wire signal_wire_150;
    reg mechanisms$reg_fifo_rx;
    wire signal_mux_744;
    wire signal_and_242;
    wire signal_wire_151;
    wire signal_and_243;
    wire signal_and_244;
    wire [4:0] signal_mux_745;
    wire signal_not_194;
    wire [4:0] signal_mux_746;
    wire [4:0] signal_wire_152;
    reg [4:0] mechanisms$rx_fifo$reg_count;
    wire signal_eq_218;
    wire signal_not_195;
    wire signal_and_245;
    wire signal_mux_747;
    wire [3:0] signal_const_820;
    wire signal_eq_219;
    wire signal_and_246;
    wire signal_and_247;
    wire signal_or_138;
    wire signal_and_248;
    wire signal_or_139;
    wire signal_wire_153;
    wire signal_eq_220;
    wire signal_not_196;
    wire signal_and_249;
    wire signal_and_250;
    wire signal_and_251;
    wire [4:0] signal_mux_748;
    wire signal_not_197;
    wire [4:0] signal_mux_749;
    wire [4:0] signal_wire_154;
    reg [4:0] mechanisms$tx_fifo$reg_count;
    wire signal_lt_25;
    wire signal_or_140;
    wire signal_and_252;
    wire signal_select_293;
    wire [15:0] signal_cat_49;
    wire signal_select_294;
    wire [15:0] signal_cat_50;
    wire [2:0] signal_select_295;
    wire [12:0] signal_const_832;
    wire [15:0] signal_cat_51;
    wire [2:0] signal_select_296;
    wire [15:0] signal_cat_52;
    wire [2:0] signal_select_297;
    reg [15:0] signal_mux_750;
    wire signal_select_298;
    wire [15:0] signal_cat_53;
    wire signal_select_299;
    wire [15:0] signal_cat_54;
    wire [2:0] signal_select_300;
    wire [15:0] signal_cat_55;
    wire [5:0] signal_select_301;
    wire [15:0] signal_cat_56;
    wire [2:0] signal_select_302;
    wire [15:0] signal_cat_57;
    wire [2:0] signal_select_303;
    wire [15:0] signal_cat_58;
    reg [15:0] signal_mux_751;
    wire [15:0] signal_wire_155;
    wire signal_select_304;
    wire signal_mux_752;
    wire signal_not_198;
    wire [2:0] signal_select_305;
    reg [15:0] signal_mux_753;
    wire [2:0] signal_select_306;
    reg [15:0] signal_mux_754;
    reg [15:0] signal_mux_755;
    wire [15:0] signal_wire_156;
    wire [7:0] signal_select_307;
    wire signal_eq_221;
    wire signal_not_199;
    wire signal_and_253;
    wire signal_not_200;
    wire [3:0] signal_const_879;
    wire signal_eq_222;
    wire signal_and_254;
    wire signal_and_255;
    wire signal_and_256;
    wire signal_or_141;
    wire signal_select_308;
    wire signal_not_201;
    wire signal_and_257;
    wire signal_mux_756;
    wire signal_mux_757;
    wire signal_mux_758;
    wire signal_wire_157;
    reg mechanisms$reg_fifo_pending;
    wire signal_and_258;
    wire signal_and_259;
    wire signal_and_260;
    wire signal_or_142;
    wire [15:0] signal_mux_759;
    wire [15:0] signal_wire_158;
    wire [2:0] signal_select_309;
    reg [15:0] signal_mux_760;
    wire [15:0] signal_xor_3;
    wire [15:0] signal_or_143;
    wire [15:0] signal_and_261;
    wire [15:0] signal_sub_13;
    wire [2:0] signal_select_310;
    reg [15:0] signal_mux_761;
    wire [16:0] signal_cat_59;
    reg [15:0] signal_mux_762;
    wire [16:0] signal_cat_60;
    wire [16:0] signal_add_31;
    wire [15:0] signal_select_311;
    wire [2:0] signal_select_312;
    reg [15:0] signal_mux_763;
    wire [15:0] signal_xor_4;
    wire [15:0] signal_or_144;
    wire [15:0] signal_and_262;
    wire [15:0] signal_sub_14;
    wire [15:0] signal_wire_159;
    wire [15:0] signal_mux_764;
    wire signal_not_202;
    wire signal_and_263;
    wire signal_and_264;
    wire signal_and_265;
    wire [15:0] signal_mux_765;
    wire [15:0] signal_mux_766;
    wire [15:0] signal_mux_767;
    wire [15:0] signal_mux_768;
    wire [15:0] signal_mux_769;
    wire [15:0] signal_wire_160;
    reg [15:0] execution$reg_extension_word;
    wire signal_eq_223;
    wire [15:0] signal_mux_770;
    wire [5:0] signal_select_313;
    wire [15:0] signal_cat_61;
    wire [9:0] signal_select_314;
    wire [15:0] signal_cat_62;
    wire [3:0] signal_select_315;
    wire [11:0] signal_const_897;
    wire [15:0] signal_cat_63;
    wire [4:0] signal_select_316;
    wire [15:0] signal_cat_64;
    wire [9:0] signal_select_317;
    wire [15:0] signal_cat_65;
    wire [6:0] signal_select_318;
    wire [15:0] signal_cat_66;
    wire [3:0] signal_select_319;
    wire [15:0] signal_cat_67;
    wire [6:0] signal_select_320;
    wire [15:0] signal_cat_68;
    reg [15:0] signal_mux_771;
    wire signal_select_321;
    wire signal_select_322;
    wire signal_select_323;
    wire signal_select_324;
    wire signal_select_325;
    wire vdd;
    wire signal_select_326;
    wire signal_select_327;
    wire signal_select_328;
    reg signal_mux_772;
    wire [15:0] signal_mux_773;
    wire [16:0] signal_cat_69;
    reg [15:0] signal_mux_774;
    wire gnd;
    wire [16:0] signal_cat_70;
    wire [16:0] signal_add_32;
    wire [15:0] signal_select_329;
    wire [2:0] signal_select_330;
    reg [15:0] signal_mux_775;
    wire [7:0] signal_select_331;
    wire [15:0] signal_cat_71;
    wire [11:0] signal_select_332;
    wire [15:0] signal_cat_72;
    wire [13:0] signal_select_333;
    wire [15:0] signal_cat_73;
    wire [14:0] signal_select_334;
    wire [15:0] signal_cat_74;
    wire signal_select_335;
    wire [15:0] signal_mux_776;
    wire signal_select_336;
    wire [15:0] signal_mux_777;
    wire signal_select_337;
    wire [15:0] signal_mux_778;
    wire signal_select_338;
    wire [15:0] signal_mux_779;
    wire [7:0] signal_select_339;
    wire [15:0] signal_cat_75;
    wire [11:0] signal_select_340;
    wire [15:0] signal_cat_76;
    wire [13:0] signal_select_341;
    wire [15:0] signal_cat_77;
    wire [14:0] signal_select_342;
    wire [15:0] signal_cat_78;
    reg [15:0] signal_mux_780;
    wire signal_select_343;
    wire [15:0] signal_mux_781;
    wire signal_select_344;
    wire [15:0] signal_mux_782;
    wire signal_select_345;
    wire [15:0] signal_mux_783;
    wire [3:0] signal_select_346;
    wire signal_select_347;
    wire [15:0] signal_mux_784;
    wire signal_select_348;
    wire [15:0] signal_mux_785;
    wire signal_eq_224;
    wire [15:0] signal_mux_786;
    wire [15:0] signal_mux_787;
    wire [15:0] signal_mux_788;
    wire [15:0] signal_mux_789;
    wire [15:0] signal_mux_790;
    wire [15:0] signal_mux_791;
    wire [15:0] signal_mux_792;
    wire [15:0] signal_wire_161;
    reg [15:0] execution$reg_r7;
    wire signal_eq_225;
    wire [15:0] signal_mux_793;
    wire [15:0] signal_mux_794;
    wire [15:0] signal_mux_795;
    wire [15:0] signal_mux_796;
    wire [15:0] signal_mux_797;
    wire [15:0] signal_mux_798;
    wire [15:0] signal_mux_799;
    wire [15:0] signal_wire_162;
    reg [15:0] execution$reg_r6;
    wire signal_eq_226;
    wire [15:0] signal_mux_800;
    wire [15:0] signal_mux_801;
    wire [15:0] signal_mux_802;
    wire [15:0] signal_mux_803;
    wire [15:0] signal_mux_804;
    wire [15:0] signal_mux_805;
    wire [15:0] signal_mux_806;
    wire [15:0] signal_wire_163;
    reg [15:0] execution$reg_r5;
    wire signal_eq_227;
    wire [15:0] signal_mux_807;
    wire [15:0] signal_mux_808;
    wire [15:0] signal_mux_809;
    wire [15:0] signal_mux_810;
    wire [15:0] signal_mux_811;
    wire [15:0] signal_mux_812;
    wire [15:0] signal_mux_813;
    wire [15:0] signal_wire_164;
    reg [15:0] execution$reg_r4;
    wire signal_eq_228;
    wire [15:0] signal_mux_814;
    wire [15:0] signal_mux_815;
    wire [15:0] signal_mux_816;
    wire [15:0] signal_mux_817;
    wire [15:0] signal_mux_818;
    wire [15:0] signal_mux_819;
    wire [15:0] signal_mux_820;
    wire [15:0] signal_wire_165;
    reg [15:0] execution$reg_r3;
    wire signal_eq_229;
    wire [15:0] signal_mux_821;
    wire [15:0] signal_mux_822;
    wire [15:0] signal_mux_823;
    wire [15:0] signal_mux_824;
    wire [15:0] signal_mux_825;
    wire [15:0] signal_mux_826;
    wire [15:0] signal_mux_827;
    wire [15:0] signal_wire_166;
    reg [15:0] execution$reg_r2;
    wire signal_wire_167;
    wire signal_eq_230;
    wire [15:0] signal_mux_828;
    wire [15:0] signal_mux_829;
    wire [15:0] signal_mux_830;
    wire [15:0] signal_mux_831;
    wire [15:0] signal_mux_832;
    wire [15:0] signal_mux_833;
    wire [15:0] signal_mux_834;
    wire [15:0] signal_wire_168;
    reg [15:0] execution$reg_r1;
    reg [15:0] signal_mux_835;
    wire [15:0] signal_sub_15;
    wire [16:0] signal_add_33;
    wire [15:0] signal_select_349;
    wire signal_eq_231;
    wire [15:0] signal_mux_836;
    wire signal_eq_232;
    wire [15:0] signal_mux_837;
    wire signal_eq_233;
    wire [15:0] signal_mux_838;
    wire signal_eq_234;
    wire [15:0] signal_mux_839;
    wire signal_eq_235;
    wire [15:0] signal_mux_840;
    wire signal_eq_236;
    wire [15:0] signal_mux_841;
    wire [15:0] signal_mux_842;
    wire [2:0] signal_select_350;
    wire [2:0] signal_select_351;
    wire [2:0] signal_select_352;
    wire [4:0] signal_const_949;
    wire signal_eq_237;
    wire [2:0] signal_mux_843;
    wire signal_eq_238;
    wire [2:0] signal_mux_844;
    wire [2:0] signal_select_353;
    wire [2:0] signal_select_354;
    wire [2:0] signal_select_355;
    wire [2:0] signal_select_356;
    wire [2:0] signal_select_357;
    wire [2:0] signal_select_358;
    wire [2:0] signal_select_359;
    wire signal_eq_239;
    wire [2:0] signal_mux_845;
    wire signal_eq_240;
    wire [2:0] signal_mux_846;
    wire signal_eq_241;
    wire [2:0] signal_mux_847;
    wire signal_eq_242;
    wire [2:0] signal_mux_848;
    wire signal_eq_243;
    wire [2:0] signal_mux_849;
    wire signal_eq_244;
    wire [2:0] signal_mux_850;
    wire [2:0] signal_mux_851;
    wire signal_eq_245;
    wire [15:0] signal_mux_852;
    wire [15:0] signal_mux_853;
    wire [4:0] signal_const_958;
    wire signal_eq_246;
    wire signal_eq_247;
    wire signal_eq_248;
    wire signal_or_145;
    wire signal_or_146;
    wire signal_and_266;
    wire signal_eq_249;
    wire signal_eq_250;
    wire signal_eq_251;
    wire signal_eq_252;
    wire signal_eq_253;
    wire signal_eq_254;
    wire signal_eq_255;
    wire signal_or_147;
    wire signal_or_148;
    wire signal_or_149;
    wire signal_or_150;
    wire signal_or_151;
    wire signal_or_152;
    wire signal_and_267;
    wire signal_or_153;
    wire [15:0] signal_mux_854;
    wire [15:0] signal_mux_855;
    wire [15:0] signal_mux_856;
    wire [15:0] signal_mux_857;
    wire [15:0] signal_mux_858;
    wire [15:0] signal_wire_169;
    reg [15:0] execution$reg_r0;
    wire [2:0] signal_select_360;
    reg [15:0] signal_mux_859;
    wire [7:0] signal_select_361;
    wire [15:0] signal_cat_79;
    wire signal_select_362;
    wire [15:0] signal_cat_80;
    reg [15:0] signal_mux_860;
    wire [15:0] signal_wire_170;
    wire [7:0] signal_select_363;
    wire signal_eq_256;
    wire signal_eq_257;
    wire signal_and_268;
    wire signal_eq_258;
    wire signal_and_269;
    wire signal_or_154;
    wire signal_and_270;
    wire signal_and_271;
    wire signal_and_272;
    wire signal_eq_259;
    wire signal_and_273;
    wire signal_eq_260;
    wire signal_and_274;
    wire signal_eq_261;
    wire signal_and_275;
    reg [3:0] signal_mux_861;
    wire [3:0] signal_wire_171;
    wire signal_eq_262;
    wire signal_and_276;
    wire signal_or_155;
    wire signal_or_156;
    wire signal_or_157;
    wire signal_or_158;
    wire signal_or_159;
    wire signal_or_160;
    wire signal_or_161;
    wire signal_or_162;
    wire signal_or_163;
    wire signal_or_164;
    wire signal_or_165;
    wire signal_wire_172;
    wire signal_and_277;
    wire signal_and_278;
    wire signal_and_279;
    wire signal_or_166;
    wire signal_and_280;
    wire [16:0] signal_mux_862;
    wire [16:0] signal_mux_863;
    wire [16:0] signal_mux_864;
    wire [16:0] signal_mux_865;
    wire [16:0] signal_mux_866;
    wire [16:0] signal_wire_173;
    reg [16:0] execution$reg_pc;
    wire [7:0] signal_select_364;
    wire signal_eq_263;
    wire signal_eq_264;
    wire signal_and_281;
    wire signal_or_167;
    wire signal_and_282;
    wire [15:0] signal_mux_867;
    wire [15:0] signal_mux_868;
    wire [15:0] signal_mux_869;
    wire [15:0] signal_mux_870;
    wire [15:0] signal_mux_871;
    wire [15:0] signal_mux_872;
    wire [15:0] signal_wire_174;
    reg [15:0] execution$reg_base_word;
    wire [15:0] signal_mux_873;
    wire [4:0] signal_select_365;
    wire signal_eq_265;
    wire signal_or_168;
    wire signal_or_169;
    wire signal_or_170;
    wire signal_or_171;
    wire signal_or_172;
    wire signal_or_173;
    wire signal_or_174;
    wire signal_or_175;
    wire signal_or_176;
    wire signal_or_177;
    wire signal_or_178;
    wire signal_or_179;
    wire signal_or_180;
    wire signal_not_203;
    wire signal_and_283;
    wire signal_or_181;
    wire signal_and_284;
    wire signal_wire_175;
    wire signal_and_285;
    wire signal_and_286;
    wire signal_and_287;
    wire signal_and_288;
    wire signal_or_182;
    wire signal_or_183;
    wire signal_or_184;
    wire signal_and_289;
    wire signal_and_290;
    wire signal_and_291;
    wire signal_mux_874;
    wire signal_mux_875;
    wire signal_mux_876;
    wire signal_wire_176;
    reg mechanisms$timing$reg_busy;
    wire signal_mux_877;
    wire signal_not_204;
    wire signal_or_185;
    wire signal_mux_878;
    wire signal_wire_177;
    reg mechanisms$timing$reg_complete;
    wire signal_wire_178;
    wire signal_or_186;
    wire signal_and_292;
    wire signal_and_293;
    wire signal_and_294;
    wire signal_and_295;
    wire signal_mux_879;
    wire signal_not_205;
    wire signal_or_187;
    wire signal_mux_880;
    wire signal_wire_179;
    reg mechanisms$reg_wait_pending;
    wire signal_not_206;
    wire signal_and_296;
    wire signal_and_297;
    wire signal_and_298;
    wire signal_and_299;
    wire signal_and_300;
    wire signal_and_301;
    wire signal_and_302;
    wire signal_wire_180;
    wire signal_not_207;
    wire signal_not_208;
    wire signal_not_209;
    wire signal_and_303;
    wire signal_and_304;
    wire signal_and_305;
    wire signal_and_306;
    wire signal_and_307;
    wire signal_and_308;
    wire signal_and_309;
    wire signal_and_310;
    wire signal_wire_181;
    wire signal_not_210;
    wire signal_not_211;
    wire signal_not_212;
    wire signal_wire_182;
    wire signal_and_311;
    wire signal_and_312;
    wire signal_and_313;
    wire signal_not_213;
    wire signal_not_214;
    wire signal_wire_183;
    wire signal_and_314;
    wire signal_and_315;
    wire signal_and_316;
    wire signal_or_188;
    wire signal_wire_184;
    wire signal_not_215;
    wire signal_wire_185;
    wire signal_not_216;
    wire signal_wire_186;
    wire signal_not_217;
    wire signal_wire_187;
    wire signal_not_218;
    wire signal_wire_188;
    wire signal_not_219;
    wire signal_and_317;
    wire signal_and_318;
    wire signal_and_319;
    wire signal_and_320;
    wire signal_and_321;
    wire signal_and_322;
    wire signal_and_323;
    wire signal_and_324;
    wire signal_and_325;
    wire signal_or_189;
    wire signal_or_190;
    wire signal_mux_881;
    wire signal_wire_189;
    reg reg_stop_pending;
    wire signal_or_191;
    wire signal_and_326;
    wire signal_or_192;
    wire [2:0] signal_mux_882;
    wire signal_not_220;
    wire signal_wire_190;
    wire signal_and_327;
    wire signal_and_328;
    wire [2:0] signal_mux_883;
    wire signal_not_221;
    wire [2:0] signal_mux_884;
    wire [2:0] signal_mux_885;
    wire [2:0] signal_wire_191;
    reg [2:0] execution$reg_phase;
    wire signal_eq_266;
    wire signal_and_329;
    wire signal_and_330;
    wire signal_and_331;
    wire signal_or_193;
    wire signal_and_332;
    wire signal_and_333;
    wire signal_and_334;
    wire signal_or_194;
    wire signal_wire_192;
    wire signal_or_195;
    wire signal_or_196;
    wire signal_wire_193;
    wire signal_not_222;
    wire signal_and_335;
    wire signal_and_336;
    wire signal_and_337;
    wire signal_mux_886;
    wire signal_mux_887;
    wire signal_wire_194;
    reg signal_reg_29;
    wire signal_not_223;
    wire signal_or_197;
    wire signal_wire_195;
    wire signal_not_224;
    wire signal_and_338;
    wire signal_and_339;
    wire signal_and_340;
    wire signal_and_341;
    wire signal_and_342;
    wire signal_mux_888;
    wire signal_not_225;
    wire signal_mux_889;
    wire signal_wire_196;
    reg signal_reg_30;
    wire signal_not_226;
    wire signal_wire_197;
    wire signal_and_343;
    wire signal_and_344;
    wire signal_and_345;
    wire signal_and_346;
    wire signal_and_347;
    wire signal_and_348;
    wire signal_and_349;
    wire signal_and_350;
    wire signal_and_351;
    wire signal_or_198;
    wire signal_and_352;
    assign signal_not = ~ signal_and_240;
    assign signal_and = signal_and_236 & signal_not;
    assign signal_not_1 = ~ signal_and_248;
    assign signal_and_1 = signal_and_249 & signal_not_1;
    assign signal_const = 32'b00000000000000000000000000000000;
    assign signal_mux = signal_or_90 ? mechanisms$lane$reg_rx_value : signal_const;
    assign signal_select = mechanisms$events$reg_stage1[7:7];
    assign signal_select_1 = mechanisms$events$reg_stage1[6:6];
    assign signal_select_2 = mechanisms$events$reg_stage1[5:5];
    assign signal_select_3 = mechanisms$events$reg_stage1[4:4];
    assign signal_select_4 = mechanisms$events$reg_stage1[3:3];
    assign signal_select_5 = mechanisms$events$reg_stage1[2:2];
    assign signal_select_6 = mechanisms$events$reg_stage1[1:1];
    assign signal_select_7 = mechanisms$events$reg_stage1[0:0];
    assign signal_const_4 = 3'b000;
    assign signal_mux_1 = signal_or_90 ? mechanisms$lane$reg_input_pin : signal_select_192;
    assign signal_mux_2 = signal_and_162 ? signal_mux_1 : mechanisms$lane$reg_input_pin;
    assign signal_mux_3 = signal_or_91 ? mechanisms$lane$reg_input_pin : signal_mux_2;
    assign signal_wire = signal_mux_3;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_input_pin <= signal_const_4;
        else
            mechanisms$lane$reg_input_pin <= signal_wire;
    end
    always @* begin
        case (mechanisms$lane$reg_input_pin)
        0:
            signal_mux_4 <= signal_select_7;
        1:
            signal_mux_4 <= signal_select_6;
        2:
            signal_mux_4 <= signal_select_5;
        3:
            signal_mux_4 <= signal_select_4;
        4:
            signal_mux_4 <= signal_select_3;
        5:
            signal_mux_4 <= signal_select_2;
        6:
            signal_mux_4 <= signal_select_1;
        default:
            signal_mux_4 <= signal_select;
        endcase
    end
    assign signal_mux_5 = signal_mux_4 ? signal_mux_6 : signal_const;
    assign signal_const_5 = 32'b10000000000000000000000000000000;
    assign signal_const_6 = 32'b01000000000000000000000000000000;
    assign signal_const_7 = 32'b00100000000000000000000000000000;
    assign signal_const_8 = 32'b00010000000000000000000000000000;
    assign signal_const_9 = 32'b00001000000000000000000000000000;
    assign signal_const_10 = 32'b00000100000000000000000000000000;
    assign signal_const_11 = 32'b00000010000000000000000000000000;
    assign signal_const_12 = 32'b00000001000000000000000000000000;
    assign signal_const_13 = 32'b00000000100000000000000000000000;
    assign signal_const_14 = 32'b00000000010000000000000000000000;
    assign signal_const_15 = 32'b00000000001000000000000000000000;
    assign signal_const_16 = 32'b00000000000100000000000000000000;
    assign signal_const_17 = 32'b00000000000010000000000000000000;
    assign signal_const_18 = 32'b00000000000001000000000000000000;
    assign signal_const_19 = 32'b00000000000000100000000000000000;
    assign signal_const_20 = 32'b00000000000000010000000000000000;
    assign signal_const_21 = 32'b00000000000000001000000000000000;
    assign signal_const_22 = 32'b00000000000000000100000000000000;
    assign signal_const_23 = 32'b00000000000000000010000000000000;
    assign signal_const_24 = 32'b00000000000000000001000000000000;
    assign signal_const_25 = 32'b00000000000000000000100000000000;
    assign signal_const_26 = 32'b00000000000000000000010000000000;
    assign signal_const_27 = 32'b00000000000000000000001000000000;
    assign signal_const_28 = 32'b00000000000000000000000100000000;
    assign signal_const_29 = 32'b00000000000000000000000010000000;
    assign signal_const_30 = 32'b00000000000000000000000001000000;
    assign signal_const_31 = 32'b00000000000000000000000000100000;
    assign signal_const_32 = 32'b00000000000000000000000000010000;
    assign signal_const_33 = 32'b00000000000000000000000000001000;
    assign signal_const_34 = 32'b00000000000000000000000000000100;
    assign signal_const_35 = 32'b00000000000000000000000000000010;
    assign signal_const_36 = 32'b00000000000000000000000000000001;
    always @* begin
        case (signal_mux_60)
        0:
            signal_mux_6 <= signal_const_36;
        1:
            signal_mux_6 <= signal_const_35;
        2:
            signal_mux_6 <= signal_const_34;
        3:
            signal_mux_6 <= signal_const_33;
        4:
            signal_mux_6 <= signal_const_32;
        5:
            signal_mux_6 <= signal_const_31;
        6:
            signal_mux_6 <= signal_const_30;
        7:
            signal_mux_6 <= signal_const_29;
        8:
            signal_mux_6 <= signal_const_28;
        9:
            signal_mux_6 <= signal_const_27;
        10:
            signal_mux_6 <= signal_const_26;
        11:
            signal_mux_6 <= signal_const_25;
        12:
            signal_mux_6 <= signal_const_24;
        13:
            signal_mux_6 <= signal_const_23;
        14:
            signal_mux_6 <= signal_const_22;
        15:
            signal_mux_6 <= signal_const_21;
        16:
            signal_mux_6 <= signal_const_20;
        17:
            signal_mux_6 <= signal_const_19;
        18:
            signal_mux_6 <= signal_const_18;
        19:
            signal_mux_6 <= signal_const_17;
        20:
            signal_mux_6 <= signal_const_16;
        21:
            signal_mux_6 <= signal_const_15;
        22:
            signal_mux_6 <= signal_const_14;
        23:
            signal_mux_6 <= signal_const_13;
        24:
            signal_mux_6 <= signal_const_12;
        25:
            signal_mux_6 <= signal_const_11;
        26:
            signal_mux_6 <= signal_const_10;
        27:
            signal_mux_6 <= signal_const_9;
        28:
            signal_mux_6 <= signal_const_8;
        29:
            signal_mux_6 <= signal_const_7;
        30:
            signal_mux_6 <= signal_const_6;
        default:
            signal_mux_6 <= signal_const_5;
        endcase
    end
    assign signal_not_2 = ~ signal_mux_6;
    assign signal_and_2 = mechanisms$lane$reg_rx_value & signal_not_2;
    assign signal_or = signal_and_2 | signal_mux_5;
    assign signal_mux_7 = signal_eq ? signal_or : mechanisms$lane$reg_rx_value;
    assign signal_mux_8 = signal_and_160 ? signal_mux_7 : mechanisms$lane$reg_rx_value;
    assign signal_mux_9 = mechanisms$lane$reg_busy ? signal_mux_8 : mechanisms$lane$reg_rx_value;
    assign signal_mux_10 = signal_and_162 ? signal_mux : signal_mux_9;
    assign signal_mux_11 = signal_or_91 ? mechanisms$lane$reg_rx_value : signal_mux_10;
    assign signal_wire_1 = signal_mux_11;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_rx_value <= signal_const;
        else
            mechanisms$lane$reg_rx_value <= signal_wire_1;
    end
    assign signal_const_37 = 1'b0;
    assign signal_mux_12 = signal_or_90 ? mechanisms$lane$reg_sample_trailing : signal_xor_1;
    assign signal_mux_13 = signal_and_162 ? signal_mux_12 : mechanisms$lane$reg_sample_trailing;
    assign signal_mux_14 = signal_or_91 ? mechanisms$lane$reg_sample_trailing : signal_mux_13;
    assign signal_wire_2 = signal_mux_14;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_sample_trailing <= signal_const_37;
        else
            mechanisms$lane$reg_sample_trailing <= signal_wire_2;
    end
    assign signal_eq = mechanisms$lane$reg_trailing == mechanisms$lane$reg_sample_trailing;
    assign signal_mux_15 = signal_eq ? signal_or : mechanisms$lane$reg_rx_value;
    assign signal_mux_16 = mechanisms$lane$reg_rx_enable ? signal_mux_15 : mechanisms$lane$reg_rx_data;
    assign signal_mux_17 = signal_and_148 ? mechanisms$lane$reg_rx_data : signal_mux_16;
    assign signal_mux_18 = signal_and_149 ? signal_mux_17 : mechanisms$lane$reg_rx_data;
    assign signal_mux_19 = signal_and_160 ? signal_mux_18 : mechanisms$lane$reg_rx_data;
    assign signal_mux_20 = mechanisms$lane$reg_busy ? signal_mux_19 : mechanisms$lane$reg_rx_data;
    assign signal_mux_21 = signal_and_162 ? mechanisms$lane$reg_rx_data : signal_mux_20;
    assign signal_mux_22 = signal_or_91 ? mechanisms$lane$reg_rx_data : signal_mux_21;
    assign signal_wire_3 = signal_mux_22;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_rx_data <= signal_const;
        else
            mechanisms$lane$reg_rx_data <= signal_wire_3;
    end
    assign signal_const_39 = 1'b1;
    assign signal_mux_23 = mechanisms$lane$reg_rx_enable ? signal_const_39 : signal_const_37;
    assign signal_mux_24 = signal_and_148 ? signal_const_37 : signal_mux_23;
    assign signal_mux_25 = signal_and_149 ? signal_mux_24 : signal_const_37;
    assign signal_mux_26 = signal_and_160 ? signal_mux_25 : signal_const_37;
    assign signal_mux_27 = mechanisms$lane$reg_busy ? signal_mux_26 : signal_const_37;
    assign signal_mux_28 = signal_and_162 ? signal_const_37 : signal_mux_27;
    assign signal_mux_29 = signal_or_91 ? signal_const_37 : signal_mux_28;
    assign signal_wire_4 = signal_mux_29;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_rx_valid <= signal_const_37;
        else
            mechanisms$lane$reg_rx_valid <= signal_wire_4;
    end
    assign signal_not_3 = ~ signal_eq_86;
    assign signal_or_1 = mechanisms$lane$reg_busy | mechanisms$lane$reg_armed;
    assign signal_or_2 = signal_or_1 | signal_not_3;
    assign signal_and_3 = signal_or_71 & signal_not_124;
    assign signal_and_4 = signal_or_112 & signal_not_127;
    assign signal_or_3 = signal_and_4 | signal_and_3;
    assign signal_mux_30 = signal_or_3 ? signal_const_39 : mechanisms$bank$reg_conflict;
    assign signal_mux_31 = signal_or_116 ? signal_mux_30 : mechanisms$bank$reg_conflict;
    assign signal_mux_32 = signal_or_117 ? mechanisms$bank$reg_conflict : signal_mux_31;
    assign signal_wire_5 = signal_mux_32;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$bank$reg_conflict <= signal_const_37;
        else
            mechanisms$bank$reg_conflict <= signal_wire_5;
    end
    assign signal_and_5 = signal_wire_74 & signal_wire_78;
    assign signal_const_43 = 8'b00000000;
    assign signal_not_4 = ~ signal_wire_100;
    assign signal_and_6 = signal_wire_76 & signal_not_4;
    assign signal_eq_1 = signal_and_6 == signal_const_43;
    assign signal_not_5 = ~ signal_eq_1;
    assign signal_and_7 = signal_wire_78 & signal_not_5;
    assign signal_and_8 = signal_wire_77 & signal_wire_113;
    assign signal_eq_2 = signal_and_8 == signal_const_43;
    assign signal_not_6 = ~ signal_eq_2;
    assign signal_and_9 = signal_wire_74 & signal_not_6;
    assign signal_or_4 = signal_and_9 | signal_and_7;
    assign signal_or_5 = signal_or_4 | signal_and_5;
    assign signal_and_10 = signal_and_146 & signal_or_5;
    assign signal_not_7 = ~ signal_and_146;
    assign signal_or_6 = signal_wire_74 | signal_wire_78;
    assign signal_and_11 = signal_or_6 & signal_not_7;
    assign signal_or_7 = signal_and_11 | signal_and_10;
    assign signal_mux_33 = signal_or_90 ? mechanisms$lane$reg_pin_oe : signal_or_81;
    assign signal_mux_34 = signal_and_149 ? signal_const_43 : mechanisms$lane$reg_pin_oe;
    assign signal_mux_35 = signal_and_160 ? signal_mux_34 : mechanisms$lane$reg_pin_oe;
    assign signal_mux_36 = mechanisms$lane$reg_busy ? signal_mux_35 : mechanisms$lane$reg_pin_oe;
    assign signal_mux_37 = signal_and_162 ? signal_mux_33 : signal_mux_36;
    assign signal_mux_38 = signal_or_91 ? signal_const_43 : signal_mux_37;
    assign signal_wire_6 = signal_mux_38;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_pin_oe <= signal_const_43;
        else
            mechanisms$lane$reg_pin_oe <= signal_wire_6;
    end
    assign signal_select_8 = signal_wire_156[7:0];
    assign signal_and_12 = signal_select_241 & signal_select_8;
    assign signal_select_9 = signal_wire_155[0:0];
    assign signal_mux_39 = signal_select_9 ? signal_and_12 : signal_select_241;
    assign signal_mux_40 = signal_and_145 ? signal_const_43 : signal_mux_39;
    assign signal_mux_41 = signal_and_143 ? mechanisms$lane$reg_pin_oe : signal_mux_40;
    assign signal_and_13 = signal_mux_41 & signal_mux_424;
    assign signal_not_8 = ~ signal_mux_424;
    assign signal_and_14 = mechanisms$bank$reg_pin_oe & signal_not_8;
    assign signal_or_8 = signal_and_14 | signal_and_13;
    assign signal_mux_42 = signal_or_71 ? signal_or_8 : mechanisms$bank$reg_pin_oe;
    assign signal_mux_43 = signal_or_116 ? mechanisms$bank$reg_pin_oe : signal_mux_42;
    assign signal_mux_44 = signal_or_117 ? signal_const_43 : signal_mux_43;
    assign signal_wire_7 = signal_mux_44;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$bank$reg_pin_oe <= signal_const_43;
        else
            mechanisms$bank$reg_pin_oe <= signal_wire_7;
    end
    assign signal_and_15 = signal_and_157 & signal_select_191;
    assign signal_mux_45 = signal_and_15 ? signal_mux_519 : signal_const_43;
    assign signal_select_10 = signal_cat_40[31:31];
    assign signal_select_11 = signal_cat_40[30:30];
    assign signal_select_12 = signal_cat_40[29:29];
    assign signal_select_13 = signal_cat_40[28:28];
    assign signal_select_14 = signal_cat_40[27:27];
    assign signal_select_15 = signal_cat_40[26:26];
    assign signal_select_16 = signal_cat_40[25:25];
    assign signal_select_17 = signal_cat_40[24:24];
    assign signal_select_18 = signal_cat_40[23:23];
    assign signal_select_19 = signal_cat_40[22:22];
    assign signal_select_20 = signal_cat_40[21:21];
    assign signal_select_21 = signal_cat_40[20:20];
    assign signal_select_22 = signal_cat_40[19:19];
    assign signal_select_23 = signal_cat_40[18:18];
    assign signal_select_24 = signal_cat_40[17:17];
    assign signal_select_25 = signal_cat_40[16:16];
    assign signal_select_26 = signal_cat_40[15:15];
    assign signal_select_27 = signal_cat_40[14:14];
    assign signal_select_28 = signal_cat_40[13:13];
    assign signal_select_29 = signal_cat_40[12:12];
    assign signal_select_30 = signal_cat_40[11:11];
    assign signal_select_31 = signal_cat_40[10:10];
    assign signal_select_32 = signal_cat_40[9:9];
    assign signal_select_33 = signal_cat_40[8:8];
    assign signal_select_34 = signal_cat_40[7:7];
    assign signal_select_35 = signal_cat_40[6:6];
    assign signal_select_36 = signal_cat_40[5:5];
    assign signal_select_37 = signal_cat_40[4:4];
    assign signal_select_38 = signal_cat_40[3:3];
    assign signal_select_39 = signal_cat_40[2:2];
    assign signal_select_40 = signal_cat_40[1:1];
    assign signal_select_41 = signal_cat_40[0:0];
    assign signal_const_58 = 6'b000000;
    assign signal_const_59 = 6'b000001;
    assign signal_sub = signal_select_206 - signal_const_59;
    assign signal_mux_46 = signal_not_9 ? signal_const_58 : signal_sub;
    always @* begin
        case (signal_mux_46)
        0:
            signal_mux_47 <= signal_select_41;
        1:
            signal_mux_47 <= signal_select_40;
        2:
            signal_mux_47 <= signal_select_39;
        3:
            signal_mux_47 <= signal_select_38;
        4:
            signal_mux_47 <= signal_select_37;
        5:
            signal_mux_47 <= signal_select_36;
        6:
            signal_mux_47 <= signal_select_35;
        7:
            signal_mux_47 <= signal_select_34;
        8:
            signal_mux_47 <= signal_select_33;
        9:
            signal_mux_47 <= signal_select_32;
        10:
            signal_mux_47 <= signal_select_31;
        11:
            signal_mux_47 <= signal_select_30;
        12:
            signal_mux_47 <= signal_select_29;
        13:
            signal_mux_47 <= signal_select_28;
        14:
            signal_mux_47 <= signal_select_27;
        15:
            signal_mux_47 <= signal_select_26;
        16:
            signal_mux_47 <= signal_select_25;
        17:
            signal_mux_47 <= signal_select_24;
        18:
            signal_mux_47 <= signal_select_23;
        19:
            signal_mux_47 <= signal_select_22;
        20:
            signal_mux_47 <= signal_select_21;
        21:
            signal_mux_47 <= signal_select_20;
        22:
            signal_mux_47 <= signal_select_19;
        23:
            signal_mux_47 <= signal_select_18;
        24:
            signal_mux_47 <= signal_select_17;
        25:
            signal_mux_47 <= signal_select_16;
        26:
            signal_mux_47 <= signal_select_15;
        27:
            signal_mux_47 <= signal_select_14;
        28:
            signal_mux_47 <= signal_select_13;
        29:
            signal_mux_47 <= signal_select_12;
        30:
            signal_mux_47 <= signal_select_11;
        default:
            signal_mux_47 <= signal_select_10;
        endcase
    end
    assign signal_mux_48 = signal_mux_47 ? signal_mux_521 : signal_const_43;
    assign signal_select_42 = signal_select_219[3:3];
    assign signal_mux_49 = signal_select_42 ? signal_mux_521 : signal_const_43;
    assign signal_mux_50 = signal_xor_2 ? signal_mux_48 : signal_mux_49;
    assign signal_mux_51 = signal_not_152 ? signal_mux_50 : signal_const_43;
    assign signal_or_9 = signal_mux_51 | signal_mux_45;
    assign signal_mux_52 = signal_or_90 ? mechanisms$lane$reg_pin_value : signal_or_9;
    assign signal_select_43 = mechanisms$lane$reg_tx_value[31:31];
    assign signal_select_44 = mechanisms$lane$reg_tx_value[30:30];
    assign signal_select_45 = mechanisms$lane$reg_tx_value[29:29];
    assign signal_select_46 = mechanisms$lane$reg_tx_value[28:28];
    assign signal_select_47 = mechanisms$lane$reg_tx_value[27:27];
    assign signal_select_48 = mechanisms$lane$reg_tx_value[26:26];
    assign signal_select_49 = mechanisms$lane$reg_tx_value[25:25];
    assign signal_select_50 = mechanisms$lane$reg_tx_value[24:24];
    assign signal_select_51 = mechanisms$lane$reg_tx_value[23:23];
    assign signal_select_52 = mechanisms$lane$reg_tx_value[22:22];
    assign signal_select_53 = mechanisms$lane$reg_tx_value[21:21];
    assign signal_select_54 = mechanisms$lane$reg_tx_value[20:20];
    assign signal_select_55 = mechanisms$lane$reg_tx_value[19:19];
    assign signal_select_56 = mechanisms$lane$reg_tx_value[18:18];
    assign signal_select_57 = mechanisms$lane$reg_tx_value[17:17];
    assign signal_select_58 = mechanisms$lane$reg_tx_value[16:16];
    assign signal_select_59 = mechanisms$lane$reg_tx_value[15:15];
    assign signal_select_60 = mechanisms$lane$reg_tx_value[14:14];
    assign signal_select_61 = mechanisms$lane$reg_tx_value[13:13];
    assign signal_select_62 = mechanisms$lane$reg_tx_value[12:12];
    assign signal_select_63 = mechanisms$lane$reg_tx_value[11:11];
    assign signal_select_64 = mechanisms$lane$reg_tx_value[10:10];
    assign signal_select_65 = mechanisms$lane$reg_tx_value[9:9];
    assign signal_select_66 = mechanisms$lane$reg_tx_value[8:8];
    assign signal_select_67 = mechanisms$lane$reg_tx_value[7:7];
    assign signal_select_68 = mechanisms$lane$reg_tx_value[6:6];
    assign signal_select_69 = mechanisms$lane$reg_tx_value[5:5];
    assign signal_select_70 = mechanisms$lane$reg_tx_value[4:4];
    assign signal_select_71 = mechanisms$lane$reg_tx_value[3:3];
    assign signal_select_72 = mechanisms$lane$reg_tx_value[2:2];
    assign signal_select_73 = mechanisms$lane$reg_tx_value[1:1];
    assign signal_mux_53 = signal_or_90 ? mechanisms$lane$reg_tx_value : signal_cat_40;
    assign signal_mux_54 = signal_and_162 ? signal_mux_53 : mechanisms$lane$reg_tx_value;
    assign signal_mux_55 = signal_or_91 ? mechanisms$lane$reg_tx_value : signal_mux_54;
    assign signal_wire_8 = signal_mux_55;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_tx_value <= signal_const;
        else
            mechanisms$lane$reg_tx_value <= signal_wire_8;
    end
    assign signal_select_74 = mechanisms$lane$reg_tx_value[0:0];
    assign signal_add = mechanisms$lane$reg_bit_index + signal_const_59;
    assign signal_const_65 = 6'b000010;
    assign signal_sub_1 = mechanisms$lane$reg_bit_count - signal_const_65;
    assign signal_sub_2 = signal_sub_1 - mechanisms$lane$reg_bit_index;
    assign signal_mux_56 = mechanisms$lane$reg_lsb_first ? signal_add : signal_sub_2;
    assign signal_sub_3 = mechanisms$lane$reg_bit_count - signal_const_59;
    assign signal_sub_4 = signal_sub_3 - mechanisms$lane$reg_bit_index;
    assign signal_select_75 = signal_select_219[2:2];
    assign signal_not_9 = ~ signal_select_75;
    assign signal_mux_57 = signal_or_90 ? mechanisms$lane$reg_lsb_first : signal_not_9;
    assign signal_mux_58 = signal_and_162 ? signal_mux_57 : mechanisms$lane$reg_lsb_first;
    assign signal_mux_59 = signal_or_91 ? mechanisms$lane$reg_lsb_first : signal_mux_58;
    assign signal_wire_9 = signal_mux_59;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_lsb_first <= signal_const_37;
        else
            mechanisms$lane$reg_lsb_first <= signal_wire_9;
    end
    assign signal_mux_60 = mechanisms$lane$reg_lsb_first ? mechanisms$lane$reg_bit_index : signal_sub_4;
    assign signal_mux_61 = mechanisms$lane$reg_launch_trailing ? signal_mux_56 : signal_mux_60;
    always @* begin
        case (signal_mux_61)
        0:
            signal_mux_62 <= signal_select_74;
        1:
            signal_mux_62 <= signal_select_73;
        2:
            signal_mux_62 <= signal_select_72;
        3:
            signal_mux_62 <= signal_select_71;
        4:
            signal_mux_62 <= signal_select_70;
        5:
            signal_mux_62 <= signal_select_69;
        6:
            signal_mux_62 <= signal_select_68;
        7:
            signal_mux_62 <= signal_select_67;
        8:
            signal_mux_62 <= signal_select_66;
        9:
            signal_mux_62 <= signal_select_65;
        10:
            signal_mux_62 <= signal_select_64;
        11:
            signal_mux_62 <= signal_select_63;
        12:
            signal_mux_62 <= signal_select_62;
        13:
            signal_mux_62 <= signal_select_61;
        14:
            signal_mux_62 <= signal_select_60;
        15:
            signal_mux_62 <= signal_select_59;
        16:
            signal_mux_62 <= signal_select_58;
        17:
            signal_mux_62 <= signal_select_57;
        18:
            signal_mux_62 <= signal_select_56;
        19:
            signal_mux_62 <= signal_select_55;
        20:
            signal_mux_62 <= signal_select_54;
        21:
            signal_mux_62 <= signal_select_53;
        22:
            signal_mux_62 <= signal_select_52;
        23:
            signal_mux_62 <= signal_select_51;
        24:
            signal_mux_62 <= signal_select_50;
        25:
            signal_mux_62 <= signal_select_49;
        26:
            signal_mux_62 <= signal_select_48;
        27:
            signal_mux_62 <= signal_select_47;
        28:
            signal_mux_62 <= signal_select_46;
        29:
            signal_mux_62 <= signal_select_45;
        30:
            signal_mux_62 <= signal_select_44;
        default:
            signal_mux_62 <= signal_select_43;
        endcase
    end
    assign signal_mux_63 = signal_mux_62 ? signal_mux_67 : signal_const_43;
    assign signal_const_68 = 8'b10000000;
    assign signal_const_69 = 8'b01000000;
    assign signal_const_70 = 8'b00100000;
    assign signal_const_71 = 8'b00010000;
    assign signal_const_72 = 8'b00001000;
    assign signal_const_73 = 8'b00000100;
    assign signal_const_74 = 8'b00000010;
    assign signal_const_75 = 8'b00000001;
    assign signal_mux_64 = signal_or_90 ? mechanisms$lane$reg_output_pin : signal_select_194;
    assign signal_mux_65 = signal_and_162 ? signal_mux_64 : mechanisms$lane$reg_output_pin;
    assign signal_mux_66 = signal_or_91 ? mechanisms$lane$reg_output_pin : signal_mux_65;
    assign signal_wire_10 = signal_mux_66;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_output_pin <= signal_const_4;
        else
            mechanisms$lane$reg_output_pin <= signal_wire_10;
    end
    always @* begin
        case (mechanisms$lane$reg_output_pin)
        0:
            signal_mux_67 <= signal_const_75;
        1:
            signal_mux_67 <= signal_const_74;
        2:
            signal_mux_67 <= signal_const_73;
        3:
            signal_mux_67 <= signal_const_72;
        4:
            signal_mux_67 <= signal_const_71;
        5:
            signal_mux_67 <= signal_const_70;
        6:
            signal_mux_67 <= signal_const_69;
        default:
            signal_mux_67 <= signal_const_68;
        endcase
    end
    assign signal_not_10 = ~ signal_mux_67;
    assign signal_and_16 = signal_mux_75 & signal_not_10;
    assign signal_or_10 = signal_and_16 | signal_mux_63;
    assign signal_mux_68 = signal_or_90 ? mechanisms$lane$reg_clock_pin : signal_select_193;
    assign signal_mux_69 = signal_and_162 ? signal_mux_68 : mechanisms$lane$reg_clock_pin;
    assign signal_mux_70 = signal_or_91 ? mechanisms$lane$reg_clock_pin : signal_mux_69;
    assign signal_wire_11 = signal_mux_70;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_clock_pin <= signal_const_4;
        else
            mechanisms$lane$reg_clock_pin <= signal_wire_11;
    end
    always @* begin
        case (mechanisms$lane$reg_clock_pin)
        0:
            signal_mux_71 <= signal_const_75;
        1:
            signal_mux_71 <= signal_const_74;
        2:
            signal_mux_71 <= signal_const_73;
        3:
            signal_mux_71 <= signal_const_72;
        4:
            signal_mux_71 <= signal_const_71;
        5:
            signal_mux_71 <= signal_const_70;
        6:
            signal_mux_71 <= signal_const_69;
        default:
            signal_mux_71 <= signal_const_68;
        endcase
    end
    assign signal_xor = mechanisms$lane$reg_pin_value ^ signal_mux_71;
    assign signal_mux_72 = signal_or_90 ? mechanisms$lane$reg_clock_enable : signal_and_157;
    assign signal_mux_73 = signal_and_162 ? signal_mux_72 : mechanisms$lane$reg_clock_enable;
    assign signal_mux_74 = signal_or_91 ? mechanisms$lane$reg_clock_enable : signal_mux_73;
    assign signal_wire_12 = signal_mux_74;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_clock_enable <= signal_const_37;
        else
            mechanisms$lane$reg_clock_enable <= signal_wire_12;
    end
    assign signal_mux_75 = mechanisms$lane$reg_clock_enable ? signal_xor : mechanisms$lane$reg_pin_value;
    assign signal_not_11 = ~ signal_and_149;
    assign signal_mux_76 = signal_or_90 ? mechanisms$lane$reg_tx_enable : signal_not_152;
    assign signal_mux_77 = signal_and_162 ? signal_mux_76 : mechanisms$lane$reg_tx_enable;
    assign signal_mux_78 = signal_or_91 ? mechanisms$lane$reg_tx_enable : signal_mux_77;
    assign signal_wire_13 = signal_mux_78;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_tx_enable <= signal_const_37;
        else
            mechanisms$lane$reg_tx_enable <= signal_wire_13;
    end
    assign signal_mux_79 = signal_or_90 ? mechanisms$lane$reg_launch_trailing : signal_xor_2;
    assign signal_mux_80 = signal_and_162 ? signal_mux_79 : mechanisms$lane$reg_launch_trailing;
    assign signal_mux_81 = signal_or_91 ? mechanisms$lane$reg_launch_trailing : signal_mux_80;
    assign signal_wire_14 = signal_mux_81;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_launch_trailing <= signal_const_37;
        else
            mechanisms$lane$reg_launch_trailing <= signal_wire_14;
    end
    assign signal_eq_3 = mechanisms$lane$reg_trailing == mechanisms$lane$reg_launch_trailing;
    assign signal_and_17 = signal_eq_3 & mechanisms$lane$reg_tx_enable;
    assign signal_and_18 = signal_and_17 & signal_not_11;
    assign signal_mux_82 = signal_and_18 ? signal_or_10 : signal_mux_75;
    assign signal_mux_83 = signal_and_160 ? signal_mux_82 : mechanisms$lane$reg_pin_value;
    assign signal_mux_84 = mechanisms$lane$reg_busy ? signal_mux_83 : mechanisms$lane$reg_pin_value;
    assign signal_mux_85 = signal_and_162 ? signal_mux_52 : signal_mux_84;
    assign signal_mux_86 = signal_or_91 ? signal_const_43 : signal_mux_85;
    assign signal_wire_15 = signal_mux_86;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_pin_value <= signal_const_43;
        else
            mechanisms$lane$reg_pin_value <= signal_wire_15;
    end
    assign signal_select_76 = signal_wire_156[7:0];
    assign signal_mux_87 = signal_and_145 ? signal_const_43 : signal_select_76;
    assign signal_mux_88 = signal_and_143 ? mechanisms$lane$reg_pin_value : signal_mux_87;
    assign signal_select_77 = signal_wire_155[0:0];
    assign signal_and_19 = signal_and_272 & signal_select_77;
    assign signal_mux_89 = signal_and_19 ? signal_const_43 : signal_mux_88;
    assign signal_and_20 = signal_mux_89 & signal_mux_424;
    assign signal_not_12 = ~ signal_mux_424;
    assign signal_and_21 = mechanisms$bank$reg_pins & signal_not_12;
    assign signal_or_11 = signal_and_21 | signal_and_20;
    assign signal_mux_90 = signal_or_71 ? signal_or_11 : mechanisms$bank$reg_pins;
    assign signal_mux_91 = signal_or_116 ? mechanisms$bank$reg_pins : signal_mux_90;
    assign signal_mux_92 = signal_or_117 ? signal_const_43 : signal_mux_91;
    assign signal_wire_16 = signal_mux_92;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$bank$reg_pins <= signal_const_43;
        else
            mechanisms$bank$reg_pins <= signal_wire_16;
    end
    assign signal_not_13 = ~ signal_wire_132;
    assign signal_and_22 = mechanisms$events$reg_event & signal_wire_131;
    assign signal_and_23 = signal_and_22 & signal_not_13;
    assign signal_not_14 = ~ signal_wire_132;
    assign signal_and_24 = mechanisms$events$reg_overflow & signal_not_14;
    assign signal_or_12 = signal_and_24 | signal_and_23;
    assign signal_wire_17 = signal_or_12;
    always @(posedge signal_wire_167) begin
        if (signal_or_134)
            mechanisms$events$reg_overflow <= signal_const_58;
        else
            mechanisms$events$reg_overflow <= signal_wire_17;
    end
    assign signal_add_1 = execution$reg_total_cycles + signal_const_36;
    assign signal_add_2 = execution$reg_total_cycles + signal_const_36;
    assign signal_add_3 = execution$reg_total_cycles + signal_const_36;
    assign signal_mux_93 = signal_and_325 ? signal_const : execution$reg_total_cycles;
    assign signal_mux_94 = signal_and_282 ? signal_add_3 : signal_mux_93;
    assign signal_mux_95 = signal_or_16 ? signal_add_2 : signal_mux_94;
    assign signal_mux_96 = signal_or_13 ? signal_add_1 : signal_mux_95;
    assign signal_mux_97 = signal_or_192 ? execution$reg_total_cycles : signal_mux_96;
    assign signal_mux_98 = signal_and_328 ? execution$reg_total_cycles : signal_mux_97;
    assign signal_mux_99 = signal_not_221 ? execution$reg_total_cycles : signal_mux_98;
    assign signal_mux_100 = signal_wire_195 ? signal_const : signal_mux_99;
    assign signal_wire_18 = signal_mux_100;
    always @(posedge signal_wire_167) begin
        execution$reg_total_cycles <= signal_wire_18;
    end
    assign signal_add_4 = execution$reg_extension_fetches + signal_const_36;
    assign signal_mux_101 = signal_and_100 ? signal_add_4 : signal_mux_102;
    assign signal_mux_102 = signal_and_325 ? signal_const : execution$reg_extension_fetches;
    assign signal_mux_103 = signal_and_282 ? signal_mux_101 : signal_mux_102;
    assign signal_mux_104 = signal_or_192 ? execution$reg_extension_fetches : signal_mux_103;
    assign signal_mux_105 = signal_and_328 ? execution$reg_extension_fetches : signal_mux_104;
    assign signal_mux_106 = signal_not_221 ? execution$reg_extension_fetches : signal_mux_105;
    assign signal_mux_107 = signal_wire_195 ? signal_const : signal_mux_106;
    assign signal_wire_19 = signal_mux_107;
    always @(posedge signal_wire_167) begin
        execution$reg_extension_fetches <= signal_wire_19;
    end
    assign signal_add_5 = execution$reg_instruction_count + signal_const_36;
    assign signal_mux_108 = signal_and_325 ? signal_const : execution$reg_instruction_count;
    assign signal_mux_109 = signal_or_27 ? signal_add_5 : signal_mux_108;
    assign signal_mux_110 = signal_or_192 ? execution$reg_instruction_count : signal_mux_109;
    assign signal_mux_111 = signal_and_328 ? execution$reg_instruction_count : signal_mux_110;
    assign signal_mux_112 = signal_not_221 ? execution$reg_instruction_count : signal_mux_111;
    assign signal_mux_113 = signal_wire_195 ? signal_const : signal_mux_112;
    assign signal_wire_20 = signal_mux_113;
    always @(posedge signal_wire_167) begin
        execution$reg_instruction_count <= signal_wire_20;
    end
    assign signal_add_6 = execution$reg_stall_cycles + signal_const_36;
    assign signal_mux_114 = signal_and_325 ? signal_const : execution$reg_stall_cycles;
    assign signal_not_15 = ~ signal_wire_67;
    assign signal_not_16 = ~ signal_wire_172;
    assign signal_and_25 = signal_and_284 & signal_not_16;
    assign signal_and_26 = signal_and_25 & signal_not_15;
    assign signal_or_13 = signal_and_26 | signal_eq_75;
    assign signal_mux_115 = signal_or_13 ? signal_add_6 : signal_mux_114;
    assign signal_mux_116 = signal_or_192 ? execution$reg_stall_cycles : signal_mux_115;
    assign signal_mux_117 = signal_and_328 ? execution$reg_stall_cycles : signal_mux_116;
    assign signal_mux_118 = signal_not_221 ? execution$reg_stall_cycles : signal_mux_117;
    assign signal_mux_119 = signal_wire_195 ? signal_const : signal_mux_118;
    assign signal_wire_21 = signal_mux_119;
    always @(posedge signal_wire_167) begin
        execution$reg_stall_cycles <= signal_wire_21;
    end
    assign signal_add_7 = execution$reg_execute_cycles + signal_const_36;
    assign signal_mux_120 = signal_and_325 ? signal_const : execution$reg_execute_cycles;
    assign signal_or_14 = signal_and_90 | signal_and_278;
    assign signal_or_15 = signal_or_14 | signal_and_84;
    assign signal_or_16 = signal_and_333 | signal_or_15;
    assign signal_mux_121 = signal_or_16 ? signal_add_7 : signal_mux_120;
    assign signal_mux_122 = signal_or_192 ? execution$reg_execute_cycles : signal_mux_121;
    assign signal_mux_123 = signal_and_328 ? execution$reg_execute_cycles : signal_mux_122;
    assign signal_mux_124 = signal_not_221 ? execution$reg_execute_cycles : signal_mux_123;
    assign signal_mux_125 = signal_wire_195 ? signal_const : signal_mux_124;
    assign signal_wire_22 = signal_mux_125;
    always @(posedge signal_wire_167) begin
        execution$reg_execute_cycles <= signal_wire_22;
    end
    assign signal_add_8 = execution$reg_fetch_cycles + signal_const_36;
    assign signal_mux_126 = signal_and_325 ? signal_const : execution$reg_fetch_cycles;
    assign signal_mux_127 = signal_and_282 ? signal_add_8 : signal_mux_126;
    assign signal_mux_128 = signal_or_192 ? execution$reg_fetch_cycles : signal_mux_127;
    assign signal_mux_129 = signal_and_328 ? execution$reg_fetch_cycles : signal_mux_128;
    assign signal_mux_130 = signal_not_221 ? execution$reg_fetch_cycles : signal_mux_129;
    assign signal_mux_131 = signal_wire_195 ? signal_const : signal_mux_130;
    assign signal_wire_23 = signal_mux_131;
    always @(posedge signal_wire_167) begin
        execution$reg_fetch_cycles <= signal_wire_23;
    end
    assign signal_cat = { execution$reg_r7,
                          execution$reg_r6,
                          execution$reg_r5,
                          execution$reg_r4,
                          execution$reg_r3,
                          execution$reg_r2,
                          execution$reg_r1,
                          execution$reg_r0 };
    assign signal_mux_132 = signal_and_325 ? signal_const_37 : signal_const_37;
    assign signal_mux_133 = signal_or_27 ? signal_const_39 : signal_mux_132;
    assign signal_mux_134 = signal_or_192 ? signal_const_37 : signal_mux_133;
    assign signal_mux_135 = signal_and_328 ? signal_const_37 : signal_mux_134;
    assign signal_mux_136 = signal_not_221 ? signal_const_37 : signal_mux_135;
    assign signal_mux_137 = signal_wire_195 ? signal_const_37 : signal_mux_136;
    assign signal_wire_24 = signal_mux_137;
    always @(posedge signal_wire_167) begin
        execution$reg_retired <= signal_wire_24;
    end
    assign signal_wire_25 = signal_const_43;
    assign signal_const_109 = 8'b00000110;
    assign signal_const_111 = 8'b00000101;
    assign signal_const_112 = 8'b00000011;
    assign signal_mux_138 = signal_and_114 ? signal_const_75 : signal_const_74;
    assign signal_mux_139 = signal_and_128 ? signal_const_112 : signal_mux_138;
    assign signal_and_27 = signal_and_187 & signal_not_168;
    assign signal_mux_140 = signal_and_27 ? signal_const_112 : signal_mux_139;
    assign signal_and_28 = signal_or_53 & signal_and_246;
    assign signal_mux_141 = signal_and_28 ? signal_const_111 : signal_mux_140;
    assign signal_and_29 = signal_or_53 & signal_and_254;
    assign signal_mux_142 = signal_and_29 ? signal_const_73 : signal_mux_141;
    assign signal_mux_143 = signal_and_253 ? signal_const_109 : signal_mux_142;
    assign signal_wire_26 = signal_mux_143;
    assign signal_const_116 = 5'b00000;
    assign signal_cat_1 = { signal_const_116,
                            signal_mux_148 };
    assign signal_const_117 = 3'b001;
    assign signal_const_118 = 3'b010;
    assign signal_const_119 = 3'b011;
    assign signal_const_120 = 3'b100;
    assign signal_const_121 = 3'b101;
    assign signal_not_17 = ~ signal_mux_325;
    assign signal_and_30 = signal_mux_772 & signal_not_17;
    assign signal_mux_144 = signal_and_30 ? signal_const_121 : signal_const_4;
    assign signal_not_18 = ~ signal_or_33;
    assign signal_and_31 = signal_mux_772 & signal_not_18;
    assign signal_mux_145 = signal_and_31 ? signal_const_120 : signal_mux_144;
    assign signal_not_19 = ~ signal_mux_356;
    assign signal_mux_146 = signal_not_19 ? signal_const_119 : signal_mux_145;
    assign signal_not_20 = ~ signal_mux_357;
    assign signal_not_21 = ~ signal_eq_52;
    assign signal_or_17 = signal_not_21 | signal_not_20;
    assign signal_mux_147 = signal_or_17 ? signal_const_118 : signal_mux_146;
    assign signal_not_22 = ~ signal_mux_359;
    assign signal_mux_148 = signal_not_22 ? signal_const_117 : signal_mux_147;
    assign signal_cat_2 = { signal_const_116,
                            signal_mux_148 };
    assign signal_mux_149 = signal_and_325 ? signal_const_43 : execution$reg_fault_reason;
    assign signal_mux_150 = signal_and_74 ? signal_const_43 : signal_mux_149;
    assign signal_mux_151 = signal_and_75 ? signal_const_43 : signal_mux_150;
    assign signal_mux_152 = signal_and_76 ? signal_const_43 : signal_mux_151;
    assign signal_mux_153 = signal_and_77 ? signal_cat_2 : signal_mux_152;
    assign signal_mux_154 = signal_and_82 ? signal_cat_1 : signal_mux_153;
    assign signal_mux_155 = signal_and_84 ? signal_wire_26 : signal_mux_154;
    assign signal_mux_156 = signal_and_85 ? signal_wire_25 : signal_mux_155;
    assign signal_mux_157 = signal_and_88 ? signal_wire_25 : signal_mux_156;
    assign signal_mux_158 = signal_and_90 ? signal_wire_26 : signal_mux_157;
    assign signal_mux_159 = signal_or_192 ? execution$reg_fault_reason : signal_mux_158;
    assign signal_mux_160 = signal_and_328 ? execution$reg_fault_reason : signal_mux_159;
    assign signal_mux_161 = signal_not_221 ? execution$reg_fault_reason : signal_mux_160;
    assign signal_mux_162 = signal_wire_195 ? signal_const_43 : signal_mux_161;
    assign signal_wire_27 = signal_mux_162;
    always @(posedge signal_wire_167) begin
        execution$reg_fault_reason <= signal_wire_27;
    end
    assign signal_const_128 = 17'b00000000000000000;
    assign signal_mux_163 = signal_and_325 ? signal_const_128 : execution$reg_fault_address;
    assign signal_mux_164 = signal_and_74 ? execution$reg_pc : signal_mux_163;
    assign signal_mux_165 = signal_and_75 ? execution$reg_pc : signal_mux_164;
    assign signal_mux_166 = signal_and_76 ? signal_add_9 : signal_mux_165;
    assign signal_mux_167 = signal_and_77 ? execution$reg_pc : signal_mux_166;
    assign signal_mux_168 = signal_and_82 ? signal_add_9 : signal_mux_167;
    assign signal_mux_169 = signal_and_84 ? execution$reg_pc : signal_mux_168;
    assign signal_mux_170 = signal_and_85 ? execution$reg_pc : signal_mux_169;
    assign signal_mux_171 = signal_and_88 ? execution$reg_pc : signal_mux_170;
    assign signal_mux_172 = signal_and_90 ? execution$reg_pc : signal_mux_171;
    assign signal_mux_173 = signal_or_192 ? execution$reg_fault_address : signal_mux_172;
    assign signal_mux_174 = signal_and_328 ? execution$reg_fault_address : signal_mux_173;
    assign signal_mux_175 = signal_not_221 ? execution$reg_fault_address : signal_mux_174;
    assign signal_mux_176 = signal_wire_195 ? signal_const_128 : signal_mux_175;
    assign signal_wire_28 = signal_mux_176;
    always @(posedge signal_wire_167) begin
        execution$reg_fault_address <= signal_wire_28;
    end
    assign signal_mux_177 = signal_and_325 ? signal_const_128 : execution$reg_last_instruction_slot;
    assign signal_mux_178 = signal_or_27 ? execution$reg_pc : signal_mux_177;
    assign signal_mux_179 = signal_or_192 ? execution$reg_last_instruction_slot : signal_mux_178;
    assign signal_mux_180 = signal_and_328 ? execution$reg_last_instruction_slot : signal_mux_179;
    assign signal_mux_181 = signal_not_221 ? execution$reg_last_instruction_slot : signal_mux_180;
    assign signal_mux_182 = signal_wire_195 ? signal_const_128 : signal_mux_181;
    assign signal_wire_29 = signal_mux_182;
    always @(posedge signal_wire_167) begin
        execution$reg_last_instruction_slot <= signal_wire_29;
    end
    assign signal_mux_183 = signal_and_325 ? signal_const_128 : execution$reg_fault_instruction_slot;
    assign signal_mux_184 = signal_and_74 ? execution$reg_last_instruction_slot : signal_mux_183;
    assign signal_mux_185 = signal_and_75 ? execution$reg_last_instruction_slot : signal_mux_184;
    assign signal_mux_186 = signal_and_76 ? execution$reg_pc : signal_mux_185;
    assign signal_mux_187 = signal_and_77 ? execution$reg_pc : signal_mux_186;
    assign signal_mux_188 = signal_and_82 ? execution$reg_pc : signal_mux_187;
    assign signal_mux_189 = signal_and_84 ? execution$reg_pc : signal_mux_188;
    assign signal_mux_190 = signal_and_85 ? execution$reg_pc : signal_mux_189;
    assign signal_mux_191 = signal_and_88 ? execution$reg_pc : signal_mux_190;
    assign signal_mux_192 = signal_and_90 ? execution$reg_pc : signal_mux_191;
    assign signal_mux_193 = signal_or_192 ? execution$reg_fault_instruction_slot : signal_mux_192;
    assign signal_mux_194 = signal_and_328 ? execution$reg_fault_instruction_slot : signal_mux_193;
    assign signal_mux_195 = signal_not_221 ? execution$reg_fault_instruction_slot : signal_mux_194;
    assign signal_mux_196 = signal_wire_195 ? signal_const_128 : signal_mux_195;
    assign signal_wire_30 = signal_mux_196;
    always @(posedge signal_wire_167) begin
        execution$reg_fault_instruction_slot <= signal_wire_30;
    end
    assign signal_const_131 = 4'b1001;
    assign signal_const_132 = 4'b1000;
    assign signal_const_133 = 4'b0111;
    assign signal_const_134 = 4'b0110;
    assign signal_const_135 = 4'b0010;
    assign signal_const_136 = 4'b0001;
    assign signal_const_137 = 4'b0100;
    assign signal_const_138 = 4'b0011;
    assign signal_const_139 = 4'b0101;
    assign signal_const_140 = 4'b0000;
    assign signal_mux_197 = signal_and_73 ? signal_const_140 : execution$reg_fault_kind;
    assign signal_mux_198 = signal_and_325 ? signal_const_140 : signal_mux_197;
    assign signal_mux_199 = signal_and_74 ? signal_const_139 : signal_mux_198;
    assign signal_mux_200 = signal_and_75 ? signal_const_138 : signal_mux_199;
    assign signal_mux_201 = signal_and_76 ? signal_const_137 : signal_mux_200;
    assign signal_mux_202 = signal_and_77 ? signal_const_136 : signal_mux_201;
    assign signal_mux_203 = signal_and_82 ? signal_const_135 : signal_mux_202;
    assign signal_mux_204 = signal_and_84 ? signal_const_134 : signal_mux_203;
    assign signal_mux_205 = signal_and_85 ? signal_const_133 : signal_mux_204;
    assign signal_mux_206 = signal_and_88 ? signal_const_132 : signal_mux_205;
    assign signal_mux_207 = signal_and_90 ? signal_const_131 : signal_mux_206;
    assign signal_mux_208 = signal_or_192 ? execution$reg_fault_kind : signal_mux_207;
    assign signal_mux_209 = signal_and_328 ? execution$reg_fault_kind : signal_mux_208;
    assign signal_mux_210 = signal_not_221 ? execution$reg_fault_kind : signal_mux_209;
    assign signal_mux_211 = signal_wire_195 ? signal_const_140 : signal_mux_210;
    assign signal_wire_31 = signal_mux_211;
    always @(posedge signal_wire_167) begin
        execution$reg_fault_kind <= signal_wire_31;
    end
    assign signal_mux_212 = signal_and_65 ? signal_const_37 : signal_reg;
    assign signal_mux_213 = signal_and_324 ? signal_const_37 : signal_mux_212;
    assign signal_mux_214 = signal_and_342 ? signal_const_39 : signal_mux_213;
    assign signal_mux_215 = signal_not_225 ? signal_reg : signal_mux_214;
    assign signal_wire_32 = signal_mux_215;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg <= signal_const_37;
        else
            signal_reg <= signal_wire_32;
    end
    assign signal_not_23 = ~ signal_and_73;
    assign signal_and_32 = signal_wire_181 & signal_not_23;
    assign signal_not_24 = ~ signal_and_328;
    assign signal_and_33 = signal_wire_190 & signal_not_24;
    assign signal_not_25 = ~ signal_and_313;
    assign signal_and_34 = signal_wire_182 & signal_not_25;
    assign signal_not_26 = ~ signal_and_325;
    assign signal_and_35 = signal_wire_183 & signal_not_26;
    assign signal_and_36 = signal_reg_5 & signal_eq_7;
    assign signal_mux_216 = signal_and_62 ? signal_and_36 : signal_const_37;
    assign signal_mux_217 = signal_not_225 ? signal_const_37 : signal_mux_216;
    assign signal_wire_33 = signal_mux_217;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_1 <= signal_const_37;
        else
            signal_reg_1 <= signal_wire_33;
    end
    assign signal_const_148 = 16'b0000000000000000;
    assign signal_mux_218 = signal_and_62 ? signal_wire_159 : signal_reg_2;
    assign signal_mux_219 = signal_not_225 ? signal_reg_2 : signal_mux_218;
    assign signal_wire_34 = signal_mux_219;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_2 <= signal_const_148;
        else
            signal_reg_2 <= signal_wire_34;
    end
    assign signal_mux_220 = signal_and_62 ? signal_const_39 : signal_const_37;
    assign signal_mux_221 = signal_wire_193 ? signal_const_37 : signal_mux_220;
    assign signal_mux_222 = signal_and_65 ? signal_const_37 : signal_mux_221;
    assign signal_mux_223 = signal_not_225 ? signal_const_37 : signal_mux_222;
    assign signal_wire_35 = signal_mux_223;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_3 <= signal_const_37;
        else
            signal_reg_3 <= signal_wire_35;
    end
    assign signal_not_27 = ~ signal_and_58;
    assign signal_and_37 = signal_wire_186 & signal_not_27;
    assign signal_not_28 = ~ signal_and_72;
    assign signal_and_38 = signal_wire_185 & signal_not_28;
    assign signal_not_29 = ~ signal_and_351;
    assign signal_and_39 = signal_wire_187 & signal_not_29;
    assign signal_not_30 = ~ signal_and_65;
    assign signal_and_40 = signal_wire_188 & signal_not_30;
    assign signal_wire_36 = load_data_i;
    assign signal_mux_224 = signal_and_58 ? signal_wire_47 : signal_wire_38;
    assign signal_mux_225 = signal_and_351 ? signal_wire_37 : signal_mux_224;
    assign signal_select_78 = signal_mux_225[7:0];
    assign signal_not_31 = ~ signal_wire_195;
    assign signal_and_41 = signal_and_351 & signal_not_31;
    assign signal_not_32 = ~ signal_wire_195;
    assign signal_or_18 = signal_and_58 | signal_and_337;
    assign signal_lt = signal_wire_37 < signal_reg_9;
    assign signal_wire_37 = load_address_i;
    assign signal_eq_4 = signal_wire_37 == signal_reg_10;
    assign signal_not_33 = ~ signal_wire_193;
    assign signal_not_34 = ~ signal_wire_195;
    assign signal_mux_226 = signal_wire_193 ? signal_const_37 : signal_reg_30;
    assign signal_mux_227 = signal_and_324 ? signal_const_39 : signal_mux_226;
    assign signal_not_35 = ~ signal_and_43;
    assign signal_not_36 = ~ signal_wire_193;
    assign signal_and_42 = signal_and_264 & signal_not_36;
    assign signal_mux_228 = signal_and_42 ? signal_const_37 : signal_reg_29;
    assign signal_mux_229 = signal_wire_193 ? signal_const_37 : signal_mux_228;
    assign signal_mux_230 = signal_and_342 ? signal_const_37 : signal_mux_229;
    assign signal_lt_1 = signal_wire_38 < signal_reg_9;
    assign signal_const_166 = 9'b100000000;
    assign signal_const_167 = 17'b00000000000000001;
    assign signal_add_9 = execution$reg_pc + signal_const_167;
    assign signal_mux_231 = signal_and_100 ? signal_add_9 : execution$reg_pc;
    assign signal_select_79 = signal_mux_231[8:0];
    assign signal_wire_38 = signal_select_79;
    assign signal_lt_2 = signal_wire_38 < signal_const_166;
    assign signal_and_43 = signal_lt_2 & signal_lt_1;
    assign signal_wire_39 = signal_or_167;
    assign signal_or_19 = signal_and_74 | signal_and_75;
    assign signal_or_20 = signal_or_19 | signal_and_76;
    assign signal_or_21 = signal_or_20 | signal_and_77;
    assign signal_or_22 = signal_or_21 | signal_and_82;
    assign signal_or_23 = signal_or_22 | signal_and_84;
    assign signal_or_24 = signal_or_23 | signal_and_85;
    assign signal_or_25 = signal_or_24 | signal_and_88;
    assign signal_or_26 = signal_or_25 | signal_and_90;
    assign signal_eq_5 = signal_select_365 == signal_const_116;
    assign signal_not_37 = ~ signal_wire_65;
    assign signal_and_44 = signal_and_265 & signal_and_81;
    assign signal_not_38 = ~ signal_mux_772;
    assign signal_const_174 = 3'b110;
    assign signal_mux_232 = signal_and_100 ? signal_const_119 : signal_const_118;
    assign signal_mux_233 = signal_and_73 ? signal_const_117 : execution$reg_phase;
    assign signal_mux_234 = signal_and_325 ? signal_const_117 : signal_mux_233;
    assign signal_mux_235 = signal_and_282 ? signal_mux_232 : signal_mux_234;
    assign signal_mux_236 = signal_and_103 ? signal_const_117 : signal_mux_235;
    assign signal_mux_237 = signal_and_334 ? signal_const_4 : signal_mux_236;
    assign signal_not_39 = ~ signal_wire_67;
    assign signal_not_40 = ~ signal_wire_172;
    assign signal_and_45 = signal_and_283 & signal_not_40;
    assign signal_and_46 = signal_and_45 & signal_not_39;
    assign signal_mux_238 = signal_and_46 ? signal_const_120 : signal_mux_237;
    assign signal_not_41 = ~ signal_wire_65;
    assign signal_and_47 = signal_and_278 & signal_not_41;
    assign signal_mux_239 = signal_and_47 ? signal_const_121 : signal_mux_238;
    assign signal_mux_240 = signal_and_280 ? signal_const_117 : signal_mux_239;
    assign signal_mux_241 = signal_and_74 ? signal_const_174 : signal_mux_240;
    assign signal_mux_242 = signal_and_75 ? signal_const_174 : signal_mux_241;
    assign signal_mux_243 = signal_and_76 ? signal_const_174 : signal_mux_242;
    assign signal_mux_244 = signal_and_77 ? signal_const_174 : signal_mux_243;
    assign signal_mux_245 = signal_and_82 ? signal_const_174 : signal_mux_244;
    assign signal_mux_246 = signal_and_84 ? signal_const_174 : signal_mux_245;
    assign signal_mux_247 = signal_and_85 ? signal_const_174 : signal_mux_246;
    assign signal_mux_248 = signal_and_88 ? signal_const_174 : signal_mux_247;
    assign signal_mux_249 = signal_and_90 ? signal_const_174 : signal_mux_248;
    assign signal_mux_250 = signal_and_73 ? signal_const_39 : reg_stepping;
    assign signal_mux_251 = signal_and_48 ? signal_const_37 : signal_mux_250;
    assign signal_mux_252 = signal_or_190 ? signal_const_37 : signal_mux_251;
    assign signal_wire_40 = signal_mux_252;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            reg_stepping <= signal_const_37;
        else
            reg_stepping <= signal_wire_40;
    end
    assign signal_and_48 = reg_stepping & signal_wire_42;
    assign signal_mux_253 = signal_and_325 ? signal_const_37 : signal_const_37;
    assign signal_or_27 = signal_and_333 | signal_and_280;
    assign signal_mux_254 = signal_or_27 ? signal_const_39 : signal_mux_253;
    assign signal_mux_255 = signal_and_74 ? signal_const_39 : signal_mux_254;
    assign signal_mux_256 = signal_and_75 ? signal_const_39 : signal_mux_255;
    assign signal_mux_257 = signal_and_76 ? signal_const_39 : signal_mux_256;
    assign signal_mux_258 = signal_and_77 ? signal_const_39 : signal_mux_257;
    assign signal_mux_259 = signal_and_82 ? signal_const_39 : signal_mux_258;
    assign signal_mux_260 = signal_and_84 ? signal_const_39 : signal_mux_259;
    assign signal_mux_261 = signal_and_85 ? signal_const_39 : signal_mux_260;
    assign signal_mux_262 = signal_and_88 ? signal_const_39 : signal_mux_261;
    assign signal_mux_263 = signal_and_90 ? signal_const_39 : signal_mux_262;
    assign signal_mux_264 = signal_or_192 ? signal_const_37 : signal_mux_263;
    assign signal_mux_265 = signal_and_328 ? signal_const_37 : signal_mux_264;
    assign signal_mux_266 = signal_not_221 ? signal_const_37 : signal_mux_265;
    assign signal_mux_267 = signal_wire_195 ? signal_const_37 : signal_mux_266;
    assign signal_wire_41 = signal_mux_267;
    always @(posedge signal_wire_167) begin
        execution$reg_boundary <= signal_wire_41;
    end
    assign signal_wire_42 = execution$reg_boundary;
    assign signal_not_42 = ~ signal_not_226;
    assign signal_and_49 = signal_and_313 & signal_not_42;
    assign signal_mux_268 = signal_and_49 ? signal_const_39 : reg_stop_pending;
    assign signal_mux_269 = signal_and_326 ? signal_const_37 : signal_mux_268;
    assign signal_not_43 = ~ signal_wire_197;
    assign signal_not_44 = ~ signal_reg_7;
    assign signal_mux_270 = signal_and_65 ? signal_const_37 : signal_reg_12;
    assign signal_not_45 = ~ signal_reg_7;
    assign signal_not_46 = ~ signal_reg_6;
    assign signal_const_215 = 9'b000000000;
    assign signal_const_217 = 9'b000000001;
    assign signal_add_10 = signal_reg_8 + signal_const_217;
    assign signal_mux_271 = signal_eq_7 ? signal_add_10 : signal_reg_8;
    assign signal_mux_272 = signal_reg_5 ? signal_mux_271 : signal_reg_8;
    assign signal_not_47 = ~ signal_wire_193;
    assign signal_not_48 = ~ signal_wire_195;
    assign signal_not_49 = ~ signal_and_65;
    assign signal_mux_273 = signal_and_62 ? signal_const_37 : signal_reg_7;
    assign signal_mux_274 = signal_wire_193 ? signal_const_37 : signal_mux_273;
    assign signal_mux_275 = signal_and_65 ? signal_const_37 : signal_mux_274;
    assign signal_lt_3 = signal_wire_47 < signal_reg_9;
    assign signal_eq_6 = signal_wire_47 == signal_reg_8;
    assign signal_wire_43 = readback_expected_i;
    assign signal_mux_276 = signal_and_58 ? signal_wire_43 : signal_reg_4;
    assign signal_mux_277 = signal_not_225 ? signal_reg_4 : signal_mux_276;
    assign signal_wire_44 = signal_mux_277;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_4 <= signal_const_148;
        else
            signal_reg_4 <= signal_wire_44;
    end
    assign signal_eq_7 = signal_wire_159 == signal_reg_4;
    assign signal_mux_278 = signal_eq_7 ? signal_reg_6 : signal_const_39;
    assign signal_mux_279 = signal_and_58 ? signal_wire_48 : signal_reg_5;
    assign signal_mux_280 = signal_not_225 ? signal_reg_5 : signal_mux_279;
    assign signal_wire_45 = signal_mux_280;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_5 <= signal_const_37;
        else
            signal_reg_5 <= signal_wire_45;
    end
    assign signal_mux_281 = signal_reg_5 ? signal_mux_278 : signal_reg_6;
    assign signal_mux_282 = signal_and_62 ? signal_mux_281 : signal_reg_6;
    assign signal_mux_283 = signal_and_65 ? signal_const_37 : signal_mux_282;
    assign signal_mux_284 = signal_not_225 ? signal_reg_6 : signal_mux_283;
    assign signal_wire_46 = signal_mux_284;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_6 <= signal_const_37;
        else
            signal_reg_6 <= signal_wire_46;
    end
    assign signal_not_50 = ~ signal_reg_6;
    assign signal_eq_8 = signal_reg_10 == signal_reg_9;
    assign signal_and_50 = signal_reg_11 & signal_eq_8;
    assign signal_and_51 = signal_and_50 & signal_not_50;
    assign signal_and_52 = signal_and_51 & signal_eq_6;
    assign signal_and_53 = signal_and_52 & signal_lt_3;
    assign signal_mux_285 = signal_reg_11 ? signal_reg_10 : signal_reg_9;
    assign signal_wire_47 = readback_address_i;
    assign signal_lt_4 = signal_wire_47 < signal_mux_285;
    assign signal_or_28 = signal_reg_11 | signal_reg_12;
    assign signal_and_54 = signal_or_28 & signal_lt_4;
    assign signal_wire_48 = readback_verify_i;
    assign signal_mux_286 = signal_wire_48 ? signal_and_53 : signal_and_54;
    assign signal_not_51 = ~ signal_reg_7;
    assign signal_and_55 = signal_and_346 & signal_and_317;
    assign signal_and_56 = signal_and_55 & signal_wire_186;
    assign signal_and_57 = signal_and_56 & signal_not_51;
    assign signal_and_58 = signal_and_57 & signal_mux_286;
    assign signal_mux_287 = signal_and_58 ? signal_const_39 : signal_mux_275;
    assign signal_mux_288 = signal_not_225 ? signal_const_37 : signal_mux_287;
    assign signal_wire_49 = signal_mux_288;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_7 <= signal_const_37;
        else
            signal_reg_7 <= signal_wire_49;
    end
    assign signal_and_59 = signal_wire_197 & signal_reg_7;
    assign signal_and_60 = signal_and_59 & signal_not_49;
    assign signal_and_61 = signal_and_60 & signal_not_48;
    assign signal_and_62 = signal_and_61 & signal_not_47;
    assign signal_mux_289 = signal_and_62 ? signal_mux_272 : signal_reg_8;
    assign signal_mux_290 = signal_and_65 ? signal_const_215 : signal_mux_289;
    assign signal_mux_291 = signal_not_225 ? signal_reg_8 : signal_mux_290;
    assign signal_wire_50 = signal_mux_291;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_8 <= signal_const_215;
        else
            signal_reg_8 <= signal_wire_50;
    end
    assign signal_eq_9 = signal_reg_8 == signal_reg_9;
    assign signal_mux_292 = signal_and_65 ? signal_wire_53 : signal_reg_9;
    assign signal_mux_293 = signal_not_225 ? signal_reg_9 : signal_mux_292;
    assign signal_wire_51 = signal_mux_293;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_9 <= signal_const_215;
        else
            signal_reg_9 <= signal_wire_51;
    end
    assign signal_add_11 = signal_reg_10 + signal_const_217;
    assign signal_mux_294 = signal_and_65 ? signal_const_215 : signal_reg_10;
    assign signal_mux_295 = signal_and_351 ? signal_add_11 : signal_mux_294;
    assign signal_mux_296 = signal_not_225 ? signal_reg_10 : signal_mux_295;
    assign signal_wire_52 = signal_mux_296;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_10 <= signal_const_215;
        else
            signal_reg_10 <= signal_wire_52;
    end
    assign signal_eq_10 = signal_reg_10 == signal_reg_9;
    assign signal_lt_5 = signal_const_166 < signal_wire_53;
    assign signal_not_52 = ~ signal_lt_5;
    assign signal_wire_53 = load_length_i;
    assign signal_lt_6 = signal_const_215 < signal_wire_53;
    assign signal_and_63 = signal_lt_6 & signal_not_52;
    assign signal_and_64 = signal_and_346 & signal_wire_188;
    assign signal_and_65 = signal_and_64 & signal_and_63;
    assign signal_mux_297 = signal_and_65 ? signal_const_39 : signal_reg_11;
    assign signal_mux_298 = signal_and_72 ? signal_const_37 : signal_mux_297;
    assign signal_mux_299 = signal_not_225 ? signal_const_37 : signal_mux_298;
    assign signal_wire_54 = signal_mux_299;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_11 <= signal_const_37;
        else
            signal_reg_11 <= signal_wire_54;
    end
    assign signal_and_66 = signal_and_346 & signal_and_318;
    assign signal_and_67 = signal_and_66 & signal_wire_185;
    assign signal_and_68 = signal_and_67 & signal_reg_11;
    assign signal_and_69 = signal_and_68 & signal_eq_10;
    assign signal_and_70 = signal_and_69 & signal_eq_9;
    assign signal_and_71 = signal_and_70 & signal_not_46;
    assign signal_and_72 = signal_and_71 & signal_not_45;
    assign signal_mux_300 = signal_and_72 ? signal_const_39 : signal_mux_270;
    assign signal_mux_301 = signal_not_225 ? signal_reg_12 : signal_mux_300;
    assign signal_wire_55 = signal_mux_301;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_12 <= signal_const_37;
        else
            signal_reg_12 <= signal_wire_55;
    end
    assign signal_mux_302 = signal_and_73 ? signal_const_37 : execution$reg_normal_halt;
    assign signal_mux_303 = signal_and_325 ? signal_const_37 : signal_mux_302;
    assign signal_mux_304 = signal_and_334 ? signal_const_39 : signal_mux_303;
    assign signal_mux_305 = signal_and_74 ? signal_const_37 : signal_mux_304;
    assign signal_mux_306 = signal_and_75 ? signal_const_37 : signal_mux_305;
    assign signal_mux_307 = signal_and_76 ? signal_const_37 : signal_mux_306;
    assign signal_mux_308 = signal_and_77 ? signal_const_37 : signal_mux_307;
    assign signal_mux_309 = signal_and_82 ? signal_const_37 : signal_mux_308;
    assign signal_mux_310 = signal_and_84 ? signal_const_37 : signal_mux_309;
    assign signal_mux_311 = signal_and_85 ? signal_const_37 : signal_mux_310;
    assign signal_mux_312 = signal_and_88 ? signal_const_37 : signal_mux_311;
    assign signal_mux_313 = signal_and_90 ? signal_const_37 : signal_mux_312;
    assign signal_mux_314 = signal_or_192 ? execution$reg_normal_halt : signal_mux_313;
    assign signal_mux_315 = signal_and_328 ? execution$reg_normal_halt : signal_mux_314;
    assign signal_mux_316 = signal_not_221 ? execution$reg_normal_halt : signal_mux_315;
    assign signal_mux_317 = signal_wire_195 ? signal_const_37 : signal_mux_316;
    assign signal_wire_56 = signal_mux_317;
    always @(posedge signal_wire_167) begin
        execution$reg_normal_halt <= signal_wire_56;
    end
    assign signal_wire_57 = execution$reg_normal_halt;
    assign signal_not_53 = ~ signal_wire_57;
    assign signal_and_73 = signal_and_324 & signal_and_310;
    assign signal_mux_318 = signal_and_73 ? signal_const_37 : execution$reg_execution_fault;
    assign signal_mux_319 = signal_and_325 ? signal_const_37 : signal_mux_318;
    assign signal_not_54 = ~ signal_eq_263;
    assign signal_and_74 = signal_eq_264 & signal_not_54;
    assign signal_mux_320 = signal_and_74 ? signal_const_39 : signal_mux_319;
    assign signal_and_75 = signal_and_281 & signal_and_342;
    assign signal_mux_321 = signal_and_75 ? signal_const_39 : signal_mux_320;
    assign signal_and_76 = signal_and_100 & signal_and_342;
    assign signal_mux_322 = signal_and_76 ? signal_const_39 : signal_mux_321;
    assign signal_not_55 = ~ signal_and_98;
    assign signal_and_77 = signal_and_329 & signal_not_55;
    assign signal_mux_323 = signal_and_77 ? signal_const_39 : signal_mux_322;
    assign signal_const_262 = 16'b0000000011111111;
    assign signal_lt_7 = signal_const_262 < signal_mux_770;
    assign signal_not_56 = ~ signal_lt_7;
    assign signal_eq_11 = signal_mux_770 == signal_const_148;
    assign signal_not_57 = ~ signal_eq_11;
    assign signal_const_264 = 5'b10100;
    assign signal_eq_12 = signal_select_365 == signal_const_264;
    assign signal_const_265 = 5'b10011;
    assign signal_eq_13 = signal_select_365 == signal_const_265;
    assign signal_const_266 = 5'b10101;
    assign signal_eq_14 = signal_select_365 == signal_const_266;
    assign signal_const_267 = 5'b10001;
    assign signal_eq_15 = signal_select_365 == signal_const_267;
    assign signal_or_29 = signal_eq_15 | signal_eq_14;
    assign signal_or_30 = signal_or_29 | signal_eq_13;
    assign signal_or_31 = signal_or_30 | signal_eq_12;
    assign signal_mux_324 = signal_or_31 ? signal_not_57 : vdd;
    assign signal_const_268 = 5'b01111;
    assign signal_eq_16 = signal_select_365 == signal_const_268;
    assign signal_mux_325 = signal_eq_16 ? signal_not_56 : signal_mux_324;
    assign signal_mux_326 = signal_and_100 ? signal_const_39 : signal_const_37;
    assign signal_mux_327 = signal_and_325 ? signal_const_37 : execution$reg_has_extension;
    assign signal_mux_328 = signal_and_282 ? signal_mux_326 : signal_mux_327;
    assign signal_mux_329 = signal_or_192 ? signal_const_37 : signal_mux_328;
    assign signal_mux_330 = signal_and_328 ? signal_const_37 : signal_mux_329;
    assign signal_mux_331 = signal_not_221 ? signal_const_37 : signal_mux_330;
    assign signal_mux_332 = signal_wire_195 ? signal_const_37 : signal_mux_331;
    assign signal_wire_58 = signal_mux_332;
    always @(posedge signal_wire_167) begin
        execution$reg_has_extension <= signal_wire_58;
    end
    assign signal_or_32 = signal_eq_21 | signal_eq_75;
    assign signal_and_78 = signal_or_32 & execution$reg_has_extension;
    assign signal_and_79 = signal_eq_223 & signal_and_264;
    assign signal_or_33 = signal_and_79 | signal_and_78;
    assign signal_and_80 = signal_or_33 & signal_mux_325;
    assign signal_not_58 = ~ signal_mux_772;
    assign signal_or_34 = signal_not_58 | signal_and_80;
    assign signal_and_81 = signal_and_98 & signal_or_34;
    assign signal_not_59 = ~ signal_and_81;
    assign signal_and_82 = signal_and_265 & signal_not_59;
    assign signal_mux_333 = signal_and_82 ? signal_const_39 : signal_mux_323;
    assign signal_not_60 = ~ signal_wire_172;
    assign signal_and_83 = signal_and_284 & signal_wire_67;
    assign signal_and_84 = signal_and_83 & signal_not_60;
    assign signal_mux_334 = signal_and_84 ? signal_const_39 : signal_mux_333;
    assign signal_or_35 = signal_and_279 | signal_and_108;
    assign signal_and_85 = signal_or_35 & signal_wire_64;
    assign signal_mux_335 = signal_and_85 ? signal_const_39 : signal_mux_334;
    assign signal_not_61 = ~ signal_and_108;
    assign signal_not_62 = ~ signal_and_279;
    assign signal_and_86 = signal_and_106 & signal_wire_65;
    assign signal_and_87 = signal_and_86 & signal_not_62;
    assign signal_and_88 = signal_and_87 & signal_not_61;
    assign signal_mux_336 = signal_and_88 ? signal_const_39 : signal_mux_335;
    assign signal_and_89 = signal_and_284 & signal_wire_172;
    assign signal_and_90 = signal_and_89 & signal_wire_67;
    assign signal_mux_337 = signal_and_90 ? signal_const_39 : signal_mux_336;
    assign signal_mux_338 = signal_or_192 ? execution$reg_execution_fault : signal_mux_337;
    assign signal_mux_339 = signal_and_328 ? execution$reg_execution_fault : signal_mux_338;
    assign signal_mux_340 = signal_not_221 ? execution$reg_execution_fault : signal_mux_339;
    assign signal_mux_341 = signal_wire_195 ? signal_const_37 : signal_mux_340;
    assign signal_wire_59 = signal_mux_341;
    always @(posedge signal_wire_167) begin
        execution$reg_execution_fault <= signal_wire_59;
    end
    assign signal_wire_60 = execution$reg_execution_fault;
    assign signal_not_63 = ~ signal_wire_60;
    assign signal_not_64 = ~ signal_or_76;
    assign signal_eq_17 = mechanisms$bank$reg_engine_claim == signal_const_43;
    assign signal_not_65 = ~ mechanisms$lane$reg_armed;
    assign signal_not_66 = ~ mechanisms$lane$reg_busy;
    assign signal_const_276 = 2'b00;
    assign signal_eq_18 = mechanisms$reg_bridge_state == signal_const_276;
    assign signal_not_67 = ~ mechanisms$reg_fifo_pending;
    assign signal_not_68 = ~ mechanisms$timing$reg_busy;
    assign signal_mux_342 = signal_and_291 ? signal_const_39 : mechanisms$reg_wait_pending;
    assign signal_not_69 = ~ signal_and_328;
    assign signal_not_70 = ~ signal_wire_195;
    assign signal_mux_343 = signal_eq_183 ? signal_const_39 : signal_const_37;
    assign signal_mux_344 = signal_and_196 ? signal_mux_343 : signal_const_37;
    assign signal_mux_345 = signal_mux_704 ? signal_const_39 : signal_mux_344;
    assign signal_mux_346 = signal_and_196 ? signal_const_37 : mechanisms$timing$reg_busy;
    assign signal_mux_347 = signal_mux_704 ? signal_const_37 : signal_mux_346;
    assign signal_mux_348 = signal_and_199 ? mechanisms$timing$reg_busy : signal_const_39;
    assign signal_mux_349 = signal_and_203 ? mechanisms$timing$reg_busy : signal_mux_348;
    assign signal_not_71 = ~ signal_and_121;
    assign signal_eq_19 = signal_wire_171 == signal_const_133;
    assign signal_and_91 = signal_and_287 & signal_eq_19;
    assign signal_eq_20 = signal_wire_171 == signal_const_134;
    assign signal_not_72 = ~ signal_and_328;
    assign signal_not_73 = ~ signal_wire_195;
    assign signal_eq_21 = execution$reg_phase == signal_const_120;
    assign signal_const_293 = 5'b10111;
    assign signal_eq_22 = signal_select_365 == signal_const_293;
    assign signal_const_294 = 5'b11100;
    assign signal_eq_23 = signal_select_365 == signal_const_294;
    assign signal_const_295 = 5'b11011;
    assign signal_eq_24 = signal_select_365 == signal_const_295;
    assign signal_const_296 = 5'b01110;
    assign signal_eq_25 = signal_select_365 == signal_const_296;
    assign signal_const_297 = 5'b01100;
    assign signal_eq_26 = signal_select_365 == signal_const_297;
    assign signal_const_298 = 5'b01011;
    assign signal_eq_27 = signal_select_365 == signal_const_298;
    assign signal_const_299 = 5'b00111;
    assign signal_eq_28 = signal_select_365 == signal_const_299;
    assign signal_const_300 = 5'b00110;
    assign signal_eq_29 = signal_select_365 == signal_const_300;
    assign signal_const_301 = 5'b00101;
    assign signal_eq_30 = signal_select_365 == signal_const_301;
    assign signal_const_302 = 5'b00100;
    assign signal_eq_31 = signal_select_365 == signal_const_302;
    assign signal_const_303 = 5'b00011;
    assign signal_eq_32 = signal_select_365 == signal_const_303;
    assign signal_const_304 = 5'b00010;
    assign signal_eq_33 = signal_select_365 == signal_const_304;
    assign signal_const_305 = 5'b00001;
    assign signal_eq_34 = signal_select_365 == signal_const_305;
    assign signal_mux_350 = signal_and_100 ? signal_wire_159 : signal_mux_351;
    assign signal_mux_351 = signal_and_325 ? signal_const_148 : execution$reg_base_word;
    assign signal_select_80 = signal_mux_873[10:7];
    assign signal_lt_8 = signal_select_80 < signal_const_131;
    assign signal_const_309 = 10'b0000000000;
    assign signal_select_81 = signal_mux_873[9:0];
    assign signal_eq_35 = signal_select_81 == signal_const_309;
    assign signal_not_74 = ~ signal_eq_35;
    assign signal_select_82 = signal_mux_873[10:10];
    assign signal_or_36 = signal_select_82 | signal_not_74;
    assign signal_select_83 = signal_mux_873[3:0];
    assign signal_eq_36 = signal_select_83 == signal_const_140;
    assign signal_select_84 = signal_mux_873[3:0];
    assign signal_eq_37 = signal_select_84 == signal_const_140;
    assign signal_not_75 = ~ signal_eq_37;
    assign signal_select_85 = signal_mux_873[4:4];
    assign signal_mux_352 = signal_select_85 ? signal_eq_36 : signal_not_75;
    assign signal_select_86 = signal_mux_873[3:0];
    assign signal_eq_38 = signal_select_86 == signal_const_140;
    assign signal_select_87 = signal_mux_873[4:4];
    assign signal_not_76 = ~ signal_select_87;
    assign signal_and_92 = signal_not_76 & signal_eq_38;
    assign signal_select_88 = signal_mux_873[5:5];
    assign signal_mux_353 = signal_select_88 ? signal_mux_352 : signal_and_92;
    assign signal_const_313 = 2'b11;
    assign signal_select_89 = signal_mux_873[7:6];
    assign signal_lt_9 = signal_select_89 < signal_const_313;
    assign signal_and_93 = signal_lt_9 & signal_mux_353;
    assign signal_select_90 = signal_mux_873[4:0];
    assign signal_eq_39 = signal_select_90 == signal_const_116;
    assign signal_select_91 = signal_mux_873[4:0];
    assign signal_eq_40 = signal_select_91 == signal_const_116;
    assign signal_not_77 = ~ signal_eq_40;
    assign signal_select_92 = signal_mux_873[5:5];
    assign signal_mux_354 = signal_select_92 ? signal_eq_39 : signal_not_77;
    assign signal_select_93 = signal_mux_873[4:0];
    assign signal_eq_41 = signal_select_93 == signal_const_116;
    assign signal_select_94 = signal_mux_873[5:5];
    assign signal_not_78 = ~ signal_select_94;
    assign signal_and_94 = signal_not_78 & signal_eq_41;
    assign signal_select_95 = signal_mux_873[6:6];
    assign signal_mux_355 = signal_select_95 ? signal_mux_354 : signal_and_94;
    assign signal_select_96 = signal_mux_873[9:0];
    assign signal_eq_42 = signal_select_96 == signal_const_309;
    assign signal_not_79 = ~ signal_eq_42;
    assign signal_select_97 = signal_mux_873[10:10];
    assign signal_or_37 = signal_select_97 | signal_not_79;
    assign signal_select_98 = signal_mux_873[10:8];
    assign signal_lt_10 = signal_select_98 < signal_const_174;
    assign signal_select_99 = signal_mux_873[6:3];
    assign signal_eq_43 = signal_select_99 == signal_const_140;
    assign signal_not_80 = ~ signal_eq_43;
    assign signal_select_100 = signal_mux_873[10:8];
    assign signal_lt_11 = signal_select_100 < signal_const_121;
    assign signal_select_101 = signal_mux_873[10:8];
    assign signal_lt_12 = signal_select_101 < signal_const_121;
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_356 <= vdd;
        1:
            signal_mux_356 <= vdd;
        2:
            signal_mux_356 <= vdd;
        3:
            signal_mux_356 <= signal_lt_12;
        4:
            signal_mux_356 <= signal_lt_11;
        5:
            signal_mux_356 <= vdd;
        6:
            signal_mux_356 <= vdd;
        7:
            signal_mux_356 <= signal_not_80;
        8:
            signal_mux_356 <= vdd;
        9:
            signal_mux_356 <= vdd;
        10:
            signal_mux_356 <= vdd;
        11:
            signal_mux_356 <= vdd;
        12:
            signal_mux_356 <= signal_lt_10;
        13:
            signal_mux_356 <= vdd;
        14:
            signal_mux_356 <= vdd;
        15:
            signal_mux_356 <= vdd;
        16:
            signal_mux_356 <= vdd;
        17:
            signal_mux_356 <= signal_or_37;
        18:
            signal_mux_356 <= vdd;
        19:
            signal_mux_356 <= signal_mux_355;
        20:
            signal_mux_356 <= signal_and_93;
        21:
            signal_mux_356 <= signal_or_36;
        22:
            signal_mux_356 <= vdd;
        23:
            signal_mux_356 <= signal_lt_8;
        24:
            signal_mux_356 <= vdd;
        25:
            signal_mux_356 <= vdd;
        26:
            signal_mux_356 <= vdd;
        27:
            signal_mux_356 <= vdd;
        28:
            signal_mux_356 <= vdd;
        29:
            signal_mux_356 <= vdd;
        30:
            signal_mux_356 <= vdd;
        default:
            signal_mux_356 <= vdd;
        endcase
    end
    assign signal_select_102 = signal_mux_873[5:0];
    assign signal_eq_44 = signal_select_102 == signal_const_58;
    assign signal_select_103 = signal_mux_873[6:6];
    assign signal_not_81 = ~ signal_select_103;
    assign signal_or_38 = signal_not_81 | signal_eq_44;
    assign signal_select_104 = signal_mux_873[9:0];
    assign signal_eq_45 = signal_select_104 == signal_const_309;
    assign signal_select_105 = signal_mux_873[10:10];
    assign signal_not_82 = ~ signal_select_105;
    assign signal_or_39 = signal_not_82 | signal_eq_45;
    assign signal_select_106 = signal_mux_873[3:0];
    assign signal_eq_46 = signal_select_106 == signal_const_140;
    assign signal_select_107 = signal_mux_873[4:4];
    assign signal_not_83 = ~ signal_select_107;
    assign signal_or_40 = signal_not_83 | signal_eq_46;
    assign signal_select_108 = signal_mux_873[4:0];
    assign signal_eq_47 = signal_select_108 == signal_const_116;
    assign signal_select_109 = signal_mux_873[5:5];
    assign signal_not_84 = ~ signal_select_109;
    assign signal_or_41 = signal_not_84 | signal_eq_47;
    assign signal_select_110 = signal_mux_873[9:0];
    assign signal_eq_48 = signal_select_110 == signal_const_309;
    assign signal_select_111 = signal_mux_873[10:10];
    assign signal_not_85 = ~ signal_select_111;
    assign signal_or_42 = signal_not_85 | signal_eq_48;
    assign signal_const_327 = 7'b0000000;
    assign signal_select_112 = signal_mux_873[6:0];
    assign signal_eq_49 = signal_select_112 == signal_const_327;
    assign signal_select_113 = signal_mux_873[7:7];
    assign signal_not_86 = ~ signal_select_113;
    assign signal_or_43 = signal_not_86 | signal_eq_49;
    assign signal_select_114 = signal_mux_873[3:0];
    assign signal_eq_50 = signal_select_114 == signal_const_140;
    assign signal_select_115 = signal_mux_873[4:4];
    assign signal_not_87 = ~ signal_select_115;
    assign signal_or_44 = signal_not_87 | signal_eq_50;
    assign signal_select_116 = signal_mux_873[6:0];
    assign signal_eq_51 = signal_select_116 == signal_const_327;
    assign signal_select_117 = signal_mux_873[7:7];
    assign signal_not_88 = ~ signal_select_117;
    assign signal_or_45 = signal_not_88 | signal_eq_51;
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_357 <= vdd;
        1:
            signal_mux_357 <= signal_or_45;
        2:
            signal_mux_357 <= vdd;
        3:
            signal_mux_357 <= vdd;
        4:
            signal_mux_357 <= signal_or_44;
        5:
            signal_mux_357 <= vdd;
        6:
            signal_mux_357 <= signal_or_43;
        7:
            signal_mux_357 <= vdd;
        8:
            signal_mux_357 <= vdd;
        9:
            signal_mux_357 <= vdd;
        10:
            signal_mux_357 <= vdd;
        11:
            signal_mux_357 <= vdd;
        12:
            signal_mux_357 <= vdd;
        13:
            signal_mux_357 <= vdd;
        14:
            signal_mux_357 <= vdd;
        15:
            signal_mux_357 <= vdd;
        16:
            signal_mux_357 <= vdd;
        17:
            signal_mux_357 <= signal_or_42;
        18:
            signal_mux_357 <= vdd;
        19:
            signal_mux_357 <= signal_or_41;
        20:
            signal_mux_357 <= signal_or_40;
        21:
            signal_mux_357 <= signal_or_39;
        22:
            signal_mux_357 <= vdd;
        23:
            signal_mux_357 <= signal_or_38;
        24:
            signal_mux_357 <= vdd;
        25:
            signal_mux_357 <= vdd;
        26:
            signal_mux_357 <= vdd;
        27:
            signal_mux_357 <= vdd;
        28:
            signal_mux_357 <= vdd;
        29:
            signal_mux_357 <= gnd;
        30:
            signal_mux_357 <= gnd;
        default:
            signal_mux_357 <= gnd;
        endcase
    end
    assign signal_const_330 = 11'b00000000000;
    assign signal_const_332 = 11'b00011111111;
    assign signal_const_334 = 11'b00000111111;
    assign signal_const_336 = 11'b11111111111;
    assign signal_const_344 = 11'b00000001111;
    assign signal_const_345 = 11'b00000000011;
    assign signal_const_350 = 11'b11111000000;
    assign signal_const_353 = 11'b00000000111;
    assign signal_const_355 = 11'b00000011111;
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_358 <= signal_const_336;
        1:
            signal_mux_358 <= signal_const_330;
        2:
            signal_mux_358 <= signal_const_355;
        3:
            signal_mux_358 <= signal_const_345;
        4:
            signal_mux_358 <= signal_const_330;
        5:
            signal_mux_358 <= signal_const_355;
        6:
            signal_mux_358 <= signal_const_330;
        7:
            signal_mux_358 <= signal_const_353;
        8:
            signal_mux_358 <= signal_const_332;
        9:
            signal_mux_358 <= signal_const_332;
        10:
            signal_mux_358 <= signal_const_350;
        11:
            signal_mux_358 <= signal_const_330;
        12:
            signal_mux_358 <= signal_const_330;
        13:
            signal_mux_358 <= signal_const_330;
        14:
            signal_mux_358 <= signal_const_330;
        15:
            signal_mux_358 <= signal_const_345;
        16:
            signal_mux_358 <= signal_const_344;
        17:
            signal_mux_358 <= signal_const_330;
        18:
            signal_mux_358 <= signal_const_332;
        19:
            signal_mux_358 <= signal_const_330;
        20:
            signal_mux_358 <= signal_const_330;
        21:
            signal_mux_358 <= signal_const_330;
        22:
            signal_mux_358 <= signal_const_336;
        23:
            signal_mux_358 <= signal_const_330;
        24:
            signal_mux_358 <= signal_const_336;
        25:
            signal_mux_358 <= signal_const_334;
        26:
            signal_mux_358 <= signal_const_334;
        27:
            signal_mux_358 <= signal_const_330;
        28:
            signal_mux_358 <= signal_const_332;
        29:
            signal_mux_358 <= signal_const_330;
        30:
            signal_mux_358 <= signal_const_330;
        default:
            signal_mux_358 <= signal_const_330;
        endcase
    end
    assign signal_select_118 = signal_mux_873[10:0];
    assign signal_and_95 = signal_select_118 & signal_mux_358;
    assign signal_eq_52 = signal_and_95 == signal_const_330;
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_359 <= vdd;
        1:
            signal_mux_359 <= vdd;
        2:
            signal_mux_359 <= vdd;
        3:
            signal_mux_359 <= vdd;
        4:
            signal_mux_359 <= vdd;
        5:
            signal_mux_359 <= vdd;
        6:
            signal_mux_359 <= vdd;
        7:
            signal_mux_359 <= vdd;
        8:
            signal_mux_359 <= vdd;
        9:
            signal_mux_359 <= vdd;
        10:
            signal_mux_359 <= vdd;
        11:
            signal_mux_359 <= vdd;
        12:
            signal_mux_359 <= vdd;
        13:
            signal_mux_359 <= vdd;
        14:
            signal_mux_359 <= vdd;
        15:
            signal_mux_359 <= vdd;
        16:
            signal_mux_359 <= vdd;
        17:
            signal_mux_359 <= vdd;
        18:
            signal_mux_359 <= vdd;
        19:
            signal_mux_359 <= vdd;
        20:
            signal_mux_359 <= vdd;
        21:
            signal_mux_359 <= vdd;
        22:
            signal_mux_359 <= vdd;
        23:
            signal_mux_359 <= vdd;
        24:
            signal_mux_359 <= vdd;
        25:
            signal_mux_359 <= vdd;
        26:
            signal_mux_359 <= vdd;
        27:
            signal_mux_359 <= vdd;
        28:
            signal_mux_359 <= vdd;
        29:
            signal_mux_359 <= gnd;
        30:
            signal_mux_359 <= gnd;
        default:
            signal_mux_359 <= gnd;
        endcase
    end
    assign signal_and_96 = signal_mux_359 & signal_eq_52;
    assign signal_and_97 = signal_and_96 & signal_mux_357;
    assign signal_and_98 = signal_and_97 & signal_mux_356;
    assign signal_and_99 = signal_and_329 & signal_and_98;
    assign signal_and_100 = signal_and_99 & signal_mux_772;
    assign signal_select_119 = signal_mux_873[6:0];
    assign signal_select_120 = signal_select_119[6:6];
    assign signal_cat_3 = { signal_select_120,
                            signal_select_120 };
    assign signal_cat_4 = { signal_cat_3,
                            signal_cat_3 };
    assign signal_cat_5 = { signal_cat_4,
                            signal_cat_4 };
    assign signal_cat_6 = { signal_cat_5,
                            signal_cat_3 };
    assign signal_cat_7 = { signal_cat_6,
                            signal_select_119 };
    assign signal_add_12 = execution$reg_pc + signal_const_167;
    assign signal_add_13 = signal_add_12 + signal_cat_7;
    assign signal_select_121 = signal_wire_158[0:0];
    assign signal_const_363 = 5'b01101;
    assign signal_eq_53 = signal_select_365 == signal_const_363;
    assign signal_and_101 = signal_eq_53 & signal_select_121;
    assign signal_mux_360 = signal_and_101 ? signal_add_13 : signal_add_22;
    assign signal_select_122 = signal_mux_873[10:0];
    assign signal_select_123 = signal_select_122[10:10];
    assign signal_cat_8 = { signal_select_123,
                            signal_select_123 };
    assign signal_cat_9 = { signal_cat_8,
                            signal_cat_8 };
    assign signal_cat_10 = { signal_cat_9,
                             signal_cat_8 };
    assign signal_cat_11 = { signal_cat_10,
                             signal_select_122 };
    assign signal_add_14 = execution$reg_pc + signal_const_167;
    assign signal_add_15 = signal_add_14 + signal_cat_11;
    assign signal_select_124 = signal_mux_873[7:0];
    assign signal_select_125 = signal_select_124[7:7];
    assign signal_cat_12 = { signal_select_125,
                             signal_select_125 };
    assign signal_cat_13 = { signal_cat_12,
                             signal_cat_12 };
    assign signal_cat_14 = { signal_cat_13,
                             signal_cat_13 };
    assign signal_cat_15 = { signal_cat_14,
                             signal_select_125 };
    assign signal_cat_16 = { signal_cat_15,
                             signal_select_124 };
    assign signal_add_16 = execution$reg_pc + signal_const_167;
    assign signal_add_17 = signal_add_16 + signal_cat_16;
    assign signal_not_89 = ~ execution$reg_negative;
    assign signal_select_126 = signal_mux_388[15:15];
    assign signal_mux_361 = signal_and_325 ? signal_const_37 : execution$reg_negative;
    assign signal_mux_362 = signal_and_102 ? signal_select_126 : signal_mux_361;
    assign signal_mux_363 = signal_or_192 ? execution$reg_negative : signal_mux_362;
    assign signal_mux_364 = signal_and_328 ? execution$reg_negative : signal_mux_363;
    assign signal_mux_365 = signal_not_221 ? execution$reg_negative : signal_mux_364;
    assign signal_mux_366 = signal_wire_195 ? signal_const_37 : signal_mux_365;
    assign signal_wire_61 = signal_mux_366;
    always @(posedge signal_wire_167) begin
        execution$reg_negative <= signal_wire_61;
    end
    assign signal_not_90 = ~ execution$reg_carry;
    assign signal_lt_13 = signal_mux_762 < signal_mux_761;
    assign signal_select_127 = signal_add_31[16:16];
    always @* begin
        case (signal_select_312)
        0:
            signal_mux_367 <= signal_select_127;
        1:
            signal_mux_367 <= signal_lt_13;
        2:
            signal_mux_367 <= gnd;
        3:
            signal_mux_367 <= gnd;
        4:
            signal_mux_367 <= gnd;
        5:
            signal_mux_367 <= gnd;
        6:
            signal_mux_367 <= gnd;
        default:
            signal_mux_367 <= gnd;
        endcase
    end
    assign signal_lt_14 = signal_mux_774 < signal_mux_773;
    assign signal_select_128 = signal_add_32[16:16];
    always @* begin
        case (signal_select_330)
        0:
            signal_mux_368 <= signal_select_128;
        1:
            signal_mux_368 <= signal_lt_14;
        2:
            signal_mux_368 <= gnd;
        3:
            signal_mux_368 <= gnd;
        4:
            signal_mux_368 <= gnd;
        5:
            signal_mux_368 <= gnd;
        6:
            signal_mux_368 <= gnd;
        default:
            signal_mux_368 <= gnd;
        endcase
    end
    assign signal_lt_15 = signal_mux_383 < signal_mux_382;
    assign signal_lt_16 = signal_mux_384 < signal_mux_773;
    assign signal_select_129 = signal_mux_780[14:14];
    assign signal_select_130 = signal_mux_780[13:13];
    assign signal_select_131 = signal_mux_780[12:12];
    assign signal_select_132 = signal_mux_780[11:11];
    assign signal_select_133 = signal_mux_780[10:10];
    assign signal_select_134 = signal_mux_780[9:9];
    assign signal_select_135 = signal_mux_780[8:8];
    assign signal_select_136 = signal_mux_780[7:7];
    assign signal_select_137 = signal_mux_780[6:6];
    assign signal_select_138 = signal_mux_780[5:5];
    assign signal_select_139 = signal_mux_780[4:4];
    assign signal_select_140 = signal_mux_780[3:3];
    assign signal_select_141 = signal_mux_780[2:2];
    assign signal_select_142 = signal_mux_780[1:1];
    assign signal_select_143 = signal_mux_780[0:0];
    always @* begin
        case (signal_select_346)
        0:
            signal_mux_369 <= gnd;
        1:
            signal_mux_369 <= signal_select_143;
        2:
            signal_mux_369 <= signal_select_142;
        3:
            signal_mux_369 <= signal_select_141;
        4:
            signal_mux_369 <= signal_select_140;
        5:
            signal_mux_369 <= signal_select_139;
        6:
            signal_mux_369 <= signal_select_138;
        7:
            signal_mux_369 <= signal_select_137;
        8:
            signal_mux_369 <= signal_select_136;
        9:
            signal_mux_369 <= signal_select_135;
        10:
            signal_mux_369 <= signal_select_134;
        11:
            signal_mux_369 <= signal_select_133;
        12:
            signal_mux_369 <= signal_select_132;
        13:
            signal_mux_369 <= signal_select_131;
        14:
            signal_mux_369 <= signal_select_130;
        default:
            signal_mux_369 <= signal_select_129;
        endcase
    end
    assign signal_select_144 = signal_mux_780[1:1];
    assign signal_select_145 = signal_mux_780[2:2];
    assign signal_select_146 = signal_mux_780[3:3];
    assign signal_select_147 = signal_mux_780[4:4];
    assign signal_select_148 = signal_mux_780[5:5];
    assign signal_select_149 = signal_mux_780[6:6];
    assign signal_select_150 = signal_mux_780[7:7];
    assign signal_select_151 = signal_mux_780[8:8];
    assign signal_select_152 = signal_mux_780[9:9];
    assign signal_select_153 = signal_mux_780[10:10];
    assign signal_select_154 = signal_mux_780[11:11];
    assign signal_select_155 = signal_mux_780[12:12];
    assign signal_select_156 = signal_mux_780[13:13];
    assign signal_select_157 = signal_mux_780[14:14];
    assign signal_select_158 = signal_mux_780[15:15];
    always @* begin
        case (signal_select_346)
        0:
            signal_mux_370 <= gnd;
        1:
            signal_mux_370 <= signal_select_158;
        2:
            signal_mux_370 <= signal_select_157;
        3:
            signal_mux_370 <= signal_select_156;
        4:
            signal_mux_370 <= signal_select_155;
        5:
            signal_mux_370 <= signal_select_154;
        6:
            signal_mux_370 <= signal_select_153;
        7:
            signal_mux_370 <= signal_select_152;
        8:
            signal_mux_370 <= signal_select_151;
        9:
            signal_mux_370 <= signal_select_150;
        10:
            signal_mux_370 <= signal_select_149;
        11:
            signal_mux_370 <= signal_select_148;
        12:
            signal_mux_370 <= signal_select_147;
        13:
            signal_mux_370 <= signal_select_146;
        14:
            signal_mux_370 <= signal_select_145;
        default:
            signal_mux_370 <= signal_select_144;
        endcase
    end
    assign signal_mux_371 = signal_select_348 ? signal_mux_369 : signal_mux_370;
    assign signal_eq_54 = signal_select_365 == signal_const_300;
    assign signal_mux_372 = signal_eq_54 ? signal_lt_16 : signal_mux_371;
    assign signal_eq_55 = signal_select_365 == signal_const_301;
    assign signal_mux_373 = signal_eq_55 ? signal_lt_15 : signal_mux_372;
    assign signal_eq_56 = signal_select_365 == signal_const_302;
    assign signal_mux_374 = signal_eq_56 ? signal_mux_368 : signal_mux_373;
    assign signal_eq_57 = signal_select_365 == signal_const_303;
    assign signal_mux_375 = signal_eq_57 ? signal_mux_367 : signal_mux_374;
    assign signal_mux_376 = signal_and_325 ? signal_const_37 : execution$reg_carry;
    assign signal_mux_377 = signal_and_102 ? signal_mux_375 : signal_mux_376;
    assign signal_mux_378 = signal_or_192 ? execution$reg_carry : signal_mux_377;
    assign signal_mux_379 = signal_and_328 ? execution$reg_carry : signal_mux_378;
    assign signal_mux_380 = signal_not_221 ? execution$reg_carry : signal_mux_379;
    assign signal_mux_381 = signal_wire_195 ? signal_const_37 : signal_mux_380;
    assign signal_wire_62 = signal_mux_381;
    always @(posedge signal_wire_167) begin
        execution$reg_carry <= signal_wire_62;
    end
    assign signal_not_91 = ~ execution$reg_zero;
    assign signal_select_159 = signal_mux_873[7:5];
    always @* begin
        case (signal_select_159)
        0:
            signal_mux_382 <= execution$reg_r0;
        1:
            signal_mux_382 <= execution$reg_r1;
        2:
            signal_mux_382 <= execution$reg_r2;
        3:
            signal_mux_382 <= execution$reg_r3;
        4:
            signal_mux_382 <= execution$reg_r4;
        5:
            signal_mux_382 <= execution$reg_r5;
        6:
            signal_mux_382 <= execution$reg_r6;
        default:
            signal_mux_382 <= execution$reg_r7;
        endcase
    end
    assign signal_select_160 = signal_mux_873[10:8];
    always @* begin
        case (signal_select_160)
        0:
            signal_mux_383 <= execution$reg_r0;
        1:
            signal_mux_383 <= execution$reg_r1;
        2:
            signal_mux_383 <= execution$reg_r2;
        3:
            signal_mux_383 <= execution$reg_r3;
        4:
            signal_mux_383 <= execution$reg_r4;
        5:
            signal_mux_383 <= execution$reg_r5;
        6:
            signal_mux_383 <= execution$reg_r6;
        default:
            signal_mux_383 <= execution$reg_r7;
        endcase
    end
    assign signal_sub_5 = signal_mux_383 - signal_mux_382;
    assign signal_select_161 = signal_mux_873[10:8];
    always @* begin
        case (signal_select_161)
        0:
            signal_mux_384 <= execution$reg_r0;
        1:
            signal_mux_384 <= execution$reg_r1;
        2:
            signal_mux_384 <= execution$reg_r2;
        3:
            signal_mux_384 <= execution$reg_r3;
        4:
            signal_mux_384 <= execution$reg_r4;
        5:
            signal_mux_384 <= execution$reg_r5;
        6:
            signal_mux_384 <= execution$reg_r6;
        default:
            signal_mux_384 <= execution$reg_r7;
        endcase
    end
    assign signal_sub_6 = signal_mux_384 - signal_mux_773;
    assign signal_eq_58 = signal_select_365 == signal_const_300;
    assign signal_mux_385 = signal_eq_58 ? signal_sub_6 : signal_mux_785;
    assign signal_eq_59 = signal_select_365 == signal_const_301;
    assign signal_mux_386 = signal_eq_59 ? signal_sub_5 : signal_mux_385;
    assign signal_eq_60 = signal_select_365 == signal_const_302;
    assign signal_mux_387 = signal_eq_60 ? signal_mux_775 : signal_mux_386;
    assign signal_eq_61 = signal_select_365 == signal_const_303;
    assign signal_mux_388 = signal_eq_61 ? signal_mux_763 : signal_mux_387;
    assign signal_eq_62 = signal_mux_388 == signal_const_148;
    assign signal_mux_389 = signal_and_325 ? signal_const_37 : execution$reg_zero;
    assign signal_eq_63 = signal_select_365 == signal_const_299;
    assign signal_eq_64 = signal_select_365 == signal_const_300;
    assign signal_eq_65 = signal_select_365 == signal_const_301;
    assign signal_eq_66 = signal_select_365 == signal_const_302;
    assign signal_eq_67 = signal_select_365 == signal_const_303;
    assign signal_or_46 = signal_eq_67 | signal_eq_66;
    assign signal_or_47 = signal_or_46 | signal_eq_65;
    assign signal_or_48 = signal_or_47 | signal_eq_64;
    assign signal_or_49 = signal_or_48 | signal_eq_63;
    assign signal_and_102 = signal_and_333 & signal_or_49;
    assign signal_mux_390 = signal_and_102 ? signal_eq_62 : signal_mux_389;
    assign signal_mux_391 = signal_or_192 ? execution$reg_zero : signal_mux_390;
    assign signal_mux_392 = signal_and_328 ? execution$reg_zero : signal_mux_391;
    assign signal_mux_393 = signal_not_221 ? execution$reg_zero : signal_mux_392;
    assign signal_mux_394 = signal_wire_195 ? signal_const_37 : signal_mux_393;
    assign signal_wire_63 = signal_mux_394;
    always @(posedge signal_wire_167) begin
        execution$reg_zero <= signal_wire_63;
    end
    assign signal_select_162 = signal_mux_873[10:8];
    always @* begin
        case (signal_select_162)
        0:
            signal_mux_395 <= execution$reg_zero;
        1:
            signal_mux_395 <= signal_not_91;
        2:
            signal_mux_395 <= execution$reg_carry;
        3:
            signal_mux_395 <= signal_not_90;
        4:
            signal_mux_395 <= execution$reg_negative;
        5:
            signal_mux_395 <= signal_not_89;
        6:
            signal_mux_395 <= gnd;
        default:
            signal_mux_395 <= gnd;
        endcase
    end
    assign signal_mux_396 = signal_mux_395 ? signal_add_17 : signal_add_22;
    assign signal_select_163 = signal_mux_873[7:0];
    assign signal_select_164 = signal_select_163[7:7];
    assign signal_cat_17 = { signal_select_164,
                             signal_select_164 };
    assign signal_cat_18 = { signal_cat_17,
                             signal_cat_17 };
    assign signal_cat_19 = { signal_cat_18,
                             signal_cat_18 };
    assign signal_cat_20 = { signal_cat_19,
                             signal_select_164 };
    assign signal_cat_21 = { signal_cat_20,
                             signal_select_163 };
    assign signal_add_18 = execution$reg_pc + signal_const_167;
    assign signal_add_19 = signal_add_18 + signal_cat_21;
    assign signal_eq_68 = signal_sub_15 == signal_const_148;
    assign signal_not_92 = ~ signal_eq_68;
    assign signal_mux_397 = signal_not_92 ? signal_add_19 : signal_add_22;
    assign signal_select_165 = signal_mux_873[7:0];
    assign signal_select_166 = signal_select_165[7:7];
    assign signal_cat_22 = { signal_select_166,
                             signal_select_166 };
    assign signal_cat_23 = { signal_cat_22,
                             signal_cat_22 };
    assign signal_cat_24 = { signal_cat_23,
                             signal_cat_23 };
    assign signal_cat_25 = { signal_cat_24,
                             signal_select_166 };
    assign signal_cat_26 = { signal_cat_25,
                             signal_select_165 };
    assign signal_add_20 = execution$reg_pc + signal_const_167;
    assign signal_add_21 = signal_add_20 + signal_cat_26;
    assign signal_select_167 = signal_mux_873[10:8];
    always @* begin
        case (signal_select_167)
        0:
            signal_mux_398 <= execution$reg_r0;
        1:
            signal_mux_398 <= execution$reg_r1;
        2:
            signal_mux_398 <= execution$reg_r2;
        3:
            signal_mux_398 <= execution$reg_r3;
        4:
            signal_mux_398 <= execution$reg_r4;
        5:
            signal_mux_398 <= execution$reg_r5;
        6:
            signal_mux_398 <= execution$reg_r6;
        default:
            signal_mux_398 <= execution$reg_r7;
        endcase
    end
    assign signal_cat_27 = { gnd,
                             signal_mux_398 };
    assign signal_const_386 = 17'b00000000000000010;
    assign signal_mux_399 = signal_mux_772 ? signal_const_386 : signal_const_167;
    assign signal_add_22 = execution$reg_pc + signal_mux_399;
    assign signal_eq_69 = signal_select_365 == signal_const_294;
    assign signal_mux_400 = signal_eq_69 ? signal_cat_27 : signal_add_22;
    assign signal_eq_70 = signal_select_365 == signal_const_295;
    assign signal_mux_401 = signal_eq_70 ? signal_add_21 : signal_mux_400;
    assign signal_eq_71 = signal_select_365 == signal_const_296;
    assign signal_mux_402 = signal_eq_71 ? signal_mux_397 : signal_mux_401;
    assign signal_eq_72 = signal_select_365 == signal_const_297;
    assign signal_mux_403 = signal_eq_72 ? signal_mux_396 : signal_mux_402;
    assign signal_eq_73 = signal_select_365 == signal_const_298;
    assign signal_mux_404 = signal_eq_73 ? signal_add_15 : signal_mux_403;
    assign signal_mux_405 = signal_and_325 ? signal_const_128 : execution$reg_pc;
    assign signal_eq_74 = signal_select_365 == signal_const_116;
    assign signal_not_93 = ~ signal_eq_74;
    assign signal_and_103 = signal_and_333 & signal_not_93;
    assign signal_mux_406 = signal_and_103 ? signal_mux_404 : signal_mux_405;
    assign signal_wire_64 = gnd;
    assign signal_not_94 = ~ signal_wire_64;
    assign signal_eq_75 = execution$reg_phase == signal_const_121;
    assign signal_not_95 = ~ signal_or_192;
    assign signal_not_96 = ~ signal_and_328;
    assign signal_not_97 = ~ signal_wire_195;
    assign signal_and_104 = signal_wire_197 & signal_not_97;
    assign signal_and_105 = signal_and_104 & signal_not_96;
    assign signal_and_106 = signal_and_105 & signal_not_95;
    assign signal_and_107 = signal_and_106 & signal_eq_75;
    assign signal_and_108 = signal_and_107 & signal_wire_65;
    assign signal_or_50 = signal_or_163 | signal_and_295;
    assign signal_or_51 = signal_or_50 | signal_or_142;
    assign signal_wire_65 = signal_or_51;
    assign signal_not_98 = ~ signal_mux_747;
    assign signal_and_109 = signal_and_246 & signal_not_98;
    assign signal_not_99 = ~ signal_mux_752;
    assign signal_and_110 = signal_and_254 & signal_not_99;
    assign signal_or_52 = signal_and_110 | signal_and_109;
    assign signal_not_100 = ~ signal_not_201;
    assign signal_and_111 = signal_not_100 & signal_or_52;
    assign signal_or_53 = signal_and_253 | signal_and_111;
    assign signal_not_101 = ~ signal_wire_75;
    assign signal_not_102 = ~ signal_eq_86;
    assign signal_or_54 = signal_not_102 | signal_not_101;
    assign signal_not_103 = ~ signal_not_153;
    assign signal_not_104 = ~ signal_or_111;
    assign signal_and_112 = signal_and_179 & signal_not_104;
    assign signal_and_113 = signal_and_112 & signal_not_103;
    assign signal_and_114 = signal_and_113 & signal_or_54;
    assign signal_and_115 = signal_and_179 & signal_or_111;
    assign signal_eq_76 = signal_wire_155 == signal_const_148;
    assign signal_and_116 = signal_and_192 & signal_eq_76;
    assign signal_not_105 = ~ mechanisms$timing$reg_busy;
    assign signal_and_117 = signal_wire_197 & signal_not_105;
    assign signal_wire_66 = signal_and_117;
    assign signal_not_106 = ~ signal_wire_66;
    assign signal_eq_77 = signal_wire_156 == signal_const_148;
    assign signal_not_107 = ~ signal_eq_77;
    assign signal_not_108 = ~ signal_wire_126;
    assign signal_or_55 = signal_not_108 | signal_not_107;
    assign signal_eq_78 = signal_wire_155 == signal_const_148;
    assign signal_not_109 = ~ signal_eq_78;
    assign signal_not_110 = ~ signal_or_182;
    assign signal_or_56 = signal_not_110 | signal_not_109;
    assign signal_and_118 = signal_or_56 & signal_or_55;
    assign signal_not_111 = ~ signal_and_118;
    assign signal_or_57 = signal_not_111 | signal_not_106;
    assign signal_or_58 = signal_or_182 | signal_and_202;
    assign signal_or_59 = signal_or_58 | signal_and_200;
    assign signal_and_119 = signal_or_59 & signal_or_57;
    assign signal_or_60 = signal_and_119 | signal_and_116;
    assign signal_or_61 = signal_or_60 | signal_and_187;
    assign signal_or_62 = signal_or_61 | signal_and_115;
    assign signal_or_63 = signal_or_62 | signal_and_128;
    assign signal_or_64 = signal_or_63 | signal_and_114;
    assign signal_or_65 = signal_or_64 | signal_or_53;
    assign signal_wire_67 = signal_or_65;
    assign signal_not_112 = ~ signal_wire_67;
    assign signal_or_66 = signal_and_239 | signal_and_247;
    assign signal_eq_79 = signal_wire_155 == signal_const_148;
    assign signal_not_113 = ~ signal_eq_79;
    assign signal_and_120 = signal_and_192 & signal_not_113;
    assign signal_select_168 = signal_wire_170[0:0];
    assign signal_select_169 = mechanisms$events$reg_stage1[7:7];
    assign signal_select_170 = mechanisms$events$reg_stage1[6:6];
    assign signal_select_171 = mechanisms$events$reg_stage1[5:5];
    assign signal_select_172 = mechanisms$events$reg_stage1[4:4];
    assign signal_select_173 = mechanisms$events$reg_stage1[3:3];
    assign signal_select_174 = mechanisms$events$reg_stage1[2:2];
    assign signal_select_175 = mechanisms$events$reg_stage1[1:1];
    assign signal_select_176 = mechanisms$events$reg_stage1[0:0];
    assign signal_select_177 = signal_wire_155[2:0];
    always @* begin
        case (signal_select_177)
        0:
            signal_mux_407 <= signal_select_176;
        1:
            signal_mux_407 <= signal_select_175;
        2:
            signal_mux_407 <= signal_select_174;
        3:
            signal_mux_407 <= signal_select_173;
        4:
            signal_mux_407 <= signal_select_172;
        5:
            signal_mux_407 <= signal_select_171;
        6:
            signal_mux_407 <= signal_select_170;
        default:
            signal_mux_407 <= signal_select_169;
        endcase
    end
    assign signal_eq_80 = signal_mux_407 == signal_select_168;
    assign signal_and_121 = signal_and_202 & signal_eq_80;
    assign signal_not_114 = ~ signal_or_76;
    assign signal_not_115 = ~ signal_not_168;
    assign signal_select_178 = signal_mux_873[9:9];
    assign signal_const_406 = 15'b000000000000000;
    assign signal_cat_28 = { signal_const_406,
                             signal_select_178 };
    assign signal_select_179 = signal_mux_873[9:9];
    assign signal_cat_29 = { signal_const_406,
                             signal_select_179 };
    assign signal_select_180 = signal_mux_873[7:6];
    assign signal_const_412 = 14'b00000000000000;
    assign signal_cat_30 = { signal_const_412,
                             signal_select_180 };
    assign signal_select_181 = signal_mux_873[7:7];
    assign signal_cat_31 = { signal_const_406,
                             signal_select_181 };
    assign signal_mux_408 = mechanisms$reg_fifo_rx ? signal_mux_722 : signal_mux_732;
    assign signal_cat_32 = { signal_const_43,
                             signal_mux_408 };
    assign signal_cat_33 = { signal_const_43,
                             mechanisms$events$reg_stage1 };
    assign signal_const_419 = 6'b100000;
    assign signal_mux_409 = signal_or_116 ? signal_const_39 : signal_const_37;
    assign signal_mux_410 = signal_or_117 ? signal_const_37 : signal_mux_409;
    assign signal_wire_68 = signal_mux_410;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$bank$reg_rejected <= signal_const_37;
        else
            mechanisms$bank$reg_rejected <= signal_wire_68;
    end
    assign signal_wire_69 = signal_cat_34;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_fifo_faults <= signal_const_140;
        else
            mechanisms$reg_fifo_faults <= signal_wire_69;
    end
    assign signal_not_116 = ~ mechanisms$reg_fifo_faults;
    assign signal_not_117 = ~ signal_and_252;
    assign signal_and_122 = signal_wire_145 & signal_not_117;
    assign signal_mux_411 = signal_and_122 ? signal_const_39 : mechanisms$tx_fifo$reg_overflow;
    assign signal_mux_412 = signal_not_197 ? mechanisms$tx_fifo$reg_overflow : signal_mux_411;
    assign signal_wire_70 = signal_mux_412;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$tx_fifo$reg_overflow <= signal_const_37;
        else
            mechanisms$tx_fifo$reg_overflow <= signal_wire_70;
    end
    assign signal_not_118 = ~ signal_and_249;
    assign signal_and_123 = signal_wire_153 & signal_not_118;
    assign signal_mux_413 = signal_and_123 ? signal_const_39 : mechanisms$tx_fifo$reg_starvation;
    assign signal_mux_414 = signal_not_197 ? mechanisms$tx_fifo$reg_starvation : signal_mux_413;
    assign signal_wire_71 = signal_mux_414;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$tx_fifo$reg_starvation <= signal_const_37;
        else
            mechanisms$tx_fifo$reg_starvation <= signal_wire_71;
    end
    assign signal_not_119 = ~ signal_and_236;
    assign signal_and_124 = signal_wire_149 & signal_not_119;
    assign signal_mux_415 = signal_and_124 ? signal_const_39 : mechanisms$rx_fifo$reg_overflow;
    assign signal_mux_416 = signal_not_194 ? mechanisms$rx_fifo$reg_overflow : signal_mux_415;
    assign signal_wire_72 = signal_mux_416;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$rx_fifo$reg_overflow <= signal_const_37;
        else
            mechanisms$rx_fifo$reg_overflow <= signal_wire_72;
    end
    assign signal_not_120 = ~ signal_and_245;
    assign signal_and_125 = signal_wire_151 & signal_not_120;
    assign signal_mux_417 = signal_and_125 ? signal_const_39 : mechanisms$rx_fifo$reg_starvation;
    assign signal_mux_418 = signal_not_194 ? mechanisms$rx_fifo$reg_starvation : signal_mux_417;
    assign signal_wire_73 = signal_mux_418;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$rx_fifo$reg_starvation <= signal_const_37;
        else
            mechanisms$rx_fifo$reg_starvation <= signal_wire_73;
    end
    assign signal_cat_34 = { mechanisms$rx_fifo$reg_starvation,
                             mechanisms$rx_fifo$reg_overflow,
                             mechanisms$tx_fifo$reg_starvation,
                             mechanisms$tx_fifo$reg_overflow };
    assign signal_and_126 = signal_cat_34 & signal_not_116;
    assign signal_eq_81 = signal_and_126 == signal_const_140;
    assign signal_not_121 = ~ signal_eq_81;
    assign signal_not_122 = ~ signal_or_111;
    assign signal_and_127 = signal_and_179 & signal_not_122;
    assign signal_and_128 = signal_and_127 & signal_not_153;
    assign signal_not_123 = ~ signal_mux_427;
    assign signal_and_129 = mechanisms$bank$reg_engine_claim & signal_not_123;
    assign signal_mux_419 = signal_and_164 ? signal_and_129 : signal_mux_421;
    assign signal_or_67 = mechanisms$bank$reg_engine_claim | signal_mux_429;
    assign signal_mux_420 = signal_and_184 ? signal_or_67 : mechanisms$bank$reg_engine_claim;
    assign signal_mux_421 = signal_or_112 ? signal_mux_420 : mechanisms$bank$reg_engine_claim;
    assign signal_mux_422 = signal_or_93 ? signal_mux_419 : signal_mux_421;
    assign signal_or_68 = signal_and_143 | signal_and_145;
    assign signal_mux_423 = signal_or_68 ? mechanisms$bank$reg_software_claim : mechanisms$bank$reg_engine_claim;
    assign signal_or_69 = signal_and_143 | signal_and_145;
    assign signal_mux_424 = signal_or_69 ? mechanisms$reg_bridge_claim : signal_select_241;
    assign signal_and_130 = signal_mux_424 & signal_mux_423;
    assign signal_eq_82 = signal_and_130 == signal_const_43;
    assign signal_not_124 = ~ signal_eq_82;
    assign signal_and_131 = signal_or_71 & signal_not_124;
    assign signal_mux_425 = signal_and_164 ? mechanisms$bank$reg_engine_claim : mechanisms$bank$reg_software_claim;
    assign signal_not_125 = ~ signal_mux_425;
    assign signal_and_132 = signal_mux_427 & signal_not_125;
    assign signal_eq_83 = signal_and_132 == signal_const_43;
    assign signal_not_126 = ~ signal_eq_83;
    assign signal_and_133 = signal_or_93 & signal_not_126;
    assign signal_mux_426 = signal_and_184 ? mechanisms$bank$reg_software_claim : mechanisms$bank$reg_engine_claim;
    assign signal_and_134 = signal_mux_429 & signal_mux_426;
    assign signal_eq_84 = signal_and_134 == signal_const_43;
    assign signal_not_127 = ~ signal_eq_84;
    assign signal_and_135 = signal_or_112 & signal_not_127;
    assign signal_and_136 = signal_or_93 & signal_or_71;
    assign signal_or_70 = signal_and_143 | signal_and_145;
    assign signal_or_71 = signal_or_70 | signal_and_272;
    assign signal_or_72 = signal_or_93 | signal_or_71;
    assign signal_wire_74 = software_claim_valid_i;
    assign signal_and_137 = signal_and_146 & signal_wire_74;
    assign signal_eq_85 = signal_or_95 == signal_const_43;
    assign signal_not_128 = ~ signal_eq_85;
    assign signal_not_129 = ~ mechanisms$lane$reg_armed;
    assign signal_not_130 = ~ mechanisms$lane$reg_busy;
    assign signal_and_138 = signal_wire_197 & signal_not_130;
    assign signal_and_139 = signal_and_138 & signal_not_129;
    assign signal_wire_75 = signal_and_139;
    assign signal_eq_86 = mechanisms$reg_bridge_state == signal_const_276;
    assign signal_wire_76 = software_release_mask_i;
    assign signal_mux_427 = signal_and_164 ? mechanisms$reg_bridge_claim : signal_wire_76;
    assign signal_not_131 = ~ signal_mux_427;
    assign signal_and_140 = mechanisms$bank$reg_software_claim & signal_not_131;
    assign signal_mux_428 = signal_and_164 ? signal_mux_431 : signal_and_140;
    assign signal_wire_77 = software_claim_mask_i;
    assign signal_mux_429 = signal_and_184 ? signal_or_95 : signal_wire_77;
    assign signal_or_73 = mechanisms$bank$reg_software_claim | signal_mux_429;
    assign signal_mux_430 = signal_and_184 ? mechanisms$bank$reg_software_claim : signal_or_73;
    assign signal_mux_431 = signal_or_112 ? signal_mux_430 : mechanisms$bank$reg_software_claim;
    assign signal_wire_78 = software_release_valid_i;
    assign signal_not_132 = ~ signal_and_272;
    assign signal_eq_87 = mechanisms$reg_bridge_claim == signal_const_43;
    assign signal_not_133 = ~ signal_eq_87;
    assign signal_not_134 = ~ signal_or_92;
    assign signal_and_141 = signal_eq_126 & mechanisms$lane$reg_busy;
    assign signal_and_142 = signal_and_141 & signal_not_134;
    assign signal_and_143 = signal_and_142 & signal_not_133;
    assign signal_eq_88 = mechanisms$reg_bridge_claim == signal_const_43;
    assign signal_not_135 = ~ signal_eq_88;
    assign signal_and_144 = signal_eq_126 & signal_or_92;
    assign signal_and_145 = signal_and_144 & signal_not_135;
    assign signal_or_74 = signal_and_184 | signal_and_145;
    assign signal_or_75 = signal_or_74 | signal_and_143;
    assign signal_or_76 = signal_or_75 | signal_and_164;
    assign signal_not_136 = ~ signal_or_76;
    assign signal_and_146 = signal_not_136 & signal_not_132;
    assign signal_and_147 = signal_and_146 & signal_wire_78;
    assign signal_eq_89 = mechanisms$reg_bridge_claim == signal_const_43;
    assign signal_not_137 = ~ signal_eq_89;
    assign signal_const_448 = 2'b10;
    assign signal_mux_432 = signal_and_183 ? signal_or_95 : mechanisms$reg_bridge_claim;
    assign signal_mux_433 = signal_eq_127 ? signal_const_43 : signal_mux_432;
    assign signal_mux_434 = signal_or_187 ? signal_const_43 : signal_mux_433;
    assign signal_wire_79 = signal_mux_434;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_bridge_claim <= signal_const_43;
        else
            mechanisms$reg_bridge_claim <= signal_wire_79;
    end
    assign signal_eq_90 = mechanisms$reg_bridge_claim == signal_const_43;
    assign signal_mux_435 = signal_eq_90 ? signal_const_276 : signal_const_448;
    assign signal_const_458 = 2'b01;
    assign signal_mux_436 = signal_and_183 ? signal_const_458 : mechanisms$reg_bridge_state;
    assign signal_mux_437 = signal_and_148 ? signal_const_39 : signal_const_37;
    assign signal_mux_438 = signal_and_149 ? signal_mux_437 : signal_const_37;
    assign signal_mux_439 = signal_and_160 ? signal_mux_438 : signal_const_37;
    assign signal_mux_440 = mechanisms$lane$reg_busy ? signal_mux_439 : signal_const_37;
    assign signal_mux_441 = signal_and_162 ? signal_const_37 : signal_mux_440;
    assign signal_mux_442 = signal_or_91 ? signal_const_37 : signal_mux_441;
    assign signal_wire_80 = signal_mux_442;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_overrun <= signal_const_37;
        else
            mechanisms$lane$reg_overrun <= signal_wire_80;
    end
    assign signal_mux_443 = signal_or_90 ? signal_const_37 : signal_const_37;
    assign signal_mux_444 = signal_and_162 ? signal_mux_443 : signal_const_37;
    assign signal_mux_445 = signal_or_91 ? signal_const_37 : signal_mux_444;
    assign signal_wire_81 = signal_mux_445;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_underrun <= signal_const_37;
        else
            mechanisms$lane$reg_underrun <= signal_wire_81;
    end
    assign signal_mux_446 = signal_or_90 ? signal_const_39 : signal_const_37;
    assign signal_mux_447 = signal_and_162 ? signal_mux_446 : signal_const_37;
    assign signal_mux_448 = signal_or_91 ? signal_const_37 : signal_mux_447;
    assign signal_wire_82 = signal_mux_448;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_rejected <= signal_const_37;
        else
            mechanisms$lane$reg_rejected <= signal_wire_82;
    end
    assign signal_or_77 = mechanisms$lane$reg_rejected | mechanisms$lane$reg_underrun;
    assign signal_or_78 = signal_or_77 | mechanisms$lane$reg_overrun;
    assign signal_wire_83 = transfer_rx_ready_i;
    assign signal_not_138 = ~ signal_wire_83;
    assign signal_mux_449 = signal_or_90 ? mechanisms$lane$reg_rx_enable : signal_not_147;
    assign signal_mux_450 = signal_and_162 ? signal_mux_449 : mechanisms$lane$reg_rx_enable;
    assign signal_mux_451 = signal_or_91 ? mechanisms$lane$reg_rx_enable : signal_mux_450;
    assign signal_wire_84 = signal_mux_451;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_rx_enable <= signal_const_37;
        else
            mechanisms$lane$reg_rx_enable <= signal_wire_84;
    end
    assign signal_and_148 = mechanisms$lane$reg_rx_enable & signal_not_138;
    assign signal_mux_452 = signal_and_148 ? signal_const_37 : signal_const_39;
    assign signal_mux_453 = signal_and_149 ? signal_mux_452 : signal_const_37;
    assign signal_mux_454 = signal_and_160 ? signal_mux_453 : signal_const_37;
    assign signal_mux_455 = mechanisms$lane$reg_busy ? signal_mux_454 : signal_const_37;
    assign signal_mux_456 = signal_or_90 ? mechanisms$lane$reg_armed : gnd;
    assign signal_mux_457 = signal_and_162 ? signal_mux_456 : mechanisms$lane$reg_armed;
    assign signal_mux_458 = signal_or_91 ? signal_const_37 : signal_mux_457;
    assign signal_wire_85 = signal_mux_458;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_armed <= signal_const_37;
        else
            mechanisms$lane$reg_armed <= signal_wire_85;
    end
    assign signal_not_139 = ~ mechanisms$lane$reg_armed;
    assign signal_mux_459 = signal_or_90 ? mechanisms$lane$reg_busy : signal_const_39;
    assign signal_mux_460 = signal_or_90 ? mechanisms$lane$reg_bit_count : signal_select_206;
    assign signal_mux_461 = signal_and_162 ? signal_mux_460 : mechanisms$lane$reg_bit_count;
    assign signal_mux_462 = signal_or_91 ? mechanisms$lane$reg_bit_count : signal_mux_461;
    assign signal_wire_86 = signal_mux_462;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_bit_count <= signal_const_58;
        else
            mechanisms$lane$reg_bit_count <= signal_wire_86;
    end
    assign signal_sub_7 = mechanisms$lane$reg_bit_count - signal_const_59;
    assign signal_mux_463 = signal_or_90 ? mechanisms$lane$reg_bit_index : signal_const_58;
    assign signal_add_23 = mechanisms$lane$reg_bit_index + signal_const_59;
    assign signal_mux_464 = mechanisms$lane$reg_trailing ? signal_add_23 : mechanisms$lane$reg_bit_index;
    assign signal_mux_465 = signal_and_149 ? mechanisms$lane$reg_bit_index : signal_mux_464;
    assign signal_mux_466 = signal_and_160 ? signal_mux_465 : mechanisms$lane$reg_bit_index;
    assign signal_mux_467 = mechanisms$lane$reg_busy ? signal_mux_466 : mechanisms$lane$reg_bit_index;
    assign signal_mux_468 = signal_and_162 ? signal_mux_463 : signal_mux_467;
    assign signal_mux_469 = signal_or_91 ? mechanisms$lane$reg_bit_index : signal_mux_468;
    assign signal_wire_87 = signal_mux_469;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_bit_index <= signal_const_58;
        else
            mechanisms$lane$reg_bit_index <= signal_wire_87;
    end
    assign signal_eq_91 = mechanisms$lane$reg_bit_index == signal_sub_7;
    assign signal_mux_470 = signal_or_90 ? mechanisms$lane$reg_trailing : signal_const_37;
    assign signal_mux_471 = mechanisms$lane$reg_trailing ? signal_const_37 : signal_const_39;
    assign signal_mux_472 = signal_and_149 ? mechanisms$lane$reg_trailing : signal_mux_471;
    assign signal_mux_473 = signal_and_160 ? signal_mux_472 : mechanisms$lane$reg_trailing;
    assign signal_mux_474 = mechanisms$lane$reg_busy ? signal_mux_473 : mechanisms$lane$reg_trailing;
    assign signal_mux_475 = signal_and_162 ? signal_mux_470 : signal_mux_474;
    assign signal_mux_476 = signal_or_91 ? mechanisms$lane$reg_trailing : signal_mux_475;
    assign signal_wire_88 = signal_mux_476;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_trailing <= signal_const_37;
        else
            mechanisms$lane$reg_trailing <= signal_wire_88;
    end
    assign signal_and_149 = mechanisms$lane$reg_trailing & signal_eq_91;
    assign signal_mux_477 = signal_and_149 ? signal_const_37 : mechanisms$lane$reg_busy;
    assign signal_select_182 = signal_mux_504[7:7];
    assign signal_select_183 = signal_mux_504[6:6];
    assign signal_select_184 = signal_mux_504[5:5];
    assign signal_select_185 = signal_mux_504[4:4];
    assign signal_select_186 = signal_mux_504[3:3];
    assign signal_select_187 = signal_mux_504[2:2];
    assign signal_select_188 = signal_mux_504[1:1];
    assign signal_or_79 = signal_and_198 | signal_and_197;
    assign signal_const_514 = 16'b0000000000000001;
    assign signal_eq_92 = signal_select_215 == signal_const_514;
    assign signal_mux_478 = signal_eq_92 ? signal_const_276 : signal_const_276;
    assign signal_const_515 = 16'b0000000000000010;
    assign signal_eq_93 = signal_select_215 == signal_const_515;
    assign signal_mux_479 = signal_eq_93 ? signal_const_458 : signal_mux_478;
    assign signal_const_516 = 16'b0000000000000011;
    assign signal_eq_94 = signal_select_215 == signal_const_516;
    assign signal_mux_480 = signal_eq_94 ? signal_const_448 : signal_mux_479;
    assign signal_const_517 = 16'b0000000000000100;
    assign signal_eq_95 = signal_select_215 == signal_const_517;
    assign signal_mux_481 = signal_eq_95 ? signal_const_276 : signal_mux_480;
    assign signal_const_518 = 16'b0000000000000101;
    assign signal_eq_96 = signal_select_215 == signal_const_518;
    assign signal_mux_482 = signal_eq_96 ? signal_const_458 : signal_mux_481;
    assign signal_const_519 = 16'b0000000000000110;
    assign signal_eq_97 = signal_select_215 == signal_const_519;
    assign signal_mux_483 = signal_eq_97 ? signal_const_448 : signal_mux_482;
    assign signal_const_520 = 16'b0000000000000111;
    assign signal_eq_98 = signal_select_215 == signal_const_520;
    assign signal_mux_484 = signal_eq_98 ? signal_const_276 : signal_mux_483;
    assign signal_const_521 = 16'b0000000000001000;
    assign signal_eq_99 = signal_select_215 == signal_const_521;
    assign signal_mux_485 = signal_eq_99 ? signal_const_458 : signal_mux_484;
    assign signal_const_522 = 16'b0000000000001001;
    assign signal_eq_100 = signal_select_215 == signal_const_522;
    assign signal_mux_486 = signal_eq_100 ? signal_const_448 : signal_mux_485;
    assign signal_const_523 = 16'b0000000000001010;
    assign signal_eq_101 = signal_select_215 == signal_const_523;
    assign signal_mux_487 = signal_eq_101 ? signal_const_276 : signal_mux_486;
    assign signal_const_524 = 16'b0000000000001011;
    assign signal_eq_102 = signal_select_215 == signal_const_524;
    assign signal_mux_488 = signal_eq_102 ? signal_const_458 : signal_mux_487;
    assign signal_const_525 = 16'b0000000000001100;
    assign signal_eq_103 = signal_select_215 == signal_const_525;
    assign signal_mux_489 = signal_eq_103 ? signal_const_448 : signal_mux_488;
    assign signal_const_526 = 16'b0000000000001101;
    assign signal_eq_104 = signal_select_215 == signal_const_526;
    assign signal_mux_490 = signal_eq_104 ? signal_const_276 : signal_mux_489;
    assign signal_const_527 = 16'b0000000000001110;
    assign signal_eq_105 = signal_select_215 == signal_const_527;
    assign signal_mux_491 = signal_eq_105 ? signal_const_458 : signal_mux_490;
    assign signal_const_528 = 16'b0000000000001111;
    assign signal_eq_106 = signal_select_215 == signal_const_528;
    assign signal_mux_492 = signal_eq_106 ? signal_const_448 : signal_mux_491;
    assign signal_const_529 = 16'b0000000000010000;
    assign signal_eq_107 = signal_select_215 == signal_const_529;
    assign signal_mux_493 = signal_eq_107 ? signal_const_276 : signal_mux_492;
    assign signal_const_530 = 16'b0000000000010001;
    assign signal_eq_108 = signal_select_215 == signal_const_530;
    assign signal_mux_494 = signal_eq_108 ? signal_const_458 : signal_mux_493;
    assign signal_const_531 = 16'b0000000000010010;
    assign signal_eq_109 = signal_select_215 == signal_const_531;
    assign signal_mux_495 = signal_eq_109 ? signal_const_448 : signal_mux_494;
    assign signal_const_532 = 16'b0000000000010011;
    assign signal_eq_110 = signal_select_215 == signal_const_532;
    assign signal_mux_496 = signal_eq_110 ? signal_const_276 : signal_mux_495;
    assign signal_const_533 = 16'b0000000000010100;
    assign signal_eq_111 = signal_select_215 == signal_const_533;
    assign signal_mux_497 = signal_eq_111 ? signal_const_458 : signal_mux_496;
    assign signal_const_534 = 16'b0000000000010101;
    assign signal_eq_112 = signal_select_215 == signal_const_534;
    assign signal_mux_498 = signal_eq_112 ? signal_const_448 : signal_mux_497;
    assign signal_const_535 = 16'b0000000000010110;
    assign signal_eq_113 = signal_select_215 == signal_const_535;
    assign signal_mux_499 = signal_eq_113 ? signal_const_276 : signal_mux_498;
    assign signal_const_536 = 16'b0000000000010111;
    assign signal_eq_114 = signal_select_215 == signal_const_536;
    assign signal_mux_500 = signal_eq_114 ? signal_const_458 : signal_mux_499;
    assign signal_const_537 = 16'b0000000000011000;
    assign signal_eq_115 = signal_select_215 == signal_const_537;
    assign signal_mux_501 = signal_eq_115 ? signal_const_448 : signal_mux_500;
    assign signal_wire_89 = signal_mux_501;
    assign signal_mux_502 = signal_and_183 ? signal_wire_89 : mechanisms$reg_bridge_pacing_edge;
    assign signal_mux_503 = signal_or_187 ? signal_const_276 : signal_mux_502;
    assign signal_wire_90 = signal_mux_503;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_bridge_pacing_edge <= signal_const_276;
        else
            mechanisms$reg_bridge_pacing_edge <= signal_wire_90;
    end
    always @* begin
        case (mechanisms$reg_bridge_pacing_edge)
        0:
            signal_mux_504 <= signal_and_198;
        1:
            signal_mux_504 <= signal_and_197;
        2:
            signal_mux_504 <= signal_or_79;
        default:
            signal_mux_504 <= signal_const_43;
        endcase
    end
    assign signal_select_189 = signal_mux_504[0:0];
    assign signal_mux_505 = signal_and_183 ? signal_wire_101 : mechanisms$reg_bridge_pacing_pin;
    assign signal_mux_506 = signal_or_187 ? signal_const_4 : signal_mux_505;
    assign signal_wire_91 = signal_mux_506;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_bridge_pacing_pin <= signal_const_4;
        else
            mechanisms$reg_bridge_pacing_pin <= signal_wire_91;
    end
    always @* begin
        case (mechanisms$reg_bridge_pacing_pin)
        0:
            signal_mux_507 <= signal_select_189;
        1:
            signal_mux_507 <= signal_select_188;
        2:
            signal_mux_507 <= signal_select_187;
        3:
            signal_mux_507 <= signal_select_186;
        4:
            signal_mux_507 <= signal_select_185;
        5:
            signal_mux_507 <= signal_select_184;
        6:
            signal_mux_507 <= signal_select_183;
        default:
            signal_mux_507 <= signal_select_182;
        endcase
    end
    assign signal_select_190 = signal_wire_111[111:96];
    assign signal_eq_116 = signal_select_190 == signal_const_148;
    assign signal_mux_508 = signal_eq_116 ? signal_select_209 : signal_select_190;
    assign signal_mux_509 = signal_or_90 ? mechanisms$lane$reg_remaining : signal_mux_508;
    assign signal_mux_510 = signal_or_90 ? mechanisms$lane$reg_half_period : signal_select_209;
    assign signal_mux_511 = signal_and_162 ? signal_mux_510 : mechanisms$lane$reg_half_period;
    assign signal_mux_512 = signal_or_91 ? mechanisms$lane$reg_half_period : signal_mux_511;
    assign signal_wire_92 = signal_mux_512;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_half_period <= signal_const_148;
        else
            mechanisms$lane$reg_half_period <= signal_wire_92;
    end
    assign signal_not_140 = ~ mechanisms$lane$reg_observed;
    assign signal_mux_513 = signal_not_140 ? mechanisms$lane$reg_half_period : signal_mux_514;
    assign signal_sub_8 = mechanisms$lane$reg_remaining - signal_const_514;
    assign signal_not_141 = ~ signal_and_160;
    assign signal_not_142 = ~ mechanisms$lane$reg_observed;
    assign signal_and_150 = signal_not_142 & signal_not_141;
    assign signal_mux_514 = signal_and_150 ? signal_sub_8 : mechanisms$lane$reg_remaining;
    assign signal_mux_515 = signal_and_160 ? signal_mux_513 : signal_mux_514;
    assign signal_mux_516 = mechanisms$lane$reg_busy ? signal_mux_515 : mechanisms$lane$reg_remaining;
    assign signal_mux_517 = signal_and_162 ? signal_mux_509 : signal_mux_516;
    assign signal_mux_518 = signal_or_91 ? signal_const_148 : signal_mux_517;
    assign signal_wire_93 = signal_mux_518;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_remaining <= signal_const_148;
        else
            mechanisms$lane$reg_remaining <= signal_wire_93;
    end
    assign signal_eq_117 = mechanisms$lane$reg_remaining == signal_const_514;
    assign signal_wire_94 = occupied_i;
    assign signal_or_80 = signal_wire_94 | signal_wire_100;
    always @* begin
        case (signal_select_193)
        0:
            signal_mux_519 <= signal_const_75;
        1:
            signal_mux_519 <= signal_const_74;
        2:
            signal_mux_519 <= signal_const_73;
        3:
            signal_mux_519 <= signal_const_72;
        4:
            signal_mux_519 <= signal_const_71;
        5:
            signal_mux_519 <= signal_const_70;
        6:
            signal_mux_519 <= signal_const_69;
        default:
            signal_mux_519 <= signal_const_68;
        endcase
    end
    assign signal_mux_520 = signal_and_157 ? signal_mux_519 : signal_const_43;
    always @* begin
        case (signal_select_194)
        0:
            signal_mux_521 <= signal_const_75;
        1:
            signal_mux_521 <= signal_const_74;
        2:
            signal_mux_521 <= signal_const_73;
        3:
            signal_mux_521 <= signal_const_72;
        4:
            signal_mux_521 <= signal_const_71;
        5:
            signal_mux_521 <= signal_const_70;
        6:
            signal_mux_521 <= signal_const_69;
        default:
            signal_mux_521 <= signal_const_68;
        endcase
    end
    assign signal_mux_522 = signal_not_152 ? signal_mux_521 : signal_const_43;
    assign signal_or_81 = signal_mux_522 | signal_mux_520;
    assign signal_and_151 = signal_or_81 & signal_or_80;
    assign signal_eq_118 = signal_and_151 == signal_const_43;
    assign signal_not_143 = ~ signal_eq_118;
    assign signal_not_144 = ~ signal_not_147;
    assign signal_not_145 = ~ signal_not_152;
    assign signal_and_152 = signal_not_145 & signal_not_144;
    assign signal_xor_1 = signal_select_210 ^ signal_select_191;
    assign signal_select_191 = signal_select_219[4:4];
    assign signal_xor_2 = signal_select_211 ^ signal_select_191;
    assign signal_eq_119 = signal_xor_2 == signal_xor_1;
    assign signal_eq_120 = signal_select_209 == signal_const_148;
    assign signal_not_146 = ~ signal_not_158;
    assign signal_and_153 = signal_not_146 & signal_eq_120;
    assign signal_and_154 = signal_not_158 & signal_and_157;
    assign signal_select_192 = signal_select_217[2:0];
    assign signal_eq_121 = signal_select_192 == signal_select_193;
    assign signal_eq_122 = signal_select_220 == signal_const_276;
    assign signal_not_147 = ~ signal_eq_122;
    assign signal_and_155 = signal_not_147 & signal_and_157;
    assign signal_and_156 = signal_and_155 & signal_eq_121;
    assign signal_select_193 = signal_select_216[2:0];
    assign signal_select_194 = signal_select_218[2:0];
    assign signal_eq_123 = signal_select_194 == signal_select_193;
    assign signal_not_148 = ~ signal_not_158;
    assign signal_and_157 = signal_lt_19 & signal_not_148;
    assign signal_and_158 = signal_not_152 & signal_and_157;
    assign signal_and_159 = signal_and_158 & signal_eq_123;
    assign signal_select_195 = signal_mux_526[31:16];
    assign signal_cat_35 = { signal_const_148,
                             signal_select_195 };
    assign signal_select_196 = signal_mux_525[31:8];
    assign signal_cat_36 = { signal_const_43,
                             signal_select_196 };
    assign signal_select_197 = signal_mux_524[31:4];
    assign signal_cat_37 = { signal_const_140,
                             signal_select_197 };
    assign signal_select_198 = signal_mux_523[31:2];
    assign signal_cat_38 = { signal_const_276,
                             signal_select_198 };
    assign signal_select_199 = signal_cat_40[31:1];
    assign signal_cat_39 = { signal_const_37,
                             signal_select_199 };
    assign signal_cat_40 = { signal_const_148,
                             signal_select_225 };
    assign signal_select_200 = signal_select_206[0:0];
    assign signal_mux_523 = signal_select_200 ? signal_cat_39 : signal_cat_40;
    assign signal_select_201 = signal_select_206[1:1];
    assign signal_mux_524 = signal_select_201 ? signal_cat_38 : signal_mux_523;
    assign signal_select_202 = signal_select_206[2:2];
    assign signal_mux_525 = signal_select_202 ? signal_cat_37 : signal_mux_524;
    assign signal_select_203 = signal_select_206[3:3];
    assign signal_mux_526 = signal_select_203 ? signal_cat_36 : signal_mux_525;
    assign signal_select_204 = signal_select_206[4:4];
    assign signal_mux_527 = signal_select_204 ? signal_cat_35 : signal_mux_526;
    assign signal_select_205 = signal_select_206[5:5];
    assign signal_mux_528 = signal_select_205 ? signal_const : signal_mux_527;
    assign signal_eq_124 = signal_mux_528 == signal_const;
    assign signal_not_149 = ~ signal_eq_124;
    assign signal_lt_17 = signal_const_419 < signal_select_206;
    assign signal_select_206 = signal_select_240[5:0];
    assign signal_eq_125 = signal_select_206 == signal_const_58;
    assign signal_or_82 = signal_eq_125 | signal_lt_17;
    assign signal_or_83 = signal_or_82 | signal_not_149;
    assign signal_or_84 = signal_or_83 | signal_and_159;
    assign signal_or_85 = signal_or_84 | signal_and_156;
    assign signal_or_86 = signal_or_85 | signal_and_154;
    assign signal_or_87 = signal_or_86 | signal_and_153;
    assign signal_or_88 = signal_or_87 | signal_eq_119;
    assign signal_or_89 = signal_or_88 | signal_and_152;
    assign signal_or_90 = signal_or_89 | signal_not_143;
    assign signal_mux_529 = signal_or_90 ? mechanisms$lane$reg_observed : signal_not_158;
    assign signal_mux_530 = signal_and_162 ? signal_mux_529 : mechanisms$lane$reg_observed;
    assign signal_mux_531 = signal_or_91 ? mechanisms$lane$reg_observed : signal_mux_530;
    assign signal_wire_95 = signal_mux_531;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_observed <= signal_const_37;
        else
            mechanisms$lane$reg_observed <= signal_wire_95;
    end
    assign signal_mux_532 = mechanisms$lane$reg_observed ? signal_mux_507 : signal_eq_117;
    assign signal_and_160 = mechanisms$lane$reg_busy & signal_mux_532;
    assign signal_mux_533 = signal_and_160 ? signal_mux_477 : mechanisms$lane$reg_busy;
    assign signal_mux_534 = mechanisms$lane$reg_busy ? signal_mux_533 : mechanisms$lane$reg_busy;
    assign signal_mux_535 = signal_and_162 ? signal_mux_459 : signal_mux_534;
    assign signal_mux_536 = signal_or_91 ? signal_const_37 : signal_mux_535;
    assign signal_wire_96 = signal_mux_536;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_busy <= signal_const_37;
        else
            mechanisms$lane$reg_busy <= signal_wire_96;
    end
    assign signal_not_150 = ~ mechanisms$lane$reg_busy;
    assign signal_and_161 = signal_and_183 & signal_not_150;
    assign signal_and_162 = signal_and_161 & signal_not_139;
    assign signal_mux_537 = signal_and_162 ? signal_const_37 : signal_mux_455;
    assign signal_not_151 = ~ signal_wire_197;
    assign signal_or_91 = signal_not_151 | signal_and_328;
    assign signal_mux_538 = signal_or_91 ? signal_const_37 : signal_mux_537;
    assign signal_wire_97 = signal_mux_538;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$lane$reg_done_ <= signal_const_37;
        else
            mechanisms$lane$reg_done_ <= signal_wire_97;
    end
    assign signal_or_92 = mechanisms$lane$reg_done_ | signal_or_78;
    assign signal_eq_126 = mechanisms$reg_bridge_state == signal_const_458;
    assign signal_and_163 = signal_eq_126 & signal_or_92;
    assign signal_mux_539 = signal_and_163 ? signal_mux_435 : signal_mux_436;
    assign signal_mux_540 = signal_eq_127 ? signal_const_276 : signal_mux_539;
    assign signal_mux_541 = signal_or_187 ? signal_const_276 : signal_mux_540;
    assign signal_wire_98 = signal_mux_541;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_bridge_state <= signal_const_276;
        else
            mechanisms$reg_bridge_state <= signal_wire_98;
    end
    assign signal_eq_127 = mechanisms$reg_bridge_state == signal_const_448;
    assign signal_and_164 = signal_eq_127 & signal_not_137;
    assign signal_or_93 = signal_and_164 | signal_and_147;
    assign signal_mux_542 = signal_or_93 ? signal_mux_428 : signal_mux_431;
    assign signal_mux_543 = signal_or_116 ? mechanisms$bank$reg_software_claim : signal_mux_542;
    assign signal_mux_544 = signal_or_117 ? signal_const_43 : signal_mux_543;
    assign signal_wire_99 = signal_mux_544;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$bank$reg_software_claim <= signal_const_43;
        else
            mechanisms$bank$reg_software_claim <= signal_wire_99;
    end
    assign signal_wire_100 = mechanisms$bank$reg_software_claim;
    assign signal_or_94 = signal_wire_100 | signal_wire_94;
    assign signal_select_207 = signal_select_216[2:0];
    always @* begin
        case (signal_select_207)
        0:
            signal_mux_545 <= signal_const_75;
        1:
            signal_mux_545 <= signal_const_74;
        2:
            signal_mux_545 <= signal_const_73;
        3:
            signal_mux_545 <= signal_const_72;
        4:
            signal_mux_545 <= signal_const_71;
        5:
            signal_mux_545 <= signal_const_70;
        6:
            signal_mux_545 <= signal_const_69;
        default:
            signal_mux_545 <= signal_const_68;
        endcase
    end
    assign signal_mux_546 = signal_lt_19 ? signal_mux_545 : signal_const_43;
    assign signal_select_208 = signal_select_218[2:0];
    always @* begin
        case (signal_select_208)
        0:
            signal_mux_547 <= signal_const_75;
        1:
            signal_mux_547 <= signal_const_74;
        2:
            signal_mux_547 <= signal_const_73;
        3:
            signal_mux_547 <= signal_const_72;
        4:
            signal_mux_547 <= signal_const_71;
        5:
            signal_mux_547 <= signal_const_70;
        6:
            signal_mux_547 <= signal_const_69;
        default:
            signal_mux_547 <= signal_const_68;
        endcase
    end
    assign signal_eq_128 = signal_select_220 == signal_const_458;
    assign signal_not_152 = ~ signal_eq_128;
    assign signal_and_165 = signal_not_152 & signal_lt_21;
    assign signal_mux_548 = signal_and_165 ? signal_mux_547 : signal_const_43;
    assign signal_or_95 = signal_mux_548 | signal_mux_546;
    assign signal_and_166 = signal_or_95 & signal_or_94;
    assign signal_eq_129 = signal_and_166 == signal_const_43;
    assign signal_not_153 = ~ signal_eq_129;
    assign signal_not_154 = ~ signal_not_153;
    assign signal_select_209 = signal_wire_111[127:112];
    assign signal_eq_130 = signal_select_209 == signal_const_148;
    assign signal_not_155 = ~ signal_not_158;
    assign signal_and_167 = signal_not_155 & signal_eq_130;
    assign signal_and_168 = signal_not_158 & signal_lt_19;
    assign signal_lt_18 = signal_const_537 < signal_select_215;
    assign signal_not_156 = ~ signal_lt_18;
    assign signal_not_157 = ~ signal_not_156;
    assign signal_select_210 = signal_select_219[6:6];
    assign signal_select_211 = signal_select_219[5:5];
    assign signal_eq_131 = signal_select_211 == signal_select_210;
    assign signal_select_212 = signal_select_216[2:0];
    assign signal_eq_132 = signal_select_212 == signal_wire_101;
    assign signal_and_169 = signal_lt_19 & signal_eq_132;
    assign signal_select_213 = signal_select_217[2:0];
    assign signal_eq_133 = signal_select_213 == signal_wire_101;
    assign signal_and_170 = signal_lt_20 & signal_eq_133;
    assign signal_const_600 = 3'b111;
    assign signal_eq_134 = signal_select_215 == signal_const_514;
    assign signal_mux_549 = signal_eq_134 ? signal_const_4 : signal_const_4;
    assign signal_eq_135 = signal_select_215 == signal_const_515;
    assign signal_mux_550 = signal_eq_135 ? signal_const_4 : signal_mux_549;
    assign signal_eq_136 = signal_select_215 == signal_const_516;
    assign signal_mux_551 = signal_eq_136 ? signal_const_4 : signal_mux_550;
    assign signal_eq_137 = signal_select_215 == signal_const_517;
    assign signal_mux_552 = signal_eq_137 ? signal_const_117 : signal_mux_551;
    assign signal_eq_138 = signal_select_215 == signal_const_518;
    assign signal_mux_553 = signal_eq_138 ? signal_const_117 : signal_mux_552;
    assign signal_eq_139 = signal_select_215 == signal_const_519;
    assign signal_mux_554 = signal_eq_139 ? signal_const_117 : signal_mux_553;
    assign signal_eq_140 = signal_select_215 == signal_const_520;
    assign signal_mux_555 = signal_eq_140 ? signal_const_118 : signal_mux_554;
    assign signal_eq_141 = signal_select_215 == signal_const_521;
    assign signal_mux_556 = signal_eq_141 ? signal_const_118 : signal_mux_555;
    assign signal_eq_142 = signal_select_215 == signal_const_522;
    assign signal_mux_557 = signal_eq_142 ? signal_const_118 : signal_mux_556;
    assign signal_eq_143 = signal_select_215 == signal_const_523;
    assign signal_mux_558 = signal_eq_143 ? signal_const_119 : signal_mux_557;
    assign signal_eq_144 = signal_select_215 == signal_const_524;
    assign signal_mux_559 = signal_eq_144 ? signal_const_119 : signal_mux_558;
    assign signal_eq_145 = signal_select_215 == signal_const_525;
    assign signal_mux_560 = signal_eq_145 ? signal_const_119 : signal_mux_559;
    assign signal_eq_146 = signal_select_215 == signal_const_526;
    assign signal_mux_561 = signal_eq_146 ? signal_const_120 : signal_mux_560;
    assign signal_eq_147 = signal_select_215 == signal_const_527;
    assign signal_mux_562 = signal_eq_147 ? signal_const_120 : signal_mux_561;
    assign signal_eq_148 = signal_select_215 == signal_const_528;
    assign signal_mux_563 = signal_eq_148 ? signal_const_120 : signal_mux_562;
    assign signal_eq_149 = signal_select_215 == signal_const_529;
    assign signal_mux_564 = signal_eq_149 ? signal_const_121 : signal_mux_563;
    assign signal_eq_150 = signal_select_215 == signal_const_530;
    assign signal_mux_565 = signal_eq_150 ? signal_const_121 : signal_mux_564;
    assign signal_eq_151 = signal_select_215 == signal_const_531;
    assign signal_mux_566 = signal_eq_151 ? signal_const_121 : signal_mux_565;
    assign signal_eq_152 = signal_select_215 == signal_const_532;
    assign signal_mux_567 = signal_eq_152 ? signal_const_174 : signal_mux_566;
    assign signal_eq_153 = signal_select_215 == signal_const_533;
    assign signal_mux_568 = signal_eq_153 ? signal_const_174 : signal_mux_567;
    assign signal_eq_154 = signal_select_215 == signal_const_534;
    assign signal_mux_569 = signal_eq_154 ? signal_const_174 : signal_mux_568;
    assign signal_eq_155 = signal_select_215 == signal_const_535;
    assign signal_mux_570 = signal_eq_155 ? signal_const_600 : signal_mux_569;
    assign signal_eq_156 = signal_select_215 == signal_const_536;
    assign signal_mux_571 = signal_eq_156 ? signal_const_600 : signal_mux_570;
    assign signal_eq_157 = signal_select_215 == signal_const_537;
    assign signal_mux_572 = signal_eq_157 ? signal_const_600 : signal_mux_571;
    assign signal_wire_101 = signal_mux_572;
    assign signal_select_214 = signal_select_218[2:0];
    assign signal_eq_158 = signal_select_214 == signal_wire_101;
    assign signal_and_171 = signal_lt_21 & signal_eq_158;
    assign signal_or_96 = signal_and_171 | signal_and_170;
    assign signal_or_97 = signal_or_96 | signal_and_169;
    assign signal_select_215 = signal_wire_111[143:128];
    assign signal_eq_159 = signal_select_215 == signal_const_148;
    assign signal_not_158 = ~ signal_eq_159;
    assign signal_and_172 = signal_not_158 & signal_or_97;
    assign signal_eq_160 = signal_select_217 == signal_select_216;
    assign signal_and_173 = signal_lt_20 & signal_lt_19;
    assign signal_and_174 = signal_and_173 & signal_eq_160;
    assign signal_eq_161 = signal_select_218 == signal_select_216;
    assign signal_select_216 = signal_wire_111[95:80];
    assign signal_lt_19 = signal_select_216 < signal_const_521;
    assign signal_and_175 = signal_lt_21 & signal_lt_19;
    assign signal_and_176 = signal_and_175 & signal_eq_161;
    assign signal_or_98 = signal_and_176 | signal_and_174;
    assign signal_or_99 = signal_or_98 | signal_and_172;
    assign signal_not_159 = ~ signal_lt_20;
    assign signal_not_160 = ~ signal_lt_21;
    assign signal_or_100 = signal_not_160 | signal_not_159;
    assign signal_not_161 = ~ signal_lt_20;
    assign signal_not_162 = ~ signal_lt_21;
    assign signal_or_101 = signal_not_162 | signal_not_161;
    assign signal_not_163 = ~ signal_lt_20;
    assign signal_or_102 = signal_not_163 | signal_lt_21;
    assign signal_select_217 = signal_wire_111[79:64];
    assign signal_lt_20 = signal_select_217 < signal_const_521;
    assign signal_select_218 = signal_wire_111[63:48];
    assign signal_lt_21 = signal_select_218 < signal_const_521;
    assign signal_not_164 = ~ signal_lt_21;
    assign signal_or_103 = signal_not_164 | signal_lt_20;
    assign signal_select_219 = signal_wire_111[15:0];
    assign signal_select_220 = signal_select_219[1:0];
    always @* begin
        case (signal_select_220)
        0:
            signal_mux_573 <= signal_or_103;
        1:
            signal_mux_573 <= signal_or_102;
        2:
            signal_mux_573 <= signal_or_101;
        default:
            signal_mux_573 <= signal_or_100;
        endcase
    end
    assign signal_select_221 = signal_mux_576[15:8];
    assign signal_cat_41 = { signal_const_43,
                             signal_select_221 };
    assign signal_select_222 = signal_mux_575[15:4];
    assign signal_cat_42 = { signal_const_140,
                             signal_select_222 };
    assign signal_select_223 = signal_mux_574[15:2];
    assign signal_cat_43 = { signal_const_276,
                             signal_select_223 };
    assign signal_select_224 = signal_select_225[15:1];
    assign signal_cat_44 = { signal_const_37,
                             signal_select_224 };
    assign signal_select_225 = signal_wire_111[47:32];
    assign signal_select_226 = signal_select_229[0:0];
    assign signal_mux_574 = signal_select_226 ? signal_cat_44 : signal_select_225;
    assign signal_select_227 = signal_select_229[1:1];
    assign signal_mux_575 = signal_select_227 ? signal_cat_43 : signal_mux_574;
    assign signal_select_228 = signal_select_229[2:2];
    assign signal_mux_576 = signal_select_228 ? signal_cat_42 : signal_mux_575;
    assign signal_select_229 = signal_select_240[3:0];
    assign signal_select_230 = signal_select_229[3:3];
    assign signal_mux_577 = signal_select_230 ? signal_cat_41 : signal_mux_576;
    assign signal_eq_162 = signal_mux_577 == signal_const_148;
    assign signal_not_165 = ~ signal_eq_162;
    assign signal_lt_22 = signal_select_240 < signal_const_529;
    assign signal_and_177 = signal_lt_22 & signal_not_165;
    assign signal_const_659 = 16'b0000000000100000;
    assign signal_lt_23 = signal_const_659 < signal_select_240;
    assign signal_select_231 = signal_mux_873[10:7];
    assign signal_eq_163 = signal_select_231 == signal_const_140;
    assign signal_mux_578 = signal_eq_163 ? signal_mux_773 : signal_mux_579;
    assign signal_mux_579 = signal_and_325 ? signal_const_148 : execution$reg_desc_control;
    assign signal_mux_580 = signal_and_178 ? signal_mux_578 : signal_mux_579;
    assign signal_mux_581 = signal_or_192 ? execution$reg_desc_control : signal_mux_580;
    assign signal_mux_582 = signal_and_328 ? execution$reg_desc_control : signal_mux_581;
    assign signal_mux_583 = signal_not_221 ? execution$reg_desc_control : signal_mux_582;
    assign signal_mux_584 = signal_wire_195 ? signal_const_148 : signal_mux_583;
    assign signal_wire_102 = signal_mux_584;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_control <= signal_wire_102;
    end
    assign signal_select_232 = signal_mux_873[10:7];
    assign signal_eq_164 = signal_select_232 == signal_const_136;
    assign signal_mux_585 = signal_eq_164 ? signal_mux_773 : signal_mux_586;
    assign signal_mux_586 = signal_and_325 ? signal_const_148 : execution$reg_desc_bit_count;
    assign signal_mux_587 = signal_and_178 ? signal_mux_585 : signal_mux_586;
    assign signal_mux_588 = signal_or_192 ? execution$reg_desc_bit_count : signal_mux_587;
    assign signal_mux_589 = signal_and_328 ? execution$reg_desc_bit_count : signal_mux_588;
    assign signal_mux_590 = signal_not_221 ? execution$reg_desc_bit_count : signal_mux_589;
    assign signal_mux_591 = signal_wire_195 ? signal_const_148 : signal_mux_590;
    assign signal_wire_103 = signal_mux_591;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_bit_count <= signal_wire_103;
    end
    assign signal_select_233 = signal_mux_873[10:7];
    assign signal_eq_165 = signal_select_233 == signal_const_135;
    assign signal_mux_592 = signal_eq_165 ? signal_mux_773 : signal_mux_593;
    assign signal_mux_593 = signal_and_325 ? signal_const_148 : execution$reg_desc_tx_value;
    assign signal_mux_594 = signal_and_178 ? signal_mux_592 : signal_mux_593;
    assign signal_mux_595 = signal_or_192 ? execution$reg_desc_tx_value : signal_mux_594;
    assign signal_mux_596 = signal_and_328 ? execution$reg_desc_tx_value : signal_mux_595;
    assign signal_mux_597 = signal_not_221 ? execution$reg_desc_tx_value : signal_mux_596;
    assign signal_mux_598 = signal_wire_195 ? signal_const_148 : signal_mux_597;
    assign signal_wire_104 = signal_mux_598;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_tx_value <= signal_wire_104;
    end
    assign signal_select_234 = signal_mux_873[10:7];
    assign signal_eq_166 = signal_select_234 == signal_const_138;
    assign signal_mux_599 = signal_eq_166 ? signal_mux_773 : signal_mux_600;
    assign signal_mux_600 = signal_and_325 ? signal_const_522 : execution$reg_desc_output_pin;
    assign signal_mux_601 = signal_and_178 ? signal_mux_599 : signal_mux_600;
    assign signal_mux_602 = signal_or_192 ? execution$reg_desc_output_pin : signal_mux_601;
    assign signal_mux_603 = signal_and_328 ? execution$reg_desc_output_pin : signal_mux_602;
    assign signal_mux_604 = signal_not_221 ? execution$reg_desc_output_pin : signal_mux_603;
    assign signal_mux_605 = signal_wire_195 ? signal_const_522 : signal_mux_604;
    assign signal_wire_105 = signal_mux_605;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_output_pin <= signal_wire_105;
    end
    assign signal_select_235 = signal_mux_873[10:7];
    assign signal_eq_167 = signal_select_235 == signal_const_137;
    assign signal_mux_606 = signal_eq_167 ? signal_mux_773 : signal_mux_607;
    assign signal_mux_607 = signal_and_325 ? signal_const_522 : execution$reg_desc_input_pin;
    assign signal_mux_608 = signal_and_178 ? signal_mux_606 : signal_mux_607;
    assign signal_mux_609 = signal_or_192 ? execution$reg_desc_input_pin : signal_mux_608;
    assign signal_mux_610 = signal_and_328 ? execution$reg_desc_input_pin : signal_mux_609;
    assign signal_mux_611 = signal_not_221 ? execution$reg_desc_input_pin : signal_mux_610;
    assign signal_mux_612 = signal_wire_195 ? signal_const_522 : signal_mux_611;
    assign signal_wire_106 = signal_mux_612;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_input_pin <= signal_wire_106;
    end
    assign signal_select_236 = signal_mux_873[10:7];
    assign signal_eq_168 = signal_select_236 == signal_const_139;
    assign signal_mux_613 = signal_eq_168 ? signal_mux_773 : signal_mux_614;
    assign signal_mux_614 = signal_and_325 ? signal_const_522 : execution$reg_desc_clock_pin;
    assign signal_mux_615 = signal_and_178 ? signal_mux_613 : signal_mux_614;
    assign signal_mux_616 = signal_or_192 ? execution$reg_desc_clock_pin : signal_mux_615;
    assign signal_mux_617 = signal_and_328 ? execution$reg_desc_clock_pin : signal_mux_616;
    assign signal_mux_618 = signal_not_221 ? execution$reg_desc_clock_pin : signal_mux_617;
    assign signal_mux_619 = signal_wire_195 ? signal_const_522 : signal_mux_618;
    assign signal_wire_107 = signal_mux_619;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_clock_pin <= signal_wire_107;
    end
    assign signal_select_237 = signal_mux_873[10:7];
    assign signal_eq_169 = signal_select_237 == signal_const_134;
    assign signal_mux_620 = signal_eq_169 ? signal_mux_773 : signal_mux_621;
    assign signal_mux_621 = signal_and_325 ? signal_const_148 : execution$reg_desc_initial_delay;
    assign signal_mux_622 = signal_and_178 ? signal_mux_620 : signal_mux_621;
    assign signal_mux_623 = signal_or_192 ? execution$reg_desc_initial_delay : signal_mux_622;
    assign signal_mux_624 = signal_and_328 ? execution$reg_desc_initial_delay : signal_mux_623;
    assign signal_mux_625 = signal_not_221 ? execution$reg_desc_initial_delay : signal_mux_624;
    assign signal_mux_626 = signal_wire_195 ? signal_const_148 : signal_mux_625;
    assign signal_wire_108 = signal_mux_626;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_initial_delay <= signal_wire_108;
    end
    assign signal_select_238 = signal_mux_873[10:7];
    assign signal_eq_170 = signal_select_238 == signal_const_133;
    assign signal_mux_627 = signal_eq_170 ? signal_mux_773 : signal_mux_628;
    assign signal_mux_628 = signal_and_325 ? signal_const_148 : execution$reg_desc_half_period;
    assign signal_mux_629 = signal_and_178 ? signal_mux_627 : signal_mux_628;
    assign signal_mux_630 = signal_or_192 ? execution$reg_desc_half_period : signal_mux_629;
    assign signal_mux_631 = signal_and_328 ? execution$reg_desc_half_period : signal_mux_630;
    assign signal_mux_632 = signal_not_221 ? execution$reg_desc_half_period : signal_mux_631;
    assign signal_mux_633 = signal_wire_195 ? signal_const_148 : signal_mux_632;
    assign signal_wire_109 = signal_mux_633;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_half_period <= signal_wire_109;
    end
    assign signal_select_239 = signal_mux_873[10:7];
    assign signal_eq_171 = signal_select_239 == signal_const_132;
    assign signal_mux_634 = signal_eq_171 ? signal_mux_773 : signal_mux_635;
    assign signal_mux_635 = signal_and_325 ? signal_const_148 : execution$reg_desc_pacing;
    assign signal_eq_172 = signal_select_365 == signal_const_293;
    assign signal_and_178 = signal_and_333 & signal_eq_172;
    assign signal_mux_636 = signal_and_178 ? signal_mux_634 : signal_mux_635;
    assign signal_mux_637 = signal_or_192 ? execution$reg_desc_pacing : signal_mux_636;
    assign signal_mux_638 = signal_and_328 ? execution$reg_desc_pacing : signal_mux_637;
    assign signal_mux_639 = signal_not_221 ? execution$reg_desc_pacing : signal_mux_638;
    assign signal_mux_640 = signal_wire_195 ? signal_const_148 : signal_mux_639;
    assign signal_wire_110 = signal_mux_640;
    always @(posedge signal_wire_167) begin
        execution$reg_desc_pacing <= signal_wire_110;
    end
    assign signal_cat_45 = { execution$reg_desc_pacing,
                             execution$reg_desc_half_period,
                             execution$reg_desc_initial_delay,
                             execution$reg_desc_clock_pin,
                             execution$reg_desc_input_pin,
                             execution$reg_desc_output_pin,
                             execution$reg_desc_tx_value,
                             execution$reg_desc_bit_count,
                             execution$reg_desc_control };
    assign signal_wire_111 = signal_cat_45;
    assign signal_select_240 = signal_wire_111[31:16];
    assign signal_eq_173 = signal_select_240 == signal_const_148;
    assign signal_or_104 = signal_eq_173 | signal_lt_23;
    assign signal_or_105 = signal_or_104 | signal_and_177;
    assign signal_or_106 = signal_or_105 | signal_mux_573;
    assign signal_or_107 = signal_or_106 | signal_or_99;
    assign signal_or_108 = signal_or_107 | signal_eq_131;
    assign signal_or_109 = signal_or_108 | signal_not_157;
    assign signal_or_110 = signal_or_109 | signal_and_168;
    assign signal_or_111 = signal_or_110 | signal_and_167;
    assign signal_not_166 = ~ signal_or_111;
    assign signal_const_680 = 4'b1100;
    assign signal_eq_174 = signal_wire_171 == signal_const_680;
    assign signal_and_179 = signal_and_287 & signal_eq_174;
    assign signal_and_180 = signal_and_179 & signal_not_166;
    assign signal_and_181 = signal_and_180 & signal_not_154;
    assign signal_and_182 = signal_and_181 & signal_eq_86;
    assign signal_and_183 = signal_and_182 & signal_wire_75;
    assign signal_and_184 = signal_and_183 & signal_not_128;
    assign signal_or_112 = signal_and_184 | signal_and_137;
    assign signal_and_185 = signal_or_112 & signal_or_72;
    assign signal_or_113 = signal_and_185 | signal_and_136;
    assign signal_or_114 = signal_or_113 | signal_and_135;
    assign signal_or_115 = signal_or_114 | signal_and_133;
    assign signal_or_116 = signal_or_115 | signal_and_131;
    assign signal_mux_641 = signal_or_116 ? mechanisms$bank$reg_engine_claim : signal_mux_422;
    assign signal_not_167 = ~ signal_wire_197;
    assign signal_or_117 = signal_not_167 | signal_and_328;
    assign signal_mux_642 = signal_or_117 ? signal_const_43 : signal_mux_641;
    assign signal_wire_112 = signal_mux_642;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$bank$reg_engine_claim <= signal_const_43;
        else
            mechanisms$bank$reg_engine_claim <= signal_wire_112;
    end
    assign signal_wire_113 = mechanisms$bank$reg_engine_claim;
    assign signal_select_241 = signal_wire_170[7:0];
    assign signal_and_186 = signal_select_241 & signal_wire_113;
    assign signal_eq_175 = signal_and_186 == signal_const_43;
    assign signal_not_168 = ~ signal_eq_175;
    assign signal_not_169 = ~ signal_eq_256;
    assign signal_or_118 = signal_not_169 | signal_not_168;
    assign signal_and_187 = signal_or_154 & signal_or_118;
    assign signal_and_188 = signal_and_187 & signal_not_168;
    assign signal_or_119 = signal_and_188 | signal_and_128;
    assign signal_or_120 = signal_or_119 | signal_or_78;
    assign signal_or_121 = signal_or_120 | signal_not_121;
    assign signal_or_122 = signal_or_121 | mechanisms$bank$reg_rejected;
    assign signal_mux_643 = signal_or_122 ? signal_const_419 : signal_const_58;
    assign signal_const_681 = 6'b010000;
    assign signal_not_170 = ~ signal_wire_180;
    assign signal_eq_176 = execution$reg_phase == signal_const_174;
    assign signal_not_171 = ~ signal_eq_176;
    assign signal_eq_177 = execution$reg_phase == signal_const_4;
    assign signal_not_172 = ~ signal_eq_177;
    assign signal_and_189 = signal_not_172 & signal_not_171;
    assign signal_wire_114 = signal_and_189;
    assign signal_or_123 = signal_wire_114 | signal_not_170;
    assign signal_and_190 = signal_and_328 & signal_or_123;
    assign signal_mux_644 = signal_and_190 ? signal_const_681 : signal_const_58;
    assign signal_const_685 = 6'b001000;
    assign signal_mux_645 = signal_eq_179 ? mechanisms$timing$reg_period : signal_wire_155;
    assign signal_mux_646 = signal_and_193 ? signal_mux_645 : mechanisms$timing$reg_period;
    assign signal_mux_647 = signal_or_185 ? mechanisms$timing$reg_period : signal_mux_646;
    assign signal_wire_115 = signal_mux_647;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_period <= signal_const_148;
        else
            mechanisms$timing$reg_period <= signal_wire_115;
    end
    assign signal_sub_9 = mechanisms$timing$reg_phase - signal_const_514;
    assign signal_mux_648 = signal_eq_178 ? mechanisms$timing$reg_period : signal_sub_9;
    assign signal_mux_649 = signal_eq_179 ? signal_mux_650 : signal_wire_155;
    assign signal_mux_650 = signal_and_191 ? signal_const_148 : mechanisms$timing$reg_phase;
    assign signal_mux_651 = signal_and_193 ? signal_mux_649 : signal_mux_650;
    assign signal_mux_652 = signal_and_195 ? signal_mux_648 : signal_mux_651;
    assign signal_mux_653 = signal_or_185 ? signal_const_148 : signal_mux_652;
    assign signal_wire_116 = signal_mux_653;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_phase <= signal_const_148;
        else
            mechanisms$timing$reg_phase <= signal_wire_116;
    end
    assign signal_eq_178 = mechanisms$timing$reg_phase == signal_const_514;
    assign signal_mux_654 = signal_eq_178 ? signal_const_39 : signal_const_37;
    assign signal_not_173 = ~ signal_and_191;
    assign signal_not_174 = ~ signal_and_193;
    assign signal_eq_179 = signal_wire_155 == signal_const_148;
    assign signal_mux_655 = signal_eq_179 ? signal_mux_656 : signal_const_39;
    assign signal_const_701 = 4'b1011;
    assign signal_eq_180 = signal_wire_171 == signal_const_701;
    assign signal_and_191 = signal_and_287 & signal_eq_180;
    assign signal_mux_656 = signal_and_191 ? signal_const_37 : mechanisms$timing$reg_periodic_active;
    assign signal_eq_181 = signal_wire_155 == signal_const_148;
    assign signal_not_175 = ~ signal_eq_181;
    assign signal_const_703 = 4'b1010;
    assign signal_eq_182 = signal_wire_171 == signal_const_703;
    assign signal_and_192 = signal_and_287 & signal_eq_182;
    assign signal_and_193 = signal_and_192 & signal_not_175;
    assign signal_mux_657 = signal_and_193 ? signal_mux_655 : signal_mux_656;
    assign signal_mux_658 = signal_or_185 ? signal_const_37 : signal_mux_657;
    assign signal_wire_117 = signal_mux_658;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_periodic_active <= signal_const_37;
        else
            mechanisms$timing$reg_periodic_active <= signal_wire_117;
    end
    assign signal_and_194 = mechanisms$timing$reg_periodic_active & signal_not_174;
    assign signal_and_195 = signal_and_194 & signal_not_173;
    assign signal_mux_659 = signal_and_195 ? signal_mux_654 : signal_const_37;
    assign signal_mux_660 = signal_or_185 ? signal_const_37 : signal_mux_659;
    assign signal_wire_118 = signal_mux_660;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_tick <= signal_const_37;
        else
            mechanisms$timing$reg_tick <= signal_wire_118;
    end
    assign signal_wire_119 = mechanisms$timing$reg_tick;
    assign signal_mux_661 = signal_wire_119 ? signal_const_685 : signal_const_58;
    assign signal_const_704 = 6'b000100;
    assign signal_eq_183 = mechanisms$timing$reg_kind == signal_const_276;
    assign signal_mux_662 = signal_eq_183 ? signal_const_37 : signal_const_39;
    assign signal_sub_10 = mechanisms$timing$reg_remaining - signal_const_514;
    assign signal_eq_184 = mechanisms$timing$reg_kind == signal_const_276;
    assign signal_or_124 = signal_eq_184 | mechanisms$timing$reg_timeout_enable;
    assign signal_mux_663 = signal_or_124 ? signal_sub_10 : mechanisms$timing$reg_remaining;
    assign signal_mux_664 = signal_and_196 ? signal_const_148 : signal_mux_663;
    assign signal_mux_665 = signal_mux_704 ? signal_const_148 : signal_mux_664;
    assign signal_mux_666 = signal_and_199 ? mechanisms$timing$reg_remaining : signal_mux_694;
    assign signal_mux_667 = signal_and_203 ? mechanisms$timing$reg_remaining : signal_mux_666;
    assign signal_mux_668 = signal_and_291 ? signal_mux_667 : mechanisms$timing$reg_remaining;
    assign signal_mux_669 = mechanisms$timing$reg_busy ? signal_mux_665 : signal_mux_668;
    assign signal_mux_670 = signal_or_185 ? signal_const_148 : signal_mux_669;
    assign signal_wire_120 = signal_mux_670;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_remaining <= signal_const_148;
        else
            mechanisms$timing$reg_remaining <= signal_wire_120;
    end
    assign signal_eq_185 = mechanisms$timing$reg_remaining == signal_const_514;
    assign signal_mux_671 = signal_and_199 ? mechanisms$timing$reg_timeout_enable : signal_wire_126;
    assign signal_mux_672 = signal_and_203 ? mechanisms$timing$reg_timeout_enable : signal_mux_671;
    assign signal_mux_673 = signal_and_291 ? signal_mux_672 : mechanisms$timing$reg_timeout_enable;
    assign signal_mux_674 = mechanisms$timing$reg_busy ? mechanisms$timing$reg_timeout_enable : signal_mux_673;
    assign signal_mux_675 = signal_or_185 ? mechanisms$timing$reg_timeout_enable : signal_mux_674;
    assign signal_wire_121 = signal_mux_675;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_timeout_enable <= signal_const_37;
        else
            mechanisms$timing$reg_timeout_enable <= signal_wire_121;
    end
    assign signal_eq_186 = mechanisms$timing$reg_kind == signal_const_276;
    assign signal_or_125 = signal_eq_186 | mechanisms$timing$reg_timeout_enable;
    assign signal_and_196 = signal_or_125 & signal_eq_185;
    assign signal_mux_676 = signal_and_196 ? signal_mux_662 : signal_const_37;
    assign signal_select_242 = signal_and_197[7:7];
    assign signal_select_243 = signal_and_197[6:6];
    assign signal_select_244 = signal_and_197[5:5];
    assign signal_select_245 = signal_and_197[4:4];
    assign signal_select_246 = signal_and_197[3:3];
    assign signal_select_247 = signal_and_197[2:2];
    assign signal_select_248 = signal_and_197[1:1];
    assign signal_select_249 = signal_and_197[0:0];
    always @* begin
        case (mechanisms$timing$reg_pin)
        0:
            signal_mux_677 <= signal_select_249;
        1:
            signal_mux_677 <= signal_select_248;
        2:
            signal_mux_677 <= signal_select_247;
        3:
            signal_mux_677 <= signal_select_246;
        4:
            signal_mux_677 <= signal_select_245;
        5:
            signal_mux_677 <= signal_select_244;
        6:
            signal_mux_677 <= signal_select_243;
        default:
            signal_mux_677 <= signal_select_242;
        endcase
    end
    assign signal_select_250 = signal_mux_679[7:7];
    assign signal_select_251 = signal_mux_679[6:6];
    assign signal_select_252 = signal_mux_679[5:5];
    assign signal_select_253 = signal_mux_679[4:4];
    assign signal_select_254 = signal_mux_679[3:3];
    assign signal_select_255 = signal_mux_679[2:2];
    assign signal_select_256 = signal_mux_679[1:1];
    assign signal_not_176 = ~ mechanisms$events$reg_stage1;
    assign signal_and_197 = signal_not_176 & mechanisms$events$reg_previous;
    assign signal_or_126 = signal_and_198 | signal_and_197;
    assign signal_wire_122 = mechanisms$events$reg_stage1;
    always @(posedge signal_wire_167) begin
        if (signal_or_134)
            mechanisms$events$reg_previous <= signal_const_43;
        else
            mechanisms$events$reg_previous <= signal_wire_122;
    end
    assign signal_not_177 = ~ mechanisms$events$reg_previous;
    assign signal_and_198 = mechanisms$events$reg_stage1 & signal_not_177;
    assign signal_mux_678 = signal_and_291 ? signal_and_201 : mechanisms$reg_wait_either;
    assign signal_wire_123 = signal_mux_678;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_wait_either <= signal_const_37;
        else
            mechanisms$reg_wait_either <= signal_wire_123;
    end
    assign signal_mux_679 = mechanisms$reg_wait_either ? signal_or_126 : signal_and_198;
    assign signal_select_257 = signal_mux_679[0:0];
    always @* begin
        case (mechanisms$timing$reg_pin)
        0:
            signal_mux_680 <= signal_select_257;
        1:
            signal_mux_680 <= signal_select_256;
        2:
            signal_mux_680 <= signal_select_255;
        3:
            signal_mux_680 <= signal_select_254;
        4:
            signal_mux_680 <= signal_select_253;
        5:
            signal_mux_680 <= signal_select_252;
        6:
            signal_mux_680 <= signal_select_251;
        default:
            signal_mux_680 <= signal_select_250;
        endcase
    end
    assign signal_mux_681 = signal_and_199 ? mechanisms$timing$reg_level : signal_select_266;
    assign signal_mux_682 = signal_and_203 ? mechanisms$timing$reg_level : signal_mux_681;
    assign signal_mux_683 = signal_and_291 ? signal_mux_682 : mechanisms$timing$reg_level;
    assign signal_mux_684 = mechanisms$timing$reg_busy ? mechanisms$timing$reg_level : signal_mux_683;
    assign signal_mux_685 = signal_or_185 ? mechanisms$timing$reg_level : signal_mux_684;
    assign signal_wire_124 = signal_mux_685;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_level <= signal_const_37;
        else
            mechanisms$timing$reg_level <= signal_wire_124;
    end
    assign signal_select_258 = mechanisms$events$reg_stage1[7:7];
    assign signal_select_259 = mechanisms$events$reg_stage1[6:6];
    assign signal_select_260 = mechanisms$events$reg_stage1[5:5];
    assign signal_select_261 = mechanisms$events$reg_stage1[4:4];
    assign signal_select_262 = mechanisms$events$reg_stage1[3:3];
    assign signal_select_263 = mechanisms$events$reg_stage1[2:2];
    assign signal_select_264 = mechanisms$events$reg_stage1[1:1];
    assign signal_select_265 = mechanisms$events$reg_stage1[0:0];
    assign signal_mux_686 = signal_and_199 ? mechanisms$timing$reg_pin : signal_select_275;
    assign signal_mux_687 = signal_and_203 ? mechanisms$timing$reg_pin : signal_mux_686;
    assign signal_mux_688 = signal_and_291 ? signal_mux_687 : mechanisms$timing$reg_pin;
    assign signal_mux_689 = mechanisms$timing$reg_busy ? mechanisms$timing$reg_pin : signal_mux_688;
    assign signal_mux_690 = signal_or_185 ? mechanisms$timing$reg_pin : signal_mux_689;
    assign signal_wire_125 = signal_mux_690;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_pin <= signal_const_4;
        else
            mechanisms$timing$reg_pin <= signal_wire_125;
    end
    always @* begin
        case (mechanisms$timing$reg_pin)
        0:
            signal_mux_691 <= signal_select_265;
        1:
            signal_mux_691 <= signal_select_264;
        2:
            signal_mux_691 <= signal_select_263;
        3:
            signal_mux_691 <= signal_select_262;
        4:
            signal_mux_691 <= signal_select_261;
        5:
            signal_mux_691 <= signal_select_260;
        6:
            signal_mux_691 <= signal_select_259;
        default:
            signal_mux_691 <= signal_select_258;
        endcase
    end
    assign signal_eq_187 = signal_mux_691 == mechanisms$timing$reg_level;
    assign signal_select_266 = signal_wire_170[0:0];
    assign signal_select_267 = mechanisms$events$reg_stage1[7:7];
    assign signal_select_268 = mechanisms$events$reg_stage1[6:6];
    assign signal_select_269 = mechanisms$events$reg_stage1[5:5];
    assign signal_select_270 = mechanisms$events$reg_stage1[4:4];
    assign signal_select_271 = mechanisms$events$reg_stage1[3:3];
    assign signal_select_272 = mechanisms$events$reg_stage1[2:2];
    assign signal_select_273 = mechanisms$events$reg_stage1[1:1];
    assign signal_select_274 = mechanisms$events$reg_stage1[0:0];
    assign signal_select_275 = signal_wire_155[2:0];
    always @* begin
        case (signal_select_275)
        0:
            signal_mux_692 <= signal_select_274;
        1:
            signal_mux_692 <= signal_select_273;
        2:
            signal_mux_692 <= signal_select_272;
        3:
            signal_mux_692 <= signal_select_271;
        4:
            signal_mux_692 <= signal_select_270;
        5:
            signal_mux_692 <= signal_select_269;
        6:
            signal_mux_692 <= signal_select_268;
        default:
            signal_mux_692 <= signal_select_267;
        endcase
    end
    assign signal_eq_188 = signal_mux_692 == signal_select_266;
    assign signal_eq_189 = signal_mux_699 == signal_const_458;
    assign signal_and_199 = signal_eq_189 & signal_eq_188;
    assign signal_mux_693 = signal_and_199 ? mechanisms$timing$reg_kind : signal_mux_699;
    assign signal_mux_694 = signal_or_182 ? signal_wire_155 : signal_wire_156;
    assign signal_eq_190 = signal_mux_694 == signal_const_148;
    assign signal_select_276 = signal_mux_873[6:6];
    assign signal_select_277 = signal_mux_873[5:5];
    assign signal_eq_191 = signal_select_365 == signal_const_264;
    assign signal_mux_695 = signal_eq_191 ? signal_select_277 : gnd;
    assign signal_eq_192 = signal_select_365 == signal_const_265;
    assign signal_mux_696 = signal_eq_192 ? signal_select_276 : signal_mux_695;
    assign signal_wire_126 = signal_mux_696;
    assign signal_select_278 = signal_wire_170[1:0];
    assign signal_add_24 = signal_select_278 + signal_const_448;
    assign signal_select_279 = signal_wire_170[1:0];
    assign signal_eq_193 = signal_select_279 == signal_const_448;
    assign signal_eq_194 = signal_wire_171 == signal_const_131;
    assign signal_and_200 = signal_and_287 & signal_eq_194;
    assign signal_and_201 = signal_and_200 & signal_eq_193;
    assign signal_mux_697 = signal_and_201 ? signal_const_448 : signal_add_24;
    assign signal_eq_195 = signal_wire_171 == signal_const_132;
    assign signal_and_202 = signal_and_287 & signal_eq_195;
    assign signal_mux_698 = signal_and_202 ? signal_const_458 : signal_mux_697;
    assign signal_mux_699 = signal_or_182 ? signal_const_276 : signal_mux_698;
    assign signal_eq_196 = signal_mux_699 == signal_const_276;
    assign signal_or_127 = signal_eq_196 | signal_wire_126;
    assign signal_and_203 = signal_or_127 & signal_eq_190;
    assign signal_mux_700 = signal_and_203 ? mechanisms$timing$reg_kind : signal_mux_693;
    assign signal_mux_701 = signal_and_291 ? signal_mux_700 : mechanisms$timing$reg_kind;
    assign signal_mux_702 = mechanisms$timing$reg_busy ? mechanisms$timing$reg_kind : signal_mux_701;
    assign signal_mux_703 = signal_or_185 ? mechanisms$timing$reg_kind : signal_mux_702;
    assign signal_wire_127 = signal_mux_703;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_kind <= signal_const_276;
        else
            mechanisms$timing$reg_kind <= signal_wire_127;
    end
    always @* begin
        case (mechanisms$timing$reg_kind)
        0:
            signal_mux_704 <= gnd;
        1:
            signal_mux_704 <= signal_eq_187;
        2:
            signal_mux_704 <= signal_mux_680;
        default:
            signal_mux_704 <= signal_mux_677;
        endcase
    end
    assign signal_mux_705 = signal_mux_704 ? signal_const_37 : signal_mux_676;
    assign signal_mux_706 = mechanisms$timing$reg_busy ? signal_mux_705 : signal_const_37;
    assign signal_mux_707 = signal_or_185 ? signal_const_37 : signal_mux_706;
    assign signal_wire_128 = signal_mux_707;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_timeout <= signal_const_37;
        else
            mechanisms$timing$reg_timeout <= signal_wire_128;
    end
    assign signal_wire_129 = mechanisms$timing$reg_timeout;
    assign signal_and_204 = signal_and_295 & signal_wire_129;
    assign signal_mux_708 = signal_and_204 ? signal_const_704 : signal_const_58;
    assign signal_not_178 = ~ mechanisms$reg_wait_is_delay;
    assign signal_and_205 = signal_and_295 & signal_wire_178;
    assign signal_and_206 = signal_and_205 & signal_not_178;
    assign signal_mux_709 = signal_and_206 ? signal_const_65 : signal_const_58;
    assign signal_mux_710 = signal_and_291 ? signal_or_182 : mechanisms$reg_wait_is_delay;
    assign signal_wire_130 = signal_mux_710;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_wait_is_delay <= signal_const_37;
        else
            mechanisms$reg_wait_is_delay <= signal_wire_130;
    end
    assign signal_and_207 = signal_and_295 & signal_wire_178;
    assign signal_and_208 = signal_and_207 & mechanisms$reg_wait_is_delay;
    assign signal_mux_711 = signal_and_208 ? signal_const_59 : signal_const_58;
    assign signal_or_128 = signal_mux_711 | signal_mux_709;
    assign signal_or_129 = signal_or_128 | signal_mux_708;
    assign signal_or_130 = signal_or_129 | signal_mux_661;
    assign signal_or_131 = signal_or_130 | signal_mux_644;
    assign signal_or_132 = signal_or_131 | signal_mux_643;
    assign signal_wire_131 = signal_or_132;
    assign signal_select_280 = signal_wire_155[5:0];
    assign signal_and_209 = signal_and_274 & signal_or_163;
    assign signal_mux_712 = signal_and_209 ? signal_select_280 : signal_const_58;
    assign signal_wire_132 = signal_mux_712;
    assign signal_not_179 = ~ signal_wire_132;
    assign signal_and_210 = mechanisms$events$reg_event & signal_not_179;
    assign signal_or_133 = signal_and_210 | signal_wire_131;
    assign signal_wire_133 = signal_or_133;
    always @(posedge signal_wire_167) begin
        if (signal_or_134)
            mechanisms$events$reg_event <= signal_const_58;
        else
            mechanisms$events$reg_event <= signal_wire_133;
    end
    assign signal_cat_46 = { signal_const_309,
                             mechanisms$events$reg_event };
    assign signal_select_281 = signal_wire_170[0:0];
    assign signal_select_282 = mechanisms$events$reg_stage1[7:7];
    assign signal_select_283 = mechanisms$events$reg_stage1[6:6];
    assign signal_select_284 = mechanisms$events$reg_stage1[5:5];
    assign signal_select_285 = mechanisms$events$reg_stage1[4:4];
    assign signal_select_286 = mechanisms$events$reg_stage1[3:3];
    assign signal_select_287 = mechanisms$events$reg_stage1[2:2];
    assign signal_select_288 = mechanisms$events$reg_stage1[1:1];
    assign signal_not_180 = ~ signal_wire_197;
    assign signal_or_134 = signal_wire_195 | signal_not_180;
    assign signal_wire_134 = pin_async_i;
    assign signal_wire_135 = signal_wire_134;
    always @(posedge signal_wire_167) begin
        if (signal_or_134)
            mechanisms$events$reg_stage0 <= signal_const_43;
        else
            mechanisms$events$reg_stage0 <= signal_wire_135;
    end
    assign signal_wire_136 = mechanisms$events$reg_stage0;
    always @(posedge signal_wire_167) begin
        if (signal_or_134)
            mechanisms$events$reg_stage1 <= signal_const_43;
        else
            mechanisms$events$reg_stage1 <= signal_wire_136;
    end
    assign signal_select_289 = mechanisms$events$reg_stage1[0:0];
    assign signal_select_290 = signal_wire_155[2:0];
    always @* begin
        case (signal_select_290)
        0:
            signal_mux_713 <= signal_select_289;
        1:
            signal_mux_713 <= signal_select_288;
        2:
            signal_mux_713 <= signal_select_287;
        3:
            signal_mux_713 <= signal_select_286;
        4:
            signal_mux_713 <= signal_select_285;
        5:
            signal_mux_713 <= signal_select_284;
        6:
            signal_mux_713 <= signal_select_283;
        default:
            signal_mux_713 <= signal_select_282;
        endcase
    end
    assign signal_eq_197 = signal_mux_713 == signal_select_281;
    assign signal_cat_47 = { signal_const_406,
                             signal_eq_197 };
    assign signal_eq_198 = mechanisms$rx_fifo$reg_write_index == signal_const_133;
    assign signal_and_211 = signal_and_241 & signal_eq_198;
    always @(posedge signal_wire_167) begin
        if (signal_and_211)
            signal_reg_13 <= signal_wire_139;
    end
    assign signal_eq_199 = mechanisms$rx_fifo$reg_write_index == signal_const_134;
    assign signal_and_212 = signal_and_241 & signal_eq_199;
    always @(posedge signal_wire_167) begin
        if (signal_and_212)
            signal_reg_14 <= signal_wire_139;
    end
    assign signal_eq_200 = mechanisms$rx_fifo$reg_write_index == signal_const_139;
    assign signal_and_213 = signal_and_241 & signal_eq_200;
    always @(posedge signal_wire_167) begin
        if (signal_and_213)
            signal_reg_15 <= signal_wire_139;
    end
    assign signal_eq_201 = mechanisms$rx_fifo$reg_write_index == signal_const_137;
    assign signal_and_214 = signal_and_241 & signal_eq_201;
    always @(posedge signal_wire_167) begin
        if (signal_and_214)
            signal_reg_16 <= signal_wire_139;
    end
    assign signal_eq_202 = mechanisms$rx_fifo$reg_write_index == signal_const_138;
    assign signal_and_215 = signal_and_241 & signal_eq_202;
    always @(posedge signal_wire_167) begin
        if (signal_and_215)
            signal_reg_17 <= signal_wire_139;
    end
    assign signal_eq_203 = mechanisms$rx_fifo$reg_write_index == signal_const_135;
    assign signal_and_216 = signal_and_241 & signal_eq_203;
    always @(posedge signal_wire_167) begin
        if (signal_and_216)
            signal_reg_18 <= signal_wire_139;
    end
    assign signal_eq_204 = mechanisms$rx_fifo$reg_write_index == signal_const_136;
    assign signal_and_217 = signal_and_241 & signal_eq_204;
    always @(posedge signal_wire_167) begin
        if (signal_and_217)
            signal_reg_19 <= signal_wire_139;
    end
    assign signal_add_25 = mechanisms$rx_fifo$reg_write_index + signal_const_136;
    assign signal_eq_205 = mechanisms$rx_fifo$reg_write_index == signal_const_133;
    assign signal_mux_714 = signal_eq_205 ? signal_const_140 : signal_add_25;
    assign signal_mux_715 = signal_and_241 ? signal_mux_714 : mechanisms$rx_fifo$reg_write_index;
    assign signal_mux_716 = signal_not_194 ? signal_const_140 : signal_mux_715;
    assign signal_wire_137 = signal_mux_716;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$rx_fifo$reg_write_index <= signal_const_140;
        else
            mechanisms$rx_fifo$reg_write_index <= signal_wire_137;
    end
    assign signal_eq_206 = mechanisms$rx_fifo$reg_write_index == signal_const_140;
    assign signal_and_218 = signal_and_241 & signal_eq_206;
    assign signal_wire_138 = rx_data_i;
    assign signal_mux_717 = signal_and_240 ? signal_mux_727 : signal_wire_138;
    assign signal_wire_139 = signal_mux_717;
    always @(posedge signal_wire_167) begin
        if (signal_and_218)
            signal_reg_20 <= signal_wire_139;
    end
    assign signal_add_26 = mechanisms$rx_fifo$reg_read_index + signal_const_136;
    assign signal_eq_207 = mechanisms$rx_fifo$reg_read_index == signal_const_133;
    assign signal_mux_718 = signal_eq_207 ? signal_const_140 : signal_add_26;
    assign signal_mux_719 = signal_and_243 ? signal_mux_718 : mechanisms$rx_fifo$reg_read_index;
    assign signal_mux_720 = signal_not_194 ? signal_const_140 : signal_mux_719;
    assign signal_wire_140 = signal_mux_720;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$rx_fifo$reg_read_index <= signal_const_140;
        else
            mechanisms$rx_fifo$reg_read_index <= signal_wire_140;
    end
    always @* begin
        case (mechanisms$rx_fifo$reg_read_index)
        0:
            signal_mux_721 <= signal_reg_20;
        1:
            signal_mux_721 <= signal_reg_19;
        2:
            signal_mux_721 <= signal_reg_18;
        3:
            signal_mux_721 <= signal_reg_17;
        4:
            signal_mux_721 <= signal_reg_16;
        5:
            signal_mux_721 <= signal_reg_15;
        6:
            signal_mux_721 <= signal_reg_14;
        7:
            signal_mux_721 <= signal_reg_13;
        8:
            signal_mux_721 <= signal_const_43;
        9:
            signal_mux_721 <= signal_const_43;
        10:
            signal_mux_721 <= signal_const_43;
        11:
            signal_mux_721 <= signal_const_43;
        12:
            signal_mux_721 <= signal_const_43;
        13:
            signal_mux_721 <= signal_const_43;
        14:
            signal_mux_721 <= signal_const_43;
        default:
            signal_mux_721 <= signal_const_43;
        endcase
    end
    assign signal_mux_722 = signal_not_195 ? signal_mux_721 : signal_const_43;
    assign signal_eq_208 = mechanisms$tx_fifo$reg_write_index == signal_const_133;
    assign signal_and_219 = signal_and_230 & signal_eq_208;
    always @(posedge signal_wire_167) begin
        if (signal_and_219)
            signal_reg_21 <= signal_wire_143;
    end
    assign signal_eq_209 = mechanisms$tx_fifo$reg_write_index == signal_const_134;
    assign signal_and_220 = signal_and_230 & signal_eq_209;
    always @(posedge signal_wire_167) begin
        if (signal_and_220)
            signal_reg_22 <= signal_wire_143;
    end
    assign signal_eq_210 = mechanisms$tx_fifo$reg_write_index == signal_const_139;
    assign signal_and_221 = signal_and_230 & signal_eq_210;
    always @(posedge signal_wire_167) begin
        if (signal_and_221)
            signal_reg_23 <= signal_wire_143;
    end
    assign signal_eq_211 = mechanisms$tx_fifo$reg_write_index == signal_const_137;
    assign signal_and_222 = signal_and_230 & signal_eq_211;
    always @(posedge signal_wire_167) begin
        if (signal_and_222)
            signal_reg_24 <= signal_wire_143;
    end
    assign signal_eq_212 = mechanisms$tx_fifo$reg_write_index == signal_const_138;
    assign signal_and_223 = signal_and_230 & signal_eq_212;
    always @(posedge signal_wire_167) begin
        if (signal_and_223)
            signal_reg_25 <= signal_wire_143;
    end
    assign signal_eq_213 = mechanisms$tx_fifo$reg_write_index == signal_const_135;
    assign signal_and_224 = signal_and_230 & signal_eq_213;
    always @(posedge signal_wire_167) begin
        if (signal_and_224)
            signal_reg_26 <= signal_wire_143;
    end
    assign signal_eq_214 = mechanisms$tx_fifo$reg_write_index == signal_const_136;
    assign signal_and_225 = signal_and_230 & signal_eq_214;
    always @(posedge signal_wire_167) begin
        if (signal_and_225)
            signal_reg_27 <= signal_wire_143;
    end
    assign signal_add_27 = mechanisms$tx_fifo$reg_write_index + signal_const_136;
    assign signal_eq_215 = mechanisms$tx_fifo$reg_write_index == signal_const_133;
    assign signal_mux_723 = signal_eq_215 ? signal_const_140 : signal_add_27;
    assign signal_mux_724 = signal_and_230 ? signal_mux_723 : mechanisms$tx_fifo$reg_write_index;
    assign signal_mux_725 = signal_not_197 ? signal_const_140 : signal_mux_724;
    assign signal_wire_141 = signal_mux_725;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$tx_fifo$reg_write_index <= signal_const_140;
        else
            mechanisms$tx_fifo$reg_write_index <= signal_wire_141;
    end
    assign signal_eq_216 = mechanisms$tx_fifo$reg_write_index == signal_const_140;
    assign signal_and_226 = signal_and_230 & signal_eq_216;
    assign signal_select_291 = signal_wire_156[7:0];
    assign signal_mux_726 = signal_and_257 ? signal_select_291 : mechanisms$reg_fifo_data;
    assign signal_wire_142 = signal_mux_726;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_fifo_data <= signal_const_43;
        else
            mechanisms$reg_fifo_data <= signal_wire_142;
    end
    assign signal_select_292 = signal_wire_156[7:0];
    assign signal_mux_727 = mechanisms$reg_fifo_pending ? mechanisms$reg_fifo_data : signal_select_292;
    assign signal_wire_143 = signal_mux_727;
    always @(posedge signal_wire_167) begin
        if (signal_and_226)
            signal_reg_28 <= signal_wire_143;
    end
    assign signal_add_28 = mechanisms$tx_fifo$reg_read_index + signal_const_136;
    assign signal_eq_217 = mechanisms$tx_fifo$reg_read_index == signal_const_133;
    assign signal_mux_728 = signal_eq_217 ? signal_const_140 : signal_add_28;
    assign signal_mux_729 = signal_and_250 ? signal_mux_728 : mechanisms$tx_fifo$reg_read_index;
    assign signal_mux_730 = signal_not_197 ? signal_const_140 : signal_mux_729;
    assign signal_wire_144 = signal_mux_730;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$tx_fifo$reg_read_index <= signal_const_140;
        else
            mechanisms$tx_fifo$reg_read_index <= signal_wire_144;
    end
    always @* begin
        case (mechanisms$tx_fifo$reg_read_index)
        0:
            signal_mux_731 <= signal_reg_28;
        1:
            signal_mux_731 <= signal_reg_27;
        2:
            signal_mux_731 <= signal_reg_26;
        3:
            signal_mux_731 <= signal_reg_25;
        4:
            signal_mux_731 <= signal_reg_24;
        5:
            signal_mux_731 <= signal_reg_23;
        6:
            signal_mux_731 <= signal_reg_22;
        7:
            signal_mux_731 <= signal_reg_21;
        8:
            signal_mux_731 <= signal_const_43;
        9:
            signal_mux_731 <= signal_const_43;
        10:
            signal_mux_731 <= signal_const_43;
        11:
            signal_mux_731 <= signal_const_43;
        12:
            signal_mux_731 <= signal_const_43;
        13:
            signal_mux_731 <= signal_const_43;
        14:
            signal_mux_731 <= signal_const_43;
        default:
            signal_mux_731 <= signal_const_43;
        endcase
    end
    assign signal_mux_732 = signal_not_196 ? signal_mux_731 : signal_const_43;
    assign signal_mux_733 = signal_select_304 ? signal_mux_722 : signal_mux_732;
    assign signal_cat_48 = { signal_const_43,
                             signal_mux_733 };
    assign signal_mux_734 = signal_and_246 ? signal_cat_48 : signal_const_148;
    assign signal_mux_735 = signal_and_273 ? signal_cat_47 : signal_mux_734;
    assign signal_mux_736 = signal_and_275 ? signal_cat_46 : signal_mux_735;
    assign signal_mux_737 = signal_and_276 ? signal_cat_33 : signal_mux_736;
    assign signal_not_181 = ~ signal_and_328;
    assign signal_mux_738 = mechanisms$reg_fifo_rx ? signal_and_236 : signal_and_252;
    assign signal_not_182 = ~ signal_mux_747;
    assign signal_and_227 = signal_and_246 & signal_not_182;
    assign signal_const_807 = 5'b01000;
    assign signal_sub_11 = mechanisms$tx_fifo$reg_count - signal_const_305;
    assign signal_add_29 = mechanisms$tx_fifo$reg_count + signal_const_305;
    assign signal_not_183 = ~ signal_and_250;
    assign signal_and_228 = signal_and_230 & signal_not_183;
    assign signal_mux_739 = signal_and_228 ? signal_add_29 : mechanisms$tx_fifo$reg_count;
    assign signal_not_184 = ~ signal_mux_744;
    assign signal_and_229 = signal_or_136 & signal_not_184;
    assign signal_wire_145 = signal_and_229;
    assign signal_and_230 = signal_wire_145 & signal_and_252;
    assign signal_not_185 = ~ signal_and_230;
    assign signal_not_186 = ~ signal_and_248;
    assign signal_wire_146 = tx_ready_i;
    assign signal_and_231 = signal_wire_146 & signal_not_186;
    assign signal_not_187 = ~ signal_mux_744;
    assign signal_not_188 = ~ signal_and_328;
    assign signal_mux_740 = mechanisms$reg_fifo_rx ? signal_and_245 : signal_and_249;
    assign signal_mux_741 = signal_and_257 ? signal_and_254 : mechanisms$reg_fifo_push;
    assign signal_wire_147 = signal_mux_741;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_fifo_push <= signal_const_37;
        else
            mechanisms$reg_fifo_push <= signal_wire_147;
    end
    assign signal_not_189 = ~ mechanisms$reg_fifo_push;
    assign signal_and_232 = mechanisms$reg_fifo_pending & signal_not_189;
    assign signal_and_233 = signal_and_232 & signal_mux_740;
    assign signal_and_234 = signal_and_233 & signal_not_188;
    assign signal_sub_12 = mechanisms$rx_fifo$reg_count - signal_const_305;
    assign signal_add_30 = mechanisms$rx_fifo$reg_count + signal_const_305;
    assign signal_not_190 = ~ signal_and_243;
    assign signal_and_235 = signal_and_241 & signal_not_190;
    assign signal_mux_742 = signal_and_235 ? signal_add_30 : mechanisms$rx_fifo$reg_count;
    assign signal_lt_24 = mechanisms$rx_fifo$reg_count < signal_const_807;
    assign signal_or_135 = signal_lt_24 | signal_and_243;
    assign signal_and_236 = signal_wire_197 & signal_or_135;
    assign signal_not_191 = ~ signal_and_240;
    assign signal_wire_148 = rx_valid_i;
    assign signal_and_237 = signal_wire_148 & signal_not_191;
    assign signal_not_192 = ~ signal_and_253;
    assign signal_and_238 = signal_and_254 & signal_not_192;
    assign signal_and_239 = signal_and_238 & signal_mux_752;
    assign signal_or_136 = signal_and_239 | signal_and_260;
    assign signal_and_240 = signal_or_136 & signal_mux_744;
    assign signal_or_137 = signal_and_240 | signal_and_237;
    assign signal_wire_149 = signal_or_137;
    assign signal_and_241 = signal_wire_149 & signal_and_236;
    assign signal_not_193 = ~ signal_and_241;
    assign signal_mux_743 = signal_and_257 ? signal_select_304 : mechanisms$reg_fifo_rx;
    assign signal_wire_150 = signal_mux_743;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_fifo_rx <= signal_const_37;
        else
            mechanisms$reg_fifo_rx <= signal_wire_150;
    end
    assign signal_mux_744 = mechanisms$reg_fifo_pending ? mechanisms$reg_fifo_rx : signal_select_304;
    assign signal_and_242 = signal_or_138 & signal_mux_744;
    assign signal_wire_151 = signal_and_242;
    assign signal_and_243 = signal_and_245 & signal_wire_151;
    assign signal_and_244 = signal_and_243 & signal_not_193;
    assign signal_mux_745 = signal_and_244 ? signal_sub_12 : signal_mux_742;
    assign signal_not_194 = ~ signal_wire_197;
    assign signal_mux_746 = signal_not_194 ? signal_const_116 : signal_mux_745;
    assign signal_wire_152 = signal_mux_746;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$rx_fifo$reg_count <= signal_const_116;
        else
            mechanisms$rx_fifo$reg_count <= signal_wire_152;
    end
    assign signal_eq_218 = mechanisms$rx_fifo$reg_count == signal_const_116;
    assign signal_not_195 = ~ signal_eq_218;
    assign signal_and_245 = signal_wire_197 & signal_not_195;
    assign signal_mux_747 = signal_select_304 ? signal_and_245 : signal_and_249;
    assign signal_const_820 = 4'b1110;
    assign signal_eq_219 = signal_wire_171 == signal_const_820;
    assign signal_and_246 = signal_and_287 & signal_eq_219;
    assign signal_and_247 = signal_and_246 & signal_mux_747;
    assign signal_or_138 = signal_and_247 | signal_and_234;
    assign signal_and_248 = signal_or_138 & signal_not_187;
    assign signal_or_139 = signal_and_248 | signal_and_231;
    assign signal_wire_153 = signal_or_139;
    assign signal_eq_220 = mechanisms$tx_fifo$reg_count == signal_const_116;
    assign signal_not_196 = ~ signal_eq_220;
    assign signal_and_249 = signal_wire_197 & signal_not_196;
    assign signal_and_250 = signal_and_249 & signal_wire_153;
    assign signal_and_251 = signal_and_250 & signal_not_185;
    assign signal_mux_748 = signal_and_251 ? signal_sub_11 : signal_mux_739;
    assign signal_not_197 = ~ signal_wire_197;
    assign signal_mux_749 = signal_not_197 ? signal_const_116 : signal_mux_748;
    assign signal_wire_154 = signal_mux_749;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$tx_fifo$reg_count <= signal_const_116;
        else
            mechanisms$tx_fifo$reg_count <= signal_wire_154;
    end
    assign signal_lt_25 = mechanisms$tx_fifo$reg_count < signal_const_807;
    assign signal_or_140 = signal_lt_25 | signal_and_250;
    assign signal_and_252 = signal_wire_197 & signal_or_140;
    assign signal_select_293 = signal_mux_873[10:10];
    assign signal_cat_49 = { signal_const_406,
                             signal_select_293 };
    assign signal_select_294 = signal_mux_873[10:10];
    assign signal_cat_50 = { signal_const_406,
                             signal_select_294 };
    assign signal_select_295 = signal_mux_873[10:8];
    assign signal_const_832 = 13'b0000000000000;
    assign signal_cat_51 = { signal_const_832,
                             signal_select_295 };
    assign signal_select_296 = signal_mux_873[10:8];
    assign signal_cat_52 = { signal_const_832,
                             signal_select_296 };
    assign signal_select_297 = signal_mux_873[10:8];
    always @* begin
        case (signal_select_297)
        0:
            signal_mux_750 <= execution$reg_r0;
        1:
            signal_mux_750 <= execution$reg_r1;
        2:
            signal_mux_750 <= execution$reg_r2;
        3:
            signal_mux_750 <= execution$reg_r3;
        4:
            signal_mux_750 <= execution$reg_r4;
        5:
            signal_mux_750 <= execution$reg_r5;
        6:
            signal_mux_750 <= execution$reg_r6;
        default:
            signal_mux_750 <= execution$reg_r7;
        endcase
    end
    assign signal_select_298 = signal_mux_873[10:10];
    assign signal_cat_53 = { signal_const_406,
                             signal_select_298 };
    assign signal_select_299 = signal_mux_873[10:10];
    assign signal_cat_54 = { signal_const_406,
                             signal_select_299 };
    assign signal_select_300 = signal_mux_873[10:8];
    assign signal_cat_55 = { signal_const_832,
                             signal_select_300 };
    assign signal_select_301 = signal_mux_873[5:0];
    assign signal_cat_56 = { signal_const_309,
                             signal_select_301 };
    assign signal_select_302 = signal_mux_873[10:8];
    assign signal_cat_57 = { signal_const_832,
                             signal_select_302 };
    assign signal_select_303 = signal_mux_873[10:8];
    assign signal_cat_58 = { signal_const_832,
                             signal_select_303 };
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_751 <= signal_const_148;
        1:
            signal_mux_751 <= signal_const_148;
        2:
            signal_mux_751 <= signal_const_148;
        3:
            signal_mux_751 <= signal_const_148;
        4:
            signal_mux_751 <= signal_const_148;
        5:
            signal_mux_751 <= signal_const_148;
        6:
            signal_mux_751 <= signal_const_148;
        7:
            signal_mux_751 <= signal_const_148;
        8:
            signal_mux_751 <= signal_cat_58;
        9:
            signal_mux_751 <= signal_cat_57;
        10:
            signal_mux_751 <= signal_cat_56;
        11:
            signal_mux_751 <= signal_const_148;
        12:
            signal_mux_751 <= signal_const_148;
        13:
            signal_mux_751 <= signal_cat_55;
        14:
            signal_mux_751 <= signal_const_148;
        15:
            signal_mux_751 <= signal_cat_54;
        16:
            signal_mux_751 <= signal_cat_53;
        17:
            signal_mux_751 <= signal_mux_773;
        18:
            signal_mux_751 <= signal_mux_750;
        19:
            signal_mux_751 <= signal_cat_52;
        20:
            signal_mux_751 <= signal_cat_51;
        21:
            signal_mux_751 <= signal_mux_773;
        22:
            signal_mux_751 <= signal_const_148;
        23:
            signal_mux_751 <= signal_const_148;
        24:
            signal_mux_751 <= signal_const_148;
        25:
            signal_mux_751 <= signal_cat_50;
        26:
            signal_mux_751 <= signal_cat_49;
        27:
            signal_mux_751 <= signal_const_148;
        28:
            signal_mux_751 <= signal_const_148;
        29:
            signal_mux_751 <= signal_const_148;
        30:
            signal_mux_751 <= signal_const_148;
        default:
            signal_mux_751 <= signal_const_148;
        endcase
    end
    assign signal_wire_155 = signal_mux_751;
    assign signal_select_304 = signal_wire_155[0:0];
    assign signal_mux_752 = signal_select_304 ? signal_and_236 : signal_and_252;
    assign signal_not_198 = ~ signal_mux_752;
    assign signal_select_305 = signal_mux_873[8:6];
    always @* begin
        case (signal_select_305)
        0:
            signal_mux_753 <= execution$reg_r0;
        1:
            signal_mux_753 <= execution$reg_r1;
        2:
            signal_mux_753 <= execution$reg_r2;
        3:
            signal_mux_753 <= execution$reg_r3;
        4:
            signal_mux_753 <= execution$reg_r4;
        5:
            signal_mux_753 <= execution$reg_r5;
        6:
            signal_mux_753 <= execution$reg_r6;
        default:
            signal_mux_753 <= execution$reg_r7;
        endcase
    end
    assign signal_select_306 = signal_mux_873[6:4];
    always @* begin
        case (signal_select_306)
        0:
            signal_mux_754 <= execution$reg_r0;
        1:
            signal_mux_754 <= execution$reg_r1;
        2:
            signal_mux_754 <= execution$reg_r2;
        3:
            signal_mux_754 <= execution$reg_r3;
        4:
            signal_mux_754 <= execution$reg_r4;
        5:
            signal_mux_754 <= execution$reg_r5;
        6:
            signal_mux_754 <= execution$reg_r6;
        default:
            signal_mux_754 <= execution$reg_r7;
        endcase
    end
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_755 <= signal_const_148;
        1:
            signal_mux_755 <= signal_const_148;
        2:
            signal_mux_755 <= signal_const_148;
        3:
            signal_mux_755 <= signal_const_148;
        4:
            signal_mux_755 <= signal_const_148;
        5:
            signal_mux_755 <= signal_const_148;
        6:
            signal_mux_755 <= signal_const_148;
        7:
            signal_mux_755 <= signal_const_148;
        8:
            signal_mux_755 <= signal_const_148;
        9:
            signal_mux_755 <= signal_const_148;
        10:
            signal_mux_755 <= signal_const_148;
        11:
            signal_mux_755 <= signal_const_148;
        12:
            signal_mux_755 <= signal_const_148;
        13:
            signal_mux_755 <= signal_const_148;
        14:
            signal_mux_755 <= signal_const_148;
        15:
            signal_mux_755 <= signal_mux_773;
        16:
            signal_mux_755 <= signal_mux_754;
        17:
            signal_mux_755 <= signal_const_148;
        18:
            signal_mux_755 <= signal_const_148;
        19:
            signal_mux_755 <= signal_mux_773;
        20:
            signal_mux_755 <= signal_mux_773;
        21:
            signal_mux_755 <= signal_const_148;
        22:
            signal_mux_755 <= signal_const_148;
        23:
            signal_mux_755 <= signal_const_148;
        24:
            signal_mux_755 <= signal_const_148;
        25:
            signal_mux_755 <= signal_mux_753;
        26:
            signal_mux_755 <= signal_const_148;
        27:
            signal_mux_755 <= signal_const_148;
        28:
            signal_mux_755 <= signal_const_148;
        29:
            signal_mux_755 <= signal_const_148;
        30:
            signal_mux_755 <= signal_const_148;
        default:
            signal_mux_755 <= signal_const_148;
        endcase
    end
    assign signal_wire_156 = signal_mux_755;
    assign signal_select_307 = signal_wire_156[15:8];
    assign signal_eq_221 = signal_select_307 == signal_const_43;
    assign signal_not_199 = ~ signal_eq_221;
    assign signal_and_253 = signal_and_254 & signal_not_199;
    assign signal_not_200 = ~ signal_and_253;
    assign signal_const_879 = 4'b1101;
    assign signal_eq_222 = signal_wire_171 == signal_const_879;
    assign signal_and_254 = signal_and_287 & signal_eq_222;
    assign signal_and_255 = signal_and_254 & signal_not_200;
    assign signal_and_256 = signal_and_255 & signal_not_198;
    assign signal_or_141 = signal_and_256 | signal_and_227;
    assign signal_select_308 = signal_wire_170[0:0];
    assign signal_not_201 = ~ signal_select_308;
    assign signal_and_257 = signal_not_201 & signal_or_141;
    assign signal_mux_756 = signal_and_257 ? signal_const_39 : mechanisms$reg_fifo_pending;
    assign signal_mux_757 = signal_or_142 ? signal_const_37 : signal_mux_756;
    assign signal_mux_758 = signal_or_187 ? signal_const_37 : signal_mux_757;
    assign signal_wire_157 = signal_mux_758;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_fifo_pending <= signal_const_37;
        else
            mechanisms$reg_fifo_pending <= signal_wire_157;
    end
    assign signal_and_258 = mechanisms$reg_fifo_pending & mechanisms$reg_fifo_push;
    assign signal_and_259 = signal_and_258 & signal_mux_738;
    assign signal_and_260 = signal_and_259 & signal_not_181;
    assign signal_or_142 = signal_and_260 | signal_and_234;
    assign signal_mux_759 = signal_or_142 ? signal_cat_32 : signal_mux_737;
    assign signal_wire_158 = signal_mux_759;
    assign signal_select_309 = signal_mux_873[7:5];
    always @* begin
        case (signal_select_309)
        0:
            signal_mux_760 <= execution$reg_r0;
        1:
            signal_mux_760 <= execution$reg_r1;
        2:
            signal_mux_760 <= execution$reg_r2;
        3:
            signal_mux_760 <= execution$reg_r3;
        4:
            signal_mux_760 <= execution$reg_r4;
        5:
            signal_mux_760 <= execution$reg_r5;
        6:
            signal_mux_760 <= execution$reg_r6;
        default:
            signal_mux_760 <= execution$reg_r7;
        endcase
    end
    assign signal_xor_3 = signal_mux_762 ^ signal_mux_761;
    assign signal_or_143 = signal_mux_762 | signal_mux_761;
    assign signal_and_261 = signal_mux_762 & signal_mux_761;
    assign signal_sub_13 = signal_mux_762 - signal_mux_761;
    assign signal_select_310 = signal_mux_873[4:2];
    always @* begin
        case (signal_select_310)
        0:
            signal_mux_761 <= execution$reg_r0;
        1:
            signal_mux_761 <= execution$reg_r1;
        2:
            signal_mux_761 <= execution$reg_r2;
        3:
            signal_mux_761 <= execution$reg_r3;
        4:
            signal_mux_761 <= execution$reg_r4;
        5:
            signal_mux_761 <= execution$reg_r5;
        6:
            signal_mux_761 <= execution$reg_r6;
        default:
            signal_mux_761 <= execution$reg_r7;
        endcase
    end
    assign signal_cat_59 = { gnd,
                             signal_mux_761 };
    always @* begin
        case (signal_select_354)
        0:
            signal_mux_762 <= execution$reg_r0;
        1:
            signal_mux_762 <= execution$reg_r1;
        2:
            signal_mux_762 <= execution$reg_r2;
        3:
            signal_mux_762 <= execution$reg_r3;
        4:
            signal_mux_762 <= execution$reg_r4;
        5:
            signal_mux_762 <= execution$reg_r5;
        6:
            signal_mux_762 <= execution$reg_r6;
        default:
            signal_mux_762 <= execution$reg_r7;
        endcase
    end
    assign signal_cat_60 = { gnd,
                             signal_mux_762 };
    assign signal_add_31 = signal_cat_60 + signal_cat_59;
    assign signal_select_311 = signal_add_31[15:0];
    assign signal_select_312 = signal_mux_873[10:8];
    always @* begin
        case (signal_select_312)
        0:
            signal_mux_763 <= signal_select_311;
        1:
            signal_mux_763 <= signal_sub_13;
        2:
            signal_mux_763 <= signal_and_261;
        3:
            signal_mux_763 <= signal_or_143;
        4:
            signal_mux_763 <= signal_xor_3;
        5:
            signal_mux_763 <= signal_const_148;
        6:
            signal_mux_763 <= signal_const_148;
        default:
            signal_mux_763 <= signal_const_148;
        endcase
    end
    assign signal_xor_4 = signal_mux_774 ^ signal_mux_773;
    assign signal_or_144 = signal_mux_774 | signal_mux_773;
    assign signal_and_262 = signal_mux_774 & signal_mux_773;
    assign signal_sub_14 = signal_mux_774 - signal_mux_773;
    assign signal_wire_159 = prog_mem_read_data_i;
    assign signal_mux_764 = signal_and_325 ? signal_const_148 : execution$reg_extension_word;
    assign signal_not_202 = ~ signal_wire_195;
    assign signal_and_263 = signal_wire_197 & signal_reg_29;
    assign signal_and_264 = signal_and_263 & signal_not_202;
    assign signal_and_265 = signal_eq_223 & signal_and_264;
    assign signal_mux_765 = signal_and_265 ? signal_wire_159 : signal_mux_764;
    assign signal_mux_766 = signal_or_192 ? execution$reg_extension_word : signal_mux_765;
    assign signal_mux_767 = signal_and_328 ? execution$reg_extension_word : signal_mux_766;
    assign signal_mux_768 = signal_not_221 ? execution$reg_extension_word : signal_mux_767;
    assign signal_mux_769 = signal_wire_195 ? signal_const_148 : signal_mux_768;
    assign signal_wire_160 = signal_mux_769;
    always @(posedge signal_wire_167) begin
        execution$reg_extension_word <= signal_wire_160;
    end
    assign signal_eq_223 = execution$reg_phase == signal_const_119;
    assign signal_mux_770 = signal_eq_223 ? signal_wire_159 : execution$reg_extension_word;
    assign signal_select_313 = signal_mux_873[5:0];
    assign signal_cat_61 = { signal_const_309,
                             signal_select_313 };
    assign signal_select_314 = signal_mux_873[9:0];
    assign signal_cat_62 = { signal_const_58,
                             signal_select_314 };
    assign signal_select_315 = signal_mux_873[3:0];
    assign signal_const_897 = 12'b000000000000;
    assign signal_cat_63 = { signal_const_897,
                             signal_select_315 };
    assign signal_select_316 = signal_mux_873[4:0];
    assign signal_cat_64 = { signal_const_330,
                             signal_select_316 };
    assign signal_select_317 = signal_mux_873[9:0];
    assign signal_cat_65 = { signal_const_58,
                             signal_select_317 };
    assign signal_select_318 = signal_mux_873[6:0];
    assign signal_cat_66 = { signal_const_215,
                             signal_select_318 };
    assign signal_select_319 = signal_mux_873[3:0];
    assign signal_cat_67 = { signal_const_897,
                             signal_select_319 };
    assign signal_select_320 = signal_mux_873[6:0];
    assign signal_cat_68 = { signal_const_215,
                             signal_select_320 };
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_771 <= signal_const_148;
        1:
            signal_mux_771 <= signal_cat_68;
        2:
            signal_mux_771 <= signal_const_148;
        3:
            signal_mux_771 <= signal_const_148;
        4:
            signal_mux_771 <= signal_cat_67;
        5:
            signal_mux_771 <= signal_const_148;
        6:
            signal_mux_771 <= signal_cat_66;
        7:
            signal_mux_771 <= signal_const_148;
        8:
            signal_mux_771 <= signal_const_148;
        9:
            signal_mux_771 <= signal_const_148;
        10:
            signal_mux_771 <= signal_const_148;
        11:
            signal_mux_771 <= signal_const_148;
        12:
            signal_mux_771 <= signal_const_148;
        13:
            signal_mux_771 <= signal_const_148;
        14:
            signal_mux_771 <= signal_const_148;
        15:
            signal_mux_771 <= signal_const_148;
        16:
            signal_mux_771 <= signal_const_148;
        17:
            signal_mux_771 <= signal_cat_65;
        18:
            signal_mux_771 <= signal_const_148;
        19:
            signal_mux_771 <= signal_cat_64;
        20:
            signal_mux_771 <= signal_cat_63;
        21:
            signal_mux_771 <= signal_cat_62;
        22:
            signal_mux_771 <= signal_const_148;
        23:
            signal_mux_771 <= signal_cat_61;
        24:
            signal_mux_771 <= signal_const_148;
        25:
            signal_mux_771 <= signal_const_148;
        26:
            signal_mux_771 <= signal_const_148;
        27:
            signal_mux_771 <= signal_const_148;
        28:
            signal_mux_771 <= signal_const_148;
        29:
            signal_mux_771 <= signal_const_148;
        30:
            signal_mux_771 <= signal_const_148;
        default:
            signal_mux_771 <= signal_const_148;
        endcase
    end
    assign signal_select_321 = signal_mux_873[6:6];
    assign signal_select_322 = signal_mux_873[10:10];
    assign signal_select_323 = signal_mux_873[4:4];
    assign signal_select_324 = signal_mux_873[5:5];
    assign signal_select_325 = signal_mux_873[10:10];
    assign vdd = 1'b1;
    assign signal_select_326 = signal_mux_873[7:7];
    assign signal_select_327 = signal_mux_873[4:4];
    assign signal_select_328 = signal_mux_873[7:7];
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_772 <= gnd;
        1:
            signal_mux_772 <= signal_select_328;
        2:
            signal_mux_772 <= gnd;
        3:
            signal_mux_772 <= gnd;
        4:
            signal_mux_772 <= signal_select_327;
        5:
            signal_mux_772 <= gnd;
        6:
            signal_mux_772 <= signal_select_326;
        7:
            signal_mux_772 <= gnd;
        8:
            signal_mux_772 <= gnd;
        9:
            signal_mux_772 <= gnd;
        10:
            signal_mux_772 <= gnd;
        11:
            signal_mux_772 <= gnd;
        12:
            signal_mux_772 <= gnd;
        13:
            signal_mux_772 <= gnd;
        14:
            signal_mux_772 <= gnd;
        15:
            signal_mux_772 <= vdd;
        16:
            signal_mux_772 <= gnd;
        17:
            signal_mux_772 <= signal_select_325;
        18:
            signal_mux_772 <= gnd;
        19:
            signal_mux_772 <= signal_select_324;
        20:
            signal_mux_772 <= signal_select_323;
        21:
            signal_mux_772 <= signal_select_322;
        22:
            signal_mux_772 <= gnd;
        23:
            signal_mux_772 <= signal_select_321;
        24:
            signal_mux_772 <= gnd;
        25:
            signal_mux_772 <= gnd;
        26:
            signal_mux_772 <= gnd;
        27:
            signal_mux_772 <= gnd;
        28:
            signal_mux_772 <= gnd;
        29:
            signal_mux_772 <= gnd;
        30:
            signal_mux_772 <= gnd;
        default:
            signal_mux_772 <= gnd;
        endcase
    end
    assign signal_mux_773 = signal_mux_772 ? signal_mux_770 : signal_mux_771;
    assign signal_cat_69 = { gnd,
                             signal_mux_773 };
    always @* begin
        case (signal_select_355)
        0:
            signal_mux_774 <= execution$reg_r0;
        1:
            signal_mux_774 <= execution$reg_r1;
        2:
            signal_mux_774 <= execution$reg_r2;
        3:
            signal_mux_774 <= execution$reg_r3;
        4:
            signal_mux_774 <= execution$reg_r4;
        5:
            signal_mux_774 <= execution$reg_r5;
        6:
            signal_mux_774 <= execution$reg_r6;
        default:
            signal_mux_774 <= execution$reg_r7;
        endcase
    end
    assign gnd = 1'b0;
    assign signal_cat_70 = { gnd,
                             signal_mux_774 };
    assign signal_add_32 = signal_cat_70 + signal_cat_69;
    assign signal_select_329 = signal_add_32[15:0];
    assign signal_select_330 = signal_mux_873[10:8];
    always @* begin
        case (signal_select_330)
        0:
            signal_mux_775 <= signal_select_329;
        1:
            signal_mux_775 <= signal_sub_14;
        2:
            signal_mux_775 <= signal_and_262;
        3:
            signal_mux_775 <= signal_or_144;
        4:
            signal_mux_775 <= signal_xor_4;
        5:
            signal_mux_775 <= signal_const_148;
        6:
            signal_mux_775 <= signal_const_148;
        default:
            signal_mux_775 <= signal_const_148;
        endcase
    end
    assign signal_select_331 = signal_mux_778[15:8];
    assign signal_cat_71 = { signal_const_43,
                             signal_select_331 };
    assign signal_select_332 = signal_mux_777[15:4];
    assign signal_cat_72 = { signal_const_140,
                             signal_select_332 };
    assign signal_select_333 = signal_mux_776[15:2];
    assign signal_cat_73 = { signal_const_276,
                             signal_select_333 };
    assign signal_select_334 = signal_mux_780[15:1];
    assign signal_cat_74 = { signal_const_37,
                             signal_select_334 };
    assign signal_select_335 = signal_select_346[0:0];
    assign signal_mux_776 = signal_select_335 ? signal_cat_74 : signal_mux_780;
    assign signal_select_336 = signal_select_346[1:1];
    assign signal_mux_777 = signal_select_336 ? signal_cat_73 : signal_mux_776;
    assign signal_select_337 = signal_select_346[2:2];
    assign signal_mux_778 = signal_select_337 ? signal_cat_72 : signal_mux_777;
    assign signal_select_338 = signal_select_346[3:3];
    assign signal_mux_779 = signal_select_338 ? signal_cat_71 : signal_mux_778;
    assign signal_select_339 = signal_mux_783[7:0];
    assign signal_cat_75 = { signal_select_339,
                             signal_const_43 };
    assign signal_select_340 = signal_mux_782[11:0];
    assign signal_cat_76 = { signal_select_340,
                             signal_const_140 };
    assign signal_select_341 = signal_mux_781[13:0];
    assign signal_cat_77 = { signal_select_341,
                             signal_const_276 };
    assign signal_select_342 = signal_mux_780[14:0];
    assign signal_cat_78 = { signal_select_342,
                             signal_const_37 };
    always @* begin
        case (signal_select_356)
        0:
            signal_mux_780 <= execution$reg_r0;
        1:
            signal_mux_780 <= execution$reg_r1;
        2:
            signal_mux_780 <= execution$reg_r2;
        3:
            signal_mux_780 <= execution$reg_r3;
        4:
            signal_mux_780 <= execution$reg_r4;
        5:
            signal_mux_780 <= execution$reg_r5;
        6:
            signal_mux_780 <= execution$reg_r6;
        default:
            signal_mux_780 <= execution$reg_r7;
        endcase
    end
    assign signal_select_343 = signal_select_346[0:0];
    assign signal_mux_781 = signal_select_343 ? signal_cat_78 : signal_mux_780;
    assign signal_select_344 = signal_select_346[1:1];
    assign signal_mux_782 = signal_select_344 ? signal_cat_77 : signal_mux_781;
    assign signal_select_345 = signal_select_346[2:2];
    assign signal_mux_783 = signal_select_345 ? signal_cat_76 : signal_mux_782;
    assign signal_select_346 = signal_mux_873[6:3];
    assign signal_select_347 = signal_select_346[3:3];
    assign signal_mux_784 = signal_select_347 ? signal_cat_75 : signal_mux_783;
    assign signal_select_348 = signal_mux_873[10:10];
    assign signal_mux_785 = signal_select_348 ? signal_mux_779 : signal_mux_784;
    assign signal_eq_224 = signal_mux_851 == signal_const_600;
    assign signal_mux_786 = signal_eq_224 ? signal_mux_842 : signal_mux_787;
    assign signal_mux_787 = signal_and_325 ? signal_const_148 : execution$reg_r7;
    assign signal_mux_788 = signal_or_153 ? signal_mux_786 : signal_mux_787;
    assign signal_mux_789 = signal_or_192 ? execution$reg_r7 : signal_mux_788;
    assign signal_mux_790 = signal_and_328 ? execution$reg_r7 : signal_mux_789;
    assign signal_mux_791 = signal_not_221 ? execution$reg_r7 : signal_mux_790;
    assign signal_mux_792 = signal_wire_195 ? signal_const_148 : signal_mux_791;
    assign signal_wire_161 = signal_mux_792;
    always @(posedge signal_wire_167) begin
        execution$reg_r7 <= signal_wire_161;
    end
    assign signal_eq_225 = signal_mux_851 == signal_const_174;
    assign signal_mux_793 = signal_eq_225 ? signal_mux_842 : signal_mux_794;
    assign signal_mux_794 = signal_and_325 ? signal_const_148 : execution$reg_r6;
    assign signal_mux_795 = signal_or_153 ? signal_mux_793 : signal_mux_794;
    assign signal_mux_796 = signal_or_192 ? execution$reg_r6 : signal_mux_795;
    assign signal_mux_797 = signal_and_328 ? execution$reg_r6 : signal_mux_796;
    assign signal_mux_798 = signal_not_221 ? execution$reg_r6 : signal_mux_797;
    assign signal_mux_799 = signal_wire_195 ? signal_const_148 : signal_mux_798;
    assign signal_wire_162 = signal_mux_799;
    always @(posedge signal_wire_167) begin
        execution$reg_r6 <= signal_wire_162;
    end
    assign signal_eq_226 = signal_mux_851 == signal_const_121;
    assign signal_mux_800 = signal_eq_226 ? signal_mux_842 : signal_mux_801;
    assign signal_mux_801 = signal_and_325 ? signal_const_148 : execution$reg_r5;
    assign signal_mux_802 = signal_or_153 ? signal_mux_800 : signal_mux_801;
    assign signal_mux_803 = signal_or_192 ? execution$reg_r5 : signal_mux_802;
    assign signal_mux_804 = signal_and_328 ? execution$reg_r5 : signal_mux_803;
    assign signal_mux_805 = signal_not_221 ? execution$reg_r5 : signal_mux_804;
    assign signal_mux_806 = signal_wire_195 ? signal_const_148 : signal_mux_805;
    assign signal_wire_163 = signal_mux_806;
    always @(posedge signal_wire_167) begin
        execution$reg_r5 <= signal_wire_163;
    end
    assign signal_eq_227 = signal_mux_851 == signal_const_120;
    assign signal_mux_807 = signal_eq_227 ? signal_mux_842 : signal_mux_808;
    assign signal_mux_808 = signal_and_325 ? signal_const_148 : execution$reg_r4;
    assign signal_mux_809 = signal_or_153 ? signal_mux_807 : signal_mux_808;
    assign signal_mux_810 = signal_or_192 ? execution$reg_r4 : signal_mux_809;
    assign signal_mux_811 = signal_and_328 ? execution$reg_r4 : signal_mux_810;
    assign signal_mux_812 = signal_not_221 ? execution$reg_r4 : signal_mux_811;
    assign signal_mux_813 = signal_wire_195 ? signal_const_148 : signal_mux_812;
    assign signal_wire_164 = signal_mux_813;
    always @(posedge signal_wire_167) begin
        execution$reg_r4 <= signal_wire_164;
    end
    assign signal_eq_228 = signal_mux_851 == signal_const_119;
    assign signal_mux_814 = signal_eq_228 ? signal_mux_842 : signal_mux_815;
    assign signal_mux_815 = signal_and_325 ? signal_const_148 : execution$reg_r3;
    assign signal_mux_816 = signal_or_153 ? signal_mux_814 : signal_mux_815;
    assign signal_mux_817 = signal_or_192 ? execution$reg_r3 : signal_mux_816;
    assign signal_mux_818 = signal_and_328 ? execution$reg_r3 : signal_mux_817;
    assign signal_mux_819 = signal_not_221 ? execution$reg_r3 : signal_mux_818;
    assign signal_mux_820 = signal_wire_195 ? signal_const_148 : signal_mux_819;
    assign signal_wire_165 = signal_mux_820;
    always @(posedge signal_wire_167) begin
        execution$reg_r3 <= signal_wire_165;
    end
    assign signal_eq_229 = signal_mux_851 == signal_const_118;
    assign signal_mux_821 = signal_eq_229 ? signal_mux_842 : signal_mux_822;
    assign signal_mux_822 = signal_and_325 ? signal_const_148 : execution$reg_r2;
    assign signal_mux_823 = signal_or_153 ? signal_mux_821 : signal_mux_822;
    assign signal_mux_824 = signal_or_192 ? execution$reg_r2 : signal_mux_823;
    assign signal_mux_825 = signal_and_328 ? execution$reg_r2 : signal_mux_824;
    assign signal_mux_826 = signal_not_221 ? execution$reg_r2 : signal_mux_825;
    assign signal_mux_827 = signal_wire_195 ? signal_const_148 : signal_mux_826;
    assign signal_wire_166 = signal_mux_827;
    always @(posedge signal_wire_167) begin
        execution$reg_r2 <= signal_wire_166;
    end
    assign signal_wire_167 = clock_i;
    assign signal_eq_230 = signal_mux_851 == signal_const_117;
    assign signal_mux_828 = signal_eq_230 ? signal_mux_842 : signal_mux_829;
    assign signal_mux_829 = signal_and_325 ? signal_const_148 : execution$reg_r1;
    assign signal_mux_830 = signal_or_153 ? signal_mux_828 : signal_mux_829;
    assign signal_mux_831 = signal_or_192 ? execution$reg_r1 : signal_mux_830;
    assign signal_mux_832 = signal_and_328 ? execution$reg_r1 : signal_mux_831;
    assign signal_mux_833 = signal_not_221 ? execution$reg_r1 : signal_mux_832;
    assign signal_mux_834 = signal_wire_195 ? signal_const_148 : signal_mux_833;
    assign signal_wire_168 = signal_mux_834;
    always @(posedge signal_wire_167) begin
        execution$reg_r1 <= signal_wire_168;
    end
    always @* begin
        case (signal_select_357)
        0:
            signal_mux_835 <= execution$reg_r0;
        1:
            signal_mux_835 <= execution$reg_r1;
        2:
            signal_mux_835 <= execution$reg_r2;
        3:
            signal_mux_835 <= execution$reg_r3;
        4:
            signal_mux_835 <= execution$reg_r4;
        5:
            signal_mux_835 <= execution$reg_r5;
        6:
            signal_mux_835 <= execution$reg_r6;
        default:
            signal_mux_835 <= execution$reg_r7;
        endcase
    end
    assign signal_sub_15 = signal_mux_835 - signal_const_514;
    assign signal_add_33 = execution$reg_pc + signal_const_167;
    assign signal_select_349 = signal_add_33[15:0];
    assign signal_eq_231 = signal_select_365 == signal_const_296;
    assign signal_mux_836 = signal_eq_231 ? signal_sub_15 : signal_select_349;
    assign signal_eq_232 = signal_select_365 == signal_const_299;
    assign signal_mux_837 = signal_eq_232 ? signal_mux_785 : signal_mux_836;
    assign signal_eq_233 = signal_select_365 == signal_const_302;
    assign signal_mux_838 = signal_eq_233 ? signal_mux_775 : signal_mux_837;
    assign signal_eq_234 = signal_select_365 == signal_const_303;
    assign signal_mux_839 = signal_eq_234 ? signal_mux_763 : signal_mux_838;
    assign signal_eq_235 = signal_select_365 == signal_const_304;
    assign signal_mux_840 = signal_eq_235 ? signal_mux_760 : signal_mux_839;
    assign signal_eq_236 = signal_select_365 == signal_const_305;
    assign signal_mux_841 = signal_eq_236 ? signal_mux_773 : signal_mux_840;
    assign signal_mux_842 = signal_and_266 ? signal_wire_158 : signal_mux_841;
    assign signal_select_350 = signal_mux_873[10:8];
    assign signal_select_351 = signal_mux_873[10:8];
    assign signal_select_352 = signal_mux_873[8:6];
    assign signal_const_949 = 5'b01001;
    assign signal_eq_237 = signal_select_365 == signal_const_949;
    assign signal_mux_843 = signal_eq_237 ? signal_select_351 : signal_select_352;
    assign signal_eq_238 = signal_select_365 == signal_const_807;
    assign signal_mux_844 = signal_eq_238 ? signal_select_350 : signal_mux_843;
    assign signal_select_353 = signal_mux_873[10:8];
    assign signal_select_354 = signal_mux_873[7:5];
    assign signal_select_355 = signal_mux_873[7:5];
    assign signal_select_356 = signal_mux_873[9:7];
    assign signal_select_357 = signal_mux_873[10:8];
    assign signal_select_358 = signal_mux_873[10:8];
    assign signal_select_359 = signal_mux_873[10:8];
    assign signal_eq_239 = signal_select_365 == signal_const_295;
    assign signal_mux_845 = signal_eq_239 ? signal_select_358 : signal_select_359;
    assign signal_eq_240 = signal_select_365 == signal_const_296;
    assign signal_mux_846 = signal_eq_240 ? signal_select_357 : signal_mux_845;
    assign signal_eq_241 = signal_select_365 == signal_const_299;
    assign signal_mux_847 = signal_eq_241 ? signal_select_356 : signal_mux_846;
    assign signal_eq_242 = signal_select_365 == signal_const_302;
    assign signal_mux_848 = signal_eq_242 ? signal_select_355 : signal_mux_847;
    assign signal_eq_243 = signal_select_365 == signal_const_303;
    assign signal_mux_849 = signal_eq_243 ? signal_select_354 : signal_mux_848;
    assign signal_eq_244 = signal_select_365 == signal_const_304;
    assign signal_mux_850 = signal_eq_244 ? signal_select_353 : signal_mux_849;
    assign signal_mux_851 = signal_and_266 ? signal_mux_844 : signal_mux_850;
    assign signal_eq_245 = signal_mux_851 == signal_const_4;
    assign signal_mux_852 = signal_eq_245 ? signal_mux_842 : signal_mux_853;
    assign signal_mux_853 = signal_and_325 ? signal_const_148 : execution$reg_r0;
    assign signal_const_958 = 5'b11010;
    assign signal_eq_246 = signal_select_365 == signal_const_958;
    assign signal_eq_247 = signal_select_365 == signal_const_949;
    assign signal_eq_248 = signal_select_365 == signal_const_807;
    assign signal_or_145 = signal_eq_248 | signal_eq_247;
    assign signal_or_146 = signal_or_145 | signal_eq_246;
    assign signal_and_266 = signal_and_280 & signal_or_146;
    assign signal_eq_249 = signal_select_365 == signal_const_295;
    assign signal_eq_250 = signal_select_365 == signal_const_296;
    assign signal_eq_251 = signal_select_365 == signal_const_299;
    assign signal_eq_252 = signal_select_365 == signal_const_302;
    assign signal_eq_253 = signal_select_365 == signal_const_303;
    assign signal_eq_254 = signal_select_365 == signal_const_304;
    assign signal_eq_255 = signal_select_365 == signal_const_305;
    assign signal_or_147 = signal_eq_255 | signal_eq_254;
    assign signal_or_148 = signal_or_147 | signal_eq_253;
    assign signal_or_149 = signal_or_148 | signal_eq_252;
    assign signal_or_150 = signal_or_149 | signal_eq_251;
    assign signal_or_151 = signal_or_150 | signal_eq_250;
    assign signal_or_152 = signal_or_151 | signal_eq_249;
    assign signal_and_267 = signal_and_333 & signal_or_152;
    assign signal_or_153 = signal_and_267 | signal_and_266;
    assign signal_mux_854 = signal_or_153 ? signal_mux_852 : signal_mux_853;
    assign signal_mux_855 = signal_or_192 ? execution$reg_r0 : signal_mux_854;
    assign signal_mux_856 = signal_and_328 ? execution$reg_r0 : signal_mux_855;
    assign signal_mux_857 = signal_not_221 ? execution$reg_r0 : signal_mux_856;
    assign signal_mux_858 = signal_wire_195 ? signal_const_148 : signal_mux_857;
    assign signal_wire_169 = signal_mux_858;
    always @(posedge signal_wire_167) begin
        execution$reg_r0 <= signal_wire_169;
    end
    assign signal_select_360 = signal_mux_873[9:7];
    always @* begin
        case (signal_select_360)
        0:
            signal_mux_859 <= execution$reg_r0;
        1:
            signal_mux_859 <= execution$reg_r1;
        2:
            signal_mux_859 <= execution$reg_r2;
        3:
            signal_mux_859 <= execution$reg_r3;
        4:
            signal_mux_859 <= execution$reg_r4;
        5:
            signal_mux_859 <= execution$reg_r5;
        6:
            signal_mux_859 <= execution$reg_r6;
        default:
            signal_mux_859 <= execution$reg_r7;
        endcase
    end
    assign signal_select_361 = signal_mux_873[9:2];
    assign signal_cat_79 = { signal_const_43,
                             signal_select_361 };
    assign signal_select_362 = signal_mux_873[7:7];
    assign signal_cat_80 = { signal_const_406,
                             signal_select_362 };
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_860 <= signal_const_148;
        1:
            signal_mux_860 <= signal_const_148;
        2:
            signal_mux_860 <= signal_const_148;
        3:
            signal_mux_860 <= signal_const_148;
        4:
            signal_mux_860 <= signal_const_148;
        5:
            signal_mux_860 <= signal_const_148;
        6:
            signal_mux_860 <= signal_const_148;
        7:
            signal_mux_860 <= signal_const_148;
        8:
            signal_mux_860 <= signal_const_148;
        9:
            signal_mux_860 <= signal_const_148;
        10:
            signal_mux_860 <= signal_const_148;
        11:
            signal_mux_860 <= signal_const_148;
        12:
            signal_mux_860 <= signal_const_148;
        13:
            signal_mux_860 <= signal_cat_80;
        14:
            signal_mux_860 <= signal_const_148;
        15:
            signal_mux_860 <= signal_cat_79;
        16:
            signal_mux_860 <= signal_mux_859;
        17:
            signal_mux_860 <= signal_const_148;
        18:
            signal_mux_860 <= signal_const_148;
        19:
            signal_mux_860 <= signal_cat_31;
        20:
            signal_mux_860 <= signal_cat_30;
        21:
            signal_mux_860 <= signal_const_148;
        22:
            signal_mux_860 <= signal_const_148;
        23:
            signal_mux_860 <= signal_const_148;
        24:
            signal_mux_860 <= signal_const_148;
        25:
            signal_mux_860 <= signal_cat_29;
        26:
            signal_mux_860 <= signal_cat_28;
        27:
            signal_mux_860 <= signal_const_148;
        28:
            signal_mux_860 <= signal_const_148;
        29:
            signal_mux_860 <= signal_const_148;
        30:
            signal_mux_860 <= signal_const_148;
        default:
            signal_mux_860 <= signal_const_148;
        endcase
    end
    assign signal_wire_170 = signal_mux_860;
    assign signal_select_363 = signal_wire_170[15:8];
    assign signal_eq_256 = signal_select_363 == signal_const_43;
    assign signal_eq_257 = signal_wire_171 == signal_const_139;
    assign signal_and_268 = signal_and_287 & signal_eq_257;
    assign signal_eq_258 = signal_wire_171 == signal_const_137;
    assign signal_and_269 = signal_and_287 & signal_eq_258;
    assign signal_or_154 = signal_and_269 | signal_and_268;
    assign signal_and_270 = signal_or_154 & signal_eq_256;
    assign signal_and_271 = signal_and_270 & signal_not_115;
    assign signal_and_272 = signal_and_271 & signal_not_114;
    assign signal_eq_259 = signal_wire_171 == signal_const_138;
    assign signal_and_273 = signal_and_287 & signal_eq_259;
    assign signal_eq_260 = signal_wire_171 == signal_const_135;
    assign signal_and_274 = signal_and_287 & signal_eq_260;
    assign signal_eq_261 = signal_wire_171 == signal_const_136;
    assign signal_and_275 = signal_and_287 & signal_eq_261;
    always @* begin
        case (signal_select_365)
        0:
            signal_mux_861 <= signal_const_140;
        1:
            signal_mux_861 <= signal_const_140;
        2:
            signal_mux_861 <= signal_const_140;
        3:
            signal_mux_861 <= signal_const_140;
        4:
            signal_mux_861 <= signal_const_140;
        5:
            signal_mux_861 <= signal_const_140;
        6:
            signal_mux_861 <= signal_const_140;
        7:
            signal_mux_861 <= signal_const_140;
        8:
            signal_mux_861 <= signal_const_140;
        9:
            signal_mux_861 <= signal_const_136;
        10:
            signal_mux_861 <= signal_const_135;
        11:
            signal_mux_861 <= signal_const_140;
        12:
            signal_mux_861 <= signal_const_140;
        13:
            signal_mux_861 <= signal_const_138;
        14:
            signal_mux_861 <= signal_const_140;
        15:
            signal_mux_861 <= signal_const_137;
        16:
            signal_mux_861 <= signal_const_139;
        17:
            signal_mux_861 <= signal_const_134;
        18:
            signal_mux_861 <= signal_const_133;
        19:
            signal_mux_861 <= signal_const_132;
        20:
            signal_mux_861 <= signal_const_131;
        21:
            signal_mux_861 <= signal_const_703;
        22:
            signal_mux_861 <= signal_const_701;
        23:
            signal_mux_861 <= signal_const_140;
        24:
            signal_mux_861 <= signal_const_680;
        25:
            signal_mux_861 <= signal_const_879;
        26:
            signal_mux_861 <= signal_const_820;
        27:
            signal_mux_861 <= signal_const_140;
        28:
            signal_mux_861 <= signal_const_140;
        29:
            signal_mux_861 <= signal_const_140;
        30:
            signal_mux_861 <= signal_const_140;
        default:
            signal_mux_861 <= signal_const_140;
        endcase
    end
    assign signal_wire_171 = signal_mux_861;
    assign signal_eq_262 = signal_wire_171 == signal_const_140;
    assign signal_and_276 = signal_and_287 & signal_eq_262;
    assign signal_or_155 = signal_and_276 | signal_and_275;
    assign signal_or_156 = signal_or_155 | signal_and_274;
    assign signal_or_157 = signal_or_156 | signal_and_273;
    assign signal_or_158 = signal_or_157 | signal_and_272;
    assign signal_or_159 = signal_or_158 | signal_and_121;
    assign signal_or_160 = signal_or_159 | signal_and_120;
    assign signal_or_161 = signal_or_160 | signal_and_191;
    assign signal_or_162 = signal_or_161 | signal_and_183;
    assign signal_or_163 = signal_or_162 | signal_or_66;
    assign signal_or_164 = signal_or_163 | signal_and_291;
    assign signal_or_165 = signal_or_164 | signal_and_257;
    assign signal_wire_172 = signal_or_165;
    assign signal_and_277 = signal_and_284 & signal_wire_172;
    assign signal_and_278 = signal_and_277 & signal_not_112;
    assign signal_and_279 = signal_and_278 & signal_wire_65;
    assign signal_or_166 = signal_and_279 | signal_and_108;
    assign signal_and_280 = signal_or_166 & signal_not_94;
    assign signal_mux_862 = signal_and_280 ? signal_mux_360 : signal_mux_406;
    assign signal_mux_863 = signal_or_192 ? execution$reg_pc : signal_mux_862;
    assign signal_mux_864 = signal_and_328 ? execution$reg_pc : signal_mux_863;
    assign signal_mux_865 = signal_not_221 ? execution$reg_pc : signal_mux_864;
    assign signal_mux_866 = signal_wire_195 ? signal_const_128 : signal_mux_865;
    assign signal_wire_173 = signal_mux_866;
    always @(posedge signal_wire_167) begin
        execution$reg_pc <= signal_wire_173;
    end
    assign signal_select_364 = execution$reg_pc[16:9];
    assign signal_eq_263 = signal_select_364 == signal_const_43;
    assign signal_eq_264 = execution$reg_phase == signal_const_117;
    assign signal_and_281 = signal_eq_264 & signal_eq_263;
    assign signal_or_167 = signal_and_281 | signal_and_100;
    assign signal_and_282 = signal_or_167 & signal_and_337;
    assign signal_mux_867 = signal_and_282 ? signal_mux_350 : signal_mux_351;
    assign signal_mux_868 = signal_and_329 ? signal_wire_159 : signal_mux_867;
    assign signal_mux_869 = signal_or_192 ? execution$reg_base_word : signal_mux_868;
    assign signal_mux_870 = signal_and_328 ? execution$reg_base_word : signal_mux_869;
    assign signal_mux_871 = signal_not_221 ? execution$reg_base_word : signal_mux_870;
    assign signal_mux_872 = signal_wire_195 ? signal_const_148 : signal_mux_871;
    assign signal_wire_174 = signal_mux_872;
    always @(posedge signal_wire_167) begin
        execution$reg_base_word <= signal_wire_174;
    end
    assign signal_mux_873 = signal_eq_266 ? signal_wire_159 : execution$reg_base_word;
    assign signal_select_365 = signal_mux_873[15:11];
    assign signal_eq_265 = signal_select_365 == signal_const_116;
    assign signal_or_168 = signal_eq_265 | signal_eq_34;
    assign signal_or_169 = signal_or_168 | signal_eq_33;
    assign signal_or_170 = signal_or_169 | signal_eq_32;
    assign signal_or_171 = signal_or_170 | signal_eq_31;
    assign signal_or_172 = signal_or_171 | signal_eq_30;
    assign signal_or_173 = signal_or_172 | signal_eq_29;
    assign signal_or_174 = signal_or_173 | signal_eq_28;
    assign signal_or_175 = signal_or_174 | signal_eq_27;
    assign signal_or_176 = signal_or_175 | signal_eq_26;
    assign signal_or_177 = signal_or_176 | signal_eq_25;
    assign signal_or_178 = signal_or_177 | signal_eq_24;
    assign signal_or_179 = signal_or_178 | signal_eq_23;
    assign signal_or_180 = signal_or_179 | signal_eq_22;
    assign signal_not_203 = ~ signal_or_180;
    assign signal_and_283 = signal_or_193 & signal_not_203;
    assign signal_or_181 = signal_and_283 | signal_eq_21;
    assign signal_and_284 = signal_or_181 & signal_and_106;
    assign signal_wire_175 = signal_and_284;
    assign signal_and_285 = signal_wire_175 & signal_wire_197;
    assign signal_and_286 = signal_and_285 & signal_not_73;
    assign signal_and_287 = signal_and_286 & signal_not_72;
    assign signal_and_288 = signal_and_287 & signal_eq_20;
    assign signal_or_182 = signal_and_288 | signal_and_91;
    assign signal_or_183 = signal_or_182 | signal_and_202;
    assign signal_or_184 = signal_or_183 | signal_and_200;
    assign signal_and_289 = signal_or_184 & signal_and_118;
    assign signal_and_290 = signal_and_289 & signal_wire_66;
    assign signal_and_291 = signal_and_290 & signal_not_71;
    assign signal_mux_874 = signal_and_291 ? signal_mux_349 : mechanisms$timing$reg_busy;
    assign signal_mux_875 = mechanisms$timing$reg_busy ? signal_mux_347 : signal_mux_874;
    assign signal_mux_876 = signal_or_185 ? signal_const_37 : signal_mux_875;
    assign signal_wire_176 = signal_mux_876;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_busy <= signal_const_37;
        else
            mechanisms$timing$reg_busy <= signal_wire_176;
    end
    assign signal_mux_877 = mechanisms$timing$reg_busy ? signal_mux_345 : signal_const_37;
    assign signal_not_204 = ~ signal_wire_197;
    assign signal_or_185 = signal_not_204 | signal_and_328;
    assign signal_mux_878 = signal_or_185 ? signal_const_37 : signal_mux_877;
    assign signal_wire_177 = signal_mux_878;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$timing$reg_complete <= signal_const_37;
        else
            mechanisms$timing$reg_complete <= signal_wire_177;
    end
    assign signal_wire_178 = mechanisms$timing$reg_complete;
    assign signal_or_186 = signal_wire_178 | signal_wire_129;
    assign signal_and_292 = mechanisms$reg_wait_pending & signal_or_186;
    assign signal_and_293 = signal_and_292 & signal_wire_197;
    assign signal_and_294 = signal_and_293 & signal_not_70;
    assign signal_and_295 = signal_and_294 & signal_not_69;
    assign signal_mux_879 = signal_and_295 ? signal_const_37 : signal_mux_342;
    assign signal_not_205 = ~ signal_wire_197;
    assign signal_or_187 = signal_and_328 | signal_not_205;
    assign signal_mux_880 = signal_or_187 ? signal_const_37 : signal_mux_879;
    assign signal_wire_179 = signal_mux_880;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            mechanisms$reg_wait_pending <= signal_const_37;
        else
            mechanisms$reg_wait_pending <= signal_wire_179;
    end
    assign signal_not_206 = ~ mechanisms$reg_wait_pending;
    assign signal_and_296 = signal_not_206 & signal_not_68;
    assign signal_and_297 = signal_and_296 & signal_not_67;
    assign signal_and_298 = signal_and_297 & signal_eq_18;
    assign signal_and_299 = signal_and_298 & signal_not_66;
    assign signal_and_300 = signal_and_299 & signal_not_65;
    assign signal_and_301 = signal_and_300 & signal_eq_17;
    assign signal_and_302 = signal_and_301 & signal_not_64;
    assign signal_wire_180 = signal_and_302;
    assign signal_not_207 = ~ signal_and_313;
    assign signal_not_208 = ~ signal_and_328;
    assign signal_not_209 = ~ signal_wire_195;
    assign signal_and_303 = signal_wire_181 & signal_wire_197;
    assign signal_and_304 = signal_and_303 & signal_not_209;
    assign signal_and_305 = signal_and_304 & signal_not_208;
    assign signal_and_306 = signal_and_305 & signal_not_207;
    assign signal_and_307 = signal_and_306 & signal_not_226;
    assign signal_and_308 = signal_and_307 & signal_wire_180;
    assign signal_and_309 = signal_and_308 & signal_not_63;
    assign signal_and_310 = signal_and_309 & signal_not_53;
    assign signal_wire_181 = step_valid_i;
    assign signal_not_210 = ~ signal_wire_181;
    assign signal_not_211 = ~ signal_and_328;
    assign signal_not_212 = ~ signal_wire_195;
    assign signal_wire_182 = stop_valid_i;
    assign signal_and_311 = signal_wire_182 & signal_wire_197;
    assign signal_and_312 = signal_and_311 & signal_not_212;
    assign signal_and_313 = signal_and_312 & signal_not_211;
    assign signal_not_213 = ~ signal_and_313;
    assign signal_not_214 = ~ signal_and_328;
    assign signal_wire_183 = run_valid_i;
    assign signal_and_314 = signal_wire_183 & signal_not_214;
    assign signal_and_315 = signal_and_314 & signal_not_213;
    assign signal_and_316 = signal_and_315 & signal_not_210;
    assign signal_or_188 = signal_and_316 | signal_and_310;
    assign signal_wire_184 = signal_or_188;
    assign signal_not_215 = ~ signal_wire_193;
    assign signal_wire_185 = load_complete_valid_i;
    assign signal_not_216 = ~ signal_wire_185;
    assign signal_wire_186 = readback_valid_i;
    assign signal_not_217 = ~ signal_wire_186;
    assign signal_wire_187 = load_write_valid_i;
    assign signal_not_218 = ~ signal_wire_187;
    assign signal_wire_188 = load_start_valid_i;
    assign signal_not_219 = ~ signal_wire_188;
    assign signal_and_317 = signal_not_219 & signal_not_218;
    assign signal_and_318 = signal_and_317 & signal_not_217;
    assign signal_and_319 = signal_and_318 & signal_not_216;
    assign signal_and_320 = signal_and_346 & signal_and_319;
    assign signal_and_321 = signal_and_320 & signal_not_215;
    assign signal_and_322 = signal_and_321 & signal_wire_184;
    assign signal_and_323 = signal_and_322 & signal_reg_12;
    assign signal_and_324 = signal_and_323 & signal_not_44;
    assign signal_and_325 = signal_and_324 & signal_and_316;
    assign signal_or_189 = signal_and_325 | signal_and_328;
    assign signal_or_190 = signal_or_189 | signal_not_43;
    assign signal_mux_881 = signal_or_190 ? signal_const_37 : signal_mux_269;
    assign signal_wire_189 = signal_mux_881;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            reg_stop_pending <= signal_const_37;
        else
            reg_stop_pending <= signal_wire_189;
    end
    assign signal_or_191 = reg_stop_pending | signal_and_313;
    assign signal_and_326 = signal_or_191 & signal_wire_42;
    assign signal_or_192 = signal_and_326 | signal_and_48;
    assign signal_mux_882 = signal_or_192 ? signal_const_4 : signal_mux_249;
    assign signal_not_220 = ~ signal_wire_195;
    assign signal_wire_190 = abort_valid_i;
    assign signal_and_327 = signal_wire_190 & signal_wire_197;
    assign signal_and_328 = signal_and_327 & signal_not_220;
    assign signal_mux_883 = signal_and_328 ? signal_const_4 : signal_mux_882;
    assign signal_not_221 = ~ signal_wire_197;
    assign signal_mux_884 = signal_not_221 ? signal_const_4 : signal_mux_883;
    assign signal_mux_885 = signal_wire_195 ? signal_const_4 : signal_mux_884;
    assign signal_wire_191 = signal_mux_885;
    always @(posedge signal_wire_167) begin
        execution$reg_phase <= signal_wire_191;
    end
    assign signal_eq_266 = execution$reg_phase == signal_const_118;
    assign signal_and_329 = signal_eq_266 & signal_and_264;
    assign signal_and_330 = signal_and_329 & signal_and_98;
    assign signal_and_331 = signal_and_330 & signal_not_38;
    assign signal_or_193 = signal_and_331 | signal_and_44;
    assign signal_and_332 = signal_or_193 & signal_or_180;
    assign signal_and_333 = signal_and_332 & signal_not_37;
    assign signal_and_334 = signal_and_333 & signal_eq_5;
    assign signal_or_194 = signal_and_334 | signal_or_26;
    assign signal_wire_192 = signal_or_194;
    assign signal_or_195 = signal_wire_192 | signal_and_328;
    assign signal_or_196 = signal_or_195 | signal_or_192;
    assign signal_wire_193 = signal_or_196;
    assign signal_not_222 = ~ signal_wire_193;
    assign signal_and_335 = signal_and_340 & signal_not_222;
    assign signal_and_336 = signal_and_335 & signal_wire_39;
    assign signal_and_337 = signal_and_336 & signal_and_43;
    assign signal_mux_886 = signal_and_337 ? signal_const_39 : signal_mux_230;
    assign signal_mux_887 = signal_not_225 ? signal_const_37 : signal_mux_886;
    assign signal_wire_194 = signal_mux_887;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_29 <= signal_const_37;
        else
            signal_reg_29 <= signal_wire_194;
    end
    assign signal_not_223 = ~ signal_reg_29;
    assign signal_or_197 = signal_not_223 | signal_and_264;
    assign signal_wire_195 = reset_i;
    assign signal_not_224 = ~ signal_wire_195;
    assign signal_and_338 = signal_wire_197 & signal_reg_30;
    assign signal_and_339 = signal_and_338 & signal_not_224;
    assign signal_and_340 = signal_and_339 & signal_or_197;
    assign signal_and_341 = signal_and_340 & signal_wire_39;
    assign signal_and_342 = signal_and_341 & signal_not_35;
    assign signal_mux_888 = signal_and_342 ? signal_const_37 : signal_mux_227;
    assign signal_not_225 = ~ signal_wire_197;
    assign signal_mux_889 = signal_not_225 ? signal_const_37 : signal_mux_888;
    assign signal_wire_196 = signal_mux_889;
    always @(posedge signal_wire_167) begin
        if (signal_wire_195)
            signal_reg_30 <= signal_const_37;
        else
            signal_reg_30 <= signal_wire_196;
    end
    assign signal_not_226 = ~ signal_reg_30;
    assign signal_wire_197 = en_i;
    assign signal_and_343 = signal_wire_197 & signal_not_226;
    assign signal_and_344 = signal_and_343 & signal_wire_180;
    assign signal_and_345 = signal_and_344 & signal_not_34;
    assign signal_and_346 = signal_and_345 & signal_not_33;
    assign signal_and_347 = signal_and_346 & signal_not_219;
    assign signal_and_348 = signal_and_347 & signal_wire_187;
    assign signal_and_349 = signal_and_348 & signal_reg_11;
    assign signal_and_350 = signal_and_349 & signal_eq_4;
    assign signal_and_351 = signal_and_350 & signal_lt;
    assign signal_or_198 = signal_and_351 | signal_or_18;
    assign signal_and_352 = signal_or_198 & signal_not_32;
    assign prog_mem_enable_o = signal_and_352;
    assign prog_mem_write_enable_o = signal_and_41;
    assign prog_mem_address_o = signal_select_78;
    assign prog_mem_write_data_o = signal_wire_36;
    assign load_start_accepted_o = signal_and_65;
    assign load_start_rejected_o = signal_and_40;
    assign load_write_accepted_o = signal_and_351;
    assign load_write_rejected_o = signal_and_39;
    assign load_complete_accepted_o = signal_and_72;
    assign load_complete_rejected_o = signal_and_38;
    assign readback_accepted_o = signal_and_58;
    assign readback_rejected_o = signal_and_37;
    assign readback_response_valid_o = signal_reg_3;
    assign readback_response_data_o = signal_reg_2;
    assign readback_response_match_o = signal_reg_1;
    assign run_accepted_o = signal_and_325;
    assign run_rejected_o = signal_and_35;
    assign stop_accepted_o = signal_and_313;
    assign stop_rejected_o = signal_and_34;
    assign abort_accepted_o = signal_and_328;
    assign abort_rejected_o = signal_and_33;
    assign step_accepted_o = signal_and_73;
    assign step_rejected_o = signal_and_32;
    assign halted_o = signal_not_226;
    assign engines_idle_o = signal_wire_180;
    assign image_valid_o = signal_reg_12;
    assign load_active_o = signal_reg_11;
    assign image_length_o = signal_reg_9;
    assign words_written_o = signal_reg_10;
    assign words_verified_o = signal_reg_8;
    assign verification_failed_o = signal_reg_6;
    assign fetch_fault_o = signal_reg;
    assign execution_active_o = signal_and_189;
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
    assign descriptor_o = signal_cat_45;
    assign phase_o = execution$reg_phase;
    assign fetch_cycles_o = execution$reg_fetch_cycles;
    assign execute_cycles_o = execution$reg_execute_cycles;
    assign stall_cycles_o = execution$reg_stall_cycles;
    assign instruction_count_o = execution$reg_instruction_count;
    assign extension_fetches_o = execution$reg_extension_fetches;
    assign total_cycles_o = execution$reg_total_cycles;
    assign mechanism_request_valid_o = signal_wire_175;
    assign mechanism_kind_o = signal_wire_171;
    assign mechanism_accepted_o = signal_wire_172;
    assign mechanism_refused_o = signal_wire_67;
    assign mechanism_completion_valid_o = signal_wire_65;
    assign snapshot_o = mechanisms$events$reg_stage1;
    assign rising_o = signal_and_198;
    assign falling_o = signal_and_197;
    assign status_o = mechanisms$events$reg_event;
    assign status_overflow_o = mechanisms$events$reg_overflow;
    assign pins_o = mechanisms$bank$reg_pins;
    assign pin_oe_o = mechanisms$bank$reg_pin_oe;
    assign software_claim_o = mechanisms$bank$reg_software_claim;
    assign engine_claim_o = mechanisms$bank$reg_engine_claim;
    assign software_request_rejected_o = signal_or_7;
    assign bank_conflict_o = mechanisms$bank$reg_conflict;
    assign timing_busy_o = mechanisms$timing$reg_busy;
    assign transfer_busy_o = signal_or_2;
    assign transfer_done_o = mechanisms$lane$reg_done_;
    assign transfer_fault_o = signal_or_78;
    assign transfer_rx_valid_o = mechanisms$lane$reg_rx_valid;
    assign transfer_rx_data_o = mechanisms$lane$reg_rx_data;
    assign tx_valid_o = signal_and_1;
    assign tx_data_o = signal_mux_732;
    assign rx_ready_o = signal_and;
    assign tx_count_o = mechanisms$tx_fifo$reg_count;
    assign rx_count_o = mechanisms$rx_fifo$reg_count;

endmodule
