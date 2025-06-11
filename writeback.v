/*module WriteBack(
				input clk,
				input [31:0]data,
				input [4:0]rd,
				input regwrite,
				output reg regwrite_o,
				output reg [4:0]rd_o,
				output reg [31:0]data_o
				);
				
				
				
	always@(posedge clk) begin
		if(regwrite) begin
			regwrite_o<= regwrite;
			rd_o <= rd;
			data_o <= data;
		end else begin
            regwrite_o <= 0;
            rd_o <= 5'd0;
            data_o <= 32'd0;
        end
	end
endmodule */	
module writeback (
    input [31:0] alu_result,
    input [31:0] ld_data,
    input mem_to_reg,
    output reg [31:0] wb_data
);

    always @(*) begin
    if (mem_to_reg)
        wb_data = ld_data;
    else
        wb_data = alu_result;
end

endmodule

    assign wb_data = mem_to_reg ? ld_data : alu_result;

endmodule
