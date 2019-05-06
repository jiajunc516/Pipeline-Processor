
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
    memory_if.master     dmem_if,
    output logic [DW-1:0] WB_Data
  );

  logic [AW-1:0] pc_next;
  logic [DW-1:0] aluop1, aluop2, alu_result;
  logic [DW-1:0] regf_dout1, regf_dout2;
  logic [AW-1:0] regf_wr_addr;
  logic [DW-1:0] regf_wr_data;
  logic [DW-1:0] imm_val;

  program_counter
  #(.AW(AW))
  pc_inst
  ( .clk    ( clk   ),
    .rst_n  ( rst_n ),
    .enable ( 1'b1  ),
    .din    ( pc_next ),
    .pc     ( pc      )
  );

  logic [AW-1:0] pc_4;
  logic [DW-1:0] r_data;
  assign pc_4 = pc + 4;

  assign regf_wr_en   = ctrl.reg_write;
  assign regf_wr_addr = inst.rinst.rd;
  assign regf_wr_data = ctrl.mem2reg != 2'b01 ? alu_result : dmem_if.rdata;

  // J-type or U-type
  logic jump;
  logic [1:0] U_pc;
  logic [AW-1:0] pc_imm;
  logic [DW-1:0] w_j_data;
  logic [DW-1:0] w_auipc_data;
  logic [DW-1:0] w_lui_data;
  assign jump = ctrl.jalr_mode || ctrl.jal_mode;
  assign U_pc[0] = inst.uinst.opcode == OP_AUIPC;
  assign U_pc[1] = inst.uinst.opcode == OP_LUI;
  assign w_j_data = jump ? pc_4 : regf_wr_data;
  assign w_auipc_data = U_pc[0] ? pc_imm : w_j_data;
  assign w_lui_data = U_pc[1] ? imm_val : w_auipc_data;
  
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
    .wr_data  ( w_lui_data  )
  );

  immediate_generator
  #( .DW(DW) )
  immgen_inst
  (
    .inst ( inst    ),
    .imm  ( imm_val )
  );

  // Jump pc
  logic [AW-1:0] pc_jalr;
  logic [AW-1:0] pc_jal;
  adder #( .WD(AW) )
  jalradder
  (
    .a  (regf_dout1),
    .b  (imm_val),
    .y  (pc_jalr)
  );
  adder #( .WD(AW) )
  jaladder
  (
    .a  (pc),
    .b  (imm_val),
    .y  (pc_jal)
  );
  mux2 #( .WD(AW) )
  jalpc
  (
    .a  (pc_jal),
    .b  (pc_jalr),
    .s  (ctrl.jalr_mode),
    .y  (pc_imm)
  );
  // End jump pc

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
  assign WB_Data = alu_result;
  
  // Branch control
  logic [DW-1:0] imm_sft;
  assign imm_sft = imm_val << 1;
  logic [AW-1:0] pc_N;
  logic     bran_cont;
  assign bran_cont = alu_zero && ctrl.branch;
  
  adder #( .WD(AW) )
  pcadder
  (
    .a  (pc),
    .b  (imm_sft),
    .y  (pc_N)
  );
  
  logic [AW-1:0] pc_F;
  
  mux2 #( .WD(AW) )
  pcmux
  (
    .a  (pc_4),
    .b  (pc_N),
    .s  (bran_cont),
    .y  (pc_F)
  );
  
  // Jump control
  mux2 #( .WD(AW) )
  jmp_mux
  (
    .a  (pc_F),
    .b  (pc_imm),
    .s  (jump),
    .y  (pc_next)
  );
  
  // Data memory
  assign dmem_if.addr  = alu_result;
  assign dmem_if.wr    = ctrl.mem_write;
  assign dmem_if.wdata = regf_dout2;
 /*
  // Store data
  always_comb
	begin
	  case(inst.sinst.func3)
		3'b000: // SB
			dmem_if.wdata = {{24{regf_dout2[7]}}, regf_dout2[7:0]};
		3'b001: // SH
			dmem_if.wdata = {{16{regf_dout2[15]}}, regf_dout2[15:0]};
		3'b010: // SW
			dmem_if.wdata = regf_dout2;
	  default:
		dmem_if.wdata = regf_dout2; 
	endcase
  end
  
  data_memory dmem_inst(
	.clk(clk),
	.mem_if(dmem_if)
  );
  
  // Load data
  
  always_comb
	begin
	  case(inst.iinst.func3)
		3'b000: // LB
			r_data = {{24{dmem_if.rdata[31]}}, dmem_if.rdata[7:0]};
		3'b001: // LH
			r_data = {{16{dmem_if.rdata[31]}}, dmem_if.rdata[15:0]};
		3'b010: // LW
			r_data = dmem_if.rdata;
		3'b100: // LBU
			r_data = {24'b0, dmem_if.rdata[7:0]};
		3'b101: // LHU
			r_data = {16'b0, dmem_if.rdata[15:0]};
	  default:
		r_data = dmem_if.rdata; 
	endcase
  end
*/
endmodule:datapath
