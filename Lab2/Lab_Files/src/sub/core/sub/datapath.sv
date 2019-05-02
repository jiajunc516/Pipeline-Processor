
import riscv_package::*;

module datapath
  #(
    parameter AW = 32,
    parameter DW = 32
  )
  (
    input logic          clk,
    input logic          rst_n,
    input riscv_inst32_t inst,
    controller_if.in     ctrl,
    output [AW-1:0]      pc,
    memory_if.master     dmem_if
  );

  logic [AW-1:0] pc_next;
  logic [DW-1:0] aluop1, aluop2, alu_result;
  logic [DW-1:0] regf_dout1, regf_dout2;
  logic [AW-1:0] regf_wr_addr;
  logic [DW-1:0] regf_wr_data;
  logic [DW-1:0] imm_val;

  assign  pc_next = pc + 1;

  program_counter
  #(.AW(AW))
  pc_inst
  ( .clk    ( clk   ),
    .rst_n  ( rst_n ),
    .enable ( 1'b1  ),
    .din    ( pc_next ),
    .pc     ( pc      )
  );


  assign regf_wr_en   = ctrl.reg_write;
  assign regf_wr_addr = inst.rinst.rd;
  assign regf_wr_data = ctrl.mem2reg != 2'b01 ? alu_result : dmem_if.rdata;


  register_file
  #( .AW(5), .DW(DW))
  regf_inst
  (
    .clk      ( clk            ),
    .rst_n    ( rst_n          ),
    .rd_addr1 ( inst.rinst.rs1 ),
    .rd_addr2 ( inst.rinst.rs2 ),
    .rd_data1 ( regf_dout1     ),
    .rd_data2 ( regf_dout2     ),
    .wr_en    ( regf_wr_en     ),
    .wr_addr  ( regf_wr_addr   ),
    .wr_data  ( regf_wr_data   )
  );

  immediate_generator
  #( .DW(DW) )
  immgen_inst
  (
    .inst ( inst    ),
    .imm  ( imm_val )
  );


  assign aluop1 = regf_dout1;
  assign aluop2 = ~ctrl.alu_src ?  regf_dout2 : imm_val;

  alu_operation_e  operation;
  logic       cont_beq;
  logic       cont_bnq;
  logic       cont_blt;
  logic       cont_bgt;
  logic [2:0] readdatasel;
  logic [1:0] writedatasel;

  alu_controller aluc_inst(
    .*,
    .aluop  ( ctrl.aluop       ),
    .funct3 ( inst.rinst.func3 ),
    .funct7 ( inst.rinst.func7 )
  );

  logic       comp_out;
  
  comparator comp_inst(
    .operand_a (aluop1),
    .operand_b (aluop2),
    .funct3 (inst.binst.funct3)
    .dout (comp_out)
  );

  logic       alu_zero;

  alu
  #()
  alu_inst
  (
    .operand_a ( aluop1    ),
    .operand_b ( aluop2    ),
    .operation ( operation ),
    .branch    ( alu_zero ),
    .result    ( alu_result )
  );

  assign dmem_if.addr  = alu_result;
  assign dmem_if.wr    = ctrl.mem_write;
  assign dmem_if.wdata = regf_dout2;
  
  branch bran_inst(
	.alu_zero (alu_zero),
	.controller_branch (comp_out),
	.shift_input (imm_val),
	.pc_output ( pc ),
	.adder_output ( pc + 1),
	.mux_output ( pc_next )
  );

endmodule:datapath
