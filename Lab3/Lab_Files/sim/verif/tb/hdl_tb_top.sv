
module hdl_tb_top;

//clock and reset signal declaration
  logic tb_clk, reset;
  
    //clock generation
  always begin
    #1 tb_clk = ~tb_clk;
  end
  
  //reset Generation
  // FIXME: Nee9d clock & reset agents
  initial begin
    tb_clk = 0;
    reset  = 0;
    repeat(2) @(posedge tb_clk);
    reset  = 1;
  end
  
  
  design_top dut_inst(
      .clk(tb_clk),
      .rst_n(reset)
     );
endmodule
