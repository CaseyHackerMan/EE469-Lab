/* arm is the spotlight of the show and contains the bulk of the datapath and
**	control logic. This module is split into two parts, the datapath and control. 
*/

// clk - system clock
// rst - system reset
// InstrF - incoming 32 bit instruction from imem, contains opcode, condition, addresses and or immediates
// ReadData - data read out of the dmem
// WriteData - data to be written to the dmem
// MemWrite - write enable to allowed WriteData to overwrite an existing dmem word
// PC - the current program count value, goes to imem to fetch instruciton
// ALUResult - result of the ALU operation, sent as address to the dmem

module arm (
    input  logic        clk, rst,
	input  logic [31:0] InstrF,
	input  logic [31:0] ReadDataM,
	output logic [31:0] WriteDataM, 
	output logic [31:0] PCF, ALUOutM,
    output logic        MemWriteM
);

	// datapath buses and signals
	logic [31:0] PCPrime, PCPlus4F, PCPlus8; // pc signals
	logic [31:0] InstrD;
	logic [ 3:0] RA1D, RA2D;                  // regfile input addresses
	logic [31:0] RD1D, RD2D;                  // raw regfile outputs
	logic [31:0] RD1E, RD2E;                  // raw regfile outputs
	logic [ 3:0] WA3E, WA3M, WA3W;            // regfile write address
	logic [ 3:0] ALUFlags;                  // alu combinational flag outputs
	logic [31:0] ExtImmD, ExtImmE, SrcA, SrcB;        // immediate and alu inputs 
	logic [31:0] ResultW;                    // computed or fetched value to be written into regfile or pc


	// control signals
	logic PCSrcD, RegWriteD, MemtoRegD, MemWriteD, BranchD, ALUSrcD, CondEx;
	logic PCSrcE, RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, 
	logic [1:0] RegSrcD, ImmSrcD, ALUControlD, FlagWriteD;
	logic [3:0] Flags, FlagsE; //prev FlagsReg
	logic [3:0] CondE, 


    /* The datapath consists of a PC as well as a series of muxes to make decisions about which data words
	 ** to pass forward and operate on. It is noticeably missing the register file and alu, which you will 
	 ** fill in using the modules made in lab 1. To correctly match up signals to the ports of the register
	 ** file and alu take some time to study and understand the logic and flow of the datapath.
    */
    //-------------------------------------------------------------------------------
    //                                      DATAPATH
    //-------------------------------------------------------------------------------

	always_ff @(posedge clk) begin
		InstrD <= InstrF;
		PCPlus8 <= PCPlus4F + 'd4;
		RD1E <= RD1D;
		RD2E <= RD2D;
		WA3E <= InstrD[15:12];
		WA3M <= WA3E;
		WA3W <= WA3M;
		ExtImmE <= ExtImmD;
		ALUOutM <= ALUResultE;
		WriteDataM <= WriteDataE;
		ALUOutW <= ALUOutM;
		ReadDataW <= ReadDataM;
	end

	assign PCPrime = PCSrc ? Result : PCPlus4;  // mux, use either default or newly computed value
	assign PCPlus4F = PCF + 'd4;                  // default value to access next instruction
	// assign PCPlus8 = PCPlus4 + 'd4;             // value read when reading from reg[15]

	// update the PC, at rst initialize to 0
	always_ff @(posedge clk) begin
	  if (rst) PC <= '0;
	  else     PC <= PCPrime;
	end
	 
	// writing to flag registers
	always_ff @(posedge clk) begin
		if (FlagWrite[0]) FlagsReg[1:0] <= ALUFlags[1:0];
		if (FlagWrite[1]) FlagsReg[3:2] <= ALUFlags[3:2];
	end

	// determine the register addresses based on control signals
	// RegSrc[0] is set if doing a branch instruction
	// RefSrc[1] is set when doing memory instructions
	assign RA1D = RegSrc[0] ? 4'd15        : InstrD[19:16];
	assign RA2D = RegSrc[1] ? InstrD[15:12] : InstrD[ 3: 0];

	// instantiates the registers
	reg_file u_reg_file (
		.clk       (~clk), 
		.wr_en     (RegWriteW),
		.write_data(ResultW),
		.write_addr(WA3W),
		.read_addr1(RA1D), 
		.read_addr2(RA2D),
		.read_data1(RD1D), 
		.read_data2(RD2D)
	);

	// two muxes, put together into an always_comb for clarity
	// determines which set of instruction bits are used for the immediate
	always_comb begin
		if      (ImmSrc == 'b00) 
						ExtImmD = {{24{InstrD[7]}},InstrD[7:0]};          // 8 bit immediate - reg operations
		else if (ImmSrc == 'b01)
						ExtImmD = {20'b0, InstrD[11:0]};                 // 12 bit immediate - mem operations
		else         ExtImmD = {{6{InstrD[23]}}, InstrD[23:0], 2'b00}; // 24 bit immediate - branch operation
	end

	// WriteData and SrcA are direct outputs of the register file,
	// wheras SrcB is chosen between reg file output and the immediate
	always_comb begin
		case(ForwardAE)
			2'b00: SrcAE = RD1E;
			2'b01: SrcAE = ResultW;
			2'b10: SrcAE = ALUOutM;
		endcase

		SrcBE = ALUSrcE ? ExtImmE : WriteDataE;
		
		case(ForwardBE)
			2'b00: WriteDataE = RD2E;
			2'b01: WriteDataE = ResultW;
			2'b10: WriteDataE = ALUOutM;
		endcase
	end
    
	// instantiates the alu
	alu u_alu (
		.a          (SrcA), 
		.b          (SrcB),
		.ALUControl (ALUControl),
		.Result     (ALUResultE),
		.ALUFlags   (ALUFlags)
	);

	// determine the result to run back to PC or the register file based on whether we used a memory instruction
	assign Result = MemtoReg ? ReadDataW : ALUOutW;  // determine whether final writeback result is 
																	//  from dmemory or alu


	/* The control conists of a large decoder, which evaluates the top bits of the instruction and 
	** produces the control bits which become the select bits and write enables of the system. The 
	** write enables (RegWrite, MemWrite and PCSrc) are especially important because they are 
	** representative of your processors current state. 
	*/
	//-------------------------------------------------------------------------------
	//                                      CONTROL
	//-------------------------------------------------------------------------------


	
	// sets conditional excecution based on conditional and flags (N, Z, C, V)
	always_comb begin
		case (InstrD[31:28])
			4'b0000 : CondEx = FlagsReg[2]; // EQ
			4'b0001 : CondEx = ~FlagsReg[2];// NE
			4'b1010 : CondEx = ~(FlagsReg[3] ^ FlagsReg[0]); // GE
			4'b1100 : CondEx = ~FlagsReg[2] & ~(FlagsReg[3] ^ FlagsReg[0]); // GT
			4'b1101 : CondEx = FlagsReg[2] | (FlagsReg[3] ^ FlagsReg[0]); // LE
			4'b1011 : CondEx = FlagsReg[3] ^ FlagsReg[0]; // LT
			default:  CondEx = 1;
		endcase
	end
				
    // set contol signals 
    always_comb begin
		if (CondEx) begin
			casez (InstrD[27:20])
	
				// ADD/ADDS (Imm or Reg)
				8'b00?_0100_? : begin   // bit 20 sets flags (ADDS), bit 25 decides immediate or reg
					PCSrc    = 0;
					MemtoReg = 0; 
					MemWrite = 0; 
					ALUSrc   = InstrD[25]; // may use immediate
					RegWrite = 1;
					RegSrc   = 'b00;
					ImmSrc   = 'b00; 
					ALUControl = 'b00;
					FlagWrite = InstrD[20] ? 'b11 : 'b00;
				end
	
				// SUB/SUBS (Imm or Reg)
				8'b00?_0010_? : begin   // bit 20 sets flags (SUBS), bit 25 decides immediate or reg
					PCSrc    = 0; 
					MemtoReg = 0; 
					MemWrite = 0; 
					ALUSrc   = InstrD[25]; // may use immediate
					RegWrite = 1;
					RegSrc   = 'b00;
					ImmSrc   = 'b00; 
					ALUControl = 'b01;
					FlagWrite = InstrD[20] ? 'b11 : 'b00;
				end
				
				// CMP (Imm or Reg)
				8'b00?_1010_1 : begin   // bit 25 decides immediate or reg
					PCSrc    = 0; 
					MemtoReg = 0; 
					MemWrite = 0; 
					ALUSrc   = InstrD[25]; // may use immediate
					RegWrite = 1;
					RegSrc   = 'b00;
					ImmSrc   = 'b00; 
					ALUControl = 'b01;
					FlagWrite = 'b11;
				end
	
				// AND/ANDS
				8'b000_0000_? : begin // bit 20 sets flags (ANDS)
					PCSrc    = 0; 
					MemtoReg = 0; 
					MemWrite = 0; 
					ALUSrc   = 0; 
					RegWrite = 1;
					RegSrc   = 'b00;
					ImmSrc   = 'b00;    // doesn't matter
					ALUControl = 'b10;  
					FlagWrite = InstrD[20] ? 'b10 : 'b00;
				end
	
				// ORR/ORRS
				8'b000_1100_? : begin // bit 20 sets flags (ORRS)
					PCSrc    = 0; 
					MemtoReg = 0; 
					MemWrite = 0; 
					ALUSrc   = 0; 
					RegWrite = 1;
					RegSrc   = 'b00;
					ImmSrc   = 'b00;    // doesn't matter
					ALUControl = 'b11;
					FlagWrite = InstrD[20] ? 'b10 : 'b00;
				end
	
				// LDR
				8'b010_1100_1 : begin
					PCSrc    = 0; 
					MemtoReg = 1; 
					MemWrite = 0; 
					ALUSrc   = 1;
					RegWrite = 1;
					RegSrc   = 'b10;    // msb doesn't matter
					ImmSrc   = 'b01; 
					ALUControl = 'b00;  // do an add
					FlagWrite = 'b00;
				end
	
				// STR
				8'b010_1100_0 : begin
					PCSrc    = 0; 
					MemtoReg = 0; // doesn't matter
					MemWrite = 1; 
					ALUSrc   = 1;
					RegWrite = 0;
					RegSrc   = 'b10;    // msb doesn't matter
					ImmSrc   = 'b01; 
					ALUControl = 'b00;  // do an add
					FlagWrite = 'b00;
				end
	
				// B
				8'b1010_???? : begin
						PCSrc    = 1; 
						MemtoReg = 0;
						MemWrite = 0; 
						ALUSrc   = 1;
						RegWrite = 0;
						RegSrc   = 'b01;
						ImmSrc   = 'b10; 
						ALUControl = 'b00;  // do an add
						FlagWrite = 'b00;
				end
	
				default: begin
					PCSrc    = 0; 
						MemtoReg = 0; // doesn't matter
						MemWrite = 0; 
						ALUSrc   = 0;
						RegWrite = 0;
						RegSrc   = 'b00;
						ImmSrc   = 'b00; 
						ALUControl = 'b00;  // do an add
						FlagWrite  = 'b00;
				end
			endcase
		end 
		else begin
			PCSrc    = 0; 
			MemtoReg = 0; // doesn't matter
			MemWrite = 0; 
			ALUSrc   = 0;
			RegWrite = 0;
			RegSrc   = 'b00;
			ImmSrc   = 'b00; 
			ALUControl = 'b00;  // do an add
			FlagWrite  = 'b00;
    	end
	end
endmodule