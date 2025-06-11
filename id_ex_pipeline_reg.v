module id_ex_pipeline_reg (
    input clk, reset, stall, flush,
    
    // Data inputs
    input [31:0] rs1_data_in, rs2_data_in, imm_in,
    input [31:0] pc_in, pc_plus_4_in,
    input [4:0] rs1_addr_in, rs2_addr_in, rd_addr_in,
    
    // Control inputs
    input reg_write_in, mem_read_in, mem_write_in, mem_to_reg_in,
    input [1:0] access_sz_in,
    input s_us_in,
    input branch_in, jump_in, jalr_in,
    input b_rs1_pc_in, use_imm_in,
    input is_mul_in, is_rsqr_in,
    input [3:0] op_a_in, op_s_in,
    input [2:0] op_l_in, bra_c_in,
    input [1:0] sel_r_in,
    input is_lui_in, is_auipc_in,
    
    // Data outputs
    output reg [31:0] rs1_data_out, rs2_data_out, imm_out,
    output reg [31:0] pc_out, pc_plus_4_out,
    output reg [4:0] rs1_addr_out, rs2_addr_out, rd_addr_out,
    
    // Control outputs
    output reg reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out,
    output reg [1:0] access_sz_out,
    output reg s_us_out,
    output reg branch_out, jump_out, jalr_out,
    output reg b_rs1_pc_out, use_imm_out,
    output reg is_mul_out, is_rsqr_out,
    output reg [3:0] op_a_out, op_s_out,
    output reg [2:0] op_l_out, bra_c_out,
    output reg [1:0] sel_r_out,
    output reg is_lui_out, is_auipc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Reset/flush all signals
            rs1_data_out <= 32'b0;
            rs2_data_out <= 32'b0;
            imm_out <= 32'b0;
            pc_out <= 32'b0;
            pc_plus_4_out <= 32'b0;
            rs1_addr_out <= 5'b0;
            rs2_addr_out <= 5'b0;
            rd_addr_out <= 5'b0;
            
            // Control signals - all inactive
            reg_write_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            access_sz_out <= 2'b10;
            s_us_out <= 1'b0;
            branch_out <= 1'b0;
            jump_out <= 1'b0;
            jalr_out <= 1'b0;
            b_rs1_pc_out <= 1'b1;
            use_imm_out <= 1'b0;
            is_mul_out <= 1'b0;
            is_rsqr_out <= 1'b0;
            op_a_out <= 4'b0000;
            op_s_out <= 4'b0000;
            op_l_out <= 3'b000;
            bra_c_out <= 3'b000;
            sel_r_out <= 2'b00;
            is_lui_out <= 1'b0;
            is_auipc_out <= 1'b0;
        end
        else if (!stall) begin
            // Normal operation - pass inputs to outputs
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            imm_out <= imm_in;
            pc_out <= pc_in;
            pc_plus_4_out <= pc_plus_4_in;
            rs1_addr_out <= rs1_addr_in;
            rs2_addr_out <= rs2_addr_in;
            rd_addr_out <= rd_addr_in;
            
            // Control signals
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            access_sz_out <= access_sz_in;
            s_us_out <= s_us_in;
            branch_out <= branch_in;
            jump_out <= jump_in;
            jalr_out <= jalr_in;
            b_rs1_pc_out <= b_rs1_pc_in;
            use_imm_out <= use_imm_in;
            is_mul_out <= is_mul_in;
            is_rsqr_out <= is_rsqr_in;
            op_a_out <= op_a_in;
            op_s_out <= op_s_in;
            op_l_out <= op_l_in;
            bra_c_out <= bra_c_in;
            sel_r_out <= sel_r_in;
            is_lui_out <= is_lui_in;
            is_auipc_out <= is_auipc_in;
        end
        // If stall is active, all outputs remain unchanged
    end
endmodule
