extends GridBasedAlgorithm

func _ready():
	var start_position = grid.to_vertex(start.position)
	var goal_position = grid.to_vertex(goal.position)
	var already_added : = {}
	var open : = {}
	var a_star = AStar2D.new()
	a_star.reserve_space(grid.get_used_cells().size())
	print(grid.get_used_cells())
	for cell in grid.get_used_cells():
		if not grid.is_cell_obstacle(cell):
			var cell_id = a_star.get_available_point_id()
			a_star.add_point(cell_id, cell)
			already_added[cell] = cell_id
			for neighbor in grid.get_neighbors(cell):
				if not neighbor in already_added:
					var neighbor_id
					if neighbor in open:
						neighbor_id = open[neighbor]
					else:
						neighbor_id = a_star.get_available_point_id()
						open[neighbor] = neighbor_id
					a_star.add_point(neighbor_id, neighbor)
					a_star.connect_points(cell_id, neighbor_id)
	print("count: ", a_star.get_point_count())
	
	
	
	if grid.is_cell_free(start_position) and grid.is_cell_free(goal_position):
		if start_position in already_added and goal_position in already_added:
			var start_id = already_added[start_position]
			var goal_id = already_added[goal_position]
			print("id_start: ", start_id)
			print("id_goal: ", goal_id)
			print("connections: ", a_star.get_point_connections(start_id))
			var path = a_star.get_point_path(start_id, goal_id)
			print("astar: ", path)
			print("get_id_path ", a_star.get_id_path(start_id, goal_id))
		elif not start_position in already_added:
			push_error("Start position is not in already_added")
		else:
			push_error("Goal position is not in already_added")
	elif not grid.is_cell_free(start_position):
		push_error("Start position is not free!")
		return false
	else:
		push_error("Goal position is not free!")
		return false
