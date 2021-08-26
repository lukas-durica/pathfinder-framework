tool

class_name AgentGraph extends Node2D

# to remember the path for runtime
export (NodePath) var node_path_to_path
export var speed : = 150.0
export (int, -1, 1, 1) var path_direction : = 1

var paths : = []
var points : = []
var path_follow : RemotePathFollow

onready var visualization : = $Visualization/Sprite
onready var path_connector : = $PathConnector2D

func _ready():
	if not Engine.editor_hint:
		path_follow = path_connector.find_remote_path_follow()
		if not node_path_to_path.is_empty():
			var path = get_node(node_path_to_path)
			align_to_path(path, global_position)
		else:
			push_warning(name + "node path to path is empty!")
		set_process(false)
	$Visualization/Label.text = name

func _process(delta):
	# update_position
	
	if Engine.editor_hint:
		return
	
	path_follow.offset += delta * speed * path_direction
	
	if can_update_path():
		var point = points.pop_front()
		
		if point:
			var path = point.path
			var old_unit_offset = path_follow.unit_offset
			align_to_path(path, global_position)
			var new_unit_offset = path_follow.unit_offset
			if can_invert_direction(old_unit_offset, new_unit_offset):
				invert_direction()
		else:
			set_process(false)
	

func run(p_points : Array):
	if p_points.empty():
		push_error(name + "paths data is empty!")
		return
	
	points = p_points
	# agent is already alligned to this path, thus pop front it
	var point : MarginalPointArea = points[0]
	path_direction = -1 if point.type == MarginalPointArea.START else 1
	points.pop_front()
	set_process(true)



#func align_to_path(path : Path2D, align_to : Vector2):
#	if path_follow.get_parent():
#		HelperFunctions.reparent(path_follow, path)
#	else:
#		path.add_child(path_follow)
#		# set the remote node at the beginning when aligning to path
#		# and path follow has no parent
#
#	path_follow.set_remote_node(self)
#
#	var local_origin = path.to_local(align_to)
#	var closest_offset = path.curve.get_closest_offset(local_origin)
#	path_follow.offset = closest_offset

func align_to_path(path : Path2D, align_to : Vector2):
	if path_follow.get_parent():
		HelperFunctions.reparent(path_follow, path)
	else:
		path.add_child(path_follow)
		# set the remote node at the beginning when aligning to path
		# and path follow has no parent
	
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
	visualization.rotate(PI)
	path_direction *= -1

func is_on_target() -> bool:
	print("doplnit")
	
	return false

func _on_PathConnector2D_connected_to_path(path):
	node_path_to_path = get_path_to(path)

func _on_PathConnector2D_disconnected_from_path():
	node_path_to_path = ""
