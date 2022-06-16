`include "defines.v"

module regfile(
    input [`RegAddrBus] r1,
    output reg [`RegBus]     rdata1,
    input r1e,

    input [`RegAddrBus] r2,
    output reg [`RegBus]     rdata2,
    input r2e,

    input [`RegAddrBus] rw,
    input [`RegBus]     wdata,
    input we,

    input rst,
    input clk
);

    reg [`RegBus] rf[0:31];

    //写
	always @(posedge clk) begin
		if(we) begin
			rf[rw] <= wdata;
		end
	end

    //读r1
    always @(*) begin
        //注意优先级
        if(rst == `Enable) begin //复位
            rdata1 <= `ZeroWord;
        end else if (r1 == `RegNumLog2'b0)  begin //读取0寄存器
            rdata1 <= `ZeroWord;
        end else if ((r1 == rw) && (we == `Enable) //解决 wb - id冲突
                        && (r1e == `Enable)) begin    //寄存器移动操作
            rdata1 <= wdata;
        end else if (r1e == `Enable) begin  //读取地址内容
            rdata1 <= rf[r1];
        end else begin  //额外情况防止锁存器
            rdata1 <= `ZeroWord;
        end

    end

    //类似的，读r2
    always @(*) begin
        //注意优先级
        if(rst == `Enable) begin //复位
            rdata2 <= `ZeroWord;
        end else if (r2 == `RegNumLog2'b0)  begin //读取0寄存器
            rdata2 <= `ZeroWord;
        end else if ((r2 == rw) && (we == `Enable) 
                        && (r2e == `Enable)) begin    //寄存器移动操作
            rdata2 <= wdata;
        end else if (r2e == `Enable) begin  //读取地址内容
            rdata2 <= rf[r2];
        end else begin  //额外情况防止锁存器
            rdata2 <= `ZeroWord;
        end
    end

endmodule