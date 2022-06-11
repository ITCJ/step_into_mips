`include "defines.v"

module mem_wb(
    input clk, rst,

    input [`InstAddrBus]    pc_i,
    input [`RegAddrBus]     rw_i,
    input                   wreg_i,
    input [`RegBus]         wdata_i,

    output reg [`InstAddrBus]   pc_o, 
    output reg [`RegAddrBus]    rw_o,
    output reg                  wreg_o,
    output reg [`RegBus]        wdata_o
);

always @(posedge clk) begin
    if(rst == `Enable) begin
        pc_o    <=  `ZeroWord;
        rw_o    <= `NOPRegAddr;
        wreg_o  <= `Disable;
        wdata_o <= `ZeroWord;
    end else begin
        pc_o        <= pc_i;
        rw_o        <= rw_i;
        wreg_o      <= wreg_i;
        wdata_o     <= wdata_i;
    end
end

endmodule 