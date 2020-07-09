extends Reference
"""
Comments of the algorithm is in BreadthFirstSearch.gd
This class is used for debug (learning) purposes. It colors the cells. It is 
slower than BreadthFirstSearch.
Two modes (alaways use init() method before the use):
	(1) For finding path instantly (find_path())
	(2) For stepping the algorithm (step())
"""
class_name BreadthFirstSearchDebug

var open_debug : = []

var closed_debug : = {}

var start_debug := Vector2.INF

var goal_debug := Vector2.INF

var graph_debug = null

var is_initialized : = false

func init(graph, start : Vector2, goal : Vector2):
	graph_debug = graph
	start_debug = start
	goal_debug = goal
	
	open_debug.push_back(start)
	closed_debug[start] = null
	is_initialized = true

func find_path() \
		-> Array:
	if not is_initialized:
		show_error()
		return Array()
	
	while not open_debug.empty():
		if step():
			return reconstruct_path()

	return Array()

func reconstruct_path() -> Array:
	var path : = []
	var current = goal_debug
	
	while not current == null:
		#set color to the cell as path
		graph_debug.set_cellv(current, graph_debug.PATH)
		path.push_back(current)
		current = closed_debug[current]
		
	path.push_back(current)
	path.invert()
	return path

#stepping the algorithm
func step() -> bool:
	if not is_initialized:
		show_error()
		return false
	
	var current = open_debug.front()
	if current == goal_debug:
		return true
	
	#set color as closed
	graph_debug.set_cellv(current, graph_debug.CLOSED)
	open_debug.pop_front()
	for neighbor in graph_debug.get_neighbors(current):
		if not neighbor in closed_debug:
			open_debug.push_back(neighbor)
			#set color to it
			graph_debug.set_cellv(neighbor, graph_debug.OPEN)
			closed_debug[neighbor] = current
	return false

#reset the algorithm
func reset():
	open_debug.clear()
	closed_debug.clear()
	start_debug = Vector2.INF
	goal_debug = Vector2.INF
	graph_debug = null
	is_initialized = false

func show_error():
	push_error("Breadth First Search was not initialized. " + \
			"Initialization is needed in order to step the algorithm.")
