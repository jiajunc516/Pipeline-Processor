module hvl_tb_top();
  	string  test_machine_code_path = "$verif/test/bin/";
	string  binary_file_name = "inst.bin";
	initial begin
		if($value$plusargs( "BIN=%s", binary_file_name )) begin
			
		end 
		$display("#################################");
		$display("This is HVL Top . . .");
		$display("Preloading instruction memory with %s/%s", test_machine_code_path, binary_file_name);
		$readmemb({test_machine_code_path, binary_file_name}, hdl_tb_top.dut_inst.riscv_inst.imem_inst.mem);
		#100ns;
		$finish;
	end
endmodule
