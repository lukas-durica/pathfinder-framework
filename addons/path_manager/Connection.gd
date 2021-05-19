tool

class_name Connection extends Node2D

# connections is dictionary with the key of path name and array of connected 
# other path names as as value
# making connections means making passable from one path to another
# dont assign it with := {} Godots bug will share it through the all instancies
# for simplicity only the names are stored, not a the whole path
# passable_connections["ConnectablePath2"] = ["ConnectablePath", 
#		"ConnectablePath3"]
export(Dictionary) var passable_connections

# serves purely for reconnecting after loading the scene
# e.g.: ../../Paths/ConnectablePath2/End
export(Array) var connected_area_paths

# managing connected areas for position update as connection will change its
# position, and as well as destroying connection if there is no other
# connected areas
var connected_areas : = []

# only in run time for creating pathfindig graph
var connected_paths : = []

# only in run time for finding connected paths
var passable_paths : = {}

var id : = -1

func _ready():
	set_notify_transform(true)
	
	if not connected_area_paths.empty():
		reconnect()
	
	connected_paths = get_connected_paths()
	if not Engine.editor_hint:
		create_passable_paths()
	
	
func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update_areas_position()
			update()

func _draw():
	var c = Color.blue
	draw_circle(Vector2.ZERO, 10.0, Color(c.r, c.g, c.b, 0.5))


func _to_string():
	return name

func update_areas_position():
	for connected_area in connected_areas:
		connected_area.update_border_point(global_position)

func add_to_connection(connected_area : PointArea):
	print("add to connection")
	if connected_area.is_connection_valid():
		push_error("connection already exists!")
	
	connected_area.connection = self
	connected_area_paths.push_back(String(get_path_to(connected_area)))
	connected_areas += [connected_area]
	# connect it to all connections there are
	passable_connections[connected_area.path.name] = []
	for path_to_path_node in passable_connections:
		if path_to_path_node == connected_area.path.name:
			continue
		
		# add to this connection to every already added path
		passable_connections[path_to_path_node] += [connected_area.path.name]
		
		#add the already added connections to this path
		passable_connections[connected_area.path.name] += [path_to_path_node]
	

func remove_from_connection(connected_area : Area2D):
	connected_area_paths.erase(String(get_path_to(connected_area)))
	connected_areas.erase(connected_area)
	passable_connections.erase(connected_area.path.name)
	connected_area.connection = null
	for connection in passable_connections:
		var node_path_idx = passable_connections[connection].find(
				connected_area.path.name)
		if node_path_idx != -1:
			passable_connections[connection].remove(node_path_idx)
	if connected_areas.size() == 1:
		var last_connected_area = connected_areas[0]
		last_connected_area.connection = null
		queue_free()

func update_path_name(old_name : String, new_name : String):
	for path_to_area in connected_area_paths:
		
		var idx : int = path_to_area.rfindn("/")
		var idx2 : int = path_to_area.rfindn("/", idx - 1)
		if old_name == path_to_area.substr(idx2 + 1, idx - idx2 - 1):
			connected_area_paths.erase(path_to_area)
			path_to_area.erase(idx2 + 1, old_name.length())
			path_to_area = path_to_area.insert(idx2 + 1, new_name)
			connected_area_paths.push_back(path_to_area)
			break
	
	#update the key of the dictionary wih new name
	var path_names = passable_connections[old_name]
	passable_connections.erase(old_name)
	passable_connections[new_name] = path_names
	
	# find all passable connections and update it ith new name
	for path_name in passable_connections:
		for passable_path_name in passable_connections[path_name]:
			if passable_path_name == old_name:
				passable_connections[path_name].erase(old_name)
				passable_connections[path_name].push_back(new_name)


func extract_path_name(node_path_area : String) -> String:
	var idx : int = node_path_area.rfindn("/")
	var idx2 : int = node_path_area.rfindn("/", idx - 1)
	return node_path_area.substr(idx2 + 1, idx - idx2 - 1)
	 

# return positions of connections and not connected areas
#func get_neighbor_points() -> Array:
#	var border_points : = []
#	for path in get_connected_paths():
#		var point = path.get_connections_or_areas()
#		if point != self:
#			border_points.push_back(point)
#	return border_points

func get_neighbor_points(path) -> Array:
	var neighbor_points : = []
	for path in passable_paths[path]:
		var points : Array = path.get_connections_or_areas()
		for point in points:
			if point != self:
				neighbor_points.push_back(point)
	return neighbor_points
	

func create_passable_paths():
	for path_name in passable_connections:
		var path = get_node(get_relative_node_path_to_path(path_name))
		
		passable_paths[path] = []
		for connected_path in passable_connections[path_name]:
			passable_paths[path].push_back(get_node(
					get_relative_node_path_to_path(connected_path)))

func get_relative_node_path_to_path(path_name : String) -> String:
	for path_to_area in connected_area_paths:
		if extract_path_name(path_to_area) == path_name:
			var idx : int = path_to_area.rfindn("/")
			return path_to_area.substr(0, idx)
	return String()
	

func get_connected_paths() -> Array:
	if not connected_paths.empty():
		return connected_paths
	
	var paths : = []
	for area in connected_areas:
		# connection can hold both areas of one path
		if not area.path in paths:
			paths.push_back(area.path)
	return paths

func reconnect():
	for path in connected_area_paths:
		var area = get_node(path)
		area.connection = self
		connected_areas += [area]
