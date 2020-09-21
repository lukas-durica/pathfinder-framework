"""
This algortihm uses Godot's Astar. It converts the grid to Godot's Astar 
representation.
"""

extends GridBasedAlgorithm

class_name AStarGodot

var a_star = AStar2D.new()

func _initialize(grid):
	a_star.clear()
	# already added vertexes to Godot's A* representation as points
	var already_added : = {}
	
	# vertexes that already have their IDs but was not added to already_added
	var has_id : = {}
	
	# reserve memory in A* with the size of the grid
	a_star.reserve_space(grid.get_used_cells().size())
	for current_cell in grid.get_used_cells():
		
		# check if the current cell is not and obstacle
		if not grid.is_cell_obstacle(current_cell):
			
			# if the current cell is has id get the id, else generate one
			var cell_id = has_id[current_cell] if has_id.has(current_cell) else \
					a_star.get_available_point_id()
			
			#add current cell to the A*
			a_star.add_point(cell_id, current_cell)
			
			#add it to already_added
			already_added[current_cell] = cell_id
			
			#get its neighbors
			for neighbor in grid.get_neighbors(current_cell):
				
				# if the neighbor is not obstacle and is not in already added
				if not grid.is_cell_obstacle(neighbor) \
						and not already_added.has(neighbor):
					
						# if neighbor has id, get its id
						var neighbor_id
						if neighbor in has_id:
							neighbor_id = has_id[neighbor]
						else:
							#else generate new id and add it there
							neighbor_id = a_star.get_available_point_id()
							has_id[neighbor] = neighbor_id
						# add neighbor as point 
						a_star.add_point(neighbor_id, neighbor)
						# and connect it to the current cell
						a_star.connect_points(cell_id, neighbor_id)


# find ids of the closest points to start and goal and pass them to the 
# algorithm
func _find_solution(starts_and_goals : Array):
	var start_id = a_star.get_closest_point(starts_and_goals[0].start)
	var goal_id = a_star.get_closest_point(starts_and_goals[0].goal)
	return a_star.get_point_path(start_id, goal_id)
