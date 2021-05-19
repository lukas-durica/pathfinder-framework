class_name Graph extends Node2D


var paths_and_points : = {}

class PathData extends Reference:
	var path
	var point
	
	func _init(pth, pnt):
		path = pth
		point = pnt

onready var node_paths : = $Paths
onready var node_connections : = $Connections

func _ready():
	#create_ids()
	for path in node_paths.get_children():
		if path is ConnectablePath:
			var points = path.get_connections_or_areas()
			for point in points:
				print("key: ", {path = path, point = point})
				paths_and_points[{path = path, point = point}] \
						= get_paths_and_points({path = path, point = point})
				

func get_paths_and_points(path_and_point : Dictionary) -> Array:
	if path_and_point.point is PointArea:
		return []
	var paths_data : = []
	for path in path_and_point.point.passable_paths[path_and_point.path]:
		#print("data: ", {path = path, 
		#		point = path.get_opposite_point(path_and_point.point)})
		
		paths_data.push_back({path = path, 
				point = path.get_opposite_point(path_and_point.point)})
	return paths_data
	
func create_ids():
	var id = 0
	for path in node_paths.get_children():
		if path is ConnectablePath:
			path.id = id
			id += 1
	id = 0
	for connection in node_connections.get_children():
		if connection is Connection:
			connection.id = id
			id += 1
