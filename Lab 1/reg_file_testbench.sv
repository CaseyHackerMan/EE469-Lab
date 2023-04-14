/* Oliver Huang [ohlbur] & Casey Culbertson [casey534]
 * Prof. Hussein
 * EE 469
 * 6April 2023
 * Lab 1 - DE1_SoC.sv
 */

 // testbench for reg_file
module reg_file_testbench();

	logic clk, wr_en;
	logic [31:0] write_data, read_data1, read_data2;
	logic [3:0] write_addr, read_addr1, read_addr2;
	
	reg_file dut (.*);

    //clock setup
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		repeat(250) #(clock_period /2) clk <= ~clk;
				
	end

   
	initial begin
      // test 1
		wr_en = 1'b0;
		read_addr1 = 4'b0000; read_addr2 = 4'b0000;
		write_addr = 4'b1010; write_data = {32{1'b1}}; @(posedge clk);
		wr_en = 1'b1; @(posedge clk);
		@(posedge clk);
      write_addr = 4'b0100; write_data = {16{2'b01}}; @(posedge clk);
      @(posedge clk);
		wr_en = 1'b0;

      //test 2
      read_addr1 = 4'b1010; read_addr2 = 4'b0100; @(posedge clk);
     
      // test 3
		wr_en = 1'b1; 
		read_addr1 = 4'b1111; read_addr2 = 4'b1111;
		@(posedge clk);
		write_addr = 4'b1111; write_data = {32{1'b0}}; @(posedge clk);
      @(posedge clk);
		@(posedge clk);

		$stop;
		
	end
	
endmodule
			