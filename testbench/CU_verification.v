`timescale 1ns / 1ps

module CU_verification();

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

    // Control word bit definitions
    localparam PE    = 15, PO    = 14, MI    = 13, RO    = 12,
               II    = 11, IO    = 10, AI    = 9,  AO    = 8,
               EO    = 7,  CI    = 6,  S0    = 5,  S1    = 4,
               BI    = 3,  BO    = 2,  OI    = 1,  HLT_SIG = 0;

    // Opcode definitions
    localparam LDR = 4'b0000, ADD = 4'b0001, SUB = 4'b0010, MUL = 4'b0011,
               DIV = 4'b0100, OUTA = 4'b0101, OUTB = 4'b0110, HLT = 4'b0111;

    // State definitions
    localparam T0 = 3'd0, T1 = 3'd1, T2 = 3'd2, T3 = 3'd3, T4 = 3'd4, T5 = 3'd5;

    // Clock generation
    always #5 clk = ~clk;

    // Verification counters
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;

    // Task to check control signal
    task check_signal(string signal_name, integer bit_pos, bit expected);
        begin
            if (CW[bit_pos] == expected) begin
                $display("  ✓ %s: %b (expected: %b)", signal_name, CW[bit_pos], expected);
                pass_count = pass_count + 1;
            end else begin
                $display("  ✗ %s: %b (expected: %b)", signal_name, CW[bit_pos], expected);
                fail_count = fail_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask

    // Task to run a test cycle
    task test_cycle(string test_name, reg [3:0] test_opcode, reg [2:0] expected_state);
        begin
            opcode = test_opcode;
            #10;
            if (uut.current_state == expected_state) begin
                $display("PASS: %s - State: %b", test_name, expected_state);
            end else begin
                $display("FAIL: %s - Expected State: %b, Got: %b", 
                         test_name, expected_state, uut.current_state);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 0;
        opcode = LDR;

        $display("\n========================================");
        $display("    CU CONTROL UNIT VERIFICATION TEST    ");
        $display("========================================\n");

        // Test 1: Reset Behavior
        $display("\n--- TEST 1: Reset Behavior ---");
        reset = 1;
        #10;
        if (uut.current_state == T0) begin
            $display("PASS: Reset brings state to T0");
        end else begin
            $display("FAIL: Reset state is %b, expected T0", uut.current_state);
        end
        reset = 0;
        #10;

        // Test 2: LDR (Load Register) - 4 cycles (T0->T1->T2->T3 with early exit to T0)
        $display("\n--- TEST 2: LDR Instruction Control Signals ---");
        opcode = LDR;
        
        // T0: Should have PO and MI
        $display("T0 cycle:");
        check_signal("PO", PO, 1);
        check_signal("MI", MI, 1);
        #10;

        // T1: Should have RO and II
        $display("T1 cycle:");
        check_signal("RO", RO, 1);
        check_signal("II", II, 1);
        #10;

        // T2: Should be 0 (Decode)
        $display("T2 cycle (Decode):");
        check_signal("CW should be 0", 0, (CW == 16'h0000) ? 1 : 0);
        #10;

        // T3: Should have IO and MI
        $display("T3 cycle (Execute):");
        check_signal("IO", IO, 1);
        check_signal("MI", MI, 1);
        #10;

        // T4: Should have RO and AI
        $display("T4 cycle (Execute):");
        check_signal("RO", RO, 1);
        check_signal("AI", AI, 1);
        #10;

        // Test 3: ADD Instruction
        $display("\n--- TEST 3: ADD Instruction Control Signals ---");
        opcode = ADD;
        
        // T0: Should have PO and MI
        $display("T0 cycle:");
        check_signal("PO", PO, 1);
        check_signal("MI", MI, 1);
        #10;

        // T1: Should have RO and II
        $display("T1 cycle:");
        check_signal("RO", RO, 1);
        check_signal("II", II, 1);
        #10;

        // T2: Should be 0 (Decode)
        $display("T2 cycle (Decode):");
        check_signal("CW should be 0", 0, (CW == 16'h0000) ? 1 : 0);
        #10;

        // T3: Should have IO and MI
        $display("T3 cycle:");
        check_signal("IO", IO, 1);
        check_signal("MI", MI, 1);
        #10;

        // T4: Should have RO and BI
        $display("T4 cycle:");
        check_signal("RO", RO, 1);
        check_signal("BI", BI, 1);
        #10;

        // T5: Should have EO and AI (S0=0, S1=0 for ADD)
        $display("T5 cycle (Execute ALU):");
        check_signal("EO", EO, 1);
        check_signal("AI", AI, 1);
        check_signal("S0", S0, 0);
        check_signal("S1", S1, 0);
        #10;

        // Test 4: SUB Instruction
        $display("\n--- TEST 4: SUB Instruction Control Signals ---");
        opcode = SUB;
        
        // Skip to T5 (same as ADD for T0-T4)
        repeat(5) #10;
        
        // T5: Should have EO, AI, and S0=1, S1=0 for SUB
        $display("T5 cycle (Execute ALU - Subtract):");
        check_signal("EO", EO, 1);
        check_signal("AI", AI, 1);
        check_signal("S0", S0, 1);  // S0=1 for subtraction
        check_signal("S1", S1, 0);
        #10;

        // Test 5: HLT Instruction
        $display("\n--- TEST 5: HLT (Halt) Instruction ---");
        opcode = HLT;
        
        // Skip to T3
        repeat(3) #10;
        
        // T3: Should be 0
        $display("T3 cycle:");
        check_signal("CW should be 0", 0, (CW == 16'h0000) ? 1 : 0);
        #10;

        // T4: Should have HLT signal
        $display("T4 cycle:");
        check_signal("HLT", HLT_SIG, 1);
        #10;

        // T5: Should still have HLT signal
        $display("T5 cycle:");
        check_signal("HLT", HLT_SIG, 1);
        #10;

        // Check that state loops back to T3 (not T0) for HLT
        $display("\nChecking HLT state loop...");
        if (uut.current_state == T3) begin
            $display("PASS: HLT stays in T3");
        end else begin
            $display("FAIL: HLT state is %b, expected T3", uut.current_state);
        end

        // Test 6: OUTA Instruction
        $display("\n--- TEST 6: OUTA (Output A) Instruction ---");
        opcode = OUTA;
        
        // Reset state machine
        reset = 1; #10; reset = 0; #10;
        
        // Skip to T3
        repeat(2) #10;
        
        // T3: Should be 0 (no memory access needed)
        $display("T3 cycle:");
        check_signal("CW should be 0", 0, (CW == 16'h0000) ? 1 : 0);
        #10;

        // T4: Should have AO and OI
        $display("T4 cycle:");
        check_signal("AO", AO, 1);
        check_signal("OI", OI, 1);
        #10;

        // Summary
        $display("\n========================================");
        $display("    TEST SUMMARY                          ");
        $display("========================================");
        $display("Total Tests: %d", test_count);
        $display("Passed: %d", pass_count);
        $display("Failed: %d", fail_count);
        if (fail_count == 0) begin
            $display("\n✓ ALL TESTS PASSED!");
        end else begin
            $display("\n✗ SOME TESTS FAILED!");
        end
        $display("========================================\n");

        $finish;
    end

endmodule
