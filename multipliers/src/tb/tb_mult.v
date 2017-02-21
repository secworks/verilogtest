
module tb_mult;

  parameter API_WIDTH       = 16;
  localparam OPA_WIDTH      = 64;
  localparam OPB_WIDTH      = 64;

  reg                        clk;
  reg                        reset_n;
  reg                        cs;
  reg                        we;
  reg  [7 : 0]               addr;
  reg  [(API_WIDTH - 1) : 0] write_data;
  wire [(API_WIDTH - 1) : 0] read_data;




endmodule // tb_mult
