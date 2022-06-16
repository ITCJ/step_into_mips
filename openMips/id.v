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
    output reg                  reg1_read_o,

    output                      stall,

    //---------- jump
    input                   is_in_delayslot_i,

    output reg              branch_flag_o,
    output reg [`RegBus]    branch_target_address_o,
    output reg              is_in_delayslot_o,
    output reg [`RegBus]    link_addr_o,
    output reg              next_inst_in_delayslot_o,

    //---------- sw/lw
    output [`RegBus]        inst_o

);

assign stall = `Disable;

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

// jump
wire [`RegBus]      pc_plus_8;
wire [`RegBus]      pc_plus_4;
wire [`RegBus]      imm_sll2_signedext;

assign pc_plus_8 = pc_i + 8;
assign pc_plus_4 = pc_i + 4;
assign imm_sll2_signedext = { {14{inst_i[15]}}, 
                                inst_i[15:0], 
                                2'b00 };  
assign stallreq = `Disable;


// load store
assign inst_o = inst_i;

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

        link_addr_o                 <= `ZeroWord;
        branch_target_address_o     <= `ZeroWord;
        branch_flag_o               <= `Disable;
        next_inst_in_delayslot_o    <= `Disable;    
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

        link_addr_o                 <= `ZeroWord;
        branch_target_address_o     <= `ZeroWord;
        branch_flag_o               <= `Disable;    
        next_inst_in_delayslot_o    <= `Disable;
        case (op)
            // TODO special 指令
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

                            `EXE_OR: begin
                                aluop_o     <= `EXE_OR_OP;
                                alusel_o    <= `EXE_RES_LOGIC;
                                
                                wreg_o      <= `Enable;
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid   <= `Enable;
                            end

                            `EXE_XOR: begin
                                aluop_o     <= `EXE_XOR_OP;
                                alusel_o    <= `EXE_RES_LOGIC;
                                
                                wreg_o      <= `Enable;
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid   <= `Enable;
                            end

                            `EXE_NOR: begin
                                aluop_o     <= `EXE_NOR_OP;
                                alusel_o    <= `EXE_RES_LOGIC;
                                
                                wreg_o      <= `Enable;
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid   <= `Enable;
                            end
                            
                            `EXE_SLLV: begin
                                aluop_o     <= `EXE_SLL_OP;
                                alusel_o    <= `EXE_RES_SHIFT;
                                
                                wreg_o      <= `Enable;
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid   <= `Enable;
                            end

                            `EXE_SRLV: begin
                                aluop_o     <= `EXE_SRL_OP;
                                alusel_o    <= `EXE_RES_SHIFT;
                                
                                wreg_o      <= `Enable;
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid   <= `Enable;
                            end
                            
                            `EXE_SRAV: begin
                                aluop_o     <= `EXE_SRA_OP;
                                alusel_o    <= `EXE_RES_SHIFT;
                                
                                wreg_o      <= `Enable;
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid   <= `Enable;
                            end

                            `EXE_SYNC: begin
                                aluop_o     <= `EXE_NOP_OP;
                                alusel_o    <= `EXE_RES_NOP;

                                wreg_o      <= `Disable;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b1;

                                instvalid   <= `Enable;
                            end
                            `EXE_MFHI: begin
                                aluop_o     <= `EXE_MFHI_OP;
                                alusel_o    <= `EXE_RES_MOVE;

                                // wd_o        <= rt;
                                wreg_o      <= `Enable;

                                reg1_read_o <= `Disable;
                                reg2_read_o <= `Disable;

                                // imm         <= {16'h0, imm_i};

                                instvalid   <= `Enable;
                            end

                            `EXE_MFLO: begin
                                aluop_o     <= `EXE_MFLO_OP;
                                alusel_o    <= `EXE_RES_MOVE;

                                // wd_o        <= rt;
                                wreg_o      <= `Enable;

                                reg1_read_o <= `Disable;
                                reg2_read_o <= `Disable;

                                // imm         <= {16'h0, imm_i};

                                instvalid   <= `Enable;
                            end

                            `EXE_MTHI: begin
                                aluop_o     <= `EXE_MTHI_OP;
                                alusel_o    <= `EXE_RES_MOVE;

                                // wd_o        <= rt;
                                // wreg_o      <= `Disable;

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Disable;

                                // imm         <= {16'h0, imm_i};

                                instvalid   <= `Enable;
                            end

                            `EXE_MTLO: begin
                                aluop_o     <= `EXE_MTLO_OP;
                                alusel_o    <= `EXE_RES_MOVE;

                                // wd_o        <= rt;
                                // wreg_o      <= `Disable;

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Disable;

                                // imm         <= {16'h0, imm_i};

                                instvalid   <= `Enable;
                            end

                            `EXE_MOVN: begin
                                aluop_o     <= `EXE_MOVN_OP;
                                alusel_o    <= `EXE_RES_MOVE;

                                // wd_o        <= rt;
                                if (reg2_o != `ZeroWord) begin
                                    wreg_o <= `Enable;
                                end else begin
                                    wreg_o <= `Disable;
                                end

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                // imm         <= {16'h0, imm_i};

                                instvalid   <= `Enable;
                            end

                            `EXE_MOVZ: begin
                                aluop_o     <= `EXE_MOVZ_OP;
                                alusel_o    <= `EXE_RES_MOVE;

                                // wd_o        <= rt;
                                if (reg2_o == `ZeroWord) begin
                                    wreg_o <= `Enable;
                                end else begin
                                    wreg_o <= `Disable;
                                end

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                // imm         <= {16'h0, imm_i};

                                instvalid   <= `Enable;
                            end

                            `EXE_SLT: begin
                                aluop_o <= `EXE_SLT_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;

                                wreg_o <= `Enable;

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid <= `Enable;
                            end
                            `EXE_SLTU: begin
                                aluop_o <= `EXE_SLTU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;

                                wreg_o <= `Enable;

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid <= `Enable; 
                            end

                            `EXE_ADD: begin
                                aluop_o <= `EXE_ADD_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                
                                wreg_o <= `Enable;
                                
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid <= `Enable;   
                            end

                            `EXE_ADDU: begin
                                wreg_o <= `Enable;
                                aluop_o <= `EXE_ADDU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;
                                instvalid <= `Enable;   
                            end
                            `EXE_SUB: begin
                                aluop_o <= `EXE_SUB_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;

                                wreg_o <= `Enable;

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid <= `Enable;   
                            end
                            `EXE_SUBU: begin
                                aluop_o <= `EXE_SUBU_OP;
                                alusel_o <= `EXE_RES_ARITHMETIC;

                                wreg_o <= `Enable;
                                
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid <= `Enable;   
                            end
                            `EXE_MULT: begin
                                wreg_o <= `Disable;
                                
                                aluop_o <= `EXE_MULT_OP;

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid <= `Enable;   
                            end
                            `EXE_MULTU: begin
                                aluop_o <= `EXE_MULTU_OP;
                                
                                wreg_o <= `Disable;

                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Enable;

                                instvalid <= `Enable;   
                            end

                            `EXE_JR: begin
                                aluop_o     <= `EXE_JR_OP;
                                alusel_o    <= `EXE_RES_JUMP_BRANCH;
                                
                                wreg_o      <= `Disable;
                                
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Disable;
                                
                                link_addr_o <= `ZeroWord;
                                
                                branch_target_address_o <= reg1_o;
                                branch_flag_o           <= `Enable;
                       
                                next_inst_in_delayslot_o <= `Enable;
                                instvalid                <= `Enable;    
                            end

                            `EXE_JALR: begin
                                aluop_o     <= `EXE_JALR_OP;
                                alusel_o    <= `EXE_RES_JUMP_BRANCH;

                                wreg_o  <= `Enable;
                                wd_o    <= rd;
                                
                                reg1_read_o <= `Enable;
                                reg2_read_o <= `Disable;
                                
                                
                                link_addr_o             <= pc_plus_8;
                                branch_target_address_o <= reg1_o;
                                branch_flag_o           <= `Enable;
                       
                                next_inst_in_delayslot_o <= `Enable;
                                
                                instvalid <= `Enable;    
                                end 
                        default: begin
                                
                            end
                        endcase
                    end 
                    default:  begin
                        
                    end
                endcase
                end

            //TODO special2
            `EXE_SPECIAL2_INST: begin
                case ( op3 )
                    `EXE_CLZ:       begin
                        aluop_o <= `EXE_CLZ_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;

                        wreg_o <= `Enable;

                        reg1_read_o <= `Enable;
                        reg2_read_o <= 1'b0;

                        instvalid <= `Enable; 
                    end

                    `EXE_CLO:   begin
                        aluop_o <= `EXE_CLO_OP;
                        alusel_o <= `EXE_RES_ARITHMETIC;
                        
                        wreg_o <= `Enable;
                        
                        reg1_read_o <= `Enable; 
                        reg2_read_o <= `Disable;
                        
                        instvalid <= `Enable; 
                    end

                    `EXE_MUL:   begin
                        aluop_o <= `EXE_MUL_OP;
                        alusel_o <= `EXE_RES_MUL;

                        wreg_o <= `Enable;

                        reg1_read_o <= `Enable; 
                        reg2_read_o <= `Enable;

                        instvalid <= `Enable;      
                    end
                    
                    default: begin
                    end
                endcase      //EXE_SPECIAL_INST2 case
                end

            // TODO op 指令 
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
            
            `EXE_ANDI: begin
                aluop_o     <= `EXE_AND_OP;
                alusel_o    <= `EXE_RES_LOGIC;

                wd_o        <= rt;
                wreg_o      <= `Enable;

                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;

                imm         <= {16'h0, imm_i};

                instvalid   <= `Enable;
                end

            `EXE_XORI: begin
                aluop_o     <= `EXE_XOR_OP;
                alusel_o    <= `EXE_RES_LOGIC;

                wd_o        <= rt;
                wreg_o      <= `Enable;

                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;

                imm         <= {16'h0, imm_i};

                instvalid   <= `Enable;
                end

            `EXE_LUI: begin
                aluop_o     <= `EXE_OR_OP;
                alusel_o    <= `EXE_RES_LOGIC;

                wd_o        <= rt;
                wreg_o      <= `Enable;

                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;

                imm         <= {imm_i, 16'h0};

                instvalid   <= `Enable;
                end
            
            `EXE_PREF: begin
                aluop_o     <= `EXE_NOP_OP;
                alusel_o    <= `EXE_RES_NOP;

                wd_o        <= rt;
                wreg_o      <= `Disable;

                reg1_read_o <= `Disable;
                reg2_read_o <= `Disable;

                // imm         <= {imm_i, 16'h0};

                instvalid   <= `Enable;
                end

            `EXE_SLTI:   begin
                aluop_o  <= `EXE_SLT_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;

                wreg_o <= `Enable;
                wd_o <= inst_i[20:16];     

                reg1_read_o <= `Enable; 
                reg2_read_o <= `Disable;    
                
                imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                instvalid <= `Enable; 
                end

            `EXE_SLTIU:   begin
                aluop_o <= `EXE_SLTU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;

                wreg_o <= `Enable;
                wd_o <= inst_i[20:16];     

                reg1_read_o <= `Enable; 
                reg2_read_o <= `Disable;    
                
                imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                instvalid <= `Enable; 
                end

            `EXE_ADDI:   begin
                aluop_o  <= `EXE_ADDI_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                
                wreg_o <= `Enable;
                wd_o <= inst_i[20:16];     
                
                reg1_read_o <= `Enable; 
                reg2_read_o <= `Disable;    
                
                imm <= {{16{inst_i[15]}}, inst_i[15:0]};
                instvalid <= `Enable; 
                end

            `EXE_ADDIU:   begin
                aluop_o  <= `EXE_ADDIU_OP;
                alusel_o <= `EXE_RES_ARITHMETIC;
                
                wreg_o <= `Enable;
                wd_o <= inst_i[20:16];

                reg1_read_o <= `Enable; 
                reg2_read_o <= `Disable;
                
                imm <= {
                        {16{inst_i[15]}}, 
                        inst_i[15:0]        };
                instvalid <= `Enable;   
             end
            
            `EXE_J:            begin
                aluop_o  <= `EXE_J_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                
                wreg_o   <= `Disable;

                reg1_read_o <= `Disable;
                reg2_read_o <= `Disable;

                link_addr_o <= `ZeroWord;
                branch_target_address_o <= {    pc_plus_4[31:28], 
                                                inst_i[25:0], 
                                                2'b00               };
                branch_flag_o <= `Enable;
                next_inst_in_delayslot_o <= `Enable;   
                           
                instvalid <= `Enable;    
                end

            `EXE_JAL:            begin
                aluop_o     <= `EXE_JAL_OP;
                alusel_o    <= `EXE_RES_JUMP_BRANCH;
                
                wreg_o      <= `Enable;
                wd_o <= 5'b11111;    //默认存到 $31
                
                reg1_read_o <= `Disable;
                reg2_read_o <= `Disable;
                
                link_addr_o <= pc_plus_8 ;
                branch_target_address_o <= {
                                            pc_plus_4[31:28], 
                                            inst_i[25:0], 
                                            2'b00           };
                branch_flag_o <= `Enable;
                next_inst_in_delayslot_o <= `Enable;              
                
                instvalid <= `Enable;    
             end
            
            `EXE_BEQ:            begin
                aluop_o  <= `EXE_BEQ_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                
                wreg_o <= `Disable;

                reg1_read_o <= `Enable;
                reg2_read_o <= `Enable;

                if(reg1_o == reg2_o) begin
                    branch_target_address_o     <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o               <= `Enable;
                    next_inst_in_delayslot_o    <= `Enable;
                end
                
                instvalid <= `Enable;    
                end
            
            `EXE_BGTZ:            begin
                aluop_o   <= `EXE_BGTZ_OP;
                alusel_o  <= `EXE_RES_JUMP_BRANCH;
                
                wreg_o    <= `Disable;
                
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                  
                if( (reg1_o[31] == `Disable ) && 
                    (reg1_o != `ZeroWord)   ) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Enable;
                    next_inst_in_delayslot_o <= `Enable;              
                end
                
                instvalid <= `Enable;    
                end
            
            `EXE_BLEZ:            begin
                aluop_o  <= `EXE_BLEZ_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                
                wreg_o <= `Disable;

                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;
                
                if( (reg1_o[31] == 1'b1) || 
                    (reg1_o == `ZeroWord) ) begin
                    branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o <= `Enable;
                    next_inst_in_delayslot_o <= `Enable;              
                end
                
                instvalid <= `Enable;    
             end

            `EXE_BNE:            begin
                aluop_o  <= `EXE_BLEZ_OP;
                alusel_o <= `EXE_RES_JUMP_BRANCH;
                
                wreg_o <= `Disable;
                
                reg1_read_o <= `Enable;
                reg2_read_o <= `Enable;
                
                if(reg1_o != reg2_o) begin
                    branch_target_address_o     <= pc_plus_4 + imm_sll2_signedext;
                    branch_flag_o               <= `Enable;
                    next_inst_in_delayslot_o    <= `Enable;              
                end
                
                instvalid <= `Enable;    
                end
            
            `EXE_LW:            begin
                aluop_o <= `EXE_LW_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                
                wreg_o <= `Enable;
                wd_o <= inst_i[20:16];
                
                reg1_read_o <= `Enable;
                reg2_read_o <= `Disable;          
                
                instvalid <= `Enable;    
                end

            `EXE_SW:            begin
                wreg_o <= `Disable;
                
                aluop_o <= `EXE_SW_OP;
                alusel_o <= `EXE_RES_LOAD_STORE; 
                
                reg1_read_o <= `Enable;
                reg2_read_o <= `Enable;

                instvalid <= `Enable;    
                end

            `EXE_REGIMM_INST:        begin
                case (op4)
                    `EXE_BGEZ:    begin
                        aluop_o  <= `EXE_BGEZ_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        
                        wreg_o <= `Disable;
                        
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Disable;

                        if(reg1_o[31] == 1'b0) begin
                            branch_target_address_o     <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o               <= `Enable;
                            next_inst_in_delayslot_o    <= `Enable;              
                        end
                        
                        instvalid <= `Enable;    
                    end

                    `EXE_BGEZAL:        begin
                        aluop_o  <= `EXE_BGEZAL_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        
                        wreg_o  <= `Enable;
                        wd_o    <= 5'b11111;
                        
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Disable;
                        
                        link_addr_o <= pc_plus_8; 
                        
                        if(reg1_o[31] == 1'b0) begin
                            branch_target_address_o     <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o               <= `Enable;
                            next_inst_in_delayslot_o    <= `Enable;
                        end
                        
                        instvalid <= `Enable;
                    end

                    `EXE_BLTZ:        begin
                        aluop_o <= `EXE_BGEZAL_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        
                        wreg_o <= `Disable;
                        
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Disable;
                        
                        if(reg1_o[31] == 1'b1) begin
                            branch_target_address_o     <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o               <= `Enable;
                            next_inst_in_delayslot_o    <= `Enable;              
                        end
                        instvalid <= `Enable;    
                    end
                    `EXE_BLTZAL:        begin
                        aluop_o  <= `EXE_BGEZAL_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        
                        wreg_o  <= `Enable;
                        wd_o    <= 5'b11111;
                        
                        reg1_read_o <= `Enable;
                        reg2_read_o <= `Disable;
                        
                        link_addr_o <= pc_plus_8;    
                        
                        if(reg1_o[31] == 1'b1) begin
                            branch_target_address_o     <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o               <= `Enable;
                            next_inst_in_delayslot_o    <= `Enable;
                        end
                        
                        instvalid <= `Enable;
                    end
                    default: 
                        instvalid   <= `Disable;
                endcase
                end
        endcase

        if (inst_i[31:21] == 11'b00000000000) begin
                if(op3 == `EXE_SLL) begin
                    aluop_o     <= `EXE_SLL_OP;
                    alusel_o    <= `EXE_RES_SHIFT;

                    wd_o        <= rd;
                    wreg_o      <= `Enable;

                    reg1_read_o <= `Disable;
                    reg2_read_o <= `Enable;

                    imm[4:0]         <= op2;

                    instvalid   <= `Enable;
                end else if (op3 == `EXE_SRL) begin
                    aluop_o     <= `EXE_SRL_OP;
                    alusel_o    <= `EXE_RES_SHIFT;

                    wd_o        <= rd;
                    wreg_o      <= `Enable;

                    reg1_read_o <= `Disable;
                    reg2_read_o <= `Enable;

                    imm[4:0]         <= op2;

                    instvalid   <= `Enable;
                end else if (op3 == `EXE_SRA) begin
                    aluop_o     <= `EXE_SRA_OP;
                    alusel_o    <= `EXE_RES_SHIFT;

                    wd_o        <= rd;
                    wreg_o      <= `Enable;

                    reg1_read_o <= `Disable;
                    reg2_read_o <= `Enable;

                    imm[4:0]         <= op2;

                    instvalid   <= `Enable;
                end
            end
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


// ------------ delayslot out
always @ (*) begin
    if(rst == `Enable) begin
        is_in_delayslot_o <= `Disable;
    end else begin
        is_in_delayslot_o <= is_in_delayslot_i;        
    end
end

endmodule