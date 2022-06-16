`include "defines.v"

module if_id(
    input rst,
    input clk,
    input [`InstAddrBus] if_pc,
    input [`InstBus] if_inst,
    output reg [`InstAddrBus] id_pc,
    output reg [`InstBus] id_inst,

    input [5:0] stall
);

    always @(posedge clk) begin
        if (rst == `Enable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if(stall[1] == `Enable && stall[2] == `Disable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if(stall[1] == `Disable) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule