module reg_file(input logic clk, wr_en,
                input logic [31:0] write_data, 
                input logic [3:0] write_addr,
                input logic [3:0] read_addr1, read_addr2, 
                output logic [31:0] read_data1, read_data2);
			
	logic [15:0][31:0] memory;	
	
	always_comb begin
		read_data1 = memory[read_addr1];
		read_data2 = memory[read_addr2];
	end
	
	always_ff @(posedge clk) begin
	
		if (wr_en) begin
			memory[write_addr] <= write_data;
		end
	end
		
endmodule

// meow meow meow meow mewo
		