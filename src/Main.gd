extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Grid.adjust_screen_to_grid($Camera2D)
	print($Grid.get_cellv(Vector2(2, 2)))


