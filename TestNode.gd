extends AStar2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	add_point(0, Vector2(0,0))
	add_point(1, Vector2(5,0))
	add_point(2, Vector2(10,0))
	connect_points(0, 1)
	connect_points(1, 2)
	print(get_id_path(2,0))
	var n = duplicate()
	print(n.get_id_path(2,0))
