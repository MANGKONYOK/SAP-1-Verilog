# SAP-1 Control Unit - Detailed Instruction Timing Reference

## Overview
This document provides detailed cycle-by-cycle breakdown of each instruction's execution through the CU state machine.

---

## Instruction Timing Diagrams

### Format:
```
State | Control Signals | Description
------|-----------------|------------------
  T0  | [Signals]       | [What happens]
  T1  | [Signals]       | [What happens]
  ...
```

---

## 1. LDR (Load Register) - Opcode: 0000

**Total Cycles: 4 (Early exit at T4)**

```
T0 | PO | MI | PE         | Fetch: Output PC to MAR, Enable PC increment
T1 | RO | II              | Fetch: Read RAM, Load into IR
T2 | (no operations)      | Decode: IR decodes opcode
T3 | IO | MI              | Execute: Output memory address to MAR
T4 | RO | AI              | Execute: Read RAM, Load to Register A
T0 | (restart cycle)      | Return to Fetch (Early exit due to LDR detection)
```

**W-Bus Flow:**
1. PC → MAR → Address Bus
2. RAM[Address] → IR
3. IR_addr → MAR → Address Bus
4. RAM[Address] → Register A

**Result:** Register A contains value from memory

---

## 2. ADD (Add) - Opcode: 0001

**Total Cycles: 6**

```
T0 | PO | MI | PE         | Fetch: Output PC to MAR, Enable PC increment
T1 | RO | II              | Fetch: Read RAM, Load into IR
T2 | (no operations)      | Decode: IR decodes opcode
T3 | IO | MI              | Execute: Output memory address to MAR
T4 | RO | BI              | Execute: Read RAM, Load to Register B
T5 | EO | AI | S0=0 S1=0  | Execute: ALU (RA + RB), result to Register A
T0 | (restart cycle)      | Return to Fetch
```

**ALU Control Codes:**
- S0 = 0, S1 = 0 → ADD function

**W-Bus Flow:**
1. PC → MAR (Fetch)
2. RAM[PC] → IR (Fetch)
3. IR_addr → MAR (Execute start)
4. RAM[IR_addr] → Register B (Execute middle)
5. ALU(RA + RB) → Register A (Execute end)

**Result:** Register A = Register A + Memory[IR_addr]

---

## 3. SUB (Subtract) - Opcode: 0010

**Total Cycles: 6**

```
T0 | PO | MI | PE         | Fetch: Output PC to MAR, Enable PC increment
T1 | RO | II              | Fetch: Read RAM, Load into IR
T2 | (no operations)      | Decode: IR decodes opcode
T3 | IO | MI              | Execute: Output memory address to MAR
T4 | RO | BI              | Execute: Read RAM, Load to Register B
T5 | EO | AI | S0=1 S1=0  | Execute: ALU (RA - RB), result to Register A
T0 | (restart cycle)      | Return to Fetch
```

**ALU Control Codes:**
- S0 = 1, S1 = 0 → SUB function

**Operation:** A = A - M[addr]

---

## 4. MUL (Multiply) - Opcode: 0011

**Total Cycles: 6**

```
T0 | PO | MI | PE         | Fetch: Output PC to MAR, Enable PC increment
T1 | RO | II              | Fetch: Read RAM, Load into IR
T2 | (no operations)      | Decode: IR decodes opcode
T3 | IO | MI              | Execute: Output memory address to MAR
T4 | RO | BI              | Execute: Read RAM, Load to Register B
T5 | EO | AI | S0=0 S1=1  | Execute: ALU (RA * RB), result to Register A
T0 | (restart cycle)      | Return to Fetch
```

**ALU Control Codes:**
- S0 = 0, S1 = 1 → MUL function

**Operation:** A = A * M[addr]

**Note:** If result > 255, upper bits go to Register C or saved separately

---

## 5. DIV (Divide) - Opcode: 0100

**Total Cycles: 6**

```
T0 | PO | MI | PE         | Fetch: Output PC to MAR, Enable PC increment
T1 | RO | II              | Fetch: Read RAM, Load into IR
T2 | (no operations)      | Decode: IR decodes opcode
T3 | IO | MI              | Execute: Output memory address to MAR
T4 | RO | BI              | Execute: Read RAM, Load to Register B
T5 | EO | AI | S0=1 S1=1  | Execute: ALU (RA / RB), result to Register A
T0 | (restart cycle)      | Return to Fetch
```

**ALU Control Codes:**
- S0 = 1, S1 = 1 → DIV function

**Operation:** A = A / M[addr]

**Note:** Remainder may be saved to Register B or discarded

---

## 6. OUTA (Output A) - Opcode: 0101

**Total Cycles: 4**

```
T0 | PO | MI | PE         | Fetch: Output PC to MAR, Enable PC increment
T1 | RO | II              | Fetch: Read RAM, Load into IR
T2 | (no operations)      | Decode: IR decodes opcode
T3 | (no operations)      | Execute: No memory access needed
T4 | AO | OI              | Execute: Output Register A to Output Register
T0 | (restart cycle)      | Return to Fetch
```

**W-Bus Flow:**
1. PC → MAR (Fetch)
2. RAM[PC] → IR (Fetch)
3. Register A → Output Register (Execute)

**Result:** Display or capture value of Register A

---

## 7. OUTB (Output B) - Opcode: 0110

**Total Cycles: 4**

```
T0 | PO | MI | PE         | Fetch: Output PC to MAR, Enable PC increment
T1 | RO | II              | Fetch: Read RAM, Load into IR
T2 | (no operations)      | Decode: IR decodes opcode
T3 | (no operations)      | Execute: No memory access needed
T4 | BO | OI              | Execute: Output Register B to Output Register
T0 | (restart cycle)      | Return to Fetch
```

**W-Bus Flow:**
1. PC → MAR (Fetch)
2. RAM[PC] → IR (Fetch)
3. Register B → Output Register (Execute)

**Result:** Display or capture value of Register B

---

## 8. HLT (Halt) - Opcode: 0111

**Total Cycles: Indefinite (Loops at T3)**

```
T0 | PO | MI | PE         | Fetch: Output PC to MAR, Enable PC increment
T1 | RO | II              | Fetch: Read RAM, Load into IR
T2 | (no operations)      | Decode: IR decodes opcode
T3 | (no operations)      | Halt: State machine stays here
T3 | (no operations)      | Halt: Loops indefinitely
T3 | (no operations)      | Halt: No more instructions executed
```

**Note:** Signal HLT becomes active in state machine, all control lines go low

---

## Control Signal Summary Table

| Signal | Bit | Purpose |
|--------|-----|---------|
| PE | 15 | Enable PC (Increment) |
| PO | 14 | Output PC to W-Bus |
| MI | 13 | Load MAR from W-Bus |
| RO | 12 | Output RAM to W-Bus |
| II | 11 | Load IR from W-Bus |
| IO | 10 | Output IR address to W-Bus |
| AI | 9 | Load Register A from W-Bus |
| AO | 8 | Output Register A to W-Bus |
| EO | 7 | Output ALU result to W-Bus |
| CI | 6 | Load Register C from W-Bus |
| S0 | 5 | ALU Function Bit 0 |
| S1 | 4 | ALU Function Bit 1 |
| BI | 3 | Load Register B from W-Bus |
| BO | 2 | Output Register B to W-Bus |
| OI | 1 | Load Output Register from W-Bus |
| HLT | 0 | Halt Signal |

---

## ALU Operation Codes

| S1 | S0 | Operation |
|----|----|-----------| 
| 0 | 0 | ADD |
| 0 | 1 | SUB |
| 1 | 0 | MUL |
| 1 | 1 | DIV |

---

## W-Bus Activity Summary

### Fetch Cycle (Universal)
1. **T0**: PC → W-Bus → MAR (via PO | MI | PE)
2. **T1**: RAM → W-Bus → IR (via RO | II)

### Execute Cycle (Instruction Dependent)

#### LDR Execute:
3. **T3**: IR_addr → W-Bus → MAR (via IO | MI)
4. **T4**: RAM → W-Bus → Register A (via RO | AI)

#### ALU Operations (ADD, SUB, MUL, DIV) Execute:
3. **T3**: IR_addr → W-Bus → MAR (via IO | MI)
4. **T4**: RAM → W-Bus → Register B (via RO | BI)
5. **T5**: ALU(RA op RB) → W-Bus → Register A (via EO | AI)

#### Output Operations (OUTA, OUTB) Execute:
3. **T3**: (No operation)
4. **T4**: Register (A or B) → W-Bus → Output Reg (via AO|OI or BO|OI)

---

## State Machine Transitions

```
NORMAL FLOW (except LDR and HLT):
T0 → T1 → T2 → T3 → T4 → T5 → T0

LDR EARLY EXIT:
T0 → T1 → T2 → T3 → T4 → T0 (skips T5)

HLT INFINITE LOOP:
T0 → T1 → T2 → T3 → T3 → T3 → ... (stays at T3)
```

---

## Key Points for Verification

1. **Fetch always takes T0-T1**: Every instruction fetches from memory
2. **Decode at T2**: Opcode is decoded to determine execute sequence
3. **ALU operations at T5**: All arithmetic operations finalize at T5
4. **LDR is fastest**: Completes in 4 cycles (T0-T4)
5. **All others take 6 cycles**: Standard cycle length is 6 (T0-T5)
6. **Output instructions take 4 cycles**: No ALU operation needed
7. **HLT stays at T3**: State machine loops indefinitely

---

## Testing Verification Points

When testing the CU, verify:

1. ✓ Fetch cycle signals appear in T0-T1 for all instructions
2. ✓ T2 is always empty (no operations)
3. ✓ Memory address appears in T3 for operations that need it
4. ✓ Register B loads in T4 for ALU operations
5. ✓ ALU operations complete with correct S0/S1 codes in T5
6. ✓ Output instructions route to Output Register in T4
7. ✓ HLT remains in T3 indefinitely after reaching it
8. ✓ LDR returns to T0 after T4 (no T5)
9. ✓ State machine resets to T0 after reset signal
10. ✓ PC increments in every T0 cycle (PE signal)

---

## Debug Guide

If a test fails:

1. Check state machine is advancing correctly (T0→T1→T2→...)
2. Verify reset clears state to T0
3. Confirm clock is toggling and CLK is being used (not inv_clk) for state register
4. Check that CW values match expected signals for each state
5. Verify opcode is being read correctly in each cycle
6. Test each instruction individually before combinations
