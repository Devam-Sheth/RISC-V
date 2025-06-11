/*module memoryaccess(
					input clk,
					input [2:0]memacc,
					output reg [2:0]memacc_o,
					output reg [31:0]data_out,
					input [1:0] sizein,
					output reg [1:0] sizeout,
					input [31:0]datain,
					output reg [31:0] memdatain,
					input[31:0] memdataout,
					input [31:0] addr_alu,
					output reg [31:0] addr_memx,
					output [31:0] mem_dataout,
					
					);
							
		assign memacc_o = memacc;
		assign sizeout = sizein;
			
		always@(posedge clk) begin
		
		
		if(memacc[0]) begin
			addr_mem <= addr_alu;
		
		if(memacc[1]) begin
			mem_dataout <= memdataout;
		end
		if(memacc[2]) begin
			memdatain<= datain;
		end
		end
		else begin
		data_out <= addr_alu;
		
	end
endmodule */	

// MEM stage code as per Chandra Shekhar sir's code as it is more detailed 
module rv32i_mem_stage (
    input [31:0] dm_adr,        // data memory address (low endian)
    input [1:0] access_sz,      // Byte (00), Half (01), Word (10)
    input s_us,                 // signed(0) / unsigned(1) load
    input [31:0] sd_32,         // data to store
    input [1:0] acc_type,       // read(01), write(10), else no access
    output reg [31:0] ld_32     // data read from memory
);

    reg [31:0] mem_d [0:255]; // word-addressable memory

    function [31:0] mem_d_load;
        input [31:0] mem_data_byte_adr;
        input [1:0] data_size;
        input s_us;

        reg [7:0] w1b3, w1b2, w1b1, w1b0, w2b3, w2b2, w2b1, w2b0;
        reg [1:0] boff;
    begin
        boff = mem_data_byte_adr[1:0];
        {w1b3, w1b2, w1b1, w1b0} = mem_d[mem_data_byte_adr[31:2]];
        {w2b3, w2b2, w2b1, w2b0} = mem_d[mem_data_byte_adr[31:2] + 1];

        case (data_size)
            2'b00: // LB, LBU
                case (boff)
                    2'b00: mem_d_load = s_us ? {24'b0, w1b0} : {{24{w1b0[7]}}, w1b0};
                    2'b01: mem_d_load = s_us ? {24'b0, w1b1} : {{24{w1b1[7]}}, w1b1};
                    2'b10: mem_d_load = s_us ? {24'b0, w1b2} : {{24{w1b2[7]}}, w1b2};
                    2'b11: mem_d_load = s_us ? {24'b0, w1b3} : {{24{w1b3[7]}}, w1b3};
                endcase

            2'b01: // LH, LHU
                case (boff)
                    2'b00: mem_d_load = s_us ? {16'b0, w1b1, w1b0} : {{16{w1b1[7]}}, w1b1, w1b0};
                    2'b01: mem_d_load = s_us ? {16'b0, w1b2, w1b1} : {{16{w1b2[7]}}, w1b2, w1b1};
                    2'b10: mem_d_load = s_us ? {16'b0, w1b3, w1b2} : {{16{w1b3[7]}}, w1b3, w1b2};
                    2'b11: mem_d_load = s_us ? {16'b0, w2b0, w1b3} : {{16{w2b0[7]}}, w2b0, w1b3};
                endcase

            2'b10: // LW
                case (boff)
                    2'b00: mem_d_load = {w1b3, w1b2, w1b1, w1b0};
                    2'b01: mem_d_load = {w2b0, w1b3, w1b2, w1b1};
                    2'b10: mem_d_load = {w2b1, w2b0, w1b3, w1b2};
                    2'b11: mem_d_load = {w2b2, w2b1, w2b0, w1b3};
                endcase

            default:
                begin
                    $display("Illegal data size in %m");
                    mem_d_load = 32'b0;
                end
        endcase
    end
    endfunction

    task mem_d_store;
        input [31:0] mem_data_byte_adr;
        input [31:0] data_value_32_bit;
        input [1:0] data_size;

        reg [1:0] boff;
    begin
        boff = mem_data_byte_adr[1:0];

        case (data_size)
            2'b00: // SB
                case (boff)
                    2'b00: mem_d[mem_data_byte_adr[31:2]][7:0] = data_value_32_bit[7:0];
                    2'b01: mem_d[mem_data_byte_adr[31:2]][15:8] = data_value_32_bit[7:0];
                    2'b10: mem_d[mem_data_byte_adr[31:2]][23:16] = data_value_32_bit[7:0];
                    2'b11: mem_d[mem_data_byte_adr[31:2]][31:24] = data_value_32_bit[7:0];
                endcase

            2'b01: // SH
                case (boff)
                    2'b00: mem_d[mem_data_byte_adr[31:2]][15:0] = data_value_32_bit[15:0];
                    2'b01: mem_d[mem_data_byte_adr[31:2]][23:8] = data_value_32_bit[15:0];
                    2'b10: mem_d[mem_data_byte_adr[31:2]][31:16] = data_value_32_bit[15:0];
                    2'b11:
                        begin
                            mem_d[mem_data_byte_adr[31:2]][31:24] = data_value_32_bit[7:0];
                            mem_d[mem_data_byte_adr[31:2]+1][7:0] = data_value_32_bit[15:8];
                        end
                endcase

            2'b10: // SW
                case (boff)
                    2'b00: mem_d[mem_data_byte_adr[31:2]] = data_value_32_bit;
                    2'b01:
                        begin
                            mem_d[mem_data_byte_adr[31:2]][31:8] = data_value_32_bit[23:0];
                            mem_d[mem_data_byte_adr[31:2]+1][7:0] = data_value_32_bit[31:24];
                        end
                    2'b10:
                        begin
                            mem_d[mem_data_byte_adr[31:2]][31:16] = data_value_32_bit[15:0];
                            mem_d[mem_data_byte_adr[31:2]+1][15:0] = data_value_32_bit[31:16];
                        end
                    2'b11:
                        begin
                            mem_d[mem_data_byte_adr[31:2]][31:24] = data_value_32_bit[7:0];
                            mem_d[mem_data_byte_adr[31:2]+1][23:0] = data_value_32_bit[31:8];
                        end
                endcase

            default:
                $display("Illegal data size in %m");
        endcase
    end
    endtask

    always @(*) begin
        case (acc_type)
            2'b01: ld_32 = mem_d_load(dm_adr, access_sz, s_us); // Load
            2'b10: begin // Store
                mem_d_store(dm_adr, sd_32, access_sz);
                ld_32 = 32'b0;
            end
            default: begin
                $display("Illegal access type in %m");
                ld_32 = 32'b0;
            end
        endcase
    end
endmodule
