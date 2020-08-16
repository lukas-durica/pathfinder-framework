extends TileMap

class_name Grid

enum {NONE = -1, FREE, OBSTACLE, OPEN, CLOSED, PATH}

const CARDINAL_MOVEMENT_COST = 5
const DIAGONAL_MOVEMENT_COST = 7


#eight way directional movement
var is_8_directional : = false


# wold/global position to grid/vertex position
func to_vertex(world_position : Vector2) -> Vector2:
	return world_to_map(world_position)

# get neighbors of a given cell
func get_neighbors(vertex : Vector2) -> Array:
	var directions = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	if is_8_directional:
		directions += [Vector2.LEFT + Vector2.UP, Vector2.UP + Vector2.RIGHT, 
				Vector2.RIGHT + Vector2.DOWN, Vector2.DOWN + Vector2.LEFT]
	var neighbors = []
	
	for direction in directions:
		var tile_position = Vector2(vertex.x + direction.x,
				vertex.y + direction.y)
		if is_cell_valid(tile_position) and not is_cell_obstacle(tile_position):
			neighbors.push_back(tile_position)
	return neighbors

func get_states(vertex : Vector2) -> Array:
	var wait = Vector2.ZERO
	return wait + get_neighbors(vertex)

# manhattan distance between two vertexes
func get_manhattan_distance(vertex_a : Vector2, vertex_b : Vector2) -> int:
	return int(abs(vertex_a.x - vertex_b.x) + abs(vertex_a.y - vertex_b.y)) * \
			CARDINAL_MOVEMENT_COST


func get_diagonal_distance(vertex_a : Vector2, vertex_b : Vector2) -> int:
	return 0
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
	if current.x != neighbor.x and current.y != current.y:
		return CARDINAL_MOVEMENT_COST
	return DIAGONAL_MOVEMENT_COST

# 0,0!1,0!2,0
# 0,1!1,1!2,1
# 0,2!1,2!2,2



