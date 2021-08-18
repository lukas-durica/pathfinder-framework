class_name CurvedGraph extends Node2D


var paths_data : = {}

var paths_data_by_id : = {}


onready var node_paths : = $Paths

class PathData extends Reference:
	var id : = -1
	var path : ConnectablePath
	var area : MarginalPointArea
	# array of path data types
	var neighbors : = []
	
	func _init(p_idx : int, p_path : ConnectablePath, 
			p_area : MarginalPointArea):
		id = p_idx
		path = p_path
		area = p_area
	
	func _to_string():
		return "path: {0} -> point: {1}".format(
				[path, area.get_compound_name()])

func _ready():
	yield(get_tree(),"physics_frame")
	yield(get_tree(),"physics_frame")
	create_path_data()
	assign_neighbors()

func create_path_data():
	var id : = 0
	for path in node_paths.get_children():
		if path is ConnectablePath:
			paths_data[path] = []
			var areas = path.get_marginal_point_areas()
			for area in areas:
				var new_path_data = PathData.new(id, path, area)
				paths_data[path] += [new_path_data]
				paths_data_by_id[id] = new_path_data
				id += 1

func assign_neighbors():
	
	for path in paths_data:
		for path_data in paths_data[path]:
			path_data.neighbors = get_neighbors(path_data)

func get_neighbors(path_data : PathData)  -> Array:
	var neighbors : = []
	
	var connections_data = path_data.path.get_passable_connections_data(
			path_data.area.type)
	for connection in connections_data:
		#print(get_path_data(connection.path, connection.area))
		neighbors.push_back(get_path_data(connection.path, connection.area))
	
	
	return neighbors

func get_path_data(path, area) -> PathData:
	for path_data in paths_data[path]:
		if path_data.area == area:
			return path_data
	push_error("Path data: {0} {1} was not found".format(
			[path.name, area.name]))
	return null



