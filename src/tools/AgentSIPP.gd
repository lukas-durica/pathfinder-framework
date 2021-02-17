class_name AgentSipp extends Node2D


var grid : Grid
var path : = [] setget _set_path

func _ready():
	$LabelName.text = name

# set path and then set timer and start it
func _set_path(value):
	pass
	
func update_position():
	# vertex position of the agent to world position
	# Vector3 is converted to Vector2
	var vertex = Vector2(path.front().x, path.front().y)
	position = grid.to_world(vertex)
	path.pop_front()
