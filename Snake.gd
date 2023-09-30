extends Spatial

# Exporting instance scene to the Viewport.
export (PackedScene) var seg_scene


var target = Spatial
var base = Spatial

func _ready():
	G.last_scene = get_child(1)
	base = get_node("Base")
	G.prev_scene = base
	target = get_node("../../Path/PathFollow/target")
	$Segment_coll._target(target, base)


# Creating a number of segments = num.
func _segment(num):
	# Clearing segments if there are more then the first one
	if get_child_count()>2:
		for _i in range(1,get_child_count()-1):
			remove_child(get_child(2))
		G.last_scene = get_child(1)
		G.prev_scene = base
		print("last ",G.last_scene," prev ",G.prev_scene)
	$Segment_coll._target(target, base)
	# Cycle creating the segments
	for i in range(2,num+1):
		# Creating instance for copying
		var seg = seg_scene.instance()
		
		# Setting spawn point in the Joint
		var seg_spawn_location = G.last_scene.get_node("Joint").global_transform.origin
		
		# Creating a child Node
		if i < num:
			add_child(seg)
			# Spawning segment
			seg.initialize(seg_spawn_location, i)
			# Setting target as child's position
			G.prev_scene._target(get_child(i),get_child(i-2).get_node("Joint"))
		else: # Last seg spawns as a PathFollow child
			print("Yeah")
			G.path_follow.add_child(seg)
			G.prev_scene._target(seg,get_child(i-2).get_node("Joint"))
			G.path.get_curve().set_point_position(0, seg_spawn_location + Vector3(0,0,1))
		
		
		
		
		
		
		print("last ",G.last_scene," prev ",G.prev_scene)
		
	G.last_scene._target(null, G.prev_scene)
	#print("base ", get_child(1).base," target ", get_child(1).target)




# Recieving a signal from button.
func _on_UI_create_seg():
	var num = get_node("../../UI/Seg_num").text
	self._segment(num.to_int())
