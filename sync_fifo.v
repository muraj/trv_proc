module sync_fifo
#(
  parameter DATA_WIDTH = 8,
  parameter RAM_DEPTH = 3
)
(
  input wire clk,
  input wire rst,
  input wire rd_en,
  input wire wr_en,
  input wire [0 +: DATA_WIDTH] wr_data,
  output wire [0 +: DATA_WIDTH] rd_data,
  output wire full,
  output wire empty,
)
  reg [0 +: RAM_DEPTH] head;
  reg [0 +: RAM_DEPTH] tail;
  reg [0 +: RAM_DEPTH] cnt;

  assign empty = cnt == 0;
  assign full = cnt == (1<<RAM_DEPTH);
  wire queue = wr_en && !full;
  wire dequeue = rd_en && !empty;
  
  always @(posedge clk) begin
    if (rst) begin
      head <= 0;
      tail <= 0;
      cnt <= 0;
    end
    else
      head <= head + queue;
      tail <= tail + dequeue;
      cnt <= cnt + (queue - dequeue);
    end
  end

  sync_dp_ram #(DATA_WIDTH, RAM_DEPTH) fifo_ram
        (.clk(clk),
         .wr_en(wr_en && !full),
         .wr_addr(head),
         .wr_data(wr_data),
         .rd_en(rd_en && !empty),
         .rd_addr(tail),
         .rd_data(rd_data));
endmodule
