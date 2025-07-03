module Branch_Comp (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic        Branch,   // tín hiệu từ control unit
    input  logic [2:0]  funct3,   // instr[14:12]
    output logic        BrTaken   // = 1 nếu nhảy, = 0 nếu không
);
    always_comb begin
        if (!Branch)
            BrTaken = 1'b0;
        else begin
            unique case (funct3)
                3'b000: BrTaken = (A == B);                          // BEQ
                3'b001: BrTaken = (A != B);                          // BNE
                3'b100: BrTaken = ($signed(A) < $signed(B));         // BLT
                3'b101: BrTaken = ($signed(A) >= $signed(B));        // BGE
                3'b110: BrTaken = (A < B);                           // BLTU
                3'b111: BrTaken = (A >= B);                          // BGEU
                default: BrTaken = 1'b0;                             
            endcase
        end
    end
endmodule
