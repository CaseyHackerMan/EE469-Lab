/* Oliver Huang [ohlbur] & Casey Culbertson [casey534]
 * Prof. Hussein
 * EE 469
 * 5 May 2023
 * Lab 4 - top.sv
 *
 * top is a structurally made toplevel module. It consists of 3 instantiations, as well as the signals that link them. 
 * It is almost totally self-contained, with no outputs and two system inputs: clk and rst. clk represents the clock 
 * the system runs on, with one instruction being read and executed every cycle. rst is the system reset and should 
 * be run for at least a cycle when simulating the system.
 */

// clk - system clock
// rst - system reset. Technically unnecessary
module top( input logic clk, rst );
    
    // processor io signals   
	logic [31:0] InstrF;
	logic [31:0] ReadDataM;
	logic [31:0] WriteDataM;
	logic [31:0] PCF, ALUOutM;
    logic        MemWriteM;

    // our single cycle arm processor
	arm processor (.*);

    // instruction memory
    // contained machine code instructions which instruct processor on which operations to make
    // effectively a rom because our processor cannot write to it
    imem imemory (
		.addr   (PCF    ),
		.instr  (InstrF )
    );

    // data memory
    // containes data accessible by the processor through ldr and str commands
    dmem dmemory (
        .clk     (clk       ), 
		.wr_en   (MemWriteM ),
		.addr    (ALUOutM   ),
		.wr_data (WriteDataM),
		.rd_data (ReadDataM )
    );


endmodule