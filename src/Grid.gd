extends TileMap

class_name Grid

enum {NONE = -1, FREE, OBSTACLE}

func _ready():
	adjust_screen_to_grid()
	
# adjusting the size of the screen to the size of the grid
func adjust_screen_to_grid():
	
	# the size of the screen
	var screen_size : = get_viewport().get_visible_rect().size
	
	# size of the rectangle enclosing the used (non-empty) tiles of the map
	var rect_size = get_used_rect().end * cell_size
	
	# computing the ratio vector of the screen size and rectangle size
	var ratio_vec =  rect_size / screen_size
	
	# getting the greater ratio size
	var ratio = max(ratio_vec.x, ratio_vec.y)
	
	# and applying it the zoom to the camera and zooming sizes proportionally
	$Camera2D.zoom = Vector2(ratio, ratio)
