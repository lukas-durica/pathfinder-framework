tool

class_name AgentGraph extends Node2D

enum Direction {BACKWARD = -1, NONE = 0, FORWARD = 1}

# to remember the path for runtime
export (NodePath) var node_path_to_path
export var speed : = 150.0
export (Direction) var path_direction : = Direction.NONE

var pathfinding_points : = []
var path_follow : RemotePathFollow
var actual_path : Path2D
var goal_node : Node2D

onready var visualization : = $Visualization
onready var path_connector : = $PathConnector2D

func _ready():
	if not Engine.editor_hint:
		actual_path = get_node(node_path_to_path)
		initialize_path_folow()
		align_path_follow_to_path(actual_path)
		

	set_name_to_visualization()
	set_process(false)

func _process(delta):
	if Engine.editor_hint:
		return
	
	update_path_follow_offset(delta)
	
	if is_on_goal():
		set_process(false)
	
	if can_update_path():
		if is_next_path_valid():
			update_actual_path()
			align_to_actual_path()
		else:
			set_process(false)

func initialize_path_folow():
	path_follow = path_connector.find_remote_path_follow()
	path_follow.remote_node = self

func set_name_to_visualization():
	$Visualization/Label.text = name

func run(p_points : Array, goal : Node2D):
	if p_points.empty():
		push_error(name + ": paths points are empty!")
		return

	pathfinding_points = p_points
	goal_node = goal
	set_initial_direction()
	update_actual_path()
	align_path_follow_to_path(actual_path)
	set_process(true)

func update_path_follow_offset(delta : float):
	path_follow.offset += delta * speed * path_direction
	
func can_update_path() -> bool:
	return path_direction == Direction.FORWARD \
			and path_follow.unit_offset >= 1.0 \
			or path_direction == Direction.BACKWARD \
			and path_follow.unit_offset <= 0.0

func is_next_path_valid() -> bool:
	return not pathfinding_points.empty()

func update_actual_path():
	var point = pathfinding_points.pop_front()
	actual_path = point.path

func align_to_actual_path():
	var old_unit_offset = path_follow.unit_offset
	align_path_follow_to_path(actual_path)
	var new_unit_offset = path_follow.unit_offset
	if can_invert_direction(old_unit_offset, new_unit_offset):
		invert_direction()

func set_initial_direction():
	var point_position = pathfinding_points[0].global_position
	var point_offset = HelperFunctions.get_closest_path_offset(actual_path, 
			point_position)
	
	if point_offset > path_follow.offset:
		path_direction = Direction.FORWARD
	elif point_offset < path_follow.offset:
		path_direction = Direction.BACKWARD
	else:
		push_error(name + "Point offset == path_follow.offset")

func align_path_follow_to_path(path : Path2D):
	path_follow.align_to_path(path)

func can_invert_direction(old_unit_offset : float, 
		new_unit_offset : float) -> bool:
	return int(round(old_unit_offset)) == int(round(new_unit_offset))

func invert_direction():
	visualization.rotate(PI)
	match path_direction:
		Direction.FORWARD:
			path_direction = Direction.BACKWARD
		Direction.BACKWARD:
			path_direction = Direction.FORWARD

func is_on_goal() -> bool:
	if not is_on_goal_path():
		return false
	var goal_path_offset = HelperFunctions.get_closest_path_offset(actual_path, 
			goal_node.global_position)
	return is_behind_the_point_on_path(goal_path_offset)

func is_behind_the_point_on_path(point : float) -> bool:
	return path_direction == Direction.FORWARD\
		and path_follow.offset >= point \
		or path_direction == Direction.BACKWARD \
		and path_follow.offset <= point

func is_on_goal_path() -> bool:
	return pathfinding_points.size() == 1

func _on_PathConnector2D_connected_to_path(path):
	node_path_to_path = get_path_to(path)

func _on_PathConnector2D_disconnected_from_path():
	node_path_to_path = ""
