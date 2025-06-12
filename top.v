module Riscv_Top (
    input clk,
    input reset
);

	wire [31:0] instr;
	wire [31:0] pc;
	wire [31:0] rs1_data; 
	wire [31:0] rs2_data;
    	wire [31:0] imm_val;
	wire [4:0] rs1;
	wire [4:0] rs2;
    	wire [4:0] rd;
    	wire [6:0] opcode;
    	wire [2:0] funct3;
    	wire [6:0] funct7;
	wire reg_write; 
	wire mem_read;
	wire mem_write;
	wire mem_to_reg;
	wire [1:0] access_sz;
    	wire s_us;    
    	wire branch;
    	wire jump;
    	wire jalr; 
    	wire b_rs1_pc;  
    	wire use_imm;       
	wire [3:0] op_a;        
	wire [2:0] op_l;     
	wire [3:0] op_s;
	wire [2:0] bra_c;
	wire [1:0] sel_r;
    	wire is_lui;
    	wire is_auipc;
    	wire stall;
    	wire flush;
	wire [31:0] rs1_data_in;
	wire [31:0] rs2_data_in;
	wire [31:0] pc_in, //pc_plus_4_in, // remove pc_plus_4 in every code ig
	wire [31:0] rs1_data_out;
	wire [31:0] rs2_data_out;
	wire [31:0] rs2_data_out1;
	wire [31:0] imm_out;
    //wire [31:0] pc_out, pc_plus_4_out,
	wire [4:0] rs1_addr_out;
	wire [4:0] rs2_addr_out;
	wire [4:0] rd_addr_out,rd_addr_out1;
	wire reg_write_out,
	wire reg_write_out1;
	wire mem_read_out,
	wire mem_read_out1;
	wire mem_write_out,
	wire mem_write_out1;
	wire mem_to_reg_out,
	wire mem_to_reg_out1;
	wire [1:0] access_sz_out,access_sz_out1;
        wire s_us_out,s_us_out1;
        wire branch_out;
        wire jump_out,jump_out1;
        wire jalr_out,jalr_out1;
        wire b_rs1_pc_out;
        wire use_imm_out;
	wire [3:0] op_a_out;
	wire [3:0] op_s_out;
	wire [2:0] op_l_out;
	wire [2:0] bra_c_out;
	wire [1:0] sel_r_out;
        wire is_lui_out;
        wire is_auipc_out;
    //input [4:0] id_ex_rs1, id_ex_rs2,
    //input [4:0] ex_mem_rd, mem_wb_rd,
    //input       ex_mem_reg_write,
    //input       mem_wb_reg_write,
	wire [1:0] forward_a;
	wire [1:0]forward_b;
	wire [31:0] alu_result;
	wire [31:0] branch_target;
        wire branch_taken;
	wire [31:0] jalr_target;
    //wire [31:0] pc_plus_4_out,
	wire [31:0] alu_result_out;
    //wire [31:0] rs2_data_out,
	wire [31:0] branch_target_out;
    //wire [4:0]  rd_addr_out,
        wire branch_taken_out;
    //wire [1:0] access_sz_out,
    //wire s_us_out, jump_out, jalr_out //take care of the above 3 first and ex_mem_reg also
	wire [31:0]dataout;
	wire [31:0] ld_32;
    //output reg [4:0]  rd_out,
	wire [31:0] alu_result_out_memwbpipeline;
	wire [31:0] ld_data_out;
    //output reg reg_write_out
	wire [31:0] wb_data;

	pc_wire IF(
		.clk(clk),
		.reset(reset),
		.taken_br(branch), 
		.is_jal(jal),
		.is_jalr(jalr),
		.br_tgt_pc(branch_target), 
		.jalr_tgt_pc(jalr_target),
		.pc(pc)
);
	if_id_pipeline_reg IF_ID_REG(
		.clk(clk),
		.reset(reset),
		.stall(stall),
		.flush(flush),
		.pc_in(pc), //.instr_in(instr), // remove instr_in ig
		.pc_out(pc_in), //instr_out // remove instr_out ig
);
	
	Decoder ID( 
	    .instr(instr),
	    .clk(clk),
		//input [31:0]rs1_datain, // these two commented lines are not required ig
		//input [31:0]rs2_datain,
	    .rs1_dataout(rs1_data),
	    .rs2_dataout(rs2_data),
	    .rs1_addrout(rs1),
	    .rs2_addrout(rs2),
	    .im(imm_val),
	    .rd(rd),
	    .opcode(opcode),
	    .f3(funct3),
	    .f7(funct7)
		);
	
	  control_unit ctrlunit(
	    .opcode(opcode),
	    .funct3(funct3),
	    .funct7(funct7),
	    .reg_write(reg_write), 
	    .mem_read(mem_read),
	    .mem_write(mem_write),
	    .mem_to_reg(mem_to_reg),
	    .access_sz(access_sz),
	    .s_us(s_us),         
	    .branch(branch),
	    .jump(jump),
	    .jalr(jalr), 
	    .b_rs1_pc(b_rs1_pc),      
	    .use_imm(use_imm),       
	    .op_a(op_a),          
	    .op_l(op_l),          
	    .op_s(op_s),          
	    .bra_c(bra_c),        
	    .sel_r(sel_r),         
	    .is_lui(is_lui),
	    .is_auipc(is_auipc)
	);
	
	id_ex_pipeline_reg ID_EX_REG(
	    .clk(clk),
	    .reset(reset),
	    .stall(stall),
	    .flush(flush),
	    .rs1_data_in(rs1_data_in),
	    .rs2_data_in(rs2_data_in),
	    .imm_in(imm_val),
	    //input [31:0] pc_in, pc_plus_4_in,
	    .rs1_addr_in(rs1),
	    .rs2_addr_in(rs2),
	    .rd_addr_in(rd),
	    .reg_write_in(reg_write), 
	    .mem_read_in(mem_read),
	    .mem_write_in(mem_write),
	    .mem_to_reg_in(mem_to_reg),
	    .access_sz_in(access_sz),
	    .s_us_in(s_us),
	    .branch_in(branch),
	    .jump_in(jump),
	    .jalr_in(jalr),
	    .b_rs1_pc_in(b_rs1_pc),
	    .use_imm_in(use_imm),
	    .op_a_in(op_a),
	    .op_s_in(op_s),
	    .op_l_in(op_l),
	    .bra_c_in(bra_c),
	    .sel_r_in(sel_r),
	    .is_lui_in(is_lui),
	    .is_auipc_in(is_auipc),
	    .rs1_data_out(rs1_data_out),
	    .rs2_data_out(rs2_data_out), 
	    .imm_out(imm_out),
	    //output reg [31:0] pc_out, pc_plus_4_out,
	    .rs1_addr_out(rs1_addr_out),
	    .rs2_addr_out(rs2_addr_out),
	    .rd_addr_out(rd_addr_out),
	    .reg_write_out(reg_write_out),
	    .mem_read_out(mem_read_out),
	    .mem_write_out(.mem_write_out),
	    .mem_to_reg_out(mem_to_reg_out),
	    .access_sz_out(access_sz_out),
	    .s_us_out(s_us_out),
	    .branch_out(branch_out),
	    .jump_out(jump_out),
	    .jalr_out(jalr_out),
	    .b_rs1_pc_out(b_rs1_pc_out),
	    .use_imm_out(use_imm_out),
	    .op_a_out(op_a_out),
	    .op_s_out(op_s_out),
	    .op_l_out(op_l_out),
	    .bra_c_out(bra_c_out),
	    .sel_r_out(sel_r_out),
	    .is_lui_out(is_lui_out),
	    .is_auipc_out(is_auipc_out)
	);
	
	forwarding_unit FU(      // not sure of this rn
		.id_ex_rs1(rs1), 
		.id_ex_rs2(rs2),
		.ex_mem_rd(rd), 
		.mem_wb_rd(rd),
		.ex_mem_reg_write(reg_write),
		.mem_wb_reg_write(reg_write),
	    .forward_a(forward_a), .forward_b(forward_b)
	);
	
	rv32i_ex EX(
	    .rs1_d(rs1_data_out), 
	    .rs2_d(rs2_data_out), 
	    .imm_d(imm_out),// pc_d, pc_plus_4,
	    .rs1_addr(rs1_addr_out),
	    .rs2_addr(rs2_addr_out),
	    .op_a(op_a_out),
	    .op_s(op_s_out),
	    .op_l(op_l_out),
	    .bra_c(bra_c_out),
	    .sel_r(sel_r_out),
	    .is_lui(is_lui_out),
	    .is_auipc(is_auipc_out)
	    .forward_a(forward_a), 
	    .forward_b(forward_b),
	    //input [31:0] ex_mem_alu_result,
	    //input [31:0] mem_wb_data,
	    .alu_result(alu_result),
	    .branch_target(branch_target),
	    .branch_taken(branch_taken),
	    .jalr_target(jalr_target)
	);
	
	ex_mem_pipeline_reg EX_MEM_REG(
		  .clk(clk), .reset(reset),
	    //input [31:0] pc_plus_4_in,
		  .alu_result_in(alu_result),
		.rs2_data_in(rs2_data_out), //for store
		  .branch_target_in(branch_target),
		.rd_addr_in(rd_addr_out),
		  .branch_taken_in(branch_taken), //left to add jalr_target_in
		.reg_write_in(reg_write_out),
		.mem_read_in(mem_read_out), 
		.mem_write_in(mem_read_out), 
		.mem_to_reg_in(mem_to_reg_out),
		.access_sz_in(access_sz_out),
		.s_us_in(s_us_out), 
		.jump_in(jump_out),
		.jalr_in(jalr_out), //branch_out left
	    //output reg [31:0] pc_plus_4_out, 
		  .alu_result_out(alu_result_out),
		.rs2_data_out(rs2_data_out1),
		  .branch_target_out(branch_target_out),
		  .rd_addr_out(rd_addr_out1),
		  .branch_taken_out(branch_taken_out),
		.reg_write_out(reg_write_out1),
		.mem_read_out(.mem_read_out1), 
		.mem_write_out(mem_write_out1), 
		.mem_to_reg_out(.mem_to_reg_out),
		.access_sz_out(access_sz_out1),
		.s_us_out(s_us_out1),
		.jump_out(jump_out1), 
		.jalr_out(jalr_out1)
	);
	
	Memory DataMemory(
		   .clk(clk),
			//input start,
			//input [2:0]memaccess,
			//input [1:0]size,
			//input [9:0]Memaddr,
			//input [31:0]datain,
		   .dataout(dataout)
	);
	
	rv32i_mem_stage (
	    //input [31:0] dm_adr,        // data memory address (low endian)
		.access_sz(access_sz_out1),      // Byte (00), Half (01), Word (10)
		.s_us(s_us_out1),                 // signed(0) / unsigned(1) load
	    //input [31:0] sd_32,         // data to store
	    //input [1:0] acc_type,       // read(01), write(10), else no access
		    .ld_32(ld_32)     // data read from memory
	);
	// sole this tomorrow memwbreg
	mem_wb_pipeline_reg MEM_WB_REG(
		    .clk(clk),
	    //input [4:0]  rd_in,
		    .alu_result_in(alu_result_out),
		    .ld_data_in(ld_32),
	    //input reg_write_in,
	//stalling condn is left ig
	    //output reg [4:0]  rd_out,
		    .alu_result_out(alu_result_out_memwbpipeline),
		    .ld_data_out(ld_data_out),
	    //output reg reg_write_out
	);
	
	writeback WB(
		    .alu_result(alu_result_out_memwbpipeline),
		    .ld_data(ld_data_out),
		.mem_to_reg(mem_to_reg),
		    .wb_data(wb_data)
	);
	
	registers RegisterFile(
		    .clk(clk),
		    .reset(reset),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.regwrite(reg_write),
		    .datain(wb_data),
		    .rs1_data(rs1_data_in),
		    .rs2_data(rs2_data_in)
						);
		
