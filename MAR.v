`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 3429
// 
// Create Date: 05/17/2026 11:13:47 PM
// Design Name: 
// Module Name: MAR
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


module MAR(
    input [3:0] bus_in,
    input lm_n,
    input clk,
    output [3:0] addr_out
    );
    
    reg [3:0] addr = 4'b0000;
    
    always @(posedge clk) begin
        if (!lm_n) begin
            addr <= bus_in;
        end
    end
    
    assign addr_out = addr;
    
endmodule
