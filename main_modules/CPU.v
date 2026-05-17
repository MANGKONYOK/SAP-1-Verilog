module CPU (
    input wire clk,
    input wire reset,
    output wire [7:0] out
);
    // Control word and Control Signals
    wire [15:0] CW;
    
    // Control Words: PE, PO, MI, RO, II, IO, AI, AO, EO, CI, S0, S1, BI, BO, OI, HLT
    wire PE  = CW[15];
    wire PO  = CW[14];
    wire MI  = CW[13];
    wire RO  = CW[12];
    wire II  = CW[11];
    wire IO  = CW[10];
    wire AI  = CW[9];
    wire AO  = CW[8];
    wire EO  = CW[7];
    wire CI  = CW[6];
    wire S0  = CW[5];
    wire S1  = CW[4];
    wire BI  = CW[3];
    wire BO  = CW[2];
    wire OI  = CW[1];
    wire HLT = CW[0];

    // Internal wires
    wire [7:0] W_bus;
    
    wire [3:0] PC_out;
    wire [3:0] MAR_out;
    wire [7:0] RAM_out;
    wire [3:0] IR_opcode;
    wire [3:0] IR_addr;
    wire [7:0] RA_out;
    wire [7:0] RB_out;
    wire [7:0] RC_out;
    wire [7:0] ALU_out;
    wire [7:0] ALU_upper; // Upper 8 bits from MUL/DIV

    // W-Bus Implementation
    assign W_bus = (PO) ? {4'b0000, PC_out} :
                   (IO) ? {4'b0000, IR_addr} :
                   (RO) ? RAM_out :
                   (AO) ? RA_out :
                   (BO) ? RB_out :
                   (EO) ? ALU_out  :
                   8'b00000000;

    // Sub-Module Instantiations
    
    // Program Counter (PC)
    PC uut_PC (clk, reset, PE, PC_out);

    // Memory Address Register (MAR)
    MAR uut_MAR (clk, MI, W_bus[3:0], MAR_out);

    // RAM (Memory)
    RAM uut_RAM (MAR_out, RAM_out);

    // Instruction Register (IR)
    IR uut_IR (clk, reset, II, W_bus, IR_opcode, IR_addr);

    // Control Unit (CU)
    // Triggering on negative edge or utilizing inverted clock
    wire inv_clk = ~clk;
    CU uut_CU (IR_opcode, inv_clk, reset, CW);

    // Register A
    Register uut_Ra (clk, reset, AI, W_bus, RA_out);

    // Register B (Directly loaded from ALU's exceed/upper output as per diagram)
    // Note: If BI is active, it takes the upper 8-bits from ALU (for MUL/DIV)
    Register uut_Rb (clk, reset, BI, ALU_upper, RB_out);

    // Register C
    Register uut_Rc (clk, reset, CI, W_bus, RC_out);

    // ALU (Outputs lower 8-bits to W_bus via EO, and upper 8-bits to Reg B)
    ALU uut_ALU (RA_out, RC_out, {S1, S0}, ALU_out, ALU_upper);

    // Output Register (OUT)
    Register uut_Output (clk, reset, OI, W_bus, out);

endmodule