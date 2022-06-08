`include "defines.v"

module ex(
    input rst,

    input [`AluOpBus]       aluop_i,
    input [`AluSelBus]      alusel_i,
    input [`RegBus]         rdata1,
    input [`RegBus]         rdata2,

    input [`RegAddrBus]     rw_i,
    input                   wreg_i,

    output reg [`RegAddrBus]    rw_o,
    output reg                  wreg_o,
    output reg [`RegBus]        wdata_o
);

reg [`RegBus]   result;

//---------- calculate
always @(*) begin
    if(rst == `Enable) begin
        result <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_ORI: begin
                result <= rdata1 | rdata2;
            end
            default: begin
                result <= `ZeroWord;
            end
        endcase
    end
end

//---------- result seletc
always @(*) begin
    rw_o <= rw_i;
    wreg_o <= wreg_i;
    
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= result;
        end
        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end

endmodule