extends GridBasedAlgorithm

# Conflict-based search
# Citation: Sharon, Guni, et al. "Conflict-based search for optimal multi-agent 
# pathfinding." Artificial Intelligence 219 (2015): 40-66.
class_name CBS

# There can be two types of conflicts Vertex and Edge. Vertex conflict is a 
# tuple (ai, aj, v, t) where agent ai and agent a j occupy vertex v at time 
# point t. A solution (of k paths) is valid if all its paths have no conflicts. 
# A consistent solution can be invalid if, despite the fact that the individual 
# paths are consistent with the constraints associated with their agents, these 
# paths still have conflicts.
enum ConflictType {NONE, VERTEX, EDGE}

# low-level search using space-time astar
var astar = AStarCBS.new()

# agents are created from starts and goals
var agents = []

# Each node N in the CT consists of:
# 1. A set of constraints (N.constraints). Each of these constraints belongs to
# a single agent. The root of the CT contains an empty set of constraints. 
# The child of a node in the CT inherits the constraints of the parent and adds 
# one new constraint for one agent.
# 2. A solution (N.solution). A set of k paths, one path for each agent. The 
# path for agent ai must be consistent with the constraints of ai. Such paths 
# are found by the low-level search.
# 3. The total cost (N.cost) of the current solution (summed over all the 
# single-agent path costs). This cost is referred to as the f -value of node N.
# Following variables were additionally added:
# 4. Parent. For iterating and cumulating constraints for a given agent in 
# binary tree
# 5. Costs. Costs of partial solutions, i.e. individual paths, in order
# to avoid iterating through the paths
class CBSNode:
	var constraint : CBSConstraint
	var solution : = []
	var cost : = 0
	var parent = null
	var costs : = []

# CBSAgent is helper class created for storing ID for every pair consisting of 
# start and goal
class CBSAgent:
	var id : = -1
	var start_state : = Vector3.INF
	var goal_state : = Vector3.INF

# A constraint is a tuple (ai, v,t) where agent ai (represented by agent_id) is 
# prohibited from occupying vertex v at time step t. During the course of the 
# algorithm, agents will be associated with constraints. A consistent path for 
# agent ai is a path that satisfies all its constraints. Likewise, a consistent 
# solution is a solution that is made up from paths, such that the path for any 
# agent ai is consistent with the constraints of ai.
# According to the problem definition agents are not allowed to cross the same 
# edge at opposite direction then edge conflicts can also occur. We define an 
# edge conflict to be the tuple (ai, a j, v1, v2, t) where two agents “swap” 
# locations (ai moves from v1 to v2 while a j moves from v2 to v1) between time 
# step t to time step t + 1. An edge constraint is defined as (ai, v1, v2, t),
# where agent ai is prohibited of starting to move along the edge from v1 to v2 
# at time step t (and reaching v2 at time step t + 1). When applicable, edge 
# conflicts are treated by the high level in the same manner as vertex conflicts.
# Due to the fact that vertex and edge conflicts are different, they are 
# represented by different data types - vertex conflic with Vector3 and edge
# conflict with Transform2D. In CBSConstrain class variable called data stores
# the conflict
class CBSConstraint:
	var agent_id : = -1
	var data

# overrided virtual function
func initialize(grid):
	.initialize(grid)
	# assign the graph to the
	astar.grid = grid

# overrided virtual function
func find_solution(starts_and_goals : Array):
	# clear open as it is the member value
	
	#the structure for best-first search for high-level search
	var open = MinBinaryHeap.new()
	
	# create agents, assign id, start and goals
	create_agents(starts_and_goals)
		
	# get root CBS node without any constraints
	var root = get_root()
	
	# insert it to min heap for best-first search
	open.insert_key({value = root.cost, node = root})
	
	# just helper variable
	var closed_nodes : = 0
	
	# while open list is not empty
	while not open.empty():
		
		# get the node with the lowest value
		var current = open.extractMin().node
		
		# the length of the paths in the solution needs to be of the same 
		# size during searching for conflict even if they (agents) are 
		# waiting at the goal position
		add_padding_to_solution(current.solution)
		
		# validate the paths in the solution until a first conflict occurs
		var conflict = get_first_conflict(current.solution)
		
		# if there is no conflict we have solution
		if conflict.type == ConflictType.NONE:
			print("cost: ", current.cost)
			print("closed nodes: ", closed_nodes)
			print("open_nodes: ", open.size() + 1)
			return current.solution
		
		# 2 is number of agents in the any conflict
		for i in range(2):
			
			# create variable for constraint
			var new_constraint = CBSConstraint.new()
			
			# add id of the agent to which conflict belongs
			new_constraint.agent_id = conflict.ai if i == 0 else conflict.aj
			
			# if the conflict is vertex conflict
			if conflict.type == ConflictType.VERTEX:
				new_constraint.data = conflict.v
			
			# if the conflict is edge conflict
			elif conflict.type == ConflictType.EDGE:
				if i == 0:
					#to create edge constraint, the data type with 5 members is
					# needed thus Transform2D 
					# from : Vector2, to : Vector2, when : int
					new_constraint.data = Transform2D(Vector2(conflict.v1.x, 
							conflict.v1.y), Vector2(conflict.v2.x, 
							conflict.v2.y), Vector2(conflict.v1.z, 0))
				# for other agent the conflicts varies from and to values
				else:
					new_constraint.data = Transform2D(Vector2(conflict.v2.x, 
							conflict.v2.y), Vector2(conflict.v1.x, 
							conflict.v1.y), Vector2(conflict.v1.z, 0))
			
			# for each constraint create new node
			var new_node = CBSNode.new()
			new_node.parent = current
			new_node.constraint = new_constraint
			
			# duplicate solution from the current node, deep copy, i.e. all 
			# stored arrays are duplicated also
			new_node.solution = current.solution.duplicate(true)
			new_node.costs = current.costs.duplicate(true)
			new_node.cost = current.cost
			
			# update the soluction with a given constraint
			update_solution(new_node)
			
			# if solution is feasible
			if new_node.cost != INF:
				open.insert_key({value = new_node.cost, node = new_node})
		closed_nodes += 1
	return []

# for every pair of start and goal create states Vector3 and add it to the 
# helper class CBSAgent with ID
func create_agents(starts_and_goals : Array):
	for i in starts_and_goals.size():
		var agent = CBSAgent.new()
		agent.id = i
		var start = starts_and_goals[i].start
		var goal = starts_and_goals[i].goal
		agent.start_state = Vector3(start.x, start.y, 0)
		agent.goal_state = Vector3(goal.x, goal.y, 0)
		agents.push_back(agent)


#validate the paths until a first conflict occurs
func get_first_conflict(solution : Array) -> Dictionary:
	var conflicts = {}
	var agent_id : = 0
	for path in solution:
		# id of the vertex in path
		var vertex_idx : = 0
		# for every vertex in path
		for vertex_in_time in path:
			
			# if a given vertex is not in conflicts add it and assign its agent
			# id to it
			if not vertex_in_time in conflicts:
				conflicts[vertex_in_time] = agent_id
			# if such vertex is already in conflicts 
			else:
				# vertex conflict is a tuple (ai, aj, v, t)
				# ai - first agent in conflict (who)
				# aj - second agent in conflict (whith whom)
				# v - conflicting vertex (where)
				# t - type of confliv
				#print("vertex conflict")
				return {ai = agent_id, aj = conflicts[vertex_in_time], 
						v = vertex_in_time, type = ConflictType.VERTEX}
			
			# lets search if movement from vertex to next_vertex wont create
			# edge conflict
			if vertex_idx + 1 < path.size():
				var next_vertex_in_time = path[vertex_idx + 1]
				
				# the hash table keys needs to be consistent, e.g. edge movement
				# from the vertex # (x,y) to (x+1, y) in time t to t+1 is the 
				# same as the egde movement of the other agent (x+1, y) to (x,y)
				# in time t to t+1
				var edge_in_time = Transform2D.IDENTITY
				if vertex_in_time < next_vertex_in_time:
					edge_in_time = Transform2D(Vector2(vertex_in_time.x,
							vertex_in_time.y), Vector2(next_vertex_in_time.x, 
							next_vertex_in_time.y), 
							Vector2(vertex_in_time.z, 0))
				else:
					edge_in_time = Transform2D(Vector2(next_vertex_in_time.x,
							next_vertex_in_time.y), Vector2(vertex_in_time.x, 
							vertex_in_time.y), Vector2(vertex_in_time.z, 0))
				# if there is not such edge, add it
				if not conflicts.has(edge_in_time):
					conflicts[edge_in_time] = agent_id
				
				else:
					#edge conflict is a tuple (ai, a j, v1, v2, t)
					# ai - first agent in conflict (who)
					# aj - second agent in conflict (whith whom)
					# v1 - conflicting vertex in time defining an edge (from)
					# v2 - conflicting vertex in time defining an edge (to)
					# t - type of conflict
					
					return {ai = agent_id, aj = conflicts[edge_in_time],
							v1 = vertex_in_time, v2 = next_vertex_in_time, 
							type = ConflictType.EDGE}
			
			vertex_idx += 1
		agent_id += 1
	# no conflicts were found
	return {type = ConflictType.NONE}

# get root CBSNode with no constraints in it
func get_root() -> CBSNode:
	var root = CBSNode.new()
	astar.constraints = {}
	for agent in agents:
		# use low level search, which has no knowledge about other agents
		# and compute its cost
		var partial_solution = astar.find_solution([{
				start = agent.start_state, goal = agent.goal_state}])
		root.solution.push_back(partial_solution.path)
		root.costs.push_back(partial_solution.cost)
		root.cost += partial_solution.cost
	return root

# add padding to paths with respect to the longest paths
func add_padding_to_solution(solution : Array):
	var path_max_size = 0
	
	# find maximum size of all paths
	for path in solution:
		if path.size() > path_max_size:
			path_max_size = path.size()
	
	# every path will be padded to aforemention maximum size with the last
	# action, i.e. will be waiting at the goal position, waiting at the goal
	# position costs nothing
	
	for path in solution:
		if path.size() < path_max_size:
			var path_size = path.size()
			var last_state = path.back()
			path.resize(path_max_size)
			for i in range(path_size, path_max_size):
				# update time parameter in vertex accordingly
				last_state.z += Grid.TIME_STEP
				path[i] = last_state

# update the solution to the constraint
func update_solution(node : CBSNode):
	var agent_id = node.constraint.agent_id
	var constraints : = {}
	var current_node = node
	# get all constraints in this branch to the root
	while current_node.parent:
		# if the constraint matches agent_id
		if current_node.constraint.agent_id == agent_id:
			var constraint = current_node.constraint
			# add constraint to the hastable constraints assign agent id to it
			constraints[constraint.data] = constraint.agent_id
		current_node = current_node.parent
	var agent : CBSAgent = agents[agent_id]
	astar.constraints = constraints
	
	# if the goal is found reconstruct the path, i.e. early exit
	# in CBS search we know the length of the paths and they need to have
	# same size during searching for conflict, even if they (agents) are 
	# waiting at the goal position, thus in CBS set goal.z (time parameter)
	# to the size of the padded path, and new path must be at least long as
	# is the padded path
	var goal_state = agent.goal_state
	goal_state.z = node.solution[agent_id].back().z
	
	
	var partial_solution = astar.find_solution([{start = agent.start_state, 
			goal = goal_state}])
	
	# add new path to the solution
	node.solution[agent_id] = partial_solution.path
	
	# substract old cost from the cost of the node
	node.cost -= node.costs[agent_id]
	
	#assign new cost to costs
	node.costs[agent_id] = partial_solution.cost
	
	# and finally add it to the cost od the node
	node.cost += node.costs[agent_id]

func clear():
	agents.clear()
	
