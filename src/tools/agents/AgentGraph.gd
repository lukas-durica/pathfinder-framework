class_name AgentGraph extends Node2D

const PATH_FOLLOW_PATH : = "res://src/tools/agents/RemotePathFollow.tscn"
const PATH_FOLLOW_SCENE : = preload(PATH_FOLLOW_PATH)

export var speed : = 150.0
export (int, -1, 1, 1) var path_direction : = 1

onready var path_follow : RemotePathFollow = PATH_FOLLOW_SCENE.instance()
onready var visualization : = $Visualization

func _ready():
	$Visualization/Label.text = name

func _process(delta):
	
	# update_position
	path_follow.offset += delta * speed * path_direction
	
	if can_update_path():
		var next_path = path_follow.get_next_path()
		if next_path:
			var old_unit_offset = path_follow.unit_offset
			align_to_path(next_path, global_position)
			var new_unit_offset = path_follow.unit_offset
			if can_invert_direction(old_unit_offset, new_unit_offset):
				print("old_unit_offset: ", old_unit_offset)
				print("new_unit_offset: ", new_unit_offset)
				invert_direction()
			
		else:
			set_process(false)


func align_to_path(path : Path2D, align_to : Vector2):
	if path_follow.get_parent():
		HelperFunctions.reparent(path_follow, path)
	else:
		path.add_child(path_follow)
		path_follow.set_remote_node(self)
	
	var local_origin = path.to_local(align_to)
	var closest_offset = path.curve.get_closest_offset(local_origin)
	path_follow.offset = closest_offset


func can_update_path() -> bool:
	return path_direction == 1 and path_follow.unit_offset >= 1.0 \
			or path_direction == -1 and path_follow.unit_offset <= 0.0

func can_invert_direction(old_unit_offset : float, 
		new_unit_offset : float) -> bool:
	return int(round(old_unit_offset)) == int(round(new_unit_offset))

func invert_direction():
	visualization.rotate(deg2rad(180))
	path_direction *=-1
	

	
	
	
	
	
	
	

	

