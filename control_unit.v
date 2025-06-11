module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg reg_write, 
    output reg mem_read, mem_write, mem_to_reg,
    output reg [1:0] access_sz,     // 00: byte, 01: half, 10: word
    output reg s_us,          // 0: signed, 1: unsigned (for loads)
    output reg branch, jump, jalr, 
    output reg b_rs1_pc,      // 0: rs1+offset, 1: pc+offset for branches
    output reg use_imm,       // 0: use rs2, 1: use immediate
    output reg is_mul, is_rsqr,
    output reg [3:0] op_a,          // Arithmetic operations
    output reg [2:0] op_l,          // Logical operations  
    output reg [3:0] op_s,          // Shift operations
    output reg [2:0] bra_c,         // Branch condition
    output reg [1:0] sel_r,         // Result select: 00=arith, 01=wire, 10=shift, 11=imm
    output reg is_lui, is_auipc
);

    always @(*) begin
        // Default values - all control signals off
        reg_write = 1'b0;
        mem_read = 1'b0; 
        mem_write = 1'b0; 
        mem_to_reg = 1'b0;
        access_sz = 2'b10;    // Default to word
        s_us = 1'b0;          // Default to signed
        
        branch = 1'b0; 
        jump = 1'b0; 
        jalr = 1'b0;
        b_rs1_pc = 1'b1;      // Default to PC-relative
        
        use_imm = 1'b0;
        is_mul = 1'b0; 
        is_rsqr = 1'b0;
        
        op_a = 4'b0000; 
        op_s = 4'b0000; 
        op_l = 3'b000; 
        bra_c = 3'b000;
        sel_r = 2'b00;
        
        is_lui = 1'b0;
        is_auipc = 1'b0;

        case (opcode)
            7'b0110011: begin  // R-type instructions
                reg_write = 1'b1;
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000001) begin
                            is_mul = 1'b1;           // MUL
                            sel_r = 2'b00;
                        end
                        else if (funct7 == 7'b0000010) begin
                            is_rsqr = 1'b1;          // RSQR (custom instruction)
                            sel_r = 2'b00;
                        end
                        else if (funct7 == 7'b0100000) begin
                            op_a = 4'b1000;          // SUB
                            sel_r = 2'b00;
                        end
                        else begin
                            op_a = 4'b0000;          // ADD
                            sel_r = 2'b00;
                        end
                    end
                    3'b001: begin
                        op_s = 4'b0001;              // SLL
                        sel_r = 2'b10;
                    end
                    3'b010: begin
                        op_a = 4'b0010;              // SLT
                        sel_r = 2'b00;
                    end
                    3'b011: begin
                        op_a = 4'b0011;              // SLTU
                        sel_r = 2'b00;
                    end
                    3'b100: begin
                        op_l = 3'b100;               // XOR
                        sel_r = 2'b01;
                    end
                    3'b101: begin
                        if (funct7[5]) 
                            op_s = 4'b1101;          // SRA
                        else 
                            op_s = 4'b0101;          // SRL
                        sel_r = 2'b10;
                    end
                    3'b110: begin
                        op_l = 3'b110;               // OR
                        sel_r = 2'b01;
                    end
                    3'b111: begin
                        op_l = 3'b111;               // AND
                        sel_r = 2'b01;
                    end
                endcase
            end
            
            7'b0010011: begin  // I-type ALU instructions
                reg_write = 1'b1; 
                use_imm = 1'b1;
                case (funct3)
                    3'b000: begin
                        op_a = 4'b0000;              // ADDI
                        sel_r = 2'b00;
                    end
                    3'b010: begin
                        op_a = 4'b0010;              // SLTI
                        sel_r = 2'b00;
                    end
                    3'b011: begin
                        op_a = 4'b0011;              // SLTIU
                        sel_r = 2'b00;
                    end
                    3'b100: begin
                        op_l = 3'b100;               // XORI
                        sel_r = 2'b01;
                    end
                    3'b110: begin
                        op_l = 3'b110;               // ORI
                        sel_r = 2'b01;
                    end
                    3'b111: begin
                        op_l = 3'b111;               // ANDI
                        sel_r = 2'b01;
                    end
                    3'b001: begin
                        op_s = 4'b0001;              // SLLI
                        sel_r = 2'b10;
                    end
                    3'b101: begin
                        if (funct7[5]) 
                            op_s = 4'b1101;          // SRAI
                        else 
                            op_s = 4'b0101;          // SRLI
                        sel_r = 2'b10;
                    end
                endcase
            end
            
            7'b0000011: begin  // Load instructions
                reg_write = 1'b1; 
                mem_read = 1'b1; 
                mem_to_reg = 1'b1;
                use_imm = 1'b1;
                op_a = 4'b0000;  // Address calculation: rs1 + imm
                b_rs1_pc = 1'b0; // Use rs1 for address calculation
                
                case (funct3)
                    3'b000: begin  // LB
                        access_sz = 2'b00;
                        s_us = 1'b0;
                    end
                    3'b001: begin  // LH
                        access_sz = 2'b01;
                        s_us = 1'b0;
                    end
                    3'b010: begin  // LW
                        access_sz = 2'b10;
                        s_us = 1'b0;
                    end
                    3'b100: begin  // LBU
                        access_sz = 2'b00;
                        s_us = 1'b1;
                    end
                    3'b101: begin  // LHU
                        access_sz = 2'b01;
                        s_us = 1'b1;
                    end
                    default: begin
                        access_sz = 2'b10;
                        s_us = 1'b0;
                    end
                endcase
            end
            
            7'b0100011: begin  // Store instructions
                mem_write = 1'b1; 
                use_imm = 1'b1;
                op_a = 4'b0000;  // Address calculation: rs1 + imm
                b_rs1_pc = 1'b0; // Use rs1 for address calculation
                
                case (funct3)
                    3'b000: access_sz = 2'b00;  // SB
                    3'b001: access_sz = 2'b01;  // SH
                    3'b010: access_sz = 2'b10;  // SW
                    default: access_sz = 2'b10;
                endcase
            end
            
            7'b1100011: begin  // Branch instructions
                branch = 1'b1;
                bra_c = funct3;
                op_a = 4'b1000;   // Subtraction for comparison
                b_rs1_pc = 1'b1;  // PC-relative branch target
                use_imm = 1'b1;   // Use immediate for branch offset
            end
            
            7'b1101111: begin  // JAL
                reg_write = 1'b1; 
                jump = 1'b1;
                b_rs1_pc = 1'b1;  // PC-relative jump
                use_imm = 1'b1;
                sel_r = 2'b11;    // Store PC+4 in rd
            end
            
            7'b1100111: begin  // JALR
                reg_write = 1'b1; 
                jalr = 1'b1;
                b_rs1_pc = 1'b0;  // rs1-relative jump
                use_imm = 1'b1;
                op_a = 4'b0000;   // rs1 + imm for target address
                sel_r = 2'b11;    // Store PC+4 in rd
            end
            
            7'b0110111: begin  // LUI
                reg_write = 1'b1;
                is_lui = 1'b1;
                use_imm = 1'b1;
                sel_r = 2'b11;    // Pass immediate directly
            end
            
            7'b0010111: begin  // AUIPC
                reg_write = 1'b1;
                is_auipc = 1'b1;
                use_imm = 1'b1;
                op_a = 4'b0000;   // PC + imm
                b_rs1_pc = 1'b1;  // Use PC for calculation
                sel_r = 2'b00;
            end
            
            default: begin
                // All signals remain at default (inactive) values
                // This handles undefined opcodes gracefully
            end
        endcase
    end
endmodule
