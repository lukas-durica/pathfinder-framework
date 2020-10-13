extends GridBasedAlgorithm

class_name ICTS

var astar = AStarCBS.new()

class ICTSNode:
	var total_cost : = 0
	var costs : = []
	

var starts_goals : = []

func _initialize(grid):
	pass

func _find_solution(starts_and_goals : Array):
	starts_goals = starts_and_goals
	var root = get_root()


func get_root() -> ICTSNode:
	var root = ICTSNode.new()
	var total_cost = 0
	for sag in starts_goals:
		var partial_solution = astar.find_solution([{start = sag.start_state, 
				goal = sag.goal_state}])
		root.costs.push_back(partial_solution.cost)
		total_cost += partial_solution.cost
	root.total_cost = total_cost
	return root


func generate_successors(node : ICTSNode) -> Array:
	var new_total_cost = node.total_cost +1
	var n_agents = starts_goals.size()
	# duplicate children which can be pruned.
	# fig. 4
	return []
	
	

func _clear():
	pass

