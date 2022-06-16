`include "defines.v"
module top(
    input clk, rst
);

    wire [`InstBus]         rom_data_i;
    wire                    rom_ce_o;
    wire [`InstAddrBus]     rom_addr_o;

    wire             mem_we_i;
    wire [`RegBus]   mem_addr_i;
    wire [`RegBus]   mem_data_i;
    wire [`RegBus]   mem_data_o;
    wire [3:0]       mem_sel_i;  
    wire             mem_ce_i;  
    cpu cpu0(
        .rst(rst), .clk(clk),

        .rom_data_i(rom_data_i),

        .rom_ce_o(rom_ce_o),
        .rom_addr_o(rom_addr_o)
    );

    inst_rom inst_rom0(
        .ce(rom_ce_o),
        .addr(rom_addr_o),
        
        .inst(rom_data_i)
    );

    data_ram data_ram0(
        .clk(clk),

        .we(mem_we_i),
        .addr(mem_addr_i),
        .sel(mem_sel_i),

        .data_i(mem_data_i),
        .data_o(mem_data_o),

        .ce(mem_ce_i)        
    );
endmodule 