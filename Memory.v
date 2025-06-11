module Memory(
		input clk,
		input start,
		input [2:0]memaccess,
		input [1:0]size,
		input [9:0]Memaddr,
		input [31:0]datain,
		output reg [31:0]dataout
		);
		
		reg [7:0] Mem [0:1023];
		
		
		
		
		always@(posedge clk) begin
		if (memaccess[0]) begin
			
				if(memaccess[1]) begin	
					case(size)
					2'b00: Mem[Memaddr] <= datain[7:0];
					2'b01: begin
						Mem[Memaddr] <= datain[7:0];
						Mem[Memaddr+1] <= datain[15:8];
					end
					2'b10: begin
						Mem[Memaddr] <= datain[7:0];
						Mem[Memaddr+1] <= datain[15:8];
						Mem[Memaddr+2] <= datain[23:16];
						Mem[Memaddr+3] <= datain[31:24];
					end
					endcase
				end
				
				else if(memaccess[2]) begin
					case (size)
                2'b00: dataout <= {{24{Mem[Memaddr][7]}}, Mem[Memaddr]};       // LB
                2'b01: dataout <= {{16{Mem[Memaddr + 1][7]}}, Mem[Memaddr + 1], Mem[Memaddr]}; // LH
                2'b10: dataout <= {Mem[Memaddr + 3], Mem[Memaddr + 2], Mem[Memaddr + 1], Mem[Memaddr]}; // LW
            endcase
					end
			end
		end
			
			
				
endmodule				
			
		