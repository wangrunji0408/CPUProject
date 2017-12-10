# -*- coding:utf-8 -*-
import cv2
import numpy as np

img = cv2.imread('奋战三星期造台计算机.bmp')
fout = open('fzsxq.mp', 'w')

fout.write("""
NOP

; 清空屏幕
# R0 <= E000
# R1 <= FFFF
# Draw 000 R0
SUBU R1 R0 R2
BNEZ R2 0xFC
ADDIU R0 0x1
""")

for i in range(0, 5):
	cimg = img[:, 16*i : 16*(i+1)]
	y = 0
	for line in cimg:
		x = i * 16
		for p in line:
			if p.any():
				fout.write('# Draw 777 (%d,%d)\n' % (x,y))
			x += 1
		y += 1	

for i in range(0, 5):
	cimg = img[:, 16*(i+5) : 16*(i+6)]
	y = 16
	for line in cimg:
		x = i * 16
		for p in line:
			if p.any():
				fout.write('# Draw 777 (%d,%d)\n' % (x,y))
			x += 1
		y += 1	
			
