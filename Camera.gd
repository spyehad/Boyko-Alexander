extends Camera

var rot_x = 0
var rot_y = 0

var ROT_SPEED = 0.01
var SPEED = 0.5

var pos = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	G.Cam = self
	G.Cam_joint = get_parent()
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseMotion and event.button_mask & 4:
		
		rot_x -= event.relative.y * ROT_SPEED
		rot_y -= event.relative.x * ROT_SPEED
		
		if rot_x > PI/4 : rot_x = PI/4
		if rot_x < -PI/4: rot_x = -PI/4
		
		G.Cam_joint.rotation.y = rot_y
		G.Cam_joint.rotation.x = rot_x
	
	pass

func _process(delta):
	
	var rot_cam = G.Cam_joint.get_rotation().y
	
	if Input.is_action_pressed("ui_left"):
		G.Cam_joint.translation.x -= SPEED * cos(rot_cam)
		G.Cam_joint.translation.z += SPEED * sin(rot_cam)
		pass
	if Input.is_action_pressed("ui_right"):
		G.Cam_joint.translation.x += SPEED * cos(rot_cam)
		G.Cam_joint.translation.z -= SPEED * sin(rot_cam)
		pass
	if Input.is_action_pressed("ui_up"):
		G.Cam_joint.translation.z -= SPEED * cos(rot_cam)
		G.Cam_joint.translation.x -= SPEED * sin(rot_cam)
		pass
	if Input.is_action_pressed("ui_down"):
		G.Cam_joint.translation.z += SPEED * cos(rot_cam)
		G.Cam_joint.translation.x += SPEED * sin(rot_cam)
		pass
	
	
	
	pass
