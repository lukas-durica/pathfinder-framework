extends Node2D

var astar : = AStar2D.new()

func _ready():
	astar.add_point(0, Vector2.ZERO)
	astar.add_point(1, Vector2.ZERO)
	astar.add_point(2, Vector2.ZERO)
	astar.connect_points(0, 1)
	astar.connect_points(1, 2)
	for point_id in astar.get_points():
		#print(point_id, ": ", astar.get_point_position(point_id))
		print(point_id ,": conn: ", astar.get_point_connections(point_id))
	print(astar.get_points())
	
	
	


