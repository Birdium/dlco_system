module rv32_ctrl(
	input 	clock,
	input 	reset,
	output [31:0] debugdata
);

// definitions

wire [31:0] iaddr, idataout, drdaddr, dwraddr, ddataout, ddatain, PC;
wire [2:0] dop;
wire iclk, drdclk, dwrclk, dwe, datawe; // dwe 是CPU输出结果, datawe 是向dmem中输入信号

assign debugdata = PC;
assign datawe=(dwraddr[31:20]==12'h001)? dwe:1'b0; // 比较地址, 确定写使能.
assign ddata=(drdaddr[31:20]==12'h001)? ddataout: // 选取dmem输出
            ((drdaddr[31:20]==12'h003)? keymemout :32'b0 ); // 键盘输出
		
// CPU
				
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
	.dmemwe(dwe),
	.dbgdata(PC)
);

// dmem

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


// imem				
				
imem my_imem(
	.addr(imemaddr),
	.rdclk(imemclk),
	.dataout(imemdataout)
);

// vga and ps2 to be done...



endmodule
