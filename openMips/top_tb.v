`include "defines.v"
`timescale 1ns/1ps

module top_tb();

  reg     CLOCK_50;
  reg     rst;
  
       
  initial begin
    CLOCK_50 = 1'b0;
    forever #10 CLOCK_50 = ~CLOCK_50;
  end
      
  initial begin
    rst = `Enable;
    #195 rst= `Disable;
    #1000 $stop;
  end
       
  top top0(
		.clk(CLOCK_50),
		.rst(rst)	
	);

endmodule