module DMEM (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        MemRead,
    input  logic        MemWrite,
    input  logic [2:0]  funct3,      // instr[14:12]
    input  logic [31:0] addr,        // byte address
    input  logic [31:0] WriteData,
    output logic [31:0] ReadData
);
    localparam DEPTH = 1024;         // 4 KiB
    logic [31:0] mem [0:DEPTH-1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++) mem[i] <= 32'b0;
        end
        
        else if (MemWrite) begin
            case (funct3)
                3'b000: begin // SB
                    int byte_off = addr[1:0];
                    int word_idx = addr[11:2];
                    logic [31:0] w = mem[word_idx];
                    w[ (byte_off*8) +: 8 ] = WriteData[7:0];
                    mem[word_idx] <= w;
                end
                3'b001: begin // SH
                    int half_off = addr[1];
                    int word_idx = addr[11:2];
                    logic [31:0] w = mem[word_idx];
                    w[ (half_off*16) +: 16 ] = WriteData[15:0];
                    mem[word_idx] <= w;
                end
                default: begin // SW (3'b010) – word
                    mem[addr[11:2]] <= WriteData;
                end
            endcase
        end
    end
    
    always_comb begin
        if (!MemRead)
            ReadData = 32'b0;
        else begin
            logic [31:0] rword = mem[addr[11:2]];
            unique case (funct3)
                3'b000: begin // LB (signed)
                    logic [7:0] byte_val = rword[ (addr[1:0]*8) +: 8 ];
                    ReadData = {{24{byte_val[7]}}, byte_val};
                end
                3'b100: begin // LBU
                    logic [7:0] byte_val = rword[ (addr[1:0]*8) +: 8 ];
                    ReadData = {24'b0, byte_val};
                end
                3'b001: begin // LH (signed)
                    logic [15:0] half_val = rword[ (addr[1]*16) +: 16 ];
                    ReadData = {{16{half_val[15]}}, half_val};
                end
                3'b101: begin // LHU
                    logic [15:0] half_val = rword[ (addr[1]*16) +: 16 ];
                    ReadData = {16'b0, half_val};
                end
                default: ReadData = rword; // LW (3'b010)
            endcase
        end
    end
endmodule
