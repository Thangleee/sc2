module RegisterFile (
    input  logic        clk,
    input  logic        rst_n,         // Active-low reset
    input  logic        RegWrite,      // Ghi vào rd
    input  logic [4:0]  rs1, rs2, rd,  // Địa chỉ đọc/ghi
    input  logic [31:0] WriteData,     // Dữ liệu ghi
    output logic [31:0] ReadData1,
    output logic [31:0] ReadData2
);
    logic [31:0] registers [0:31];
    
    assign ReadData1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign ReadData2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++)
                registers[i] <= 32'd0;
        end else if (RegWrite && rd != 5'd0) begin
            registers[rd] <= WriteData;
        end
    end
endmodule
