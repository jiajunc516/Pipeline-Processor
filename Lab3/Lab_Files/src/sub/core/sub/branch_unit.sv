module BranchUnit
	#(parameter PW = 9)
	(input logic [PW-1:0] curr_pc,
	 input logic [31:0] imm_value,
	 input logic [31:0] alu_result,
	 input logic jalr_sel,
	 input logic branch_sel,

	 output logic [31:0] pc_imm,
	 output logic [31:0] pc_4,
	 output logic [31:0] pc_branch, 
	 output logic pc_sel
	 );
	 
	 logic [31:0] pc_jal;
	 logic [31:0] pc_jalr;
	 logic [31:0] pc_32;
	 
	 assign pc_32 = {23'b0, curr_pc};
	 assign pc_imm = pc_32 + imm_value;
	 assign pc_4 = pc_32 + 32'b100;
	 
	 assign pc_branch = (jalr_sel) ? alu_result : (branch_sel) ? pc_imm : 32'b0;
	 assign pc_sel = jalr_sel || branch_sel;
	 
endmodule:BranchUnit