BEGIN:
	NOP
	# R0 <= 0000
	# R0 => *8000	
	# R0 <= E000
	# R1 <= FFFF
CLEAR_LOOP:
	# Draw 000 R0
	ADDIU R0 0x1
	SUBU R1 R0 R2
	BNEZ R2 CLEAR_LOOP
	NOP
ROUND_BEGIN:
	NOP
FALL:
	# R0 <= FFFF
FALL_LOOP: 
	# R1 <= {{-(1<<7)}}
	ADDU R0 R1 R1
	# R2 <= *R1
	# R2 => *R0
FALL_LOOP_NEXT:
	# R2 <= E080
	SUBU R2 R0 R2
	BNEZ R2 FALL_LOOP
	ADDIU R0 0xFF
NEW:
	# R0 <= {{int('E000',16)-(1<<7)}}
	# R1 <= *8000
	ADDU R0 R1 R2
	ADDIU R1 0x1
	# R1 => *8000
	# R1 <= 0001
	# R1 => *R2

	# R0 <= E000
NEW_LOOP:
	# R1 <= {{-(1<<7)}}
	ADDU R0 R1 R1
	# R2 <= *R1 ; 0 1 2
	BEQZ R2 NEW_LOOP_NEXT
	# R3 <= 0001
	CMP R2 R3
	BTEQZ ONE
	NOP
TWO:
	# R2 <= {{1}}
	# R2 => *R1
	# R1 <= {{char_data('0','070',False)}}
	# R1 => *R0
	B NEW_LOOP_NEXT
ONE:
	# R2 <= {{2}}
	# R2 => *R1
	# R1 <= {{char_data('0','070',True)}}
	# R1 => *R0
NEW_LOOP_NEXT:
	# R1 <= {{int('E000',16)+80}}
	SUBU R1 R0 R1
	BNEZ R1 NEW_LOOP
	ADDIU R0 0x1
NEXT_ROUND:
	# Wait 1000
	B ROUND_BEGIN
	NOP




