`include "defines.v"

module data_ram(

input clk,
input 				ce,
input 				we,
input [`RegBus] 	addr,
input [3:0] 		sel,
input [`RegBus]		data_i,
output reg[`RegBus]	data_o

);

reg[7:0]  data_mem0 [0:128];
reg[7:0]  data_mem1 [0:128];
reg[7:0]  data_mem2 [0:128];
reg[7:0]  data_mem3 [0:128];

always @ (posedge clk) begin
if (ce == `Disable) begin
  data_o <= `ZeroWord;
end else if(we == `Enable) begin
  if (sel[3] == 1'b1) begin
      data_mem3[addr[17+1:2]] <= data_i[31:24];
    end
  if (sel[2] == 1'b1) begin
      data_mem2[addr[17+1:2]] <= data_i[23:16];
    end
    if (sel[1] == 1'b1) begin
      data_mem1[addr[17+1:2]] <= data_i[15:8];
    end
  if (sel[0] == 1'b1) begin
      data_mem0[addr[17+1:2]] <= data_i[7:0];
    end       
end
end

always @ (*) begin
if (ce == `Disable) begin
    data_o <= `ZeroWord;
end else if(we == `Disable) begin
    data_o <= {data_mem3[addr[17+1:2]],
               data_mem2[addr[17+1:2]],
               data_mem1[addr[17+1:2]],
               data_mem0[addr[17+1:2]]};
end else begin
	data_o <= `ZeroWord;
end
end

endmodule