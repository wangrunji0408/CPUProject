;�塢��дָ��洢������

;*** ����˵����R4��R5Ϊѭ������   ***
;***     ��Ҫѭ����0x07~0x09��3�� ***
;***     ÿ����ִ��25,000,000��   ***
;***     ��0.75����ָ��           ***

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

;��ͻ��(7)SWдָ��洢��
;�������ӳٲ���(9)ADDIU��(7)SW
;�������ӳٲ���(9)ADDIU��(8)BNEZ