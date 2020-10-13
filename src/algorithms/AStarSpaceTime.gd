extends Reference

#impelmentation similar to AstarRedBlob
#var graph

class_name AStarSpaceTime

static func find_solution(grid : Grid, start : Vector3, goal : Vector3):
	
	# The key idea for all of these algorithms is that we keep track of an 
	# expanding cells called the frontier.
	var frontier = MinBinaryHeap.new()
	
	# insert start and add it value 0
	# however its cost should be based on heuristics, but at the beginning of
	# the search there are no other vertexes/states only start
	frontier.insert_key({value = 0, vertex = start})
	
	# came_from for each location points to the place where we came from. These 
	# are like “breadcrumbs”. They’re enough to reconstruct the entire path.
	var came_from = {}
	
	# cost_so_far, to keep track of the total movement cost from the start 
	# location.
	var cost_so_far = {}
	
	# add start position to came_from and add 0 as total movemenbt cost
	came_from[start] = null
	cost_so_far[start] = 0
	
	# until the frontier is empty, hovewer in search with time parameter
	# there is less likely the frontier will be empty,
	while not frontier.empty():
		
		#Pick and remove a cell with minimal value from the frontier.
		var min_value = frontier.extractMin()
		
		var current = min_value.vertex
		#graph.set_cellv(current, Grid.CLOSED)
		
		# if the goal is found reconstruct the path, i.e. early exit
		# in CBS search we know the length of the paths and they need to have
		# same size during searching for conflict, even if they (agents) are 
		# waiting at the goal position, thus in CBS set goal.z (time parameter)
		# to the size of the padded path, and new path must be at least long as
		# is the padded path
		
		if is_equal(goal, current):
			return reconstruct_path(current, came_from) 
					
		
		#Expand it by looking at its neighbors
		for state in grid.get_states(current):
			
			# get cost from the start of the current node and add the cost
			# of the movement between current node and neighbor (i.e.
			# regular movement, diagonal movement)
			var new_cost = cost_so_far[current] 
			
			
			# if the current state position is at the goal and is waiting the
			# cost is zero else compute the cost
			new_cost += 0 if is_equal(goal, current) else grid.get_cost(
					Vector2(current.x, current.y), 
					Vector2(state.x, state.y))
			
			# Less obviously, we may end up visiting a location multiple times, 
			# with different costs, so we need to alter the logic a little bit. 
			# Instead of adding a location to the frontier if the location has 
			# never been reached, we’ll add it if the new path to the location 
			# is better than the best previous path.
			
			if not state in cost_so_far or new_cost < cost_so_far[state]:
			#var is_in_cost_so_far = state in cost_so_far	
				
				
				#graph.set_cellv(neighbor, Grid.OPEN)
				cost_so_far[state] = new_cost
				
				# The location closest to the goal will be explored first.
				var heuristic = grid.get_heuristic_distance(
						Vector2(goal.x, goal.y), Vector2(state.x, state.y))
				
				# by adding new_cost and heuristic we will end up with the 
				# priority, i.e. f = g + h
				var priority = new_cost + heuristic
				
				# insert it to the frontier
				frontier.insert_key({value = priority, vertex = state})
				
				# add current as place where we came from to neighbor
				came_from[state] = current
	
	# if there are no nodes in frontier
	return {path = [], cost = INF}

static func reconstruct_path(goal : Vector3, came_from : Dictionary) -> Array:
	var path : = []
	var current = goal
	# if this cell is not start (only start has no previous cell)
	# and if there is no path to goal, than there is no previous cell for
	# goal
	while not current == null:
		#add tile to our path
		#print(current)
		path.push_back(current)
	
		#and set current the previous vertex
		current = came_from[current]
	
	#add the start to the path
	#path.push_back(current)
	#the path is oriented from the goal to the start so it needs to be reversed
	path.invert()
	return path


# function for comparing position, i.e. withoat time dimension
static func is_equal(goal, state) -> bool:
	return Vector2(goal.x, goal.y) == Vector2(state.x, state.y)
