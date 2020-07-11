extends Reference
"""
A* is a modification of Dijkstra’s Algorithm that is optimized for a single 
destination. Dijkstra’s Algorithm can find paths to all locations; A* finds 
paths to one location, or the closest of several locations. It prioritizes paths
that seem to be leading closer to a goal.
Check for more at:
www.redblobgames.com/pathfinding/a-star/introduction.html#astar
and even more on implementation of A* here:
www.redblobgames.com/pathfinding/a-star/implementation.html#algorithm
"""

class_name AStarRedBlob

static func find_path(graph, start : Vector2, goal : Vector2) -> Array:

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
			var elapsed = OS.get_ticks_usec() - time_start
			print("RedBlob AStar: ", elapsed)
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

static func reconstruct_path(goal : Vector2, came_from : Dictionary) -> Array:
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
