
module instruction_memory
  #(
    parameter AW =  9,
    parameter DW = 32
  )
  (
    input  logic          clk,
    input  logic          wr,
    input  logic [AW-1:0] addr,
    input  logic [DW-1:0] wdata,
    output logic [DW-1:0] rdata
  );

`ifdef __SIM__

  logic [DW-1:0] mem [2**AW];

  always_ff @(posedge clk) begin
    if(wr)
      mem[addr] <= wdata;
  end

  assign rdata = mem[addr];

`else

   SRAM1RW512x32 RAM (
         .A       ( addr   ),
         .CE      ( clk    ),
         .WEB     ( ~wr    ),
         .OEB     ( wr     ),
         .CSB     ( 1'b0   ),
         .I       ( wd     ),
         .O       ( rdi_en )
         );

`endif

endmodule:instruction_memory
