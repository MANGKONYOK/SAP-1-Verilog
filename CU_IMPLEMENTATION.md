# SAP-1 Control Unit (CU) Implementation Summary

## Overview
The Control Unit (CU) has been completed with full support for all 8 instructions and comprehensive testbenches.

## Changes Made

### 1. **CU.v - Control Unit Module**
- **Fixed port order**: Changed from `(clk, reset, opcode, CW)` to `(opcode, clk, reset, CW)` to match CPU.v instantiation
- **Corrected control signal definitions**: Aligned all signal names with CPU.v expectations
  - PE (Program Counter Enable) - bit 15
  - PO (Program Counter Output) - bit 14
  - MI (Memory Address Register Input) - bit 13
  - RO (RAM Output) - bit 12
  - II (Instruction Register Input) - bit 11
  - IO (Instruction Register Output) - bit 10
  - AI (Register A Input) - bit 9
  - AO (Register A Output) - bit 8
  - EO (ALU Output) - bit 7
  - CI (Register C Input) - bit 6
  - S0, S1 (ALU Function Selectors) - bits 5, 4
  - BI (Register B Input) - bit 3
  - BO (Register B Output) - bit 2
  - OI (Output Register Input) - bit 1
  - HLT (Halt Signal) - bit 0

- **Completed timing logic for all states (T0-T5)**:
  - **T0**: Fetch cycle - Output PC to MAR and enable PC increment
  - **T1**: Fetch cycle - Read instruction from RAM into IR
  - **T2**: Decode cycle - No operations (prepare for execution)
  - **T3**: Execute cycle - Send address from IR to MAR (except for OUTA/OUTB/HLT)
  - **T4**: Execute cycle - Read data or perform operation
  - **T5**: Execute cycle - ALU operation or finalize

- **Implemented all 8 instructions**:
  1. **LDR** (Load Register): Load value from memory into Register A
  2. **ADD**: Add value from memory to Register A
  3. **SUB**: Subtract value from memory from Register A
  4. **MUL**: Multiply Register A by value from memory
  5. **DIV**: Divide Register A by value from memory
  6. **OUTA**: Output contents of Register A
  7. **OUTB**: Output contents of Register B
  8. **HLT** (Halt): Stop execution

### 2. **CU_tb.v - Enhanced Testbench**
- Created comprehensive testbench with:
  - Signal decoding functions to display control signals in human-readable format
  - State name display function
  - Tests for all 8 instructions
  - Multiple clock cycles per instruction
  - Shows state progression and control word for each cycle

### 3. **CU_verification.v - Verification Testbench (NEW)**
- Advanced verification module with:
  - Automated signal checking with pass/fail reporting
  - Individual bit verification for each control signal
  - Test summary with total passed/failed count
  - Specific tests for:
    - Reset behavior
    - LDR instruction cycle
    - ADD instruction cycle
    - SUB instruction cycle
    - HLT instruction behavior

## Instruction Timing

### LDR - Load Register (4 cycles)
```
T0: PO | MI | PE         (Output PC to MAR, Enable PC increment)
T1: RO | II              (Read instruction from RAM)
T2: (no operations)      (Decode)
T3: IO | MI              (Output address to MAR)
T4: RO | AI              (Load from RAM to Register A)
T0: (Loop back)
```

### ADD - Add (6 cycles)
```
T0: PO | MI | PE         (Output PC to MAR, Enable PC increment)
T1: RO | II              (Read instruction from RAM)
T2: (no operations)      (Decode)
T3: IO | MI              (Output address to MAR)
T4: RO | BI              (Load operand to Register B)
T5: EO | AI              (ALU adds RA+RB, result to Register A)
T0: (Loop back)
```

### SUB - Subtract (6 cycles)
```
T0: PO | MI | PE         (Output PC to MAR, Enable PC increment)
T1: RO | II              (Read instruction from RAM)
T2: (no operations)      (Decode)
T3: IO | MI              (Output address to MAR)
T4: RO | BI              (Load operand to Register B)
T5: S0 | EO | AI         (ALU subtracts RA-RB, result to Register A)
T0: (Loop back)          (S0=1 for subtract function)
```

### MUL - Multiply (6 cycles)
```
T0: PO | MI | PE
T1: RO | II
T2: (no operations)
T3: IO | MI
T4: RO | BI
T5: S1 | EO | AI         (ALU multiplies RA*RB, result to Register A)
T0: (Loop back)          (S1=1 for multiply function)
```

### DIV - Divide (6 cycles)
```
T0: PO | MI | PE
T1: RO | II
T2: (no operations)
T3: IO | MI
T4: RO | BI
T5: S1 | S0 | EO | AI    (ALU divides RA/RB, result to Register A)
T0: (Loop back)          (S1=1, S0=1 for divide function)
```

### OUTA - Output Register A (4 cycles)
```
T0: PO | MI | PE
T1: RO | II
T2: (no operations)
T3: (no operations)
T4: AO | OI              (Output Register A to Output Register)
T0: (Loop back)
```

### OUTB - Output Register B (4 cycles)
```
T0: PO | MI | PE
T1: RO | II
T2: (no operations)
T3: (no operations)
T4: BO | OI              (Output Register B to Output Register)
T0: (Loop back)
```

### HLT - Halt (stays at T3)
```
T0: PO | MI | PE
T1: RO | II
T2: (no operations)
T3: (no operations) - State loops at T3
T4: HLT_SIG
T5: HLT_SIG
... (halts indefinitely)
```

## ALU Function Selection
- S0=0, S1=0: ADD
- S0=1, S1=0: SUB
- S0=0, S1=1: MUL
- S0=1, S1=1: DIV

## How to Run Tests

### Using CU_tb.v (Full Display):
```bash
iverilog -o cu_test main_modules/CU.v testbench/CU_tb.v
vvp cu_test
```

### Using CU_verification.v (Pass/Fail Report):
```bash
iverilog -o cu_verify main_modules/CU.v testbench/CU_verification.v
vvp cu_verify
```

## Integration with CPU.v
The CU is now properly integrated with CPU.v:
- CU receives the opcode from IR
- CU outputs a 16-bit control word
- All control signals are properly decoded from the control word
- The CU uses the inverted clock (negative edge) for proper timing

## Files Modified/Created
1. ✅ `main_modules/CU.v` - Completed with all logic
2. ✅ `testbench/CU_tb.v` - Enhanced comprehensive testbench
3. ✅ `testbench/CU_verification.v` - New verification testbench with automated checking
