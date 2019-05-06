
module data_memory
  #(
    parameter AW = 11,
    parameter DW = 32
  )
  (
    input  logic          clk,
	input  logic [2:0] func3,
    memory_if.slave       mem_if
  );

`ifdef __SIM__

  logic [DW-1:0] mem [2**AW];

  always_ff @(posedge clk) begin
    if(mem_if.wr)
      mem[mem_if.addr] <= mem_if.wdata;
  end

  logic [DW-1:0] temp_r_data;
  assign temp_r_data = mem[mem_if.addr];
  always_comb
    begin
      case(func3)
        3'b000: // LB
            mem_if.rdata = {{24{temp_r_data[31]}}, temp_r_data[7:0]};
        3'b001: // LH
            mem_if.rdata = {{16{temp_r_data[31]}}, temp_r_data[15:0]};
        3'b010: // LW
            mem_if.rdata = temp_r_data;
        3'b100: // LBU
            mem_if.rdata = {24'b0, temp_r_data[7:0]};
        3'b101: // LHU
            mem_if.rdata = {16'b0, temp_r_data[15:0]};
      default:
        mem_if.rdata = temp_r_data; 
    endcase
  end

`else

   SRAM1RW512x32 RAM (
         .A       ( mem_if.addr   ),
         .CE      ( clk           ),
         .WEB     ( ~mem_if.wr    ),
         .OEB     ( mem_if.wr     ),
         .CSB     ( 1'b0          ),
         .I       ( mem_if.wdata  ),
         .O       ( mem_if.rdata  )
         );

`endif


endmodule:data_memory
