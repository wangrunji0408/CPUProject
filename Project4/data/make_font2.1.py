import cv2
import numpy as np

img = cv2.imread('奋战三星期造台计算机.bmp')

for i in range(32, 128+25):
	cimg = img[:, 8*(i-32) : 8*(i-32+1)]
	for line in cimg:
		for p in line:
			o = 1 if p.any() else 0
			coe.write('%x' % o)
			coe.write(',')
			k += 1
