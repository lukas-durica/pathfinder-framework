extends Node2D

var path = [] setget _set_path
var grid : Grid

func _set_path(value):
	if path.empty():
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
		
	position = grid.map_to_world(path.front())
	path.pop_front()
