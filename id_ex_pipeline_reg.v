// renamed, contents being the same
module pipeline2(
    input clk,
    input [31:0] rs1,
    input [31:0] rs2,
    input [31:0] imm,
    input [2:0]  op_type,
    input [4:0]  op,
    input [1:0]  immctrl,
    
    output reg [31:0] rs1_out,
    output reg [31:0] rs2_out,
    output reg [31:0] imm_out,
    output reg [2:0]  op_type_out,
    output reg [4:0]  op_out,
    output reg [1:0]  immctrl_out
);

always @(posedge clk) begin
    rs1_out      <= rs1;
    rs2_out      <= rs2;
    imm_out      <= imm;
    op_type_out  <= op_type;
    op_out       <= op;
    immctrl_out  <= immctrl;
end

endmodule
