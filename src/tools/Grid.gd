extends TileMap

class_name Grid

enum {NONE = -1, FREE, OBSTACLE, OPEN, CLOSED, PATH}


# wold/global position to grid/vertex position
func to_vertex(world_position : Vector2) -> Vector2:
	return world_to_map(world_position)

# get neighbors of a given cell
func get_neighbors(vertex : Vector2, eight_directional : = false) -> Array:
	var directions = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	if eight_directional:
		directions += [Vector2.LEFT + Vector2.UP, Vector2.UP + Vector2.RIGHT, 
				Vector2.RIGHT + Vector2.DOWN, Vector2.DOWN + Vector2.LEFT]
	var neighbors = []
	
	for direction in directions:
		var tile_position = Vector2(vertex.x + direction.x,
				vertex.y + direction.y)
		if is_cell_valid(tile_position) and not is_cell_obstacle(tile_position):
			neighbors.push_back(tile_position)
	return neighbors
	
# manhattan distance between two vertexes
func get_manhattan_distance(vertex_a : Vector2, vertex_b: Vector2) -> int:
	return int(abs(vertex_a.x - vertex_b.x) + abs(vertex_a.y - vertex_b.y))
	
# whether the cell at given vertex exists
func is_cell_valid(vertex : Vector2) -> bool:
	#ternary operator
	return true if get_cellv(vertex) != -1 else false

# whether the cell at given vertex is free
func is_cell_free(vertex : Vector2) -> bool:
	return get_cellv(vertex) == FREE

# whether the cell at given vertex is an obstacle
func is_cell_obstacle(vertex : Vector2) -> bool:
	return get_cellv(vertex) == OBSTACLE

# set all vertexes to FREE except OBSTACLE type
func reset():
	for vertex in get_used_cells():
		if not is_cell_obstacle(vertex):
			set_cellv(vertex, FREE)
			
func get_cost(current, neighbor):
	var md = get_manhattan_distance(current, neighbor)
	if md == 1:
		return 10
	elif md == 2:
		return 14
	else:
		push_warning("get cost is not valid")
