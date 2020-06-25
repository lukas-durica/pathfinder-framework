extends Reference
"""
Breadth First Search explores equally in all directions. This is an incredibly 
useful algorithm, not only for regular path finding, but also for procedural map
generation, flow field pathfinding, distance maps, and other types of map 
analysis.
Check for more at:
https://www.redblobgames.com/pathfinding/a-star/introduction.html#breadth-first-search
"""

class_name BreadthFirstSearch

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


func find_path(graph, start, goal):
	#add start to the open list, as this will be first vertex to expand by 
	#looking at its neighbors
	open.push_back(start)
	
	#add start to closed there is no previous vertex from it came from
	closed[start] = null
	
	while not open.empty():
		# get node from FIFO stack
		# the node is now closed
		var current = open.front()
		
		#set color as closed
		graph.set_cellv(current, graph.CLOSED)
		#remove actual vertex
		open.pop_front()
		
		# iterate through valid neighbors
		for neighbor in graph.get_neighbors(current):
			
			# if the neighbor is not already in closed
			if not closed.has(neighbor):
				#add it to FIFO stack
				open.push_back(neighbor)
				
				#set color to it
				graph.set_cellv(neighbor, graph.OPEN)
				
				#assign current node as the previous node to neighbor
				closed[neighbor] = current
		
	recostruct_path(goal, graph)
		#reconstructing path, we start with the goal
		#recostruct_path(goal, path)

func recostruct_path(goal, graph):
	var path : = []
	# if this cell is not start (only start has no previous cell)
	var current = goal
	while not current == null:
		graph.set_cellv(current, graph.PATH)
		path.push_back(current)
		current = closed[current]
		
	#add the start to the path
	path.push_back(current)
	#the path is oriented from the goal to the start so need to be reversed
	return path.invert()
	
	
	

