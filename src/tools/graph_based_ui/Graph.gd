class_name Graph extends Node2D
var processed_connection : = {}
var points : = {}
var connection_to_process : = {}

func _ready():
	for connection in get_parent().get_node("Connections"):
		if not connection is Connection or connection in processed_connection:
			continue
		
		points[connection.global_transform.origin] = []
		for border_point in connection.get_neighbor_points():
			if border_point is PointArea:
				



func get_neighbors() ->Array:
	
