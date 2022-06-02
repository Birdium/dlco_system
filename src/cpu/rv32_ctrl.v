module rv32_ctrl(
	input 	clock,
	input 	reset,
	output [31:0] debugdata
);

wire [31:0] iaddr, idataout, drdaddr, dwraddr, ddataout, ddatain, PC;
wire [2:0] dop;
wire iclk, drdclk, dwrclk, datawe;

assign debugdata = PC;

rv32is my_rv32is(
	.clock(clock),
	.reset(reset),
	.imemaddr(iaddr),
	.imemdataout(idataout),
	.imemclk(iclk),
	.dmemaddr(daddr),
	.dmemdataout(ddataout),
	.dmemdatain(ddatain),
	.dmemrdclk(drdclk),
	.dmemwrclk(dwrclk),
	.dmemop(dop),
	.dmemwe(datawe),
	.dbgdata(PC)
);

dmem datamem(
	.rdaddr(drdaddr),
	.dataout(ddataout),
	.wraddr(dwraddr),
	.datain(ddatain),
	.rdclk(drdclk),
	.wrclk(dwrclk),
	.memop(dop),
	.we(datawe)
);

imem my_imem(
	.addr(imemaddr),
	.rdclk(imemclk),
	.dataout(imemdataout)
);

endmodule
