module design_top
	#(
		CORES = 1,
		DATA_WIDTH = 32,
		ADDR_WIDTH = 32
	)
(
    clk,
    rst_n,

    apb3_pclk,
    apb3_pready,
    apb3_pslverr,
    apb3_paddr,
    apb3_pwrite,
    apb3_psel,
    apb3_penable,
    apb3_pwdata,
    apb3_prdata,
	
	addr,
	data,
	valid,
	
	wb_addr,
	wb_data,
	wb_en
  );

  input logic clk;
  input logic rst_n;

  input logic apb3_pclk;
  input logic apb3_paddr;
  input logic apb3_pwrite;
  input logic apb3_psel;
  input logic apb3_penable;
  input logic apb3_pwdata;
  output logic apb3_pready;
  output logic apb3_pslverr;
  output logic apb3_prdata;
  
  output logic [5-1:0] wb_addr;
  output logic [DATA_WIDTH-1:0] wb_data;
  output logic wb_en;
  
  input logic [31:0] addr;
  input logic [31:0] data;
  input logic valid;


riscv #() riscv_inst(
  .*
  /* .* is equivalant to the following  */
  //.clk (clk),
  //.rst_n (rst_n)
  );


endmodule
