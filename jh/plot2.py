from math import sin, cos
import pyglet
from pyglet.gl import *
import numpy as np
import csv

ORIGIN_X = 150
ORIGIN_Y = 150
LENGTH1 = 200
LENGTH2 = 200
INIT_1 = 30.0
INIT_2 = 30.0
R = 0.01*LENGTH1
class Arm(object):
	viewer = None
	def __init__(self):
		self.theta1 = []
		self.theta2 = []
		with open('theta1.csv') as csv_file:
			print("read theta1")
			csv_reader = csv.reader(csv_file, delimiter=',')
			for row in csv_reader:
				#temp = map(float, row[:])
				self.theta1.append(float(row[0]))#temp)

		with open('theta2.csv') as csv_file:
			print("read theta2")
			csv_reader = csv.reader(csv_file, delimiter=',')
			for row in csv_reader:
				#temp = float#map(float, row[:])
				self.theta2.append(float(row[0]))
		#print("theta1")
		#print(self.theta1)
		#print("theta2")
		#print(self.theta2)
		#self.theta1 = [30.0, 30.0, 30.0, 29.3006, 28.8261, 28.1265, 27.4385, 26.7406, 26.2636, 25.7701, 25.3967, 25.0241, 24.6619, 24.2924, 24.0519, 23.8085, 23.5644, 23.3197, 23.0703, 22.9098, 22.7428, 22.5766, 22.4071, 22.2891, 22.1699, 22.0497, 21.9558, 21.8628, 21.7695, 21.7127, 21.6645, 21.6198, 21.5749, 21.5273, 21.4765, 21.4773, 21.4778, 21.4784, 21.4789, 21.4912]
		#self.theta2 = y = [30.0, 30.0, 30.0, 31.6073, 33.3077, 35.3679, 37.4511, 39.5393, 41.1747, 42.81, 44.194, 45.5538, 46.9285, 48.2625, 49.3624, 50.4496, 51.5441, 52.6461, 53.7553, 54.6937, 55.6271, 56.5673, 57.5147, 58.3503, 59.1924, 60.041, 60.819, 61.603, 62.3934, 63.0932, 63.7904, 64.4899, 65.1953, 65.9016, 66.6086, 67.2311, 67.8535, 68.4759, 69.0982, 69.7051]
		#self.theta1 = np.linspace(0,1.56,20)
		#self.theta2 = np.linspace(0,1.56,20)
		self.j1 = [ORIGIN_X, ORIGIN_Y] 
		self.j2 = [0.0, 0.0]
		self.ee = [0.0, 0.0]
		self.steps = 0
		#self.l1 = 200
		#self.l2 = 200
	#manage traffic light colors
	def arm_position(self, steps):
		#print("here")
		#print(steps)
		self.j2[0] = LENGTH1*cos(self.theta1[steps]*3.14/180.0) + self.j1[0]
		self.j2[1] = LENGTH1*sin(self.theta1[steps]*3.14/180.0) + self.j1[1]
		self.ee[0] = LENGTH1*cos(self.theta1[steps]*3.14/180.0) + LENGTH2*cos(self.theta1[steps]*3.14/180.0+self.theta2[steps]*3.14/180.0)  + self.j1[0]
		self.ee[1] = LENGTH1*sin(self.theta1[steps]*3.14/180.0) + LENGTH2*sin(self.theta1[steps]*3.14/180.0+self.theta2[steps]*3.14/180.0)  + self.j1[1]

	#update traffic using car_list and traffic_light_list
	def render(self,dt): 
		if self.viewer is None:
			self.viewer = Viewer()
		if (self.steps < len(self.theta1)):
			self.arm_position(self.steps)
			self.steps +=1
		else:
			self.steps = 0
			self.viewer.ee_trace = pyglet.graphics.Batch()
		#print(len(self.car_list))
		self.viewer.update(dt, self.j1, self.j2, self.ee)

class Viewer(pyglet.window.Window):
	def __init__(self):
		super().__init__(width=700, height=700, resizable=False, caption='2D Arm', vsync=False)
		glEnable(GL_PROGRAM_POINT_SIZE_EXT)
		glPointSize(3)
		pyglet.gl.glClearColor(0.8, 0.8, 0.8, 1) #background color
		bg_vertices = [ORIGIN_X+LENGTH1*cos(INIT_1*3.14/180.0)+LENGTH2*cos(INIT_1*3.14/180.0+INIT_2*3.14/180.0), ORIGIN_Y+LENGTH1*sin(INIT_1*3.14/180.0)+LENGTH2*sin(INIT_1*3.14/180.0+INIT_2*3.14/180.0)]
		self.bg = pyglet.graphics.Batch() 
		self.arm_batch = None 
		self.ee_trace = pyglet.graphics.Batch()
		#self.arm = arm
		#for i in range(2):
		self.bg.add(2, pyglet.gl.GL_LINES, None,
			('v2f', [bg_vertices[0]-200, bg_vertices[1], bg_vertices[0]+100, bg_vertices[1]]),
			('c3B', (86, 10, 29)*2))

		self.bg.add(2, pyglet.gl.GL_LINES, None,
			('v2f', [bg_vertices[0]-200, bg_vertices[1]-R, bg_vertices[0]+100, bg_vertices[1]-R]),
			('c3B', (86, 10, 29)*2))
		self.bg.add(2, pyglet.gl.GL_LINES, None,
			('v2f', [bg_vertices[0]-200, bg_vertices[1]+R, bg_vertices[0]+100, bg_vertices[1]+R]),
			('c3B', (86, 10, 29)*2))
	#draw the batch
	def on_draw(self):
		self.clear()
		self.bg.draw()
		self.arm_batch.draw()
		self.ee_trace.draw()
	#update info of cars and traffic lights, called at time interval defined in function: pyglet.clock.schedule_interval()
	def update(self, dt, j1, j2, ee):
		#print(j1)
		#print(j2)
		#print(ee)
		arm_batch = pyglet.graphics.Batch()
		ee_trace = pyglet.graphics.Batch()
		arm_batch.add(2, pyglet.gl.GL_LINES, None,
                             ('v2f', [j1[0], j1[1], j2[0],j2[1]]), 
                             ('c3B', (86, 10, 29)*2))
		arm_batch.add(2, pyglet.gl.GL_LINES, None,
                             ('v2f', [j2[0], j2[1], ee[0],ee[1]]), 
                             ('c3B', (86, 10, 29)*2))
		self.ee_trace.add(1, pyglet.gl.GL_POINTS, None, ('v2f', (ee[0], ee[1])), ('c3B', (0, 0, 255)))

		self.arm_batch = arm_batch

if __name__ == '__main__':
	env = Arm()
	while True:
		pyglet.clock.schedule_interval(env.render,0.1) #0.1 is the update time interval
		pyglet.app.run()