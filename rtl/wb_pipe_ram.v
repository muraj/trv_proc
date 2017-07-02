/******************
 * Wishbone compatible pipelined ram.  This allows compatible cores to
 * simulate memories with high latency and limited bandwidth
 ******************/
module wb_pipe_ram
#(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 3,
  parameter QUEUE_DEPTH = 3,
  parameter LATENCY_WIDTH = 6
)
(
  input wire clk_i,
  input wire rst_i,
  input wire  [0 +: ADDR_WIDTH] adr_i,
  input wire  [0 +: DATA_WIDTH] dat_i,
  output wire [0 +: DATA_WIDTH] dat_o,
  output wire [0 +: ADDR_WIDTH] tag_o,  // replies back with the requested address, for cacheline purposes
  input wire we_i,
  input wire stb_i,
  input wire cyc_i,
  output wire ack_o,
  output wire stall_o
);

  wire cur_invalid;
  wire [0 +: ADDR_WIDTH] cur_adr;
  wire [0 +: DATA_WIDTH] cur_dat;
  wire cur_we;

  reg [0 +: LATENCY_WIDTH] lat_cntr;

  assign ack_o = lat_cntr == 0 && cyc_i && stb_i;
  assign tag_o = cur_adr;

  sync_fifo #(ADDR_WIDTH + DATA_WIDTH + 1, QUEUE_DEPTH) req_q
    (.clk(clk_i), .rst(rst_i),
     .rd_en(lat_cntr == 0), .wr_en(cyc_i && stb_i),
     .wr_data({adr_i, dat_i, we_i}),
     .rd_data({cur_adr, cur_dat, cur_we}),
     .full(stall_o), .empty(cur_invalid));

  sync_dp_ram #(DATA_WIDTH, ADDR_WIDTH) ram
    (.clk(clk), .wr_en(lat_cntr == 0 && cyc_i && stb_i && cur_we)
     .wr_addr(cur_adr), .wr_data(cur_dat),
     .rd_en(lat_cntr == 0 && cyc_i && stb_i && !cur_we),
     .rd_addr(cur_adr), .rd_data(dat_o));

  always @(posedge clk_i) begin
    if (rst_i || !cyc_i)
      lat_cntr <= ~0;
    else
      lat_cntr <= (lat_cntr == 0 ? ~0 : lat_cntr - 1);
  end

endmodule
