module dut_top( 
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
	    apb3_prdata	    	    	    
	);
	
	input logic clk;
	input logic rst_n;
	
	input logic apb3_pclk,
	input logic apb3_paddr,
	input logic apb3_pwrite,
	input logic apb3_psel,
	input logic apb3_penable,
	input logic apb3_pwdata,
    output logic apb3_pready,
	output logic apb3_pslverr,	    
	output logic apb3_prdata
	
	
endmodule