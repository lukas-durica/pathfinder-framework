class_name AStarSpaceTimeTest extends GridBasedAlgorithm

#impelmentation similar to AstarRedBlob
#var graph
var grid_points : = {}

class GridPoint:
	func _init(v : Vector2):
		vertex = Vector3(v.x, v.y, 0.0)
		neighbors.push_back(self)
	
	#func _to_string():
		#return str(vertex)
	var neighbors : = []
	var vertex : = Vector3.INF


func initialize(grd):
	.initialize(grd)
	
	var already_added : = {}
	
	# vertexes that already have their IDs but was not added to already_added

	
	# reserve memory in A* with the size of the grid
	for current in grid.get_used_cells():
		# check if the current cell is not and obstacle
		if grid.is_cell_obstacle(current):
			continue
		# it will be added so chceck if is added
		
		 
		if not current in already_added:
			add_point(current)
			#add it to already_added and processed
			already_added[current] = true
			#add current cell to the A*
		elif current in already_added and not already_added[current]:
			already_added[current] = true
		
		#get its neighbors
		for neighbor in grid.get_neighbors(current):
			# if the neighbor is not obstacle and is not in already added 
			# and processed
			if grid.is_cell_obstacle(neighbor) or (neighbor in already_added \
					and already_added[neighbor]):
				continue
			
			if not neighbor in already_added:
				add_point(neighbor)
				
				#neighbor added but not yet processed
				already_added[neighbor] = false
			
			# and connect it to the current cell
			connect_points(current, neighbor)
	
func add_point(vertex : Vector2):
	if vertex in grid_points:
		push_warning("Vertex {0} already in grid!".format([vertex]))
		return
	grid_points[vertex] = GridPoint.new(vertex)
	
func connect_points(vertex_a : Vector2, vertex_b : Vector2):
	if not vertex_a in grid_points:
		push_warning("Vertex {0} is not in grid!".format([vertex_a]))
		return
	
	if not vertex_b in grid_points:
		push_warning("Vertex {0} is not in grid!".format([vertex_b]))
		return
	
	grid_points[vertex_a].neighbors.push_back(grid_points[vertex_b])
	grid_points[vertex_b].neighbors.push_back(grid_points[vertex_a])

func find_solution(starts_and_goals : Array):
	pass
	
	var start_v2 = starts_and_goals[0].start
	var goal_v2 = starts_and_goals[0].goal
	
	var start = Vector3(start_v2.x, start_v2.y, 0.0)
	var goal = Vector3(goal_v2.x, goal_v2.y, 0.0)
		
	# The key idea for all of these algorithms is that we keep track of an 
	# expanding cells called the frontier.
	
	var frontier = MinPriorityQueueCpp.new()
	# insert start and add it value 0
	# however its cost should be based on heuristics, but at the beginning of
	# the search there are no other vertexes/states only start
	#print("start v2 point:", grid_points[start_v2])
	frontier.push(0, {point = grid_points[start_v2], time_step = 0})
	
	# came_from for each location points to the place where we came from. These 
	# are like “breadcrumbs”. They’re enough to reconstruct the entire path.
	var came_from = {}
	
	# cost_so_far, to keep track of the total movement cost from the start 
	# location.
	var cost_so_far = {}
	
	# add start position to came_from and add 0 as total movemenbt cost
	came_from[start] = null
	cost_so_far[start] = 0
	
	# until the frontier is empty, hovewer in search with time parameter
	# there is less likely the frontier will be empty,
	while not frontier.empty():
		
		#Pick and remove a cell with minimal value from the frontier.
		var current_data = frontier.top()
		#print("current_data: ", current_data)
		var current = Vector3(current_data.point.vertex)
		current.z = current_data.time_step
	
		#graph.set_cellv(current, Grid.CLOSED)
		
		# if the goal is found reconstruct the path, i.e. early exit
		# in CBS search we know the length of the paths and they need to have
		# same size during searching for conflict, even if they (agents) are 
		# waiting at the goal position, thus in CBS set goal.z (time parameter)
		# to the size of the padded path, and new path must be at least long as
		# is the padded path
		
		if goal.x == current.x and goal.y == current.y:
			return reconstruct_path(current, came_from)
		
		frontier.pop()
		
		#Expand it by looking at its neighbors
		for neighbor_point in current_data.point.neighbors:
			var state = neighbor_point.vertex
			state.z = current.z + Grid.TIME_STEP
			
			# get cost from the start of the current node and add the cost
			# of the movement between current node and neighbor (i.e.
			# regular movement, diagonal movement)
			var new_cost = cost_so_far[current]
			
			
			# if the current state position is at the goal and is waiting the
			# cost is zero else compute the cost
			# 0 is waiting at goal
			# 4 is waiting at non-goal
			# 5 is moving
			
			
			
			new_cost += 0.0 if goal.x == state.x and goal.y == state.y \
					else 49.0 if current.x == state.x and current.y == state.y \
					else 50.0
					
					
			
			# Less obviously, we may end up visiting a location multiple times, 
			# with different costs, so we need to alter the logic a little bit. 
			# Instead of adding a location to the frontier if the location has 
			# never been reached, we’ll add it if the new path to the location 
			# is better than the best previous path.
			
			if not state in cost_so_far or new_cost < cost_so_far[state]:
			#var is_in_cost_so_far = state in cost_so_far	
				
				
				#graph.set_cellv(neighbor, Grid.OPEN)
				cost_so_far[state] = new_cost
				
				# The location closest to the goal will be explored first.
				var heuristic = (abs(goal.x - state.x) + 
						abs(goal.y - state.y)) * 50.0
				
				# by adding new_cost and heuristic we will end up with the 
				# priority, i.e. f = g + h
				var priority = new_cost + heuristic
				
				# insert it to the frontier
				frontier.push(priority, {point = neighbor_point, 
						time_step = state.z})
				neighbor_point.unreference()
				# add current as place where we came from to neighbor
				came_from[state] = current
	
	# if there are no nodes in frontier
	return {path = [], cost = INF}

static func reconstruct_path(goal : Vector3, came_from : Dictionary) -> Array:
	var path : = []
	var current = goal
	# if this cell is not start (only start has no previous cell)
	# and if there is no path to goal, than there is no previous cell for
	# goal
	while not current == null:
		#add tile to our path
		#print(current)
		path.push_back(current)
	
		#and set current the previous vertex
		current = came_from[current]
	
	#add the start to the path
	#path.push_back(current)
	#the path is oriented from the goal to the start so it needs to be reversed
	path.invert()
	return path

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for vertex in grid_points:
			grid_points[vertex].neighbors.clear()
		#grid_points.clear()
# function for comparing position, i.e. withoat time dimension
static func is_equal(goal, state) -> bool:
	return Vector2(goal.x, goal.y) == Vector2(state.x, state.y)
