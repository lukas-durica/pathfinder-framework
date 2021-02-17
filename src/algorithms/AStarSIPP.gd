class_name AStarSIPP extends GridBasedAlgorithm

var vertex_intervals : = {}

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

func get_first_free_interval(intervals : Array, interval : Vector2):
	var idx = intervals.bsearch_custom(interval, self, "binary_search", false)
	var size = interval.y - interval.x
	var prev_value = intervals[idx - 1].y if idx > 0 else -1
	var next_value = intervals[idx].x if idx < intervals.size() else INF
	if prev_value < interval.x and interval.y < next_value:
			return interval
	while idx <= intervals.size():
		if next_value - prev_value > size:
			return Vector2(prev_value + 1, prev_value + 1 + size)
		idx+=1
		prev_value = intervals[idx - 1].y if idx > 0 else -1
		next_value = intervals[idx].x if idx < intervals.size() else INF
	
func binary_search(a : Vector2, b : Vector2):
	return a.y < b.x

func test_intervals():
	var test_dict = {Vector2(0, 1) : Vector2(0, 1), 
					Vector2(1, 2) : Vector2(6, 7),
					Vector2(2, 3) : Vector2(6, 7), 
					Vector2(3, 4) : Vector2(6, 7),
					Vector2(4, 5) : Vector2(6, 7),
					Vector2(5, 6) : Vector2(6, 7),
					Vector2(6, 7) : Vector2(6, 7),
					Vector2(7, 8) : Vector2(13, 14),
					Vector2(9, 10) : Vector2(13, 14),
					Vector2(12, 16) : Vector2(19, 23),
					Vector2(16, 17) : Vector2(19, 20),
					Vector2(17, 18) : Vector2(19, 20),
					Vector2(18, 19) : Vector2(19, 20),
					Vector2(21, 22) : Vector2(21, 22)} 

	var intervals = [Vector2(2, 3), Vector2(4, 5), Vector2(8, 9), 
			Vector2(9, 10), Vector2(11, 12), Vector2(16, 18)]
	
	for test_value in test_dict:
		var test = get_first_free_interval(test_value, intervals)
		if test == test_dict[test_value]:
			print("OK Interval: {0}: {1} ".format([test_value, 
					test_dict[test_value]]))
		else:
			print("Error Interval: {0}: {1} is {2} ".format([test_value, 
					test_dict[test_value], test]))
