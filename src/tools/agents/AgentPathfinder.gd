class_name AgentPathfinder extends Node2D

enum {MOVEMENT, ROTATION}

const RADIUS_TO_SCALE : = 2.0
const ANGULAR_VELOCITY_UNIT : = 180.0
const GRID_SIZE : = 64.0

var path : = [] setget _set_path

export(float, 0.01, 10.0, 0.1) var size : = 0.5 setget _set_size
export(float, 0.01, 10.0, 0.1) var movement_speed : = 1.0
export(float, 0.01, 10.0, 0.1) var rotation_speed : = 1.0

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
	pass
	#self.path = create_test_path()

func _process(delta):
	
	if last_action == Vector3.INF:
		last_action = action_to_world(path.pop_front())
		print("last_action: ", last_action)
	if next_action == Vector3.INF:
		next_action = action_to_world(path.pop_front())
		action_time = 0.0
		
	if last_action == Vector3.INF or next_action == Vector3.INF:
		set_process(false)
		return
	
	var shift = 1.0
	if is_movement_action():
		#print("movement action")
		shift = movement_speed * GRID_SIZE / Vector2(last_action.x, 
				last_action.y).distance_to(Vector2(next_action.x, 
				next_action.y))
	elif is_rotation_action():
		#print("rotation action")
		shift = rotation_speed * ANGULAR_VELOCITY_UNIT / abs(
				last_action.z - next_action.z)
	
	# in case of waiting
	#print("shift: ", shift)
	action_time += delta * shift
	total_time += delta
	#print("action_time: ", action_time)
	var interpolation : = Vector3.ZERO
	if action_time < 1.0:
		interpolation = last_action.linear_interpolate(next_action, action_time)
	else:
		interpolation = last_action.linear_interpolate(next_action, 1.0)
		action_time -= 1.0
		last_action = next_action
		next_action = Vector3.INF
		#print(rotation_degrees)
		#print(total_time)
	
	rotation_degrees = -interpolation.z
	global_position = Vector2(interpolation.x, interpolation.y)
	#print("global_position: ", global_position)
	#print("rotation_degrees: ", rotation_degrees)

func run(pth : Array):
	self.path = pth
	set_process(true)

# action without specifying data type, parameter can be null
func action_to_world(action) -> Vector3:
	#print("action: ", action)
	if action == null:
		return Vector3.INF
	var world_position = grid.to_world(Vector2(action.x, action.y))
	return Vector3(world_position.x, world_position.y, action.z - 180.0)

func is_movement_action() -> bool:
	return not Vector2(last_action.x, last_action.y).is_equal_approx(
			Vector2(next_action.x, next_action.y))

func is_rotation_action() -> bool:
	return not is_equal_approx(last_action.z, next_action.z)

static func create_test_path() -> Array:
	var test_path : = []
	#i: 35 j: 7 heading: 180 interval.begin: 0 interval.end: 1e+09
	#i: 35 j: 7 heading: 106.928 interval.begin: 0 interval.end: 1e+09
	#i: 12 j: 0 heading: 106.928 interval.begin: 0 interval.end: 1e+09
	#i: 12 j: 0 heading: 0 interval.begin: 0 interval.end: 1e+09
	test_path.push_back(Vector3(7.0, 35.0, 180.0))
	test_path.push_back(Vector3(7.0, 35.0, 106.928))
	test_path.push_back(Vector3(0.0, 12.0, 106.928))
	test_path.push_back(Vector3(0.0, 12.0, 0.0))
	return test_path
