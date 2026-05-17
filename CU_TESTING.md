# CU Testing Guide

## Quick Start

The Control Unit has been completed with full logic for all timing states and all 8 instructions. There are two testbenches available to verify it works correctly.

## Testbenches Available

### 1. CU_tb.v - Comprehensive Display Testbench
Shows the complete cycle-by-cycle operation of each instruction.

**Features:**
- Displays state transitions (T0-T5)
- Shows active control signals in human-readable format
- Tests all 8 instructions (LDR, ADD, SUB, MUL, DIV, OUTA, OUTB, HLT)
- Clear visual output of timing sequences

**Output example:**
```
--- Test 2: LDR Instruction Cycle ---
T-cycle | State: T0 (Fetch1) | CW: PO | MI | PE | 
T-cycle | State: T1 (Fetch2) | CW: RO | II | 
T-cycle | State: T2 (Decode) | CW: No controls
T-cycle | State: T3 (Execute1) | CW: IO | MI | 
T-cycle | State: T4 (Execute2) | CW: RO | AI | 
T-cycle | State: T0 (Fetch1) | CW: PO | MI | PE | 
```

### 2. CU_verification.v - Automated Verification Testbench
Provides automated pass/fail verification with detailed signal checking.

**Features:**
- Automated signal verification
- Individual bit checking for each control signal
- Pass/fail reporting
- Test counter and summary
- Specific checks for:
  - Reset behavior
  - Each instruction's control sequence
  - ALU function selection signals

**Output example:**
```
--- TEST 2: LDR Instruction Control Signals ---
T0 cycle:
  ✓ PO: 1 (expected: 1)
  ✓ MI: 1 (expected: 1)
T1 cycle:
  ✓ RO: 1 (expected: 1)
  ✓ II: 1 (expected: 1)
...
========================================
    TEST SUMMARY                          
========================================
Total Tests: 45
Passed: 45
Failed: 0

✓ ALL TESTS PASSED!
```

## Running the Tests

### Using Linux/macOS with Icarus Verilog:

```bash
# Navigate to project directory
cd /path/to/SAP-1-Verilog

# Run comprehensive testbench
iverilog -o cu_test main_modules/CU.v testbench/CU_tb.v
vvp cu_test

# Run verification testbench
iverilog -o cu_verify main_modules/CU.v testbench/CU_verification.v
vvp cu_verify
```

### Using Windows with Icarus Verilog:

```cmd
# Navigate to project directory
cd C:\Users\wit\Desktop\comarch\SAP-1-Verilog

# Run comprehensive testbench
iverilog -o cu_test main_modules/CU.v testbench/CU_tb.v
vvp cu_test

# Run verification testbench
iverilog -o cu_verify main_modules/CU.v testbench/CU_verification.v
vvp cu_verify
```

### Using the provided script (Linux/macOS):

```bash
chmod +x run_tests.sh
./run_tests.sh
```

## Installation of Icarus Verilog

### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install iverilog
```

### macOS:
```bash
brew install icarus-verilog
```

### Windows:
- Download from: http://iverilog.wikia.com/
- Or use WSL (Windows Subsystem for Linux) with Ubuntu environment

## Key Signals to Verify

When looking at test output, verify these signals appear at correct times:

### Fetch Cycle (T0-T1):
- **T0**: PE (increment PC), PO (output PC), MI (load MAR)
- **T1**: RO (read RAM), II (load IR)

### Execute Cycle (varies by instruction):
- **LDR (T3-T4)**:
  - T3: IO (output instruction address), MI (load MAR)
  - T4: RO (read RAM), AI (load Register A)
  
- **ADD/SUB/MUL/DIV (T3-T5)**:
  - T3: IO, MI
  - T4: RO (read RAM), BI (load Register B)
  - T5: EO (ALU output), AI (load result to Register A)
    - ADD: S0=0, S1=0
    - SUB: S0=1, S1=0
    - MUL: S0=0, S1=1
    - DIV: S0=1, S1=1

- **OUTA/OUTB (T4)**:
  - AO or BO (output register), OI (load output)

- **HLT (stays at T3)**:
  - State machine loops at T3 indefinitely

## Expected Behavior

1. **Reset**: After reset, CU should be in state T0
2. **State Machine**: Should cycle through T0→T1→T2→T3→T4→T5→T0 (except LDR and HLT)
3. **LDR**: Should exit at T4 and return to T0 (4-cycle instruction)
4. **Other ALU ops**: Should take 6 cycles (T0→T1→T2→T3→T4→T5→T0)
5. **OUTA/OUTB**: Should take 4 cycles and exit at T4
6. **HLT**: Should stay in T3 indefinitely

## Troubleshooting

### If tests don't compile:
1. Verify all Verilog files are in correct locations
2. Check for syntax errors (mismatched begin/end, missing semicolons)
3. Verify parameter definitions match between modules

### If tests compile but show unexpected results:
1. Check that control signal names match CPU.v expectations
2. Verify state machine transitions in Next State Logic
3. Check opcode definitions (LDR=0000, ADD=0001, etc.)
4. Verify control signal assignments in Output Logic

### Common Issues:
- **CW is 16'h0000 everywhere**: Check that control signals are being ORed correctly
- **State not changing**: Verify clock is toggling and reset is being handled
- **Wrong signals active**: Check parameter bit positions match CPU.v

## Integration Verification

To verify CU integrates correctly with CPU.v:

1. Check that CU port order matches CPU.v instantiation:
   - Port order: (opcode, clk, reset, CW)
   
2. Verify control signal bit positions in CPU.v:
   - PE on CW[15], PO on CW[14], etc.

3. Run the full CPU testbench with CU integrated

## Files Related to CU

- `main_modules/CU.v` - Main Control Unit module
- `testbench/CU_tb.v` - Comprehensive cycle-by-cycle testbench
- `testbench/CU_verification.v` - Automated verification with pass/fail
- `CU_IMPLEMENTATION.md` - Detailed implementation documentation
- `CU_TESTING.md` - This file
