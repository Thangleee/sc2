module IMEM #(
    parameter int     DEPTH          = 256,
    parameter string  HEXFILE        = "imem.hex",
    parameter logic [31:0] default_instr = 32'h0000_0013   // NOP (ADDI x0,x0,0)
)(
    input  logic [31:0] addr,         // byte address, word-aligned (bit [1:0] == 2'b00)
    output logic [31:0] Instruction
);
    logic [31:0] mem [0:DEPTH-1];
    always_comb begin
        if (addr[31:2] < DEPTH)
            Instruction = mem[addr[31:2]];
        else
            Instruction = default_instr;
    end    
    initial begin
        $readmemh(HEXFILE, mem);
        // Debug (tùy chọn): in 4 từ đầu tiên
        $display("IMEM[0]=%h  IMEM[1]=%h  IMEM[2]=%h  IMEM[3]=%h",
                 mem[0], mem[1], mem[2], mem[3]);
    end
endmodule
