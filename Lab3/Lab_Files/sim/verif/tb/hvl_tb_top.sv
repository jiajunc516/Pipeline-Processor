`define HDL_TOP    hdl_tb_top.dut_inst
`define RISCV      `HDL_TOP.riscv_inst
`define DP         `RISCV.dp_inst
`define REGF       `DP.regf_inst
`define ALU        `DP.alu_inst
`define ALU_RESULT `RISCV.dp_inst.alu_inst.result
`define CLK        hdl_tb_top.dut_inst.clk
`define PC		   `RISCV.pc
`define DMEM	   `RISCV.dmem_inst
`define WB_Data		`REGF.wr_data

module hvl_tb_top();
  	string  test_machine_code_path = "$verif/test/bin/";
	string  binary_file_name = "inst.bin";
	integer score = 80;
	logic [31:0] temp;

	initial begin
		if($value$plusargs( "BIN=%s", binary_file_name )) begin
			
		end 
		$display("#################################");
		$display("This is HVL Top . . .");
		$display("Preloading instruction memory with %s/%s", test_machine_code_path, binary_file_name);
		$readmemb({test_machine_code_path, binary_file_name}, hdl_tb_top.dut_inst.riscv_inst.imem_inst.mem);



	//Branch delayed slot: 1
    @(posedge `CLK iff hdl_tb_top.dut_inst.rst_n == 1);
    //@(posedge hdl_tb_top.dut_inst.clk);
    @(posedge hdl_tb_top.dut_inst.clk);
    @(posedge hdl_tb_top.dut_inst.clk);
    @(posedge hdl_tb_top.dut_inst.clk);
    @(posedge hdl_tb_top.dut_inst.clk);

	if(`WB_Data	!== 32'd0) //andi
		begin
			score = score - 5;
			$display("andi is not working: The WB_data should be: %d, But you got: %d",32'd0,`WB_Data);
		end


	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd3) //xori
		begin
			score = score - 5;
			$display("xori is not working: The WB_data should be: %d, But you got: %d",32'd3,`WB_Data);
		end
		

	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd4) //xori
	    begin
			score = score - 5;
			$display("xori is not working: The WB_data should be: %d, But you got: %d",32'd4,`WB_Data);
		end

		
	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd1) //sub
		begin
			score = score - 5;
			$display("sub is not working: The WB_data should be: %d, But you got: %d",32'd1,`WB_Data);
		end

	
	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd7) //add
		begin
			score = score - 5;
			$display("add is not working: The WB_data should be: %d, But you got: %d",32'd7,`WB_Data);
		end


		
	@(posedge hdl_tb_top.dut_inst.clk);
	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd7) //lw
		begin
			score = score - 8;
			$display("lw/sw is not working: The WB_data should be: %d, But you got: %d",32'd7,`WB_Data);
		end



	@(posedge hdl_tb_top.dut_inst.clk);
	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd1) //slt
		begin
			score = score - 7;
			$display("slt is not working: The WB_Data should be: %d, But you got: %d",32'd1,`WB_Data);
		end


	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd7) //lw
		begin
			score = score - 8;
			$display("lw/sw is not working: The WB_Data should be: %d, But you got: %d",32'd7,`WB_Data);
		end
	

	if(`RISCV.pc !== 32'd48) //beq
		begin
			score = score - 9;
			$display("beq is not working: The PC should be: %d, But you got: %d",32'd48,`RISCV.pc);
		end


	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd0) //xori
		begin
			score = score - 5;
			$display("xori is not working: The WB_Data should be: %d, But you got: %d",32'd0,`WB_Data);
		end



	@(posedge hdl_tb_top.dut_inst.clk);
	@(posedge hdl_tb_top.dut_inst.clk);
	if(`WB_Data !== 32'd0) //xori
		begin
			score = score - 5;
			$display("xori is not working: The WB_Data should be: %d, But you got: %d",32'd0,`WB_Data);
		end

		
	if(`RISCV.pc !== 32'd0) //jalr
		begin
			score = score - 8;
			$display("beq is not working: The PC should be: %d, But you got: %d",32'd0,`RISCV.pc);
		end

	
	$display("The total score is: %d",score);
	
	#100ns;
	$stop;



   end
endmodule
















