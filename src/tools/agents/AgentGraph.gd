class_name AgentGraph extends Node2D

const PATH_FOLLOW_SCENE : = \
		preload("res://src/tools/agents/RemotePathFollow.tscn")

export var speed : = 40.0

onready var path_follow : RemotePathFollow = PATH_FOLLOW_SCENE.instance()

func _ready():
	$Label.text = name
	

func _process(delta):
	
	path_follow.offset += delta * speed
	
	if path_follow.unit_offset >= 1.0:
		var next_path = path_follow.get_next_path()
		if next_path:
			align_to_path(next_path, global_position)
		else:
			set_process(false)
		

func align_to_path(path : Path2D, align_to : Vector2):
	print("old unit offset: ", path_follow.unit_offset)
	print("global_position: ", global_position)
	if path_follow.get_parent():
		HelperFunctions.reparent(path_follow, path)
	else:
		path.add_child(path_follow)
		#var path_to = path_follow.remote_transform.get_path_to(self)
		#path_follow.remote_transform.remote_path = path_to
		path_follow.set_remote_node(self)
	var local_origin = path.to_local(align_to)
	var closest_offset = path.curve.get_closest_offset(local_origin)
	
	print("closest_offset: ", closest_offset)
	path_follow.offset = closest_offset
	
	print("new unit offset: ", path_follow.unit_offset)
	print("global_position: ", global_position)
	
	
	
	
	

	

