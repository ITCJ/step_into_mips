module id(
    input [`InstAddrBus]    pc_i,
    input [`InstBus]        inst_i,

    // input reg1_data_i,
    // input reg2_data_i,
    
    input rst,

    output reg [`AluOpBus]      aluop_o,
    output reg [`AluSelBus]     aluset_o,
    // output reg reg1_o,
    // output reg reg2_o,
    
    output reg [`RegAddrBus]    wd_o,
    output reg wreg_o,

    output reg [`RegAddrBus]    reg2_addr_o,
    output reg reg2_read_o,
    output reg [`RegAddrBus]    reg1_addr_o,
    output reg reg1_read_o
);

//对输入的指令分段
wire [5:0] op   =   inst_i[31:26];
wire [4:0] rs   =   inst_i[25:21];
wire [4:0] rt   =   inst_i[20:16];
// wire [4:0] op3   =   inst_i[15:11];
// wire [4:0] op4   =   inst_i[10:6];
// wire [5:0] op5   =   inst_i[5:0];

reg [`RegBus]        imm;

reg instvalid;


//译码 op seg -> aluop
always @(*) begin
    if (rst == `Enable) begin
        aluop_o     <= `EXE_NOP_OP;
        aluset_o    <= `EXE_RES_NOP;

        wd_o        <= `NOPRegAddr;
        wreg_o      <= `Disable;

        instvalid   <= `Disable;

        reg1_read_o <= `Disable;
        reg1_addr_o <= `NOPRegAddr;
        reg2_read_o <= `Disable;
        reg2_addr_o <= `NOPRegAddr;

        imm         <= 32'h0;
    end else begin
        aluop_o     <= `EXE_NOP_OP;
        aluset_o    <= `EXE_RES_NOP;

        //TODO 
        wd_o        <= rt;
        wreg_o      <= `Disable;
        
          
    end
end



endmodule