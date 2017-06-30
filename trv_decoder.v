module trv_decoder
(
  input wire [31:0] inst,
  output wire [2:0] alu_op,
  output wire [5:0] alu_arg,
  output wire sel_rs1,
  output wire sel_rs2,
  output wire sel_rd,
  output wire [4:0] rd,
  output wire [4:0] rs1,
  output wire [4:0] rs2,
  output wire [31:0] imm,
  output wire is_rd_mem,
  output wire is_wr_mem,
  output wire is_cond_br,
  output wire is_uncond_br,
);

  always @* begin
    is_rd_mem = 0;
    is_wr_mem = 0;
    is_cond_br = 0;
    is_uncond_br = 0;
    alu_op = `TRV_OPCODE_ALU_OP_ACC;
    alu_arg = `TRV_OPCODE_ALU_OP_ACC_ADD;
    imm = 31{1'bx};
    sel_rs1 = `TRV_ALU_ARG_REG;
    sel_rs2 = `TRV_ALU_ARG_REG;
    sel_rd = `TRV_ALU_ARG_REG;
    rs1 = `TRV_ZERO_REG;
    rs2 = `TRV_ZERO_REG;
    rd = `TRV_ZERO_REG;
    case (`TRV_OPCODE(inst))
    `TRV_OPCODE_CSR: begin
      sel_rd = `TRV_ALU_ARG_REG;
      rs1 = `TRV_OPCODE_RS1(inst);
      rd = `TRV_OPCODE_RD(inst);
      imm = `TRV_OPCODE_I_IMM(inst);
      alu_op = `TRV_OPCODE_ALU_OP(inst);
    end
    `TRV_OPCODE_RR: begin
      rs1 = `TRV_OPCODE_RS1(inst);
      rs2 = `TRV_OPCODE_RS2(inst);
      rd = `TRV_OPCODE_RD(inst);
      alu_arg = `TRV_OPCODE_ALU_ARG(inst);
      alu_op = `TRV_OPCODE_ALU_OP(inst);
    end
    `TRV_OPCODE_RI_GRP1: begin
      sel_rs2 = `TRV_ALU_ARG_IMM;
      rs1 = `TRV_OPCODE_RS1(inst);
      rd = `TRV_OPCODE_RD(inst);
      alu_op = `TRV_OPCODE_ALU_OP(inst);
      if (alu_op == 3'b101 || alu_op == 3'b001) begin
        imm = `TRV_OPCODE_RS2(inst);
        alu_arg = `TRV_OPCODE_ALU_ARG(inst);
      end
      else
        imm = `TRV_OPCODE_I_IMM(inst);
    end
    `TRV_OPCODE_LUI, `TRV_OPCODE_AUIPC: begin
      sel_rs1 = opcode == `TRV_OPCODE_AUIPC ? `TRV_ALU_ARG_PC : `TRV_ALU_ARG_REG;
      sel_rs2 = `TRV_ALU_ARG_IMM;
      sel_rd = `TRV_ALU_ARG_REG;
      alu_op = `TRV_OPCODE_ALU_OP(inst);
      rd = `TRV_OPCODE_RD(inst);
      imm = `TRV_OPCODE_U_IMM(inst) << 12;
    end
    `TRV_OPCODE_STORE: begin
      is_wr_mem = 1;
      sel_rs1 = `TRV_ALU_ARG_MEM;
      rs1 = `TRV_OPCODE_RS1(inst);
      rs2 = `TRV_OPCODE_RS2(inst);
      alu_op = `TRV_OPCODE_ALU_OP_ACC;
      alu_arg = `TRV_OPCODE_ALU_OP_ACC_ADD;
      imm = `TRV_OPCODE_S_IMM(inst);
    end
    `TRV_OPCODE_LOAD: begin
      is_rd_mem = 1;
      sel_rs2 = `TRV_ALU_ARG_IMM;
      sel_rd = `TRV_ALU_ARG_REG;
      rs1 = `TRV_OPCODE_RS1(inst);
      rs2 = `TRV_OPCODE_RS2(inst);
      rd = `TRV_OPCODE_RD(inst);
      alu_op = `TRV_OPCODE_ALU_OP_ACC;
      alu_arg = `TRV_OPCODE_ALU_OP_ACC_ADD;
      imm = `TRV_OPCODE_I_IMM(inst);
    end
    `TRV_OPCODE_JAL: begin
      is_uncond_br = 1;
      sel_rs1 = `TRV_ALU_ARG_PC;
      sel_rd = `TRV_ALU_ARG_REG;
      rd = `TRV_OPCODE_RD(inst);
      alu_op = `TRV_OPCODE_ALU_OP_ACC;
      alu_arg = `TRV_OPCODE_ALU_OP_ACC_ADD;
      imm = `TRV_OPCODE_J_IMM(inst);
    end
    `TRV_OPCODE_UNCOND_BR: begin
      is_uncond_br = 1;
      sel_rd = `TRV_ALU_ARG_REG;
      sel_rs2 = `TRV_ALU_ARG_IMM;
      rd = `TRV_OPCODE_RD(inst);
      rs1 = `TRV_OPCODE_RS1(inst);
      alu_op = `TRV_OPCODE_ALU_OP_ACC;
      alu_arg = `TRV_OPCODE_ALU_OP_ACC_ADD;
      imm = `TRV_OPCODE_J_IMM(inst);
    end
    `TRV_OPCODE_COND_BR: begin
      is_cond_br = 1;
      rs1 = `TRV_OPCODE_RS1(inst);
      rs2 = `TRV_OPCODE_RS2(inst);
      alu_op = `TRV_OPCODE_ALU_OP(inst);
      imm = `TRV_OPCODE_B_IMM(inst);
    end
    endcase
  end
endmodule
