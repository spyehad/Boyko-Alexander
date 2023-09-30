extends Spatial

var a  
var b 
var c 

var pos
var vec_z

func _ready():
	a = scale.x
	b = scale.y
	c = scale.z
	#print(a," ",b," ",c," ")
	pos = $Box.global_transform.origin
	vec_z = $Box.global_transform.basis.z.normalized()
	#G.cargo = self




func _on_Box_mouse_entered():
	G.mouse_entered = self
