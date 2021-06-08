class_name Graph extends Node2D


var paths_data : = {}

var paths_data_by_id : = {}

class PathData extends Reference:
	var id : = -1
	var path
	var point
	var neighbors : = []
	
	func _init(idx : int, pth, pnt):
		id = idx
		path = pth
		point = pnt
	
	func _to_string():
		return "path: {0} -> point: {1}".format([path, point])
	

onready var node_paths : = $Paths
onready var node_connections : = $Connections

func _ready():
	create_path_data()
	assign_neighbors()

func create_path_data():
	var id : = 0
	for path in node_paths.get_children():
		if path is ConnectablePath:
			paths_data[path] = []
			var points = path.get_connections_or_areas()
			for point in points:
				var new_path_data = PathData.new(id, path, point)
				print(new_path_data , " ", path.name, " ",  point.name)
				paths_data[path] += [new_path_data]
				paths_data_by_id[id] = new_path_data
				id += 1

func assign_neighbors():
	for path in paths_data:
		for path_data in paths_data[path]:
			path_data.neighbors = get_neighbors(path_data)

func get_neighbors(path_data : PathData)  -> Array:
	if path_data.point is MarginalPointArea:
		return []
	var neighbors : = []
	for path in path_data.point.passable_paths[path_data.path]:
		neighbors.push_back(get_path_data(path, 
			path.get_opposite_point(path_data.point)))
	return neighbors

func get_path_data(path, point) -> PathData:
	for path_data in paths_data[path]:
		if path_data.point == point:
			return path_data
	push_error("Path data: {0} {1} was not found".format(
			[path.name, point.name]))
	return null
	
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
