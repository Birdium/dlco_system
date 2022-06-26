module displayer(
	input clk,
	input [ 9:0] h_addr, v_addr,
	input [ 7:0] ascii,
	input [11:0] pixel,
	input ascii_or_pixel, // 0 if ascii, 1 if pixel
	output reg [11:0] data, 
	output [6:0] vrdaddr_h,
	output [4:0] vrdaddr_v,
	output [14:0] gdaddr,
	output vrdclk
);

reg [11:0] vga_font [4095:0];
reg flash_on;

wire [9:0] scan_x, scan_y;
wire [3:0] ch_x;
wire [11:0] ch_y, line;

initial
begin
	$readmemh("vga_font.txt", vga_font, 0, 4095);
	flash_on = 0;
end

assign scan_x = h_addr / 9;
assign scan_y = v_addr / 16;
assign vrdaddr_h = scan_x[6:0];
assign vrdaddr_v = scan_y[4:0];
assign gdaddr = {h_addr[9:2], v_addr[8:2]};

assign vrdclk = ~clk;
assign ch_x = h_addr % 9;
assign ch_y = {ascii, v_addr[3:0]};
assign line = vga_font[ch_y];

cursor my_cursor(clk, flash_on);

// character reader
always @ (posedge clk)
begin
//	if (scan_x == cur_x && scan_y == cur_y) begin
//		data <= {12{flash_on}};
//	end
//	else 
	if (ascii_or_pixel == 0)
		data <= {12{line[ch_x[3:0]]}};
	else
		data <= pixel;
end

// no need to write.. tashikani
// character writer

// always @ (posedge en)
// begin
// 	if (w_ascii == 8'h0D) begin // enter 
// 		if (cur_y == 29) begin // end of the screen
// 			for (i = 0; i < 29; i = i+1)
// 				for (j = 0; j < 70; j = j+1)
// 					chars[i][j] <= chars[i+1][j];
// 			for (i = 1; i < 69; i = i+1)
// 				chars[29][i] <= 8'h0;
// 			chars[29][0] <= 8'h3E;
// 			cur_x <= 2;
// 		end
// 		else begin 
// 			chars[cur_y+1][0] <= 8'h3E;
// 			cur_x <= 2;
// 			cur_y <= cur_y + 1;
// 		end
// 	end
// 	else if (w_ascii == 8'h08) begin // backspace
// 		if (cur_x == 0) begin
// 			if (cur_y != 0) begin
// 				chars[cur_y-1][69] <= 8'h0;
// 				cur_x <= 8'd69;
// 				cur_y <= cur_y - 1;
// 			end
// 		end
// 		else begin
// 			chars[cur_y][cur_x-1] <= 8'h0;
// 			cur_x <= cur_x - 1;
// 		end
// 	end
// 	else if (is_dir) begin // directions
// 		if (w_ascii == 8'h32) begin // down 
// 			if (cur_y != 29) cur_y <= cur_y + 1;
// 		end
// 		else if (w_ascii == 8'h34) begin // left
// 			if (cur_x != 0) cur_x <= cur_x - 1;
// 		end
// 		else if (w_ascii == 8'h36) begin // right 
// 			if (cur_x != 69) cur_x <= cur_x + 1;
// 		end
// 		else if (w_ascii == 8'h38) begin // up
// 			if (cur_y != 0) cur_y <= cur_y - 1;
// 		end
// 	end
// 	else begin // characters
// 		if (cur_x == 69) begin
// 			if (cur_y == 29) begin 
// 				for (i = 0; i < 29; i = i+1)
// 					for (j = 0; j < 70; j = j+1)
// 						chars[i][j] <= chars[i+1][j];
// 				for (i = 0; i < 69; i = i+1)
// 					chars[29][i] <= 8'h0;
// 				chars[28][69] <= w_ascii;
// 				cur_x <= 0;
// 			end
// 			else begin
// 				chars[cur_y][cur_x] <= w_ascii;
// 				cur_y <= cur_y + 1;
// 				cur_x <= 0;
// 			end
// 		end
// 		else begin
// 			chars[cur_y][cur_x] <= w_ascii;
// 			cur_x <= cur_x + 1;
// 		end
// 	end
// end

endmodule