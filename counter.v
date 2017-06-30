//-----------------------------------------------------
// Design Name : counter
// File Name : counter.v
// Function : This is a 4 bit up-counter with
// Synchronous active high reset and
// with active high enable signal
//-----------------------------------------------------
module counter (
  input wire clock,  // Clock input of the design
  input wire reset,  // active high, synchronous Reset input
  input wire enable, // Active high enable signal for counter
  output reg [3:0] counter_out // 4 bit vector output of the counter
); // End of port list

// Since this counter is a positive edge trigged one,
// We trigger the below block with respect to positive
// edge of the clock.
always @ (posedge clock)
begin : COUNTER // Block Name
  // At every rising edge of clock we check if reset is active
  // If active, we load the counter output with 4'b0000
  if (reset) begin
    counter_out <= 4'b0000;
  end
  // If enable is active, then we increment the counter
  else if (enable) begin
    counter_out <= counter_out + 1;
  end
end // End of Block COUNTER

endmodule // End of Module counter
