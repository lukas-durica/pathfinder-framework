class_name AgentSIPP extends Node2D

var speed = 1
var grid : Grid
var path : = [] setget _set_path
var time_step : = 0
var last_start : = 0

func _ready():
	$LabelName.text = name

# set path and then set timer and start it
func _set_path(value):
	path = value
	var start_time = path.front().z
	update_position()
	$Timer.start()


func _on_Timer_timeout():
	if path.empty():
		$Timer.stop()
		return
	time_step+=1
	# path denotes, when it is time to leave current vertex
	# while this is discrete movement we update position one
	# timestep later to move agent to new vertex
	if last_start + 1  == time_step:
		update_position()

func update_position():
	

	# vertex position of the agent to world position
	# Vector3 is converted to Vector2
	var vertex = Vector2(path.front().x, path.front().y)
	last_start = path.front().z
	position = grid.to_world(vertex)
	path.pop_front()

	
