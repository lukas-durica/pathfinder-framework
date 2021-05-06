tool
class_name PointArea extends Area2D

signal point_area_entered(my_area, entered_area)
signal point_area_exited(my_area, exited_area)
signal point_area_was_clicked(area, button_type)
#signal path_area_entered(my_area, entered_area)
#signal path_area_exited(my_area, exited_area)

var path
var is_start
var connection
var overlapped_point_areas : = []
#var entered_path_area : Area2D

func _draw():
	if not overlapped_point_areas.empty():
		var c = Color.azure
		c.a = 0.25 if connection else 0.5
		draw_circle(Vector2.ZERO, 10.0, c)
	else:
		var c = Color.green if is_start else Color.red
		draw_circle(Vector2.ZERO, 10.0, Color(c.r, c.g, c.b, 0.5))

func _on_Area2D_area_entered(area : Area2D):
	# avoid the cyclic reference
	if area.is_in_group("point_areas"):
		overlapped_point_areas.push_back(area)
		emit_signal("point_area_entered", self, area)
		if Engine.editor_hint and overlapped_point_areas.size() == 1:
			update()
#	elif area.is_in_group("path_areas") and overlapped_point_areas.empty() \
#			and area.path != path:
#		entered_path_area = area
#		emit_signal("path_area_entered", self, area)
#		if Engine.editor_hint:
#			update()

func _on_Area2D_area_exited(area : Area2D):
	if area.is_in_group("point_areas"):
		overlapped_point_areas.erase(area)
		emit_signal("point_area_exited", self, area)
		if Engine.editor_hint:
			update()
#	elif area.is_in_group("path_areas") and entered_path_area:
#		entered_path_area = null
#		emit_signal("path_area_exited", self, area)
#		if Engine.editor_hint:
#			update()

# clicking on the area
func _on_Area2D_input_event(viewport : Node, event : InputEvent, 
		shape_idx : int):
	
	if not Engine.editor_hint and event is InputEventMouseButton \
			and event.pressed:
		match event.button_index:
			BUTTON_LEFT, BUTTON_RIGHT:
				emit_signal("point_area_was_clicked", self, event.button_index)

func is_connection_valid() -> bool:
	return connection and connection.is_inside_tree()
	
func get_compound_name() -> String:
	return path.name + "/" + name

func update_border_point(pos : Vector2):
	if is_start:
		path.set_start_point(pos)
	else:
		path.set_end_point(pos)
	
