extends GridBasedAlgorithm


# Conflict-based search
class_name CBS

# start position and goals position in the form of starts_and_goals[start] = goal
var agents = []

var astar = AStarCBS.new()

var open = MinBinaryHeap.new()

class CBSNode:
	var constraint : CBSConstraint
	var solution : = [[]]
	var cost : = INF
	var parent = null

class CBSAgent:
	var id : = -1
	var start_position : = Vector2.INF
	var goal_position : = Vector2.INF
	
class CBSConstraint:
	var agent_id : = -1
	var vertex : = Vector3.INF
	var time : = -1

# edge conflict is tuple (ai, aj, v1, v2, t) 

#start_and_goal
func _initialize(graph):
	astar.graph = graph
	
	
func _find_solution(starts_and_goals : Array):
	for i in starts_and_goals.size():
		var start = starts_and_goals[i].start
		var goal = starts_and_goals[i].goal
		var agent = CBSAgent.new()
		agent.id = i
		agent.start_position = start
		agent.goal_position = goal
		agents.push_back(agent)
	
	
	var root = CBSNode.new()
	root.solution = get_root_solution()
	root.cost = get_sic(root.solution)
	open.insert_key({value = root.cost, node = root})
		
	while not open.empty():
		var current = open.extractMin().node
		var conflict = get_first_conflict(current.solution)
		if conflict.empty():
			return current.solution
		
		for i in range(2):
			
			var new_constraint = CBSConstraint.new()
			new_constraint.agent_id = conflict.ai if i == 0 else conflict.aj
			new_constraint.vertex = conflict.v
			
			#print(new_constraint.vertex)
			
			var new_node = CBSNode.new()
			new_node.parent = current
			new_node.constraint = new_constraint
			new_node.solution = current.solution.duplicate(true)
			
			update_solution(new_node)
			new_node.cost = get_sic(new_node.solution)
			if new_node.cost != INF:
				open.insert_key({value = new_node.cost, node = new_node})
	
	
	
#validate the paths until a first conflict occurs
func get_first_conflict(solution : Array) -> Dictionary:
	var vertex_conflicts = {}
	var agent_id = 0
	for path in solution:
		for vertex_in_time in path:
			if not vertex_in_time in vertex_conflicts:
				vertex_conflicts[vertex_in_time] = agent_id
			else:
				# vertex conflict is a tuple (ai, aj, v, t)
				# ai - first agent in conflict (who)
				# aj - second agent in conflict (whith whom)
				# v - conflicting vertex (where)
				# t - timestamp with the conflict (when)
				return {ai = agent_id, aj = vertex_conflicts[vertex_in_time], 
						v = vertex_in_time}
		agent_id += 1
	return {}
	


func get_root_solution() -> Array:
	var solution = []
	for agent in agents:
		
		var path = astar.find_solution([{start = agent.start_position, goal = agent.goal_position}])
		solution.append(path)
	return solution

func update_solution(node : CBSNode):
	var constraints : = {}
	var current_node = node
	while current_node.parent:
		if current_node.constraint.agent_id == node.constraint.agent_id:
			var constraint = current_node.constraint
			constraints[constraint.vertex] = constraint.agent_id
		current_node = current_node.parent
	var agent : CBSAgent = agents[node.constraint.agent_id]
	astar.constraints = constraints
	var path = astar.find_solution([{start = agent.start_position, 
			goal = agent.goal_position}])
	node.solution[node.constraint.agent_id] = path

# sum of individual costs (heuristic)
static func get_sic(solution : Array):
	var sic : = 0
	for path in solution:
		if path.empty():
			return INF
		sic += path.size()
	
	return sic

	
	
	
