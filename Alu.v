/*module ALU(
    input clk,
input logic [31:0]rs1,
input logic [31:0] imm,
input logic [31:0] rs2,
input [2:0]op_type,
input [31:0] pc,
input [1:0]immctrl,
input [4:0]op,
output reg [4:0] rd,
output reg [31:0] next_pc
);

reg take_branch;
reg [31:0] branch_target;


//arithmetic
wire [31:0]operand2 = (immctrl[0])? imm:rs2;
reg [9:0] ls_addr;


always@(posedge clk) begin
	
	case (op_type)
	3'd0:
	case(op)
            5'd0  : rd = rs1 + operand2;                        // ADD, ADDI
            5'd1  : rd = rs1 - operand2;                        // SUB
            5'd2  : rd = rs1 ^ operand2;                        // XOR, XORI
            5'd3  : rd = rs1 | operand2;                        // OR, ORI
            5'd4  : rd = rs1 & operand2;                        // AND, ANDI
            5'd5  : rd = rs1 << operand2[4:0];                  // SLL, SLLI
            5'd6  : rd = rs1 >> operand2[4:0];                  // SRL, SRLI (logical shift)
            5'd7  : rd = $signed(rs1) >>> operand2[4:0];        // SRA, SRAI (arithmetic shift)
            5'd8  : rd = ($signed(rs1) < $signed(operand2)) ? 32'd1 : 32'd0; // SLT, SLTI
            5'd9  : rd = (rs1 < operand2) ? 32'd1 : 32'd0;      // SLTU, SLTIU
            default: rd = 32'd0;
        endcase
		3'd1:
		ls_addr <= rs1+imm;
		3'd2:
	case (op) 
		5'd0: if (rs1 == rs2)          take_branch = 1'b1;  // BEQ
        5'd1: if (rs1 != rs2)          take_branch = 1'b1;  // BNE
        5'd2: if ($signed(rs1) < $signed(rs2)) take_branch = 1'b1;  // BLT
        5'd3: if ($signed(rs1) >= $signed(rs2)) take_branch = 1'b1; // BGE
        5'd4: if (rs1 < rs2)           take_branch = 1'b1;  // BLTU
        5'd5: if (rs1 >= rs2)          take_branch = 1'b1;  // BGEU
        default: take_branch = 1'b0;
	endcase
	3'd3:	
	case(op)
	5'd0: rd <= im<<4'd12;
	5'd1: rd <= pc+ imm<<4'd12;
	endcase
	endcase
end
endmodule */
// Updated EX stage code for more detailed explained with reference to Chandra Shekhar sir's code and aligning with control_unit.v code
module rv32i_ex1 (
    input  [31:0] rs1_d, rs2i_d, imm_d, pc_v, off_v,
    input  [3:0] op_a, op_s,
    input  [2:0] op_l,
    input  [1:0] sel_r,
    input  [2:0] bra_c,
    input        b_rs1_pc,
    input        is_mul, is_rsqr,
    output reg [31:0] res_d_op, res_brt_dma,
    output reg        res_bra
);

    reg [32:0] res_d_op_a_33;
    reg [31:0] res_d_op_a_32, res_d_op_l_32, res_d_op_s_32;
    wire [63:0] product;
    wire [63:0] square;
    wire [31:0] mul_result, rsqr_result;


    // Arithmetic operations
    always @(*) begin
        case (op_a)
            4'b0000: begin
                res_d_op_a_33 = rs1_d + rs2i_d;
                res_d_op_a_32 = res_d_op_a_33[31:0];
            end
            4'b1000: begin
                res_d_op_a_33 = rs1_d - rs2i_d;
                res_d_op_a_32 = res_d_op_a_33[31:0];
            end
            4'b0010: begin
                res_d_op_a_33 = rs1_d - rs2i_d;
                res_d_op_a_32 = {31'b0, res_d_op_a_33[32]};
            end
            4'b0011: begin
                res_d_op_a_33 = rs1_d - rs2i_d;
                res_d_op_a_32 = {31'b0, ~res_d_op_a_33[32]};
            end
            default: begin
    res_d_op_a_33 = 33'd0;
    res_d_op_a_32 = 32'd0;
                res_d_op_a_33 = rs1_d + rs2i_d;
                res_d_op_a_32 = res_d_op_a_33[31:0];
            end
        endcase
    end

    // Logical operations
    always @(*) begin
        case (op_l)
            3'b100: res_d_op_l_32 = rs1_d ^ rs2i_d;
            3'b110: res_d_op_l_32 = rs1_d | rs2i_d;
            3'b111: res_d_op_l_32 = rs1_d & rs2i_d;
            default: res_d_op_l_32 = rs1_d ^ rs2i_d;
        endcase
    end

    // Shift operations
    always @(*) begin
        case (op_s)
            4'b0001: res_d_op_s_32 = rs1_d << rs2i_d[4:0];
            4'b0101: res_d_op_s_32 = rs1_d >> rs2i_d[4:0];
            4'b1101: res_d_op_s_32 = $signed(rs1_d) >>> rs2i_d[4:0];
            default: res_d_op_s_32 = rs1_d << rs2i_d[4:0];
        endcase
    end

    // Branch evaluation
    always @(*) begin
        case (bra_c)
            3'b000: res_bra = (res_d_op_a_33 == 0);
            3'b001: res_bra = (res_d_op_a_33 != 0);
            3'b100: res_bra = res_d_op_a_33[32];
            3'b101: res_bra = ~res_d_op_a_33[32];
            3'b110: res_bra = ~res_d_op_a_33[32];
            3'b111: res_bra = res_d_op_a_33[32];
            default: res_bra = 1'b0;
        endcase
    end

    // MUL and RSQR
    assign product  = $signed(rs1_d) * $signed(rs2i_d);
    assign mul_result = product[31:0];
    assign square  = $signed(rs1_d) * $signed(rs1_d);
    assign rsqr_result = square[31:0];

    always @(*) begin
        case (sel_r)
            2'b00: res_d_op = is_mul  ? mul_result :
                              is_rsqr ? rsqr_result : res_d_op_a_32;
            2'b01: res_d_op = res_d_op_l_32;
            2'b10: res_d_op = res_d_op_s_32;
            default: res_d_op = rs2i_d;
        endcase
    end

    // Branch target or memory address calculation
    always @(*) begin
        res_brt_dma = b_rs1_pc ? (pc_v + off_v) : (rs1_d + off_v);
    end
endmodule
