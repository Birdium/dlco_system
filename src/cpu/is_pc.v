module is_pc(
	input [31:0] PC, imm, busA,
	input PCAsrc, PCBsrc,
	output [31:0] nextPC
);

wire [31:0] PCA, PCB;
assign PCA = (PCAsrc == 1'b0 ? 4 : imm);
assign PCB = (PCBsrc == 1'b0 ? PC : busA);
assign nextPC = PCA + PCB;

endmodule 