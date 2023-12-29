module ALU(CLK,A,B,S,EQUAL,GT,LT,Zero,CarryOut,Overflow,F,FF);
input [7:0]A,B;
input [3:0]S;
input CLK;
output reg EQUAL,GT,LT,Zero,CarryOut,Overflow;
output reg [7:0] F,FF;
reg [8:0] FEXT;
reg [7:0]BX;

always@(posedge CLK)
begin
FF <=F;
end

always @(*)
	begin
		
		case(S)
		4'b0000:begin
		BX=B;
		FEXT= A+BX;
		F = FEXT[7:0];
			
		end
		4'b0001:
		begin
		BX=-B;
		FEXT=A+BX;
		F = FEXT[7:0];
		
		end
		4'b0011:F=-B;
		4'b1000:F=A&B;
		4'b1001:F=A^B;
		4'b1010:F=A|B;
		4'b1011:F=~B;
		4'b1100:F=(B>>1)|({B[0], {7{1'b0}}});
		4'b1101:F=(B<<1)|({{7{1'b0}}, B[7]});
		4'b1110:F=B>>1;
		4'b1111:F=B<<1;
		//default:0;
		
		endcase
		GT= (A>B)?1'b1:1'b0;
		LT= (A<B)?1'b1:1'b0;
		EQUAL= (A==B)?1'b1:1'b0;
		Zero = (F==0)?1'b1:1'b0;
		if((A[7]==BX[7])&&(BX[7]!=F[7]))
		Overflow =1;
		else
		Overflow=0;
		CarryOut=FEXT[8];
	end


endmodule
