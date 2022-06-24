module handmade_fifo(
    input [7:0] data,
    input rdclk, rdreq, wrclk, wrreq,
    output reg [7:0] q,
    output reg rdempty, wrfull
);

reg [7:0] fifo[31:0];
reg [4:0] w_ptr, r_ptr;

initial begin
    w_ptr <= 0; r_ptr <= 0; rdempty <= 0; wrfull <= 0;
end

always @ (posedge rdclk) begin
    if (rdreq) begin
        if (r_ptr != w_ptr) begin
            q <= fifo[r_ptr];
            r_ptr <= r_ptr + 1;
            rdempty <= 0;
        end
        else begin
            q <= 0;
            rdempty <= 1;
        end
    end
    else begin
        q <= 0;
        rdempty <= 0;
    end
end

always @ (posedge wrclk) begin
    if (wrreq) begin
        if (r_ptr != (w_ptr + 1) % 8) begin
            fifo[w_ptr] <= data;
            w_ptr <= w_ptr + 1;
            wrfull <= 0;
        end
        else wrfull <= 1;
    end
    else wrfull <= 0;

end

endmodule