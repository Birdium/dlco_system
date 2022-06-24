module ascii_cnt(
	input [7:0] ascii,
	input clk,
	output reg en
);

reg [15:0] cnt;
reg long_pressing;
reg [7:0] ascii_tmp;

initial begin
	en <= 0;
	long_pressing <= 0;
	cnt <= 0;
	ascii_tmp <= 8'b0;
end

always @ (posedge clk) begin
	if (ascii == 0) begin
		ascii_tmp <= ascii;
		en <= 0;
		cnt <= 0;
		long_pressing <= 0;
	end
	else if (ascii != ascii_tmp) begin
		ascii_tmp <= ascii;
		en <= 1;
		cnt <= 0;
		long_pressing <= 0;
	end
//	else if (long_pressing) begin
//		if (cnt == 2499) begin
//			en <= 1;
//			cnt <= 0;
//		end
//		else begin
//			en <= 0;
//			cnt <= cnt + 1;
//		end
//	end
//	else if (cnt == 24999) begin
//		en <= 1;
//		long_pressing <= 1;
//		cnt <= 0;
//	end
//	else begin
//		en <= 0;
//		cnt <= cnt + 1;
//	end
end

endmodule
