class_name AgentPathfinder extends Node2D

enum {MOVEMENT, ROTATION}

const RADIUS_TO_SCALE : = 2.0
const ANGULAR_VELOCITY : = 180.0

var grid : Grid

var path : = [] setget _set_path
var size : = 0.5 setget _set_size
var rotation_speed : = 1.0
var movement_speed : = 1.0

var action_time : = 0.0
var last_action : = Vector3(0.0, 0.0, 0.0)
var next_action : = Vector3(1.0, 0.0, 0.0)

var total_time : = 0.0

func _set_path(value : Array):
	path = value

func _set_size(value : float):
	scale *= value * RADIUS_TO_SCALE

#s = v*t
#t = s/v
# 1.0 180 in one timestep
# Speed 1.0 means that the agent can rotate for 180 degrees within one time unit.

func _process(delta):
	
	if not last_action:
		last_action = action_to_world(path.pop_front())
	if not next_action:
		next_action = action_to_world(path.pop_front())
	
	print("last_action: ", last_action)
	print("next_action: ", next_action)
	
	if last_action == Vector3.INF or next_action == Vector3.INF:
		return
	
	print("computing shift")
	
	var shift = movement_speed if is_movement_action() \
			else rotation_speed * 180.0 / abs(last_action.z - next_action.z)
	
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
	

#func _process(delta):
#
#
#
#	var shift = movement_speed if is_movement_action() \
#			else rotation_speed * 180.0 / abs(last_action.z - next_action.z)
#	action_time += delta * shift
#
#
#	total_time += delta
#
#	var interpolation : = Vector3.ZERO
#	if action_time < 1.0:
#		 last_action.linear_interpolate(next_action, action_time)
#
#	else:
#		action_time -= 1.0
#		interpolation = last_action.linear_interpolate(next_action, 1.0)
#		last_action = next_action
#		print(rotation_degrees)
#		print(total_time)
#		path[0].pop_front()
#
#		if not path.empty():
#			next_action = action_to_world(path[0].front())
#
#	rotation_degrees = interpolation.z
#	global_position = Vector2(interpolation.x, interpolation.y)
#
		
		
func action_to_world(action) -> Vector3:
	if not action:
		return Vector3.INF
	var world_position = grid.to_world(Vector2(action.x, action.y))
	return Vector3(world_position.x, world_position.y, action.z - 180)

func is_movement_action():
	return not Vector2(last_action.x, last_action.y).is_equal_approx(
			Vector2(next_action.x, next_action.y))
