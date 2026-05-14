# SAP-1 Verilog Architecture

Verilog implementation of a modified SAP-1 8-bit architecture, designed for synthesis on a Xilinx Artix-7 FPGA board.

## Current Project Status
The **Top Module (`CPU.v`)** has been fully integrated based on a **Top-Down Design** approach:
- **Internal Wires Declared:** Virtual wires connecting all sub-modules (e.g., `regA_out`, `alu_out`) are perfectly routed.
- **Mux-Based W-Bus:** Replaced traditional tri-state buffers with an `assign W_bus = ...` multiplexer logic to manage data routing safely.
- **16-bit Control Word:** The `CTRL_WORD` from the Control Unit is properly split into individual execution signals (`PE`, `PO`, `MI`, etc.).
- **16-bit Output via Software Approach:** Extended the traditional SAP-1 instruction set to support outputting large ALU values (like Multiplication). The machine code sequentially calls `OUT A` (lower 8 bits) and `OUT B` (upper 8 bits) to display the full 16-bit answer on an 8-bit LED array.

## Verification & Simulation
- **Memory Initialization:** `RAM.mem` is tightly packed with machine code running a full Arithmetic suite (LDR, ADD, SUB, MUL, DIV) and outputs the results sequentially.
- **Top-Level Testbench:** `testbench/CPU_tb.v` generates a 100MHz clock, provides a reset sequence, and outputs a `cpu_waveforms.vcd` file for EDA Playground and Vivado.
- **Unit Testing:** Empty testbench skeletons have been set up for all individual modules (`ALU_tb.v`, `PC_tb.v`, etc.) so that team members can verify their components in isolation.

## Directory Structure
- **`main_modules/`**: Contains the core logic coordinators.
  - `CPU.v`: The Top-Level module that ties the Mux bus, Control Unit, and all registers/ALU together.
  - `CU.v`: Control Unit (Stub) - Awaits final State Machine implementation.
  - `Clock_Divider.v`: Steps down the 100MHz FPGA oscillator to a visible 1Hz clock for LED blinking.
- **`sub_modules/`**: Contains the core processing components.
  - `ALU.v` (Arithmetic Logic Unit)
  - `PC.v` (Program Counter)
  - `MAR.v` (Memory Address Register)
  - `IR.v` (Instruction Register)
  - `RAM.v` (Memory module that loads `RAM.mem`)
  - `Ra.v`, `Rb.v`, `Rc.v`, `Rout.v` (8-bit Registers)
- **`testbench/`**: Contains `CPU_tb.v` and all Unit Test files (`ALU_tb.v`, `PC_tb.v`, etc.).
- **`constraints.xdc`**: Xilinx Artix-7 (e.g., Basys 3) pin definitions for Clock, Reset, and Output LEDs.
- **`RAM.mem`**: Memory Initialization file holding the test machine code sequence.

## How to Test in Vivado
1. Create a new RTL Project and target your specific FPGA board (e.g., Artix-7).
2. Add all `.v` files from `main_modules/` and `sub_modules/` as **Design Sources**. 
3. Add `RAM.mem` as a **Design Source** so Vivado can load the machine code.
4. Add `constraints.xdc` as a **Constraints File**.
5. Add the `testbench/` folder as **Simulation Sources** and set `CPU_tb.v` as the Top Module.
6. Run **Behavioral Simulation** for `888ns` to observe the waveforms (`W_bus`, `out`, etc.).