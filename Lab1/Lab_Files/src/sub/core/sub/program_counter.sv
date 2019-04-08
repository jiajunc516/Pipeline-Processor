
module program_counter
  #(parameter AW = 32)
  (
    input  logic clk,
    input  logic rst_n,
    input  logic enable,

    input  logic [AW-1:0] din,
    output logic [AW-1:0] pc
  );

  always_ff @(posedge clk)
  begin
    if( ~rst_n )
      pc <= '0;
    else if (enable)
      pc <= din;
  end

endmodule:program_counter
