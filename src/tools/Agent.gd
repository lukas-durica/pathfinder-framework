extends Node2D

var path : = [] setget _set_path
var grid : Grid



func _ready():
	randomize()
	modulate = Color(randf(), randf(), randf(), 1.0)

func _set_path(value):
	if value.empty():
		return
	path = value
	update_position()
	$Timer.start()
	visible = true
	
func _on_Timer_timeout():
	update_position()
	
func update_position():
	if path.empty():
		$Timer.stop()
		return
	
	#vertex position of the agent to world position
	#if needed Vector3 is converted to Vector2
	var vertex = Vector2(path.front().x, path.front().y)
	position = grid.to_world(vertex)
	path.pop_front()
