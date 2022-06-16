`include "defines.v"

module mem(
    input rst,

    input [`RegAddrBus]     rw_i,
    input                   wreg_i,
    input [`RegBus]         wdata_i,

    output reg [`RegAddrBus]    rw_o,
    output reg                  wreg_o,
    output reg [`RegBus]        wdata_o,

    //---------- hilo 
    input                   whilo_i,
    input [`RegBus]         hi_i,
    input [`RegBus]         lo_i,

    output reg              whilo_o,
    output reg [`RegBus]    hi_o,
    output reg [`RegBus]    lo_o,
    
    //---------- lw/sw
    input [`AluOpBus]        aluop_i,
    input [`RegBus]          mem_addr_i,
    input [`RegBus]          reg2_i,
    input [`RegBus]          mem_data_i,

    output reg [`RegBus]      mem_addr_o,
    output wire               mem_we_o,
    output reg [3:0]          mem_sel_o,
    output reg [`RegBus]      mem_data_o,
    output reg                mem_ce_o
); 

reg                   mem_we;
assign mem_we_o = mem_we ;

always @(*) begin
    if(rst == `Enable) begin
        rw_o    <= `NOPRegAddr;
        wreg_o  <= `Disable;
        wdata_o <= `ZeroWord;

        whilo_o <= `Disable;
        hi_o    <= `ZeroWord;
        lo_o    <= `ZeroWord;
        
        mem_addr_o  <= `ZeroWord;
        mem_we      <= `Disable;
        mem_sel_o   <= 4'b0000;
        mem_data_o  <= `ZeroWord;
        mem_ce_o    <= `Disable;	
    end else begin
        rw_o    <= rw_i;
        wreg_o  <= wreg_i;
        wdata_o <= wdata_i;
        
        whilo_o <= whilo_i;
        hi_o    <= hi_i;
        lo_o    <= lo_i;

        mem_addr_o  <= `ZeroWord;
        mem_we      <= `Disable;
        mem_sel_o   <= 4'b0000;
        mem_data_o  <= `ZeroWord;
        mem_ce_o    <= `Disable;

        case (aluop_i)
        `EXE_LW_OP:		begin
            mem_addr_o  <= mem_addr_i;
            mem_we      <= `Disable;
            wdata_o     <= mem_data_i;
            mem_sel_o   <= 4'b1111;
            mem_ce_o    <= `Enable;		
            end

        `EXE_SW_OP:		begin
            mem_addr_o  <= mem_addr_i;
            mem_we      <= `Enable;
            mem_data_o  <= reg2_i;
            mem_sel_o   <= 4'b1111;	
            mem_ce_o    <= `Enable;		
            end

        endcase
    end
end

endmodule