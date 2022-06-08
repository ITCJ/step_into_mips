`include "defines.v"

module id_ex(
    input rst, clk,
    input [`AluOpBus]   id_aluop,
    input [`AluSelBus]  id_alusel,
    
    input [`RegBus]     id_rdata1,
    input [`RegBus]     id_rdata2,
    input [`RegAddrBus] id_rw,
    input               id_wreg,

    // ----------
    
    output reg [`AluOpBus]   ex_aluop,
    output reg [`AluSelBus]  ex_alusel,
    
    output reg [`RegBus]     ex_rdata1,
    output reg [`RegBus]     ex_rdata2,
    output reg [`RegAddrBus] ex_rw,
    output reg               ex_wreg

);

    always @(posedge clk) begin
        if(rst == `Enable) begin
            ex_aluop    <=  `EXE_NOP_OP;
            ex_alusel   <=  `EXE_RES_NOP;
            ex_rdata1   <=  `ZeroWord;
            ex_rdata2   <=  `ZeroWord;
            ex_rw       <=  `ZeroWord;
            ex_wreg     <=  `Disable;
        end else begin
            ex_aluop    <=  id_aluop;
            ex_alusel   <=  id_alusel;
            ex_rdata1   <=  id_rdata1;
            ex_rdata2   <=  id_rdata2;
            ex_rw       <=  id_rw;
            ex_wreg     <=  id_wreg;
        end
    end

endmodule 