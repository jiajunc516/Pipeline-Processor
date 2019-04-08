
module register_file
  #(
    parameter AW =  5,
    parameter DW = 32
  )
  (
    input logic           clk,
    input logic           rst_n,
    input logic           wr_en,
    input logic  [AW-1:0] wr_addr,
    input logic  [DW-1:0] wr_data,
    input logic  [AW-1:0] rd_addr1,
    input logic  [AW-1:0] rd_addr2,
    output logic [DW-1:0] rd_data1,
    output logic [DW-1:0] rd_data2
    );

  logic [DW-1:0] regmem [2**AW-1:0];

  assign rd_data1 = regmem[rd_addr1];
  assign rd_data2 = regmem[rd_addr2];

  always_ff @(posedge clk)
    begin
      if(~rst_n)
        for(int i=0; i<2**AW; i=i+1)
          regmem[i] = '0;
      else if (wr_en)
        regmem[wr_addr] = wr_data;
    end

endmodule:register_file
