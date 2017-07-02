/*
* Copyright (c) 2017 Cory Perry
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

`define BIT_WIDTH 32
`define STAGES 8

module pipe_mult_tb();

reg [1024*8-1:0] vcdfn;
reg [`BIT_WIDTH-1:0] stage_a[`STAGES:0];
reg [`BIT_WIDTH-1:0] stage_b[`STAGES:0];

reg clock, start, reset;

wire [`BIT_WIDTH-1:0] result;

wire done;

wire [`BIT_WIDTH-1:0] cres = stage_a[`STAGES]*stage_b[`STAGES];

wire correct = (cres==result)|~done;
integer i, j;

pipe_mult #(`BIT_WIDTH, `STAGES) m0
  (.clk_i(clock), .rst_i(reset),
   .multiplier_i(stage_a[0]), .multicand_i(stage_b[0]),
   .start_i(start), .product_o(result), .done_o(done));

always @(posedge clock)
  for(j=0;j<`STAGES;j=j+1) begin
    stage_a[j+1] <= stage_a[j];
    stage_b[j+1] <= stage_b[j];
  end

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

  if ($value$plusargs("WAVES=%s",vcdfn)) begin
    $dumpfile(vcdfn);
    $dumpvars(0, pipe_mult_tb);
  end

  $monitor("Time:%4.0f done:%b a:%h b:%h product:%h result:%h",$time,done,stage_a[`STAGES],stage_b[`STAGES],cres,result);

  $display ("Basic testing");
  stage_a[0]=2;
  stage_b[0]=3;
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
  stage_a[0]=-1;
  @(negedge clock);
  start=0;
  @(posedge done);
  @(negedge clock);
  @(negedge clock);
  start=1;
  stage_a[0]=-20;
  stage_b[0]=5;
  @(negedge clock);
  start=0;
  @(posedge done);
  @(negedge clock);

  $display ("Interface test");
  for(i=0;i<100;i=i+1)
  begin
    start=1;
    stage_a[0]={$random,$random};
    stage_b[0]={$random,$random};
    @(negedge clock);
    start=0;
    @(posedge done);
    @(negedge clock);
  end
  $display ("Pipelined test");
  for(i=0;i<100;i=i+1)
  begin
    start=1;
    stage_a[0]={$random,$random};
    stage_b[0]={$random,$random};
    @(negedge clock);
  end
  $display ("*** PASSED ***"); 

  $finish;
end

endmodule
