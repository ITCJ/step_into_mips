`include "defines.v"

module ex_mem(
    input rst,
    input clk,

    input [`RegAddrBus]     ex_rw,
    input                   ex_wreg,
    input [`RegBus]         ex_wdata,

    output reg [`RegAddrBus]    mem_rw,
    output reg                  mem_wreg,
    output reg [`RegBus]        mem_wdata
);

always @(*) begin
    if(rst == `Enable)  begin
        mem_rw      <=  `NOPRegAddr;
        mem_wreg    <=  `Disable;
        mem_wdata   <=  `ZeroWord;
    end else begin
        mem_rw      <= ex_rw;
        mem_wreg    <= ex_wreg;
        mem_wdata   <= ex_wdata;
    end
end

endmodule