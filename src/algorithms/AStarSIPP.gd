class_name AStarSIPP extends GridBasedAlgorithm

const MIN_GAP : =  1.0
var vertex_intervals : = {Vector2(0, 0) : [Vector2(0, 2), Vector2(5, INF)],
						Vector2(0, -1) : [Vector2(0, 2), Vector2(5, INF)],
						Vector2(0, 1) : [Vector2(0, 2), Vector2(5, INF)]}
#var vertex_intervals : = {}
var agent_speed : = 1.0



func find_solution(starts_and_goals : Array):
# The key idea for all of these algorithms is that we keep track of an 
	# expanding cells called the frontier.
	# the interval length is based on speed and from entering
	# to exiting it will spend 2 times the value on the vertex
	var interval_length = 1 / agent_speed
	
	var start = starts_and_goals[0].start
	var goal = starts_and_goals[0].goal
	
	var frontier = MinPriorityQueueCpp.new()
	
	#frontier.insert_key({value = 0, vertex = start})
	# add end of the interval based on the agent speed
	frontier.push(0, start)
	
	# came_from for each location points to the place where we came from. These 
	# are like “breadcrumbs”. They’re enough to reconstruct the entire path.
	var came_from = {}
	
	# cost_so_far, to keep track of the total movement cost from the start 
	# location.
	var cost_so_far = {}
	
	# add start position to came_from and add 0 as total movemenbt cost
	#came_from[start] = Quat(INF, INF, 0, interval_length)
	came_from[start] = null
	
	#interval ranging from 0 to interval_length
	cost_so_far[start] = interval_length
	
	var used_interval : = {}
	used_interval[start] = Vector2(0, interval_length)
	
	
	while not frontier.empty():
		#Pick and remove a cell from the frontier.
		var current = frontier.top()
		frontier.pop()
		# if the goal is found reconstruct the path, i.e. early exit
		if current == goal:
			return reconstruct_path(goal, came_from, used_interval, 
					interval_length)
		
		#print("---===current: {0} ===---".format([current]))
		# expected interval of the neighbors vertexes, however this can
		# change due to avaibility of the open intervals
		grid.set_cellv(current, Grid.CLOSED)
		
		# current interval end
		#var ciend = cost_so_far[current]
		# neighbor interval start
		
		
		
		var nistart = cost_so_far[current] - interval_length
		# neighbor interval end
	
		var niend = nistart + interval_length * 2  
		
		#print("neighbor interval: ", Vector2(nistart, niend))
		
		#Expand it by looking at its neighbors
		for neighbor in grid.get_neighbors(current):
			
			#print("---neighbor: {0} ---".format([neighbor]))
			# get cost from the start of the current node and add the cost
			# of the movement between current node and neighbor
			#print("target interval: ", Vector2(nistart, niend))
			var open_interval
			
			if vertex_intervals.get(neighbor) == null:
				open_interval = Vector2(nistart, niend)
				#print("real interval: ", Vector2(nistart, niend))
			else: 
				open_interval = find_open_interval(vertex_intervals.get(neighbor), 
						Vector2(nistart, niend))
				#print("real interval: ", free_intreval)
			
			#print("open_interval: ", open_interval)
			var new_cost = open_interval.y
		
			#var waiting_interval = Vector2(ciend + MIN_GAP, 
			#		free_interval.z - interval_length / 2.0)
			
			
			
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
				var heuristic = grid.get_manhattan_distance_a_sipp(goal, 
						neighbor) + interval_length * 2 
				var priority = new_cost + heuristic
		
				# insert it to the frontier
				frontier.push(priority, neighbor)
				
				# add current as place where we came from to neighbor
				came_from[neighbor] = Vector2(current.x, current.y)
				used_interval[neighbor] = Vector2(open_interval.x, open_interval.y)
				grid.set_cellv(neighbor, Grid.OPEN)
	
	return Array()

func reconstruct_path(goal : Vector2, came_from : Dictionary, used_interval, 
		interval_length) -> Array:
	var path : = []
	var current = goal
	# if this cell is not start (only start has no previous cell)
	# and if there is no path to goal, than there is no previous cell for
	var previous = null
	while not current == null:
		#add tile to our path
		
		var interval_array = vertex_intervals.get(current)
		if interval_array == null:
				vertex_intervals[current] = [Vector2(0, INF)]
				interval_array = vertex_intervals[current]
		
		if previous == null:
			
			insert_closed_interval(interval_array, Vector2(
					used_interval[current].x, INF))
		else:
			print("previous: ", previous)
			print("interval_previous: ", used_interval[previous])
			insert_closed_interval(interval_array, Vector2(
					used_interval[current].x, 
					used_interval[previous].x + interval_length))
		
		path.push_back(current)
		#and set current the previous vertex
		previous = current
		
		current = came_from[current]
		
	#add the start to the path
	#path.push_back(current)
	#the path is oriented from the goal to the start so it needs to be reversed
	path.invert()
	print(vertex_intervals)
	return path


func insert_closed_interval(intervals : Array, interval : Vector2):
	print("insert_closed_interval: ", interval)
	var idx = intervals.bsearch_custom(interval, self, "search")
	var safe_interval = intervals[idx]
	if not safe_interval.x <= interval.x and interval.y <= safe_interval.y:
		push_warning("Is not inside the safe interval interval: {0}" + 
				" safe interval: {1} ".format([interval, safe_interval]))
		return
	if interval == safe_interval \
			or interval.x - MIN_GAP == safe_interval.x \
			and interval.y + MIN_GAP == safe_interval.y:
		intervals.remove(idx)
		return
	elif interval.x == safe_interval.x \
			or interval.x - MIN_GAP == safe_interval.x:
		intervals[idx].x = interval.y + MIN_GAP
	
	elif interval.y == safe_interval.y \
			or interval.y + MIN_GAP == safe_interval.y:
		intervals[idx].y = interval.x - MIN_GAP
	
	elif safe_interval.x < interval.x and interval.y < safe_interval.y:
		intervals[idx].x = interval.y + MIN_GAP
		intervals.insert(idx, Vector2(safe_interval.x, 
				interval.x - MIN_GAP))
	else:
		push_error("Safe {1} interval does not contain interval {2}".format(
				[safe_interval, interval]))

func find_open_interval(intervals : Array, interval : Vector2):
	print("intervals: ", intervals)
	print("interval: ", interval)
	
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
