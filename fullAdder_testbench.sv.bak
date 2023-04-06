// Tests the full adder from  fullAdder.sv
module fullAdder_testbench();
	
	logic A,B,cin,sum,cout;
	
	fullAdder dut (A, B, cin, sum, cout);
	
	integer i;
	initial begin
	
		for (i=0; i<2**3; i++) begin
			{A, B, cin} = i; #10;
		end
		
		$stop;
		
	end
	
endmodule