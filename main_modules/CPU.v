module CPU (
    input wire CLK,
    input wire RESET,
    output wire [7:0] OUT_DATA
);

    // -------------------------------------------------------------------------
    // 1. Control Word and Control Signals
    // -------------------------------------------------------------------------
    wire [15:0] CTRL_WORD;
    
    // Control Word Split: {PE, PO, MI, RO, II, IO, AI, AO, EO, CI, S0, S1, BI, BO, OI, HLT}
    wire PE  = CTRL_WORD[15];
    wire PO  = CTRL_WORD[14];
    wire MI  = CTRL_WORD[13];
    wire RO  = CTRL_WORD[12];
    wire II  = CTRL_WORD[11];
    wire IO  = CTRL_WORD[10];
    wire AI  = CTRL_WORD[9];
    wire AO  = CTRL_WORD[8];
    wire EO  = CTRL_WORD[7];
    wire CI  = CTRL_WORD[6];
    wire S0  = CTRL_WORD[5];
    wire S1  = CTRL_WORD[4];
    wire BI  = CTRL_WORD[3];
    wire BO  = CTRL_WORD[2];
    wire OI  = CTRL_WORD[1];
    wire HLT = CTRL_WORD[0];

    // -------------------------------------------------------------------------
    // 2. Internal Wires (Buses and Data Lines)
    // -------------------------------------------------------------------------
    wire [7:0] W_bus;
    
    wire [3:0] pc_out;
    wire [3:0] mar_out;
    wire [7:0] ram_out;
    wire [3:0] ir_opcode;
    wire [3:0] ir_addr;
    wire [7:0] regA_out;
    wire [7:0] regB_out;
    wire [7:0] regC_out;
    wire [7:0] alu_out;

    // -------------------------------------------------------------------------
    // 3. Mux-Based W-Bus Implementation
    // -------------------------------------------------------------------------
    assign W_bus = (PO) ? {4'b0000, pc_out} :
                   (IO) ? {4'b0000, ir_addr} :
                   (RO) ? ram_out :
                   (AO) ? regA_out :
                   (BO) ? regB_out :
                   (EO) ? alu_out  :
                   8'b00000000;

    // -------------------------------------------------------------------------
    // 4. Sub-Module Instantiations
    // -------------------------------------------------------------------------
    
    // Program Counter (PC)
    PC u_PC (
        .CLK(CLK),
        .RESET(RESET),
        .PE(PE),
        .pc_out(pc_out)
    );

    // Memory Address Register (MAR)
    MAR u_MAR (
        .CLK(CLK),
        .MI(MI),
        .data_in(W_bus[3:0]), // Lower 4 bits from W-bus
        .mar_out(mar_out)
    );

    // RAM (Memory)
    RAM u_RAM (
        .addr(mar_out),
        .data_out(ram_out) // Connected to W-Bus via Mux when RO=1
    );

    // Instruction Register (IR)
    IR u_IR (
        .CLK(CLK),
        .RESET(RESET),
        .II(II),
        .data_in(W_bus),
        .ir_opcode(ir_opcode),
        .ir_addr(ir_addr)
    );

    // Control Unit (CU)
    // Triggering on negative edge or utilizing inverted clock internally
    wire inv_CLK = ~CLK;
    CU u_CU (
        .opcode(ir_opcode),
        .CLK(inv_CLK), 
        .RESET(RESET),
        .CTRL_WORD(CTRL_WORD)
    );

    // Register A
    Register u_RegA (
        .CLK(CLK),
        .RESET(RESET),
        .Load_Enable(AI),
        .data_in(W_bus),
        .reg_out(regA_out)
    );

    // Register B
    Register u_RegB (
        .CLK(CLK),
        .RESET(RESET),
        .Load_Enable(BI),
        .data_in(W_bus),
        .reg_out(regB_out)
    );

    // Register C (Directly loaded from ALU as per modified spec)
    // Note: If CI is active, it takes from ALU, otherwise keeps old value
    Register u_RegC (
        .CLK(CLK),
        .RESET(RESET),
        .Load_Enable(CI),
        .data_in(alu_out), // Directly from ALU!
        .reg_out(regC_out)
    );

    // ALU
    ALU u_ALU (
        .A(regA_out),
        .C(regC_out),
        .S({S1, S0}),
        .alu_out(alu_out)
    );

    // Output Register (OUT)
    Register u_RegOUT (
        .CLK(CLK),
        .RESET(RESET),
        .Load_Enable(OI),
        .data_in(W_bus),
        .reg_out(OUT_DATA)
    );

endmodule
