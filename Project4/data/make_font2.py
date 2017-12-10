import cv2
import numpy as np

img = cv2.imread('font2.png')

coe = open('font.coe', 'w')
coe.write('memory_initialization_radix=2;\n')
coe.write('memory_initialization_vector=\n')

k = 32*8*16
for i in range(32*8*16):
	coe.write('0,')

for i in range(32, 128+25):
	cimg = img[:, 8*(i-32) : 8*(i-32+1)]
	for line in cimg:
		for p in line:
			o = 1 if p.any() else 0
			coe.write('%x' % o)
			coe.write(',')
			k += 1
