import riscv_pachage::*;

module branch
    #(parameter DW = 32)
	(
		input logic alu_zero,
		input logic controller_branch,
		input logic [DW-1:0] shift_input,
		input logic [DW-1:0] pc_output,
		input logic [DW-1:0] adder_output,
		
		output logic [DW-1:0] mux_output
	);
	logic [DW-1:0] mux_input;
	assign shift_output = shift_input << 1;
	adder adder_l(
		.a (pc_output),
		.b (shift_output),
		.y (mux_input)
	);
	
	mux2 mux(
		.a (adder_output),
		.b (mux_input),
		.s (alu_zero & controller_branch),
		.y (mux_output)
	);
endmodule:branch