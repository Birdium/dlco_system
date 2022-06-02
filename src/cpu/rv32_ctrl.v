module rv32_ctrl(
	input 	clock,
	input 	reset,
	output [31:0] debugdata
);

// definitions

wire [31:0] iaddr, idataout, drdaddr, dwraddr, ddataout, ddata, ddatain, PC;
wire [2:0] dop;
wire iclk, drdclk, dwrclk;
wire cpu_we, data_we, vga_we;

assign debugdata = PC;

// instr: 000, data: 001, vga: 002, ps2: 003, ...
assign data_we	=(dwraddr[31:20] == 12'h001)? cpu_we : 1'b0;
assign vga_we	=(dwraddr[31:20] == 12'h002)? cpu_we : 1'b0;

assign cpu_data=(drdaddr[31:20] == 12'h001)? ddataout: // 选取dmem输出
					((drdaddr[31:20] == 12'h003)? keymemout : 32'b0 ); // 键盘输出
				
// CPU
				
rv32is my_rv32is(
	.clock(clock),
	.reset(reset),
	.imemaddr(iaddr),
	.imemdataout(idataout),
	.imemclk(iclk),
	.dmemaddr(daddr),
	.dmemdataout(cpu_data),
	.dmemdatain(ddatain),
	.dmemrdclk(drdclk),
	.dmemwrclk(dwrclk),
	.dmemop(dop),
	.dmemwe(cpuwe),
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
	.we(data_we)
);


// imem				
				
imem my_imem(
	.addr(iaddr),
	.rdclk(iclk),
	.dataout(idataout)
);

// vga and ps2 to be done...



endmodule
