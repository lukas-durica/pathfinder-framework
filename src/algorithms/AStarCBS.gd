extends Reference
#impelmentation similar to AstarRedBlob
var graph

class_name AStarCBS


#For cases where two low-level A* states have the same f -value, we used a 
#tie-breaking policy based on Standley’s #tie-breaking conflict avoidance table 
#(CAT) (described in Section 3.3.4). States that contain a conflict with a 
#smaller number of other agents are preferred. For example, if states s1 = (v1,
#t1) and s2 = (v2,t2) have the same f value, but v1 is used by two other agents 
#at time t1 while v2 is not used by any other agent at time t2, then s2 will be 
#expanded first. This tie-breaking #policy improves the total running time by a
#factor of 2 compared to arbitrary tie breaking. Duplicate states detection and
#pruning (DD) speeds up the low-level procedure. Unlike single-agent 
#pathfinding, the low-level state-space also includes the time dimension and 
#dynamic ‘obstacles’ caused by constraints. Therefore, two states are 
#considered duplicates if both the position of ai and the time step are 
#identical in both states


# additional_constraints are added during the CBS search in the form of
# Vector3(x_position, y_position, time_dimension)
func find_path(start: Vector2, goal : Vector2, 
		constraints : Dictionary) -> Array:
	# The key idea for all of these algorithms is that we keep track of an 
	# expanding cells called the frontier.
	var frontier = MinBinaryHeap.new()
	frontier.insert_key({value = 0, vertex = start})
	
	# came_from for each location points to the place where we came from. These 
	# are like “breadcrumbs”. They’re enough to reconstruct the entire path.
	var came_from = {}
	
	# cost_so_far, to keep track of the total movement cost from the start 
	# location.
	var cost_so_far = {}
	
	# add start position to came_from and add 0 as total movemenbt cost
	came_from[start] = null
	cost_so_far[start] = 0

	
	while not frontier.empty():
		#Pick and remove a cell from the frontier.
		var current = frontier.extractMin().vertex
		graph.set_cellv(current, Grid.CLOSED)
		# if the goal is found reconstruct the path, i.e. early exit
		if current == goal:
			return reconstruct_path(goal, came_from)
		#Expand it by looking at its neighbors
		for neighbor in graph.get_states(current):
			
			# get cost from the start of the current node and add the cost
			# of the movement between current node and neighbor (e.g. 
			# horizontal/vertical - 10, diagonal - 14)
			var new_cost = cost_so_far[current] \
				+ graph.get_cost(current, neighbor)
				
			# development notes: cost bude time, v pripade, ze stoji na mieste
			# je potrebne pridat cost o 1
			
			# Less obviously, we may end up visiting a location multiple times, 
			# with different costs, so we need to alter the logic a little bit. 
			# Instead of adding a location to the frontier if the location has 
			# never been reached, we’ll add it if the new path to the location 
			# is better than the best previous path.
			if not neighbor in cost_so_far or new_cost < cost_so_far[neighbor]:
				cost_so_far[neighbor] = new_cost
				
				# The location closest to the goal will be explored first.
				var priority = new_cost + graph.get_manhattan_distance(goal, 
						neighbor)
						
				# insert it to the frontier
				frontier.insert_key({value = priority, vertex = neighbor})
				
				# add current as place where we came from to neighbor
				came_from[neighbor] = current
				graph.set_cellv(neighbor, Grid.OPEN)
	
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
