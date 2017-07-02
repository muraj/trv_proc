module AND2X1(A, B, Y);
input A, B;
output Y;
and(Y, A, B);
endmodule

module AND2X2(A, B, Y);
input A, B;
output Y;
and(Y, A, B);
endmodule

module AOI21X1(A, B, C, Y);
input A, B, C;
output Y;
wire tmp;
and(tmp, A, B);
nor(Y, tmp, C);
endmodule

module AOI22X1(A, B, C, D, Y);
input A, B, C, D;
output Y;
wire tmp0, tmp1;
and(tmp0, A, B);
and(tmp1, C, D);
nor(Y, tmp0, tmp1);
endmodule

module BUFX2(A, Y);
input A;
output Y;
buf(Y, A);
endmodule

module BUFX4(A, Y);
input A;
output Y;
buf(Y, A);
endmodule

module DFFPOSX1(CLK, D, Q);
input CLK, D;
output reg Q;
always @(posedge CLK)
	Q <= D;
endmodule

module INVX1(A, Y);
input A;
output Y;
not(Y, A);
endmodule

module INVX2(A, Y);
input A;
output Y;
not(Y, A);
endmodule

module INVX4(A, Y);
input A;
output Y;
not(Y, A);
endmodule

module INVX8(A, Y);
input A;
output Y;
not(Y, A);
endmodule

module NAND2X1(A, B, Y);
input A, B;
output Y;
nand(Y, A, B);
endmodule

module NAND3X1(A, B, C, Y);
input A, B, C;
output Y;
nand(Y, A, B, C);
endmodule

module NOR2X1(A, B, Y);
input A, B;
output Y;
nor(Y, A, B);
endmodule

module NOR3X1(A, B, C, Y);
input A, B, C;
output Y;
nor(Y, A, B, C);
endmodule

module OAI21X1(A, B, C, Y);
input A, B, C;
output Y;
wire tmp;
or(tmp, A, B);
nand(Y, tmp, C);
endmodule

module OAI22X1(A, B, C, D, Y);
input A, B, C, D;
output Y;
wire tmp0, tmp1;
or(tmp0, A, B);
or(tmp1, C, D);
nand(Y, tmp0, tmp1);
endmodule

module OR2X1(A, B, Y);
input A, B;
output Y;
or(Y, A, B);
endmodule

module OR2X2(A, B, Y);
input A, B;
output Y;
or(Y, A, B);
endmodule

module XNOR2X1(A, B, Y);
input A, B;
output Y;
xnor(Y, A, B);
endmodule

module XOR2X1(A, B, Y);
input A, B;
output Y;
xor(Y, A, B);
endmodule
