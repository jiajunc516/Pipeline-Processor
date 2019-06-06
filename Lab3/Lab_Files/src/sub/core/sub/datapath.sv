
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
    output logic [ 5-1:0]  wb_addr,
    output logic [DW-1:0]  wb_data,
    output logic           wb_en
  );

  logic [PC_W-1:0] cur_pc, pc_4, pc_next;
  logic [DW-1:0] alu_result;
  logic [DW-1:0] regf_dout1, regf_dout2;
  logic [RF_ADDR-1:0] regf_wr_addr;
  logic [RF_ADDR-1:0] regf_rd_addr1, regf_rd_addr2;
  //logic [DW-1:0] regf_wr_data;
  logic [DW-1:0] ReadData;
  logic [DW-1:0] imm_val;
  logic [DW-1:0] br_imm, br_pc, old_pc_4;
  logic regf_wr_en;
  logic pc_sel, reg_stall;
  logic [1:0] RWsel;
  logic [1:0] FA_sel;
  logic [1:0] FB_sel;
  logic [DW-1:0] FA_result;
  logic [DW-1:0] FB_result;
  logic [DW-1:0] wr_mux_result, wr_mux_src;
  logic [DW-1:0] alu_operand_b;

  IF_ID_REG A;
  ID_EX_REG B;
  EX_MEM_REG C;
  MEM_WB_REG D;

  // next pc
  adder #(PC_W) pcadd(cur_pc, 9'b001, pc_4); // Byte - 9'b100, Line - 9'b001
  mux2 #(PC_W) pcmux(pc_4, br_pc[PC_W-1:0], pc_sel, pc_next);
  
  program_counter
  #(.AW(PC_W))
  pc_inst
  ( .clk    ( clk   ),
    .rst_n  ( rst_n ),
    .stall ( reg_stall  ),
    .din    ( pc_next ),
    .pc     ( cur_pc      )
  );
  assign pc = cur_pc;
  
  // IF_ID_REG
  assign RWsel[0] = (ctrl.jalr_mode || ctrl.jal_mode || (inst.rinst.opcode == OP_AUIPC));
  assign RWsel[1] = ((inst.rinst.opcode == OP_LUI) || (inst.rinst.opcode == OP_AUIPC));
  
  always @(posedge clk)
  begin
    if ((!rst_n) || (pc_sel))
    begin
        A.curr_pc <= 0;
        A.curr_instr <= 0;
		A.ALUSrc <= 0;
		A.MemtoReg <= 0;
        A.RegWrite <= 0;
        A.MemRead <= 0;
        A.MemWrite <= 0;
        A.rw_sel <= 0;
        A.ALUOp <= 0;
        A.branch <= 0;
        A.jalr_sel <= 0;   
    end
    else if (!reg_stall)
	begin
        A.curr_pc <= cur_pc;
        A.curr_instr <= inst;
		A.ALUSrc <= ctrl.alu_src;
		A.MemtoReg <= ctrl.mem2reg;
        A.RegWrite <= ctrl.reg_write;
        A.MemRead <= ctrl.mem_read;
        A.MemWrite <= ctrl.mem_write;
        A.rw_sel <= RWsel;
        A.ALUOp <= ctrl.aluop;
        A.branch <= ctrl.branch || ctrl.jal_mode;
        A.jalr_sel <= ctrl.jalr_mode;  
    end
  end

  
  // hazard detection unit
  //assign regf_wr_en   = D.RegWrite;
  //assign regf_wr_addr = D.rd;
  //assign regf_rd_addr1 = A.curr_instr[19:15];
  //assign regf_rd_addr2 = A.curr_instr[24:20];
  
  HazardDetection detect(A.curr_instr[19:15], A.curr_instr[24:20], B.rd, B.MemRead, reg_stall);
 
  assign wb_addr = D.rd;
  assign wb_en = D.RegWrite;
 
  // register file
  register_file
  #( .AW(5), .DW(DW))
  regf_inst
  (
    .clk      ( clk            ),
    .rst_n    ( rst_n          ),
    .rd_addr1 ( A.curr_instr[19:15] ),
    .rd_addr2 ( A.curr_instr[24:20] ),
    .rd_data1 ( regf_dout1     ),
    .rd_data2 ( regf_dout2     ),
    .wr_en    ( D.RegWrite     ),
    .wr_addr  ( D.rd   ),
    .wr_data  ( wr_mux_result  )
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
    if ((!rst_n) || (reg_stall) || (pc_sel))
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
        B.jalr_sel <= 0;    
        B.curr_instr <= A.curr_instr;
    end
    else
    begin
        B.curr_pc <= A.curr_pc;
        B.rdata1 <= regf_dout1;
        B.rdata2 <= regf_dout2;
        B.imm_value <= imm_val;
        B.rs1 <= A.curr_instr[19:15];
        B.rs2 <= A.curr_instr[24:20];
        B.rd <= A.curr_instr[11:7];
        B.func3 <= A.curr_instr[14:12];
        B.func7 <= A.curr_instr[31:25];
        B.ALUSrc <= A.ALUSrc;
        B.MemtoReg <= A.MemtoReg;
        B.RegWrite <= A.RegWrite;
        B.MemRead <= A.MemRead;
        B.MemWrite <= A.MemWrite;
        B.rw_sel <= A.rw_sel;
        B.ALUOp <= A.ALUOp;
        B.branch <= A.branch;
        B.jalr_sel <= A.jalr_sel;   
        B.curr_instr <= A.curr_instr;
    end
  end
  
  // forwarding unit
  forwarding_unit forwrdunit(B.rs1, B.rs2, C.rd, D.rd, C.RegWrite, D.RegWrite, FA_sel, FB_sel);
  
  // alu
  mux4 #(DW) FAmux(B.rdata1, wr_mux_result, C.alu_result, B.rdata1, FA_sel, FA_result);
  mux4 #(DW) FBmux(B.rdata2, wr_mux_result, C.alu_result, B.rdata2, FB_sel, FB_result);
  mux2 #(DW) srcbmux(FB_result, B.imm_value, B.ALUSrc, alu_operand_b);
  
  alu_operation_e  operation;
  logic       cont_beq;
  logic       cont_bnq;
  logic       cont_blt;
  logic       cont_bgt;
  logic [2:0] readdatasel;
  logic [1:0] writedatasel;
  alu_controller aluc_inst(
    .*,
    .aluop  ( B.ALUOp ),
    .funct3 ( B.func3 ),
    .funct7 ( B.func7 )
  );
  
  logic       alu_zero;
  alu
  #()
  alu_inst
  (
    .operand_a ( FA_result    ),
    .operand_b ( alu_operand_b    ),
    .operation ( operation ),
    .branch    ( alu_zero ),
    .result    ( alu_result )
  );
  
  // branch
  logic Bran_sel;
  assign Bran_sel = B.branch && alu_zero;
  
  BranchUnit #(PC_W) branchunit
  (
    .curr_pc ( B.curr_pc ),
    .imm_value ( B.imm_value ),
    .alu_result ( alu_result ),
    .jalr_sel ( B.jalr_sel ),
    .branch_sel ( Bran_sel ),
    .pc_imm ( br_imm ),
    .pc_4 ( old_pc_4 ),
    .pc_branch ( br_pc ), 
    .pc_sel ( pc_sel )
  );
  
  // EX_MEM_REG
  always @(posedge clk)
  begin
    if (!rst_n)
    begin
        C.pc_imm <= 0;
        C.pc_4 <= 0;
        C.alu_result <= 0;
        C.imm_value <= 0;
        C.rdata2 <= 0;
        C.rd <= 0;
        C.func3 <= 0;
        C.func7 <= 0;
        C.rw_sel <= 0;
        C.RegWrite <= 0;
        C.MemRead <= 0;
        C.MemWrite <= 0;
        C.MemtoReg <= 0;
        C.curr_instr <= 0;
    end
    else
    begin
        C.pc_imm <= br_imm;
        C.pc_4 <= old_pc_4;
        C.alu_result <= alu_result;
        C.imm_value <= B.imm_value;
        C.rdata2 <= FB_result;
        C.rd <= B.rd;
        C.func3 <= B.func3;
        C.func7 <= B.func7;
        C.rw_sel <= B.rw_sel;
        C.RegWrite <= B.RegWrite;
        C.MemRead <= B.MemRead;
        C.MemWrite <= B.MemWrite;
        C.MemtoReg <= B.MemtoReg;
        C.curr_instr <= B.curr_instr;
    end
  end
  
  // data memory
  assign dmem_if.wr    = C.MemWrite;
  assign dmem_if.addr  = C.alu_result[DM_ADDR-1:0];
  assign dmem_if.wdata = C.rdata2;
  assign dmem_if.byte_m1 = C.func3;
  //data_memory #(.AW(DM_ADDR), .DW(DW)) data_mem(clk, C.func3, dmem_if, ReadData);
  
  // MEM_WB_REG
  always @(posedge clk)
  begin
    if (!rst_n)
    begin
        D.pc_imm <= 0;
        D.pc_4 <= 0;
        D.mem_read_data <= 0;
        D.alu_result <= 0;
        D.imm_value <= 0;
        D.rd <= 0;
        D.rw_sel <= 0;
        D.RegWrite <= 0;
        D.MemtoReg <= 0;
        D.curr_instr <= 0;
    end
    else
    begin
        D.pc_imm <= C.pc_imm;
        D.pc_4 <= C.pc_4;
        D.mem_read_data <= dmem_if.rdata;
        D.alu_result <= C.alu_result;
        D.imm_value <= C.imm_value;
        D.rd <= C.rd;
        D.rw_sel <= C.rw_sel;
        D.RegWrite <= C.RegWrite;
        D.MemtoReg <= C.MemtoReg;
        D.curr_instr <= C.curr_instr;
    end
  end
  
  // last block
  mux2 #(32) resmux(D.alu_result, D.mem_read_data, D.MemtoReg, wr_mux_src);
  mux4 #(32) wrsmux(wr_mux_src, D.pc_4, D.imm_value, D.pc_imm, D.rw_sel, wr_mux_result);
  
  assign wb_data = wr_mux_result;

endmodule:datapath
