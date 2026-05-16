`timescale 1ns / 1ps

module MAR (
    input wire clk,
    input wire load,
    input wire [3:0] data_in,
    output reg [3:0] address
);

    initial begin
        address = 4'b0000;
    end

    always @(posedge clk) begin
        if (load) begin
            address <= data_in;
        end
    end

endmodule
