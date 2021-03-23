tool
class_name PointArea extends Area2D

var path
var is_start
var connection

func _draw():
	if not get_overlapping_areas().size() == 0:
		var c = Color.azure
		if connection:
			draw_circle(Vector2.ZERO, 10.0, Color(c.r, c.g, c.b, 0.25))
		else:
			draw_circle(Vector2.ZERO, 10.0, Color(c.r, c.g, c.b, 0.5))

func _on_Area2D_area_entered(area):
	if get_overlapping_areas().size() == 1:
		update()

func _on_Area2D_area_exited(area):
		update()

