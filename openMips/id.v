`include "defines.v"

module id(
    input                   rst,
    // ----------

    input [`InstAddrBus]    pc_i,
    input [`InstBus]        inst_i,
    input [`RegBus]         reg1_data_i,
    input [`RegBus]         reg2_data_i,
    
    // ---------- ex mem段写入寄存器信息

    input                   ex_wreg_i,
    input [`RegAddrBus]     ex_wd_i,
    input [`RegBus]         ex_wdata_i,

    input                   mem_wreg_i,
    input [`RegAddrBus]     mem_wd_i,
    input [`RegBus]         mem_wdata_i,

    // ---------- 
    output reg [`AluOpBus]      aluop_o,
    output reg [`AluSelBus]     alusel_o,
    output reg [`RegBus]        reg1_o,
    output reg [`RegBus]        reg2_o,
    
    output reg [`RegAddrBus]    wd_o,
    output reg                  wreg_o, //we

    output reg [`RegAddrBus]    reg2_addr_o,
    output reg                  reg2_read_o,
    output reg [`RegAddrBus]    reg1_addr_o,
    output reg                  reg1_read_o
);

//对输入的指令分段
wire [5:0] op   =   inst_i[31:26];
wire [4:0] rs   =   inst_i[25:21];
wire [4:0] rt   =   inst_i[20:16];
wire [4:0] rd   =   inst_i[15:11];

//R
wire [4:0] op2   =   inst_i[10:6];
wire [5:0] op3   =   inst_i[5:0];
wire [4:0] op4   =   inst_i[20:16];

//I
wire [15:0] imm_i   =   inst_i[15:0];

reg [`RegBus]        imm;

reg instvalid;


//译码 op seg -> aluop
always @(*) begin
    if (rst == `Enable) begin
        aluop_o     <= `EXE_NOP_OP;
        alusel_o    <= `EXE_RES_NOP;

        wd_o        <= `NOPRegAddr;
        wreg_o      <= `Disable;

        instvalid   <= `Disable;

        reg1_read_o <= `Disable;
        reg1_addr_o <= `NOPRegAddr;
        reg2_read_o <= `Disable;
        reg2_addr_o <= `NOPRegAddr;

        imm         <= `ZeroWord;
    end else begin
        //初始化状态，可以避免没用的端口出现错误内容。综合在电路上是二级mux
        //以往这部分内容我写在case中，第一个分支之前
        aluop_o     <= `EXE_NOP_OP;
        alusel_o    <= `EXE_RES_NOP;

        wd_o        <= rd;
        wreg_o      <= `Disable;

        instvalid   <= `Disable;

        reg1_read_o <= `Disable;
        reg1_addr_o <= rs;
        reg2_read_o <= `Disable;
        reg2_addr_o <= rt;

        imm         <= `ZeroWord;

        case (op)
            `EXE_SPECIAL_INST: begin
                case (op2)
                    5'b0_0000: begin
                        case (op3)
                            `EXE_AND: begin
                                aluop_o     <= `EXE_AND_OP;
                                alusel_o    <= `EXE_RES_LOGIC;

                                wreg_o      <= `Enable;
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid   <= `Enable;
                            end 
                            default: begin
                                
                            end
                        endcase
                    end 
                    default:  begin
                        
                    end
                endcase
            end

            `EXE_ORI: begin
                aluop_o     <= `EXE_OR_OP;
                alusel_o    <= `EXE_RES_LOGIC;

                wd_o        <= rt;
                wreg_o      <= `Enable;

                instvalid   <= `Enable;

                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;

                imm         <= {16'h0, imm_i};
            end
            default: 
                instvalid   <= `Disable;
        endcase
    end
end


//控制 regfile的传递
always @(*) begin
    if (rst == `Enable) begin
        reg1_o <= `ZeroWord;
    end else if ( (ex_wreg_i   == `Enable) &&   // 存在写入
                  (reg1_read_o == `Enable) &&   // 存在读取
                  (reg1_addr_o == ex_wd_i)      // 写入地址相同
                ) begin                         // ex 段 bypass
        reg1_o <= ex_wdata_i;
    end else if ( (mem_wreg_i  == `Enable) &&   // 存在写入
                  (reg1_read_o == `Enable) &&   // 存在读取
                  (reg1_addr_o == mem_wd_i)      // 写入地址相同
                ) begin                         // mem 段 bypass
        reg1_o <= mem_wdata_i;
    end else if (reg1_read_o == `Enable) begin
        reg1_o <= reg1_data_i;
    end else if (reg1_read_o == `Disable) begin
        reg1_o <= imm;
    end else begin
        reg1_o <= `ZeroWord;
    end
end

always @(*) begin
    if (rst == `Enable) begin
        reg2_o <= `ZeroWord;
    end else if ( (ex_wreg_i   == `Enable) &&   // 存在写入
                  (reg2_read_o == `Enable) &&   // 存在读取
                  (reg2_addr_o == ex_wd_i)      // 写入地址相同
                ) begin                         // ex 段 bypass
        reg2_o <= ex_wdata_i;
    end else if ( (mem_wreg_i  == `Enable) &&   // 存在写入
                  (reg2_read_o == `Enable) &&   // 存在读取
                  (reg2_addr_o == mem_wd_i)      // 写入地址相同
                ) begin                         // mem 段 bypass
        reg2_o <= mem_wdata_i;
    end else if (reg2_read_o == `Enable) begin
        reg2_o <= reg2_data_i;
    end else if (reg2_read_o == `Disable) begin
        reg2_o <= imm;
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule