extends Reference
"""
Breadth First Search explores equally in all directions. This is an incredibly 
useful algorithm, not only for regular path finding, but also for procedural map
generation, flow field pathfinding, distance maps, and other types of map 
analysis.
Check for more at:
https://www.redblobgames.com/pathfinding/a-star/introduction.html#breadth-first-search
"""
static func find_path(graph, start : Vector2, goal : Vector2) -> Array:
	#add start to the open list, as this will be first vertex to expand by 
	#looking at its neighbors
	# open is a data structure for neighbors that have not yet been visited
	# Array will be used in FIFO manner, First In (Array.push_back()) First Out 
	# (Array.front())
	var open : = []

	# use dictionary for closed list, as it is impelemented as hash table
	# closed is the list of the visited/expanded vertex (node), every vertex will be 
	# expanded only once
	# as a key use actual vertex and as a value use the priour/previous vertex to 
	# the actual vertex
	var closed : = {}
	#add start to the open list, as this will be first vertex to expand by 
	#looking at its neighbors
	open.push_back(start)
	
	#add start to closed there is no previous vertex from it came from
	closed[start] = null
	
	while not open.empty():
		# get node from FIFO stack
		# the node can be considered now as closed
		var current = open.front()

		#remove actual vertex
		open.pop_front()
		
		# iterate through valid neighbors
		for neighbor in graph.get_neighbors(current):
			
			# if the neighbor is not already in closed
			if not closed.has(neighbor):
				#add it to FIFO stack
				open.push_back(neighbor)
				
				#assign current node as the previous node to neighbor
				closed[neighbor] = current
		
	return reconstruct_path(goal, closed)
		
		#recostruct_path(goal, path)
#reconstructing path, from the goal to the start
static func reconstruct_path(goal : Vector2, closed : Dictionary) -> Array:
	var path : = []
	var current = goal
	# if this cell is not start (only start has no previous cell)
	while not current == null:		
		#add tile to our path
		path.push_back(current)
		
		#and set current the previous vertex
		current = closed[current]
		
	#add the start to the path
	path.push_back(current)
	#the path is oriented from the goal to the start so it needs to be reversed
	path.invert()
	return path
	

