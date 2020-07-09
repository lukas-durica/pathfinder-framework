extends Reference
"""
Breadth First Search explores equally in all directions. This is an incredibly 
useful algorithm, not only for regular path finding, but also for procedural map
generation, flow field pathfinding, distance maps, and other types of map 
analysis.
Check for more at:
www.redblobgames.com/pathfinding/a-star/introduction.html#breadth-first-search
"""

class_name BreadthFirstSearch

static func find_path(graph, start : Vector2, goal : Vector2) -> Array:
	#add start to the open list, as this will be first vertex to expand by 
	#looking at its neighbors
	# open is a data structure for neighbors that have not yet been visited
	# Array will be used in FIFO manner, First In (Array.push_back()) First Out 
	# (Array.front())
	var open : = []

	# use dictionary for closed list, as it is impelemented as hash table
	# closed is the list of the visited/expanded vertex (node), every vertex 
	# will be expanded only once
	# as a key use actual vertex and as a value use the priour/previous vertex to 
	# the actual vertex
	var closed : = {}
	#add start to the open list, as this will be first vertex to expand by 
	#looking at its neighbors
	open.push_back(start)
	
	#add start to closed there is no previous vertex from it came from
	closed[start] = null
	
	#until the there are not visited/expadned nodes
	while not open.empty():
		# get node from FIFO stack
		# the node can be considered now as closed
		var current = open.front()
		
		#if the goal was found, reconstruct the path, i.e. early exit
		if current == goal:
			return reconstruct_path(goal, closed)
		
		#remove actual vertex
		open.pop_front()
		
		# iterate through valid neighbors
		for neighbor in graph.get_neighbors(current):
			
			# if the neighbor is not already in closed
			if not neighbor in closed:
				#add it to FIFO stack
				open.push_back(neighbor)
				
				#assign current node as the previous node to neighbor
				closed[neighbor] = current
		
	# reconstruct the found path from the goal to start
	return Array()
		
		
#reconstructing path, from the goal to the start
static func reconstruct_path(goal : Vector2, closed : Dictionary) -> Array:
	var path : = []
	var current = goal
	# if this cell is not start (only start has no previous cell)
	# and if there is no path to goal, than there is no previous cell for
	# goal
	while not current == null:
		#add tile to our path
		path.push_back(current)
		
		#and set current the previous vertex
		current = closed[current]
		
	#the path is oriented from the goal to the start so it needs to be reversed
	path.invert()
	return path
	

