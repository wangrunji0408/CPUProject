;一、性能标定
;这段程序一般没有数据冲突和结构冲突，可作为性能标定。

;*** 程序说明：R4、R5为循环变量   ***
;***     主要循环体0x0D~0x12，6条 ***
;***     每条各执行25,000,000次   ***
;***     共1.50亿条指令           ***
;***     （行号从0开始）          ***

LI R5 0xFF
NOP
NOP
NOP
SLL R5 R5 0x0
NOP
NOP
NOP
ADDIU R5 0x82
LI R4 0x60
NOP
NOP
NOP
ADDIU R4 0x1
LI R0 0x0
LI R1 0x1
LI R2 0x2
BNEZ R4 0xFB
NOP
ADDIU R5 0x1
NOP
NOP
NOP
BNEZ R5 0xF1
NOP
JR R7
NOP