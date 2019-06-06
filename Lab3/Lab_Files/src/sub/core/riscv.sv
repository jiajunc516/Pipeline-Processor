
import riscv_package::*;

module riscv
  #(
    CORES = 1,
    DATA_WIDTH = 32,
    ADDR_WIDTH = 32
  )
  (
    input logic clk,
    input logic rst_n,
  // Register Interface
    input logic [31:0] addr  ,
    input logic [31:0] data  ,
    input logic        valid , 
  // Interconnect Interface
  // Debug Interface
    output logic [         5-1:0] wb_addr,
    output logic [DATA_WIDTH-1:0] wb_data,
    output logic                  wb_en
  );

  /* local definitions*/
  logic [ADDR_WIDTH-1:0] pc;
  logic [ADDR_WIDTH-1:0] imem_addr;
  riscv_inst32_t         inst;
  controller_if          ctrl_if();
  memory_if              dmem_if();

  assign imem_addr = valid ? addr : pc;
  
  instruction_memory
  #()
  imem_inst(
    .clk   ( clk     ),
    .addr  ( pc[8:0]      ),
    .rdata ( inst    ),
    .wr    ( 1'b0    ),
    .wdata ( data )
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
	.wb_addr ( wb_addr ),
    .wb_data ( wb_data ),
    .wb_en   ( wb_en   ),
    .dmem_if ( dmem_if )
  );

  data_memory
  #()
  dmem_inst(
    .clk    ( clk ),
//	.func3  (inst.iinst.func3),
    .mem_if ( dmem_if  )
  );

endmodule:riscv
