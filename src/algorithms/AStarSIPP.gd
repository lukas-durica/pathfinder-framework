class_name AStarSIPP extends GridBasedAlgorithm

const MIN_GAP : =  1.0
var vertex_intervals : = {}
var agent_speed : = 1.0

func find_solution(starts_and_goals : Array):
# The key idea for all of these algorithms is that we keep track of an 
	# expanding cells called the frontier.
	
	var start = starts_and_goals[0].start
	var goal = starts_and_goals[0].goal
	
	var frontier = MinPriorityQueueCpp.new()
	
	#frontier.insert_key({value = 0, vertex = start})
	# add end of the interval based on the agent speed
	frontier.push(0 + 1 / agent_speed * 2, start)
	
	# came_from for each location points to the place where we came from. These 
	# are like “breadcrumbs”. They’re enough to reconstruct the entire path.
	var came_from = {}
	
	# cost_so_far, to keep track of the total movement cost from the start 
	# location.
	var cost_so_far = {}
	
	# add start position to came_from and add 0 as total movemenbt cost
	came_from[start] = null
	cost_so_far[start] = 1 / agent_speed * 2

	
	while not frontier.empty():
		#Pick and remove a cell from the frontier.
		var current = frontier.top()
		frontier.pop()
		# if the goal is found reconstruct the path, i.e. early exit
		if current == goal:
			return reconstruct_path(goal, came_from)
		#Expand it by looking at its neighbors
		var interval_start = cost_so_far[current] - 1 / agent_speed
		var interval_end = interval_start + 1 / agent_speed * 2
		for neighbor in grid.get_neighbors(current):
			
			# get cost from the start of the current node and add the cost
			# of the movement between current node and neighbor
			
			var free_interval = find_open_interval(vertex_intervals[neighbor], 
					Vector2(interval_start, interval_end))
			
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


func insert_closed_interval(intervals : Array, interval : Vector2):
	var idx = intervals.bsearch_custom(interval, self, "search")
	var safe_interval = intervals[idx]
	if not safe_interval.x <= interval.x and interval.y <= safe_interval.y:
		push_warning("Is not inside the safe interval interval: {0}" + 
				" safe interval: {1} ".format([interval, safe_interval]))
		return
	if interval == safe_interval or interval.x - MIN_GAP == safe_interval.x \
			and interval.y + MIN_GAP == safe_interval.y:
		intervals.remove(idx)
		return
	elif interval.x == safe_interval.x or interval.x - MIN_GAP == safe_interval.x:
		intervals[idx].x = interval.y + MIN_GAP
	
	elif interval.y == safe_interval.y or interval.y + MIN_GAP == safe_interval.y:
		intervals[idx].y = interval.x - MIN_GAP
	
	elif safe_interval.x < interval.x and interval.y < safe_interval.y:
		intervals[idx].x = interval.y + MIN_GAP
		intervals.insert(idx, Vector2(safe_interval.x, interval.x - MIN_GAP))
	else:
		push_error("Safe {1} interval does not contain interval {2}".format(
				[safe_interval, interval]))

func find_open_interval(intervals : Array, interval : Vector2):
	if not intervals:
		return interval
	var idx = intervals.bsearch_custom(interval, self, "search")
	
#	if  intervals[idx].x <= interval.x and interval.y <= intervals[idx].y:
#		return interval
#
	var length = interval.y - interval.x
	var prev_point = intervals[idx].x
	var next_point = intervals[idx].y

	while not (prev_point <= interval.x and interval.y <= next_point):

		interval.x = intervals[idx].x
		interval.y = interval.x + length
		prev_point = intervals[idx].x
		next_point = intervals[idx].y
		idx += 1
	return interval

func search(a: Vector2, b : Vector2):
	return a.y < b.y
