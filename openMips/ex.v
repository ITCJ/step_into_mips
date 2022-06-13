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

reg [`RegBus]   logicResult;
reg [`RegBus]   shiftResult;

//---------- calculate
always @(*) begin
    if(rst == `Enable) begin
        logicResult <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_OR_OP: begin
                logicResult <= rdata1 | rdata2;
            end

            `EXE_AND_OP: begin
                logicResult <= rdata1 & rdata2;
            end

            `EXE_NOR_OP: begin
                logicResult <= ~(rdata1 | rdata2);
            end

            `EXE_XOR_OP: begin
                logicResult <= rdata1 ^ rdata2;
            end

            default: begin
                logicResult <= `ZeroWord;
            end
        endcase
    end
end

always @(*) begin
    if(rst == `Enable) begin
        shiftResult <= `ZeroWord;
    end else begin
        case (aluop_i)
            `EXE_SLL_OP: begin
                shiftResult <= rdata2 << rdata1[4:0];
            end 

            `EXE_SRL_OP:    begin
                shiftResult <= rdata2 >> rdata2[4:0];
            end

            `EXE_SRA_OP:    begin
                shiftResult <= ({32{rdata2[31]}} << (6'd32-{1'b0,rdata1[4:0]}))
                                | rdata2 >> rdata1[4:0];
            end

            default: begin
                shiftResult <= `ZeroWord;
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
            wdata_o <= logicResult;
        end

        `EXE_RES_LOGIC: begin
            wdata_o <= shiftResult;
        end

        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end

endmodule