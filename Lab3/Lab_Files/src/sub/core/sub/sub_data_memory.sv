module sub_data_memory
  #(
    parameter AW =  9,
    parameter DW =  8
  )
  (
    input  logic          clk,
    memory_if.slave       mem_if
  );

`ifndef __SIM__

  logic [DW-1:0] mem [2**AW];

  always_ff @(posedge clk) begin
    if(mem_if.wr)
      mem[mem_if.addr] <= mem_if.wdata;
  end

  assign    mem_if.rdata = mem[mem_if.addr];

`else

   SRAM1RW512x8 RAM (
         .A       ( mem_if.addr   ),
         .CE      ( clk           ),
         .WEB     ( ~mem_if.wr    ),
         .OEB     ( mem_if.wr     ),
         .CSB     ( 1'b0          ),
         .I       ( mem_if.wdata  ),
         .O       ( mem_if.rdata  )
         );        
         
`endif


endmodule:sub_data_memory