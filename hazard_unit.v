module hazard_unit (
    input [4:0] id_rs1, id_rs2,
    input [4:0] ex_rd,
    input       ex_mem_read,
    output      stall
);
    wire stall;
assign stall = ex_mem_read && ex_rd != 0 &&
                  (ex_rd == id_rs1 || ex_rd == id_rs2);
endmodule
