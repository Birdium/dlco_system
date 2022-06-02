module rv32is(
	input 	clock,
	input 	reset,
	output [31:0] imemaddr,
	input  [31:0] imemdataout,
	output 	imemclk,
	output [31:0] dmemaddr,
	input  [31:0] dmemdataout,
	output [31:0] dmemdatain,
	output 	dmemrdclk,
	output	dmemwrclk,
	output [2:0] dmemop,
	output	dmemwe,
	output [31:0] dbgdata
);
//assign debug = myregfile.regs[1]; 

reg [31:0] PC;

wire [31:0] instr, imm, busA, busB, busW, ALUout, nextPC, ALUA, ALUB;
wire [3:0] ALUctr;
wire [2:0] ExtOp, Branch, MemOp;
wire [1:0] ALUBsrc;
wire ALUAsrc, RegWr, MemtoReg, MemWr, less, zero, PCAsrc, PCBsrc;

wire [6:0] op, func7;
wire [4:0] rs1, rs2, rd;
wire [2:0] func3;

assign instr = imemdataout;
assign op  = instr[6:0];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd  = instr[11:7];
assign func3  = instr[14:12];
assign func7  = instr[31:25];

imm_gen my_imm_gen(
	.instr(instr),
	.ExtOp(ExtOp),
	.imm(imm)
);

ctrl_gen my_ctrl_gen(
	.op(op),
	.func3(func3),
	.func7_5(func7[5]),
	.ExtOp(ExtOp),
	.RegWr(RegWr),
	.ALUAsrc(ALUAsrc),
	.ALUBsrc(ALUBsrc),
	.ALUctr(ALUctr),
	.Branch(Branch),
	.MemtoReg(MemtoReg),
	.MemWr(MemWr),
	.MemOp(MemOp)
);

register_file myregfile(
	.Ra(rs1),
	.Rb(rs2),
	.Rw(rd),
	.busW(busW),
	.RegWr(RegWr),
	.WrClk(~clock),
	.busA(busA),
	.busB(busB)
);

alu_src my_alu_src(
	.busA(busA),
	.busB(busB),
	.PC(PC),
	.imm(imm),
	.ALUAsrc(ALUAsrc),
	.ALUBsrc(ALUBsrc),
	.ALUA(ALUA),
	.ALUB(ALUB)
);

assign busW = (MemtoReg ? dmemdataout : ALUout);

alu my_alu(
	.A(ALUA),
	.B(ALUB),
	.ALUctr(ALUctr),
	.less(less),
	.zero(zero),
	.ALUout(ALUout)
);

is_pc my_is_pc(
	.PC(PC),
	.imm(imm),
	.busA(busA),
	.PCAsrc(PCAsrc),
	.PCBsrc(PCBsrc),
	.nextPC(nextPC)
);

branch_cond my_branch_cond(
	.less(less),
	.zero(zero),
	.branch(Branch),
	.PCAsrc(PCAsrc),
	.PCBsrc(PCBsrc)
);

// for OJ test
assign imemaddr = (reset ? 32'b0 : nextPC);
assign imemclk = ~clock;

assign dmemaddr = ALUout;
assign dmemdatain = busB;
assign dmemrdclk = clock;
assign dmemwrclk = ~clock;
assign dmemop = MemOp;
assign dmemwe = MemWr;
assign dbgdata = PC;

initial begin
	PC <= 32'b0;
end

always @ (negedge clock) begin
	if (reset) PC <= 32'b0;
	else PC <= nextPC;
end
//imem my_imem(
//	TBD
//);

//dmem my_dmem(
//	.addr(ALUout),
//	.datain(busB),
//	.dataout(busW),
//	.rdclk(clock),
//	.wrclk(~clock),
//	.memop(MemOp),
//	.we(MemWr),
//);

endmodule