module HarzardDetection
	(input logic[4:0] if_id_rs1,
	 input logic[4:0] if_id_rs2,
	 input logic[4:0] id_ex_rd,
	 input logic id_ex_MemRead,
	 output logic stall
	);
	
	assign stall = (id_ex_MemRead && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)))? 1: 0;
endmodule: HarzardDetection