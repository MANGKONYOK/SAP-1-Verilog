`timescale 1ns / 1ps

module RAM (
    input wire [3:0] address,
    output wire [7:0] data_out
);

    reg [7:0] memory [0:15];
    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            memory[i] = 8'b00000000;
        end

        $readmemb("RAM.mem", memory);
    end

    assign data_out = memory[address];

endmodule
