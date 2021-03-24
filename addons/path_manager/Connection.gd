tool

class_name Connection extends Node2D

# connections is dictionary with the key of path name and array of connected 
# other path names as as value
# making connections means making passable from one path to another
# dont assign it with := {} Godots bug will share it through the instancies
# for simplicity only the name is stored no the whole path
export(Dictionary) var passable_connections

# serves purely for reconnecting after loading the scene
export(Array) var connected_area_paths

# managing connected areas for position update as connection will change its
# position, and as well as destroying connection if there is no other
# connected areas
var connected_areas : = []

# only in run time
var connected_paths : = []

func _ready():
	
	set_notify_transform(true)
	reconnect()
	connected_paths = get_connected_paths()

func _notification(what):
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update_areas_position()
			update()

func _draw():
	var c = Color.palegreen
	draw_circle(Vector2.ZERO, 10.0, Color(c.r, c.g, c.b, 0.5))

func update_areas_position():
	for connected_area in connected_areas:
		connected_area.global_transform.origin = global_transform.origin
		connected_area.path.update_border_point(connected_area)

func add_to_connection(connected_area : PointArea):
	if connected_area.connection:
		push_error("connection already exists!")
	
	connected_area.connection = self
	connected_area_paths.push_back(get_path_to(connected_area))
	connected_areas += [connected_area]
	# connect it to all connections there are
	passable_connections[connected_area.path.name] = []
	for path_to_path_node in passable_connections:
		if path_to_path_node == connected_area.path.name:
			continue
		
		passable_connections[path_to_path_node] += [connected_area.path.name]
		passable_connections[connected_area.path.name] += [path_to_path_node]
	
	var path = connected_area.path
	path.update_border_point(connected_area)
	
	for area in connected_areas:
		should_create_passable_connection(area, connected_area)

func remove_from_connection(connected_area : Area2D):
	print("removing from connection: ", connected_area.path.name, "/", 
			connected_area.name)
	connected_area_paths.erase(get_path_to(connected_area))
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

func should_create_passable_connection(area1 : PointArea, area2 : PointArea) \
		-> bool:
			
	if not area1 or not area2:
		return false
	var normal1 = area1.path.get_connection_normal(area1.is_start)
	var normal2 = area2.path.get_connection_normal(area2.is_start)
	print("angle to: ", rad2deg(normal2.angle_to(normal1)))
	return false

# return positions of connections and not connected areas
func get_neighbor_points() -> Array:
	var border_points : = []
	for path in get_connected_paths():
		var point = path.get_connections_or_areas()
		if point != self:
			border_points.push_back(point)
	return border_points
	

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
	print("Reconnecting...")
	
	for path in connected_area_paths:
		var area = get_node(path)
		print("path: ", path)
		print(area.path.name, "/", area.name)
		area.connection = self
		connected_areas += [area]