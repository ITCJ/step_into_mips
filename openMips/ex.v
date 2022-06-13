`include "defines.v"

module ex(
    input rst,

    input [`AluOpBus]       aluop_i,
    input [`AluSelBus]      alusel_i,
    input [`RegBus]         rdata1,
    input [`RegBus]         rdata2,

    input [`RegAddrBus]     rw_i,
    input                   wreg_i,

    // ---------- hilo 
    input [`RegBus]         hi_i,
    input [`RegBus]         lo_i,
    input                   mem_whilo_i,
    input [`RegBus]         mem_hi_i,
    input [`RegBus]         mem_lo_i,
    input                   wb_whilo_i,
    input [`RegBus]         wb_hi_i,
    input [`RegBus]         wb_lo_i,

    // ---------- wreg
    output reg [`RegAddrBus]    rw_o,
    output reg                  wreg_o,
    output reg [`RegBus]        wdata_o,

    // ---------- hilo 
    output reg                   whilo_o,
    output reg [`RegBus]         hi_o,
    output reg [`RegBus]         lo_o
);

reg [`RegBus]   logicResult;
reg [`RegBus]   shiftResult;
reg [`RegBus]   moveResult;
reg [`RegBus]   HI;
reg [`RegBus]   LO;

//---------- HILO 冲突处理
always @(*) begin
    if (rst == `Enable) begin
        HI <= `ZeroWord;
        LO <= `ZeroWord;
    end else if(mem_whilo_i == `Enable) begin
        HI <= mem_hi_i;
        LO <= mem_lo_i;
    end else if(wb_whilo_i == `Enable) begin
        HI <= wb_hi_i;
        LO <= wb_lo_i;
    end else begin
        HI <= hi_i;
        LO <= lo_i;
    end
end

//----------move 数据通路
always @(*) begin
    if (rst == `Enable) begin
        moveResult <= `ZeroWord;
    end else begin
        moveResult <= `ZeroWord;
        case (aluop_i)
            `EXE_MOVZ_OP: begin 
                moveResult <= rdata1;
            end

            `EXE_MOVN_OP: begin 
                moveResult <= rdata1;
            end

            `EXE_MFHI_OP: begin 
                moveResult <= HI;
            end

            // `EXE_MTHI_OP: begin 
            //     whilo_o <= `Enable;
            //     hi_o <= rdata1;
            //     lo_o <= LO;
            // end

            `EXE_MFLO_OP: begin 
                moveResult <= LO;
            end

            // `EXE_MTLO_OP: begin 
            //     whilo_o <= `Enable;
            //     hi_o <= HI;
            //     lo_o <= rdata1;
            // end

            default: begin
                // whilo_o <= `Disable;
                // hi_o    <= `ZeroWord;
                // lo_o    <= `ZeroWord;
            end
        endcase

    end
end

//---------- 独立另一mux

always @ (*) begin
    if(rst == `Enable) begin
        whilo_o <= `Disable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;		
    end else if(aluop_i == `EXE_MTHI_OP) begin
        whilo_o <= `Enable;
        hi_o <= rdata1;
        lo_o <= LO;
    end else if(aluop_i == `EXE_MTLO_OP) begin
        whilo_o <= `Enable;
        hi_o <= HI;
        lo_o <= rdata1;
    end else begin
        whilo_o <= `Disable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end				
end	

//---------- calculate logical，shift 数据通路
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
                shiftResult <= rdata2 >> rdata1[4:0];
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

//---------- result select
always @(*) begin
    rw_o <= rw_i;
    wreg_o <= wreg_i;
    
    case (alusel_i)
        `EXE_RES_LOGIC: begin
            wdata_o <= logicResult;
        end

        `EXE_RES_SHIFT: begin
            wdata_o <= shiftResult;
        end

        `EXE_RES_MOVE: begin
            wdata_o <= moveResult;
        end

        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end

endmodule