module forwarding_unit
 (input logic[4:0] rs1,
  input logic[4:0] rs2,
  input logic[4:0] ex_mem_rd,
  input logic[4:0] mem_wb_rd,
  input logic ex_mem_rs,
  input logic mem_wb_rs,
  output logic[1:0] forward_a,
  output logic[1:0] forward_b
  );
  
  assign forward_a = ((ex_mem_rs) && (ex_mem_rd != 0) && (ex_mem_rd == rs1)) ? 2'b10 :
					 ((mem_wb_rs) && (mem_wb_rd != 0) && (mem_wb_rd == rs1)) ? 2'b01 : 2'b00;
  
  assign forward_b = ((ex_mem_rs) && (ex_mem_rd != 0) && (ex_mem_rd == rs2)) ? 2'b10 :
					 ((mem_wb_rs) && (mem_wb_rd != 0) && (mem_wb_rd == rs2)) ? 2'b01 : 2'b00;
  
 endmodule:forwarding_unit