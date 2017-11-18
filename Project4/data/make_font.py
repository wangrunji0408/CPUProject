import cv2
import numpy as np

base64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

img = np.zeros((16, 128*16), np.ubyte)
for i in range(128):
	cv2.putText(img, chr(i), (16*i + 2, 11), cv2.FONT_HERSHEY_SIMPLEX, 0.5, 255)
cv2.imwrite('font.png', img)

coe = open('font.coe', 'w')
coe.write('memory_initialization_radix=2;\n')
coe.write('memory_initialization_vector=\n')

k = 0
for i in range(128):
	img = np.zeros((16, 16), np.ubyte)
	cv2.putText(img, chr(i), (2, 11), cv2.FONT_HERSHEY_SIMPLEX, 0.5, 255)
	for line in img:
		for p in line:
			o = 1 if p == 255 else 0
			coe.write('%x' % o)
			coe.write(',' if k != 32768-1 else ';')
			k += 1
