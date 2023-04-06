// Implements an ALU with controls for addition, subtraction,
// bitwise AND, and bitwise OR. Has negative, zero, cout, 
/* Oliver Huang [ohlbur] & Casey Culbertson [casey534]
 * Prof. Hussein
 * EE 469
 * 6April 2023
 * Lab 1 - DE1_SoC.sv
 */

// Implements an ALU with controls for addition, subtraction,
// bitwise AND, and bitwise OR. Has negative, zero, cout, 
// and overflow flags.
module alu(input logic [31:0] a, b,
			  input logic [1:0] ALUControl,
			  output logic [31:0] Result,
			  output logic [3:0] ALUFlags);
			  
	
	logic N,Z,C,V,Cout;
	logic [31:0] Sum;
	
	// flags: 3=Negative 2=Zero 1=Cout 0=oVerflow
	assign ALUFlags = {N,Z,C,V};
	
	
	// addition and subtraction
	logic [31:0] temp;
	assign temp = ALUControl[0] ? ~b : b;
	assign {Cout,Sum} = a + temp + ALUControl[0];
	
	// final result
	assign Result = ALUControl[1] ? (ALUControl[0] ? a|b : a&b) : Sum;
	
	// flags
	assign V = ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ Sum[31]) & ~ALUControl[1];
	assign C = ~ALUControl[1] & Cout;
	assign N = Result[31];
	assign Z = ~|Result;
	  
endmodule