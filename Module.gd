extends Spatial

var length = 10

# Segments' addresses
var left
var right
var mid

var left_joint
var mid_joint
var right_joint

var left_rotated = false
var right_rotated = false
var mid_angled = false
var right_angled = false

# Targets' addresses (targets are points on a path)
var targ_l
var targ_r
var targ_m

var rot_x = 0

var STEP = PI/37
var ROT_STEP = PI/180
var MAX_ROT = PI/2 # Equals 45deg swing
var ROT_ERROR = PI/179 # The accuracy of following the path
var DIST_ERROR = 0.2
var CYCLES = 2000

var cycle_count = 0
var step_real
var rot_real

export var not_order = true

export var target = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	target *= 2
	left = $Joint/Segment_1
	mid = $Joint/Segment_1/Joint/Segment_2
	right = $Joint/Segment_1/Joint/Segment_2/Joint/Segment_3
	left_joint = self
	right_joint = $Joint/Segment_1/Joint/Segment_2/Joint
	mid_joint = $Joint/Segment_1/Joint
	
	
	targ_m = G.get_node(G.target[target])
	targ_r = G.get_node(G.target[target + 1])
	
	rot_real = ROT_STEP
	step_real = STEP
	
	target /= 2
	pass

func _swing(h, delta, body):
	body.rotation.y += h# * delta
	pass


func _rotate(r, delta):
	rotation.x += r# * delta
	#print("rot = ",rotation.x)
	pass

func _calc_angle(delta, body, tar1, tar2):
	# Calculates global positions of segments
	var g_pos = body.get_global_transform().origin
	# Calculate global positions of targets
	var g_pos_t1 = tar1.get_global_transform().origin
	var g_pos_t2 = tar2.get_global_transform().origin
	
	# Calculate Vector3D of z axis in global coordinates
	var vec_z = get_global_transform().basis.z
	# Calculate Vector3D of x axis in global coordinates
	var vec_x = get_global_transform().basis.x
	
	# Calculate Vector3D pointing to targets
	var dist_to_tar = (g_pos_t1 - g_pos)
	
	var dist_projected = dist_to_tar - dist_to_tar.project(vec_x)
	
	# Calculating angle in YZ plane
	var angle = vec_z.signed_angle_to(dist_projected, vec_x)
	
	var res = true
	
	if (dist_projected.length() > DIST_ERROR):
		# Rotates module so it's -Z axis would face the target's position
		
		if (angle >= 0 + ROT_ERROR and angle < PI/2) or (angle >= -PI + ROT_ERROR and angle < -PI/2):
			#print("ang = ",angle," < 0")
			_rotate(rot_real, delta)
			res = false
		
		elif (angle <= PI - ROT_ERROR and angle > PI/2) or (angle > -PI/2 and angle < 0 - ROT_ERROR):
			#print("ang = ",angle," > 0")
			_rotate(-rot_real, delta)
			res = false
		else: res = true
	
	if res: cycle_count = 0
	return res
	pass

func make_angle(body, tar):
	
	var ang = G.module_angs[tar]
	
	
	body.rotation.y = ang
	
	pass




func _calc_swing(delta, body, joint, tar):
	# Calculates global positions of segments
	var g_pos = body.get_global_transform().origin
	# Calculate global positions of targets
	var g_pos_t = tar.get_global_transform().origin
	
	# Calculate Vector3D of z axis in global coordinates
	var vec_z = body.get_global_transform().basis.z
	
	# Calculate Vector3D pointing to targets
	var dist_to_tar = (g_pos - g_pos_t)
	
	# Projecting Vectors onto z axis of the module
	dist_to_tar = dist_to_tar.project(vec_z)
	
	# If distance to the middle target is higher than error
	if (dist_to_tar.length() > DIST_ERROR):
		# Calculating sign of distance
		var koeff = dist_to_tar.normalized() + vec_z.normalized()
		koeff = round(koeff.length() - 1)
		
		# Deciding the direction of movement
		match int(koeff):
			1:
				if (joint.rotation.y) < MAX_ROT:
					_swing(step_real, delta, joint)
			-1:
				if (joint.rotation.y) > -MAX_ROT:
					_swing(-step_real, delta, joint)
		return false
	else:
		return true
		
	pass

func _physics_process(delta):
	
	not_order = G.module_state[target-1]
	#print("Mod #",target,"; State = ",not_order)
	
	if not_order: 
		#return
		left_rotated = false
		mid_angled = false
		right_angled = false
		right_rotated = false
		cycle_count = 0
		return
	
	if cycle_count == CYCLES:
		G.module_state[target-1] = true
		G.UI.print_info(["Module #",str(target)," stuck!"])
		if right.get_node("Joint").get_child_count() > 0:
			G.module_state[target] = false
		return
	
	# Check if targets are set
	if targ_m and targ_r:
		
		
		
		if left_rotated:
			if mid_angled:
				if right_rotated:
					right_angled = _calc_swing(delta, right, right_joint, targ_r)
				else:
					#right_rotated = _calc_angle(delta, mid, targ_r, targ_r)
					right_rotated = _calc_angle(delta, left, targ_r, targ_r)
			else:
				mid_angled = _calc_swing(delta, mid, mid_joint, targ_m)
		else:
			#left_rotated = _calc_angle(delta, mid, targ_m, targ_r)
			left_rotated = _calc_angle(delta, left, targ_m, targ_r)
	
	#print("l_r = ",left_rotated,"; m_a = ",mid_angled,"; r_a = ",right_angled,"; r_r = ",right_rotated)
	
	if left_rotated and mid_angled and right_angled and right_rotated:
		G.module_state[target-1] = true
		G.UI.print_info(["Module #", str(target)," angled"]) 
		#print("Module #", target," angled")
		#print("Rotation: ", rotation.x/PI*180 ,"; Angle middle: ", mid_joint.rotation.y/PI*180,"; Angle right: ", right_joint.rotation.y/PI*180)
		if right.get_node("Joint").get_child_count() > 0:
			G.module_state[target] = false
		else: G.UI.print_info(["Finished"])
	else: cycle_count += 1
	
	pass
