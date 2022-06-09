`include "defines.v"

module cpu(
    input clk,
    input rst,

    input [`RegBus]         rom_data_i,

    output reg              rom_ce_o,
    output reg [`RegBus]    rom_addr_o
);
    //TODO ---------- IF
    wire [`RegBus]      pc_if;
    pc_reg pc0(
        .clk(clk),
        .rst(rst),
        .pc(pc_if),
        .ce(rom_ce_o)
    );

    //需要例化rom IP用于输入指令进行测试
    assign rom_data_i = pc_if;

    //TODO ---------- IF/ID
    wire id_pc_i;
    wire id_inst_i;
    if_id if_id0(
        .clk(clk),
        .rst(rst),

        .if_pc(pc_if),
        .if_inst(rom_data_i),

        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );

    //TODO ---------- ID

    wire [`RegBus]  rdata1;
    wire [`RegBus]  rdata2;
    
    wire [`RegAddrBus]      reg2_addr;
    wire                    reg2_read;
    wire [`RegAddrBus]      reg1_addr;
    wire                    reg1_read;

    wire [`AluOpBus]        id_aluop_o;
    wire [`AluSelBus]       id_alusel_o;
    
    wire [`RegAddrBus]      id_wd_o;
    wire                    id_wreg_o;
    
    wire [`RegBus]          id_reg1_o;
    wire [`RegBus]          id_reg2_o;
    id id0(
        .rst(rst),

        .pc_i(id_pc_i),
        .ins_i(id_inst_i),

        //regfile
        .reg1_data_i(rdata1),
        .reg2_data_i(rdata2),
        
        .reg2_addr_o(reg2_addr),
        .reg2_read_o(reg2_read),
        .reg1_addr_o(reg1_addr),
        .reg1_read_o(reg1_read),

        // 连接ID/EX
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o),
        
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o)
    );

    regfile regfile0(
        .r1(reg1_addr),
        .rdata1(rdata1),
        .r1e(reg1_read),

        .r2(reg2_addr),
        .rdata2(rdata2),
        .r2e(reg2_read),

        .rw(),
        .wdata(),
        .we(),

        .rst(rst),
        .clk(clk)
    );

    //TODO ---------- ID/EX
    wire [`AluOpBus]    ex_aluop_i;
    wire [`AluSelBus]   ex_alusel_i;
    wire [`RegBus]      ex_rdata1_i;
    wire [`RegBus]      ex_rdata2_i;
    wire [`RegAddrBus]  ex_rw_i;
    wire                ex_wreg_i;

    id_ex id_ex0(
        .rst(rst),  .clk(clk),

        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_rdata1(id_reg1_o),
        .id_rdata2(id_reg2_o),
        .id_rw(id_wd_o),
        .id_wreg(id_wreg_o),
        
        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_rdata1(ex_rdata1_i),
        .ex_rdata2(ex_rdata2_i),
        .ex_rw(ex_rw_i),
        .ex_wreg(ex_wreg_i)
    );

    //TODO ---------- EX
    wire [`RegAddrBus]  ex_rw_o;
    wire                ex_wreg_o;
    wire [`RegBus]      ex_wdata_o;

    ex ex0(
        .rst(rst),

        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .rdata1(ex_rdata1_i),
        .rdata2(ex_rdata2_i),
        .rw_i(ex_rw_i),
        .wreg_i(ex_wreg_i),

        .rw_o(ex_rw_o),
        .wreg_o(ex_wreg_o),
        .wdata_o(ex_wdata_o)
    );

    //TODO ---------- EX/MEM
    wire [`RegAddrBus]  mem_rw_i;
    wire                mem_wreg_i;
    wire [`RegBus]      mem_wdata_i;
    ex_mem ex_mem0(
        .rst(rst),
        .clk(clk),

        .ex_rw(ex_rw_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        .mem_rw(mem_rw_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i)
    );

    //TODO ---------- MEM
    wire [`RegAddrBus]  mem_rw_o;
    wire                mem_wreg_o;
    wire [`RegBus]      mem_wdata_o;
    mem mem0(
        .rst(rst),

        .rw_i(mem_rw_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        .rw_o(mem_rw_o),
        .wreg_o(mem_wreg_o),
        .wdata_o(mem_wdata_o)
    );

    //TODO ---------- MEM/WB
    mem_wb  mem_wb0(
        .clk(clk), .rst(rst),
        .rw_i(mem_rw_i),
        .wreg_i(mem_wreg_i),
        .wdata_i(mem_wdata_i),

        .rw_o(wb_rw_o),
        .wreg_o(wb_wreg_o),
        .wdata_o(wb_wdata_o)
    );

endmodule 