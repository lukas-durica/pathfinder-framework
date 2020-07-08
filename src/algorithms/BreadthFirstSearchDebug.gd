extends Reference
"""
Breadth First Search explores equally in all directions. This is an incredibly 
useful algorithm, not only for regular path finding, but also for procedural map
generation, flow field pathfinding, distance maps, and other types of map 
analysis.
Check for more at:
https://www.redblobgames.com/pathfinding/a-star/introduction.html#breadth-first-search
"""
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

# a variable needed to step the algorithm
var start_step := Vector2.INF
# a variable needed to step the algorithm
var goal_step := Vector2.INF

var graph

class_name BreadthFirstSearch

var is_initialized : = false

# for debug purposes, will use colors
func find_path_debug(graph, start : Vector2, goal : Vector2, step : = false) \
		-> Array:
	open.push_back(start)
	goal_step = goal
	#add start to closed there is no previous vertex from it came from
	closed[start] = null
	
	while not open.empty():
		if step_debug(graph):
			return reconstruct_path_debug(graph, goal, closed)

	return Array()

#reconstructing path, from the goal to the start
static func reconstruct_path_debug(graph, goal : Vector2, 
			closed : Dictionary) -> Array:
	var path : = []
	var current = goal
	# if this cell is not start (only start has no previous cell)
	while not current == null:
		#set color to it
		graph.set_cellv(current, graph.PATH)
		
		#add tile to our path
		path.push_back(current)
		
		#and set current the previous vertex
		current = closed[current]
		
	#add the start to the path
	path.push_back(current)
	#the path is oriented from the goal to the start so it needs to be reversed
	path.invert()
	return path

#needed only for stepping
func init(graph, start : Vector2, goal : Vector2):
	open_debug.push_back(start)
	goal_debug = goal
	#add start to closed there is no previous vertex from it came from
	closed_debug[start] = null

func step_debug(graph):
	# get node from FIFO stack
	# the node will be now expanded by search for its neighbors
	var current = open_debug.front()
	
	#if goal was found, break the loop, i.e. early exit
	if current == goal_debug:
		return reconstruct_path_debug(grap)
	#set color as closed
	graph.set_cellv(current, graph.CLOSED)
	#remove actual vertex
	open_debug.pop_front()
		
	# iterate through valid neighbors
	for neighbor in graph.get_neighbors(current):
			
		# if the neighbor is not already in closed
		if not closed_debug.has(neighbor):
			#add it to FIFO stack
			open_debug.push_back(neighbor)
				
			#set color to it
			graph.set_cellv(neighbor, graph.OPEN)
				
			#assign current node as the previous node to neighbor
			closed_debug[neighbor] = current

