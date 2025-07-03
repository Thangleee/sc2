module ALU_decoder (
    input  logic [1:0] alu_op,     // 00/01/10/11
    input  logic [2:0] funct3,     // instr[14:12]
    input  logic       funct7b5,   // instr[30]
    output logic [3:0] alu_control // điều khiển sang ALU
);
    always_comb begin
        unique case (alu_op)
            2'b00: alu_control = 4'b0000;          // ADD  (load, store, auipc)
            2'b01: alu_control = 4'b0001;          // SUB  (branch so sánh rs1-rs2)
            2'b11: alu_control = 4'b1010;          // PASS_B (LUI: imm -> rd)
            2'b10: begin                           // R/I-type cần giải mã sâu
                unique case (funct3)
                    3'b000: alu_control = (funct7b5 ? 4'b0001 : 4'b0000); // SUB / ADD
                    3'b001: alu_control = 4'b0010;  // SLL / SLLI
                    3'b010: alu_control = 4'b0011;  // SLT / SLTI
                    3'b011: alu_control = 4'b0100;  // SLTU / SLTIU
                    3'b100: alu_control = 4'b0101;  // XOR / XORI
                    3'b101: alu_control = (funct7b5 ? 4'b0111 : 4'b0110); // SRA/SRAI or SRL/SRLI
                    3'b110: alu_control = 4'b1000;  // OR  / ORI
                    3'b111: alu_control = 4'b1001;  // AND / ANDI
                    default: alu_control = 4'b0000; // mặc định ADD
                endcase
            end
            default: alu_control = 4'b0000;        // an toàn: ADD
        endcase
    end
endmodule
