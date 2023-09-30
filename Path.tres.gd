extends Path

var path
var radius = 7
var length = 80
var h = 10
var seg_len = 5

var prev_point = Vector3()

var total_err_vec = Vector3()
var CUT_ERR = 0.2

var num_iter

# Called when the node enters the scene tree for the first time.
func _ready():
	G.path = self
	pass

func _input(event):
	
	if event.is_action_pressed("ui_accept"):
		
		gen_curve()
	



func clear_curve():
	path.clear_points()
	print("yeah")



func helix_curve(pos):
	var c_a = G.cargo.a
	var c_b = G.cargo.b
	var c_c = G.cargo.c
	radius = sqrt(pow(c_a,2)+pow(c_b,2))+1
	var l0 = pos.length()
	var L = 45 - l0
	
	print("Cube param: a: ",c_a," b: ",c_b," c: ",c_c," ")
	
	
	
	var l = 2*radius*PI
	
	h = l/(sqrt(pow(L,2)/pow(2*c_c,2)-1))  # Посчитать минимальный шаг для кривой. Вписать как константу
	
	var n = 2*c_c/h
	
	#print("n = ",n,"; h = ",h,"; L = ",L,"; l = ",l)
	
	var cargo_pos = pos
	var cargo_vec = G.cargo.vec_z 
	
	var N = 2000
	var h_z = h*n/N
	var h_alph = -2*PI*n/N
	#var err = (pow(a,2) + pow(b,2) + )/N*2
	
	#var x0 = radius*cos(0)
	#var y0 = radius*sin(0)
	#var z0 = 0
	
	
	for i in range(0,N):
		
		var z = i*h_z
		#var alpha = 2*(i-h)*PI/2/length-PI/2
		#var r = 2*radius*cos(alpha)
		var alpha = PI/4+i*h_alph
		var r = radius
		var x = r*cos(alpha)
		var y = r*sin(alpha)
		
		#var c = pow(x-x0,2)+pow(y-y0,2)+pow(z-z0,2) 
		
		#print(c)
		
		#if c > 24 and c < 26 or i == N-1:  
			
			
			
		#	x0 = x
		#	y0 = y
		#	z0 = z
		var points_vec = Vector3(x, y, z-c_c)
		#print(points_vec)
		var axis_vec = (cargo_vec.cross(Vector3(0,0,1))).normalized() 
		var axis_angle = cargo_vec.angle_to(Vector3(0,0,1))
		points_vec.rotated(axis_vec,axis_angle)
		points_vec += cargo_pos
		calc_cut(points_vec,CUT_ERR)
		#	path.add_point(points_vec)
			
		
	pass
	
	pass

func calc_cut(new_point,err):
	
	var count = path.get_point_count()
	
	var cut_vec = new_point - prev_point
	var cut_len = cut_vec.length()
	
	if cut_len >= seg_len - err and cut_len <= seg_len + err:
		#path.add_point(new_point)
		approx(new_point)
		#print(new_point)
		
	elif cut_len >= seg_len + err:
		
		new_point = prev_point
		var n = floor(cut_len/seg_len)
		for i in range(0,n):
			new_point += cut_vec.normalized()*seg_len
			path.add_point(new_point)
			prev_point = new_point
			num_iter += 1
	pass
	
	
	
	pass

func approx(new_point):
	
	var cut_vec = new_point - prev_point
	var point_count = path.get_point_count()
	var last = new_point
	var last_1 = path.get_point_position(point_count-1) 
	var last_2 = path.get_point_position(point_count-2)
	var last_3 = path.get_point_position(point_count-3)
	
	#print(last, last_1, last_2, last_3)
	
	var right = last - last_1
	var mid = last_1 - last_2
	var left = last_2 - last_3
	
	if (point_count > 3) and (num_iter % 2 == 1):
		#print("points: ",last, last_1, last_2, last_3)
		#print("vectors: ",right,mid,left)
		var base_plane_vec = left.cross(mid).normalized()
		var sec_plane_vec = mid.cross(right).normalized()
		#print(base_plane_vec,sec_plane_vec)
		if base_plane_vec != Vector3() and base_plane_vec != sec_plane_vec:
			var new_right = (right - right.project(base_plane_vec)).normalized() * right.length()
			total_err_vec += new_right - right
			#print(total_err_vec)
			new_point = prev_point + new_right
			print("res = ",new_point, "; num = ", num_iter)
			
	#print(new_point)
	path.add_point(new_point)
	prev_point = new_point
	num_iter += 1
	
	pass



func gen_curve():
	if G.cargo == null:
		print("No cargo selected!")
		return
	path = Curve3D.new()
	
	var pos = G.cargo.pos - global_transform.origin
	
	path.add_point(Vector3(0,0,0))
	prev_point = Vector3(0,-2.5,0)
	
	num_iter = 1
	path.add_point(prev_point)
	
	helix_curve(pos)
	
	set_curve(path)
	pass
