/* Oliver Huang [ohlbur] & Casey Culbertson [casey534]
 * Prof. Hussein
 * EE 469
 * 5 May 2023
 * Lab 4 - reg_file.sv
 *
 * reg_file implements a 16x32 register file with 
 * syncronous writing and two asyncronous read ports
 */
module reg_file(input logic clk, wr_en,
                input logic [31:0] write_data, 
                input logic [3:0] write_addr,
                input logic [3:0] read_addr1, read_addr2, 
				input logic [31:0] R15,
                output logic [31:0] read_data1, read_data2);
			
	logic [15:0][31:0] memory;	 
	
	// async read
	always_comb begin
		read_data1 = memory[read_addr1];
		read_data2 = memory[read_addr2];
	end
	
	// sync write
	always_ff @(posedge clk) begin
	
		if (wr_en & (write_addr != 4'd15)) begin
			memory[write_addr] <= write_data;
		end

		memory[15] = R15;
	end
		
endmodule

// meow meow meow meow mewo
		