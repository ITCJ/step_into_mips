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
    output reg [`RegBus]        mem_wdata
);

always @(posedge clk) begin
    if(rst == `Enable)  begin
        pc_o        <=  `ZeroWord;
        mem_rw      <=  `NOPRegAddr;
        mem_wreg    <=  `Disable;
        mem_wdata   <=  `ZeroWord;
    end else begin
        pc_o        <= pc_i;
        mem_rw      <= ex_rw;
        mem_wreg    <= ex_wreg;
        mem_wdata   <= ex_wdata;
    end
end

endmodule