`timescale 1ns / 1ps

module CU_tb();

    // Clock and Control signals
    reg clk;
    reg reset;
    reg [3:0] opcode;
    wire [15:0] CW;

    // Instantiate CU
    CU uut (
        .opcode(opcode),
        .clk(clk),
        .reset(reset),
        .CW(CW)
    );

    // Control word bit definitions (matching CPU.v)
    localparam PE    = 15, // Program Counter Enable
               PO    = 14, // Program Counter Output
               MI    = 13, // MAR Input
               RO    = 12, // RAM Output
               II    = 11, // IR Input
               IO    = 10, // IR Output (address)
               AI    = 9,  // Register A Input
               AO    = 8,  // Register A Output
               EO    = 7,  // ALU Output
               CI    = 6,  // Register C Input
               S0    = 5,  // ALU Select 0
               S1    = 4,  // ALU Select 1
               BI    = 3,  // Register B Input
               BO    = 2,  // Register B Output
               OI    = 1,  // Output Register Input
               HLT_SIG = 0; // Halt Signal

    // Opcode definitions
    localparam LDR  = 4'b0000, 
               ADD  = 4'b0001, 
               SUB  = 4'b0010, 
               MUL  = 4'b0011, 
               DIV  = 4'b0100, 
               OUTA = 4'b0101, 
               OUTB = 4'b0110, 
               HLT  = 4'b0111;

    // State definitions
    localparam T0 = 3'd0, T1 = 3'd1, T2 = 3'd2, T3 = 3'd3, T4 = 3'd4, T5 = 3'd5;

    // Clock generation
    always #5 clk = ~clk;

    // Helper function to display state
    function string state_name(input [2:0] state);
        case(state)
            T0: return "T0 (Fetch1)";
            T1: return "T1 (Fetch2)";
            T2: return "T2 (Decode)";
            T3: return "T3 (Execute1)";
            T4: return "T4 (Execute2)";
            T5: return "T5 (Execute3)";
            default: return "Unknown";
        endcase
    endfunction

    // Helper function to decode CW
    function string decode_cw(input [15:0] cw);
        string result = "";
        if (cw[PE])   result = {result, "PE | "};
        if (cw[PO])   result = {result, "PO | "};
        if (cw[MI])   result = {result, "MI | "};
        if (cw[RO])   result = {result, "RO | "};
        if (cw[II])   result = {result, "II | "};
        if (cw[IO])   result = {result, "IO | "};
        if (cw[AI])   result = {result, "AI | "};
        if (cw[AO])   result = {result, "AO | "};
        if (cw[EO])   result = {result, "EO | "};
        if (cw[CI])   result = {result, "CI | "};
        if (cw[S0])   result = {result, "S0 | "};
        if (cw[S1])   result = {result, "S1 | "};
        if (cw[BI])   result = {result, "BI | "};
        if (cw[BO])   result = {result, "BO | "};
        if (cw[OI])   result = {result, "OI | "};
        if (cw[HLT_SIG]) result = {result, "HLT | "};
        if (cw == 16'h0000) result = "No controls";
        return result;
    endfunction

    initial begin
        clk = 0;
        reset = 0;
        opcode = 4'b0000;
        
        $display("\n========== CU TESTBENCH ==========\n");

        // Test 1: Reset
        $display("--- Test 1: Reset State ---");
        reset = 1;
        #10;
        reset = 0;
        $display("After reset, CW = %016b", CW);
        $display("Current state should be T0\n");

        // Test 2: LDR instruction (Load Register)
        $display("--- Test 2: LDR Instruction Cycle ---");
        opcode = LDR;
        repeat(12) begin
            $display("T-cycle | State: %s | CW: %s", 
                     state_name(uut.current_state), decode_cw(CW));
            #10;
        end
        $display("");

        // Test 3: ADD instruction
        $display("--- Test 3: ADD Instruction Cycle ---");
        opcode = ADD;
        repeat(18) begin
            $display("T-cycle | State: %s | CW: %s", 
                     state_name(uut.current_state), decode_cw(CW));
            #10;
        end
        $display("");

        // Test 4: SUB instruction
        $display("--- Test 4: SUB Instruction Cycle ---");
        opcode = SUB;
        repeat(18) begin
            $display("T-cycle | State: %s | CW: %s", 
                     state_name(uut.current_state), decode_cw(CW));
            #10;
        end
        $display("");

        // Test 5: MUL instruction
        $display("--- Test 5: MUL Instruction Cycle ---");
        opcode = MUL;
        repeat(18) begin
            $display("T-cycle | State: %s | CW: %s", 
                     state_name(uut.current_state), decode_cw(CW));
            #10;
        end
        $display("");

        // Test 6: DIV instruction
        $display("--- Test 6: DIV Instruction Cycle ---");
        opcode = DIV;
        repeat(18) begin
            $display("T-cycle | State: %s | CW: %s", 
                     state_name(uut.current_state), decode_cw(CW));
            #10;
        end
        $display("");

        // Test 7: OUTA instruction
        $display("--- Test 7: OUTA Instruction Cycle ---");
        opcode = OUTA;
        repeat(12) begin
            $display("T-cycle | State: %s | CW: %s", 
                     state_name(uut.current_state), decode_cw(CW));
            #10;
        end
        $display("");

        // Test 8: OUTB instruction
        $display("--- Test 8: OUTB Instruction Cycle ---");
        opcode = OUTB;
        repeat(12) begin
            $display("T-cycle | State: %s | CW: %s", 
                     state_name(uut.current_state), decode_cw(CW));
            #10;
        end
        $display("");

        // Test 9: HLT instruction (should stay in T3)
        $display("--- Test 9: HLT Instruction (Halt) ---");
        opcode = HLT;
        repeat(12) begin
            $display("T-cycle | State: %s | CW: %s", 
                     state_name(uut.current_state), decode_cw(CW));
            #10;
        end
        $display("HLT should hold in T3 state\n");

        $display("========== TESTBENCH COMPLETE ==========\n");
        $finish;
    end

endmodule