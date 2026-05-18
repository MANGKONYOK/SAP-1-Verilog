`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 05/18/2026 05:35:47 PM
// Design Name: 
// Module Name: CPU
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


module CPU (
    input clk,
    input reset_n,
    output [7:0] out_leds
);

    wire [7:0] w_bus;

    wire [3:0] mar_to_ram;     
    wire [3:0] ir_opcode;      
    wire [7:0] accum_to_alu;   
    wire [7:0] regb_to_alu;    

    wire cp, ep, lm_n, ce_n, li_n, ei_n, la_n, ea, su, mu, di, eu, lb_n, lo_n;

    Control_unit CU (
        .clk(clk),
        .clr_n(reset_n),
        .opcode(ir_opcode),
        .cp(cp), .ep(ep), .lm_n(lm_n), .ce_n(ce_n), .li_n(li_n), 
        .ei_n(ei_n), .la_n(la_n), .ea(ea), .su(su), .mu(mu), .di(di),
        .eu(eu), .lb_n(lb_n), .lo_n(lo_n)
    );

    PC PC (
        .clk_n(clk),
        .clr_n(reset_n),
        .cp(cp),
        .ep(ep),
        .bus_out(w_bus[3:0])
    );

    MAR MAR (
        .clk(clk),
        .lm_n(lm_n),
        .bus_in(w_bus[3:0]), 
        .addr_out(mar_to_ram)
    );

    RAM MEMORY (
        .addr_in(mar_to_ram),
        .ce_n(ce_n),
        .bus_out(w_bus)  
    );

    IR INSTRUCTION_REG (
        .clk(clk),
        .clr(~reset_n),  
        .li_n(li_n),
        .ei_n(ei_n),
        .bus_in(w_bus),
        .opcode(ir_opcode),
        .bus_out(w_bus)  
    );

    Accumulator ACCUM (
        .clk(clk),
        .la_n(la_n),
        .ea(ea),
        .bus_in(w_bus),
        .alu_out(accum_to_alu),
        .bus_out(w_bus)  
    );

    B_register B_REG (
        .clk(clk),
        .lb_n(lb_n),
        .bus_in(w_bus),
        .alu_out(regb_to_alu)
    );

    ALU MATH_UNIT (
        .ra_in(accum_to_alu),
        .rb_in(regb_to_alu),
        .su(su),
        .mu(mu),
        .di(di),
        .eu(eu),
        .bus_out(w_bus)  
    );

    Output_registor OUT_REG (
        .clk(clk),
        .lo_n(lo_n),
        .bus_in(w_bus),
        .display_out(out_leds) 
    );

endmodule
