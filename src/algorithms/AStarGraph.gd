class_name AStarGraph extends Reference
"""
Check for more at:
www.redblobgames.com/pathfinding/a-star/introduction.html#astar
and even more on implementation of A* here:
www.redblobgames.com/pathfinding/a-star/implementation.html#algorithm
	

	RedBlob Implementation notes:
	I eliminate the check for a node being in the frontier with a higher cost. 
	By not checking, I end up with duplicate elements in the frontier. The 
	algorithm still works. It will revisit some locations more than necessary 
	(but rarely, in my experience, as long as the heuristic is admissible). The 
	code is simpler and it allows me to use a simpler and faster priority queue 
	that does not support the decrease-key operation. The paper “Priority Queues
	and Dijkstra’s Algorithm” suggests that this approach is faster in practice.
	
	Instead of storing both a “closed set” and an “open set”, I have a visited 
	flag that tells me whether it’s in either of those sets. This simplifies the
	code further.
	
	I don’t need to store a separate open or closed set explicitly because the 
	set is implicit in the keys of the came_from and cost_so_far tables. Since 
	we always want one of those two tables, there’s no need to store the 
	open/closed sets separately.
	
	I use hash tables instead of arrays of node objects. This eliminates the 
	rather expensive initialize step that many other implementations have. For 
	large game maps, the initialization of those arrays is often slower than 
	the rest of A*.
"""

var graph 

func _init(grph : Node2D):
	graph = grph

func find_solution(start_path : ConnectablePath, offset : float, 
		goal_area : Node2D) -> Array:
	
	# The key idea for all of these algorithms is that we keep track of an 
	# expanding cells called the frontier.
	var frontier = MinPriorityQueueCpp.new()
	#var frontier = MinBinaryHeap.new()
	
	#var start = starts_and_goals[0].start
	#var goal = starts_and_goals[0].goal
	
	# came_from for each location points to the place where we came from. These 
	# are like “breadcrumbs”. They’re enough to reconstruct the entire path.
	var came_from = {}
	
	# cost_so_far, to keep track of the total movement cost from the start 
	# location.
	var cost_so_far = {}
	
	var start_path_data_0 = graph.paths_data[start_path][0]
	var start_path_data_1 = graph.paths_data[start_path][1]
	
	# add start position to came_from and add 0 as total movemenbt cost
	
	var length = start_path.get_length()
	
	#var frontier = MinBinaryHeap.new()
	#frontier.insert_key({value = 0, vertex = start})
	frontier.push(offset, start_path_data_0.id)
	
	
	frontier.push(length - offset, start_path_data_1.id)
	
	
	came_from[start_path_data_0] = null
	came_from[start_path_data_1] = null
	
	cost_so_far[start_path_data_0] = offset
	cost_so_far[start_path_data_1] = length - offset

	while not frontier.empty():
		#Pick and remove a cell from the frontier.
		var current = graph.paths_data_by_id[frontier.top()]
		frontier.pop()
		print("current: ", current)
		#grid.set_cellv(current, Grid.CLOSED)
		# if the goal is found reconstruct the path, i.e. early exit
		if current.area == goal_area:
			return reconstruct_path(current, came_from)
		#Expand it by looking at its neighbors
		for neighbor in current.neighbors:
			# get cost from the start of the current node and add the cost
			# of the movement between current node and neighbor (e.g. 
			# horizontal/vertical - 10, diagonal - 14)
			var new_cost = cost_so_far[current] + neighbor.path.get_length()
				
			
			# Less obviously, we may end up visiting a location multiple times, 
			# with different costs, so we need to alter the logic a little bit. 
			# Instead of adding a location to the frontier if the location has 
			# never been reached, we’ll add it if the new path to the location 
			# is better than the best previous path.
			if not neighbor in cost_so_far or new_cost < cost_so_far[neighbor]:
				cost_so_far[neighbor] = new_cost
				
				# The location closest to the goal will be explored first.
				var heuristic = neighbor.area.global_position.distance_to(
						goal_area.global_position)
				
				var priority = new_cost + heuristic
						
				# insert it to the frontier
				frontier.push(priority, neighbor.id)
				
				# add current as place where we came from to neighbor
				came_from[neighbor] = current
				#grid.set_cellv(neighbor, Grid.OPEN)
	return Array()

func reconstruct_path(goal_data, came_from : Dictionary) -> Array:
	var path : = []
	var current = goal_data
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
