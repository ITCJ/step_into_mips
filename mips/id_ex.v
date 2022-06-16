`include "defines.v"

module id_ex(
    input rst, clk,

    input [`InstAddrBus]pc_i,
    input [`AluOpBus]   id_aluop,
    input [`AluSelBus]  id_alusel,
    
    input [`RegBus]     id_rdata1,
    input [`RegBus]     id_rdata2,
    input [`RegAddrBus] id_rw,
    input               id_wreg,

    // ----------
    
    output reg [`InstAddrBus]pc_o,               
    output reg [`AluOpBus]   ex_aluop,
    output reg [`AluSelBus]  ex_alusel,
    
    output reg [`RegBus]     ex_rdata1,
    output reg [`RegBus]     ex_rdata2,
    output reg [`RegAddrBus] ex_rw,
    output reg               ex_wreg,

    // ----------

    input [5:0] stall,

    // ---------- jump
    input               id_is_in_delayslot,
    input [`RegBus]     id_link_address,
    input               next_inst_in_delayslot_i,

    output reg              ex_is_in_delayslot,
    output reg [`RegBus]    ex_link_address,
    output reg              is_in_delayslot_o,

    // ----------- sw/lw
    input [`RegBus]         id_inst,
    output reg [`RegBus]    ex_inst
);

    always @(posedge clk) begin
        if(rst == `Enable) begin
            pc_o        <=  `ZeroWord;
            ex_aluop    <=  `EXE_NOP_OP;
            ex_alusel   <=  `EXE_RES_NOP;
            ex_rdata1   <=  `ZeroWord;
            ex_rdata2   <=  `ZeroWord;
            ex_rw       <=  `ZeroWord;
            ex_wreg     <=  `Disable;
            
            ex_link_address     <= `ZeroWord;
            ex_is_in_delayslot  <= `Disable;
            is_in_delayslot_o   <= `Disable;    

            ex_inst     <= `ZeroWord;
        end else if(stall[2] == `Enable && stall[3] == `Disable) begin
            pc_o        <=  `ZeroWord;
            ex_aluop    <=  `EXE_NOP_OP;
            ex_alusel   <=  `EXE_RES_NOP;
            ex_rdata1   <=  `ZeroWord;
            ex_rdata2   <=  `ZeroWord;
            ex_rw       <=  `ZeroWord;
            ex_wreg     <=  `Disable;
            ex_link_address     <= `ZeroWord;
            ex_is_in_delayslot  <= `Disable;

            ex_inst     <= id_inst;
        end else if(stall[2] == `Disable) begin
            pc_o        <=  pc_i;
            ex_aluop    <=  id_aluop;
            ex_alusel   <=  id_alusel;
            ex_rdata1   <=  id_rdata1;
            ex_rdata2   <=  id_rdata2;
            ex_rw       <=  id_rw;
            ex_wreg     <=  id_wreg;
            ex_link_address     <= id_link_address;
            ex_is_in_delayslot  <= id_is_in_delayslot;
            is_in_delayslot_o   <= next_inst_in_delayslot_i;

            ex_inst     <= id_inst; 
        end
    end

endmodule 