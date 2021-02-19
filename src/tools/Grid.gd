extends TileMap

class_name Grid

enum {NONE = -1, FREE, OBSTACLE, OPEN, CLOSED, PATH}

const TIME_STEP = 1

const WAITING_COST = 5
const REGULAR_MOVEMENT_COST = 5
const DIAGONAL_MOVEMENT_COST = 7


#eight way directional movement
var is_8_directional : = false


# wold position to grid/vertex position
func to_vertex(world_position : Vector2) -> Vector2:
	return world_to_map(world_position)

# grid/vertex position to world position with halfcell offset
func to_world(vertex : Vector2) ->Vector2:
	return map_to_world(vertex) + cell_size / 2.0

# get neighbors of a given cell for single agent pathfinding
func get_neighbors(vertex : Vector2) -> Array:
	var directions = get_cardinal_directions()
	if is_8_directional:
		directions += get_diagonal_directions()
	var neighbors = []
	
	for direction in directions:
		var tile_position = vertex + direction
		if is_cell_valid(tile_position) and not is_cell_obstacle(tile_position):
			neighbors.push_back(tile_position)
	return neighbors

#get states for multiagent path finding
func get_states(vertex : Vector3) -> Array:
	#wait action at the same vertex
	vertex.z += TIME_STEP
	var states = []
	states.push_back(vertex)
	states += get_valid_directions(vertex, get_cardinal_directions())
	if is_8_directional:
		states += get_valid_directions(vertex, get_diagonal_directions())
	return states

# get array of valid subsequent vertexes defined by directions and the
# validate them, i.e. check if they are valid and not obstacle
func get_valid_directions(vertex: Vector3, directions : Array):
	var valid_directions = []
	for direction in directions:
		var tile_position = Vector3(vertex.x + direction.x, 
				vertex.y + direction.y, vertex.z)
	
		if is_cell_valid(Vector2(tile_position.x, tile_position.y)) \
				and not is_cell_obstacle(Vector2(tile_position.x, 
				tile_position.y)):
			valid_directions.push_back(tile_position)
	return valid_directions

# +
static func get_cardinal_directions() -> Array:
	return [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
# /\
static func get_diagonal_directions() -> Array:
	return [Vector2.LEFT + Vector2.UP, Vector2.UP + Vector2.RIGHT, 
			Vector2.RIGHT + Vector2.DOWN, Vector2.DOWN + Vector2.LEFT]

# heuristic distance between two vertexes based on th type of the movement
func get_heuristic_distance(vertex_a : Vector2, vertex_b : Vector2) -> int:
	if is_8_directional:
		return get_diagonal_distance(vertex_a, vertex_b)
	return get_manhattan_distance(vertex_a, vertex_b)

# manhattan distance between two vertexes
func get_manhattan_distance(vertex_a : Vector2, vertex_b : Vector2) -> int:
	return int(abs(vertex_a.x - vertex_b.x) + abs(vertex_a.y - vertex_b.y)) * \
			REGULAR_MOVEMENT_COST
			
func get_manhattan_distance_a_sipp(vertex_a : Vector2, vertex_b : Vector2) -> int:
	return int(abs(vertex_a.x - vertex_b.x) + abs(vertex_a.y - vertex_b.y))

# diagonal distance between two vertexes
func get_diagonal_distance(vertex_a : Vector2, vertex_b : Vector2) -> int:
	var dx = abs(vertex_a.x - vertex_b.x)
	var dy = abs(vertex_a.y - vertex_b.y)
	return REGULAR_MOVEMENT_COST * int(abs(dx-dy)) + \
			DIAGONAL_MOVEMENT_COST * int(min(dx,dy))

# whether the cell at given vertex exists
func is_cell_valid(vertex : Vector2) -> bool:
	#ternary operator
	return get_cellv(vertex) != NONE 

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

#includes waiting cost
func get_cost(current, neighbor):
	if Vector2(current.x, current.y) == Vector2(neighbor.x, neighbor.y):
		return WAITING_COST
	
	
	if current.x == neighbor.x or current.y == neighbor.y:
		return REGULAR_MOVEMENT_COST
	return  DIAGONAL_MOVEMENT_COST

# 0,0!1,0!2,0
# 0,1!1,1!2,1
# 0,2!1,2!2,2


func create_test_label(vertex : Vector2, a_star_values : Vector3):
	var label = preload("res://src/ui/TestLabel.tscn").instance()
	label.rect_position = map_to_world(vertex)
	label.set_a_star_values(a_star_values)
	label.set_name(str(vertex))
	add_child(label)
			
func update_test_label(vertex : Vector2, a_star_values : Vector3):
	get_node(str(vertex)).set_a_star_values(a_star_values)


