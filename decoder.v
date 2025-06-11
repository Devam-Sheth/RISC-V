	
module Decoder(
	input wire [31:0]	instr,
	input clk,
	input [31:0]rs1_datain,
	input [31:0]rs2_datain,
	output wire [31:0]	rs1_dataout,
	output wire [31:0]	rs2_dataout,
	output wire [4:0]	rs1_addrout,
	output wire [4:0]	rs2_addrout,
	output reg [31:0]	im,
	output wire[4:0] 	rd,
	output wire [6:0] opcode,
	output wire [2:0]f3,
	output wire [6:0]f7
	
	);
	
	wire [4:0]rs1_addr;
	wire [4:0]rs2_addr;
	
	
	assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign f3 = instr[14:12];
    assign rs1_addr    = instr[19:15];
    assign rs2_addr    = instr[24:20];
    assign f7 = instr[31:25];
	
	assign rs1_addrout = rs1_addr;
	assign rs2_addrout = rs2_addr;
	
	assign rs1_dataout = rs1_datain;
    assign rs2_dataout = rs2_datain;
	
	
	
	always @(posedge clk) begin
		
	
        casez (opcode)
            7'b0110011: begin im = 32'b0; end     																	//R-type
			7'b0010011, 7'b0000011, 7'b1100111: begin    															//I-type
            case (f3)
                3'b001: begin // slli
                    if (f7 == 7'b0000000)
                        im = {27'b0, instr[24:20]};
					else
                        im = 32'bx;	
                    end
                3'b101: begin
                    if (f7 == 7'b0000000) // srli
                        im = {27'b0, instr[24:20]};
                    else if (f7 == 7'b0100000) // srai
                        im = {27'b0, instr[24:20]};
                    else
                        im = 32'bx; // invalid
                end
                default: begin
                    im = {{20{instr[31]}}, instr[31:20]}; 
                end
            endcase
        end						
           7'b0100011: begin im = {{20{instr[31]}}, instr[31:25], instr[11:7]}; end                                   //S-type
            7'b1100011: begin im = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; end       //B-type
            7'b1101111: begin im = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; end     //J-type
            7'b0110111,7'b0010111:
						begin im = {instr[31:12], 12'b0}; end      													  //U-type
            default: 	begin im = 32'b0; end
        endcase
    end
    end
		
		
	endmodule	
		
		