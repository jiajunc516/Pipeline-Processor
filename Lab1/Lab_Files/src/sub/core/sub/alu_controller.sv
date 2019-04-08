
import riscv_package::*;

module alu_controller(

    //inputs
    input logic [1:0] aluop,  //7-bit opcode field from the instruction
    input logic [6:0] funct7, // bits 25 to 31 of the instruction
    input logic [2:0] funct3, // bits 12 to 14 of the instruction

    //output
    output alu_operation_e operation, //operation selection for alu
    output logic cont_beq,
    output logic cont_bnq,
    output logic cont_blt,
    output logic cont_bgt,
    output logic [2:0] readdatasel,
    output logic [1:0] writedatasel
  );

  logic cont_lb_sb, cont_lh_sh, cont_lbu, cont_lhu;

  assign operation[0]= (((aluop == 2'b10)  && ((funct3==3'b110) || (funct3==3'b001) || (funct3==3'b100) || (funct7 == 7'b0000000 && (funct3==3'b101)) || (funct3==3'b011)))   ||
                       ( (aluop == 2'b01 ) && ((funct3==3'b110) || (funct3==3'b111) ) ) );
  assign operation[1]= (   ((aluop ==2'b10) &&    ( (funct3==3'b000)||(funct3==3'b001)||(funct3==3'b100) ) ) ||
      ((aluop ==2'b00) && ((funct3==3'b000) || (funct3==3'b001) || (funct3==3'b100) || (funct3==3'b101) || (funct3==3'b010)) ) ||
      ((aluop==2'b01) && ((funct3==3'b000) || (funct3==3'b001) || (funct3==3'b111) || (funct3==3'b101))) ||
      (aluop==2'b11));
  assign operation[2]=  (    ( (aluop ==2'b10) &&   (( funct7 == 7'b0100000  &&  (funct3==3'b000)) || (funct3==3'b100) ||(funct3==3'b101)        )        ) ||
      (    (aluop ==2'b01) &&    (    (funct3==3'b000) || (funct3==3'b001)    )  ));
  assign operation[3]= (( (aluop ==2'b10) && ((funct3==3'b010) || (funct3==3'b011)  )  ) ||
      ( (aluop ==2'b01) && ( (funct3==3'b100) || (funct3==3'b101) || (funct3==3'b110) || (funct3==3'b111) )));


  assign cont_beq = ( (aluop ==2'b01) && (funct3==3'b000) );
  assign cont_bnq = ( (aluop ==2'b01) && (funct3==3'b001) );
  assign cont_blt = ( (aluop ==2'b01) && ( (funct3==3'b100) || (funct3==3'b110) ) );
  assign cont_bgt = ( (aluop ==2'b01) && ( (funct3==3'b101) || (funct3==3'b111) ) );

  assign cont_lb_sb  = ( (aluop ==2'b00) && (funct3==3'b000) );
  assign cont_lh_sh  = ( (aluop ==2'b00) && (funct3==3'b001) );
  assign cont_lbu    = ( (aluop ==2'b00) && (funct3==3'b100) );
  assign cont_lhu    = ( (aluop ==2'b00) && (funct3==3'b101) );

  assign readdatasel  = ( cont_lb_sb ? 3'b001 :(cont_lh_sh ? 3'b010 : (cont_lbu ? 3'b011 : (cont_lhu ? 3'b100 : 3'b000))) );
  assign writedatasel = ( cont_lb_sb ? 2'b01 : (cont_lh_sh ? 2'b10 : 2'b00));

endmodule:alu_controller
