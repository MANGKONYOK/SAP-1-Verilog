`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2026 04:22:24 AM
// Design Name: 
// Module Name: Accumulator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Accumulator(
    input [7:0] bus_in,
    input la_n,
    input clk,
    input ea,
    output [7:0] alu_out,
    output [7:0] bus_out
    );
    
    reg [7:0] reg_a = 8'b0000_0000;
    
    always @(posedge clk) begin
        if (!la_n) begin
            reg_a <= bus_in;
        end
    end
    
    assign bus_out = (ea) ? reg_a : 8'bzzzz_zzzz;
    assign alu_out = reg_a;
    
endmodule
