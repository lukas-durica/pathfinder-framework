class_name AStarGodotGraph extends Node

var a_star : = AStar2D.new()
var graph 
var ids_by_areas : = {}
var areas_by_ids : = {}
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
		areas_by_ids[area_id] = point_area
		a_star.add_point(area_id, point_area.global_position)
	return area_id


func find_solution(start_path : ConnectablePath, start_point : Vector2,
			goal_path : ConnectablePath, goal_point : Vector2) -> Array:
	
#	var local_start_point : = start_path.to_local(start_point)
#	var local_goal_point : = goal_path.to_local(goal_point)
#
#	var closest_start_point : = start_path.curve.get_closest_point(
#			local_start_point)
#	var closest_goal_point : = goal_path.curve.get_closest_point(
#			local_goal_point)
#
#	var global_start_point : = start_path.to_global(closest_start_point)
#	var global_goal_point : = goal_path.to_global(closest_goal_point)
#
#	print("closest_start_point: ", closest_start_point)
#	print("closest_goal_point: ", closest_goal_point)
	
	var start_id : = a_star.get_available_point_id()
	a_star.add_point(start_id, start_point)
	
	var goal_id : = a_star.get_available_point_id()
	a_star.add_point(goal_id, goal_point)
	
	print("start_id: ", start_id)
	print("goal_id: ", goal_id)
	
	var start_path_areas : =  start_path.get_marginal_point_areas()
	var goal_path_areas : =  goal_path.get_marginal_point_areas()
	
	a_star.connect_points(start_id, ids_by_areas[start_path_areas[0]])
	a_star.connect_points(start_id, ids_by_areas[start_path_areas[1]])
	
	a_star.connect_points(goal_id, ids_by_areas[goal_path_areas[0]])
	a_star.connect_points(goal_id, ids_by_areas[goal_path_areas[1]])
	
	var id_path : Array = a_star.get_id_path(start_id, goal_id)
	
	print("solution id: ", id_path)
	print("solution pn: ", a_star.get_point_path(start_id, goal_id))
	
	a_star.remove_point(start_id)
	a_star.remove_point(goal_id)
	
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
	
