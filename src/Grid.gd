extends TileMap

class_name Grid

enum {NONE = -1, FREE, OBSTACLE, OPEN, CLOSED, PATH}

var camera : Camera2D

onready var start = $Start

onready var goal = $Goal

func _ready():
	pass

# will return grid position from world/global position
func to_vertex(world_position):
	return world_to_map(world_position)


func get_neighbors(vertex : Vector2, eight_directional : = false) -> Array:
	var directions = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	if eight_directional:
		directions += [Vector2.LEFT + Vector2.UP, Vector2.UP + Vector2.RIGHT, 
				Vector2.RIGHT + Vector2.DOWN, Vector2.DOWN + Vector2.LEFT]
	var neighbors = []
	
	for direction in directions:
		var tile_position = Vector2(vertex.x + direction.x,
				vertex.y + direction.y)
		if is_cell_valid(tile_position):
			neighbors.push_back(tile_position)
	return neighbors
	
	
# whether the vertex is valid
func is_cell_valid(vertex : Vector2) -> bool:
	match get_cellv(vertex):
		FREE, OPEN, CLOSED, PATH:
			return true
	return false


func _input(event : InputEvent):
	if event is InputEventMouseButton and event.pressed:
		var cell_pos = world_to_map(get_global_mouse_position())
		var cell = get_cellv(cell_pos)
		if cell == FREE:
			if event.button_index == BUTTON_LEFT:
				start.position = map_to_world(cell_pos) + cell_size / 2.0
			elif event.button_index == BUTTON_RIGHT:
				goal.position = map_to_world(cell_pos) + cell_size / 2.0
#will set OPEN, CLOSED and PATH cells to FREE
func reset():
	for vertex in get_used_cells():
		var cell = get_cellv(vertex)
		if cell != FREE and cell != OBSTACLE:
			set_cellv(vertex, FREE)
