class_name AStarSIPP extends GridBasedAlgorithm

var intervals : = {}

func find_solution(starts_and_goals : Array):
# The key idea for all of these algorithms is that we keep track of an 
	# expanding cells called the frontier.
	
	var start = starts_and_goals[0].start
	var goal = starts_and_goals[0].goal
	
	var frontier = MinPriorityQueueCpp.new()
	
	#frontier.insert_key({value = 0, vertex = start})
	frontier.push(0, start)
	
	# came_from for each location points to the place where we came from. These 
	# are like “breadcrumbs”. They’re enough to reconstruct the entire path.
	var came_from = {}
	
	# cost_so_far, to keep track of the total movement cost from the start 
	# location.
	var cost_so_far = {}
	
	# add start position to came_from and add 0 as total movemenbt cost
	came_from[start] = null
	cost_so_far[start] = 0

	
	while not frontier.empty():
		#Pick and remove a cell from the frontier.
		var current = frontier.top()
		frontier.pop()
		# if the goal is found reconstruct the path, i.e. early exit
		if current == goal:
			return reconstruct_path(goal, came_from)
		#Expand it by looking at its neighbors
		for neighbor in grid.get_neighbors(current):
			
			# get cost from the start of the current node and add the cost
			# of the movement between current node and neighbor
			
			var new_cost = cost_so_far[current] \
				+ grid.get_cost(current, neighbor)
			
			#var new_cost = cost_so_far[current] \
			#	+ grid.get_cost(current, neighbor)
			
			# Less obviously, we may end up visiting a location multiple times, 
			# with different costs, so we need to alter the logic a little bit. 
			# Instead of adding a location to the frontier if the location has 
			# never been reached, we’ll add it if the new path to the location 
			# is better than the best previous path.
			if not neighbor in cost_so_far or new_cost < cost_so_far[neighbor]:
				cost_so_far[neighbor] = new_cost
				
				# The location closest to the goal will be explored first.
				var heuristic = grid.get_manhattan_distance(goal, 
						neighbor)
				var priority = new_cost + heuristic
						
				# insert it to the frontier
				frontier.push(priority, neighbor)
				
				# add current as place where we came from to neighbor
				came_from[neighbor] = current
	
	return Array()

func reconstruct_path(goal : Vector2, came_from : Dictionary) -> Array:
	var path : = []
	var current = goal
	# if this cell is not start (only start has no previous cell)
	# and if there is no path to goal, than there is no previous cell for
	# goal
	while not current == null:
		#add tile to our path
		path.push_back(current)
	
		#and set current the previous vertex
		current = came_from[current]
	
	#add the start to the path
	#path.push_back(current)
	#the path is oriented from the goal to the start so it needs to be reversed
	path.invert()
	return path

func get_firs_free_interval(vertex : Vector2, interval_start : int, size : int):
	if not vertex in intervals:
		return Vector2(interval_start, interval_start + size)
	
	var vertex_intervals = intervals[vertex]
	if vertex_intervals.empty():
		push_error("vertex intervals are empty!")
		return
	var idx = vertex_intervals.bsearch(Vector2(interval_start, 
			interval_start + size))
	if idx == vertex_intervals.size():
		return Vector2(vertex_intervals[idx].y + 1, vertex_intervals[idx].y + 1)
	else:
		pass
	

