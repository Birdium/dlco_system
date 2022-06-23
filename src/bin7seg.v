module bin7seg(
	 input  [3:0] b,
	 output reg [6:0] h
	);
	reg [3:0] tb;
	
   // Set sgn = '-' if SUM is negative
   assign sgn = (b[3] == 1) ? 7'b0111111 : 7'b1111111;
	
	always @(b) begin
		tb = (b[3] == 1) ? (~b + 1) : b;
		case (tb)
			4'd0 : h = 7'b1000000;
			4'd1 : h = 7'b1111001;
			4'd2 : h = 7'b0100100;
			4'd3 : h = 7'b0110000;
			4'd4 : h = 7'b0011001;
			4'd5 : h = 7'b0010010;
			4'd6 : h = 7'b0000010;
			4'd7 : h = 7'b1111000;
			4'd8 : h = 7'b0000000;
			default : h = 7'b1111111;
		endcase
	end
endmodule
