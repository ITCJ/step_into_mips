`include "defines.v"

module ex_mem(
    input rst,
    input clk,

    input [`InstAddrBus]    pc_i,
    input [`RegAddrBus]     ex_rw,
    input                   ex_wreg,
    input [`RegBus]         ex_wdata,

    output reg [`InstAddrBus]   pc_o, 
    output reg [`RegAddrBus]    mem_rw,
    output reg                  mem_wreg,
    output reg [`RegBus]        mem_wdata,

    //------ hilo 
    input           ex_whilo,
    input [`RegBus] ex_hi,
    input [`RegBus] ex_lo,

    output reg              mem_whilo,
    output reg [`RegBus]    mem_hi,
    output reg [`RegBus]    mem_lo,

    input [5:0] stall
);

always @(posedge clk) begin
    if(rst == `Enable)  begin
        pc_o        <=  `ZeroWord;
        mem_rw      <=  `NOPRegAddr;
        mem_wreg    <=  `Disable;
        mem_wdata   <=  `ZeroWord;

        mem_whilo   <=  `Disable;
        mem_hi      <=  `ZeroWord;
        mem_lo      <=  `ZeroWord;
    end else if(stall[3] == `Enable && stall[4] == `Disable)  begin
        pc_o        <=  `ZeroWord;
        mem_rw      <=  `NOPRegAddr;
        mem_wreg    <=  `Disable;
        mem_wdata   <=  `ZeroWord;

        mem_whilo   <=  `Disable;
        mem_hi      <=  `ZeroWord;
        mem_lo      <=  `ZeroWord;
    end else if (stall[3] == `Disable) begin
        pc_o        <= pc_i;
        mem_rw      <= ex_rw;
        mem_wreg    <= ex_wreg;
        mem_wdata   <= ex_wdata;

        mem_whilo   <=  ex_whilo;
        mem_hi      <=  ex_hi;
        mem_lo      <=  ex_lo;
    end
end

endmodule