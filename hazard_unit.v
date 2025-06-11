module hazard_unit (
    input [4:0] if_id_rs1, if_id_rs2,
    input [6:0] if_id_opcode,
    input [4:0] id_ex_rd,
    input id_ex_mem_read,
    input id_ex_branch, id_ex_jump, id_ex_jalr,
    input [4:0] ex_mem_rd,
    input ex_mem_reg_write,
    input ex_mem_branch_taken,
    input ex_mem_jump, ex_mem_jalr,
    input [4:0] mem_wb_rd,
    input mem_wb_reg_write,
    output reg pc_write,        // Enable PC update
    output reg if_id_write,     // Enable IF/ID register update
    output reg id_ex_flush,     // Flush ID/EX register (insert bubble)
    output reg if_id_flush,     // Flush IF/ID register
    output reg stall            // Overall stall signal
);

    reg load_use_hazard;
    reg branch_hazard;
    reg jump_hazard;
    reg control_hazard;

    always @(*) begin
        load_use_hazard = 1'b0;
        branch_hazard = 1'b0;
        jump_hazard = 1'b0;
        control_hazard = 1'b0;
        
        // 1. LOAD-USE HAZARD DETECTION
        // Check if previous instruction is a load and current uses its result
        if (id_ex_mem_read && (id_ex_rd != 5'b0)) begin
            if ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)) begin
                load_use_hazard = 1'b1;
            end
        end
        
        // 2. BRANCH HAZARD DETECTION
        // Check if branch instruction needs data from previous instructions
        if (if_id_opcode == 7'b1100011) begin // Branch instructions
            // Check for data dependency with ID/EX stage
            if (id_ex_reg_write && (id_ex_rd != 5'b0)) begin
                if ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)) begin
                    branch_hazard = 1'b1;
                end
            end
            // Check for data dependency with EX/MEM stage
            if (ex_mem_reg_write && (ex_mem_rd != 5'b0)) begin
                if ((ex_mem_rd == if_id_rs1) || (ex_mem_rd == if_id_rs2)) begin
                    branch_hazard = 1'b1;
                end
            end
        end
        
        // 3. JUMP HAZARD DETECTION (for JALR)
        // JALR depends on rs1 value
        if (if_id_opcode == 7'b1100111) begin // JALR instruction
            // Check for data dependency with ID/EX stage
            if (id_ex_reg_write && (id_ex_rd != 5'b0)) begin
                if (id_ex_rd == if_id_rs1) begin
                    jump_hazard = 1'b1;
                end
            end
            // Check for data dependency with EX/MEM stage
            if (ex_mem_reg_write && (ex_mem_rd != 5'b0)) begin
                if (ex_mem_rd == if_id_rs1) begin
                    jump_hazard = 1'b1;
                end
            end
        end
        
        // 4. CONTROL HAZARD (Branch taken or jump executed)
        if (ex_mem_branch_taken || ex_mem_jump || ex_mem_jalr) begin
            control_hazard = 1'b1;
        end
        
        // Generate control signals based on hazard types
        if (load_use_hazard || branch_hazard || jump_hazard) begin
            // Stall pipeline
            pc_write = 1'b0;        // Don't update PC
            if_id_write = 1'b0;     // Don't update IF/ID register
            id_ex_flush = 1'b1;     // Insert bubble in ID/EX stage
            if_id_flush = 1'b0;     // Keep IF/ID content
            stall = 1'b1;
        end
        else if (control_hazard) begin
            // Flush pipeline due to control hazard
            pc_write = 1'b1;        // Update PC with new target
            if_id_write = 1'b1;     // Allow IF/ID update
            id_ex_flush = 1'b1;     // Flush ID/EX stage
            if_id_flush = 1'b1;     // Flush IF/ID stage
            stall = 1'b0;
        end
        else begin
            // No hazard - normal operation
            pc_write = 1'b1;
            if_id_write = 1'b1;
            id_ex_flush = 1'b0;
            if_id_flush = 1'b0;
            stall = 1'b0;
        end
    end
endmodule
