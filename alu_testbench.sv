module alu_testbench();

	logic clk;
	logic [31:0] a, b;
   logic [1:0] ALUControl;
	logic [31:0] Result;
	logic [3:0] ALUFlags;
	
	alu dut (.*);

    //clock setup
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		repeat(250) #(clock_period /2) clk <= ~clk;
				
	end //initial


    
	initial begin
		@(posedge clk);
      ALUControl<=2'b00; a<=32'h00000000; b<=32'h00000000; @(posedge clk);
														b<=32'hFFFFFFFF; @(posedge clk);
							    a<=32'h00000001;                  @(posedge clk);
							    a<=32'h000000FF; b<=32'h00000001; @(posedge clk);
								 
		ALUControl<=2'b01; a<=32'h00000000; b<=32'h00000000; @(posedge clk);
														b<=32'hFFFFFFFF; @(posedge clk);
								 a<=32'h00000001; b<=32'h00000001; @(posedge clk);
								 a<=32'h00000100;                  @(posedge clk);

		ALUControl<=2'b10; a<=32'hFFFFFFFF; b<=32'hFFFFFFFF; @(posedge clk);
													   b<=32'h12345678; @(posedge clk);
								 a<=32'h12345678; b<=32'h87654321; @(posedge clk);
								 a<=32'h00000000; b<=32'hFFFFFFFF; @(posedge clk);
								 
		ALUControl<=2'b11; a<=32'hFFFFFFFF; 					  @(posedge clk);
								 a<=32'h12345678; b<=32'h87654321; @(posedge clk);
								 a<=32'h00000000; b<=32'hFFFFFFFF; @(posedge clk);
								                  b<=32'h00000000; @(posedge clk);		 
		$stop;
		
	end
	
endmodule
			