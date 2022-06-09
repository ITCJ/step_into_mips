`include "defines.v"
module top(
    input clk, rst
);

    wire rom_data_i;
    wire rom_ce_o;
    wire rom_addr_o;
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
endmodule 