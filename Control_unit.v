`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Peeranat Ngk. 3429
// 
// Create Date: 05/18/2026 03:01:55 PM
// Design Name: 
// Module Name: Control_unit
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


module Control_unit(
    input [3:0] opcode,
    input clk,
    input clr_n,
    output reg cp, ep, lm_n, ce_n, li_n, ei_n, la_n, ea, su, eu, lb_n, lo_n
    );
    
    parameter T0 = 3'd0, T1 = 3'd1, T2 = 3'd2,
              T3 = 3'd3, T4 = 3'd4, T5 = 3'd5;
              
    parameter LDR = 4'b0000, ADD = 4'b0001, SUB = 4'b0010, OUTA = 4'b0011, HLT = 4'b1111;
    
    reg [2:0] t_state = T0;
    
    always @(negedge clk or negedge clr_n) begin
        if (!clr_n) begin
            t_state <= T0;
        end else if (t_state == T5) begin
            t_state <= T0;
        end else begin
            t_state <= t_state + 1;
        end
    end
    
    always @(*) begin
        {cp, ep, ea, su, eu} = 5'b00000;
        {lm_n, ce_n, li_n, ei_n, la_n, lb_n, lo_n} = 7'b1111111;
        
        case (t_state)
            T0: begin ep = 1; lm_n = 0; end // MAR <= PC
            T1: begin cp = 1; end // PC <= PC + 1
            T2: begin ce_n = 0; li_n = 0; end // IR <= RAM
            T3: begin
                case (opcode)
                    LDR, ADD, SUB: begin // MAR <= IR
                        ei_n = 0;
                        lm_n = 0;
                    end
                    OUTA: begin // Output_reg <= RA
                        ea = 1;
                        lo_n = 0;
                    end
                endcase
            end
            T4: begin
                case (opcode)
                    LDR: begin // RA <= RAM
                        ce_n = 0;
                        la_n = 0;
                    end
                    ADD: begin // RB <= RAM
                        ce_n = 0;
                        lb_n = 0;
                    end
                    SUB: begin // RB <= RAM
                        ce_n = 0;
                        lb_n = 0;
                    end
                endcase
            end
            T5: begin
                case (opcode)
                    ADD: begin // RA <= ALU
                        eu = 1;
                        la_n = 0;
                    end
                    SUB: begin // RA <= ALU
                        su = 1; // enable SUB mode
                        eu = 1;
                        la_n = 0;
                    end
                endcase
            end
        endcase
    end
    
endmodule
