`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 
// 
// Create Date: 05/18/2026 05:16:22 AM
// Design Name: 
// Module Name: Output_registor
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


module Output_registor(
    input [7:0] bus_in,
    input lo_n,
    input clk,
    output [7:0] display_out
    );
    
    reg [7:0] reg_dis = 8'b0000_0000;
    
    always @(posedge clk) begin
        if (!lo_n) begin
            reg_dis <= bus_in;
        end
    end
    
    assign display_out = reg_dis;
    
endmodule
