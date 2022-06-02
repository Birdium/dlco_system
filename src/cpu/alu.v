module alu(
	input [31:0] A,
	input [31:0] B,
	input [3:0]  ALUctr,
	output less,
	output zero,
	output reg [31:0] ALUout);

//add your code here
wire of, cf, lr, al, slt_result;
wire [31:0] barrel_result, adder_result;
assign zero = (ALUctr[2:0] == 3'b010) ? (~|adder_result) : (~|ALUout);
assign less = ALUout[0];
assign lr = ~ALUctr[2];
assign al = ALUctr[3];
assign slt_result = (ALUctr[3]) ? (cf) : (adder_result[31] ^ of);

barrel my_barrel(A, B[4:0], lr, al, barrel_result);
adder my_adder(
	.A(A),
	.B(B),
	.addsub(|ALUctr),
	.F(adder_result),
	.overflow(of),
	.carry(cf)
);

always @ (*)
begin
	casex (ALUctr[2:0])
		4'b000: ALUout <= adder_result;
		4'b001: ALUout <= barrel_result;
		4'b010: ALUout <= {31'b0, slt_result};
		4'b011: ALUout <= B;
		4'b100: ALUout <= A ^ B;
		4'b101: ALUout <= barrel_result;
		4'b110: ALUout <= A | B;
		4'b111: ALUout <= A & B;
	endcase
end

endmodule