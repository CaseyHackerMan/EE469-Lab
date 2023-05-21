@ Oliver Huang & Casey Culbertson
@ Prof. Hussein
@ Lab 4 Task 2
@ 19 May 2023

@ An algorithm that adds two 32-bit floats
@ First float is passed as argument in R0
@ Second float is passed as argument in R0
@ R0 stores result when done

.global _start
_start:
    @R0 and R1 are arguments
    BL FLOATADD
    B _done
FLOATADD:
    PUSH {R4, R5, R6, R7}    @save regs that could be disturbed
    MOV   R2, R0
    MOV   R5, #0xff000000
    ORR   R5, R5, #0x00800000
    AND   R3, R1, R5
    LSR   R3, R3, #23         @ exp1 in R3
    AND   R0, R2, R5
    LSR   R0, R0, #23         @ exp2 in R0
    SUBS  R6, R0, R3
    SUBMI R6, R3, R0          @ exp diff in R6
    MOVMI R0, R3
    LSL   R0, R0, #23         @ larger exponent in R0
    MVN   R5, R5
    AND   R4, R1, R5
    AND   R3, R2, R5
    ANDPL R3, R1, R5          @ smaller frac in R3
    ANDPL R4, R2, R5          @ larger frac in R4
    ORR   R3, R3, #0x00800000
    ORR   R4, R4, #0x00800000
    LSR   R3, R3, R6
    ADD   R3, R3, R4
    CMP   R3, #0x01000000    @ check for overflow
    LSRPL R3, R3, #1         @ shift result if overflow
    ANDMI R3, R3, R5         @ else remove leading 1
    ADD   R0, R0, R3
    POP {R4, R5, R6, R7}    @restore regs
    MOV PC, LR
_done:
    B _done                    @infinite loop for testing/ending
.end