`timescale 1ns / 1ps

module CPU_tb();

    // Declare testbench signals
    reg clk;
    reg reset;
    wire [7:0] out;

    // Instantiate top module
    CPU uut_CPU (clk, reset, out);

    // Create master clock
    always begin
        #5 clk = ~clk;
    end

    // Initial block for test
    initial begin
        // Waveform generation
        $dumpfile("cpu_waveforms.vcd");
        $dumpvars(0, CPU_tb);

        // Initialize clock
        clk = 0;

        // Reset
        // Assert 'reset' high to clear registers
        reset = 1;
        #20; 
        
        // Release 'reset' to start machine execution
        reset = 0;

        // Simulation run for enough time to execute the short program
        #888;
        
        // Finish
        $display("Simulation Succeeded.");
        $finish;
    end

endmodule