class_name AStarGodotGraph extends AStar2D

#var a_star : = AStar2D.new()
var graph 
var ids_by_areas : = {}
var areas_by_ids : = {}
var start_id : int
var goal_id : int
var start_to_0_area_length : float
var start_to_1_area_length : float
var goal_to_0_area_length : float
var goal_to_1_area_length : float

func initialize(grph : CurvedGraph):
	clear()
	
	graph = grph
	var paths : Node2D = graph.get_node("Paths")
	for path in paths.get_children():
		path = path as ConnectablePath
		if path:
			print("path: ", path.name)
			var point_areas : Array = path.get_marginal_point_areas()
			for point_area in point_areas:
				point_area = point_area as MarginalPointArea
				
				var area_id = create_or_get_point_id(point_area)
				print("point_area: {0} id: {1}".format(
						[point_area.get_compound_name(), area_id]))
				print("position: ", point_area.global_position)
				var interconnected_areas : Array = \
						path.get_passable_connection_areas(point_area.type)
				
				# inter_area is at the same position as point_area
				for conn_area in interconnected_areas:
					
					conn_area = conn_area as MarginalPointArea
					var conn_area_id : = create_or_get_point_id(conn_area)
					print("conn_area: {0} id: {1}".format(
						[conn_area.get_compound_name(), conn_area_id]))
					print("position: ", conn_area.global_position)
					
					if not are_points_connected(area_id, conn_area_id):
						print("connecting: ", area_id, " and ", conn_area_id)
						connect_points(area_id, conn_area_id)
			
			print("connecting: ", ids_by_areas[point_areas[0]], " and ", 
					ids_by_areas[point_areas[1]])
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


func _compute_cost(from_id, to_id):
	print("from_id: ", from_id)
	print("to_id: ", to_id)
	
	if from_id == start_id:
		pass
	
	#start_to_0_area_length
	#start_to_1_area_length
	#goal_to_0_area_length
	#goal_to_1_area_length
	
	var area_from_path = areas_by_ids[from_id].path
	if area_from_path == areas_by_ids[to_id].path:
		return area_from_path.get_length()
	return 0

func find_solution(start_path : ConnectablePath, start_point : Vector2,
			goal_path : ConnectablePath, goal_point : Vector2) -> Array:
	
	var local_start_point : = start_path.to_local(start_point)
	var local_goal_point : = goal_path.to_local(goal_point)
#
#	var closest_start_point : = start_path.curve.get_closest_point(
#			local_start_point)
#	var closest_goal_point : = goal_path.curve.get_closest_point(
#			local_goal_point)

	var start_offset : = start_path.curve.get_closest_offset(local_start_point)
	var goal_offset : = goal_path.curve.get_closest_offset(local_goal_point)

#
#	var global_start_point : = start_path.to_global(closest_start_point)
#	var global_goal_point : = goal_path.to_global(closest_goal_point)
#
#	print("closest_start_point: ", closest_start_point)
#	print("closest_goal_point: ", closest_goal_point)
	
	#offset
	#length - offset
	
	
	
	start_id = get_available_point_id()
	add_point(start_id, start_point)
	
	goal_id = get_available_point_id()
	add_point(goal_id, goal_point)
	
	print("start_id: ", start_id)
	print("goal_id: ", goal_id)
	
	var start_path_areas : =  start_path.get_marginal_point_areas()
	var goal_path_areas : =  goal_path.get_marginal_point_areas()
	
	start_to_0_area_length = start_offset
	start_to_1_area_length = start_path.get_length() - start_offset
	
	goal_to_0_area_length = goal_offset
	goal_to_1_area_length = start_path.get_length() - goal_offset
	
	connect_points(start_id, ids_by_areas[start_path_areas[0]])
	connect_points(start_id, ids_by_areas[start_path_areas[1]])
	
	connect_points(goal_id, ids_by_areas[goal_path_areas[0]])
	connect_points(goal_id, ids_by_areas[goal_path_areas[1]])
	
	#cast PoolArrayInt to Array for function pop_front and pop_back
	var id_path : Array = get_id_path(start_id, goal_id)
	
	print("solution id: ", id_path)
	print("solution pn: ", get_point_path(start_id, goal_id))
	
	remove_point(start_id)
	remove_point(goal_id)
	
	id_path.pop_front()
	id_path.pop_back()
	
	var solution : = []
	solution.push_back(areas_by_ids[id_path[0]].path)
	var idx : = 0
	for point_id in id_path:
		if idx % 2 != 0:
			solution.push_back(areas_by_ids[point_id].path)
		idx += 1
	
	
	return solution

