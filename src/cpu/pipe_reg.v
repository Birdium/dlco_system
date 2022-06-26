module pipe_reg(
    // clock ports
    input  clock,
    input  reset,

    input  [31: 0] in_ALUout,
    input  [31: 0] in_busB,
    input  [ 2: 0] in_MemOp,
    input  [ 4: 0] in_rd,
    input  in_MemtoReg,
    input  in_RegWr,
    input  in_MemWr,

    output [31: 0] out_ALUout,
    output [31: 0] out_busB,
    output [ 2: 0] out_MemOp,
    output [ 4: 0] out_rd,
    output out_MemtoReg,
    output out_RegWr,
    output out_MemWr
);

    reg [31: 0] internal_ALUout;
    reg [31: 0] internal_busB;
    reg [ 2: 0] internal_MemOp;
    reg [ 4: 0] internal_rd;
    reg internal_MemtoReg;
    reg internal_RegWr;
    reg internal_MemWr;

    always @(negedge clock) begin
        internal_ALUout <= in_ALUout;
        internal_busB <= in_busB;
        internal_MemOp <= in_MemOp;
        internal_rd <= in_rd;
        internal_MemtoReg <= in_MemtoReg;
        internal_RegWr <= in_RegWr;
        internal_MemWr <= in_MemWr;
    end

    assign out_ALUout = internal_ALUout;
    assign out_busB = internal_busB;
    assign out_MemOp = internal_MemOp;
    assign out_rd = internal_rd;
    assign out_MemtoReg = internal_MemtoReg;
    assign out_RegWr = internal_RegWr;
    assign out_MemWr = internal_MemWr;

endmodule