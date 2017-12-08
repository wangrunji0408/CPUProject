;二、运算数据冲突的效率测试
;从这一节起，假设正确处理了数据冲突，有数据冲突的地方不再加NOP。

;*** 程序说明：R4、R5为循环变量   ***
;***     主要循环体0x05~0x0D，9条 ***
;***     每条各执行25,000,000次   ***
;***     共2.25亿条指令           ***

LI R1 0x55
LI R5 0xFF
SLL R5 R5 0x0
ADDIU R5 0x82
LI R4 0x60
ADDU R1 R1 R2
ADDU R2 R1 R3
SUBU R3 R2 R2
CMP R1 R2
ADDU R2 R3 R2
BEQZ R4 0x3
ADDIU R4 0x1
BTEQZ 0xF8
NOP
ADDIU R5 0x1
BNEZ R5 0xF4
NOP
JR R7
NOP


;冲突：(5)ADDU后接(6)ADDU
;　　　(5)ADDU、(6)ADDU后接(7)SUBU
;　　　(7)SUBU后接(8)CMP
;　　　(6)ADDU、(7)SUBU后接(9)ADDU
;
;行号从0开始，非主要循环体内的冲突不计