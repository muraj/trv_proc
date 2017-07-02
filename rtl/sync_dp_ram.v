module sync_dp_ram
#(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 3
)
(
  input wire clk,
  input wire wr_en,
  input wire [0 +: ADDR_WIDTH] wr_addr,
  input wire [0 +: DATA_WIDTH] wr_data,

  input wire rd_en,
  input wire [0 +: ADDR_WIDTH] rd_addr,
  output wire [0 +: DATA_WIDTH] rd_data,
);

  reg [0 +: DATA_WIDTH] mem [1<<ADDR_WIDTH];

  assign rd_data = mem[rd_addr];

  always @(posedge clk) begin
    mem[wr_addr] <= wr_en ? wr_data : mem[wr_addr];
  end

endmodule
