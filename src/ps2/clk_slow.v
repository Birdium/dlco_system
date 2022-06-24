module clk_slow(
	input clk,
	output reg out
);

reg [15:0] cnt;

always @ (posedge clk) begin
	if (cnt == 499) begin
		out <= ~out;
		cnt <= 0;
	end
	else begin
		cnt <= cnt + 1;
	end
end

endmodule
