module dmem(
	input  [31:0] addr,
	output reg [31:0] dataout,
	input  [31:0] datain,
	input  rdclk,
	input  wrclk,
	input [2:0] memop,
	input we);

wire [31:0] q;
reg [3:0] byteena_a, byteena_a_t;
reg [31:0] datain_t;

testdmem my_mem(
	.byteena_a(byteena_a),
	.data(datain_t),
	.rdaddress(addr[16:2]),
	.rdclock(rdclk),
	.wraddress(addr[16:2]),
	.wrclock(wrclk),
	.wren(we),
	.q(q)
);

always @(*) begin
	case(memop[1:0])
		2'b00: byteena_a_t = 4'b0001;
		2'b01: byteena_a_t = 4'b0011;
		2'b10: byteena_a_t = 4'b1111;
		default: byteena_a_t = 4'b0000;
	endcase
	case(addr[1:0])
		2'b00: begin datain_t = datain; byteena_a = byteena_a_t; end
		2'b01: begin datain_t = {datain[23:0], 8'b0}; byteena_a = {byteena_a_t[2:0], 1'b0}; end
		2'b10: begin datain_t = {datain[15:0], 16'b0}; byteena_a = {byteena_a_t[1:0], 2'b0}; end
		2'b11: begin datain_t = {datain[7:0], 24'b0}; byteena_a = {byteena_a_t[0], 3'b0}; end
		default: begin datain_t = datain; byteena_a = byteena_a_t; end
	endcase
end

always @ (*)
begin
	case (memop) 
		3'b000: 
			case (addr[1:0])
				2'b00: dataout = {{24{q[7]}}, q[7:0]};
				2'b01: dataout = {{24{q[15]}}, q[15:8]};
				2'b10: dataout = {{24{q[23]}}, q[23:16]};
				2'b11: dataout = {{24{q[31]}}, q[31:24]};
			endcase
		3'b001: 
			case (addr[1])
				1'b0: dataout = {{16{q[15]}}, q[15:0]};
				1'b1: dataout = {{16{q[31]}}, q[31:16]};
			endcase
		3'b010: dataout = q;
		3'b100: 
			case (addr[1:0])
				2'b00: dataout = {24'b0, q[7:0]};
				2'b01: dataout = {24'b0, q[15:8]};
				2'b10: dataout = {24'b0, q[23:16]};
				2'b11: dataout = {24'b0, q[31:24]};
			endcase
		3'b101: 
			case (addr[1])
				1'b0: dataout = {16'b0, q[15:0]};
				1'b1: dataout = {16'b0, q[31:16]};
			endcase
	endcase
end

endmodule
