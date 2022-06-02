module adder(
	input  [31:0] A,
	input  [31:0] B,
	input  addsub,
	output [31:0] F,
	output carry,
	output zero,
	output overflow
	);

	wire [31:0] t_no_Cin;

	assign t_no_Cin = {32{addsub}}^B;
	assign { carry, F } = (A + t_no_Cin + addsub) ^ (addsub << 32);
	assign overflow = (A[31] == t_no_Cin[31]) && (F[31] != A[31]);
	assign zero = ~(|F);

endmodule