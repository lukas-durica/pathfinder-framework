"""
code and comments are from:
https://medium.com/@nicholas.w.swift/easy-a-star-pathfinding-7e6689c7f7b2


"""

extends GridBasedAlgorithm


class_name AStarDefault

class AStarNode:
	var parent : = Vector2.INF
	var position : = Vector2.INF
	var g : = 0
	var h : = 0
	var f : = 0
	
	func equals(other_node):
		return position == other_node.position

func init(graph):
	pass

func find_path(graph, start : Vector2, goal : Vector2) -> Array:
	var start_node = AStarNode.new()
	start_node.position = start
	start_node.f = graph.get_manhattan_distance(start, goal)
	
	var goal_node = AStarNode.new()
	goal_node.position = goal
	#  consists of nodes that have been visited but not expanded (meaning that 
	# sucessors have not been explored yet). This is the list of pending tasks.
	var open_list = []
	
	# consists of nodes that have been visited and expanded (sucessors have 
	# been explored already and included in the open list, if this was the case).
	var closed_list = []
	
	open_list.push_back(start_node)
	
	while not open_list.empty():
		var current_node = open_list[0]
		var current_index = 0
		var index = 0
		for item in open_list:
			if item.f < current_node.f:
				current_node = item
				current_index = index
			index += 1
	
		open_list.remove(current_index)
		closed_list.append(current_node.position)
		
		if current_node == goal_node:
			return reconstruct_path(current_node)
		
		for neighbor in graph.get_neighbors(current_node):
			if neighbor.position in closed_list:
				continue
			neighbor.g = current_node.g + 1
			neighbor.h = graph.get_manhattan_distance(neighbor.position, goal)
			neighbor.f = neighbor.g + neighbor.h
			
			for open_node in open_list:
				if open_node.position == neighbor.position and neighbor.g > open_node.g:
					continue
			
			open_list.push_back(neighbor)
		
	return Array()


func reconstruct_path(current_node):
	var path = []
	var current = current_node
	while current != null:
		path.append(current.position)
		current = current.parent
	path.invert()
	return path
# One important aspect of A* is f = g + h. The f, g, and h variables are in our 
# Node class and get calculated every time we create a new vertex. Quickly I’ll 
# go over what these variables mean.
# F is the total cost of the vertex.
# G is the distance between the current vertex and the start.
# H is the heuristic — estimated distance from the current vertex to the end.


#1. Add the starting square (or node) to the open list.
#2. Repeat the following:
#A) Look for the lowest F cost square on the open list. We refer to this as the 
#current square.
#B). Switch it to the closed list.
#C) For each of the 8 squares adjacent to this current square …
#If it is not walkable or if it is on the closed list, ignore it. Otherwise do 
#the following.
#If it isn’t on the open list, add it to the open list. Make the current square 
#the parent of this square. Record the F, G, and H costs of the square.
#If it is on the open list already, check to see if this path to that square is 
#better, using G cost as the measure. A lower G cost means that this is a better
#path. If so, change the parent of the square to the current square, and 
#recalculate the G and F scores of the square. If you are keeping your open 
#list sorted by F score, you may need to resort the list to account for the 
#change.
#D) Stop when you:
#Add the target square to the closed list, in which case the path has been 
#found, or
#Fail to find the target square, and the open list is empty. In this case,
#there is no path.
#3. Save the path. Working backwards from the target square, go from each 
#square to its parent square until you reach the starting square. That is your 
#path.
