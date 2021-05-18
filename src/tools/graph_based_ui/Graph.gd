class_name Graph extends Node2D


var paths : = {}
var path_points : = {}

onready var node_paths : = $Paths
onready var node_connections : = $Connections

func _ready():
	for path in node_paths.get_children():
		if path is ConnectablePath:
			paths[path] = []
			path_points[path] = []
			var points = path.get_connections_or_areas()
			for point in points:
				if point is Connection:
					paths[path].push_back(
							(point as Connection).passable_paths[path])
					path_points[path].push_back(point)


