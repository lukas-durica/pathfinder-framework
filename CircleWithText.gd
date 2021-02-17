class_name CircleWithText extends Node2D

onready var label : = $Label

var parent


func _draw():
	if parent:
		var parent_origin = parent.global_transform.origin
		draw_line(Vector2.ZERO, to_local(parent_origin), Color.red, 3.0)
	draw_circle(Vector2.ZERO, 25, Color.white)
	
