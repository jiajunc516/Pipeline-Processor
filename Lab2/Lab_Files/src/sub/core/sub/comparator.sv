
import riscv_package::*;

module comparator()
    // inputs
    input logic [31:0] operand_a,
    input logic [31:0] operand_b,
    input logic [2:0] funct3

    // outputs
    output logic result
    );

    assign result = ((operand_a == operand_b) && (funct3 == 3'b000)) ||
                    ((operand_a != operand_b) && (funct3 == 3'b001)) ||
                    ((operand_a < operand_b) && ((funct3 == 3'b100) || (funct3 == 3'b110))) ||
                    ((operand_a > operand_b) && ((funct3 == 3'b101) || (funct3 == 3'b111)));

endmodule:comparator