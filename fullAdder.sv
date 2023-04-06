/* Oliver Huang [ohlbur] & Casey Culbertson [casey534]
 * Prof. Hussein
 * EE 469
 * 6April 2023
 * Lab 1 - DE1_SoC.sv
 */

// Implements a full adder
module fullAdder (A, B, cin, sum, cout);
	
	input logic A,B,cin;
	output logic sum, cout;
	
	assign sum = A ^ B ^ cin; 
	assign cout = A & B | cin & (A^B);
	
endmodule
