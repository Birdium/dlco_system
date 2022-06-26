module rv32is_pipe2(
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
    wire [31: 0] ALUout;
    wire [ 2: 0] MemOp;
    wire [ 4: 0] rd;
    wire MemtoReg;
    wire RegWr;
    wire MemWr;

    wire [31: 0] out_ALUout;
    wire [31: 0] out_busB;
    wire [ 2: 0] out_MemOp;
    wire [ 4: 0] out_rd;
    wire out_MemtoReg;
    wire out_RegWr;
    wire out_MemWr;

    wire [31: 0] forward_busA;
    wire [31: 0] forward_busB;
    wire [31: 0] busA;
    wire [31: 0] busB;
    wire [ 4: 0] rs1;
    wire [ 4: 0] rs2;

    wire [31: 0] busW;

    assign forward_busA = ((rs1 != 0) && (rs1 == out_rd)) ? busW : busA;
    assign forward_busB = ((rs2 != 0) && (rs2 == out_rd)) ? busW : busB;

    IF_ID_EX if_id_ex(
        .clock(clock),
        .reset(reset),
        .dbgdata(dbgdata),

        .rs1(rs1), .busA(forward_busA),
        .rs2(rs2), .busB(forward_busB),

        .ALUout(ALUout),
        .MemOp(MemOp),
        .rd(rd),
        .MemtoReg(MemtoReg),
        .MemWr(MemWr),
        .RegWr(RegWr),

        .imemdataout(imemdataout),
        .imemaddr(imemaddr),
        .imemclk(imemclk)
    );

    pipe_reg my_pipe_reg(
        .clock(clock),
        .reset(reset),

        .in_ALUout(ALUout),
        .in_busB(forward_busB),
        .in_MemOp(MemOp),
        .in_rd(rd),
        .in_MemtoReg(MemtoReg),
        .in_MemWr(MemWr),
        .in_RegWr(RegWr),

        .out_ALUout(out_ALUout),
        .out_busB(out_busB),
        .out_MemOp(out_MemOp),
        .out_rd(out_rd),
        .out_MemtoReg(out_MemtoReg),
        .out_MemWr(out_MemWr),
        .out_RegWr(out_RegWr)
    );

    MEM_WB mem_wb(
        .clock(clock),
        .reset(reset),
        
        .busW(busW),
		  .busB(out_busB),

        .ALUout(out_ALUout),
        .MemOp(out_MemOp),
        .MemtoReg(out_MemtoReg),
        .MemWr(out_MemWr),
        
        .dmemdataout(dmemdataout),
        .dmemdatain(dmemdatain),
        .dmemaddr(dmemaddr),
        .dmemop(dmemop),
        .dmemrdclk(dmemrdclk),
        .dmemwrclk(dmemwrclk),
        .dmemwe(dmemwe)
    );

    register_file myregfile(
        .Ra(rs1),
        .Rb(rs2),
        .Rw(out_rd),
        .busW(busW),
        .RegWr(out_RegWr),
        .WrClk(~clock),
        .busA(busA),
        .busB(busB)
    );

endmodule