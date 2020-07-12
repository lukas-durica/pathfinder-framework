extends Reference

class_name GodotAStar

var start : = Vector2.INF
var goal : = Vector2.INF
var a_star : = AStar2D.new()
var added_points : = {}
var is_initialized : = false
func _ready():
	pass
func init(graph, start : Vector2, goal : Vector2):
	self.start = start
	self.goal = goal
	var open : = {}
	a_star.clear()
	a_star.reserve_space(graph.get_used_cells().size())
	for cell in graph.get_used_cells():
		if not graph.is_cell_obstacle(cell):
			var cell_id = open[cell] if open.has(cell) else \
					a_star.get_available_point_id()
			a_star.add_point(cell_id, cell)
			added_points[cell] = cell_id
			for neighbor in graph.get_neighbors(cell):
				if not graph.is_cell_obstacle(neighbor):
					if not neighbor in added_points: 
						var neighbor_id = open[neighbor] if open.has(neighbor)\
								else a_star.get_available_point_id()
						if not neighbor in open:
							open[neighbor] = neighbor_id
						a_star.add_point(neighbor_id, neighbor)
						a_star.connect_points(cell_id, neighbor_id)
	is_initialized = true

func find_path() -> PoolVector2Array:
	if start in added_points and goal in added_points:
		var start_id = added_points[start]
		var goal_id = added_points[goal]
		return a_star.get_point_path(start_id, goal_id)
	elif not start in added_points:
		push_error("Start position is not in added_points")
		return PoolVector2Array()
	else:
		push_error("Goal position is not in added_points")
		return PoolVector2Array()

func reset():
	a_star.clear()
	added_points.clear()
	is_initialized = false

