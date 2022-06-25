module keyboard(
	input clk,clrn,ps2_clk,ps2_data,
	output reg [7:0] cur_key,
	output [7:0] ascii_key, debug_key,
	output reg shift, caps, ctrl, alt, is_dir
);


wire ready, overflow;
reg is_brk, upcoming_dir, nextdata_n;
wire [7:0] keydata;

initial begin
	nextdata_n <= 1;
	cur_key <= 0;
	is_brk <= 0;
	upcoming_dir <= 0;
	is_dir <= 0;
	shift <= 0;
	ctrl <= 0;
	caps <= 0;
end

assign debug_key = keydata;

always @ (negedge clk) begin
	if (clrn == 0) begin
		nextdata_n <= 1;
		cur_key <= 0;
		is_brk <= 0;
		is_dir <= 0;
		upcoming_dir <= 0;
		shift <= 0;
		ctrl <= 0;
		caps <= 0;
	end
	else begin
		if (ready) begin
			if (keydata == 8'hF0) begin
				is_brk <= 1;
			end
			else begin
				if (is_brk) begin
					is_brk <= 0;
					if (keydata == 8'h12) begin
						shift <= 0;
					end
					else if (upcoming_dir) begin
						upcoming_dir <= 0;
						is_dir <= 0;
						cur_key <= 8'h0;
					end
					else if (keydata == 8'h14) begin
						ctrl <= 0;
					end
					else if (keydata == 8'h11) begin
						alt <= 0;
					end
					else if (keydata != 8'h58) begin
						cur_key <= 8'h0;
					end
				end
				else if (keydata == 8'hE0) begin
					upcoming_dir <= 1;
				end
				else if (keydata == 8'h12) begin
					shift <= 1;
				end
				else if (keydata == 8'h14) begin
					ctrl <= 1;
				end
				else if (keydata == 8'h11) begin
					alt <= 1;
				end
				else if (keydata == 8'h58) begin
					caps <= ~caps;
				end
				else if (upcoming_dir) begin
					upcoming_dir <= 0;
					is_dir <= 1;
					cur_key <= keydata;
				end
				else cur_key <= keydata;
			end
			nextdata_n <= 0;
		end
		else nextdata_n <= 1;
	end
end

ps2_keyboard kbd_inst(
	.clk(clk),
	.clrn(clrn),
	.ps2_clk(ps2_clk),
	.ps2_data(ps2_data),
	.data(keydata),
	.ready(ready),
	.nextdata_n(nextdata_n),
	.overflow(overflow)
);

wire [7:0] raw_ascii;

data2ascii ascii_inst(
	.data(cur_key),
	.ascii(raw_ascii),
	.uppercase(shift^caps)
);

assign ascii_key = raw_ascii | {is_dir, 7'b0};

endmodule
