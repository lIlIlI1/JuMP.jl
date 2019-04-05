import numpy as np
from math import sin, cos, asin, acos, tan, atan2, sqrt, pi
import csv

ORIGIN_X = 150
ORIGIN_Y = 150
LENGTH1 = 1#200
LENGTH2 = 1#200
INIT_1 = 30.0
INIT_2 = 30.0
FINAL_1 = 30.0
FINAL_2 = 90.0
R = 0.01*LENGTH1
STEPS = 40

def ik(x, y):
	'''
	beta = atan2(x, y)
	phi = acos((x**2.0+y**2.0+LENGTH1**2.0-LENGTH2**2.0)/(2*LENGTH1*sqrt(x**2.0+y**2.0)))
	theta = acos((x**2.0+y**2.0-LENGTH1**2.0-LENGTH2**2.0)/(2*LENGTH1*LENGTH2))

	theta1 = (beta - phi)*180.0/pi
	theta2 = (pi - theta)*180.0/pi
	'''
	theta2 = acos((x**2.0+y**2.0-LENGTH1**2.0-LENGTH2**2.0)/(2*LENGTH1*LENGTH2))
	theta1 = atan2(y,x) - asin((LENGTH2*sin(theta2))/(sqrt(x**2.0+y**2.0))) 
	return theta1*180.0/pi, theta2*180.0/pi

def nominal_path():
	theta1_list = []
	theta2_list = []
	#ORIGIN_X+LENGTH1*cos(INIT_1*3.14/180.0)+LENGTH2*cos(INIT_1*3.14/180.0+INIT_2*3.14/180.0), ORIGIN_Y+LENGTH1*sin(INIT_1*3.14/180.0)+LENGTH2*sin(INIT_1*3.14/180.0+INIT_2*3.14/180.0)]
	x_start = LENGTH1*cos(INIT_1*pi/180.0)+LENGTH2*cos(INIT_1*pi/180.0+INIT_2*pi/180.0) #+ORIGIN_X
	y_start = LENGTH1*sin(INIT_1*pi/180.0)+LENGTH2*sin(INIT_1*pi/180.0+INIT_2*pi/180.0) #+ORIGIN_Y
	x_final = LENGTH1*cos(FINAL_1*pi/180.0)+LENGTH2*cos(FINAL_1*pi/180.0+FINAL_2*pi/180.0) #+ORIGIN_X
	x_ideal = np.linspace(x_start, x_final, STEPS)
	y_ideal = [y_start]*STEPS
	''' 
	'''
	print("x_ideal")
	print(x_ideal)
	print("y_ideal")
	print(y_ideal)
	
	for i in range(STEPS):
		t1, t2 = ik(x_ideal[i], y_ideal[i])
		theta1_list.append(t1)
		theta2_list.append(t2)
	filename = "ideal_theta1.csv" 
	f = open(filename, 'w')
	for i in range(STEPS):
		f.write(str(theta1_list[i]))
		f.write('\n')
	f.close()

	filename = "ideal_theta2.csv" 
	f = open(filename, 'w')
	for i in range(STEPS):
		f.write(str(theta2_list[i]))
		f.write('\n')
	f.close()

	'''
	'''
	print("t1")
	print(theta1_list)
	print("t2")
	print(theta2_list)
	

if __name__ == '__main__':
	nominal_path()

