;�����������ݳ�ͻ��Ч�ʲ���
;����һ���𣬼�����ȷ���������ݳ�ͻ�������ݳ�ͻ�ĵط����ټ�NOP��

;*** ����˵����R4��R5Ϊѭ������   ***
;***     ��Ҫѭ����0x05~0x0D��9�� ***
;***     ÿ����ִ��25,000,000��   ***
;***     ��2.25����ָ��           ***

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


;��ͻ��(5)ADDU���(6)ADDU
;������(5)ADDU��(6)ADDU���(7)SUBU
;������(7)SUBU���(8)CMP
;������(6)ADDU��(7)SUBU���(9)ADDU
;
;�кŴ�0��ʼ������Ҫѭ�����ڵĳ�ͻ����