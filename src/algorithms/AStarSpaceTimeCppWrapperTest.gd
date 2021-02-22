class_name AStarSpaceTimeCppWrapperTest extends GridBasedAlgorithm

#var astar_cpp : = AStarCustom.new()
var astar_cpp : = AStarSpaceTimeCppTest.new()
var added : = {}
var connected : = {}
func initialize(grd):
	.initialize(grd)
	var start_time = OS.get_ticks_usec()
	var idx : = 0
	# already added vertexes to Godot's A* representation as points
	
	
	# reserve memory in A* with the size of the grid
	for current in grid.get_used_cells():
		# check if the current cell is not and obstacle
		if grid.is_cell_obstacle(current):
			continue
		# it will be added so chceck if is added
		#print("current: ", current)
		if not current in added:
			astar_cpp.add_point(idx, current)
			#print("adding point: {0}: {1} ".format([idx, current]))
			#add it to added and processed
			added[current] = idx
			idx += 1
			#add current cell to the A*
		connected[current] = true
		#get its neighbors
		for neighbor in grid.get_neighbors(current):
			
			if neighbor in connected:
				continue
			var neighbor_idx = -1
			if neighbor in added:
				neighbor_idx = added[neighbor]
			else:
				astar_cpp.add_point(idx, neighbor)
				added[neighbor] = idx
				neighbor_idx = idx
				idx += 1
			#print("adding neighbor: {0}: {1}".format([idx, neighbor]))
			# neighbor added but not yet processed
		
			# and connect it to the current cell
			astar_cpp.connect_points(added[current], neighbor_idx)
	

# virtual functions
func find_solution(starts_and_goals : Array):
	var start = starts_and_goals[0].start
	var goal = starts_and_goals[0].goal
	return astar_cpp.find_solution(added[start], added[goal], 1.0)

func clear():
	astar_cpp.clear_constraints()
