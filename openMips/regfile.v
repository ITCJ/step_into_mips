`include "defines.v"

module regfile(
    input [`RegAddrBus] r1,
    input [`RegBus]     rdata1,
    input r1e,

    input [`RegAddrBus] r2,
    input [`RegBus]     rdata2,
    input r2e,

    input [`RegAddrBus] rw,
    input [`RegBus]     wdata,
    input we,

    input rst,
    input clk,
);

    reg [31:0] rf[31:0];

    //写
	always @(posedge clk) begin
		if(we) begin
			 rf[rw] <= wdata;
		end
	end

    //读r1
    always @(*) begin
        if(rst == )
    end

endmodule