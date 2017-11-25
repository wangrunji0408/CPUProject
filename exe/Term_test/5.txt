;五、读写指令存储器测试

;*** 程序说明：R4、R5为循环变量   ***
;***     主要循环体0x07~0x09，3条 ***
;***     每条各执行25,000,000次   ***
;***     共0.75亿条指令           ***

LI R2 0xFF
LI R3 0x55
SLL R3 R3 0x0
LI R5 0xFF
SLL R5 R5 0x0
ADDIU R5 0x83
LI R4 0x61
SW R3 R4 0x1
BNEZ R4 0xFE
ADDIU R4 0x1
BNEZ R5 0xFB
ADDIU R5 0x1
JR R7
NOP

;冲突：(7)SW写指令存储器
;　　　延迟槽内(9)ADDIU后(7)SW
;　　　延迟槽内(9)ADDIU后(8)BNEZ