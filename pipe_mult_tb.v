`define BIT_WIDTH 32
`define STAGES 16

module pipe_mult_tb();

reg [`BIT_WIDTH-1:0] a,b;
reg quit, clock, start, reset;

wire [`BIT_WIDTH-1:0] result;

wire done;

wire [`BIT_WIDTH-1:0] cres = a*b;

wire correct = (cres==result)|~done;
integer i;


pipe_mult #(`BIT_WIDTH, `STAGES) m0
  (.clk_i(clock), .rst_i(reset),
   .multiplier_i(a), .multicand_i(b),
   .start_i(start), .product_o(result), .done_o(done));

always @(posedge clock)
  #2 if(!correct) begin 
    $display("Incorrect at time %4.0f",$time);
    $display("cres = %h result = %h",cres,result);
    $display ("*** FAILED ***"); 
    $finish;
  end

always
begin
  #5;
  clock=~clock;
end

initial begin

  if ($test$plusargs("WAVES")) begin
    $dumpfile("pipe_mult_tb.vcd");
    $dumpvars(0, pipe_mult_tb);
  end

  $monitor("Time:%4.0f done:%b a:%h b:%h product:%h result:%h",$time,done,a,b,cres,result);

  a=2;
  b=3;
  reset=1;
  clock=0;
  start=1;

  @(negedge clock);
  reset=0;
  @(negedge clock);
  start=0;
  @(posedge done);
  @(negedge clock);
  start=1;
  a=-1;
  @(negedge clock);
  start=0;
  @(posedge done);
  @(negedge clock);
  @(negedge clock);
  start=1;
  a=-20;
  b=5;
  @(negedge clock);
  start=0;
  @(posedge done);
  @(negedge clock);
  quit = 0;
  quit <= #10000 1;
  while(~quit)
  for(i=0;i<100;i=i+1)
  begin
    start=1;
    a={$random,$random};
    b={$random,$random};
    @(negedge clock);
    start=0;
    @(posedge done);
    @(negedge clock);
  end
  $display ("*** PASSED ***"); 
  $finish;
end

endmodule
