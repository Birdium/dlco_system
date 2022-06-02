module data2ascii(
	input [7:0] data,
	input uppercase,
	output [7:0] ascii
);

(* ram_init_file = "scancode.mif" *) reg [7:0] myrom1[255:0];
(* ram_init_file = "capscode.mif" *) reg [7:0] myrom2[255:0];
assign ascii = uppercase ? myrom2[data] : myrom1[data];

endmodule
