/* Oliver Huang [ohlbur] & Casey Culbertson [casey534]
 * Prof. Hussein
 * EE 469
 * 6April 2023
 * Lab 1 - DE1_SoC.sv
 */

// testbench for alu
module alu_testbench();

	logic clk;
	logic [31:0] a, b;
   logic [1:0] ALUControl;
	logic [31:0] Result;
	logic [3:0] ALUFlags;
	logic [103:0] testvectors [1000:0];
	
	alu dut (.*);

    //clock setup
	parameter clock_period = 100;
	
	initial clk = 1;
	always begin
		#(clock_period/2);
		clk = ~clk;
	end
	

	
	initial begin
		// read test vector from file
		$readmemh("alu.tv", testvectors);
		
		// run tests
		for(int i = 0; i < 20; i = i + 1) begin
			{ALUControl, a, b, Result, ALUFlags} = testvectors[i]; @(posedge clk);
		end
		
		$stop;
	end
	
endmodule
			