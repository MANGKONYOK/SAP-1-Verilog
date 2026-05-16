`timescale 1ns / 1ps

module IR (
    input wire clk,
    input wire reset,
    input wire load,
    input wire [7:0] data_in,
    output wire [3:0] opcode,
    output wire [3:0] address
);

    reg [7:0] instruction;

    assign opcode = instruction[7:4];
    assign address = instruction[3:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction <= 8'b00000000;
        end else if (load) begin
            instruction <= data_in;
        end
    end

endmodule
