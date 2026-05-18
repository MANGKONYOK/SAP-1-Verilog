`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 3429
// 
// Create Date: 05/17/2026 11:33:53 PM
// Design Name: 
// Module Name: RAM
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


module RAM(
    input [3:0] addr_in,
    input ce_n,
    output [7:0] bus_out
    );
    
    reg [7:0] memory [0:15];
    
    initial begin
        $readmemb("RAM.mem", memory);
    end
    
    assign bus_out = (!ce_n) ? memory[addr_in] : 8'bzzzz_zzzz;
    
endmodule
