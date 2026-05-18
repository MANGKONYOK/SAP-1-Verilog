`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 3429
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
// Additional Comments: Generated code - Please recheck
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_CPU();

    // Inputs to the CPU are 'reg' so we can control them in the testbench
    reg clk;
    reg reset_n;
    
    // Outputs from the CPU are 'wire' so we can look at them
    wire [7:0] out_leds;

    // Instantiate the Top-Level CPU
    CPU my_sap1 (
        .clk(clk),
        .reset_n(reset_n),
        .out_leds(out_leds)
    );

    // ---------------------------------------------------------
    // VIRTUAL CLOCK GENERATOR
    // Flips the clock signal every 5 nanoseconds forever
    // ---------------------------------------------------------
    always #5 clk = ~clk;

    // ---------------------------------------------------------
    // SIMULATION SEQUENCE
    // ---------------------------------------------------------
    initial begin
        // 1. Initialize variables
        clk = 0;
        reset_n = 0; // Press the virtual reset button!
        
        // 2. Wait 20 nanoseconds for the modules to clear
        #20;
        
        // 3. Release the reset button to start the CPU
        reset_n = 1;
        
        // 4. Let the simulation run for 2000 nanoseconds 
        // (Enough time to fetch and execute several instructions)
        #2000;
        
        // 5. Stop the Vivado simulation automatically
        $finish; 
    end

endmodule
