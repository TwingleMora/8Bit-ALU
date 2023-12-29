//Signed
module ALU(CLK,A,B,S,EQUAL,GT,LT,Zero,CarryOut,Overflow,F,FF);//GT: Greater Than, LT: Less Than 
input [7:0]A,B;
input [3:0]S;
input CLK;
output EQUAL,GT,LT,Zero,CarryOut,Overflow;
output [7:0] F,FF;
wire [7:0] AF,LF,SHF; // you must declare any vector otherwise it will be declared automatically with a width of 1bit

Arithmetic_Unit AU(A,B,S[1:0],EQUAL,GT,LT,Zero,CarryOut,Overflow,AF);
Logic_Unit LU(A,B,S[1:0],LF);
Shifter_Unit SHU(A,S[1:0],SHF);
Control_Unit CONTU(AF,LF,SHF,S[3:2],F);
Register R(F,CLK,FF);
endmodule 
module Arithmetic_Unit(A,B,S,EQUAL,GT,LT,Zero,CarryOut,Overflow,AF);
input [7:0]A,B;
input[1:0] S;
output [7:0] AF;
output EQUAL,GT,LT,Zero,CarryOut,Overflow;
wire [7:0]zeros8bit;
assign zeros8bit = {8{1'b0}};
//fist input is either A or 0
wire[7:0] AX;
Mux2To1_8bit mux0(A,zeros8bit,S[1],AX);
ADDER_SUBTRACTOR A_S(AX,B,S[0],AF,CarryOut,Overflow,Zero);
//ADDER_SUBTRACTOR(A,B,S,SUM,COUT,OVERFLOW,ZERO);
//GT
FullComparator FC(A,B,EQUAL,GT,LT);
endmodule

module Flipflop1bit(D,CLK,Q);
input D,CLK;
output Q;
wire QBAR;
wire S,R;
assign S=D;
not n0(R,D);
nand na0(a0,S,CLK);
nand na1(b0,R,CLK);
nand na2(Q,a0,QBAR);
nand na3(QBAR,b0,Q);

endmodule
module Register (D,CLK,R);
input [7:0] D;
input CLK;
output [7:0]R;
genvar i;
generate
 for (i=0; i<8; i=i+1) begin : generate_register// <-- example block name
    Flipflop1bit FF(D[i],CLK,R[i]);

end
endgenerate

endmodule

module Comparator(A,B,EQUAL,GT,LT);
input A,B;
output EQUAL,GT,LT;
not n0(BBAR,B);
not n1(ABAR,A);
xnor xn0(EQUAL,A,B);
and a0(GT,BBAR,A);
and a1(LT,ABAR,B);
endmodule

module Comparator2bit(A,B,EQUAL,GT,LT,E,G,L);
input [1:0] A,B;
input E,G,L;
output EQUAL,GT,LT;
wire  [1:0] EQUALW,GTW,LTW;
genvar i;
generate
    for (i=0; i<2; i=i+1) begin : generate_comparator// <-- example block name
    Comparator CX (A[i],B[i],EQUALW[i],GTW[i],LTW[i]);
end
endgenerate
and an1(a0,EQUALW[1],GTW[0]);
and ann1(a00,E,a0);
and annn1(a11,E,GTW[1]);
or o1(a1,a11,a00);
or o2(GT,G,a1);

and an2(b0,EQUALW[1],LTW[0]);
and ann2(b00,E,b0);
and annn2(b11,E,LTW[1]);
or o3(b1,b11,b00);
or o4(LT,L,b1);

and an3(c1,EQUALW[0],EQUALW[1]);
and an4(EQUAL,E,c1);


endmodule

module FullComparator(A,B,EQUAL,GT,LT);
input [7:0] A,B;

output EQUAL,GT,LT;
wire EQUALBAR;
//wire  [7:0] EQUALW,GTW,LTW;
Comparator2bit c0(A[7:6],B[7:6],e0,g0,l0,1'b1,1'b0,1'b0);
Comparator2bit c1(A[5:4],B[5:4],e1,g1,l1,e0,g0,l0);
Comparator2bit c2(A[3:2],B[3:2],e2,g2,l2,e1,g1,l1);
Comparator2bit c3(A[1:0],B[1:0],EQUAL,GT,LT,e2,g2,l2);
//not n0(EQUAL,EQUALBAR);

endmodule
module Logic_Unit(A,B,S,LF);
input [7:0]A,B;
input[1:0] S;
output [7:0] LF;
wire [7:0] AND_X,XOR_X,OR_X,NOT_X;
and88 and0(AND_X,A,B);
xor8 xor0 (XOR_X,A,B);
or88 or0 (OR_X,A,B);
not8 not0 (NOT_X,B);
Mux4To1_8bit mux0(AND_X,XOR_X,OR_X,NOT_X,S,LF);


endmodule

module Shifter_Unit(A,S,SHF);
input [7:0]A;
input[1:0] S;
output [7:0] SHF;
wire[7:0] RR,LR,RS,LS;
RightRotate RRB(A,RR);
LeftRotate LRB(A,LR);
RightShift RSB(A,RS);
LeftShift LSB(A,LS);
Mux4To1_8bit mux0(RR,LR,RS,LS,S,SHF);
endmodule

module Control_Unit(AF,LF,SHF,S,F);
input [7:0]AF,LF,SHF;
input[1:0] S;
output [7:0] F;
wire [7:0]w0;
Mux2To1_8bit mux0(LF,SHF,S[0],w0);
Mux2To1_8bit mux1(AF,w0,S[1],F);
endmodule



//Arithmetic Blocks
module ADDER_SUBTRACTOR(A,B,S,SUM,COUT,OVERFLOW,ZERO);
input [7:0]A,B;
input S;
output [7:0]SUM;
output COUT,OVERFLOW,ZERO;
wire [7:0]BXOR;
wire [7:0]extend; 
assign extend = {8{S}};
xor8 xor80(BXOR,B,extend);
wire [7:0] common,nott;
wire zeroBar;
FullAdder FA(A,BXOR,common,S,COUT,OVERFLOW);
not8 nt8(nott,common);
and8to1 a8t1(zeroBar,nott);
not(ZERO,zeroBar);
assign SUM = common;

endmodule

module FullAdder(A,B,SUM,CIN,COUT,OVERFLOW);
input [7:0]A,B;
input CIN; 
output [7:0]SUM;
output COUT,OVERFLOW;
FullAdder1Bit	FA0(A[0],B[0],SUM[0],CIN,c0);
FullAdder1Bit	FA1(A[1],B[1],SUM[1],c0,c1);
FullAdder1Bit	FA2(A[2],B[2],SUM[2],c1,c2);
FullAdder1Bit	FA3(A[3],B[3],SUM[3],c2,c3);
FullAdder1Bit	FA4(A[4],B[4],SUM[4],c3,c4);
FullAdder1Bit	FA5(A[5],B[5],SUM[5],c4,c5);
FullAdder1Bit	FA6(A[6],B[6],SUM[6],c5,c6);
FullAdder1Bit	FA7(A[7],B[7],SUM[7],c6,COUT);
xor xor0(OVERFLOW,c6,COUT);
endmodule
module FullAdder1Bit(A,B,S,Cin,Co);
input A,B,Cin;
output S,Co;
xor xor0 (w0,A,B);
xor xor1 (S,w0,Cin);
and and0 (w1,A,B);
and and1 (w2,Cin,w0);
or or0 (Co,w1,w2);
endmodule

//Logic Blocks
module xor8(R,A,B);
input  [7:0]	A,B;
output [7:0]	R;
xor	xor0(R[0],A[0],B[0]);
xor	xor1(R[1],A[1],B[1]);
xor	xor2(R[2],A[2],B[2]);
xor	xor3(R[3],A[3],B[3]);
xor	xor4(R[4],A[4],B[4]);
xor	xor5(R[5],A[5],B[5]);
xor	xor6(R[6],A[6],B[6]);
xor	xor7(R[7],A[7],B[7]);
endmodule
module or88(R,A,B);
input  [7:0]	A,B;
output [7:0]	R;
or	or0(R[0],A[0],B[0]);
or	or1(R[1],A[1],B[1]);
or	or2(R[2],A[2],B[2]);
or	or3(R[3],A[3],B[3]);
or	or4(R[4],A[4],B[4]);
or	or5(R[5],A[5],B[5]);
or	or6(R[6],A[6],B[6]);
or	or7(R[7],A[7],B[7]);
endmodule
module and88(R,A,B);
input  [7:0]	A,B;
output [7:0]	R;
and	and0(R[0],A[0],B[0]);
and	and1(R[1],A[1],B[1]);
and	and2(R[2],A[2],B[2]);
and	and3(R[3],A[3],B[3]);
and	and4(R[4],A[4],B[4]);
and	and5(R[5],A[5],B[5]);
and	and6(R[6],A[6],B[6]);
and	and7(R[7],A[7],B[7]);
endmodule
module not8(R,X);
input  [7:0]	X;
output [7:0]	R;
not	not0(R[0],X[0]);
not	not1(R[1],X[1]);
not	not2(R[2],X[2]);
not	not3(R[3],X[3]);
not	not4(R[4],X[4]);
not	not5(R[5],X[5]);
not	not6(R[6],X[6]);
not	not7(R[7],X[7]);
endmodule
module and8to1(R,X);
input  [7:0]	X;
output  R;
and	and0(w0,X[0],X[1]);
and	and1(w1,X[2],X[3]);
and	and2(w2,X[4],X[5]);
and	and3(w3,X[6],X[7]);

and	andx0(x0,w0,w1);
and	andx1(x1,w2,w3);

and	andz0(R,x0,x1);


endmodule


//Control Blocks
module Mux2To1_8bit(M1,M2,S,R);
input[7:0] M1,M2;
input S;
output[7:0] R;
Mux2To1_1bit mux1(M1[0],M2[0],S,R[0]);
Mux2To1_1bit mux2(M1[1],M2[1],S,R[1]);
Mux2To1_1bit mux3(M1[2],M2[2],S,R[2]);
Mux2To1_1bit mux4(M1[3],M2[3],S,R[3]);
Mux2To1_1bit mux5(M1[4],M2[4],S,R[4]);
Mux2To1_1bit mux6(M1[5],M2[5],S,R[5]);
Mux2To1_1bit mux7(M1[6],M2[6],S,R[6]);
Mux2To1_1bit mux8(M1[7],M2[7],S,R[7]);

endmodule
module Mux2To1_1bit(M1,M2,S,R);
input M1,M2;
input S;
output R;
wire SBar;
not n0(SBar,S);
and a0(w1,M1,SBar);
and a1(w2,M2,S);
or o0(R,w1,w2);
endmodule

module Mux4To1_8bit(M1,M2,M3,M4,S,R);
input[7:0] M1,M2,M3,M4;
input [1:0]S;
output[7:0] R;
Mux4To1_1bit mux1(M1[0],M2[0],M3[0],M4[0],S,R[0]);
Mux4To1_1bit mux2(M1[1],M2[1],M3[1],M4[1],S,R[1]);
Mux4To1_1bit mux3(M1[2],M2[2],M3[2],M4[2],S,R[2]);
Mux4To1_1bit mux4(M1[3],M2[3],M3[3],M4[3],S,R[3]);
Mux4To1_1bit mux5(M1[4],M2[4],M3[4],M4[4],S,R[4]);
Mux4To1_1bit mux6(M1[5],M2[5],M3[5],M4[5],S,R[5]);
Mux4To1_1bit mux7(M1[6],M2[6],M3[6],M4[6],S,R[6]);
Mux4To1_1bit mux8(M1[7],M2[7],M3[7],M4[7],S,R[7]);

endmodule
module Mux4To1_1bit(M1,M2,M3,M4,S,R);
input M1,M2,M3,M4;
input [1:0]S;
output R;
//least significant bit is 0
wire S0Bar;
wire S1Bar;
not n0(S0Bar,S[0]);
not n1(S1Bar,S[1]);
//S1' S0' M1
and a0(w1,M1,S0Bar);
and a1(w2,w1,S1Bar);

//S1' S0 M2
and a00(w11,M2,S[0]);
and a11(w22,w11,S1Bar);
//S1  S0' M3
and a000(w111,M3,S[1]);
and a111(w222,w111,S0Bar);
//S1  S0  M4
and a0000(w1111,M4,S[1]);
and a1111(w2222,w1111,S[0]);

or o0(x0,w2,w22);
or o1(x1,x0,w222);
or o2(R,x1,w2222);

endmodule

//Shifting Blocks
module RightRotate(X,R);
input  [7:0]	X;
output [7:0]	R;
assign R[0] = X[1];
assign R[1] = X[2];
assign R[2] = X[3];
assign R[3] = X[4];
assign R[4] = X[5];
assign R[5] = X[6];
assign R[6] = X[7];
assign R[7] = X[0]; 
endmodule

module LeftRotate(X,R);
input  [7:0]	X;
output [7:0]	R;
assign R[0] = X[7];
assign R[1] = X[0];
assign R[2] = X[1];
assign R[3] = X[2];
assign R[4] = X[3];
assign R[5] = X[4];
assign R[6] = X[5];
assign R[7] = X[6]; 
endmodule

module RightShift(X,R);
input  [7:0]	X;
output [7:0]	R;
assign R[0] = X[1];
assign R[1] = X[2];
assign R[2] = X[3];
assign R[3] = X[4];
assign R[4] = X[5];
assign R[5] = X[6];
assign R[6] = X[7];
assign R[7] = 0; 
endmodule

module LeftShift(X,R);
input  [7:0]	X;
output [7:0]	R;
assign R[0] = 0;
assign R[1] = X[0];
assign R[2] = X[1];
assign R[3] = X[2];
assign R[4] = X[3];
assign R[5] = X[4];
assign R[6] = X[5];
assign R[7] = X[6]; 
endmodule
