module ctrl_gen(
	input [6:0] op,
	input [2:0] func3,
	input func7_5,
	output reg [2:0] ExtOp,
	output reg RegWr,
	output reg ALUAsrc,
	output reg [1:0] ALUBsrc,
	output reg [3:0] ALUctr,
	output reg [2:0] Branch,
	output reg MemtoReg,
	output reg MemWr,
	output [2:0] MemOp

);

assign MemOp = func3;

always @ (*) begin
	case (op[6:2]) 
		5'b01101,
		5'b00101: ExtOp = 3'b001;
		5'b01000: ExtOp = 3'b010;
		5'b11000: ExtOp = 3'b011;
		5'b11011: ExtOp = 3'b100;
		default: ExtOp = 3'b000;
	endcase
end

always @ (*) begin
	if (op[5:2] == 4'b1000) RegWr = 1'b0;
	else RegWr = 1'b1;
end

always @ (*) begin
	case (op[6:2]) 
		5'b11011: Branch = 3'b001;
		5'b11001: Branch = 3'b010;
		5'b11000: begin
			case (func3) 
				3'b000: Branch = 3'b100;
				3'b001: Branch = 3'b101;
				3'b100,
				3'b110: Branch = 3'b110;
				3'b101,
				3'b111: Branch = 3'b111;
				default: Branch = 0;
			endcase
		end
		default: Branch = 0;
	endcase
end

always @ (*) begin
	if (op[6:2] == 5'b00000) MemtoReg = 1'b1;
	else MemtoReg = 1'b0;
end

always @ (*) begin
	if (op[6:2] == 5'b01000) MemWr = 1'b1;
	else MemWr = 1'b0;
end

always @ (*) begin
	if (op[6:2] == 5'b00101 
	 || op[6:2] == 5'b11011
	 || op[6:2] == 5'b11001) ALUAsrc = 1'b1;
	 else ALUAsrc = 1'b0;
end

always @ (*) begin
	case (op[6:2])
		5'b01101,
		5'b00101,
		5'b00100,
		5'b00000,
		5'b01000: ALUBsrc = 2'b01;
		5'b11011,
		5'b11001: ALUBsrc = 2'b10;
		default: ALUBsrc = 2'b00;
	endcase
end

always @ (*) begin
	case (op[6:2])
		5'b01101: ALUctr = 4'b0011;
		5'b11000: begin
			if (func3[2:1] == 2'b11) ALUctr = 4'b1010;
			else ALUctr = 4'b0010;
		end
		5'b01100: begin
			if (func3 == 3'b011 && func7_5 == 1'b0)
				ALUctr = 4'b1010;
			else ALUctr = {func7_5, func3};
		end
		5'b00100: begin
			if (func3[1:0] == 2'b01)
				ALUctr = {func7_5, func3};
			else if (func3 == 3'b011) 
				ALUctr = 4'b1010;
			else ALUctr = {1'b0, func3};
		end
		default: ALUctr = 4'b0000;
	endcase
end

endmodule
