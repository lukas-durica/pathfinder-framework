extends TileMap

class_name Grid

enum {NONE = -1, FREE, OBSTACLE, OPEN, CLOSED, PATH}

var camera_zoom : = 1.0

onready var start = $Start

onready var goal = $Goal

func _ready():
	adjust_screen_to_grid()
	var bfs = BreadthFirstSearch.new()
	bfs.find_path(self, world_to_map(start.position), 
			world_to_map(goal.position))
	
# adjusting the size of the screen to the size of the grid
func adjust_screen_to_grid():
	
	# the size of the screen
	var screen_size : = get_viewport().get_visible_rect().size
	
	
	print("rect size: ", $VBoxContainer.rect_size * $VBoxContainer.rect_scale)
	
	# size of the rectangle enclosing the used (non-empty) tiles of the map and
	# size of the scaled gui 
	var rect_size = get_used_rect().end * cell_size + Vector2(
			$VBoxContainer.rect_size.x * $VBoxContainer.rect_scale.x, 0.0)
	
	# computing the ratio vector of the screen size and rectangle size
	var ratio_vec =  rect_size / screen_size
	
	# getting the greater ratio size
	camera_zoom = max(ratio_vec.x, ratio_vec.y)
	
		
	# and applying it the zoom to the camera and zooming sizes proportionally
	$Camera2D.zoom *= camera_zoom
	
	# move gui to the position next to grid
	$VBoxContainer.rect_position.x = get_used_rect().end.x * cell_size.x
	
# 4 directional
func get_neighbors(vertex : Vector2) -> Array:
	var directions = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
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
		var cell_pos = world_to_map(event.position * camera_zoom)
		var cell = get_cellv(cell_pos)
		
		if cell == FREE:
			if event.button_index == BUTTON_LEFT:
				start.position = map_to_world(cell_pos) + cell_size / 2.0
			elif event.button_index == BUTTON_RIGHT:
				goal.position = map_to_world(cell_pos) + cell_size / 2.0
				
		
		
