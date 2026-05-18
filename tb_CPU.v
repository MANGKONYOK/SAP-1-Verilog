`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 05/18/2026 05:40:18 PM
// Design Name: 
// Module Name: tb_CPU
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


module tb_CPU();

    reg clk;
    reg reset_n;
    
    wire [7:0] out_leds;

    CPU my_sap1 (
        .clk(clk),
        .reset_n(reset_n),
        .out_leds(out_leds)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset_n = 0;
        
        #20;
        
        reset_n = 1;
        
        #2000;
        
        $finish; 
    end

endmodule
