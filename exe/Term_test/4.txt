;四、访存数据冲突性能测试

;*** 程序说明：R4、R5为循环变量   ***
;***     主要循环体0x07~0x0C，6条 ***
;***     每条各执行25,000,000次   ***
;***     共1.50亿条指令           ***

LI R2 0xFF
LI R3 0xC0
SLL R3 R3 0x0
LI R5 0xFF
SLL R5 R5 0x0
ADDIU R5 0x83
LI R1 0x61
SW R3 R1 0x2
LW R3 R4 0x2
SW R3 R4 0x1
LW R3 R1 0x1
BNEZ R4 0xFB
ADDIU R1 0x1
BNEZ R5 0xF8
ADDIU R5 0x1
JR R7
NOP

;冲突：(8)LW后(9)SW
;　　　(8)LW后(B)BNEZ
;　　　(A)LW后延迟槽内(C)ADDIU
;　　　延迟槽内(C)ADDIU后(7)SW