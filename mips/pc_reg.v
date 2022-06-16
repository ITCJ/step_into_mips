`include "defines.v"

module pc_reg(
    input rst,
    input clk,

    output reg [`InstAddrBus] pc,
    output reg ce,

    // -- STALL
    input [5:0] stall,

    // --- branch jump
    input                   branch_flag_i,
    input [`InstAddrBus]    branch_target_address_i
    );


    always @(posedge clk) begin
        if (rst == `Enable) begin
            ce <= `Disable;
        end else begin
            ce <= `Enable;
        end
    end

    always @(posedge clk) begin
       if(ce == `Disable) begin
           pc <= `ZeroWord;
       end else if(stall[0] == `Disable) begin
           if (branch_flag_i == `Enable) begin
               pc <= branch_target_address_i;
           end else begin
                pc <= pc + 4'h4;    
           end
       end else begin
           pc <= pc;
       end
    end

endmodule
