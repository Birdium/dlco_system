
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module dlco_system(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// Video-In //////////
	input 		          		TD_CLK27,
	input 		     [7:0]		TD_DATA,
	input 		          		TD_HS,
	output		          		TD_RESET_N,
	input 		          		TD_VS,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// ADC //////////
	output		          		ADC_CONVST,
	output		          		ADC_DIN,
	input 		          		ADC_DOUT,
	output		          		ADC_SCLK,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT,

	//////////// IR //////////
	input 		          		IRDA_RXD,
	output		          		IRDA_TXD
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

wire [31:0] iaddr, idataout, daddr, ddataout, ddata, ddatain, cpu_data, PC;
wire [31:0] keymemout;
wire [2:0] dop;
wire iclk, drdclk, dwrclk;
wire cpu_we, data_we, vga_we;

// instr: 000, data: 001, vga: 002, ps2: 003, ...
assign data_we	=(daddr[31:20] == 12'h001)? cpu_we : 1'b0;
assign vga_we	=(daddr[31:20] == 12'h002)? cpu_we : 1'b0;

assign cpu_data	=(daddr[31:20] == 12'h001)? ddataout: // 选取dmem输出
				((daddr[31:20] == 12'h003)? keymemout : 32'b0 ); // 键盘输出

// VGA + vmem
reg [11:0] vga_data;
wire [9:0] h_addr, v_addr;
wire [3:0] vga_r, vga_g, vga_b;

wire [7:0] vdataout;
wire [11:0] vrdaddr;

// KBD
wire [7:0] scancode, asciicode;

// CLK
wire clk, cpuclk, vgaclk, kbdclk, vrdclk;

// reset
wire cpurst, vgarst, kbdrst;
assign cpurst = SW[0];
assign vgarst = SW[1];
assign kbdrst = SW[2];
// assign cpurst = SW[3];
// assign cpurst = SW[4];

//=======================================================
//  Structural coding
//=======================================================


// CPU
				
rv32is my_rv32is( // in out 是相对于rv32is来说的
	.clock(cpuclk),
	.reset(cpurst),
	.imemaddr(iaddr),
	.imemdataout(idataout),
	.imemclk(iclk),
	.dmemaddr(daddr), 
	.dmemdataout(cpu_data), // 给 CPU 的数据
	.dmemdatain(ddatain), // CPU 给的
	.dmemrdclk(drdclk),
	.dmemwrclk(dwrclk),
	.dmemop(dop),
	.dmemwe(cpu_we),
	.dbgdata(PC)
);

// dmem: [0x00100000, 0x0011ffff)
// 和exp11类似,, 只不过这里的data_we要转换成特定模块的we
// dmem 分配了 2^17 Byte的空间, 提供的地址应当是17bit的, 输出则是32bit的, 怎么取值和memop相关
dmem_ctrl my_dmem_ctrl(
	.addr(daddr[16:0]),
	.dataout(ddataout),
	.datain(ddatain),
	.rdclk(drdclk),
	.wrclk(dwrclk),
	.memop(dop),
	.we(data_we)
);


// imem: [0x00000000, 0x0001ffff)
// imem 分配了 2^15 * 4Byte的空间, 因为rv32的缘故, 指令是定长的, 只需要提供15bit的地址信息, 

imem my_imem(
	.address(iaddr[16:2]),
	.clock(iclk),
	.q(idataout)
);

// vga: [0x00200000, 0x00201000)
// 显存大小为 64*64 Byte. 
// TBD: 此外可以将0x00201000映射到起始行号寄存器, 0x00201001颜色寄存器...
// 
vmem my_vmem(
	.data(cpu_data[7:0]),
	.rdaddress(vrdaddr), // VGA 读
	.rdclock(vrdclk),
	.wraddress(daddr[11:0]), // cpu 写
	.wrclock(dwrclk),
	.wren(vga_we),
	.q(vdataout)
);

assign VGA_R = {vga_r, 4'b0};
assign VGA_G = {vga_g, 4'b0};
assign VGA_B = {vga_b, 4'b0};
assign VGA_SYNC_N = 0;

displayer my_displayer(
	.clk(vgaclk),
	.ascii(vdataout), // read from vmem
	.h_addr(h_addr),
	.v_addr(v_addr),
	.data(vga_data),
	.vrdclk(vrdclk), // let VGA tell vmem when to read
	.vrdaddr(vrdaddr)
);

vga_ctrl vga_inst(
	.pclk(VGA_CLK),
	.reset(1'b0),
	.vga_data(vga_data),
	.h_addr(h_addr),
	.v_addr(v_addr),
	.hsync(VGA_HS),
	.vsync(VGA_VS),
	.valid(VGA_BLANK_N),
	.vga_r(vga_r),
	.vga_g(vga_g),
	.vga_b(vga_b)
);

//wire [7:0] tmp1, tmp2;

// ps2
keyboard my_key(
	.clk(kbdclk),
	.clrn(kbdrst),
	.ps2_clk(PS2_CLK),
	.ps2_data(PS2_DAT),
//	.cur_key(tmp1),
//	.ascii_key(tmp2)
	.cur_key(scancode),
	.ascii_key(asciicode)
);

// CLK
clkgen #(25000000) my_clk(
	.clkin(CLOCK_50),
	.clken(1'b1),
	.clkout(clk)
);

assign cpuclk = clk;
assign vgaclk = clk;
assign kbdclk = clk;

endmodule
