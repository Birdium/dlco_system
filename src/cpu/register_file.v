module register_file(
	input [4:0] Ra, Rb, Rw,
	input [31:0] busW,
	input RegWr, WrClk,
	output [31:0] busA, busB
);

reg [31:0] regs[31:0];

assign busA = regs[Ra];
assign busB = regs[Rb];

integer i;
initial begin
	for (i=0;i<32;i=i+1) regs[i] = 32'b0;
end

always @ (posedge WrClk) begin
	if (RegWr) regs[Rw] <= (|Rw) ? busW : 32'b0;
end

endmodule
