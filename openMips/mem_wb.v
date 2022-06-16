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
    output reg [`RegBus]        wdata_o,

    //---------- hilo 
    input                   whilo_i,
    input [`RegBus]         hi_i,
    input [`RegBus]         lo_i,

    output reg              whilo_o,
    output reg [`RegBus]    hi_o,
    output reg [`RegBus]    lo_o,

    input [5:0] stall
);

always @(posedge clk) begin
    if(rst == `Enable) begin
        pc_o    <=  `ZeroWord;
        rw_o    <= `NOPRegAddr;
        wreg_o  <= `Disable;
        wdata_o <= `ZeroWord;

        whilo_o <= `Disable;
        hi_o    <= `ZeroWord;
        lo_o    <= `ZeroWord;
    end else if(stall[4] == `Enable && stall[5] == `Disable) begin
        pc_o    <=  `ZeroWord;
        rw_o    <= `NOPRegAddr;
        wreg_o  <= `Disable;
        wdata_o <= `ZeroWord;

        whilo_o <= `Disable;
        hi_o    <= `ZeroWord;
        lo_o    <= `ZeroWord;
    end else if(stall[4] == `Disable) begin
        pc_o        <= pc_i;
        rw_o        <= rw_i;
        wreg_o      <= wreg_i;
        wdata_o     <= wdata_i;

        whilo_o <= whilo_i;
        hi_o    <= hi_i;
        lo_o    <= lo_i;
    end
end

endmodule 