
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
    case(operation)
      ALU_AND:
        result = operand_a & operand_b;
      ALU_OR :
        result = operand_a | operand_b;
      ALU_ADD:
        result = operand_a + operand_b;
      ALU_SUB:
        result = $signed(operand_a) - $signed(operand_b);
      default:
        result = 'b0;
    endcase
  end
endmodule:alu
