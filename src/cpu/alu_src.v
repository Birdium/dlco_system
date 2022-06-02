module alu_src(
	input [31:0] busA, busB, PC, imm,
	input ALUAsrc,
	input [1:0] ALUBsrc,
	output reg [31:0] ALUA, ALUB
);

always @ (*) begin
	ALUA = (ALUAsrc ? PC : busA);
end

always @ (*) begin
	case (ALUBsrc) 
		2'b00 : ALUB = busB;
		2'b01 : ALUB = imm;
		2'b10 : ALUB = 32'd4;
		default : ALUB = 32'd0;
	endcase
end

endmodule