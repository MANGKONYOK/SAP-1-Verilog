`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 3429
// 
// Create Date: 05/18/2026 01:21:52 AM
// Design Name: 
// Module Name: IR
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


module IR(
    input [7:0] bus_in,
    input li_n,
    input clk,
    input clr,
    input ei_n,
    output [3:0] opcode,
    output [7:0] bus_out
    );
    
    reg [7:0] ir_reg;
    
    always @(posedge clk or posedge clr) begin
        if (clr) begin
            ir_reg <= 8'b0000_0000;
        end else if (!li_n) begin
            ir_reg <= bus_in;
        end
    end
    
    assign opcode = ir_reg[7:4];
    assign bus_out = (!ei_n) ? {4'bzzzz, ir_reg[3:0]} : 8'bzzzz_zzzz;
    
endmodule
