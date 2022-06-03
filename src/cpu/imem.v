module imem(
	input  [13:0] addr,
	input  rdclk,
	output reg [31:0] dataout
);

//add your code here
reg [31:0] ram [32767:0];


always @ (posedge rdclk)
begin
	dataout <= ram[addr];
end

endmodule
