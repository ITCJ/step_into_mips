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

reg [`RegBus]        ariResult;
reg [`DoubleRegBus]  mulResult; 

//---------- algotithm 预计算
//获取中间变量
wire [`RegBus]          rdata2_mux;
wire [`RegBus]          rdata1_not; 
wire [`RegBus]          result_sum;
wire                    ov_sum;
wire                    rdata1_eq_rdata2;
wire                    rdata1_lt_rdata2;
wire [`RegBus]          opdata1_mult;
wire [`RegBus]          opdata2_mult;
wire [`DoubleRegBus]    hilo_temp; 

//减法取补码
assign rdata2_mux = ((aluop_i == `EXE_SUB_OP) || 
                        (aluop_i == `EXE_SUBU_OP) ||
                        (aluop_i == `EXE_SLT_OP) ) ? 
                        (~rdata2)+1 : rdata2;

assign result_sum = rdata1 + rdata2_mux;

assign ov_sum = ((!rdata1[31] && !rdata2_mux[31]) && result_sum[31]) ||
                 ((rdata1[31] && rdata2_mux[31]) && (!result_sum[31]));  

//          larger than     r1 r2       进行比较
assign rdata1_lt_rdata2 = ((aluop_i == `EXE_SLT_OP)) ?
                                                ((rdata1[31] && !rdata2[31]) ||  //负 - 正
                                                (!rdata1[31] && !rdata2[31] && result_sum[31]) || // 正 - 正，结果为负
                                                (rdata1[31] && rdata2[31] && result_sum[31]))       //负 负 结果为负
                                                : (rdata1 < rdata2);    //无符号比较

assign rdata1_not = ~rdata1;

//----------  arithmetic 数据通路

	always @ (*) begin
		if(rst == `Enable) begin
			ariResult <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP:		begin
					ariResult <= rdata1_lt_rdata2 ;
				end
				`EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:		begin
					ariResult <= result_sum; 
				end
				`EXE_SUB_OP, `EXE_SUBU_OP:		begin
					ariResult <= result_sum; 
				end		
				`EXE_CLZ_OP:		begin
					ariResult <= rdata1[31] ? 0 : rdata1[30] ? 1 : rdata1[29] ? 2 :
													 rdata1[28] ? 3 : rdata1[27] ? 4 : rdata1[26] ? 5 :
													 rdata1[25] ? 6 : rdata1[24] ? 7 : rdata1[23] ? 8 : 
													 rdata1[22] ? 9 : rdata1[21] ? 10 : rdata1[20] ? 11 :
													 rdata1[19] ? 12 : rdata1[18] ? 13 : rdata1[17] ? 14 : 
													 rdata1[16] ? 15 : rdata1[15] ? 16 : rdata1[14] ? 17 : 
													 rdata1[13] ? 18 : rdata1[12] ? 19 : rdata1[11] ? 20 :
													 rdata1[10] ? 21 : rdata1[9] ? 22 : rdata1[8] ? 23 : 
													 rdata1[7] ? 24 : rdata1[6] ? 25 : rdata1[5] ? 26 : 
													 rdata1[4] ? 27 : rdata1[3] ? 28 : rdata1[2] ? 29 : 
													 rdata1[1] ? 30 : rdata1[0] ? 31 : 32 ;
				end
				`EXE_CLO_OP:		begin
					ariResult <= (rdata1_not[31] ? 0 : rdata1_not[30] ? 1 : rdata1_not[29] ? 2 :
													 rdata1_not[28] ? 3 : rdata1_not[27] ? 4 : rdata1_not[26] ? 5 :
													 rdata1_not[25] ? 6 : rdata1_not[24] ? 7 : rdata1_not[23] ? 8 : 
													 rdata1_not[22] ? 9 : rdata1_not[21] ? 10 : rdata1_not[20] ? 11 :
													 rdata1_not[19] ? 12 : rdata1_not[18] ? 13 : rdata1_not[17] ? 14 : 
													 rdata1_not[16] ? 15 : rdata1_not[15] ? 16 : rdata1_not[14] ? 17 : 
													 rdata1_not[13] ? 18 : rdata1_not[12] ? 19 : rdata1_not[11] ? 20 :
													 rdata1_not[10] ? 21 : rdata1_not[9] ? 22 : rdata1_not[8] ? 23 : 
													 rdata1_not[7] ? 24 : rdata1_not[6] ? 25 : rdata1_not[5] ? 26 : 
													 rdata1_not[4] ? 27 : rdata1_not[3] ? 28 : rdata1_not[2] ? 29 : 
													 rdata1_not[1] ? 30 : rdata1_not[0] ? 31 : 32) ;
				end
				default:				begin
					ariResult <= `ZeroWord;
				end
			endcase
		end
	end

//---------- mul 数据预处理

//乘法时
assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))
                                                //      乘数是负数              补码
                                                && (rdata1[31] == 1'b1)) ? (~rdata1 + 1) : rdata1;

assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))
                                                && (rdata2[31] == 1'b1)) ? (~rdata2 + 1) : rdata2;		

//自动综合乘法器
assign hilo_temp = opdata1_mult * opdata2_mult;

always @ (*) begin
    if(rst == `Enable) begin
        mulResult <= {`ZeroWord,`ZeroWord};
    end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP))begin
        if(rdata1[31] ^ rdata2[31] == 1'b1) begin
            mulResult <= ~hilo_temp + 1;
        end else begin
            mulResult <= hilo_temp;
        end
    end else begin
            mulResult <= hilo_temp;
    end
end


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

//---------- hilo 输出控制 mux

always @ (*) begin
    if(rst == `Enable) begin
        whilo_o <= `Disable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;  
    end else if (   (aluop_i == `EXE_MULT_OP) ||
                    (aluop_i == `EXE_MULTU_OP)
                ) begin
        whilo_o <= `Enable;
        hi_o <= mulResult[63:32];
        lo_o <= mulResult[31:0];
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

        `EXE_RES_ARITHMETIC: begin
            wdata_o <= ariResult;
        end
        
        `EXE_RES_MUL:  begin
            wdata_o <= mulResult[31:0];
        end

        default: begin
            wdata_o <= `ZeroWord;
        end
    endcase
end

endmodule