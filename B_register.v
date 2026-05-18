`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 3429
// 
// Create Date: 05/18/2026 04:47:49 AM
// Design Name: 
// Module Name: B_register
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


module B_register(
    input [7:0] bus_in,
    input lb_n,
    input clk,
    output alu_out
    );
    
    reg [7:0] reg_b = 8'b0000_0000;
    
    always @(posedge clk) begin
        if (!lb_n) begin
            reg_b <= bus_in;
        end
    end
    
    assign alu_out = reg_b;
    
endmodule
