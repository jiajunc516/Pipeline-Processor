interface memory_if();
  parameter DW = 32;
  parameter AW =  9;

  logic          wr;
  logic [AW-1:0] addr;
  logic [DW-1:0] wdata;
  logic [DW-1:0] rdata;
  logic    [2:0] byte_m1; // Valid Number of Bytes minus 1

  modport slave(
    input  wr,
    input  addr,
    input  wdata,
	input byte_m1,
    output rdata
    );

  modport master(
    output  wr,
    output  addr,
    output  wdata,
	output byte_m1,
    input   rdata
  );
endinterface: memory_if
