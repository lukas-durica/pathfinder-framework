class_name AStarGodotGraph extends Node

var a_star = AStar2D.new()
var graph 

func _init(grph : CurvedGraph):
	graph = grph

	a_star.clear()
	# already added vertexes to Godot's A* representation as points
	var already_added : = {}
	
	# vertexes that already have their IDs but was not added to already_added
	var has_id : = {}
	
	# reserve memory in A* with the size of the grid
	#a_star.reserve_space(graph.paths_data.size())
	for path in graph.paths_data:
		for path_data in graph.paths_data[path]:
		
			# if the current cell is has id get the id, else generate one
			var area_id = has_id[path_data.area] if has_id.has(path_data.area) else \
					a_star.get_available_point_id()
			
			print("area_id: ", area_id)
			print("path_data : ", path_data.area.get_compound_name())
			#add current cell to the A*
			a_star.add_point(area_id, path_data.area.global_position)
			
			#add it to already_added
			already_added[path_data.area] = area_id
			
			#get its neighbors
			for neighbor in path_data.neighbors:
				print("neighbor: ", neighbor.area.get_compound_name())
				# if the neighbor is not obstacle and is not in already added
				if not already_added.has(neighbor.area):
					
						# if neighbor has id, get its id
						var neighbor_id
						if neighbor.area in has_id:
							neighbor_id = has_id[neighbor.area]
						else:
							#else generate new id and add it there
							neighbor_id = a_star.get_available_point_id()
							has_id[neighbor.area] = neighbor_id
						# add neighbor as point
						
						a_star.add_point(neighbor_id, neighbor.area.global_position)
						# and connect it to the current cell
						a_star.connect_points(area_id, neighbor_id)


func find_solution(start_path : ConnectablePath, offset : float, 
		goal_area : Node2D) -> Array:
	
	var start_path_data_0 = graph.paths_data[start_path][0]
	var start_path_data_1 = graph.paths_data[start_path][1]
	
	# add start position to came_from and add 0 as total movemenbt cost
	
	var length = start_path.get_length()
	
	#var frontier = MinBinaryHeap.new()
	#frontier.insert_key({value = 0, vertex = start})
	
	var start_area 
	var end_area
	if start_path_data_0.area.type == MarginalPointArea.START:
		start_area = start_path_data_0.area
		end_area = start_path_data_1.area
	else:
		start_area = start_path_data_1.area
		end_area = start_path_data_0.area
		
	var initial_area
	#var start area is closer
	initial_area = start_area if offset < length - offset else end_area
		
	
	var start_id = a_star.get_closest_point(initial_area.global_position)
	var goal_id = a_star.get_closest_point(goal_area.global_position)
	print("solution: ", a_star.get_point_path(start_id, goal_id))
	return []
	
