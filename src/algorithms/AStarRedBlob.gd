extends GridBasedAlgorithm
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

class_name AStarRedBlob

func _find_path(start: Vector2, goal : Vector2) -> Array:

	var frontier = MinBinaryHeap.new()
	frontier.insert_key({value = 0, vertex = start})
	var came_from = {}
	var cost_so_far = {}
	came_from[start] = null
	cost_so_far[start] = 0
	var time_start = OS.get_ticks_usec()

	
	while not frontier.empty():
		var current = frontier.extractMin().vertex
		if current == goal:
			return reconstruct_path(goal, came_from)
		for neighbor in graph.get_neighbors(current):
			var new_cost = cost_so_far[current] \
				+ graph.get_cost(current, neighbor)
			if not neighbor in cost_so_far or new_cost < cost_so_far[neighbor]:
				cost_so_far[neighbor] = new_cost
				var priority = new_cost + graph.get_manhattan_distance(goal, 
						neighbor)
				frontier.insert_key({value = priority, vertex = neighbor})
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
