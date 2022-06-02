module cursor(
	input clk,
	output reg flash_on
);

reg [31:0] flash_cnt;
parameter flash_freq = 12500000;

initial
begin
	flash_on <= 0;
	flash_cnt <= 0;
end

always @ (posedge clk)
begin
	if (flash_cnt == flash_freq) begin
		flash_cnt <= 0;
		flash_on <= ~flash_on;
	end 
	else flash_cnt <= flash_cnt + 1;
end

endmodule