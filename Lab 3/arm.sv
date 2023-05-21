/* Oliver Huang [ohlbur] & Casey Culbertson [casey534]
 * Prof. Hussein
 * EE 469
 * 5 May 2023
 * Lab 4 - arm.sv
 *
 * arm is the spotlight of the show and contains the bulk of the datapath and
 *	control logic. This module is split into two parts, the datapath and control. 
 */

// clk - system clock
// rst - system reset
// InstrF - incoming 32 bit instruction from imem
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
	logic [31:0] PCPrime, PCPlus4F, PCPlus8D; // pc signals
	logic [31:0] InstrD; 					  // instruction
	logic [ 3:0] RA1D, RA2D;                  // regfile input addresses
	logic [ 3:0] RA1E, RA2E;                  // regfile input addresses
	logic [31:0] RD1D, RD2D;                  // raw regfile outputs
	logic [31:0] RD1E, RD2E;                  // raw regfile outputs
	logic [ 3:0] WA3E, WA3M, WA3W;            // regfile write address
	logic [ 3:0] ALUFlags;                    // alu combinational flag outputs
	logic [31:0] ExtImmD, ExtImmE, SrcAE, SrcBE;      // immediate and alu inputs 
	logic [31:0] ResultW, ALUResultE;   	  // computed or fetched value to be 
											  // 	written into regfile or pc
	logic [31:0] WriteDataE, ReadDataW, ALUOutW;      // memory signals


	// control signals
	logic PCSrcD, PCSrcE, PCSrcM, PCSrcW;
	logic RegWriteD, RegWriteE, RegWriteM, RegWriteW;
	logic MemtoRegD, MemtoRegE, MemtoRegM, MemtoRegW;
	logic MemWriteD, MemWriteE;
	logic [1:0] ALUControlD, ALUControlE;
	logic BranchD, BranchE, BranchTakenE;
	logic ALUSrcD, ALUSrcE;
	logic [1:0] FlagWriteD, FlagWriteE;
	logic [3:0] CondE;
	logic [3:0] FlagsPrime, FlagsE;  //prev FlagsReg
	logic [1:0] ImmSrcD;
	logic [1:0] RegSrcD;
	logic CondExE;

	// hazard signals
	logic StallF, StallD, FlushD, FlushE;
	logic Match_1E_M, Match_2E_M, Match_1E_W, Match_2E_W;
	logic Match_12D_E, ldrStallD, PCWrPendingF;
	logic [1:0] ForwardAE, ForwardBE;

	parameter NOP = 32'hE1A00000;  // MOV R0, R0 (do nothing)

    //-------------------------------------------------------------------------------
    //                                      DATAPATH
    //-------------------------------------------------------------------------------
	
	// D registers
	always_ff @(posedge clk) begin
		if (~StallD) begin
			if (~FlushD)
				InstrD <= InstrF;
			else
				InstrD <= NOP;
		end
		// holds old value if stall (automatic)
	end
	
	// E registers
	always_ff @(posedge clk) begin
		if (~FlushE) begin
			PCSrcE <= PCSrcD;
			RegWriteE <= RegWriteD;
			MemtoRegE <= MemtoRegD;
			MemWriteE <= MemWriteD;
			ALUControlE <= ALUControlD;
			BranchE <= BranchD;
			ALUSrcE <= ALUSrcD;
			FlagWriteE <= FlagWriteD;
			CondE <= InstrD[31:28];
			FlagsE <= FlagsPrime;
			RA1E <= RA1D;
			RA2E <= RA2D;
			RD1E <= RD1D;
			RD2E <= RD2D;
			WA3E <= InstrD[15:12];
			ExtImmE <= ExtImmD;
		end else begin
			PCSrcE <= 1'b0;
			RegWriteE <= 1'b0;
			MemtoRegE <= 1'b0;
			MemWriteE <= 1'b0;
			ALUControlE <= 2'b0;
			BranchE <= 1'b0;
			ALUSrcE <= 1'b0;
			FlagWriteE <= 2'b0;
			CondE <= 4'b1110;  // open the floodgates
			FlagsE <= 4'b0;
			RA1E <= 4'b0;
			RA2E <= 4'b0;
			RD1E <= 32'b0;
			RD2E <= 32'b0;
			WA3E <= 4'b0;
			ExtImmE <= 32'b0;
		end
	end

	assign BranchTakenE = BranchE & CondExE;

	// M registers
	always_ff @(posedge clk) begin
		PCSrcM <= PCSrcE & CondExE;
		RegWriteM <= RegWriteE & CondExE;
		MemtoRegM <= MemtoRegE;
		MemWriteM <= MemWriteE & CondExE;
		ALUOutM <= ALUResultE;
		WriteDataM <= WriteDataE;
		WA3M <= WA3E;
	end

	// W registers
	always_ff @(posedge clk) begin
		PCSrcW <= PCSrcM;
		RegWriteW <= RegWriteM;
		MemtoRegW <= MemtoRegM;
		ReadDataW <= ReadDataM;
		ALUOutW <= ALUOutM;
		WA3W <= WA3M;
	end

	// mux, use either default or newly computed value
	assign PCPrime = BranchTakenE ? ALUResultE : (PCSrcW ? ResultW : PCPlus4F);  

	assign PCPlus4F = PCF + 'd4;                  // default value to access next instruction
	assign PCPlus8D = PCPlus4F;                   // value read when reading from reg[15]

	// update the PC, at rst initialize to 0
	always_ff @(posedge clk) begin
		if (~StallF) begin
			if (rst) PCF <= '0;
	  		else     PCF <= PCPrime;
		end
		// hold old value if stall
	end

	always_comb begin
		if (FlagWriteE[0]) FlagsPrime[1:0] = ALUFlags[1:0];
		if (FlagWriteE[1]) FlagsPrime[3:2] = ALUFlags[3:2];
	end

	// determine the register addresses based on control signals
	// RegSrc[0] is set if doing a branch instruction
	// RefSrc[1] is set when doing memory instructions
	assign RA1D = RegSrcD[0] ? 4'd15        : InstrD[19:16];
	assign RA2D = RegSrcD[1] ? InstrD[15:12] : InstrD[ 3: 0];

	// instantiates the registers
	reg_file u_reg_file (
		.clk       (~clk), 
		.wr_en     (RegWriteW),
		.write_data(ResultW),
		.write_addr(WA3W),
		.read_addr1(RA1D), 
		.read_addr2(RA2D),
		.R15(PCPlus8D),
		.read_data1(RD1D), 
		.read_data2(RD2D)
	);

	// two muxes, put together into an always_comb for clarity
	// determines which set of instruction bits are used for the immediate
	always_comb begin
		if (ImmSrcD == 'b00) 
			ExtImmD = {{24{InstrD[7]}},InstrD[7:0]};          // 8 bit immediate - reg operations
		else if (ImmSrcD == 'b01)
			ExtImmD = {20'b0, InstrD[11:0]};                  // 12 bit immediate - mem operations
		else
			ExtImmD = {{6{InstrD[23]}}, InstrD[23:0], 2'b00}; // 24 bit immediate - branch operation
	end

	// WriteData and SrcA are direct outputs of the register file,
	// wheras SrcB is chosen between reg file output and the immediate
	always_comb begin
		case(ForwardAE)
			2'b00: SrcAE = RD1E;
			2'b01: SrcAE = ResultW;
			2'b10: SrcAE = ALUOutM;
		endcase
	
		case(ForwardBE)
			2'b00: WriteDataE = RD2E;
			2'b01: WriteDataE = ResultW;
			2'b10: WriteDataE = ALUOutM;
		endcase

		SrcBE = ALUSrcE ? ExtImmE : WriteDataE;  // determine other alu operand
	end
    
	// instantiates the alu
	alu u_alu (
		.a          (SrcAE), 
		.b          (SrcBE),
		.ALUControl (ALUControlE),
		.Result     (ALUResultE),
		.ALUFlags   (ALUFlags)
	);

	// determine the result to run back to PC or the register file based on whether we used a memory instruction
	assign ResultW = MemtoRegW ? ReadDataW : ALUOutW;  // determine whether final writeback result is 
													   // from dmemory or alu

    /* The hazard unit handles the hazards introduced by pipelining. It controls the
	** forwarding, stalling, and flushing needed to ensure correct excecution.
	*/
    //-------------------------------------------------------------------------------
    //                                HAZARD UNIT
    //-------------------------------------------------------------------------------
	
	// match detection
	assign Match_1E_M = (RA1E == WA3M);
	assign Match_1E_W = (RA1E == WA3W);
	assign Match_2E_M = (RA2E == WA3M);
	assign Match_2E_W = (RA2E == WA3W);
	assign Match_12D_E = (RA1D == WA3E) | (RA2D == WA3E);

	// stalling and flushing control
	assign ldrStallD = Match_12D_E & MemtoRegE;
	assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;  
	assign StallF = ldrStallD | PCWrPendingF;  // stall fetch
	assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;
	assign FlushE = ldrStallD | BranchTakenE;
	assign StallD = ldrStallD;
	
	always_comb begin
		// ForwardAE logic
		if (Match_1E_M & RegWriteM) ForwardAE = 2'b10;
		else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;
		else ForwardAE = 2'b00;

		// ForwardBE logic
		if (Match_2E_M & RegWriteM) ForwardBE = 2'b10;
		else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01;
		else ForwardBE = 2'b00;
	end

	//-------------------------------------------------------------------------------
	//                                      CONTROL
	//-------------------------------------------------------------------------------
	
	// sets conditional excecution based on conditional and flags (N, Z, C, V)
	always_comb begin
		case (CondE)
			4'b0000 : CondExE = FlagsE[2]; // EQ
			4'b0001 : CondExE = ~FlagsE[2];// NE
			4'b1010 : CondExE = ~(FlagsE[3] ^ FlagsE[0]); // GE
			4'b1100 : CondExE = ~FlagsE[2] & ~(FlagsE[3] ^ FlagsE[0]); // GT
			4'b1101 : CondExE = FlagsE[2] | (FlagsE[3] ^ FlagsE[0]); // LE
			4'b1011 : CondExE = FlagsE[3] ^ FlagsE[0]; // LT
			4'b1110 : CondExE = 1;
			default:  CondExE = 0;
		endcase
	end
				
    // set contol signals 
    always_comb begin
		
		casez (InstrD[27:20])
			// ADD/ADDS (Imm or Reg)
			8'b00?_0100_? : begin   // bit 20 sets flags (ADDS), bit 25 decides immediate or reg
				PCSrcD    = 0;
				MemtoRegD = 0; 
				MemWriteD = 0; 
				ALUSrcD   = InstrD[25]; // may use immediate
				RegWriteD = 1;
				RegSrcD   = 'b00;
				ImmSrcD   = 'b00; 
				BranchD   = 0;
				ALUControlD = 'b00;
				FlagWriteD  = InstrD[20] ? 'b11 : 'b00;
			end
	
			// SUB/SUBS (Imm or Reg)
			8'b00?_0010_? : begin   // bit 20 sets flags (SUBS), bit 25 decides immediate or reg
				PCSrcD    = 0; 
				MemtoRegD = 0; 
				MemWriteD = 0; 
				ALUSrcD   = InstrD[25]; // may use immediate
				RegWriteD = 1;
				RegSrcD   = 'b00;
				ImmSrcD   = 'b00; 
				BranchD   = 0;
				ALUControlD = 'b01;
				FlagWriteD  = InstrD[20] ? 'b11 : 'b00;
			end
			
			// CMP (Imm or Reg)
			8'b00?_1010_1 : begin   // bit 25 decides immediate or reg
				PCSrcD    = 0; 
				MemtoRegD = 0; 
				MemWriteD = 0; 
				ALUSrcD   = InstrD[25]; // may use immediate
				RegWriteD = 1;
				RegSrcD   = 'b00;
				ImmSrcD   = 'b00;
				BranchD   = 0; 
				ALUControlD = 'b01;
				FlagWriteD  = 'b11;
			end
	
			// AND/ANDS
			8'b000_0000_? : begin // bit 20 sets flags (ANDS)
				PCSrcD    = 0; 
				MemtoRegD = 0; 
				MemWriteD = 0; 
				ALUSrcD   = 0; 
				RegWriteD = 1;
				RegSrcD   = 'b00;
				ImmSrcD   = 'b00;    // doesn't matter
				BranchD   = 0;
				ALUControlD = 'b10;  
				FlagWriteD  = InstrD[20] ? 'b10 : 'b00;
			end
	
			// ORR/ORRS
			8'b000_1100_? : begin // bit 20 sets flags (ORRS)
				PCSrcD    = 0; 
				MemtoRegD = 0; 
				MemWriteD = 0; 
				ALUSrcD   = 0; 
				RegWriteD = 1;
				RegSrcD   = 'b00;
				ImmSrcD   = 'b00;    // doesn't matter
				BranchD   = 0;
				ALUControlD = 'b11;
				FlagWriteD  = InstrD[20] ? 'b10 : 'b00;
			end
	
			// LDR
			8'b010_1100_1 : begin
				PCSrcD    = 0; 
				MemtoRegD = 1; 
				MemWriteD = 0; 
				ALUSrcD   = 1;
				RegWriteD = 1;
				RegSrcD   = 'b10;    // msb doesn't matter
				ImmSrcD   = 'b01; 
				BranchD   = 0;
				ALUControlD = 'b00;  // do an add
				FlagWriteD  = 'b00;
			end
	
			// STR
			8'b010_1100_0 : begin
				PCSrcD    = 0; 
				MemtoRegD = 0; // doesn't matter
				MemWriteD = 1; 
				ALUSrcD   = 1;
				RegWriteD = 0;
				RegSrcD   = 'b10;    // msb doesn't matter
				ImmSrcD   = 'b01; 
				BranchD   = 0;
				ALUControlD = 'b00;  // do an add
				FlagWriteD  = 'b00;
			end
	
			// B
			8'b1010_???? : begin
					PCSrcD    = 1; 
					MemtoRegD = 0;
					MemWriteD = 0; 
					ALUSrcD   = 1;
					RegWriteD = 0;
					RegSrcD   = 'b01;
					ImmSrcD   = 'b10;
					BranchD   = 1; 
					ALUControlD = 'b00;  // do an add
					FlagWriteD  = 'b00;
			end
	
			default: begin
				PCSrcD    = 0; 
				MemtoRegD = 0; // doesn't matter
				MemWriteD = 0; 
				ALUSrcD   = 0;
				RegWriteD = 0;
				RegSrcD   = 'b00;
				ImmSrcD   = 'b00; 
				BranchD   = 0;
				ALUControlD = 'b00;  // do an add
				FlagWriteD  = 'b00;
			end
		endcase
	end
	
endmodule