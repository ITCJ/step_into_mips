`include "defines.v"

module pc_reg(
    input rst,
    input clk,

    output reg [`InstAddrBus] pc,
    output reg ce,

    // -- STALL
    input stall
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
       end else if(stall == `Enable) begin
           pc <= pc;
       end else begin
           pc <= pc + 4'h4;
       end
    end

endmodule
