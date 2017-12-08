# -*- coding:utf-8 -*-
import os
import sys

filename = sys.argv[1]
outname = filename.replace('mp', 'mips')
fin = open(filename, 'r')
fout = open(outname, 'w')

# R0-R2 用户可用
# R3 用于读写内存的内容
# R4 用于访问内存的地址
# R5 用于TESTR/TESTW返回地址

TEST_RW_INSTS = """
TESTW:	NOP	 			;测试串口1是否能写 使用R4 R3
	LI R4 0x00BF 
	SLL R4 R4 0x0000 
	LW R4 R3 0x0001		; R3 <= mem[BF01]
	LI R4 0x0001 
	AND R4 R3
	BEQZ R4 TESTW		;BF01&1=0 则等待	
	NOP		
	JR R5
	NOP 
TESTR:	NOP				;测试串口1是否能读 使用R4 R3
	LI R4 0x00BF 
	SLL R4 R4 0x0000 
	LW R4 R3 0x0001		; R3 <= mem[BF01]
	LI R4 0x0002
	AND R4 R3
	BEQZ R4 TESTR		;BF01&2=0  则等待	
	NOP	
	JR R5
	NOP
WAIT:  NOP				;等待 每回合R4-- 直到R4=0
	BNEZ R4 WAIT
	ADDIU R4 0xFF
	JR R5
	NOP
"""

TESTR = """
	MFPC R5				; 测试读串口
	ADDIU R5 0x0002
	B TESTR
	NOP
"""

TESTW = """
	MFPC R5				; 测试写串口
	ADDIU R5 0x0002
	B TESTW	
	NOP
"""

RETURN = """
	JR R7				; 返回
	NOP
"""

def set_reg(reg, data):
	if data.startswith('{{') and data.endswith('}}'):
		num = eval(data.strip('{}'))
		num = (1 << 16) + num if num < 0 else num
		data = '%04x' % num
	assert(len(data) == 4)
	if data[0:2] == '00':
		return '\tLI %s 0x%s\t\t\t; %s <= %s\n' % (reg, data[2:4],  reg, data)
	else:
		return """
	LI %s 0x%s
	SLL %s %s 0x0000 
	ADDIU %s 0x%s		; %s <= %s
""" % (reg, data[0:2], reg, reg, reg, data[2:4],  reg, data)

def read_mem(addr, reg):
	return (TESTR if addr == 'BF00' else '') \
		+ set_reg('R4', addr) \
		+ '\tLW %s %s 0x0\t\t' % ('R4', reg) \
		+ '; %s <= *%s\n' % (reg, addr)

def write_mem(addr, reg):
	return (TESTW if addr == 'BF00' else '') \
		+ set_reg('R4', addr) \
		+ '\tSW %s %s 0x0\t\t' % ('R4', reg) \
		+ '; %s => *%s\n' % (reg, addr)

def wait(count):
	return set_reg('R4', count) +  """
	MFPC R5				; 等待
	ADDIU R5 0x0002
	B WAIT	
	NOP
"""

def read_uart(reg):
	return TESTR + read_mem('BF00', reg)

def write_uart(reg):
	return TESTW + write_mem('BF00', reg)

def pixel_addr(x, y):
	assert(x >= 0 and x < 80)
	assert(y >= 0 and y < 60)
	return '%04x' % (int('E000', 16) + (y << 7) + x,)

def color_data(color):
	# color = '777'
	x = 0
	for c in color:
		assert(ord(c) >= ord('0') and ord(c) <= ord('7'))	
		x = (x << 3) + (ord(c) - ord('0'))
	return '%04x' % x

def char_data(char, color='777', down=False):
	# color = '777'
	x = 0
	for c in color:
		assert(ord(c) >= ord('0') and ord(c) <= ord('7'))	
		x = (x << 2) + (ord(c) - ord('0')) / 2
	x = x << 8
	x |= ord(char)
	x |= 1 << 15
	x |= 1 << 14 if down else 0
	return '%04x' % x

def print_str(s, pos, color='777'):
	(x, y) = pos
	res = ''
	for c in s:
		assert(x >= 0 and x < 80 and y >= 0 and y < 59)
		res += set_reg(reg='R3', data=char_data(c, color, down=False))
		res += write_mem(addr=pixel_addr(x, y), reg='R3')
		res += set_reg(reg='R3', data=char_data(c, color, down=True))
		res += write_mem(addr=pixel_addr(x, y+1), reg='R3')
		x += 1
	return res

def print_color(color, pos):
	res = set_reg(reg='R3', data=color_data(color))
	if pos.startswith('R'):
		# pos = 'R0'
		res += '\tSW %s R3 0x0\n' % pos
	else:
		# pos = '(10,12)'
		(x, y) = [int(i) for i in pos.strip('()').split(',')]
		assert(x >= 0 and x < 80 and y >= 0 and y < 60)
		res += write_mem(addr=pixel_addr(x, y), reg='R3')
	return res

def process_line(line, line_num):
	if not line.strip().startswith('#'):
		fout.write(line)
		return
	tokens = line.strip()[1:].strip().split(' ')

	if tokens[0].startswith('Print'):
		# Print Hello,World (20,19)
		s = tokens[1]
		pos = [int(i) for i in tokens[2].strip('()').split(',')]
		fout.write(print_str(s, pos))
	elif tokens[0].startswith('Draw'):
		# Draw 700 (20,19)
		# Draw 700 R2
		fout.write(print_color(color=tokens[1], pos=tokens[2]))	
	elif tokens[0].startswith('Wait'):
		# Wait 0A00
		fout.write(wait(count=tokens[1]))	
	elif tokens[0].startswith('Return'):
		# Return
		fout.write(RETURN)
	elif tokens[0].startswith('R'):
		# R4 <= BF00
		# R4 <= *BF00
		# R4 <= R2
		reg = tokens[0]
		rw = tokens[1]
		data = tokens[2]
		if rw == '<=':
			if data.startswith('R'):
				print('Not supported: MOVE')
				fout.write('\tMOVE %s %s\n' % (reg, data))
			elif data.startswith('*R'):
				fout.write('\tLW %s %s 0x0\n' % (data[1:], reg))
			elif data.startswith('*'):
				fout.write(read_mem(addr=data[1:], reg=reg))
			else:
				fout.write(set_reg(reg=reg, data=data))
		elif rw == '=>':
			if data.startswith('R'):
				print('Not supported: MOVE')
				fout.write('\tMOVE %s %s\n' % (data, reg))
			elif data.startswith('*R'):
				fout.write('\tSW %s %s 0x0\n' % (data[1:], reg))
			elif data.startswith('*'):
				fout.write(write_mem(addr=data[1:], reg=reg))
			else:
				print('Syntax Error! Line %d' % line_num)
		else:
			print('Syntax Error! Line %d' % line_num)
	else:
		print('Syntax Error! Line %d' % line_num)


i = 1
for line in fin.readlines():
	process_line(line, i)
	i += 1
fout.write(RETURN)	
fout.write(TEST_RW_INSTS)