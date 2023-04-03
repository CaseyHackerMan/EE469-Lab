// Implements a full adder
module fullAdder (A, B, cin, sum, cout);
	
	input logic A,B,cin;
	output logic sum, cout;
	
	assign sum = A ^ B ^ cin;
	assign cout = A & B | cin & (A^B);
	
endmodule

