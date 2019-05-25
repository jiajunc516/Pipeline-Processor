module BranchUnit
	#(parameter PW = 9)
	(input logic [PW-1:0] pc_input,
	 input logic [31:0] imm_value,
	 input logic [31:0] regf_dout1,
	 input logic jalr_mode,
	 input logic branch_sel,
	 //input logic alu_zero, //changed from logic[31:0] alu_out to alu_zero
	 output logic [31:0] pc_imm,
	 output logic [31:0] pc_4,
	// output logic pc_branch, 
	 output logic pc_sel);
	 
	 logic [31:0] pc_jal;
	 logic [31:0] pc_jalr;
	 logic [31:0] pc_32;
	 
	 assign pc_32 = {23'b0, pc_input};	 
	 
	 assign pc_jal = pc_32 + imm_value;
	 assign pc_jalr = regf_dout1 + imm_value;

	 assign pc_imm = jalr_mode ? pc_jalr : pc_jal;
	 assign pc_4 = pc_32 + 32'b100;
	 assign pc_sel = jalr_mode || branch_sel;
	// assign branch_sel  = branch && alu_zero;
	 
endmodule:BranchUnit