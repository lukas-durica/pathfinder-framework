class_name AStarCustomCPP extends GridBasedAlgorithm

#var astar_cpp : = AStarCustom.new()
var astar_cpp : = preload("res://bin/AStarCustom.gdns").new()
var dict_grid : = {}

func initialize(grd):
	.initialize(grd)
	
	for vertex in grid.get_used_cells_by_id(Grid.FREE):
		dict_grid[vertex] = true
	
# virtual functions
func find_solution(starts_and_goals : Array):
	var start = starts_and_goals[0].start
	var goal = starts_and_goals[0].goal
	return astar_cpp.find_solution(dict_grid, start, goal)

func clear():
	pass
