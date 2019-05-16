
interface controller_if();
  logic       alu_src;     /* 0: the second alu operand comes from the second register file output (read data 2);
   1: the second alu operand is the sign-extended; lower 16 bits of the instruction. */
  logic [1:0] mem2reg;   /* 0: the value fed to the register write data input comes from the alu.
   1: the value fed to the register write data input comes from the data memory. */
  logic       reg_write;   // the register on the write register input is written with the value on the write data input
  logic       mem_read;    // data memory contents designated by the address input are put on the read data output
  logic       mem_write;   // data memory contents designated by the address input are replaced by the value on the write data input.
  logic [3:0] write_enable;
  logic [4:0] read_enable;
  logic [1:0] aluop;
  logic       branch;       //0: branch is not taken; 1: branch is taken
  logic       jalr_mode;
  logic       jal_mode;
  logic       lui_mode;
  logic [1:0] writeback;

  modport in(
    input  alu_src,
    input  mem2reg,
    input  reg_write,
    input  mem_read,
    input  mem_write,
    input  write_enable,
    input  read_enable,
    input  aluop,
    input  branch,
    input  jalr_mode,
    input  jal_mode,
    input  lui_mode,
    input  writeback
  );

  modport out(
    output  alu_src,
    output  mem2reg,
    output  reg_write,
    output  mem_read,
    output  mem_write,
    output  write_enable,
    output  read_enable,
    output  aluop,
    output  branch,
    output  jalr_mode,
    output  jal_mode,
    output  lui_mode,
    output  writeback
  );

endinterface:controller_if
