extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var a_star : = AStar2D.new()
	a_star.add_point(0, Vector2(0,0))
	a_star.add_point(1, Vector2(5,0))
	a_star.add_point(2, Vector2(10,0))
	a_star.connect_points(0, 1)
	a_star.connect_points(1, 2)
	print(a_star.get_id_path(2,0))
