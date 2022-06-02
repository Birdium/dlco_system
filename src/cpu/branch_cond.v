module branch_cond(
	input less, zero,
	input [2:0] branch,
	output PCAsrc, PCBsrc
);

wire cond;
assign cond = branch[0] ^ (branch[1] ? less : zero);
assign PCBsrc = (branch==3'b010 ? 1'b1 : 1'b0);
assign PCAsrc = (branch[2] ? cond : branch[1] ^ branch[0]);
endmodule 
