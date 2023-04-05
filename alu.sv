module alu(input logic [31:0] a, b,
			  input logic [1:0] ALUControl,
			  output logic [31:0] Result,
			  output logic [3:0] ALUFlags);
			  
	// flags: 3=neg 2=zero 1=cout 0=ovf
	logic N,Z,C,V,Cout;
	logic [31:0] Sum;
	
	assign ALUFlags = {N,Z,C,V};
	
	logic [31:0] temp;
	assign temp = ALUControl[0] ? ~b : b;
	assign {Cout,Sum} = a + temp + ALUControl[0];
	
	assign Result = ALUControl[1] ? (ALUControl[0] ? a|b : a&b) : Sum;
	
	assign V = ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ Sum[31]) & ~ALUControl[1];
	assign C = ~ALUControl[1] & Cout;
	assign N = Result[31];
	assign Z = ~|Result;
	  
endmodule