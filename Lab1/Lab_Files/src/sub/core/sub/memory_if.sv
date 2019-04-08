interface memory_if();
  parameter DW = 32;
  parameter AW =  9;

  logic          wr;
  logic [AW-1:0] addr;
  logic [DW-1:0] wdata;
  logic [DW-1:0] rdata;

  modport master(
    input  wr,
    input  addr,
    input  wdata,
    output rdata
    );

  modport slave(
    output  wr,
    output  addr,
    output  wdata,
    input   rdata
  );
endinterface: memory_if
