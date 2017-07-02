module trv_br_cond
(
  input wire [2:0] op,
  input wire [31:0] rs1,
  input wire [31:0] rs2,
  output wire take_branch
);
  wire signed s_rs1, s_rs2;
  s_rs1 = rs1;
  s_rs2 = rs2;

  always @* begin
    take_branch = 0;
    case (op)
      `TRV_OPCODE_BR_EQ:
        take_branch = rs1 == rs2;
      `TRV_OPCODE_BR_NE:
        take_branch = rs1 != rs2;
      `TRV_OPCODE_BR_LT:
        take_branch = s_rs1 < s_rs2;
      `TRV_OPCODE_BR_GE:
        take_branch = !(s_rs1 < s_rs2);
      `TRV_OPCODE_BR_LTU:
        take_branch = rs1 < rs2;
      `TRV_OPCODE_BR_GEU:
        take_branch = !(rs1 < rs2);
    endcase
  end
endmodule

module trv_alu
(
  input wire [2:0] op,
  input wire [5:0] arg,
  input wire [31:0] rs1,
  input wire [31:0] rs2,
  output wire [31:0] rd,
);
  
  wire signed s_rs1, s_rs2;
  assign s_rs1 = rs1;
  assign s_rs2 = rs2;

  always @* begin
    rd = 0;
    case(op)
      `TRV_OPCODE_ALU_OP_ACC: begin
        case (arg)
          `TRV_OPCODE_ALU_OP_ACC_ADD:
            rd = rs1 + rs2;
          `TRV_OPCODE_ALU_OP_ACC_SUB:
            rd = rs1 - rs2;
          `TRV_OPCODE_ALU_OP_ACC_MUL:
            rd = rs1 * rs2;   // TODO: pipeline this
        endcase
      end
      `TRV_OPCODE_ALU_OP_AND:
        rd = rs1 & rs2;
      `TRV_OPCODE_ALU_OP_OR:
        rd = rs1 | rs2;
      `TRV_OPCODE_ALU_OP_XOR:
        rd = rs1 ^ rs2;
      `TRV_OPCODE_ALU_OP_SLT:
        rd = {30'b0, s_rs1 < s_rs2};
      `TRV_OPCODE_ALU_OP_SLTU:
        rd = {30'b0, rs1 < rs2};
      `TRV_OPCODE_ALU_OP_SR:
        rd = (arg[1] ? rs1 >> rs2 : s_rs1 >>> s_rs2);
      `TRV_OPCODE_ALU_OP_SL:
        rd = (arg[1] ? rs1 << rs2 : s_rs1 <<< s_rs2);
    endcase
  end
endmodule
