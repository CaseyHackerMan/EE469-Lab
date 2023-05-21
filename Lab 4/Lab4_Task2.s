@Oliver Huang & Casey Culbertson
@Prof. Hussein
@Lab 4 Task 2
@19 May 2023

@An algorithm that counts the 1s of a 32 bit number
@Number to count from is passed as argument using R0
@R0 stores result when done

.global _start
_start:
	MOV R0, #0xFF			@Load R0 with 32 ones for testing
	ORR R0, R0, #0xFF00		
	ORR R0, R0, #0xFF0000
	ORR R0, R0, #0xFF000000
	BL COUNT				@call count 1s function. R0 is argument
	B STOP					@go to infinite loop to stop 

COUNT:
	@num should be passed as argument using R0
	PUSH {R4, R5, R6, R7}	@save regs that could be disturbed
	MOV R1, #0				@tally
	MOV R2, #0				@iterator var

LOOP:
	CMP R2, #32				@check i less than 32
	BGE RET					@exit if i >= 32
	AND R3, R0, #1			@bitwise AND
	CMP R3, #1				@check if lsb of num = 1
	ADDEQ R1, R1, #1		@increment tally if lsb was 1
	LSR R0, R0, #1			@shift num right to check next bit
	ADD R2, R2, #1			@increment i
	B LOOP					@continue loop
	
RET:
	MOV R0, R1
	POP {R4, R5, R6, R7}	@restore regs
	MOV PC, LR
STOP:
	B STOP					@infinite loop for testing/ending
.end