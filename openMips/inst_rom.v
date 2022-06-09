
`include "defines.v"

module inst_rom(
//	input	wire										clk,
	input wire                    ce,
	input wire[`InstAddrBus]			addr,
	output reg[`InstBus]					inst
	
);

	reg[`InstBus]  inst_mem[0:`InstMemNum-1];

	initial $readmemh ( "E:/FPGAproject/step_into_mips/openMips/inst_rom.data", inst_mem );

	always @ (*) begin
		if (ce == `Disable) begin
			inst <= `ZeroWord;
	  end else begin
		  inst <= inst_mem[addr[`InstMemNumLog2+1:2]];	//按字节编址，访问需要除4
		end
	end

endmodule