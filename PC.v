`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 3429
// 
// Create Date: 05/17/2026 09:59:04 PM
// Design Name: 
// Module Name: PC
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


module PC(
    input clk_n,
    input clr_n,
    input cp,
    input ep,
    output [3:0] bus_out
    );
    
    reg [3:0] count;
    
    always @(negedge clk_n or negedge clr_n) begin
        if (!clr_n) begin
            count <= 4'b0000;
        end else if (cp) begin
            count <= count + 1;        
        end
    end
    
    assign bus_out = (ep) ? count : 4'bzzzz;

endmodule
