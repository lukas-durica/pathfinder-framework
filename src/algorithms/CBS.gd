extends Reference


# Conflict-based search
class_name CBS

# start position and goals position in the form of starts_and_goals[start] = goal
var agents = []

var astar = AStarCBS.new()

var graph : Grid

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
	var vertex : = Vector2.INF
	var time : = -1

# edge conflict is tuple (ai, aj, v1, v2, t) 

#start_and_goal
func initialize(graph, starts_and_goals : Dictionary):
	self.graph = graph
	astar.graph = graph
	self.starts_and_goals = starts_and_goals
	
	var id : = 0
	for start in starts_and_goals:
		var goal = starts_and_goals[start]
		var agent = CBSAgent.new()
		agent.id = 0
		agent.start_position = start
		agent.goal_position = goal
		agents.push_back(agent)
		id += 1
	
	
func find_goal_solution():
	
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
			var new_node = CBSNode.new()
			new_node.parent = current
			
			var new_constraint = CBSConstraint.new()
			new_constraint.agent_id = conflict.ai if i == 0 else conflict.aj
			new_constraint.vertex = conflict.v
			new_constraint.time = conflict.t
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
		var time = 0
		for vertex in path:
			var vertex_in_time = Vector3(vertex.x, vertex.y, time)
			if not vertex_in_time in vertex_conflicts:
				vertex_conflicts[vertex_in_time] = agent_id
			else:
				# vertex conflict is a tuple (ai, aj, v, t)
				# ai - first agent in conflict (who)
				# aj - second agent in conflict (whith whom)
				# v - conflicting vertex (where)
				# t - timestamp with the conflict (when)
				return {ai = agent_id, aj = vertex_conflicts[vertex_in_time], 
						v = vertex, t = time}
			time += 1
		agent_id += 1
	return {}
	

func get_root_solution() -> Array:
	var solution = []
	
	for agent in agents:
		var path = astar.find_path(agent.start_position, agent.goal_position)
		solution.append(path)
	return solution

func update_solution(node : CBSNode):
	var constraints : = {}
	var current_node = node
	while current_node.parent:
		if current_node.constraint.agent_id == node.constraint.agent_id:
			var constraint = current_node.constraint
			constraints[Vector3(constraint.vertex.x, constraint.vertex.y, 
					constraint.time)] = constraint.agent_id
		
	var agent : CBSAgent = agents[node.agent_id]
	var path = astar.find_path(agent.start_position, agent.goal_position, 
			constraints)
	node.solution[node.agent_id] = path

# sum of individual costs (heuristic)
static func get_sic(solution : Array):
	var sic : = 0
	for path in solution:
		if path.empty():
			return INF
		sic += path.size()
	
	return sic

	
	
	
