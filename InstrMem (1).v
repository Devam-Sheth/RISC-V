module InstrMem(
    input [6:0] inaddr,
    output reg [31:0] instr
);

reg [31:0] instructionmemory[0:127];

always @(*) begin
    instr = instructionmemory[inaddr];
end

initial begin
    instructionmemory[0] = 32'h00000013; // NOP (ADDI x0, x0, 0)
    instructionmemory[1] = 32'h00100093; // ADDI x1, x0, 1
    instructionmemory[2] = 32'h00200113; // ADDI x2, x0, 2
    instructionmemory[3] = 32'h00308193; // ADDI x3, x1, 3
end

endmodule
