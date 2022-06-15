`include "defines.v"

module ctrl(
    input rst,
    input stall_from_id,
    input stall_fron_ex,

    output reg [5:0] stallSig
);

    always @(*) begin
        if (rst == `Enable) begin
            stallSig <= 6'b00_0000;
        end else if (stall_from_id) begin
            stallSig <= 6'b00_1111;
        end else if (stall_fron_ex) begin
            stallSig <= 6'b00_0111;
        end else begin
            stallSig <= 6'b00_0000;
        end
    end
endmodule