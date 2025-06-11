// renamed pipeline1 to if_id_pipeline_reg, contents being the same
/* module pipeline1(	
		input clk,
		input reg[31:0] pc_i,
		input reg[31:0] instr_i,
		output reg[31:0] pc_o,
		output reg[31:0] instr_o
		);
		
		always@(posedge clk) begin
		pc_o <= pc_i;
		instr_o<= instr_i;
		end
		
	endmodule */
module if_id_pipeline_reg (
    input clk, reset, stall, flush,
    input [31:0] pc_in, instr_in,
    output reg [31:0] pc_out, instr_out
);
    
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            pc_out <= 32'b0;
            instr_out <= 32'h00000013;  // NOP instruction
        end
        else if (!stall) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
        end
    end
    
endmodule
