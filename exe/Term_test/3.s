;三、控制指令冲突测试
;从这一节起，假设正确处理了延迟槽，行为与模拟器一样，延迟槽里可能填充语句。

;*** 程序说明：R4、R5为循环变量   ***
;***     主要循环体0x06~0x09，4条 ***
;***     每条各执行25,000,000次   ***
;***     共1.00亿条指令           ***

LI R1 0x1
LI R5 0xFF
SLL R5 R5 0x0
ADDIU R5 0x83
LI R4 0x60
CMP R4 R1
BTEQZ 0x3
ADDIU R4 0x1
BNEZ R4 0xFD
CMP R4 R1
BNEZ R5 0xF9
ADDIU R5 0x1
JR R7
NOP

;冲突：(7)ADDIU后接(8)BNEZ
;　　　(7)ADDIU后仅隔一句接延迟槽内的(9)CMP
;　　　延迟槽内的(9)CMP接(6)BTEQZ
;　　　延迟槽内的(9)CMP仅隔一句接(7)ADDIU