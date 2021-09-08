class_name AStarGodotGraphBiDirectional extends AStar2D

#var a_star : = AStar2D.new()
var graph 
var ids_by_areas : = {}
var areas_by_ids : = {}
var start_id : int
var goal_id : int

# start and goal are added, creating connections to their neighbors and
# computing distance to them storing in this dictionary
var additional_connection_lengths : = {}

func initialize(grph : CurvedGraph):
	clear()
	
	graph = grph
	var paths : Node2D = graph.get_node("Paths")
	for path in paths.get_children():
		path = path as ConnectablePath
		if path:
			#print("path: ", path.name)
			var point_areas : Array = path.get_marginal_point_areas()
			for point_area in point_areas:
				point_area = point_area as MarginalPointArea
				
				var area_id = create_or_get_point_id(point_area)
				#print("point_area: {0} id: {1}".format(
				#		[point_area.get_compound_name(), area_id]))
				#print("position: ", point_area.global_position)
				var connected_areas : Array = \
						path.get_connected_areas(point_area.type)
				
				# inter_area is at the same position as point_area
				for conn_area in connected_areas:
					
					conn_area = conn_area as MarginalPointArea
					var conn_area_id : = create_or_get_point_id(conn_area)
					#print("conn_area: {0} id: {1}".format(
					#	[conn_area.get_compound_name(), conn_area_id]))
					#print("position: ", conn_area.global_position)
					
					if not are_points_connected(area_id, conn_area_id):
					#	print("connecting: ", area_id, " and ", conn_area_id)
						connect_points(area_id, conn_area_id)
			
			#print("connecting: ", ids_by_areas[point_areas[0]], " and ", 
			#		ids_by_areas[point_areas[1]])
			connect_points(ids_by_areas[point_areas[0]], 
					ids_by_areas[point_areas[1]])
				
func create_or_get_point_id(point_area : MarginalPointArea) -> int:
	var area_id : int
	if ids_by_areas.has(point_area):
		area_id = ids_by_areas[point_area]
	else:
		area_id = get_available_point_id()
		ids_by_areas[point_area] = area_id
		areas_by_ids[area_id] = point_area
		add_point(area_id, point_area.global_position)
	return area_id


func _compute_cost(from_id : int, to_id : int) -> float:
	#print("from_id: ", from_id)
	#print("to_id: ", to_id)
	
	if from_id == start_id || to_id == start_id \
			|| from_id == goal_id || to_id == goal_id:
		#print("is start or goal: ", start_goal_connections[Vector2(from_id, 
		#		to_id)])
		return additional_connection_lengths[Vector2(from_id, to_id)]
	
	
	var area_from_path = areas_by_ids[from_id].path
	if area_from_path == areas_by_ids[to_id].path:
		#print("path match: ", area_from_path.get_length())
		return area_from_path.get_length()
	#print("not match returning zero")
	return 0.0

func find_solution(start_path : ConnectablePath, start_point : Vector2,
			goal_path : ConnectablePath, goal_point : Vector2) -> Array:
	
	start_id = insert_point_to_graph(start_path, start_point)
	goal_id = insert_point_to_graph(goal_path, goal_point)
	
	# start and goal are situated on the same path, but distance between them
	# on this path is not necessarily the shortest
	if start_path == goal_path:
		connect_points(start_id, goal_id)
		store_distance_between_start_and_goal(start_path, start_point, 
				goal_path, goal_point)
	
	var id_path : Array = get_id_path(start_id, goal_id)
	print("id_path: ", id_path)
	# remove temporary points start and goal
	remove_point(start_id)
	remove_point(goal_id)
	
	id_path.pop_front()
	id_path.pop_back()
	
	return reconstruct_solution(id_path)
	
	

func reconstruct_solution(id_path : Array) -> Array:
	var solution : = []
	var last_path
	for point_id in id_path:
		if last_path != areas_by_ids[point_id].path:
			solution.push_back(areas_by_ids[point_id])
			last_path = areas_by_ids[point_id].path
			print(areas_by_ids[point_id].get_compound_name())
	return solution

# add, connect point to its neighbors and compute and store distance to them
func insert_point_to_graph(path : ConnectablePath, point : Vector2) -> int:
	var point_id = add_point_to_graph(point)
	connect_point_to_neighbors(path, point_id)
	store_distance_to_neighbors(path, point_id)
	return point_id

func connect_point_to_neighbors(path : ConnectablePath, point_id : int):
	var path_areas : =  path.get_marginal_point_areas()
	connect_points(point_id, ids_by_areas[path_areas[0]])
	connect_points(point_id, ids_by_areas[path_areas[1]])

# usually for start point and goal point, added point needs to be manually
# removed after search
func add_point_to_graph(point : Vector2) -> int:
	var point_id = get_available_point_id()
	add_point(point_id, point)
	return point_id

func store_distance_to_neighbors(path : ConnectablePath, point_id : int):
	
	var point_position = get_point_position(point_id)
	var offset : = HelperFunctions.get_closest_path_offset(
			path, point_position)
	
	var id_start_area = ids_by_areas[path.start_point_area]
	# add their combination to make lookup easier
	additional_connection_lengths[Vector2(point_id, id_start_area)] = offset
	additional_connection_lengths[Vector2(id_start_area, point_id)] = offset
	
	var id_end_area = ids_by_areas[path.end_point_area]
	additional_connection_lengths[Vector2(point_id, id_end_area)] \
			= path.get_length() - offset
	additional_connection_lengths[Vector2(id_end_area, point_id)] \
			= path.get_length() - offset
	
func store_distance_between_start_and_goal(
			start_path : ConnectablePath, start_point : Vector2,
			goal_path : ConnectablePath, goal_point : Vector2):
		var start_offset = HelperFunctions.get_closest_path_offset(
				start_path, start_point)
		var goal_offset = HelperFunctions.get_closest_path_offset(
				goal_path, goal_point)
		var distance = abs(start_offset - goal_offset)
		additional_connection_lengths[Vector2(start_id, goal_id)] = distance
		additional_connection_lengths[Vector2(goal_id, start_id)] = distance



