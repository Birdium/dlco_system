module barrel(input [31:0] indata,
			  input [4:0] shamt,
			  input lr,
			  input al,
			  output reg [31:0] outdata);

always @ (*)
begin
	if (lr) begin
		outdata = shamt[0] ? {indata[30:0], 1'b0} : indata;	
		outdata = shamt[1] ? {outdata[29:0], 2'b0} : outdata;	
		outdata = shamt[2] ? {outdata[27:0], 4'b0} : outdata;	
		outdata = shamt[3] ? {outdata[23:0], 8'b0} : outdata;	
		outdata = shamt[4] ? {outdata[15:0], 16'b0} : outdata;	
	end else 
		if (al) begin
			outdata = shamt[0] ? {indata[31], indata[31:1]} : indata;	
			outdata = shamt[1] ? {{2{outdata[31]}}, outdata[31:2]} : outdata;	
			outdata = shamt[2] ? {{4{outdata[31]}}, outdata[31:4]} : outdata;	
			outdata = shamt[3] ? {{8{outdata[31]}}, outdata[31:8]} : outdata;	
			outdata = shamt[4] ? {{16{outdata[31]}}, outdata[31:16]} : outdata;	
		end else begin	
			outdata = shamt[0] ? {1'b0, indata[31:1]} : indata;	
			outdata = shamt[1] ? {2'b0, outdata[31:2]} : outdata;	
			outdata = shamt[2] ? {4'b0, outdata[31:4]} : outdata;	
			outdata = shamt[3] ? {8'b0, outdata[31:8]} : outdata;	
			outdata = shamt[4] ? {16'b0, outdata[31:16]} : outdata;	
		end

end

endmodule
