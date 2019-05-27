import riscv_package::*;

module controlpath (
    input riscv_inst32_t inst,
    controller_if.out ctrl
  );

  always_comb begin

        ctrl.alu_src = {
      ( inst.rinst.opcode == OP_LOAD   ||
        inst.rinst.opcode == OP_STORE  ||
        inst.rinst.opcode == OP_OP_IMM ||
        inst.rinst.opcode == OP_JALR   ||
        inst.rinst.opcode == OP_LUI) 
    };


    case( inst.rinst.opcode )
      OP_LOAD , OP_LOAD_FP : ctrl.mem2reg = 1'b1;
      //OP_AUIPC             : ctrl.mem2reg = 2'b10;
      //OP_JAL  , OP_JALR    : ctrl.mem2reg = 2'b11;
      default:
        ctrl.mem2reg = 1'b0;
    endcase

    case( inst.rinst.opcode )
      OP_LOAD, OP_OP_IMM, OP_OP, OP_JAL, OP_LUI, OP_AUIPC, OP_JAL : ctrl.reg_write = 1'b1;
      default:
        ctrl.reg_write = 1'b0;
    endcase

    ctrl.mem_read  = (inst.rinst.opcode == OP_LOAD);
    ctrl.mem_write = (inst.rinst.opcode == OP_STORE);

    case( inst.rinst.opcode )
      OP_BRANCH : ctrl.aluop = 2'b01;
      OP_LUI    : ctrl.aluop = 2'b11;
      OP_AUIPC  : ctrl.aluop = 2'b11;
      OP_JAL    : ctrl.aluop = 2'b11;
      OP_OP     : ctrl.aluop = 2'b10;
      OP_OP_IMM : ctrl.aluop = 2'b10;
      default:
        ctrl.aluop = 2'b00;
    endcase

    ctrl.branch    = (inst.rinst.opcode == OP_BRANCH);
    ctrl.jalr_mode = (inst.rinst.opcode == OP_JALR);
    ctrl.jal_mode  = (inst.rinst.opcode == OP_JAL);

  end
endmodule:controlpath

