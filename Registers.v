	`define x0  5'd0
	`define x1  5'd1
	`define x2  5'd2
	`define x3  5'd3
	`define x4  5'd4
	`define x5  5'd5
	`define x6  5'd6
	`define x7  5'd7
	`define x8  5'd8
	`define x9  5'd9
	`define x10 5'd10
	`define x11 5'd11
	`define x12 5'd12
	`define x13 5'd13
	`define x14 5'd14
	`define x15 5'd15
	`define x16 5'd16
	`define x17 5'd17
	`define x18 5'd18
	`define x19 5'd19
	`define x20 5'd20
	`define x21 5'd21
	`define x22 5'd22
	`define x23 5'd23
	`define x24 5'd24
	`define x25 5'd25
	`define x26 5'd26
	`define x27 5'd27
	`define x28 5'd28
	`define x29 5'd29
	`define x30 5'd30
	`define x31 5'd31


	module registers(
					input clk,
					input reset,
					input [4:0] rs1,
					input [4:0] rs2,
					input [4:0] rd,
					input regwrite,
					input [31:0] datain,
					output wire [31:0] rs1_data,
					output wire [31:0] rs2_data
					);
					
		reg [31:0] Registers [31:0];
		
		
		assign rs1_data = (rs1 == 0) ? 0: Registers[rs1];
		assign rs2_data = (rs2 == 0) ? 0: Registers[rs2]; 
		

		always@(posedge clk or posedge reset)
			begin
			if (reset) begin
            integer i;
            for (i = 0; i < 32; i = i + 1)
                Registers[i] <= 32'd0;
			end
			else if(regwrite && rd!=0) begin
				Registers[rd] <= datain;
				end
			end
		
	endmodule		