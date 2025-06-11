module mem_wb_pipeline_reg (
    input clk,
    input [4:0]  rd_in,
    input [31:0] alu_result_in,
    input [31:0] ld_data_in,
    input reg_write_in,

    output reg [4:0]  rd_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] ld_data_out,
    output reg reg_write_out
);

    always @(posedge clk) begin
        rd_out <= rd_in;
        alu_result_out <= alu_result_in;
        ld_data_out <= ld_data_in;
        reg_write_out <= reg_write_in;
    end

endmodule
