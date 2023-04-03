module reg_file_testbench();

	logic clk, wr_en;
	logic [31:0] write_data, read_data1, read_data2;
	logic [3:0] write_addr, read_addr1, read_addr2;
	
	reg_file dut (.*);
	//reg_file dut (clk, wr_en, write_data, read_data1, read_data2, write_addr, read_addr1, read_addr2);

   //clock setup
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		repeat(250) #(clock_period /2) clk <= ~clk;
				
	end //initial


    
	initial begin
        // test 1
		  wr_en <= 1; write_addr <= 4'b1010; write_data <= {32{1'b1}}; @(posedge clk);
                    write_addr <= 4'b0100; write_data <= {16{2'b01}}; @(posedge clk);
        @(posedge clk);

        //test 2
        wr_en <= 0;  @(posedge clk);
        read_addr1 <= 4'b1010; read_addr2 <= 4'b0100; @(posedge clk);
        
        // test 3
        read_addr2 <= 4'b1010; @(posedge clk);
        wr_en <= 1; write_addr <= 4'b1010; write_data <= {32{1'b0}}; @(posedge clk);
        
        @(posedge clk);

		$stop;
		
	end
	
endmodule
			