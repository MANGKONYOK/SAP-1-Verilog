module CU (
    input [3:0] opcode,
    input clk,
    input reset,
    output reg [15:0] CW
);

    // Determine state (T0 - T5)
    parameter T0 = 3'd0, T1 = 3'd1, T2 = 3'd2, 
              T3 = 3'd3, T4 = 3'd4, T5 = 3'd5;

    // Determine opcode
    parameter LDR = 4'b0000, ADD = 4'b0001, SUB = 4'b0010, MUL = 4'b0011, 
              DIV = 4'b0100, OUTA = 4'b0101, OUTB = 4'b0110, HLT = 4'b0111;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= T0;
        else
            current_state <= next_state;
    end


    // =========================================================================
    // ตำแหน่งบิตสัญญาณควบคุมใน CW [15:0] ให้ตรงกับ CPU.v
    // =========================================================================
    localparam PE    = 16'h8000, // บิต 15 - Program Counter Enable (Increment)
               PO    = 16'h4000, // บิต 14 - Program Counter Output
               MI    = 16'h2000, // บิต 13 - Memory Address Register Input
               RO    = 16'h1000, // บิต 12 - RAM Output
               II    = 16'h0800, // บิต 11 - Instruction Register Input
               IO    = 16'h0400, // บิต 10 - Instruction Register Output (address)
               AI    = 16'h0200, // บิต 9  - Register A Input
               AO    = 16'h0100, // บิต 8  - Register A Output
               EO    = 16'h0080, // บิต 7  - ALU Output
               CI    = 16'h0040, // บิต 6  - Register C Input
               S0    = 16'h0020, // บิต 5  - ALU Select (S0)
               S1    = 16'h0010, // บิต 4  - ALU Select (S1)
               BI    = 16'h0008, // บิต 3  - Register B Input
               BO    = 16'h0004, // บิต 2  - Register B Output
               OI    = 16'h0002, // บิต 1  - Output Register Input
               HLT_SIG = 16'h0001; // บิต 0  - Halt Signal


    // -------------------------------------------------------------------------
    // 1. Timing Logic: Next State Logic (คำนวณสถานะถัดไป)
    // -------------------------------------------------------------------------
    always @(*) begin
        case (current_state)
            T0: next_state = T1;
            T1: next_state = T2;
            T2: next_state = T3;
            T3: begin
                if (opcode == HLT)
                    next_state = T3; // ค้างอยู่ที่ T3 ตลอดไปถ้าเจอคำสั่ง Halt
                else
                    next_state = T4;
            end
            T4: begin
                // ถ้าเป็นคำสั่ง LDR ทำงานเสร็จสิ้นที่ T4 แล้ว ให้กดกลับไป T0 ทันทีเพื่อประหยัด Cycle
                if (opcode == LDR)
                    next_state = T0; 
                else
                    next_state = T5;
            end
            T5: next_state = T0;     // จบการทำงาน Execute วนกลับไป Fetch ใหม่
            default: next_state = T0;
        endcase
    end


    // -------------------------------------------------------------------------
    // 2. Timing Logic: Output Logic (กำหนดค่า Control Word)
    // -------------------------------------------------------------------------
    always @(*) begin
        // กำหนดค่า Default เป็น 0 ทั้งหมดเพื่อป้องกันการเกิด Latch บนนอกเคส
        CW = 16'h0000; 

        case (current_state)
            // ================= FETCH CYCLE (เหมือนกันทุกคำสั่ง) =================
            T0: begin
                // ย้ายค่าจาก Program Counter ไปยัง MAR และเพิ่มค่า PC
                CW = PO | MI | PE; 
            end
            T1: begin
                // อ่านคำสั่งจาก RAM เข้าสู่ IR
                CW = RO | II; 
            end
            T2: begin
                // สถานะ Decode: ปล่อยว่างไว้เพื่อรอการถอดรหัสและส่งต่อสัญญาณ
                CW = 16'h0000; 
            end

            // ================= EXECUTE CYCLE (เจาะจงตาม Opcode) =================
            T3: begin
                case (opcode)
                    LDR: begin
                        // เอาแอดเดรสที่ระบุจาก IR ส่งเข้าไปยัง MAR
                        CW = IO | MI;
                    end
                    ADD, SUB, MUL, DIV: begin
                        // เอาแอดเดรสตัวคูณ/ตัวบวก/ตัวลบ/ตัวหาร จาก IR ส่งเข้าไปยัง MAR
                        CW = IO | MI;
                    end
                    OUTA, OUTB: begin
                        // ไม่ต้องส่ง MAR เพราะไม่ต้องอ่านจากหน่วยความจำ
                        CW = 16'h0000;
                    end
                    HLT: begin
                        // Halt - ไม่ทำอะไร
                        CW = 16'h0000;
                    end
                    default: CW = 16'h0000;
                endcase
            end

            T4: begin
                case (opcode)
                    LDR: begin
                        // นำข้อมูลในหน่วยความจำ RAM มาเก็บที่ Register A
                        CW = RO | AI; 
                    end
                    ADD, SUB, MUL, DIV: begin
                        // นำข้อมูลในหน่วยความจำ RAM มาพักไว้ที่ Register B ก่อนเพื่อเตรียมเข้า ALU
                        CW = RO | BI; 
                    end
                    OUTA: begin
                        // ส่ง REG_A ไปยัง Output Register
                        CW = AO | OI;
                    end
                    OUTB: begin
                        // ส่ง REG_B ไปยัง Output Register
                        CW = BO | OI;
                    end
                    HLT: begin
                        // Halt - ไม่ทำอะไร
                        CW = HLT_SIG;
                    end
                    default: CW = 16'h0000;
                endcase
            end

            T5: begin
                case (opcode)
                    LDR: begin
                        // เนื่องจาก LDR วนกลับ T0 ไปแล้ว ตรงนี้จ่าย 0 เคลียร์สายบัส
                        CW = 16'h0000; 
                    end
                    ADD: begin
                        // สั่ง ALU: S0=0, S1=0 สำหรับ ADD, แล้วปล่อยผลลัพธ์ออกบัสเพื่อบันทึกกลับเข้า REG_A
                        CW = EO | AI; 
                    end
                    SUB: begin
                        // สั่ง ALU: S0=1, S1=0 สำหรับ SUB, แล้วปล่อยผลลัพธ์ออกบัสเพื่อบันทึกกลับเข้า REG_A
                        CW = S0 | EO | AI; 
                    end
                    MUL: begin
                        // สั่ง ALU: S0=0, S1=1 สำหรับ MUL, แล้วปล่อยผลลัพธ์ออกบัส
                        CW = S1 | EO | AI;
                    end
                    DIV: begin
                        // สั่ง ALU: S0=1, S1=1 สำหรับ DIV, แล้วปล่อยผลลัพธ์ออกบัส
                        CW = S1 | S0 | EO | AI;
                    end
                    OUTA, OUTB: begin
                        // เคลียร์บัส เพราะคำสั่งเสร็จเรียบร้อยแล้ว
                        CW = 16'h0000;
                    end
                    HLT: begin
                        // Hold Halt signal
                        CW = HLT_SIG;
                    end
                    default: CW = 16'h0000;
                endcase
            end

            default: CW = 16'h0000;
        endcase
    end

endmodule