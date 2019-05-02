
package riscv_package;

  /* ALU Operations */

  typedef enum logic [3:0]{
    ALU_AND = 4'b0000,
    ALU_OR  = 4'b0001,
    ALU_ADD = 4'b0010,
    ALU_SUB = 4'b0110,
    ALU_LT  = 4'b0111, // Less than
    ALU_NOR = 4'b1100,
    ALU_SLT = 4'b0011,
    ALU_SLL = 4'b0100,
    ALU_SRL = 4'b0101,
    ALU_SRA = 4'b1000,
    ALU_BEQ = 4'b1001,
    ALU_BNE = 4'b1010,
    ALU_BLT = 4'b1011,
    ALU_BGE = 4'b1101,
    ALU_BLTU = 4'b1110,
    ALU_BGEU = 4'b1111
  } alu_operation_e;

  /* Based on Table 19.1: RISC-V base opcode map */
  typedef  enum logic[6:0]{
    OP_LOAD       = 7'b0000011  ,
    OP_LOAD_FP    = 7'b0000111  ,
    OP_CUSTOM_0   = 7'b0001011  ,
    OP_MISC_MEM   = 7'b0001111  ,
    OP_OP_IMM     = 7'b0010011  ,
    OP_AUIPC      = 7'b0010111  ,
    OP_OP_IMM_32  = 7'b0011011  ,
    OP_STORE      = 7'b0100011  ,
    OP_STORE_FP   = 7'b0100111  ,
    OP_CUSTOM_1   = 7'b0101011  ,
    OP_AMO        = 7'b0101111  ,
    OP_OP         = 7'b0110011  ,
    OP_LUI        = 7'b0110111  ,
    OP_OP_32      = 7'b0111011  ,
    OP_MADD       = 7'b1000011  ,
    OP_MSUB       = 7'b1000111  ,
    OP_NMSUB      = 7'b1001011  ,
    OP_NMADD      = 7'b1001111  ,
    OP_OP_FP      = 7'b1010011  ,
    OP_CUSTOM_2   = 7'b1011011  ,
    OP_BRANCH     = 7'b1100011  ,
    OP_JALR       = 7'b1100111  ,
    OP_JAL        = 7'b1101111  ,
    OP_SYSTEM     = 7'b1110011  ,
    OP_CUSTOM_3   = 7'b1111011
  } opcode32_e;

  typedef struct packed  {
    logic [ 6: 0] func7;
    logic [ 4: 0] rs2;
    logic [ 4: 0] rs1;
    logic [ 2: 0] func3;
    logic [ 4: 0] rd;
    opcode32_e    opcode;
  } rtype_t;

  typedef struct packed {
    logic [11: 0] imm;
    logic [ 4: 0] rs1;
    logic [ 2: 0] func3;
    logic [ 4: 0] rd;
    opcode32_e    opcode;
  } itype_t;

  typedef struct packed {
    logic [ 6: 0] imm5_11;
    logic [ 4: 0] rs2;
    logic [ 4: 0] rs1;
    logic [ 2: 0] func3;
    logic [ 4: 0] imm0_4;
    opcode32_e    opcode;
  } stype_t;

  typedef struct packed {
    logic         imm12;
    logic [ 5: 0] imm10_5;
    logic [ 4: 0] rs2;
    logic [ 4: 0] rs1;
    logic [ 2: 0] func3;
    logic [ 3: 0] imm4_1;
    logic         imm11;
    opcode32_e    opcode;
  } btype_t;

  typedef struct packed {
    logic [19: 0] imm7;
    logic [ 4: 0] rd;
    opcode32_e    opcode;
  } utype_t;

  typedef struct packed {
    logic         imm20;
    logic [ 9: 0] imm10_1;
    logic         imm11;
    logic [ 7: 0] imm19_12;
    logic [ 4: 0] rd;
    opcode32_e    opcode;
  } jtype_t;


  typedef union packed {
    rtype_t rinst;
    itype_t iinst;
    stype_t sinst;
    btype_t binst;
    utype_t uinst;
    jtype_t jinst;
    logic [31:0] bits;
  } riscv_inst32_t;

endpackage:riscv_package
