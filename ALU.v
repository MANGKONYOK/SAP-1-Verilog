`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 3429
// 
// Create Date: 05/18/2026 04:43:40 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [7:0] ra_in,
    input [7:0] rb_in,
    input su,
    input eu,
    output [7:0] bus_out
    );
    
    reg [7:0] result = 8'b0000_0000;
    reg [7:0] rb_mod = 8'b0000_0000;
    
    always @(*) begin 
        if (su) begin
            rb_mod = ~rb_in; // 1st-complement
        end else begin
            rb_mod = rb_in;
        end
        
        result = ra_in + rb_mod + su; // if (su) then +1 to make 2nd-complement; Using "+" cost FPGA to build an adder.
        
     end
    
    assign bus_out = (eu) ? result : 8'bzzzz_zzzz;
    
    
endmodule
