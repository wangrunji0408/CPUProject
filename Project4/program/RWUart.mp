BEGIN:	
	# R2 <= *BF00
	# R0 <= 00FF
	AND R2 R0			; R2 <= R2 & 0x00FF
	# R2 => *BF00

