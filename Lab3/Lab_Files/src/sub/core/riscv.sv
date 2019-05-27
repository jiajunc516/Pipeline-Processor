
import riscv_package::*;

module riscv
  #(
    CORES = 1,
    DATA_WIDTH = 32,
    ADDR_WIDTH = 32
  )
  (
    input logic clk,
    input logic rst_n
  // Register Interface
  // Interconnect Interface
  // Debug Interface
  );

  /* local definitions*/
  logic [ADDR_WIDTH-1:0] pc;
  riscv_inst32_t         inst;
  controller_if          ctrl_if();
  memory_if              dmem_if();

  instruction_memory
  #()
  imem_inst(
    .clk   ( clk     ),
    .addr  ( pc      ),
    .rdata ( inst    ),
    .wr    ( 1'b0    ),
    .wdata ( )
  );

  controlpath cp_inst(
    .inst ( inst    ),
    .ctrl ( ctrl_if )
  );

  datapath
  #(.AW(ADDR_WIDTH))
  dp_inst (
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .pc      ( pc      ),
    .inst    ( inst    ),
    .ctrl    ( ctrl_if ),
    .dmem_if ( dmem_if )
  );

//  data_memory
//  #()
//  dmem_inst(
//    .clk    ( clk ),
//	.func3  (inst.iinst.func3),
//    .mem_if ( dmem_if  )
//  );

endmodule:riscv
