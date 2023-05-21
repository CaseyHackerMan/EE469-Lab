.text
.align=2

.global Start
Start:
	
	mov r0, #4			@Load 4 into r0
	mov r1, #5			@Load 5 into r1
	mov r3, #0			@Load 0 into r3
	add r2, r0, r1		@Add r0 to r1 and place in r2
	add r2, r2, r2		@Add r2 to itself
	sub r2, r2, #3		@Subtract 3 from r2
	str r2, [r3, #156]	@Store r2 in 40th word of memory
S:
	B S					@Infinite loop ending
.end