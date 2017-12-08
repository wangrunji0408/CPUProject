BEGIN:
	NOP
	# R0 <= E000
	# R1 <= FFFF
	# Debug Clear
CLEAR_LOOP:
	# Draw 000 R0
	ADDIU R0 0x1
	SUBU R1 R0 R2
	BNEZ R2 CLEAR_LOOP
	NOP
INIT:
	# Print GameOfLife (30,0)
	# Draw 777 (10,10)
	# Draw 777 (10,11)
	# Draw 777 (10,12)
ROUND_START: NOP
MOVE_MEM:
	# Debug MoveMem
	; Move E000-FFFF to C000-DFFF
	# R0 <= E000
	# R1 <= C000
MOVE_MEM_LOOP:
	# R2 <= *R1
	ADDIU R1 0x1	
	# R2 => *R0
	ADDIU R0 0x1
	# R2 <= FFFF
	SUBU R2 R0 R2
	BNEZ R2 MOVE_MEM_LOOP
	NOP
CALC:
	# Debug Calc
	# R0 <= C000 ;addr
CALC_LOOP: NOP
TEST_RANGE: NOP
TEST_X:
	# R1 <= 007F
	AND R1 R0		; R1 = x
	# R2 <= 0000
	SLT R2 R1		; if x <= 0
	BTEQZ CALC_LOOP_NEXT 
	# R2 <= {{80}}
	SLT R1 R2		; if x >= 80
	BTEQZ CALC_LOOP_NEXT
TEST_Y:
	# R1 <= {{((1<<6)-1)<<7}}
	AND R1 R0		; R1 = y
	# R2 <= {{4<<7}}
	SLT R2 R1		; if y <= 4
	BTEQZ CALC_LOOP_NEXT 
	# R2 <= {{50<<7}}
	SLT R1 R2		; if y >= 50
	BTEQZ CALC_LOOP_NEXT
	
CALC_SUM:
	# R1 <= 0000 ;count

	# R2 <= {{1}}
	ADDU R0 R2 R2
	# R2 <= *R2
	# R3 <= 0001
	AND R3 R2
	ADDU R1 R3 R1

	# R2 <= {{-1}}
	ADDU R0 R2 R2
	# R2 <= *R2
	# R3 <= 0001
	AND R3 R2
	ADDU R1 R3 R1

	# R2 <= {{(1<<7)}}
	ADDU R0 R2 R2
	# R2 <= *R2
	# R3 <= 0001
	AND R3 R2
	ADDU R1 R3 R1

	# R2 <= {{(1<<7)+1}}
	ADDU R0 R2 R2
	# R2 <= *R2
	# R3 <= 0001
	AND R3 R2
	ADDU R1 R3 R1

	# R2 <= {{(1<<7)-1}}
	ADDU R0 R2 R2
	# R2 <= *R2
	# R3 <= 0001
	AND R3 R2
	ADDU R1 R3 R1

	# R2 <= {{-(1<<7)}}
	ADDU R0 R2 R2
	# R2 <= *R2
	# R3 <= 0001
	AND R3 R2
	ADDU R1 R3 R1

	# R2 <= {{-(1<<7)+1}}
	ADDU R0 R2 R2
	# R2 <= *R2
	# R3 <= 0001
	AND R3 R2
	ADDU R1 R3 R1

	# R2 <= {{-(1<<7)-1}}
	ADDU R0 R2 R2
	# R2 <= *R2
	# R3 <= 0001
	AND R3 R2
	ADDU R1 R3 R1

TEST_NOW:
	# R2 <= *R0 ;self
	BNEZ R2 CASE_ALIVE
	NOP
CASE_DEAD:
	; alive when = 3
	# R2 <= 0003
	CMP R2 R1
	BTEQZ ALIVE
	NOP
	B DEAD
	NOP
CASE_ALIVE:
	; alive when = 2 | 3
	# R2 <= 0003
	CMP R2 R1
	BTEQZ ALIVE
	NOP
	# R2 <= 0002
	CMP R2 R1
	BTEQZ ALIVE
	NOP
	B DEAD
	NOP
DEAD:
	# R1 <= 0000
	B WRITE_BACK
	NOP
ALIVE:
	# R1 <= 01FF
WRITE_BACK:
	# R2 <= {{1<<13}}
	OR R2 R0
	# R1 => *R2
CALC_LOOP_NEXT:
	# R5 <= DFFF
	SUBU R5 R0 R5
	BNEZ R5 CALC_LOOP
	ADDIU R0 0x1

	# Return

	# Wait 0500 
	B ROUND_START
	NOP

