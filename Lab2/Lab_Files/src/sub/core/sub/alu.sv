
import riscv_package::*;

module alu
  #( parameter DW = 32
  )
  (
    input  logic  [DW-1:0] operand_a,
    input  logic  [DW-1:0] operand_b,
    input  alu_operation_e operation,
    output logic  [DW-1:0] result,
    output logic           branch
  );

  always_comb
  begin
    result = 'd0;
    branch = 'd0;
    case(operation)
      ALU_AND:
        result = operand_a & operand_b;
      ALU_OR :
        result = operand_a | operand_b;
      ALU_ADD:
        result = operand_a + operand_b;
      ALU_SUB:
        result = $signed(operand_a) - $signed(operand_b);
      ALU_NOR:
            result = operand_a ~| operand_b;
      ALU_LT:
            result = operand_a <operand_b ? 31'b1: 31'b0;
      ALU_SLT:
            result = $signed(operand_a)<$signed(operand_b)? 31'b1: 31'b0;
      ALU_SLL:
            result = operand_a << operand_b[4:0];
      ALU_SRL:
            result = operand_a >> operand_b[4:0];
      ALU_SRA:
            result = $signed(operand_a) >>> operand_b[4:0];
      ALU_BEQ:
            branch = 'd1;
      ALU_BNE:
            branch = 'd1;
      ALU_BLT:
            branch = 'd1;
      ALU_BGE:
            branch = 'd1;
      default:
      begin
        result = 'b0;
        branch = 'd0;
      end
    endcase
  end
endmodule:alu
