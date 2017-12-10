; Run this first
; Then G 42BD
; Time @ 4343

NOP

; 清空屏幕
# R0 <= E000
# R1 <= FFFF
# Draw 000 R0
SUBU R1 R0 R2
BNEZ R2 0xFC
ADDIU R0 0x1

# Draw 777 (6,10)
# Draw 777 (7,10)
# Draw 777 (6,11)
# Draw 777 (7,11)

# Draw 777 (16,10)
# Draw 777 (16,11)
# Draw 777 (16,12)
# Draw 777 (17,9)
# Draw 777 (17,13)
# Draw 777 (18,8)
# Draw 777 (19,8)
# Draw 777 (18,14)
# Draw 777 (19,14)

# Draw 777 (20,11)
# Draw 777 (21,9)
# Draw 777 (21,13)
# Draw 777 (22,10)
# Draw 777 (22,11)
# Draw 777 (22,12)
# Draw 777 (23,11)


# Draw 777 (26,8)
# Draw 777 (26,9)
# Draw 777 (26,10)
# Draw 777 (27,8)
# Draw 777 (27,9)
# Draw 777 (27,10)
# Draw 777 (28,7)
# Draw 777 (28,11)
# Draw 777 (30,6)
# Draw 777 (30,7)
# Draw 777 (30,11)
# Draw 777 (30,12)

# Draw 777 (40,8)
# Draw 777 (40,9)
# Draw 777 (41,8)
# Draw 777 (41,9)



