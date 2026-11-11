module timing (
    clock_i,
    reset_i,
    enable_i,
    abort_i,
    wait_valid_i,
    wait_kind_i,
    wait_pin_i,
    wait_level_i,
    wait_timeout_enable_i,
    wait_delay_i,
    snapshot_i,
    rising_i,
    falling_i,
    periodic_start_i,
    periodic_stop_i,
    periodic_period_i,
    phase_restart_i,
    ready_o,
    busy_o,
    complete_o,
    timeout_o,
    rejected_o,
    tick_o,
    remaining_o
);

    input clock_i;
    input reset_i;
    input enable_i;
    input abort_i;
    input wait_valid_i;
    input [1:0] wait_kind_i;
    input [2:0] wait_pin_i;
    input wait_level_i;
    input wait_timeout_enable_i;
    input [15:0] wait_delay_i;
    input [7:0] snapshot_i;
    input [7:0] rising_i;
    input [7:0] falling_i;
    input periodic_start_i;
    input periodic_stop_i;
    input [15:0] periodic_period_i;
    input phase_restart_i;
    output ready_o;
    output busy_o;
    output complete_o;
    output timeout_o;
    output rejected_o;
    output tick_o;
    output [15:0] remaining_o;

    wire signal_const;
    wire signal_const_1;
    wire [15:0] signal_const_2;
    wire [15:0] signal_const_3;
    wire [15:0] signal_mux;
    wire [15:0] signal_mux_1;
    wire [15:0] signal_mux_2;
    wire [15:0] signal_wire;
    reg [15:0] reg_period;
    wire [15:0] signal_sub;
    wire [15:0] signal_mux_3;
    wire [15:0] signal_mux_4;
    wire [15:0] signal_mux_5;
    wire [15:0] signal_mux_6;
    wire [15:0] signal_mux_7;
    wire [15:0] signal_mux_8;
    wire [15:0] signal_mux_9;
    wire [15:0] signal_wire_1;
    reg [15:0] reg_phase;
    wire signal_eq;
    wire signal_mux_10;
    wire signal_wire_2;
    wire signal_mux_11;
    wire signal_not;
    wire signal_not_1;
    wire signal_mux_12;
    wire signal_wire_3;
    wire signal_mux_13;
    wire signal_mux_14;
    wire signal_mux_15;
    wire signal_wire_4;
    reg reg_periodic_active;
    wire signal_and;
    wire signal_and_1;
    wire signal_mux_16;
    wire signal_mux_17;
    wire signal_wire_5;
    reg reg_tick;
    wire [15:0] signal_wire_6;
    wire signal_eq_1;
    wire signal_mux_18;
    wire signal_mux_19;
    wire signal_mux_20;
    wire signal_mux_21;
    wire signal_wire_7;
    wire signal_mux_22;
    wire signal_mux_23;
    wire signal_wire_8;
    reg reg_rejected;
    wire signal_mux_24;
    wire signal_mux_25;
    wire signal_mux_26;
    wire signal_mux_27;
    wire signal_mux_28;
    wire signal_wire_9;
    reg reg_timeout;
    wire [1:0] signal_const_24;
    wire signal_eq_2;
    wire signal_mux_29;
    wire signal_mux_30;
    wire signal_mux_31;
    wire signal_mux_32;
    wire signal_mux_33;
    wire signal_wire_10;
    reg reg_complete;
    wire [15:0] signal_sub_1;
    wire signal_eq_3;
    wire signal_or;
    wire [15:0] signal_mux_34;
    wire [15:0] signal_mux_35;
    wire [15:0] signal_mux_36;
    wire [15:0] signal_mux_37;
    wire [15:0] signal_mux_38;
    wire [15:0] signal_mux_39;
    wire [15:0] signal_mux_40;
    wire [15:0] signal_mux_41;
    wire [15:0] signal_wire_11;
    reg [15:0] reg_remaining;
    wire signal_eq_4;
    wire signal_mux_42;
    wire signal_mux_43;
    wire signal_mux_44;
    wire signal_mux_45;
    wire signal_mux_46;
    wire signal_wire_12;
    reg reg_timeout_enable;
    wire signal_eq_5;
    wire signal_or_1;
    wire signal_and_2;
    wire signal_mux_47;
    wire signal_select;
    wire signal_select_1;
    wire signal_select_2;
    wire signal_select_3;
    wire signal_select_4;
    wire signal_select_5;
    wire signal_select_6;
    wire [7:0] signal_wire_13;
    wire signal_select_7;
    reg signal_mux_48;
    wire signal_select_8;
    wire signal_select_9;
    wire signal_select_10;
    wire signal_select_11;
    wire signal_select_12;
    wire signal_select_13;
    wire signal_select_14;
    wire [7:0] signal_wire_14;
    wire signal_select_15;
    reg signal_mux_49;
    wire signal_mux_50;
    wire signal_mux_51;
    wire signal_mux_52;
    wire signal_mux_53;
    wire signal_mux_54;
    wire signal_wire_15;
    reg reg_level;
    wire signal_select_16;
    wire signal_select_17;
    wire signal_select_18;
    wire signal_select_19;
    wire signal_select_20;
    wire signal_select_21;
    wire signal_select_22;
    wire signal_select_23;
    wire [2:0] signal_const_40;
    wire [2:0] signal_mux_55;
    wire [2:0] signal_mux_56;
    wire [2:0] signal_mux_57;
    wire [2:0] signal_mux_58;
    wire [2:0] signal_mux_59;
    wire [2:0] signal_wire_16;
    reg [2:0] reg_pin;
    reg signal_mux_60;
    wire signal_eq_6;
    wire gnd;
    wire signal_wire_17;
    wire signal_wire_18;
    wire [1:0] signal_mux_61;
    wire [1:0] signal_mux_62;
    wire [1:0] signal_mux_63;
    wire [1:0] signal_mux_64;
    wire [1:0] signal_mux_65;
    wire [1:0] signal_wire_19;
    reg [1:0] reg_kind;
    reg signal_mux_66;
    wire signal_mux_67;
    wire signal_wire_20;
    wire signal_select_24;
    wire signal_select_25;
    wire signal_select_26;
    wire signal_select_27;
    wire signal_select_28;
    wire signal_select_29;
    wire signal_select_30;
    wire [7:0] signal_wire_21;
    wire signal_select_31;
    wire [2:0] signal_wire_22;
    reg signal_mux_68;
    wire signal_eq_7;
    wire [1:0] signal_const_43;
    wire signal_eq_8;
    wire signal_and_3;
    wire signal_mux_69;
    wire [15:0] signal_wire_23;
    wire signal_eq_9;
    wire signal_wire_24;
    wire [1:0] signal_wire_25;
    wire signal_eq_10;
    wire signal_or_2;
    wire signal_and_4;
    wire signal_mux_70;
    wire signal_wire_26;
    wire signal_mux_71;
    wire signal_mux_72;
    wire signal_wire_27;
    wire signal_not_2;
    wire signal_or_3;
    wire signal_mux_73;
    wire signal_wire_28;
    reg reg_busy;
    wire signal_not_3;
    wire signal_wire_29;
    wire signal_and_5;
    assign signal_const = 1'b0;
    assign signal_const_1 = 1'b1;
    assign signal_const_2 = 16'b0000000000000001;
    assign signal_const_3 = 16'b0000000000000000;
    assign signal_mux = signal_eq_1 ? reg_period : signal_wire_6;
    assign signal_mux_1 = signal_wire_7 ? signal_mux : reg_period;
    assign signal_mux_2 = signal_or_3 ? reg_period : signal_mux_1;
    assign signal_wire = signal_mux_2;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_period <= signal_const_3;
        else
            reg_period <= signal_wire;
    end
    assign signal_sub = reg_phase - signal_const_2;
    assign signal_mux_3 = signal_eq ? reg_period : signal_sub;
    assign signal_mux_4 = signal_wire_2 ? reg_period : signal_mux_3;
    assign signal_mux_5 = signal_eq_1 ? signal_mux_6 : signal_wire_6;
    assign signal_mux_6 = signal_wire_3 ? signal_const_3 : reg_phase;
    assign signal_mux_7 = signal_wire_7 ? signal_mux_5 : signal_mux_6;
    assign signal_mux_8 = signal_and_1 ? signal_mux_4 : signal_mux_7;
    assign signal_mux_9 = signal_or_3 ? signal_const_3 : signal_mux_8;
    assign signal_wire_1 = signal_mux_9;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_phase <= signal_const_3;
        else
            reg_phase <= signal_wire_1;
    end
    assign signal_eq = reg_phase == signal_const_2;
    assign signal_mux_10 = signal_eq ? signal_const_1 : signal_const;
    assign signal_wire_2 = phase_restart_i;
    assign signal_mux_11 = signal_wire_2 ? signal_const : signal_mux_10;
    assign signal_not = ~ signal_wire_3;
    assign signal_not_1 = ~ signal_wire_7;
    assign signal_mux_12 = signal_eq_1 ? signal_mux_13 : signal_const_1;
    assign signal_wire_3 = periodic_stop_i;
    assign signal_mux_13 = signal_wire_3 ? signal_const : reg_periodic_active;
    assign signal_mux_14 = signal_wire_7 ? signal_mux_12 : signal_mux_13;
    assign signal_mux_15 = signal_or_3 ? signal_const : signal_mux_14;
    assign signal_wire_4 = signal_mux_15;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_periodic_active <= signal_const;
        else
            reg_periodic_active <= signal_wire_4;
    end
    assign signal_and = reg_periodic_active & signal_not_1;
    assign signal_and_1 = signal_and & signal_not;
    assign signal_mux_16 = signal_and_1 ? signal_mux_11 : signal_const;
    assign signal_mux_17 = signal_or_3 ? signal_const : signal_mux_16;
    assign signal_wire_5 = signal_mux_17;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_tick <= signal_const;
        else
            reg_tick <= signal_wire_5;
    end
    assign signal_wire_6 = periodic_period_i;
    assign signal_eq_1 = signal_wire_6 == signal_const_3;
    assign signal_mux_18 = signal_eq_1 ? signal_const_1 : signal_mux_21;
    assign signal_mux_19 = signal_and_4 ? signal_const_1 : signal_const;
    assign signal_mux_20 = signal_wire_26 ? signal_mux_19 : signal_const;
    assign signal_mux_21 = reg_busy ? signal_const : signal_mux_20;
    assign signal_wire_7 = periodic_start_i;
    assign signal_mux_22 = signal_wire_7 ? signal_mux_18 : signal_mux_21;
    assign signal_mux_23 = signal_or_3 ? signal_const : signal_mux_22;
    assign signal_wire_8 = signal_mux_23;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_rejected <= signal_const;
        else
            reg_rejected <= signal_wire_8;
    end
    assign signal_mux_24 = signal_eq_2 ? signal_const : signal_const_1;
    assign signal_mux_25 = signal_and_2 ? signal_mux_24 : signal_const;
    assign signal_mux_26 = signal_mux_66 ? signal_const : signal_mux_25;
    assign signal_mux_27 = reg_busy ? signal_mux_26 : signal_const;
    assign signal_mux_28 = signal_or_3 ? signal_const : signal_mux_27;
    assign signal_wire_9 = signal_mux_28;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_timeout <= signal_const;
        else
            reg_timeout <= signal_wire_9;
    end
    assign signal_const_24 = 2'b00;
    assign signal_eq_2 = reg_kind == signal_const_24;
    assign signal_mux_29 = signal_eq_2 ? signal_const_1 : signal_const;
    assign signal_mux_30 = signal_and_2 ? signal_mux_29 : signal_const;
    assign signal_mux_31 = signal_mux_66 ? signal_const_1 : signal_mux_30;
    assign signal_mux_32 = reg_busy ? signal_mux_31 : signal_const;
    assign signal_mux_33 = signal_or_3 ? signal_const : signal_mux_32;
    assign signal_wire_10 = signal_mux_33;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_complete <= signal_const;
        else
            reg_complete <= signal_wire_10;
    end
    assign signal_sub_1 = reg_remaining - signal_const_2;
    assign signal_eq_3 = reg_kind == signal_const_24;
    assign signal_or = signal_eq_3 | reg_timeout_enable;
    assign signal_mux_34 = signal_or ? signal_sub_1 : reg_remaining;
    assign signal_mux_35 = signal_and_2 ? signal_const_3 : signal_mux_34;
    assign signal_mux_36 = signal_mux_66 ? signal_const_3 : signal_mux_35;
    assign signal_mux_37 = signal_and_3 ? reg_remaining : signal_wire_23;
    assign signal_mux_38 = signal_and_4 ? reg_remaining : signal_mux_37;
    assign signal_mux_39 = signal_wire_26 ? signal_mux_38 : reg_remaining;
    assign signal_mux_40 = reg_busy ? signal_mux_36 : signal_mux_39;
    assign signal_mux_41 = signal_or_3 ? signal_const_3 : signal_mux_40;
    assign signal_wire_11 = signal_mux_41;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_remaining <= signal_const_3;
        else
            reg_remaining <= signal_wire_11;
    end
    assign signal_eq_4 = reg_remaining == signal_const_2;
    assign signal_mux_42 = signal_and_3 ? reg_timeout_enable : signal_wire_24;
    assign signal_mux_43 = signal_and_4 ? reg_timeout_enable : signal_mux_42;
    assign signal_mux_44 = signal_wire_26 ? signal_mux_43 : reg_timeout_enable;
    assign signal_mux_45 = reg_busy ? reg_timeout_enable : signal_mux_44;
    assign signal_mux_46 = signal_or_3 ? reg_timeout_enable : signal_mux_45;
    assign signal_wire_12 = signal_mux_46;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_timeout_enable <= signal_const;
        else
            reg_timeout_enable <= signal_wire_12;
    end
    assign signal_eq_5 = reg_kind == signal_const_24;
    assign signal_or_1 = signal_eq_5 | reg_timeout_enable;
    assign signal_and_2 = signal_or_1 & signal_eq_4;
    assign signal_mux_47 = signal_and_2 ? signal_const : reg_busy;
    assign signal_select = signal_wire_13[7:7];
    assign signal_select_1 = signal_wire_13[6:6];
    assign signal_select_2 = signal_wire_13[5:5];
    assign signal_select_3 = signal_wire_13[4:4];
    assign signal_select_4 = signal_wire_13[3:3];
    assign signal_select_5 = signal_wire_13[2:2];
    assign signal_select_6 = signal_wire_13[1:1];
    assign signal_wire_13 = falling_i;
    assign signal_select_7 = signal_wire_13[0:0];
    always @* begin
        case (reg_pin)
        0:
            signal_mux_48 <= signal_select_7;
        1:
            signal_mux_48 <= signal_select_6;
        2:
            signal_mux_48 <= signal_select_5;
        3:
            signal_mux_48 <= signal_select_4;
        4:
            signal_mux_48 <= signal_select_3;
        5:
            signal_mux_48 <= signal_select_2;
        6:
            signal_mux_48 <= signal_select_1;
        default:
            signal_mux_48 <= signal_select;
        endcase
    end
    assign signal_select_8 = signal_wire_14[7:7];
    assign signal_select_9 = signal_wire_14[6:6];
    assign signal_select_10 = signal_wire_14[5:5];
    assign signal_select_11 = signal_wire_14[4:4];
    assign signal_select_12 = signal_wire_14[3:3];
    assign signal_select_13 = signal_wire_14[2:2];
    assign signal_select_14 = signal_wire_14[1:1];
    assign signal_wire_14 = rising_i;
    assign signal_select_15 = signal_wire_14[0:0];
    always @* begin
        case (reg_pin)
        0:
            signal_mux_49 <= signal_select_15;
        1:
            signal_mux_49 <= signal_select_14;
        2:
            signal_mux_49 <= signal_select_13;
        3:
            signal_mux_49 <= signal_select_12;
        4:
            signal_mux_49 <= signal_select_11;
        5:
            signal_mux_49 <= signal_select_10;
        6:
            signal_mux_49 <= signal_select_9;
        default:
            signal_mux_49 <= signal_select_8;
        endcase
    end
    assign signal_mux_50 = signal_and_3 ? reg_level : signal_wire_20;
    assign signal_mux_51 = signal_and_4 ? reg_level : signal_mux_50;
    assign signal_mux_52 = signal_wire_26 ? signal_mux_51 : reg_level;
    assign signal_mux_53 = reg_busy ? reg_level : signal_mux_52;
    assign signal_mux_54 = signal_or_3 ? reg_level : signal_mux_53;
    assign signal_wire_15 = signal_mux_54;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_level <= signal_const;
        else
            reg_level <= signal_wire_15;
    end
    assign signal_select_16 = signal_wire_21[7:7];
    assign signal_select_17 = signal_wire_21[6:6];
    assign signal_select_18 = signal_wire_21[5:5];
    assign signal_select_19 = signal_wire_21[4:4];
    assign signal_select_20 = signal_wire_21[3:3];
    assign signal_select_21 = signal_wire_21[2:2];
    assign signal_select_22 = signal_wire_21[1:1];
    assign signal_select_23 = signal_wire_21[0:0];
    assign signal_const_40 = 3'b000;
    assign signal_mux_55 = signal_and_3 ? reg_pin : signal_wire_22;
    assign signal_mux_56 = signal_and_4 ? reg_pin : signal_mux_55;
    assign signal_mux_57 = signal_wire_26 ? signal_mux_56 : reg_pin;
    assign signal_mux_58 = reg_busy ? reg_pin : signal_mux_57;
    assign signal_mux_59 = signal_or_3 ? reg_pin : signal_mux_58;
    assign signal_wire_16 = signal_mux_59;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_pin <= signal_const_40;
        else
            reg_pin <= signal_wire_16;
    end
    always @* begin
        case (reg_pin)
        0:
            signal_mux_60 <= signal_select_23;
        1:
            signal_mux_60 <= signal_select_22;
        2:
            signal_mux_60 <= signal_select_21;
        3:
            signal_mux_60 <= signal_select_20;
        4:
            signal_mux_60 <= signal_select_19;
        5:
            signal_mux_60 <= signal_select_18;
        6:
            signal_mux_60 <= signal_select_17;
        default:
            signal_mux_60 <= signal_select_16;
        endcase
    end
    assign signal_eq_6 = signal_mux_60 == reg_level;
    assign gnd = 1'b0;
    assign signal_wire_17 = reset_i;
    assign signal_wire_18 = clock_i;
    assign signal_mux_61 = signal_and_3 ? reg_kind : signal_wire_25;
    assign signal_mux_62 = signal_and_4 ? reg_kind : signal_mux_61;
    assign signal_mux_63 = signal_wire_26 ? signal_mux_62 : reg_kind;
    assign signal_mux_64 = reg_busy ? reg_kind : signal_mux_63;
    assign signal_mux_65 = signal_or_3 ? reg_kind : signal_mux_64;
    assign signal_wire_19 = signal_mux_65;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_kind <= signal_const_24;
        else
            reg_kind <= signal_wire_19;
    end
    always @* begin
        case (reg_kind)
        0:
            signal_mux_66 <= gnd;
        1:
            signal_mux_66 <= signal_eq_6;
        2:
            signal_mux_66 <= signal_mux_49;
        default:
            signal_mux_66 <= signal_mux_48;
        endcase
    end
    assign signal_mux_67 = signal_mux_66 ? signal_const : signal_mux_47;
    assign signal_wire_20 = wait_level_i;
    assign signal_select_24 = signal_wire_21[7:7];
    assign signal_select_25 = signal_wire_21[6:6];
    assign signal_select_26 = signal_wire_21[5:5];
    assign signal_select_27 = signal_wire_21[4:4];
    assign signal_select_28 = signal_wire_21[3:3];
    assign signal_select_29 = signal_wire_21[2:2];
    assign signal_select_30 = signal_wire_21[1:1];
    assign signal_wire_21 = snapshot_i;
    assign signal_select_31 = signal_wire_21[0:0];
    assign signal_wire_22 = wait_pin_i;
    always @* begin
        case (signal_wire_22)
        0:
            signal_mux_68 <= signal_select_31;
        1:
            signal_mux_68 <= signal_select_30;
        2:
            signal_mux_68 <= signal_select_29;
        3:
            signal_mux_68 <= signal_select_28;
        4:
            signal_mux_68 <= signal_select_27;
        5:
            signal_mux_68 <= signal_select_26;
        6:
            signal_mux_68 <= signal_select_25;
        default:
            signal_mux_68 <= signal_select_24;
        endcase
    end
    assign signal_eq_7 = signal_mux_68 == signal_wire_20;
    assign signal_const_43 = 2'b01;
    assign signal_eq_8 = signal_wire_25 == signal_const_43;
    assign signal_and_3 = signal_eq_8 & signal_eq_7;
    assign signal_mux_69 = signal_and_3 ? reg_busy : signal_const_1;
    assign signal_wire_23 = wait_delay_i;
    assign signal_eq_9 = signal_wire_23 == signal_const_3;
    assign signal_wire_24 = wait_timeout_enable_i;
    assign signal_wire_25 = wait_kind_i;
    assign signal_eq_10 = signal_wire_25 == signal_const_24;
    assign signal_or_2 = signal_eq_10 | signal_wire_24;
    assign signal_and_4 = signal_or_2 & signal_eq_9;
    assign signal_mux_70 = signal_and_4 ? reg_busy : signal_mux_69;
    assign signal_wire_26 = wait_valid_i;
    assign signal_mux_71 = signal_wire_26 ? signal_mux_70 : reg_busy;
    assign signal_mux_72 = reg_busy ? signal_mux_67 : signal_mux_71;
    assign signal_wire_27 = abort_i;
    assign signal_not_2 = ~ signal_wire_29;
    assign signal_or_3 = signal_not_2 | signal_wire_27;
    assign signal_mux_73 = signal_or_3 ? signal_const : signal_mux_72;
    assign signal_wire_28 = signal_mux_73;
    always @(posedge signal_wire_18) begin
        if (signal_wire_17)
            reg_busy <= signal_const;
        else
            reg_busy <= signal_wire_28;
    end
    assign signal_not_3 = ~ reg_busy;
    assign signal_wire_29 = enable_i;
    assign signal_and_5 = signal_wire_29 & signal_not_3;
    assign ready_o = signal_and_5;
    assign busy_o = reg_busy;
    assign complete_o = reg_complete;
    assign timeout_o = reg_timeout;
    assign rejected_o = reg_rejected;
    assign tick_o = reg_tick;
    assign remaining_o = reg_remaining;

endmodule
