
`include "pipeline_reg.sv"
import riscv_package::*;

module datapath
  #(
    parameter PC_W = 9,
    parameter RF_ADDR = 5,
    parameter DW = 32,
    parameter DM_ADDR = 9,
	parameter AW = 32 //added here
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

  logic [PC_W-1:0] pc_4, pc_next;
  logic [DW-1:0] aluop1, aluop2, alu_result;
  logic [DW-1:0] regf_dout1, regf_dout2;
  logic [RF_ADDR-1:0] regf_wr_addr;
  logic [RF_ADDR-1:0] regf_rd_addr1, regf_rd_addr2;
  logic [DW-1:0] regf_wr_data;
  logic [DW-1:0] imm_val;
  logic [DW-1:0] br_pc;
  logic regf_wr_en;
  logic pc_sel, reg_stall;

  IF_ID_REG A;
  ID_EX_REG B;
  EX_MEM_REG C;
  MEM_WB_REG D;

  // next pc
  adder #(PC_W) pcadd(pc, 9'b100, pc_4);
  mux2 #(PC_W) pcmux(pc_4, br_pc[PC_W-1:0], pc_sel, pc_next);
  
  program_counter
  #(.AW(PC_W))
  pc_inst
  ( .clk    ( clk   ),
    .rst_n  ( rst_n ),
    .enable ( reg_stall  ),
    .din    ( pc_next ),
    .pc     ( pc      )
  );

  // IF_ID_REG
  always @(posedge clk)
  begin
    if ((rst_n) || pc_sel))
    begin
        A.curr_pc <= 0;
        A.curr_instr <= 0;
    end
    else if (!reg_stall)
    begin
        A.curr_pc <= pc;
        A.curr_instr <= inst;
    end
  end

  // hazard detection unit
  assign regf_wr_en   = D.RegWrite;
  assign regf_wr_addr = D.rd;
  assign regf_rd_addr1 = A.curr_instr[19:15];
  assign regf_rd_addr2 = A.curr_instr[24:20];
  
  //HarzardDetection detect(regf_rd_addr1, regf_rd_addr2, B.rd, B.MemRead, reg_stall);
  
  // register file
  register_file
  #( .AW(5), .DW(DW))
  regf_inst
  (
    .clk      ( clk            ),
    .rst_n    ( rst_n          ),
    .rd_addr1 ( regf_rd_addr1 ),
    .rd_addr2 ( regf_rd_addr2 ),
    .rd_data1 ( regf_dout1     ),
    .rd_data2 ( regf_dout2     ),
    .wr_en    ( regf_wr_en     ),
    .wr_addr  ( regf_wr_addr   ),
    .wr_data  ( regf_wr_data  )
  );

  // sign extend
  immediate_generator
  #( .DW(DW) )
  immgen_inst
  (
    .inst ( A.curr_instr    ),
    .imm  ( imm_val )
  );

  // ID_EX_REG
  always @(posedge clk)
  begin
    if ((rst_n) || (reg_stall) || (pc_sel))
	begin
		B.curr_pc <= 0;
		B.rdata1 <= 0;
		B.rdata2 <= 0;
		B.imm_value <= 0;
		B.rs1 <= 0;
		B.rs2 <= 0;
		B.rd <= 0;
		B.func3 <= 0;
		B.func7 <= 0;
		B.ALUSrc <= 0;
		B.MemtoReg <= 0;
		B.RegWrite <= 0;
		B.MemRead <= 0;
		B.MemWrite <= 0;
		B.rw_sel <= 0;
		B.ALUOp <= 0;
		B.branch <= 0;
		B.Jalr_or_Jal <= 0;	
		B.curr_instr <= A.curr_instr;
	end
	else
	begin
		B.curr_pc <= A.curr_pc;
		B.rdata1 <= regf_dout1;
		B.rdata2 <= regf_dout2;
		B.imm_value <= imm_val;
		B.rs1 <= regf_rd_addr1;
		B.rs2 <= regf_rd_addr2;
		B.rd <= A.curr_instr[11:7];
		B.func3 <= A.curr_instr[14:12];
		B.func7 <= A.curr_instr[31:25];
		B.ALUSrc <= ctrl.alu_src;
		B.MemtoReg <= ctrl.mem2reg;
		B.RegWrite <= ctrl.reg_write;
		B.MemRead <= ctrl.mem_read;
		B.MemWrite <= ctrl.mem_write;
		B.rw_sel <= 0;
		B.ALUOp <= ctrl.aluop;
		B.branch <= ctrl.branch;
		B.Jalr_or_Jal <= 0;	
		B.curr_instr <= A.curr_instr;
	end
  end
  
  // forwarding unit
  
  // alu
  
  // EX_MEM_REG
  
  // data memory
  
  // MEM_WB_REG
  
  // last block

  // J-type or U-type
  logic jump;
  logic [1:0] U_pc;
  logic [AW-1:0] pc_imm;
  logic [DW-1:0] w_j_data;
  logic [DW-1:0] w_auipc_data;
  logic [DW-1:0] w_lui_data;
  assign jump = ctrl.jalr_mode || ctrl.jal_mode;
  assign U_pc[0] = (inst.uinst.opcode == OP_AUIPC);
  assign U_pc[1] = (inst.uinst.opcode == OP_LUI);
  assign w_j_data = jump ? pc_4 : regf_wr_data;
  assign w_auipc_data = U_pc[0] ? pc_imm : w_j_data;
  assign w_lui_data = U_pc[1] ? imm_val : w_auipc_data;

  

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
    .a  (pc_1),
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
  //assign dmem_if.wdata = regf_dout2;

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

endmodule:datapath
