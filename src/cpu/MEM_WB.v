module MEM_WB(
    // clock ports
    input  clock,
    input  reset,

    // RegFile ports
    output [31: 0] busW,

    //// Pipeline ports Begins ////

    input [31: 0] ALUout,
    input [31: 0] busB,
    input [ 2: 0] MemOp,
    input MemtoReg,
    input MemWr,

    //// Pipeline ports Ends ////

    // dmem ports
	input  [31: 0] dmemdataout, // dmem -> reg
	output [31: 0] dmemdatain,  // reg  -> dmem
   output [31: 0] dmemaddr,
	output [ 2: 0] dmemop,
	output 	dmemrdclk,
	output	dmemwrclk,
	output	dmemwe
);

assign busW = (MemtoReg ? dmemdataout : ALUout);

assign dmemaddr = ALUout;
assign dmemdatain = busB;
assign dmemrdclk = clock;
assign dmemwrclk = ~clock;
assign dmemop = MemOp;
assign dmemwe = MemWr;

endmodule