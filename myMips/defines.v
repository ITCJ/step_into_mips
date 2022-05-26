//功能
`define Enable   1'b1
`define Disable  1'b0
`define ZeroWord    32'h0000_0000

`define AluOpBus    7:0
`define AluSelBus   2:0
`define Valid       1'b0
`define InValid     1'b1

//指令
`define EXE_ORI         6'b001101
`define EXE_NOP         6'b000000

//ALU
`define EXE_OR_OP         8'b0010_0101
`define EXE_NOP_OP        8'b0000_0000

//AluSel
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_NOP         3'b000

//ROM
`define InstAddrBus     31:0
`define InstBus         31:0

`define InstMemNum      128 * 1024 - 1
`define InstMemNumLog2  17

//----------regfile
`define RegAddrBus          4:0
`define RegBus              31:0
`define RegWidth            32
`define DoubleRegWidth      64
`define DoubleRegBus        63:0
`define RegNum              32
`define RegNumLog2          5
`define NOPRegAddr          5'b0_0000
