module IF_ID_EX(
    // clock ports
    input clock,
    input reset,
    output [31: 0] dbgdata,

    // RegFile ports
    input  [31: 0] busA,
    input  [31: 0] busB,
    output [ 4: 0] rs1,
    output [ 4: 0] rs2,

    //// Pipeline ports Begins ////

    output [31: 0] ALUout,
    output [ 2: 0] MemOp,
    output [ 4: 0] rd,
    output MemtoReg,
    output MemWr,
    output RegWr,

    //// Pipeline ports Ends ////
    
    // imem ports
	input  [31: 0] imemdataout,
    output [31: 0] imemaddr,
	output imemclk
);

reg [31:0] PC;

wire [31:0] instr, imm, nextPC, ALUA, ALUB;
wire [3:0] ALUctr;
wire [2:0] ExtOp, Branch;
wire [1:0] ALUBsrc;
wire ALUAsrc, less, zero, PCAsrc, PCBsrc;

wire [6:0] op, func7;
wire [2:0] func3;

assign instr = imemdataout;
assign op  = instr[6:0];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign rd  = instr[11:7];
assign func3  = instr[14:12];
assign func7  = instr[31:25];
assign dbgdata = PC;

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

initial begin
	PC <= 32'b0;
end

always @ (negedge clock) begin
	if (reset) PC <= 32'b0;
	else PC <= nextPC;
end

endmodule