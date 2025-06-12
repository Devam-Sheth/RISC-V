module pc_wire (
    input clk, reset,
    input taken_br, is_jal, is_jalr,
    input [31:0] br_tgt_pc, jalr_tgt_pc,
    output reg [31:0] pc
);
    wire [31:0] next_pc;

    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'b0;
        else       pc <= next_pc;
    end

    assign next_pc = taken_br ? br_tgt_pc :
                     is_jal    ? br_tgt_pc :
                     is_jalr   ? jalr_tgt_pc :
                                 pc + 4;
endmodule
