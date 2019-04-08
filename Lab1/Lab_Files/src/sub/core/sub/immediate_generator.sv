
import riscv_package::*;

module immediate_generator
  #(
    parameter DW = 32
  )
  (
    input riscv_inst32_t inst,
    output logic [DW-1:0] imm
    );

  /* Based on Figure 2.4: Types of immediate produced by RISC-V instructions. */
  always_comb
    begin
      case(inst.rinst.opcode)
        OP_LOAD:
            imm = {{21{inst.bits[31]}} , inst[30:20]};
        OP_OP_IMM:
            /* FIXME: Add support for SRAI instruction*/
            imm = {{21{inst.bits[31]}} , inst[30:20]};
        OP_JALR:
            imm = {{21{inst.bits[31]}}, inst[30:20]};
        OP_STORE:
            imm = {{21{inst.bits[31]}} , inst[30:25], inst[11:7]};
        OP_LUI:
            imm = {inst[31:12], 12'b0};
        OP_AUIPC:
            imm = {inst[31:12], 12'b0};
        OP_JAL:
            imm = {{12{inst[31]}}, inst[19:12] , inst[20], inst[30:21], 1'b0};
        OP_BRANCH:
            imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        default:
            imm = {DW{1'b0}};
      endcase
    end
endmodule:immediate_generator
