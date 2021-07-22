class_name AStarGodotGraph extends Node

var a_star : = AStar2D.new()
var graph 
var ids_by_areas : = {}
func _init(grph : CurvedGraph):
	a_star.clear()
	
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
				var interconnected_areas : Array = \
						path.get_passable_connection_areas(point_area.type)
				
				# inter_area is at the same position as point_area
				for conn_area in interconnected_areas:
					
					conn_area = conn_area as MarginalPointArea
					var conn_area_id : = create_or_get_point_id(conn_area)
					print("conn_area: {0} id: {1}".format(
						[conn_area.get_compound_name(), conn_area_id]))
					
					if not a_star.are_points_connected(area_id, conn_area_id):
						print("connecting: ", area_id, " and ", conn_area_id)
						a_star.connect_points(area_id, conn_area_id)
			
			print("connecting: ", ids_by_areas[point_areas[0]], " and ", 
					ids_by_areas[point_areas[1]])
			a_star.connect_points(ids_by_areas[point_areas[0]], 
					ids_by_areas[point_areas[1]])
				
func create_or_get_point_id(point_area : MarginalPointArea) -> int:
	var area_id : int
	if ids_by_areas.has(point_area):
		area_id = ids_by_areas[point_area]
	else:
		area_id = a_star.get_available_point_id()
		ids_by_areas[point_area] = area_id
		a_star.add_point(area_id, point_area.global_position)
	return area_id


func find_solution(start_path : ConnectablePath, point_on_path : Vector2, 
		goal_area : Node2D) -> Array:
	
	
	
	# add start position to came_from and add 0 as total movemenbt cost
	
	var length : = start_path.get_length()
	var areas : = start_path.get_marginal_point_areas()
	
	#var frontier = MinBinaryHeap.new()
	#frontier.insert_key({value = 0, vertex = start})
	
	
	
	#var start area is closer
	#var initial_area  = start_area if offset < length - offset else end_area
	
	 #get_closest_position_in_segment
	
	
	var start_id = ids_by_areas[initial_area]
	var goal_id = ids_by_areas[goal_area]
	print("solution: ", a_star.get_id_path(start_id, goal_id))
	
	return []
	
