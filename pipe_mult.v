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

module pipe_mult
#(
  parameter DATA_WIDTH = 32,
  parameter STAGES = 8
)
(
  input wire clk_i,
  input wire rst_i,
  input wire start_i,
  input wire  [DATA_WIDTH-1:0] multiplier_i,
  input wire  [DATA_WIDTH-1:0] multicand_i,
  output wire [DATA_WIDTH-1:0] product_o,
  output wire done_o
);
  wire [STAGES-2:0]   inner_dones;
  wire [DATA_WIDTH*(STAGES-1)-1:0] inner_mpliers, inner_mcands, inner_prods;
  wire [DATA_WIDTH-1:0] final_mcand, final_mplier;

  stage_mult #(DATA_WIDTH, DATA_WIDTH / STAGES) stages [STAGES-1:0]
  (
    .clk(clk_i), .rst(rst_i),
    .start({inner_dones, start_i}),
      .mcand_i({inner_mcands, multicand_i}),
      .mplier_i({inner_mpliers, multiplier_i}),
      .prod_i({inner_prods, {DATA_WIDTH{1'b0}}}),
    .done({done_o, inner_dones}),
      .mcand_o({final_mcand, inner_mcands}),
      .mplier_o({final_mplier, inner_mpliers}),
      .prod_o({product_o, inner_prods})
  );
  
endmodule

module stage_mult
#(
  parameter DATA_WIDTH = 32,
  parameter SEL_WIDTH = 8
)
(
  input  wire clk,
  input  wire rst,
  input  wire start,
  input  wire [DATA_WIDTH-1:0] mcand_i, mplier_i, prod_i,
  output reg  done,
  output reg  [DATA_WIDTH-1:0] mcand_o, mplier_o, prod_o
);
  wire [DATA_WIDTH-1:0] partial_prod;

  assign partial_prod = mplier_i[SEL_WIDTH-1:0] * mcand_i;

  always @(posedge clk) begin
    done <= rst ? 0 : start;
    mcand_o  <= mcand_i << SEL_WIDTH;
    mplier_o <= mplier_i >> SEL_WIDTH;
    prod_o   <= prod_i + partial_prod;
  end
endmodule
