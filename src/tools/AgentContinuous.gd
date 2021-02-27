class_name AgentContinuous extends Node2D 

var grid : Grid
var action_time : = 0.0 
var path : = [] setget _set_path
var next_state : = Vector2.ZERO
var last_state : = Vector2.ZERO

func _set_path(value : Array):
	path = value
	start()
func _ready():
	set_process(false)

func _process(delta):
	if path.empty():
		set_process(false)
		return
	var target_reached : = false
	action_time += delta / (grid.TIME_STEP * grid.TIME_STEP_DURATION)
	var interpolation : = Vector2.ZERO
	
	if action_time <= 1.0:
		interpolation = last_state.linear_interpolate(next_state, action_time)
	else:
		action_time -= 1.0
		interpolation = last_state.linear_interpolate(next_state, 1.0)
		
		last_state = next_state
		
		path.pop_front()
		
		
		if path.empty():
			target_reached = true
		
		if not path.empty():
			next_state = action_to_state(path.front())
	
	global_transform.origin = Vector2(interpolation.x, interpolation.y)
	

		#if next_state_is_target:
		#	print("next_state_is_target")
		#	target_reached = true
		#	return
	if target_reached:
		target_reached = false
		#paths.pop_front()
		do_action()
		
		if path.empty():
			# task is finished, but MRS is not at the start vertex
			action_time = 0.0
			set_process(false)


func action_to_state(action) -> Vector2:
	if not action:
		return Vector2.INF
	var world_position = grid.to_world(Vector2(action.x, action.y))
	return Vector2(world_position.x, world_position.y)


func do_action():
	pass

func start():
	if not path.empty() and not is_processing():
		set_default_action()
		set_process(true)

func set_default_action():
	var action = path.pop_front()
	global_transform.origin = grid.to_world(Vector2(action.x, action.y))
	last_state = action_to_state(action)
	next_state = action_to_state(path.front())

