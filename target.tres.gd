extends KinematicBody

var speed = 10

var velocity = Vector3()

var off = 0
var paused = true

export var num = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	G.target[num] = str(get_path())
	if num == 1:
		off = 1.3
	else:
		off = (num - 1) * 5
	
	pass # Replace with function body.




func _physics_process(delta):
	
	get_parent().set_offset(off)
	
	
	var direction = Vector3()
	
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_forward"):
		direction.y += 1
	if Input.is_action_pressed("ui_backward"):
		direction.y -= 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	
	velocity = direction.normalized()*speed
	
	#move_and_slide(velocity,Vector3(0,1,0))
	
	pass


