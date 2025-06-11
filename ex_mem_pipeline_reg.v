/*module pipeline3(
    input clk,

    input [4:0] rd_in,
    input [31:0] data_in,
    input [31:0] alu_result_in,
    input [2:0] memacc_in,
    input [1:0] size_in,

    output reg [4:0] rd_out,
    output reg [31:0] data_out,
    output reg [31:0] alu_result_out,
    output reg [2:0] memacc_out,
    output reg [1:0] size_out
);

always @(posedge clk) begin
    rd_out         <= rd_in;
    data_out       <= data_in;
    alu_result_out <= alu_result_in;
    memacc_out     <= memacc_in;
    size_out       <= size_in;
end

endmodule */

//Updated code
module ex_mem_pipeline_reg (
    input clk, reset,
    input [31:0] pc_plus_4_in, alu_result_in, rs2_data_in, branch_target_in,
    input [4:0]  rd_addr_in,
    input branch_taken_in,
    input reg_write_in, mem_read_in, mem_write_in, mem_to_reg_in,
    input [1:0] access_sz_in,
    input s_us_in, jump_in, jalr_in,
    output reg [31:0] pc_plus_4_out, alu_result_out, rs2_data_out, branch_target_out,
    output reg [4:0]  rd_addr_out,
    output reg branch_taken_out,
    output reg reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out,
    output reg [1:0] access_sz_out,
    output reg s_us_out, jump_out, jalr_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_plus_4_out <= 32'b0;
            alu_result_out <= 32'b0;
            rs2_data_out <= 32'b0;
            branch_target_out <= 32'b0;
            rd_addr_out <= 5'b0;
            branch_taken_out <= 1'b0;
            reg_write_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            access_sz_out <= 2'b10;
            s_us_out <= 1'b0;
            jump_out <= 1'b0;
            jalr_out <= 1'b0;
        end
        else begin
            pc_plus_4_out <= pc_plus_4_in;
            alu_result_out <= alu_result_in;
            rs2_data_out <= rs2_data_in;
            branch_target_out <= branch_target_in;
            rd_addr_out <= rd_addr_in;
            branch_taken_out <= branch_taken_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            access_sz_out <= access_sz_in;
            s_us_out <= s_us_in;
            jump_out <= jump_in;
            jalr_out <= jalr_in;
        end
    end

endmodule
