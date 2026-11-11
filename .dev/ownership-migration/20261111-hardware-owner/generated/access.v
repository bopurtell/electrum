module protocol_core (
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
    execution_halt_i,
    fetch_valid_i,
    fetch_address_i,
    prog_mem_read_data_i,
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
    fetch_accepted_o,
    fetch_rejected_o,
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
    fetch_fault_o
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
    input execution_halt_i;
    input fetch_valid_i;
    input [8:0] fetch_address_i;
    input [15:0] prog_mem_read_data_i;
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
    output fetch_accepted_o;
    output fetch_rejected_o;
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

    wire signal_const;
    wire signal_const_1;
    wire signal_mux;
    wire signal_mux_1;
    wire signal_mux_2;
    wire signal_mux_3;
    wire signal_wire;
    reg signal_reg;
    wire [15:0] signal_const_4;
    wire [15:0] signal_mux_4;
    wire [15:0] signal_mux_5;
    wire [15:0] signal_wire_1;
    reg [15:0] signal_reg_1;
    wire signal_mux_6;
    wire signal_mux_7;
    wire signal_mux_8;
    wire signal_mux_9;
    wire signal_wire_2;
    reg signal_reg_2;
    wire signal_and;
    wire signal_mux_10;
    wire signal_mux_11;
    wire signal_wire_3;
    reg signal_reg_3;
    wire [15:0] signal_mux_12;
    wire [15:0] signal_mux_13;
    wire [15:0] signal_wire_4;
    reg [15:0] signal_reg_4;
    wire signal_mux_14;
    wire signal_mux_15;
    wire signal_mux_16;
    wire signal_mux_17;
    wire signal_wire_5;
    reg signal_reg_5;
    wire signal_not;
    wire signal_and_1;
    wire signal_not_1;
    wire signal_and_2;
    wire signal_not_2;
    wire signal_and_3;
    wire signal_not_3;
    wire signal_and_4;
    wire signal_not_4;
    wire signal_and_5;
    wire signal_not_5;
    wire signal_and_6;
    wire [15:0] signal_wire_6;
    wire [8:0] signal_mux_18;
    wire [8:0] signal_mux_19;
    wire [7:0] signal_select;
    wire signal_not_6;
    wire signal_and_7;
    wire signal_not_7;
    wire signal_or;
    wire signal_lt;
    wire [8:0] signal_wire_7;
    wire signal_eq;
    wire signal_not_8;
    wire signal_not_9;
    wire signal_wire_8;
    wire signal_mux_20;
    wire signal_not_10;
    wire signal_mux_21;
    wire signal_not_11;
    wire signal_not_12;
    wire [8:0] signal_const_28;
    wire [8:0] signal_const_30;
    wire [8:0] signal_add;
    wire [8:0] signal_mux_22;
    wire [8:0] signal_mux_23;
    wire signal_not_13;
    wire signal_not_14;
    wire signal_not_15;
    wire signal_mux_24;
    wire signal_mux_25;
    wire signal_mux_26;
    wire signal_lt_1;
    wire signal_eq_1;
    wire [15:0] signal_wire_9;
    wire [15:0] signal_mux_27;
    wire [15:0] signal_mux_28;
    wire [15:0] signal_wire_10;
    reg [15:0] signal_reg_6;
    wire [15:0] signal_wire_11;
    wire signal_eq_2;
    wire signal_mux_29;
    wire signal_mux_30;
    wire signal_mux_31;
    wire signal_wire_12;
    reg signal_reg_7;
    wire signal_mux_32;
    wire signal_mux_33;
    wire signal_mux_34;
    wire signal_mux_35;
    wire signal_wire_13;
    reg signal_reg_8;
    wire signal_not_16;
    wire signal_eq_3;
    wire signal_and_8;
    wire signal_and_9;
    wire signal_and_10;
    wire signal_and_11;
    wire [8:0] signal_mux_36;
    wire [8:0] signal_wire_14;
    wire signal_lt_2;
    wire signal_or_1;
    wire signal_and_12;
    wire signal_wire_15;
    wire signal_mux_37;
    wire signal_not_17;
    wire signal_and_13;
    wire signal_and_14;
    wire signal_and_15;
    wire signal_and_16;
    wire signal_mux_38;
    wire signal_mux_39;
    wire signal_wire_16;
    reg signal_reg_9;
    wire signal_and_17;
    wire signal_and_18;
    wire signal_and_19;
    wire signal_and_20;
    wire [8:0] signal_mux_40;
    wire [8:0] signal_mux_41;
    wire [8:0] signal_mux_42;
    wire [8:0] signal_wire_17;
    reg [8:0] signal_reg_10;
    wire signal_eq_4;
    wire [8:0] signal_add_1;
    wire [8:0] signal_mux_43;
    wire [8:0] signal_mux_44;
    wire [8:0] signal_mux_45;
    wire [8:0] signal_wire_18;
    reg [8:0] signal_reg_11;
    wire signal_eq_5;
    wire signal_mux_46;
    wire signal_mux_47;
    wire signal_mux_48;
    wire signal_wire_19;
    reg signal_reg_12;
    wire signal_and_21;
    wire signal_and_22;
    wire signal_and_23;
    wire signal_and_24;
    wire signal_and_25;
    wire signal_and_26;
    wire signal_and_27;
    wire signal_mux_49;
    wire signal_mux_50;
    wire signal_wire_20;
    reg signal_reg_13;
    wire signal_wire_21;
    wire signal_not_18;
    wire signal_wire_22;
    wire signal_not_19;
    wire signal_wire_23;
    wire signal_not_20;
    wire signal_wire_24;
    wire signal_not_21;
    wire signal_not_22;
    wire signal_and_28;
    wire signal_and_29;
    wire signal_and_30;
    wire signal_and_31;
    wire signal_and_32;
    wire signal_and_33;
    wire signal_and_34;
    wire signal_and_35;
    wire signal_mux_51;
    wire signal_not_23;
    wire signal_not_24;
    wire signal_not_25;
    wire signal_and_36;
    wire signal_and_37;
    wire signal_and_38;
    wire signal_mux_52;
    wire signal_mux_53;
    wire signal_mux_54;
    wire signal_wire_25;
    wire [8:0] signal_const_56;
    wire signal_lt_3;
    wire signal_not_26;
    wire [8:0] signal_wire_26;
    wire signal_lt_4;
    wire signal_and_39;
    wire signal_wire_27;
    wire signal_and_40;
    wire signal_and_41;
    wire [8:0] signal_mux_55;
    wire [8:0] signal_mux_56;
    wire [8:0] signal_wire_28;
    reg [8:0] signal_reg_14;
    wire signal_lt_5;
    wire [8:0] signal_wire_29;
    wire signal_lt_6;
    wire signal_and_42;
    wire signal_wire_30;
    wire signal_wire_31;
    wire signal_not_27;
    wire signal_and_43;
    wire signal_and_44;
    wire signal_and_45;
    wire signal_mux_57;
    wire signal_mux_58;
    wire signal_wire_32;
    reg signal_reg_15;
    wire signal_not_28;
    wire signal_or_2;
    wire signal_wire_33;
    wire signal_not_29;
    wire signal_and_46;
    wire signal_and_47;
    wire signal_and_48;
    wire signal_and_49;
    wire signal_and_50;
    wire signal_mux_59;
    wire signal_not_30;
    wire signal_mux_60;
    wire signal_wire_34;
    reg signal_reg_16;
    wire signal_not_31;
    wire signal_wire_35;
    wire signal_and_51;
    wire signal_and_52;
    wire signal_and_53;
    wire signal_and_54;
    wire signal_and_55;
    wire signal_and_56;
    wire signal_and_57;
    wire signal_and_58;
    wire signal_and_59;
    wire signal_or_3;
    wire signal_and_60;
    assign signal_const = 1'b0;
    assign signal_const_1 = 1'b1;
    assign signal_mux = signal_and_41 ? signal_const : signal_reg;
    assign signal_mux_1 = signal_and_35 ? signal_const : signal_mux;
    assign signal_mux_2 = signal_and_50 ? signal_const_1 : signal_mux_1;
    assign signal_mux_3 = signal_not_30 ? signal_reg : signal_mux_2;
    assign signal_wire = signal_mux_3;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg <= signal_const;
        else
            signal_reg <= signal_wire;
    end
    assign signal_const_4 = 16'b0000000000000000;
    assign signal_mux_4 = signal_and_38 ? signal_wire_11 : signal_reg_1;
    assign signal_mux_5 = signal_not_30 ? signal_reg_1 : signal_mux_4;
    assign signal_wire_1 = signal_mux_5;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_1 <= signal_const_4;
        else
            signal_reg_1 <= signal_wire_1;
    end
    assign signal_mux_6 = signal_and_38 ? signal_const_1 : signal_const;
    assign signal_mux_7 = signal_wire_31 ? signal_const : signal_mux_6;
    assign signal_mux_8 = signal_and_50 ? signal_const : signal_mux_7;
    assign signal_mux_9 = signal_not_30 ? signal_const : signal_mux_8;
    assign signal_wire_2 = signal_mux_9;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_2 <= signal_const;
        else
            signal_reg_2 <= signal_wire_2;
    end
    assign signal_and = signal_reg_7 & signal_eq_2;
    assign signal_mux_10 = signal_and_20 ? signal_and : signal_const;
    assign signal_mux_11 = signal_not_30 ? signal_const : signal_mux_10;
    assign signal_wire_3 = signal_mux_11;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_3 <= signal_const;
        else
            signal_reg_3 <= signal_wire_3;
    end
    assign signal_mux_12 = signal_and_20 ? signal_wire_11 : signal_reg_4;
    assign signal_mux_13 = signal_not_30 ? signal_reg_4 : signal_mux_12;
    assign signal_wire_4 = signal_mux_13;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_4 <= signal_const_4;
        else
            signal_reg_4 <= signal_wire_4;
    end
    assign signal_mux_14 = signal_and_20 ? signal_const_1 : signal_const;
    assign signal_mux_15 = signal_wire_31 ? signal_const : signal_mux_14;
    assign signal_mux_16 = signal_and_41 ? signal_const : signal_mux_15;
    assign signal_mux_17 = signal_not_30 ? signal_const : signal_mux_16;
    assign signal_wire_5 = signal_mux_17;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_5 <= signal_const;
        else
            signal_reg_5 <= signal_wire_5;
    end
    assign signal_not = ~ signal_and_45;
    assign signal_and_1 = signal_wire_30 & signal_not;
    assign signal_not_1 = ~ signal_and_35;
    assign signal_and_2 = signal_wire_21 & signal_not_1;
    assign signal_not_2 = ~ signal_and_16;
    assign signal_and_3 = signal_wire_23 & signal_not_2;
    assign signal_not_3 = ~ signal_and_27;
    assign signal_and_4 = signal_wire_22 & signal_not_3;
    assign signal_not_4 = ~ signal_and_59;
    assign signal_and_5 = signal_wire_24 & signal_not_4;
    assign signal_not_5 = ~ signal_and_41;
    assign signal_and_6 = signal_wire_27 & signal_not_5;
    assign signal_wire_6 = load_data_i;
    assign signal_mux_18 = signal_and_16 ? signal_wire_14 : signal_wire_29;
    assign signal_mux_19 = signal_and_59 ? signal_wire_7 : signal_mux_18;
    assign signal_select = signal_mux_19[7:0];
    assign signal_not_6 = ~ signal_wire_33;
    assign signal_and_7 = signal_and_59 & signal_not_6;
    assign signal_not_7 = ~ signal_wire_33;
    assign signal_or = signal_and_16 | signal_and_45;
    assign signal_lt = signal_wire_7 < signal_reg_14;
    assign signal_wire_7 = load_address_i;
    assign signal_eq = signal_wire_7 == signal_reg_11;
    assign signal_not_8 = ~ signal_wire_31;
    assign signal_not_9 = ~ signal_wire_33;
    assign signal_wire_8 = engines_idle_i;
    assign signal_mux_20 = signal_wire_31 ? signal_const : signal_reg_16;
    assign signal_not_10 = ~ signal_reg_9;
    assign signal_mux_21 = signal_and_41 ? signal_const : signal_reg_13;
    assign signal_not_11 = ~ signal_reg_9;
    assign signal_not_12 = ~ signal_reg_8;
    assign signal_const_28 = 9'b000000000;
    assign signal_const_30 = 9'b000000001;
    assign signal_add = signal_reg_10 + signal_const_30;
    assign signal_mux_22 = signal_eq_2 ? signal_add : signal_reg_10;
    assign signal_mux_23 = signal_reg_7 ? signal_mux_22 : signal_reg_10;
    assign signal_not_13 = ~ signal_wire_31;
    assign signal_not_14 = ~ signal_wire_33;
    assign signal_not_15 = ~ signal_and_41;
    assign signal_mux_24 = signal_and_20 ? signal_const : signal_reg_9;
    assign signal_mux_25 = signal_wire_31 ? signal_const : signal_mux_24;
    assign signal_mux_26 = signal_and_41 ? signal_const : signal_mux_25;
    assign signal_lt_1 = signal_wire_14 < signal_reg_14;
    assign signal_eq_1 = signal_wire_14 == signal_reg_10;
    assign signal_wire_9 = readback_expected_i;
    assign signal_mux_27 = signal_and_16 ? signal_wire_9 : signal_reg_6;
    assign signal_mux_28 = signal_not_30 ? signal_reg_6 : signal_mux_27;
    assign signal_wire_10 = signal_mux_28;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_6 <= signal_const_4;
        else
            signal_reg_6 <= signal_wire_10;
    end
    assign signal_wire_11 = prog_mem_read_data_i;
    assign signal_eq_2 = signal_wire_11 == signal_reg_6;
    assign signal_mux_29 = signal_eq_2 ? signal_reg_8 : signal_const_1;
    assign signal_mux_30 = signal_and_16 ? signal_wire_15 : signal_reg_7;
    assign signal_mux_31 = signal_not_30 ? signal_reg_7 : signal_mux_30;
    assign signal_wire_12 = signal_mux_31;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_7 <= signal_const;
        else
            signal_reg_7 <= signal_wire_12;
    end
    assign signal_mux_32 = signal_reg_7 ? signal_mux_29 : signal_reg_8;
    assign signal_mux_33 = signal_and_20 ? signal_mux_32 : signal_reg_8;
    assign signal_mux_34 = signal_and_41 ? signal_const : signal_mux_33;
    assign signal_mux_35 = signal_not_30 ? signal_reg_8 : signal_mux_34;
    assign signal_wire_13 = signal_mux_35;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_8 <= signal_const;
        else
            signal_reg_8 <= signal_wire_13;
    end
    assign signal_not_16 = ~ signal_reg_8;
    assign signal_eq_3 = signal_reg_11 == signal_reg_14;
    assign signal_and_8 = signal_reg_12 & signal_eq_3;
    assign signal_and_9 = signal_and_8 & signal_not_16;
    assign signal_and_10 = signal_and_9 & signal_eq_1;
    assign signal_and_11 = signal_and_10 & signal_lt_1;
    assign signal_mux_36 = signal_reg_12 ? signal_reg_11 : signal_reg_14;
    assign signal_wire_14 = readback_address_i;
    assign signal_lt_2 = signal_wire_14 < signal_mux_36;
    assign signal_or_1 = signal_reg_12 | signal_reg_13;
    assign signal_and_12 = signal_or_1 & signal_lt_2;
    assign signal_wire_15 = readback_verify_i;
    assign signal_mux_37 = signal_wire_15 ? signal_and_11 : signal_and_12;
    assign signal_not_17 = ~ signal_reg_9;
    assign signal_and_13 = signal_and_54 & signal_and_28;
    assign signal_and_14 = signal_and_13 & signal_wire_23;
    assign signal_and_15 = signal_and_14 & signal_not_17;
    assign signal_and_16 = signal_and_15 & signal_mux_37;
    assign signal_mux_38 = signal_and_16 ? signal_const_1 : signal_mux_26;
    assign signal_mux_39 = signal_not_30 ? signal_const : signal_mux_38;
    assign signal_wire_16 = signal_mux_39;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_9 <= signal_const;
        else
            signal_reg_9 <= signal_wire_16;
    end
    assign signal_and_17 = signal_wire_35 & signal_reg_9;
    assign signal_and_18 = signal_and_17 & signal_not_15;
    assign signal_and_19 = signal_and_18 & signal_not_14;
    assign signal_and_20 = signal_and_19 & signal_not_13;
    assign signal_mux_40 = signal_and_20 ? signal_mux_23 : signal_reg_10;
    assign signal_mux_41 = signal_and_41 ? signal_const_28 : signal_mux_40;
    assign signal_mux_42 = signal_not_30 ? signal_reg_10 : signal_mux_41;
    assign signal_wire_17 = signal_mux_42;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_10 <= signal_const_28;
        else
            signal_reg_10 <= signal_wire_17;
    end
    assign signal_eq_4 = signal_reg_10 == signal_reg_14;
    assign signal_add_1 = signal_reg_11 + signal_const_30;
    assign signal_mux_43 = signal_and_41 ? signal_const_28 : signal_reg_11;
    assign signal_mux_44 = signal_and_59 ? signal_add_1 : signal_mux_43;
    assign signal_mux_45 = signal_not_30 ? signal_reg_11 : signal_mux_44;
    assign signal_wire_18 = signal_mux_45;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_11 <= signal_const_28;
        else
            signal_reg_11 <= signal_wire_18;
    end
    assign signal_eq_5 = signal_reg_11 == signal_reg_14;
    assign signal_mux_46 = signal_and_41 ? signal_const_1 : signal_reg_12;
    assign signal_mux_47 = signal_and_27 ? signal_const : signal_mux_46;
    assign signal_mux_48 = signal_not_30 ? signal_const : signal_mux_47;
    assign signal_wire_19 = signal_mux_48;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_12 <= signal_const;
        else
            signal_reg_12 <= signal_wire_19;
    end
    assign signal_and_21 = signal_and_54 & signal_and_29;
    assign signal_and_22 = signal_and_21 & signal_wire_22;
    assign signal_and_23 = signal_and_22 & signal_reg_12;
    assign signal_and_24 = signal_and_23 & signal_eq_5;
    assign signal_and_25 = signal_and_24 & signal_eq_4;
    assign signal_and_26 = signal_and_25 & signal_not_12;
    assign signal_and_27 = signal_and_26 & signal_not_11;
    assign signal_mux_49 = signal_and_27 ? signal_const_1 : signal_mux_21;
    assign signal_mux_50 = signal_not_30 ? signal_reg_13 : signal_mux_49;
    assign signal_wire_20 = signal_mux_50;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_13 <= signal_const;
        else
            signal_reg_13 <= signal_wire_20;
    end
    assign signal_wire_21 = run_valid_i;
    assign signal_not_18 = ~ signal_wire_31;
    assign signal_wire_22 = load_complete_valid_i;
    assign signal_not_19 = ~ signal_wire_22;
    assign signal_wire_23 = readback_valid_i;
    assign signal_not_20 = ~ signal_wire_23;
    assign signal_wire_24 = load_write_valid_i;
    assign signal_not_21 = ~ signal_wire_24;
    assign signal_not_22 = ~ signal_wire_27;
    assign signal_and_28 = signal_not_22 & signal_not_21;
    assign signal_and_29 = signal_and_28 & signal_not_20;
    assign signal_and_30 = signal_and_29 & signal_not_19;
    assign signal_and_31 = signal_and_54 & signal_and_30;
    assign signal_and_32 = signal_and_31 & signal_not_18;
    assign signal_and_33 = signal_and_32 & signal_wire_21;
    assign signal_and_34 = signal_and_33 & signal_reg_13;
    assign signal_and_35 = signal_and_34 & signal_not_10;
    assign signal_mux_51 = signal_and_35 ? signal_const_1 : signal_mux_20;
    assign signal_not_23 = ~ signal_and_42;
    assign signal_not_24 = ~ signal_wire_31;
    assign signal_not_25 = ~ signal_wire_33;
    assign signal_and_36 = signal_wire_35 & signal_reg_15;
    assign signal_and_37 = signal_and_36 & signal_not_25;
    assign signal_and_38 = signal_and_37 & signal_not_24;
    assign signal_mux_52 = signal_and_38 ? signal_const : signal_reg_15;
    assign signal_mux_53 = signal_wire_31 ? signal_const : signal_mux_52;
    assign signal_mux_54 = signal_and_50 ? signal_const : signal_mux_53;
    assign signal_wire_25 = clock_i;
    assign signal_const_56 = 9'b100000000;
    assign signal_lt_3 = signal_const_56 < signal_wire_26;
    assign signal_not_26 = ~ signal_lt_3;
    assign signal_wire_26 = load_length_i;
    assign signal_lt_4 = signal_const_28 < signal_wire_26;
    assign signal_and_39 = signal_lt_4 & signal_not_26;
    assign signal_wire_27 = load_start_valid_i;
    assign signal_and_40 = signal_and_54 & signal_wire_27;
    assign signal_and_41 = signal_and_40 & signal_and_39;
    assign signal_mux_55 = signal_and_41 ? signal_wire_26 : signal_reg_14;
    assign signal_mux_56 = signal_not_30 ? signal_reg_14 : signal_mux_55;
    assign signal_wire_28 = signal_mux_56;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_14 <= signal_const_28;
        else
            signal_reg_14 <= signal_wire_28;
    end
    assign signal_lt_5 = signal_wire_29 < signal_reg_14;
    assign signal_wire_29 = fetch_address_i;
    assign signal_lt_6 = signal_wire_29 < signal_const_56;
    assign signal_and_42 = signal_lt_6 & signal_lt_5;
    assign signal_wire_30 = fetch_valid_i;
    assign signal_wire_31 = execution_halt_i;
    assign signal_not_27 = ~ signal_wire_31;
    assign signal_and_43 = signal_and_48 & signal_not_27;
    assign signal_and_44 = signal_and_43 & signal_wire_30;
    assign signal_and_45 = signal_and_44 & signal_and_42;
    assign signal_mux_57 = signal_and_45 ? signal_const_1 : signal_mux_54;
    assign signal_mux_58 = signal_not_30 ? signal_const : signal_mux_57;
    assign signal_wire_32 = signal_mux_58;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_15 <= signal_const;
        else
            signal_reg_15 <= signal_wire_32;
    end
    assign signal_not_28 = ~ signal_reg_15;
    assign signal_or_2 = signal_not_28 | signal_and_37;
    assign signal_wire_33 = reset_i;
    assign signal_not_29 = ~ signal_wire_33;
    assign signal_and_46 = signal_wire_35 & signal_reg_16;
    assign signal_and_47 = signal_and_46 & signal_not_29;
    assign signal_and_48 = signal_and_47 & signal_or_2;
    assign signal_and_49 = signal_and_48 & signal_wire_30;
    assign signal_and_50 = signal_and_49 & signal_not_23;
    assign signal_mux_59 = signal_and_50 ? signal_const : signal_mux_51;
    assign signal_not_30 = ~ signal_wire_35;
    assign signal_mux_60 = signal_not_30 ? signal_const : signal_mux_59;
    assign signal_wire_34 = signal_mux_60;
    always @(posedge signal_wire_25) begin
        if (signal_wire_33)
            signal_reg_16 <= signal_const;
        else
            signal_reg_16 <= signal_wire_34;
    end
    assign signal_not_31 = ~ signal_reg_16;
    assign signal_wire_35 = en_i;
    assign signal_and_51 = signal_wire_35 & signal_not_31;
    assign signal_and_52 = signal_and_51 & signal_wire_8;
    assign signal_and_53 = signal_and_52 & signal_not_9;
    assign signal_and_54 = signal_and_53 & signal_not_8;
    assign signal_and_55 = signal_and_54 & signal_not_22;
    assign signal_and_56 = signal_and_55 & signal_wire_24;
    assign signal_and_57 = signal_and_56 & signal_reg_12;
    assign signal_and_58 = signal_and_57 & signal_eq;
    assign signal_and_59 = signal_and_58 & signal_lt;
    assign signal_or_3 = signal_and_59 | signal_or;
    assign signal_and_60 = signal_or_3 & signal_not_7;
    assign prog_mem_enable_o = signal_and_60;
    assign prog_mem_write_enable_o = signal_and_7;
    assign prog_mem_address_o = signal_select;
    assign prog_mem_write_data_o = signal_wire_6;
    assign load_start_accepted_o = signal_and_41;
    assign load_start_rejected_o = signal_and_6;
    assign load_write_accepted_o = signal_and_59;
    assign load_write_rejected_o = signal_and_5;
    assign load_complete_accepted_o = signal_and_27;
    assign load_complete_rejected_o = signal_and_4;
    assign readback_accepted_o = signal_and_16;
    assign readback_rejected_o = signal_and_3;
    assign run_accepted_o = signal_and_35;
    assign run_rejected_o = signal_and_2;
    assign fetch_accepted_o = signal_and_45;
    assign fetch_rejected_o = signal_and_1;
    assign readback_response_valid_o = signal_reg_5;
    assign readback_response_data_o = signal_reg_4;
    assign readback_response_match_o = signal_reg_3;
    assign fetch_completion_valid_o = signal_and_37;
    assign fetch_completion_data_o = signal_wire_11;
    assign fetch_response_valid_o = signal_reg_2;
    assign fetch_response_data_o = signal_reg_1;
    assign halted_o = signal_not_31;
    assign image_valid_o = signal_reg_13;
    assign load_active_o = signal_reg_12;
    assign image_length_o = signal_reg_14;
    assign words_written_o = signal_reg_11;
    assign words_verified_o = signal_reg_10;
    assign verification_failed_o = signal_reg_8;
    assign fetch_fault_event_o = signal_and_50;
    assign fetch_fault_o = signal_reg;

endmodule
