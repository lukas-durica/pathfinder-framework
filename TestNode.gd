extends Node2D


onready var path : = $ConnectablePath
var draw_position : = Vector2.ZERO


func _ready():
	var length = path.curve.get_baked_length()
	draw_position = path.curve.interpolate_baked(length / 2.0)

func _draw():
	draw_circle(draw_position, 5.0, Color.red)

