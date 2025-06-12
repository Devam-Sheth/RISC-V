module instrmem(
		input [6:0] inaddr,
		output reg[31:0] instr
		);
		
		reg [31:0] instructionmemory[0:127];
		
		always@(*)
		begin
		instr = instructionmemory[inaddr];
		end
		
		initial begin
        instructionmemory[0] = 
        instructionmemory[1] = 
        instructionmemory[2] = 
        end
		
		endmodule