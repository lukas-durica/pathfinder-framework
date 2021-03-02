class_name AStarSpaceTimeCppWrapperTest2 extends GridBasedAlgorithm

#var astar_cpp : = AStarCustom.new()
var astar_cpp : = AStarSpaceTimeCppTest2.new()
var added : = {}
var connected : = {}
func initialize(grd):
	.initialize(grd)
	var start_time = OS.get_ticks_usec()
	var added : = {}
	var connected : = {}
	var already_added : = {}
	
	# vertexes that already have their IDs but was not added to already_added

	
	# reserve memory in A* with the size of the grid
	for current in grid.get_used_cells():
		# check if the current cell is not and obstacle
		if grid.is_cell_obstacle(current):
			continue
		# it will be added so chceck if is added
		
		 
		if not current in already_added:
			astar_cpp.add_point(current)
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
				astar_cpp.add_point(neighbor)
				
				#neighbor added but not yet processed
				already_added[neighbor] = false
			
			# and connect it to the current cell
			astar_cpp.connect_points(current, neighbor)
	

# virtual functions
func find_solution(starts_and_goals : Array):
	var initial_positions = []
	for sag in starts_and_goals:
		initial_positions.push_back(sag.start)
	astar_cpp.add_initial_agent_positions(initial_positions)
	
	var paths : = []
	for sag in starts_and_goals:
		var start = sag.start
		var goal = sag.goal
		paths.push_back(astar_cpp.find_solution(Vector3(start.x, start.y, 27.0), 
				Vector3(goal.x, goal.y, 0.0)))
	return paths
func clear():
	astar_cpp.clear_constraints()

func update_actual_time_step():
	print("udpate actual time step")
	astar_cpp.update_actual_time_step()
	
