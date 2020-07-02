extends TileMap

class_name Grid

enum {NONE = -1, FREE, OBSTACLE, OPEN, CLOSED, PATH}

var camera_zoom : = 1.0

onready var start = $Start

onready var goal = $Goal

func _ready():
	
	var bfs = BreadthFirstSearch.new()
	bfs.find_path(self, world_to_map(start.position), 
			world_to_map(goal.position))
	
# adjusting the size of the screen to the size of the grid

	
# 4 directional
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
		_:
			return false


func _input(event : InputEvent):
	if event is InputEventMouseButton and event.pressed:
		
		#since the mouse position is also based on camera zoom we need to 
		#adjust the position
		print("event.position: ", event.position)
		var cell_pos = world_to_map(event.position * camera_zoom)
		var cell = get_cellv(cell_pos)
		
		if cell == FREE:
			if event.button_index == BUTTON_LEFT:
				start.position = map_to_world(cell_pos) + cell_size / 2.0
			elif event.button_index == BUTTON_RIGHT:
				goal.position = map_to_world(cell_pos) + cell_size / 2.0
				
		
		
