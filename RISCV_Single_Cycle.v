module RISCV_Single_Cycle (
    input  logic        clk,
    input  logic        rst_n,
    output logic [31:0] PC_out_top,
    output logic [31:0] Instruction_out_top
);
    logic [31:0] PC_next;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC_out_top <= 32'b0;
        else
            PC_out_top <= PC_next;
    end
    IMEM imem_inst (
        .addr        (PC_out_top),
        .Instruction (Instruction_out_top)
    );
    logic [6:0] opcode;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = Instruction_out_top[6:0];
    assign rd     = Instruction_out_top[11:7];
    assign funct3 = Instruction_out_top[14:12];
    assign rs1    = Instruction_out_top[19:15];
    assign rs2    = Instruction_out_top[24:20];
    assign funct7 = Instruction_out_top[31:25];
	
    logic [31:0] Imm;
    Imm_Gen immgen (
        .inst     (Instruction_out_top),
        .imm_out  (Imm)
    );
    logic [31:0] ReadData1, ReadData2, WriteData;
    RegisterFile Reg_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .RegWrite   (RegWrite),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .WriteData  (WriteData),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );
    logic [1:0] ALUSrcSel;
    logic [1:0] alu_op;
    logic [3:0] ALUCtrl;
    logic RegWrite, MemRead, MemWrite, MemToReg;
    logic Branch, JAL, JALR;

    control_unit CU (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUSrc     (ALUSrcSel),
        .alu_op     (alu_op),
        .Branch     (Branch),
        .JAL        (JAL),
        .JALR       (JALR),
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        .MemToReg   (MemToReg),
        .RegWrite   (RegWrite)
    );

    ALU_decoder ALU_dec (
        .alu_op      (alu_op),
        .funct3      (funct3),
        .funct7b5    (Instruction_out_top[30]),
        .alu_control (ALUCtrl)
    );

    logic [31:0] ALU_in2, ALU_result;
    assign ALU_in2 = (ALUSrcSel == 2'b00) ? ReadData2 :
                     (ALUSrcSel == 2'b01) ? Imm :
                                            PC_out_top;

    ALU alu (
        .A      (ReadData1),
        .B      (ALU_in2),
        .ALUOp  (ALUCtrl),
        .Result (ALU_result),
        .Zero   (ALUZero)
    );

    logic ALUZero, PCSel;
    Branch_Comp brcomp (
        .A       (ReadData1),
        .B       (ReadData2),
        .Branch  (Branch),
        .funct3  (funct3),
        .BrTaken (PCSel)
    );

    logic [31:0] MemReadData;
    DMEM dmem_inst (
        .clk        (clk),
        .rst_n      (rst_n),
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        .funct3     (funct3),        
        .addr       (ALU_result),
        .WriteData  (ReadData2),
        .ReadData   (MemReadData)
    );

    assign WriteData = MemToReg ? MemReadData : ALU_result;

    logic [31:0] PC_plus4, PC_branch, PC_jalr;
    assign PC_plus4  = PC_out_top + 4;
    assign PC_branch = PC_out_top + Imm;
    assign PC_jalr   = (ReadData1 + Imm) & ~32'd1;

    assign PC_next = JALR        ? PC_jalr :
                     (PCSel | JAL) ? PC_branch :
                     PC_plus4;

endmodule
