"""
This algortihm uses Godot's Astar
"""

extends GridBasedAlgorithm

class_name AStarGodot

var a_star = AStar2D.new()

func _initialize(graph):
	var already_added : = {}
	var open : = {}
	
	a_star.reserve_space(graph.get_used_cells().size())
	for cell in graph.get_used_cells():
		if not graph.is_cell_obstacle(cell):
			var cell_id = open[cell] if open.has(cell) else \
					a_star.get_available_point_id()
			a_star.add_point(cell_id, cell)
			already_added[cell] = cell_id
			for neighbor in graph.get_neighbors(cell):
				if not graph.is_cell_obstacle(neighbor): 
					if not neighbor in already_added:
						var neighbor_id
						if neighbor in open:
							neighbor_id = open[neighbor]
						else:
							neighbor_id = a_star.get_available_point_id()
							open[neighbor] = neighbor_id
						a_star.add_point(neighbor_id, neighbor)
						a_star.connect_points(cell_id, neighbor_id)
	
func _find_path(start : Vector2, goal : Vector2):
	var start_id = a_star.get_closest_point(start)
	var goal_id = a_star.get_closest_point(goal)
	return a_star.get_point_path(start_id, goal_id)
