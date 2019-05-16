`timescale 1ns / 1ps

module tb_top;

//clock and reset signal declaration
  logic tb_clk, reset;
  logic [31:0] tb_WB_Data;
  logic [31:0] temp;
  
    //clock generation
  always begin
  #10 tb_clk = ~tb_clk;
  end
  
  //reset Generation
  initial begin
    tb_clk = 0;
    reset = 0;
  end
  
  
  riscv riscV(
      .clk(tb_clk),
      .rst_n(reset),
      .WB_Data(tb_WB_Data)      
     );
	
  
  initial begin
	$readmemb ( "$verif/program/inst.bin" , riscV.imem_inst.mem);
	reset = 1;
	@(posedge tb_clk);
	reset = 0;
	@(posedge tb_clk);
	if(riscV.dp_inst.alu_inst.result !== (riscV.dp_inst.regf_dout1+4))
		begin
			
			$display("addi r2,r0,4 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,4);
		end
	@(posedge tb_clk);
	
	if(tb_WB_Data !== (riscV.dp_inst.regf_dout1>>1))
		begin
			
			$display("SRAI r1,r2,1 is wrong. Your output: %d The correct output: %d",tb_WB_Data ,2);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== (riscV.dp_inst.regf_dout1|riscV.dp_inst.regf_dout2))
		begin
			
			$display("OR r3,r2,r1 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,6);
		end
	@(posedge tb_clk);
	
	if(tb_WB_Data !== 32'd12)
		begin
			
			$display("AUIPC r6,0 is wrong. Your output: %d The correct output: %d",tb_WB_Data, 12);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== (riscV.dp_inst.regf_dout1+riscV.dp_inst.regf_dout2))
		begin
			
			$display("ADD r5,r2,r3 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,10);
		end
	@(posedge tb_clk);
	
	if(tb_WB_Data!== (riscV.dp_inst.regf_dout1>>1))
		begin
			
			$display("SRLI  r4,r2,1 is wrong. Your output: %d The correct output: %d",tb_WB_Data,2);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== (~(riscV.dp_inst.regf_dout1 |riscV.dp_inst.regf_dout2)))
		begin
			
			$display("NOR r7,r2,r5 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result, 14);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== (riscV.dp_inst.regf_dout1&riscV.dp_inst.regf_dout2))
		begin
			
			$display("AND r9,r4,r2 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,0);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== (riscV.dp_inst.regf_dout1-riscV.dp_inst.regf_dout2))
		begin
			
			$display("SUB r10,r8,r7 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,-14);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== (riscV.dp_inst.regf_dout1&10))
		begin
			
			$display("ANDi r11, r6,10 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,8);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== (riscV.dp_inst.regf_dout1|10))
		begin
			
			$display("ORi r12,r6,10 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,14);
		end
	@(posedge tb_clk);
	
	if(tb_WB_Data !== (riscV.dp_inst.regf_dout1<<riscV.dp_inst.regf_dout2))
		begin
			
			$display("SLL r13,r5,r8 is wrong. Your output: %d The correct output: %d",tb_WB_Data,10);
		end
	@(posedge tb_clk);
	
	if(tb_WB_Data !== (riscV.dp_inst.regf_dout1<<3))
		begin
			
			$display("SLLI r14,r5,3 is wrong. Your output: %d The correct output: %d",tb_WB_Data,80);
		end
	@(posedge tb_clk);
	
	if(tb_WB_Data != -14)
		begin
			
			$display("SRA  r15,r10,r8 is wrong. Your output: %d The correct output: %d",tb_WB_Data,(-14));
		end
	@(posedge tb_clk);
	
	if(tb_WB_Data !== (riscV.dp_inst.regf_dout1>>>riscV.dp_inst.regf_dout2))
		begin
			
			$display("SRL r16,r10,r8 is wrong. Your output: %d The correct output: %d",tb_WB_Data,-14);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== 1)
		begin
			
			$display("SLTI r17,r10,4 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,32'd1);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.alu_inst.result !== 0)
		begin
			
			$display("SLT r19,r2,r10 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,0);
		end
	@(posedge tb_clk);
	
	temp = riscV.dp_inst.regf_inst.regmem[3];
	if(riscV.dp_inst.alu_inst.result != (32'd352))
		begin
			
			$display("sw r3,r0,352 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.alu_inst.result,(32'd352));
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.dmem_if.rdata !== (temp))
		begin
			
			$display("lw r13,r0,352 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.dmem_if.rdata,6);
		end
	@(posedge tb_clk);
	
	if(riscV.dp_inst.dmem_if.rdata !== (temp[7:0]))
		begin
			
			$display("lb r13,r0,352 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.dmem_if.rdata,6);
		end
	@(posedge tb_clk);
	
	if (riscV.dp_inst.regf_dout1 === riscV.dp_inst.regf_dout2) //branch taken
		begin
			@(posedge tb_clk);
			
			if(riscV.dp_inst.pc !== 32'd88)
				begin
					
					$display("BEQ r7,r14,8 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.pc,32'd88);
				end
			@(posedge tb_clk);
			@(posedge tb_clk);
			@(posedge tb_clk);
			if(riscV.dp_inst.pc !== 32'd104)
				begin
					
					$display("JAL r25,8 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.pc,32'd104);
				end
			
		end
	else //branch not taken
		begin
			@(posedge tb_clk);
			if(riscV.dp_inst.pc !== 32'd84)
				begin
					
					$display("BNE r7,r14,8 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.pc,32'd84);
				end
			@(posedge tb_clk);
			@(posedge tb_clk);
			@(posedge tb_clk);
			@(posedge tb_clk);
			if(riscV.dp_inst.pc !== 32'd104)
				begin
					
					$display("JAL r25,8 is wrong. Your output: %d The correct output: %d",riscV.dp_inst.pc,32'd104);
				end
		end


	
	$stop;
   end
endmodule
