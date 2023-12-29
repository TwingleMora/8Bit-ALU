//'include"ALU.v"

`timescale 10ns/100ps
module TestBench1;//reg for input ;; wire for output
reg  CLK_sig = 0;
reg [7:0]A_sig,B_sig;
reg [3:0]S_sig;
wire [7:0] F_sig,FF_sig;
wire EQUAL_sig,GT_sig,LT_sig,Zero_sig,CarryOut_sig,Overflow_sig;

//always #1 CLK = ~CLK;
//initial $dumpfile("TestBench1.vcd");
//initial $dumpvars(0, TestBench1);

always begin
#5 CLK_sig=!CLK_sig;
end
ALU ALU_inst
(
	.CLK(CLK_sig) ,	// input  CLK_sig
	.A(A_sig) ,	// input [7:0] A_sig
	.B(B_sig) ,	// input [7:0] B_sig
	.S(S_sig) ,	// input [3:0] S_sig
	.EQUAL(EQUAL_sig) ,	// output  EQUAL_sig
	.GT(GT_sig) ,	// output  GT_sig
	.LT(LT_sig) ,	// output  LT_sig
	.Zero(Zero_sig) ,	// output  Zero_sig
	.CarryOut(CarryOut_sig) ,	// output  CarryOut_sig
	.Overflow(Overflow_sig) ,	// output  Overflow_sig
	.F(F_sig) ,	// output [7:0] F_sig
	.FF(FF_sig) 	// output [7:0] FF_sig
);

initial begin
    //These events must be in chronological order.
    A_sig = 8'b00000000;
    B_sig = 8'b00000000;
	 S_sig = 4'b0000;
    #10
    A_sig = 8'b00001111;
    B_sig = 8'b00000101;
	 S_sig = 4'b0001;
    #10
    A_sig = 8'b00001100;
    B_sig = 8'b00001111;
	 S_sig = 4'b0011;
    #10
    A_sig = 8'b00001100;
    B_sig = 8'b00000011;
	 S_sig = 4'b1000;
    #10
    A_sig = 8'b00001100;
    B_sig = 8'b00001010;
	 S_sig = 4'b1001;
    #10
	 A_sig = 8'b00110000;
    B_sig = 8'b01000000;
	 S_sig = 4'b1010;
    #10
    A_sig = 8'b00001111;
    B_sig = 8'b01000101;
	 S_sig = 4'b1011;
    #10
    A_sig = 8'b01001100;
    B_sig = 8'b00001111;
	 S_sig = 4'b1100;
    #10
    A_sig = 8'b10001100;
    B_sig = 8'b00000011;
	 S_sig = 4'b1101;
    #10
    A_sig = 8'b10101100;
    B_sig = 8'b10101010;
	 S_sig = 4'b1110;
    #10
	 A_sig = 8'b10101101;
    B_sig = 8'b10101010;
	 S_sig = 4'b1111;
	 $stop;
	 $finish;
end
endmodule
