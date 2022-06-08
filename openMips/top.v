`include "defines.v"

module top(
    input clk,
    input rst,

    input [`RegBus]         rom_data_i,

    output reg              rom_ce_o,
    output reg [`RegBus]    rom_addr_o
);

    wire pc_wire;
    wire ce_wire;
    wire inst_wire;
    pc_reg pc(
        .clk(clk),
        .rst(rst),
        .pc(pc_wire),
        .ce(ce_wire)
    );


endmodule 