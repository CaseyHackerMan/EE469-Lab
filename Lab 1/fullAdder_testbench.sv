/* Oliver Huang [ohlbur] & Casey Culbertson [casey534]
 * Prof. Hussein
 * EE 469
 * 6April 2023
 * Lab 1 - DE1_SoC.sv
 */

// testbench for fullAdder
module fullAdder_testbench();
	
	logic A,B,cin,sum,cout;
	
	fullAdder dut (A, B, cin, sum, cout);
	
	integer i;
	initial begin
		
		// loops through all input possibilities
		for (i=0; i<2**3; i++) begin
			{A, B, cin} = i; #10;
		end
		
		$stop;
		
	end
	
endmodule