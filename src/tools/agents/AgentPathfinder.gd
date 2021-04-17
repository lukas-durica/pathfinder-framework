class_name AgentPathfinder extends Node2D

enum {MOVEMENT, ROTATION}

const RADIUS_TO_SCALE : = 2.0
const ANGULAR_VELOCITY : = 180.0

var path : = [] setget _set_path
var size : = 0.5 setget _set_size
var rotation_speed : = 1.0
var movement_speed : = 1.0

var action_time : = 0.0
var last_action : = Vector3.INF
var next_action : = Vector3.INF

var total_time : = 0.0

onready var grid : Grid = get_tree().get_nodes_in_group("grids")[0]

func _set_path(value : Array):
	path = value

func _set_size(value : float):
	scale *= value * RADIUS_TO_SCALE

func _ready():

	self.path = create_test_path()

func _process(delta):
	
	if last_action == Vector3.INF:
		last_action = action_to_world(path.pop_front())
	if next_action == Vector3.INF:
		next_action = action_to_world(path.pop_front())
	
	print("last_action: ", last_action)
	print("next_action: ", next_action)
	
	if last_action == Vector3.INF or next_action == Vector3.INF:
		return
	
	var shift = 1.0
	if is_movement_action():
		print("movement action")
		shift = movement_speed * 64.0 / Vector2(last_action.x, 
				last_action.y).distance_to(Vector2(next_action.x, 
				next_action.y))
	elif is_rotation_action():
		print("rotation action")
		shift = rotation_speed * 180.0 / abs(last_action.z - next_action.z)
	
	action_time += delta * shift
	total_time += delta
	
	var interpolation : = Vector3.ZERO
	if action_time < 1.0:
		interpolation = last_action.linear_interpolate(next_action, action_time)
	else:
		interpolation = last_action.linear_interpolate(next_action, 1.0)
		action_time -= 1.0
		last_action = next_action
		next_action = Vector3.INF
		print(rotation_degrees)
		print(total_time)
		
		
	
	rotation_degrees = interpolation.z
	global_position = Vector2(interpolation.x, interpolation.y)
	print(global_position)

# action without specifying data type, parameter can be null
func action_to_world(action) -> Vector3:
	print("action: ", action)
	if action == null:
		return Vector3.INF
	var world_position = grid.to_world(Vector2(action.x, action.y))
	return Vector3(world_position.x, world_position.y, action.z - 180.0)

func is_movement_action() -> bool:
	return not Vector2(last_action.x, last_action.y).is_equal_approx(
			Vector2(next_action.x, next_action.y))

func is_rotation_action() -> bool:
	return not is_equal_approx(last_action.z, next_action.z)

func create_test_path() -> Array:
	var test_path : = []
	test_path.push_back(Vector3(0.0, 0.0, 0.0))
	test_path.push_back(Vector3(0.0, 0.0, 180.0))
	test_path.push_back(Vector3(1.0, 0.0, 180.0))
	return test_path
