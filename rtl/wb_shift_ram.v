
// Notes to self: latency is parameterized by LATENCY_CYCLES
//                bandwidth is DATA_WIDTH / cycle
//                latency_cycles is minus one the true latency due to a reg needed to isolate RAM from the rest of the chip

module wb_shift_ram
#(
  parameter DATA_WIDTH = 32,
  parameter WORD_WIDTH = 8,
  parameter ADDR_WIDTH = 3,
  parameter LATENCY_CYCLES = 3,
)
(
  input wire clk_i,
  input wire rst_i,
  input wire  [0 +: ADDR_WIDTH] adr_i,
  input wire  [0 +: DATA_WIDTH] dat_i,
  output wire [0 +: DATA_WIDTH] dat_o,
  output wire [0 +: ADDR_WIDTH] tag_o,  // replies back with the requested address, for cacheline purposes
  input wire sel_i,
  input wire we_i,
  input wire stb_i,
  input wire cyc_i,
  output wire ack_o,
  output wire stall_o
);

// FIFO shift registers
reg [0 +: ADDR_WIDTH]              lat_pipe_addr  [LATENCY_CYCLES];
reg [0 +: DATA_WIDTH]              lat_pipe_data  [LATENCY_CYCLES];
reg [0 +: DATA_WIDTH / WORD_WIDTH] lat_pipe_sel   [LATENCY_CYCLES];
reg                                lat_pipe_we    [LATENCY_CYCLES];
reg                                lat_pipe_stb   [LATENCY_CYCLES];

// RAM
reg [0 +: DATA_WIDTH] mem [1<<ADDR_WIDTH];

// Internal wires
reg [0 +: ADDR_WIDTH]              current_addr;
reg [0 +: DATA_WIDTH]              current_data;
reg [0 +: DATA_WIDTH / WORD_WIDTH] current_sel;
reg                                current_we;
reg                                current_stb;

integer lat_idx;

// Outputs
assign stall_o = 1'b0;             // Never stall (no need to, there will always be one slot open
assign ack_o = current_stb;        // Send an ACK once everything's gone through the pipe
assign tag_o = current_addr;       // Send back the requested address for caching purposes (assuming the synthizer will optimize out unneeded bits)
assign dat_o = current_data;

// Write to mem only the parts we requested, leaving the others alone
genvar sel_idx;
generate
  for (sel_idx = 0 ; sel_idx < (DATA_WIDTH / WORD_WIDTH); sel_idx++) begin : gen_sel_cases
    always @(posedge clk_i) begin
      if(!rst_i && current_stb && current_we && current_sel[sel_idx]) begin
        // mem[current_addr][0:7] <= current_data[0:7];
        mem[current_addr][sel_idx*WORD_WIDTH : (sel_idx+1)*WORD_WIDTH - 1] <= current_data[sel_idx*WORD_WIDTH: (sel_idx+1)*WORD_WIDTH - 1];
      end
    end
endgenerate

always @(posedge clk_i) begin
  if (rst_i) begin 
    for (lat_idx = 0; lat_idx < LATENCY_CYCLES; lat_idx++) begin
      lat_pipe_stb[lat_idx] <= 0;
    end
  end
  else begin
    lat_pipe_stb [0]  <= stb_i; 
    lat_pipe_sel [0]  <= sel_i; 
    lat_pipe_we  [0]  <= we_i; 
    lat_pipe_addr[0]  <= adr_i; 
    lat_pipe_data[0]  <= dat_i; 

    current_addr <= lat_pipe_addr[LATENCY_CYCLES - 1];
    current_data <= mem[lat_pipe_addr[LATENCY_CYCLES - 1]];;
    current_sel  <= lat_pipe_sel [LATENCY_CYCLES - 1];
    current_we   <= lat_pipe_we  [LATENCY_CYCLES - 1];
    current_stb  <= lat_pipe_stb [LATENCY_CYCLES - 1];

    for (lat_idx = 1; lat_idx < LATENCY_CYCLES; lat_idx++) begin
        lat_pipe_addr[lat_idx] <= lat_pipe_addr[lat_idx-1]; 
        lat_pipe_data[lat_idx] <= lat_pipe_data[lat_idx-1]; 
        lat_pipe_sel [lat_idx] <= lat_pipe_sel [lat_idx-1]; 
        lat_pipe_we  [lat_idx] <= lat_pipe_we  [lat_idx-1]; 
        lat_pipe_stb [lat_idx] <= lat_pipe_stb [lat_idx-1]; 
    end
  end
end

endmodule
