module rv32_ctrl(
	input 	clock,
	input 	reset,
	output [31:0] debugdata
);

wire [31:0] imemaddr, imemdataout, dmemaddr, dmemdataout, dmemdatain, PC;
wire [2:0] dmemop;
wire imemclk, dmemrdclk, dmemwrclk, dmemwe;

assign debugdata = PC;

rv32is my_rv32is(
	.clock(clock),
	.reset(reset),
	.imemaddr(imemaddr),
	.imemdataout(imemdataout),
	.imemclk(imemclk),
	.dmemaddr(dmemaddr),
	.dmemdataout(dmemdataout),
	.dmemdatain(dmemdatain),
	.dmemrdclk(dmemrdclk),
	.dmemwrclk(dmemwrclk),
	.dmemop(dmemop),
	.dmemwe(dmemwe),
	.dbgdata(PC)
);

dmem my_dmem(
	.addr(dmemaddr),
	.dataout(dmemdataout),
	.datain(dmemdatain),
	.rdclk(dmemrdclk),
	.wrclk(dmemwrclk),
	.memop(dmemop),
	.we(dmemwe)
);

imem my_imem(
	.addr(imemaddr),
	.rdclk(imemclk),
	.dataout(imemdataout)
);

endmodule
