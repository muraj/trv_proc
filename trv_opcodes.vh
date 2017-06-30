`define TRV_OPCODE(i)         i[6:0]
`define TRV_OPCODE_RS1(i)     i[19:15]
`define TRV_OPCODE_ALU_OP(i)  i[14:12]
`define TRV_OPCODE_ALU_ARG(i) i[31:25]
`define TRV_OPCODE_RS2(i)     i[24:20]
`define TRV_OPCODE_RD(i)      i[11:7]
`define TRV_OPCODE_I_IMM(i)   {21{i[31]}, i[30:20]}
`define TRV_OPCODE_S_IMM(i)   {21{i[31]}, i[30:25], i[11:7]}
`define TRV_OPCODE_B_IMM(i)   {20{i[31]}, i[7], i[30:25], i[11:8], 1'b0}
`define TRV_OPCODE_U_IMM(i)   {i[31], i[30:20], i[19:12], 12{1'b0}}
`define TRV_OPCODE_J_IMM(i)   {11{i[31]}, i[19:12], i[20], i[30:21], 1'b0}

`define TRV_OPCODE_CSR        1'b1110011
`define TRV_OPCODE_RR         1'b0110011
`define TRV_OPCODE_RI_GRP1    1'b0010011
`define TRV_OPCODE_LUI        1'b0110111
`define TRV_OPCODE_AUIPC      1'b0010111
`define TRV_OPCODE_LOAD       1'b0000011
`define TRV_OPCODE_STORE      1'b0100011
`define TRV_OPCODE_JAL        1'b1101111
`define TRV_OPCODE_UNCOND_BR  1'b1100111
`define TRV_OPCODE_COND_BR    1'b1100011

`define TRV_OPCODE_ALU_OP_ACC  3'b000
`define TRV_OPCODE_ALU_OP_ACC_ADD 6'b000000
`define TRV_OPCODE_ALU_OP_ACC_SUB 6'b010000
`define TRV_OPCODE_ALU_OP_ACC_MUL 6'b000001
`define TRV_OPCODE_ALU_OP_SL   3'b001
`define TRV_OPCODE_ALU_OP_SLT  3'b010
`define TRV_OPCODE_ALU_OP_SLTU 3'b011
`define TRV_OPCODE_ALU_OP_XOR  3'b100
`define TRV_OPCODE_ALU_OP_SR   3'b101
`define TRV_OPCODE_ALU_OP_OR   3'b110
`define TRV_OPCODE_ALU_OP_AND  3'b111

`define TRV_OPCODE_BR_EQ  3'b000
`define TRV_OPCODE_BR_NE  3'b001
`define TRV_OPCODE_BR_LT  3'b100
`define TRV_OPCODE_BR_GE  3'b101
`define TRV_OPCODE_BR_LTU 3'b110
`define TRV_OPCODE_BR_GEU 3'b111

`define TRV_ZERO_REG 0

`define TRV_ALU_ARG_PC  2'b00
`define TRV_ALU_ARG_MEM 2'b01
`define TRV_ALU_ARG_REG 2'b10
`define TRV_ALU_ARG_IMM 2'b11
