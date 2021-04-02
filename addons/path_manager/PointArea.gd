tool
class_name PointArea extends Area2D

signal point_area_entered(my_area, entered_area)
signal point_area_exited_wit_connection(my_area, exited_area)
signal point_area_exited_without_connection(my_area, exited_area)
signal area_was_clicked(area, button_type)

var path
var is_start
var connection
var overlapped_point_areas : = []

func _draw():
	if not get_overlapping_areas().size() == 0:
		var c = Color.azure
		if connection:
			draw_circle(Vector2.ZERO, 10.0, Color(c.r, c.g, c.b, 0.25))
		else:
			draw_circle(Vector2.ZERO, 10.0, Color(c.r, c.g, c.b, 0.5))

func _on_Area2D_area_entered(area : Area2D):
	# avoid the cyclic reference
	if area.is_in_group("point_areas"):
		overlapped_point_areas.push_back(area)
		emit_signal("point_area_entered", self, area)
		if Engine.editor_hint and overlapped_point_areas.size() == 1:
			update()

func _on_Area2D_area_exited(area : Area2D):
	if area.is_in_group("point_areas"):
		overlapped_point_areas.erase(area)
		if area.connection:
			emit_signal("point_area_exited_wit_connection", self, area)
		else:
			emit_signal("point_area_exited_without_connection", self, area)
	
		if Engine.editor_hint:
			update()

func _on_Area2D_input_event(viewport : Node, event : InputEvent, shape_idx : int):
	if not Engine.editor_hint and event is InputEventMouseButton \
			and event.pressed:
		match event.button_index:
			BUTTON_LEFT, BUTTON_RIGHT:
				emit_signal("area_was_clicked", self, event.button_index)
			
func get_compound_name() -> String:
	return path.name + "/" + name

func _exit_tree():
	print(get_compound_name(), ": ExitTree")

