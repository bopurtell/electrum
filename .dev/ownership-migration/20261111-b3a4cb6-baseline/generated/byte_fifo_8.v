module byte_fifo_8 (
    clock_i,
    reset_i,
    enable_i,
    push_valid_i,
    push_data_i,
    pop_ready_i,
    push_ready_o,
    pop_valid_o,
    pop_data_o,
    count_o,
    overflow_o,
    starvation_o
);

    input clock_i;
    input reset_i;
    input enable_i;
    input push_valid_i;
    input [7:0] push_data_i;
    input pop_ready_i;
    output push_ready_o;
    output pop_valid_o;
    output [7:0] pop_data_o;
    output [4:0] count_o;
    output overflow_o;
    output starvation_o;

    wire signal_const;
    wire signal_const_1;
    wire signal_not;
    wire signal_and;
    wire signal_mux;
    wire signal_mux_1;
    wire signal_wire;
    reg reg_starvation;
    wire signal_not_1;
    wire signal_and_1;
    wire signal_mux_2;
    wire signal_mux_3;
    wire signal_wire_1;
    reg reg_overflow;
    wire [7:0] signal_const_4;
    wire [3:0] signal_const_12;
    wire signal_eq;
    wire signal_and_2;
    reg [7:0] signal_reg;
    wire [3:0] signal_const_13;
    wire signal_eq_1;
    wire signal_and_3;
    reg [7:0] signal_reg_1;
    wire [3:0] signal_const_14;
    wire signal_eq_2;
    wire signal_and_4;
    reg [7:0] signal_reg_2;
    wire [3:0] signal_const_15;
    wire signal_eq_3;
    wire signal_and_5;
    reg [7:0] signal_reg_3;
    wire [3:0] signal_const_16;
    wire signal_eq_4;
    wire signal_and_6;
    reg [7:0] signal_reg_4;
    wire [3:0] signal_const_17;
    wire signal_eq_5;
    wire signal_and_7;
    reg [7:0] signal_reg_5;
    wire [3:0] signal_const_18;
    wire signal_eq_6;
    wire signal_and_8;
    reg [7:0] signal_reg_6;
    wire [3:0] signal_const_19;
    wire [3:0] signal_add;
    wire signal_eq_7;
    wire [3:0] signal_mux_4;
    wire [3:0] signal_mux_5;
    wire [3:0] signal_mux_6;
    wire [3:0] signal_wire_2;
    reg [3:0] reg_write_index;
    wire signal_eq_8;
    wire signal_and_9;
    wire [7:0] signal_wire_3;
    reg [7:0] signal_reg_7;
    wire [3:0] signal_add_1;
    wire signal_eq_9;
    wire [3:0] signal_mux_7;
    wire [3:0] signal_mux_8;
    wire [3:0] signal_mux_9;
    wire [3:0] signal_wire_4;
    reg [3:0] reg_read_index;
    reg [7:0] signal_mux_10;
    wire [7:0] signal_mux_11;
    wire [4:0] signal_const_31;
    wire [4:0] signal_const_32;
    wire signal_wire_5;
    wire signal_wire_6;
    wire [4:0] signal_const_34;
    wire [4:0] signal_sub;
    wire [4:0] signal_add_2;
    wire signal_not_2;
    wire signal_and_10;
    wire [4:0] signal_mux_12;
    wire signal_wire_7;
    wire signal_and_11;
    wire signal_not_3;
    wire signal_wire_8;
    wire signal_eq_10;
    wire signal_not_4;
    wire signal_and_12;
    wire signal_and_13;
    wire signal_and_14;
    wire [4:0] signal_mux_13;
    wire signal_not_5;
    wire [4:0] signal_mux_14;
    wire [4:0] signal_wire_9;
    reg [4:0] reg_count;
    wire signal_lt;
    wire signal_or;
    wire signal_wire_10;
    wire signal_and_15;
    assign signal_const = 1'b0;
    assign signal_const_1 = 1'b1;
    assign signal_not = ~ signal_and_12;
    assign signal_and = signal_wire_8 & signal_not;
    assign signal_mux = signal_and ? signal_const_1 : reg_starvation;
    assign signal_mux_1 = signal_not_5 ? reg_starvation : signal_mux;
    assign signal_wire = signal_mux_1;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_starvation <= signal_const;
        else
            reg_starvation <= signal_wire;
    end
    assign signal_not_1 = ~ signal_and_15;
    assign signal_and_1 = signal_wire_7 & signal_not_1;
    assign signal_mux_2 = signal_and_1 ? signal_const_1 : reg_overflow;
    assign signal_mux_3 = signal_not_5 ? reg_overflow : signal_mux_2;
    assign signal_wire_1 = signal_mux_3;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_overflow <= signal_const;
        else
            reg_overflow <= signal_wire_1;
    end
    assign signal_const_4 = 8'b00000000;
    assign signal_const_12 = 4'b0111;
    assign signal_eq = reg_write_index == signal_const_12;
    assign signal_and_2 = signal_and_11 & signal_eq;
    always @(posedge signal_wire_6) begin
        if (signal_and_2)
            signal_reg <= signal_wire_3;
    end
    assign signal_const_13 = 4'b0110;
    assign signal_eq_1 = reg_write_index == signal_const_13;
    assign signal_and_3 = signal_and_11 & signal_eq_1;
    always @(posedge signal_wire_6) begin
        if (signal_and_3)
            signal_reg_1 <= signal_wire_3;
    end
    assign signal_const_14 = 4'b0101;
    assign signal_eq_2 = reg_write_index == signal_const_14;
    assign signal_and_4 = signal_and_11 & signal_eq_2;
    always @(posedge signal_wire_6) begin
        if (signal_and_4)
            signal_reg_2 <= signal_wire_3;
    end
    assign signal_const_15 = 4'b0100;
    assign signal_eq_3 = reg_write_index == signal_const_15;
    assign signal_and_5 = signal_and_11 & signal_eq_3;
    always @(posedge signal_wire_6) begin
        if (signal_and_5)
            signal_reg_3 <= signal_wire_3;
    end
    assign signal_const_16 = 4'b0011;
    assign signal_eq_4 = reg_write_index == signal_const_16;
    assign signal_and_6 = signal_and_11 & signal_eq_4;
    always @(posedge signal_wire_6) begin
        if (signal_and_6)
            signal_reg_4 <= signal_wire_3;
    end
    assign signal_const_17 = 4'b0010;
    assign signal_eq_5 = reg_write_index == signal_const_17;
    assign signal_and_7 = signal_and_11 & signal_eq_5;
    always @(posedge signal_wire_6) begin
        if (signal_and_7)
            signal_reg_5 <= signal_wire_3;
    end
    assign signal_const_18 = 4'b0001;
    assign signal_eq_6 = reg_write_index == signal_const_18;
    assign signal_and_8 = signal_and_11 & signal_eq_6;
    always @(posedge signal_wire_6) begin
        if (signal_and_8)
            signal_reg_6 <= signal_wire_3;
    end
    assign signal_const_19 = 4'b0000;
    assign signal_add = reg_write_index + signal_const_18;
    assign signal_eq_7 = reg_write_index == signal_const_12;
    assign signal_mux_4 = signal_eq_7 ? signal_const_19 : signal_add;
    assign signal_mux_5 = signal_and_11 ? signal_mux_4 : reg_write_index;
    assign signal_mux_6 = signal_not_5 ? signal_const_19 : signal_mux_5;
    assign signal_wire_2 = signal_mux_6;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_write_index <= signal_const_19;
        else
            reg_write_index <= signal_wire_2;
    end
    assign signal_eq_8 = reg_write_index == signal_const_19;
    assign signal_and_9 = signal_and_11 & signal_eq_8;
    assign signal_wire_3 = push_data_i;
    always @(posedge signal_wire_6) begin
        if (signal_and_9)
            signal_reg_7 <= signal_wire_3;
    end
    assign signal_add_1 = reg_read_index + signal_const_18;
    assign signal_eq_9 = reg_read_index == signal_const_12;
    assign signal_mux_7 = signal_eq_9 ? signal_const_19 : signal_add_1;
    assign signal_mux_8 = signal_and_13 ? signal_mux_7 : reg_read_index;
    assign signal_mux_9 = signal_not_5 ? signal_const_19 : signal_mux_8;
    assign signal_wire_4 = signal_mux_9;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_read_index <= signal_const_19;
        else
            reg_read_index <= signal_wire_4;
    end
    always @* begin
        case (reg_read_index)
        0:
            signal_mux_10 <= signal_reg_7;
        1:
            signal_mux_10 <= signal_reg_6;
        2:
            signal_mux_10 <= signal_reg_5;
        3:
            signal_mux_10 <= signal_reg_4;
        4:
            signal_mux_10 <= signal_reg_3;
        5:
            signal_mux_10 <= signal_reg_2;
        6:
            signal_mux_10 <= signal_reg_1;
        7:
            signal_mux_10 <= signal_reg;
        8:
            signal_mux_10 <= signal_const_4;
        9:
            signal_mux_10 <= signal_const_4;
        10:
            signal_mux_10 <= signal_const_4;
        11:
            signal_mux_10 <= signal_const_4;
        12:
            signal_mux_10 <= signal_const_4;
        13:
            signal_mux_10 <= signal_const_4;
        14:
            signal_mux_10 <= signal_const_4;
        default:
            signal_mux_10 <= signal_const_4;
        endcase
    end
    assign signal_mux_11 = signal_not_4 ? signal_mux_10 : signal_const_4;
    assign signal_const_31 = 5'b01000;
    assign signal_const_32 = 5'b00000;
    assign signal_wire_5 = reset_i;
    assign signal_wire_6 = clock_i;
    assign signal_const_34 = 5'b00001;
    assign signal_sub = reg_count - signal_const_34;
    assign signal_add_2 = reg_count + signal_const_34;
    assign signal_not_2 = ~ signal_and_13;
    assign signal_and_10 = signal_and_11 & signal_not_2;
    assign signal_mux_12 = signal_and_10 ? signal_add_2 : reg_count;
    assign signal_wire_7 = push_valid_i;
    assign signal_and_11 = signal_wire_7 & signal_and_15;
    assign signal_not_3 = ~ signal_and_11;
    assign signal_wire_8 = pop_ready_i;
    assign signal_eq_10 = reg_count == signal_const_32;
    assign signal_not_4 = ~ signal_eq_10;
    assign signal_and_12 = signal_wire_10 & signal_not_4;
    assign signal_and_13 = signal_and_12 & signal_wire_8;
    assign signal_and_14 = signal_and_13 & signal_not_3;
    assign signal_mux_13 = signal_and_14 ? signal_sub : signal_mux_12;
    assign signal_not_5 = ~ signal_wire_10;
    assign signal_mux_14 = signal_not_5 ? signal_const_32 : signal_mux_13;
    assign signal_wire_9 = signal_mux_14;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_count <= signal_const_32;
        else
            reg_count <= signal_wire_9;
    end
    assign signal_lt = reg_count < signal_const_31;
    assign signal_or = signal_lt | signal_and_13;
    assign signal_wire_10 = enable_i;
    assign signal_and_15 = signal_wire_10 & signal_or;
    assign push_ready_o = signal_and_15;
    assign pop_valid_o = signal_and_12;
    assign pop_data_o = signal_mux_11;
    assign count_o = reg_count;
    assign overflow_o = reg_overflow;
    assign starvation_o = reg_starvation;

endmodule
