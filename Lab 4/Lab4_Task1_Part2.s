.global _start
PUSH {R0, R1}
	
	MOV r0, #5
LOOP:
	
	CMP R0, #1
	BGT ELSE
	MOV R0, #1
	POP {R1, R2}
	MOV PC, LR
ELSE:
	SUB R0, R0, #1
	BL LOOP
	POP {R1, LR}
	MUL R0, R1, R0
	MOV PC, LR
	.end
