module CU (
    input clk,
    input reset,
    input [3:0] opcode,
    output reg [15:0] CW
);

    // Determine state (T0 - T5)
    parameter T0 = 3'd0, T1 = 3'd1, T2 = 3'd2, 
              T3 = 3'd3, T4 = 3'd4, T5 = 3'd5;

    // Determine opcode
    parameter LDR = 4'b0000, ADD = 4'b0001, SUB = 4'b0010, MUL = 4'b0011, 
              DIV = 4'b0100, OUTA = 4'b0101, OUTB = 4'b0110, HLT = 4'b0111;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= T0;
        else
            current_state <= next_state;
    end

    // ยังไม่เสร็จ