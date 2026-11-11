module input_events (
    clock_i,
    reset_i,
    pin_in_i,
    event_set_i,
    event_ack_i,
    snapshot_o,
    rising_o,
    falling_o,
    event_o,
    overflow_o
);

    input clock_i;
    input reset_i;
    input [7:0] pin_in_i;
    input [5:0] event_set_i;
    input [5:0] event_ack_i;
    output [7:0] snapshot_o;
    output [7:0] rising_o;
    output [7:0] falling_o;
    output [5:0] event_o;
    output [5:0] overflow_o;

    wire [5:0] signal_const;
    wire [5:0] signal_not;
    wire [5:0] signal_and;
    wire [5:0] signal_and_1;
    wire [5:0] signal_not_1;
    wire [5:0] signal_and_2;
    wire [5:0] signal_or;
    wire [5:0] signal_wire;
    reg [5:0] reg_overflow;
    wire [5:0] signal_wire_1;
    wire [5:0] signal_wire_2;
    wire [5:0] signal_not_2;
    wire [5:0] signal_and_3;
    wire [5:0] signal_or_1;
    wire [5:0] signal_wire_3;
    reg [5:0] reg_event;
    wire [7:0] signal_not_3;
    wire [7:0] signal_and_4;
    wire [7:0] signal_const_2;
    wire [7:0] signal_wire_4;
    reg [7:0] reg_previous;
    wire [7:0] signal_not_4;
    wire [7:0] signal_and_5;
    wire signal_wire_5;
    wire signal_wire_6;
    wire [7:0] signal_wire_7;
    wire [7:0] signal_wire_8;
    reg [7:0] reg_stage0;
    wire [7:0] signal_wire_9;
    reg [7:0] reg_stage1;
    assign signal_const = 6'b000000;
    assign signal_not = ~ signal_wire_2;
    assign signal_and = reg_event & signal_wire_1;
    assign signal_and_1 = signal_and & signal_not;
    assign signal_not_1 = ~ signal_wire_2;
    assign signal_and_2 = reg_overflow & signal_not_1;
    assign signal_or = signal_and_2 | signal_and_1;
    assign signal_wire = signal_or;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_overflow <= signal_const;
        else
            reg_overflow <= signal_wire;
    end
    assign signal_wire_1 = event_set_i;
    assign signal_wire_2 = event_ack_i;
    assign signal_not_2 = ~ signal_wire_2;
    assign signal_and_3 = reg_event & signal_not_2;
    assign signal_or_1 = signal_and_3 | signal_wire_1;
    assign signal_wire_3 = signal_or_1;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_event <= signal_const;
        else
            reg_event <= signal_wire_3;
    end
    assign signal_not_3 = ~ reg_stage1;
    assign signal_and_4 = signal_not_3 & reg_previous;
    assign signal_const_2 = 8'b00000000;
    assign signal_wire_4 = reg_stage1;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_previous <= signal_const_2;
        else
            reg_previous <= signal_wire_4;
    end
    assign signal_not_4 = ~ reg_previous;
    assign signal_and_5 = reg_stage1 & signal_not_4;
    assign signal_wire_5 = reset_i;
    assign signal_wire_6 = clock_i;
    assign signal_wire_7 = pin_in_i;
    assign signal_wire_8 = signal_wire_7;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_stage0 <= signal_const_2;
        else
            reg_stage0 <= signal_wire_8;
    end
    assign signal_wire_9 = reg_stage0;
    always @(posedge signal_wire_6) begin
        if (signal_wire_5)
            reg_stage1 <= signal_const_2;
        else
            reg_stage1 <= signal_wire_9;
    end
    assign snapshot_o = reg_stage1;
    assign rising_o = signal_and_5;
    assign falling_o = signal_and_4;
    assign event_o = reg_event;
    assign overflow_o = reg_overflow;

endmodule
