module rv32i_ex (
    input [31:0] rs1_d, rs2_d, imm_d, pc_d, pc_plus_4,
    input [4:0] rs1_addr, rs2_addr,
    input [3:0] op_a, op_s,
    input [2:0] op_l,
    input [1:0] sel_r,
    input [2:0] bra_c,
    input b_rs1_pc, use_imm,
    input branch, jump, jalr,
    input is_lui, is_auipc,
    
    // Forwarding inputs
    input [1:0] forward_a, forward_b,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_data,
    
    // Outputs
    output reg [31:0] alu_result,
    output reg [31:0] branch_target,
    output reg branch_taken,
    output [31:0] jalr_target
);

    // Internal signals
    reg [32:0] res_d_op_a_33;
    reg [31:0] res_d_op_a_32, res_d_op_l_32, res_d_op_s_32;
    wire [63:0] product, square;
    wire [31:0] mul_result, rsqr_result;
    
    // Forwarded operands
    wire [31:0] forwarded_rs1, forwarded_rs2, rs2i_d;
    
    // Forwarding muxes
    assign forwarded_rs1 = (forward_a == 2'b10) ? ex_mem_alu_result :
                          (forward_a == 2'b01) ? mem_wb_data : rs1_d;
    
    assign forwarded_rs2 = (forward_b == 2'b10) ? ex_mem_alu_result :
                          (forward_b == 2'b01) ? mem_wb_data : rs2_d;
    
    // Select between rs2 and immediate
    assign rs2i_d = use_imm ? imm_d : forwarded_rs2;

    assign product = $signed(forwarded_rs1) * $signed(rs2i_d);
    assign mul_result = product[31:0];
    assign square = $signed(forwarded_rs1) * $signed(forwarded_rs1);
    assign rsqr_result = square[31:0];

    // Arithmetic operations
    always @(*) begin
        case (op_a)
            4'b0000: begin
                res_d_op_a_33 = forwarded_rs1 + rs2i_d;
                res_d_op_a_32 = res_d_op_a_33[31:0];
            end
            4'b1000: begin
                res_d_op_a_33 = forwarded_rs1 - rs2i_d;
                res_d_op_a_32 = res_d_op_a_33[31:0];
            end
            4'b0010: begin  // SLT
                res_d_op_a_33 = $signed(forwarded_rs1) - $signed(rs2i_d);
                res_d_op_a_32 = {31'b0, res_d_op_a_33[32]};
            end
            4'b0011: begin  // SLTU
                res_d_op_a_33 = forwarded_rs1 - rs2i_d;
                res_d_op_a_32 = {31'b0, res_d_op_a_33[32]};
            end
            4'b0100: begin // rsqr
                res_d_op_a_32 = rsqr_result;
            4'b0101: begin // mul
                res_d_op_a_32 = mul_result;
            default: begin
                res_d_op_a_33 = forwarded_rs1 + rs2i_d;
                res_d_op_a_32 = res_d_op_a_33[31:0];
            end
        endcase
    end

    // Logical operations
    always @(*) begin
        case (op_l)
            3'b100: res_d_op_l_32 = forwarded_rs1 ^ rs2i_d;
            3'b110: res_d_op_l_32 = forwarded_rs1 | rs2i_d;
            3'b111: res_d_op_l_32 = forwarded_rs1 & rs2i_d;
            default: res_d_op_l_32 = forwarded_rs1 ^ rs2i_d;
        endcase
    end

    // Shift operations
    always @(*) begin
        case (op_s)
            4'b0001: res_d_op_s_32 = forwarded_rs1 << rs2i_d[4:0];
            4'b0101: res_d_op_s_32 = forwarded_rs1 >> rs2i_d[4:0];
            4'b1101: res_d_op_s_32 = $signed(forwarded_rs1) >>> rs2i_d[4:0];
            default: res_d_op_s_32 = forwarded_rs1 << rs2i_d[4:0];
        endcase
    end

    // Branch evaluation
    always @(*) begin
        case (bra_c)
            3'b000: branch_taken = (forwarded_rs1 == forwarded_rs2);    // BEQ
            3'b001: branch_taken = (forwarded_rs1 != forwarded_rs2);    // BNE
            3'b100: branch_taken = ($signed(forwarded_rs1) < $signed(forwarded_rs2));  // BLT
            3'b101: branch_taken = ($signed(forwarded_rs1) >= $signed(forwarded_rs2)); // BGE
            3'b110: branch_taken = (forwarded_rs1 < forwarded_rs2);     // BLTU
            3'b111: branch_taken = (forwarded_rs1 >= forwarded_rs2);    // BGEU
            default: branch_taken = 1'b0;
        endcase
        
        // Only assert branch_taken if it's actually a branch instruction
        branch_taken = branch & branch_taken;
    end

    // Main ALU result selection
    always @(*) begin
        if (is_lui) begin
            alu_result = imm_d;  // LUI: Load Upper Immediate
        end
        else if (is_auipc) begin
            alu_result = pc_d + imm_d;  // AUIPC: Add Upper Immediate to PC
        end
        else if (jump || jalr) begin
            alu_result = pc_plus_4;  // JAL/JALR: Store return address
        end
        else begin
            case (sel_r)
                2'b01: alu_result = res_d_op_l_32;
                2'b10: alu_result = res_d_op_s_32;
                2'b11: alu_result = imm_d;  // Direct immediate
                default: alu_result = res_d_op_a_32;
            endcase
        end
    end

    // Branch target calculation
    always @(*) begin
        if (b_rs1_pc) begin
            branch_target = pc_d + imm_d;  // PC-relative (branches, JAL)
        end
        else begin
            branch_target = forwarded_rs1 + imm_d;  // Register-relative (JALR)
        end
    end
    
    // JALR target (special case)
    assign jalr_target = (forwarded_rs1 + imm_d) & ~32'h1;  // Clear LSB as per RISC-V spec

endmodule
