extends Reference
"""
Comments of the algorithm is in BreadthFirstSearch.gd
This class is used for debug (learning) purposes. It colors the cells. It is 
slower than BreadthFirstSearch.
Two modes (alaways use init() method before the use):
	(1) For finding path instantly (find_solution())
	(2) For stepping the algorithm (step())
"""
class_name BreadthFirstSearchDebug

var open : = []

var closed : = {}

var start := Vector2.INF

var goal := Vector2.INF

var graph = null

var is_initialized : = false

func init(graph, start : Vector2, goal : Vector2):
	self.graph = graph
	self.start = start
	self.goal = goal
	
	open.push_back(start)
	closed[start] = null
	is_initialized = true

func find_solution() -> Array:
	if not is_initialized:
		show_error()
		return Array()
	
	while not open.empty():
		if step():
			return reconstruct_path()

	return Array()

func reconstruct_path() -> Array:
	var path : = []
	var current = goal
	
	while not current == null:
		#set color to the cell as path
		graph.set_cellv(current, graph.PATH)
		path.push_back(current)
		current = closed[current]
		
	path.push_back(current)
	path.invert()
	return path

#stepping the algorithm
func step() -> bool:
	if not is_initialized:
		show_error()
		return false
	
	var current = open.front()
	if current == goal:
		return true

	open.pop_front()
	#set color as closed
	graph.set_cellv(current, graph.CLOSED)
	for neighbor in graph.get_neighbors(current):
		if not neighbor in closed:
			open.push_back(neighbor)
			#set color to it
			graph.set_cellv(neighbor, graph.OPEN)
			closed[neighbor] = current
	return false

#reset the algorithm
func reset():
	open.clear()
	closed.clear()
	start = Vector2.INF
	goal = Vector2.INF
	graph = null
	is_initialized = false

func show_error():
	push_error("Breadth First Search was not initialized. " + \
			"Initialization is needed in order to step the algorithm.")
