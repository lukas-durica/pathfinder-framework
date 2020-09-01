extends GridBasedAlgorithm


# Conflict-based search
class_name CBS

enum ConflictType {NONE, VERTEX, EDGE}

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
	open.clear()
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
		if conflict.type == ConflictType.NONE:
			return current.solution
		
		for i in range(2):
			
			var new_constraint = CBSConstraint.new()
			new_constraint.agent_id = conflict.ai if i == 0 else conflict.aj
			
			# if the conflict is vertex conflict
			if conflict.type == ConflictType.VERTEX:
				new_constraint.vertex = conflict.v
			
			# if the conflict is edge conflict
			elif conflict.type == ConflictType.EDGE:
				
				new_constraint.vertex = conflict.v1 if i == 0 else conflict.v2
			
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
	var edge_conflicts = {}
	var agent_id : = 0
	for path in solution:
		#print("agent_id: ", agent_id, "path.size: ", path.size())
		var time_step : = 0
		for vertex_in_time in path:
			if not vertex_in_time in vertex_conflicts:
				vertex_conflicts[vertex_in_time] = agent_id
			else:
				# vertex conflict is a tuple (ai, aj, v, t)
				# ai - first agent in conflict (who)
				# aj - second agent in conflict (whith whom)
				# v - conflicting vertex (where)
				# t - type of confliv
				#print("vertex conflict")
				return {ai = agent_id, aj = vertex_conflicts[vertex_in_time], 
						v = vertex_in_time, type = ConflictType.VERTEX}
			
			if time_step + 1 < path.size():
				# vertex from, vertex to, and time
				# before the assing it we will compare the consecutive 
				# vertex_in_time, e.g. 
				var next_vertex_in_time = path[time_step + 1]
				
				# the hash table keys needs to be consistent, e.g. edge movement
				# from the vertex # (x,y) to (x+1, y) in time t to t+1 is the 
				# same as the egde movement of the other agent (x+1, y) to (x,y)
				# in time t to t+1
				var edge_in_time = ""
				if vertex_in_time < next_vertex_in_time:
					edge_in_time = str(Vector2(vertex_in_time.x,
							vertex_in_time.y)) + str(Vector2(
							next_vertex_in_time.x, next_vertex_in_time.y)) + \
							str(vertex_in_time.z)
				else:
					edge_in_time = str(Vector2(next_vertex_in_time.x,
							next_vertex_in_time.y)) + str(Vector2(
							vertex_in_time.x, vertex_in_time.y)) + \
							str(vertex_in_time.z)
				
				if not edge_conflicts.has(edge_in_time):
					edge_conflicts[edge_in_time] = agent_id
				
				else:
					#edge conflict is a tuple (ai, a j, v1, v2, t)
					# ai - first agent in conflict (who)
					# aj - second agent in conflict (whith whom)
					# v1 - conflicting vertex in time defining an edge (from)
					# v2 - conflicting vertex in time defining an edge (to)
					# t - type of conflict
					
					# create conflicting vertex in time for other agen
					var other_agent_vertex_conflict = Vector3(vertex_in_time.x, 
							vertex_in_time.y, next_vertex_in_time.z)
					
					# next_vertex_in_time is conflicting vertex for this agent 
					# in conflict  
					return {ai = agent_id, aj = edge_conflicts[edge_in_time],
							v1 = next_vertex_in_time, 
							v2 = other_agent_vertex_conflict, 
							type = ConflictType.EDGE}
				
			time_step += 1
		agent_id += 1
	return {type = ConflictType.NONE}
	
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

	
func _clear():
	agents.clear()
	open.clear()
	
