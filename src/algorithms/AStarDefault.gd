"""
A* is a modification of Dijkstra’s Algorithm that is optimized for a single 
destination. Dijkstra’s Algorithm can find paths to all locations; A* finds 
paths to one location, or the closest of several locations. It prioritizes paths
that seem to be leading closer to a goal.
chceck for more:
https://www.geeksforgeeks.org/a-search-algorithm/
veral locations. It prioritizes paths
that seem to be leading closer to a goal.
"""

extends GridBasedAlgorithm


class_name AStarDefault

class AStarNode:
	var parent = null
	var position : = Vector2.INF
	var g : = 0
	var h : = 0
	var f : = 0

func _initialize(graph):
	pass

func _find_path(starts_and_goals : Array) -> Array:
	# create AstarNode and set position to it
	var start_node = AStarNode.new()
	start_node.position = starts_and_goals[0].start
	var goal_node = AStarNode.new()
	goal_node.position = starts_and_goals[0].goal
	#  consists of nodes that have been visited but not expanded (meaning that 
	# sucessors have not been explored yet). This is the list of pending tasks.
	var open_list = []
	
	# consists of nodes that have been visited and expanded (sucessors have 
	# been explored already and included in the open list, if this was the case).
	var closed_list = []
	
	# put the starting node on the open list
	open_list.push_back(start_node)
	#  while the open list is not empty
	while not open_list.empty():
		#find the node with the least f on the open list
		var min_index = 0
		var index = 0
		
		var current_node = open_list[min_index]
		
		for item in open_list:
			if item.f < current_node.f:
				current_node = item
				min_index = index
			index += 1
		
		#pop current node off the open list
		open_list.remove(min_index)
		
		# if the goal was reached reconstruct path
		if current_node.position == goal_node.position:
			return reconstruct_path(current_node)
		
		# get all neighbors of current node
		for neighbor_position in graph.get_neighbors(current_node.position):
			
			# if the neighbor is closed list, jump to next neighbor
			if neighbor_position in closed_list:
				continue
			
			#create AstarNode and assign position
			var neighbor = AStarNode.new()
			neighbor.position = neighbor_position
			
			# One important aspect of A* is f = g + h. The f, g, and h variables
			# are calculated every time we create a new node.
			# G is the distance (cost) between the current node and the start.
			# H is the heuristic — estimated distance from the current node to
			# the end.
			# F is the total cost of the node. F = G + H
			
			# get cost from the start of the current node and add the cost
			# of the movement between current node and neighbor (e.g. 
			# cardinal, diagonal)
			neighbor.g = current_node.g + graph.get_cost(current_node.position, 
					neighbor_position)
			
			# compute manhattan distance for a given neighbor to goal, more info
			# www.redblobgames.com/pathfinding/a-star/introduction.html#greedy-best-first
			# The location closest to the goal will be explored first.
			neighbor.h = graph.get_manhattan_distance(neighbor.position, 
					goal_node.position)
			
			# the sum of the cost from the beginning to neighbor and estimated
			# cost to the goal is the cost of the current node
			neighbor.f = neighbor.g + neighbor.h
			
			# set current node as the parent for neighbor
			neighbor.parent = current_node
			
			index = 0
			var is_in_open_list = false
			
			# chceck if the neighbor is already in open list 
			for open_node in open_list:
				if open_node.position == neighbor.position:
					is_in_open_list = true
					# the neighbor is already in open list 
					# check if the its cost from the start is lower than node 
					# that is alrady in open list.
					if neighbor.g < open_node.g:
						# if so, it means that this is shorter way to this 
						# neighbor and replace it with actual node
						open_list[index] = neighbor
					break
				index += 1
			# if the neighbor is already in open list but cost lower, just skip 
			if is_in_open_list:
				continue
			# if the neighbor is not in open list add it to it
			open_list.push_back(neighbor)
		# add processed current node to the closed list
		closed_list.append(current_node.position)
	return Array()


func reconstruct_path(current_node) -> Array:
	var path = []
	var current = current_node
	# if this cell is not start (only start has no previous cell)
	while current != null:
		#add vertex to our path
		path.append(current.position)
		
		#set its parent as current
		current = current.parent
		
	#the path is oriented from the goal to the start so it needs to be reversed
	path.invert()
	return path
