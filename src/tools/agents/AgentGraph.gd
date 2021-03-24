class_name AgentGraph extends Node2D

const PATH_FOLLOW_SCENE : = \
		preload("res://src/tools/agents/RemotePathFollow.tscn")

export var speed : = 40.0

onready var path_follow : RemotePathFollow = PATH_FOLLOW_SCENE.instance()

func _ready():
	$Label.text = name
	

func _process(delta):
	
	path_follow.offset += delta * speed
	print("path_follow.offset: ", path_follow.offset)
	
	if path_follow.unit_offset >= 1.0:
		var next_path = get_next_path()
		if next_path:
			align_to_path(next_path, global_position)
		else:
			set_process(false)
		

func align_to_path(path : Path2D, align_to : Vector2):
	if path_follow.get_parent():
		HelperFunctions.reparent(path_follow, path)
	else:
		path.add_child(path_follow)
		path_follow.set_remote_node(self)
	
	print(path_follow.remote_transform.remote_path)
	
	var local_origin = path.to_local(align_to)
	var closest_offset = path.curve.get_closest_offset(local_origin)
	path_follow.offset = closest_offset
	
func get_closest_area() -> PointArea:
	var parent : ConnectablePath = get_parent()
	if not parent:
		push_error(name + ": Invalid Path")
		return null
	var start : = parent.start_point_area.global_transform.origin
	var end : = parent.end_point_area.global_transform.origin
	
	var dist_to_start = global_position.distance_squared_to(start)
	var dist_to_end = global_position.distance_squared_to(end)
	
	return parent.start_point_area if dist_to_start < dist_to_end \
			else parent.end_point_area
	
func get_next_path() -> ConnectablePath:
	var closest_area : = get_closest_area()
	if not closest_area:
		return null 
	
	var connection : Connection = closest_area.connection
	if not connection:
		return null
	
	else:
		if connection.connected_paths[0] != get_parent():
			return connection.connected_paths[0]
		return connection.connected_paths[1]

	
	
	

