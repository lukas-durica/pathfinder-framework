extends Node2D

class_name GridBasedUI

# use gui zoom factor for adjusting the camera zoom with respect to GUI to avoid
# overlap with the grid, just cosmetic treatment
const GUI_ZOOM_FACTOR : = 1.13

# camera is used for moving (pressing mouse wheel) and zooming (
# scrolling mouse wheel) on the grid
onready var camera : BasicCamera = $Camera

# the playground
onready var grid : Grid = $Grid

# start node, can be dragged during editor or set during the runtime 
# (left mouse button)
onready var start : Sprite = $Start

# goal node, can be dragged during editor or set during the runtime
# (right mouse button)
onready var goal : Sprite = $Goal

# the algorithm for search the path
var algorithm = AStarGodot.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#adjusting the camera zoom to the size of the grid
	adjust_camera_to_grid()
	#MapLoader.load_map(grid)

func adjust_camera_to_grid():
	
	# the size of the screen
	var screen_size : = get_viewport().get_visible_rect().size
		
	# size of the rectangle enclosing the used (non-empty) tiles of the map 
	var rect_size = grid.get_used_rect().size * grid.cell_size 
	
	# computing the ratio vector of the screen size and rectangle size
	var ratio_vec =  rect_size / screen_size
	 
	# getting the greater ratio size
	camera.zoom_factor = max(ratio_vec.x, ratio_vec.y)
	
	#adjusting zoom_ratio in respect to gui
	camera.zoom_factor *= GUI_ZOOM_FACTOR
	
	#zoom camera to the zoom_ration
	camera.zoom(0)
	
	#set camera position to the center of the grid
	camera.position = (grid.get_used_rect().position + 
			grid.get_used_rect().size / 2.0) * grid.cell_size


# set the start position and goal position in the runtime, but only until the
# algorithm is initialized
# process this input as unhadled due to higher priority of the UserInterface

func _unhandled_input(event):
	
	if event is InputEventMouseButton and event.pressed:
		
		# get mouse position to the grid (vertex) position
		var cell_pos = grid.to_vertex(get_global_mouse_position())
		
		# if the cell is free, it can be assigned as start/goal
		if grid.is_cell_free(cell_pos):
			if event.button_index == BUTTON_LEFT:
				# cell position to world/global position and add halfcell size
				# offset to it
				start.position = grid.map_to_world(cell_pos) \
						+ grid.cell_size / 2.0
			elif event.button_index == BUTTON_RIGHT:
				goal.position = grid.map_to_world(cell_pos) \
						+ grid.cell_size / 2.0


func run():
	grid.reset()
	var start_position = grid.to_vertex(start.position)
	var goal_position = grid.to_vertex(goal.position)
	if not grid.is_cell_free(start_position):
		push_error("Start position is not free!")
	elif not grid.is_cell_free(goal_position):
		push_error("Goal position is not free!")
	else:
		var time_start = OS.get_ticks_usec()
		var path = algorithm.find_path(start_position, goal_position)
		print("Elapsed time: ", OS.get_ticks_usec() - time_start)
		print("Path size: ", path.size())
		for vertex in path:
			grid.set_cellv(vertex, Grid.PATH)




# chceck which button was pressed and run the appropriate method
func _on_UserInterface_button_pressed(id : int):
	match id:
		UserInteraface.RUN:
			run()
#		UserInteraface.PAUSE:
#			pause()
#		UserInteraface.STOP:
#			stop()
#		UserInteraface.PREVIOUS_STEP:
#			previous_step()
#		UserInteraface.NEXT_STEP:
#			next_step()
		_:
			push_warning("ButtonId is not valid!")

func _on_UserInterface_menu_item_pressed(id):
	match id:
		Algorithm.A_STAR_DEFAULT:
			algorithm = AStarDefault.new()
		Algorithm.A_STAR_GODOT:
			algorithm = AStarGodot.new()
		Algorithm.A_STAR_REDBLOB:
			algorithm = AStarRedBlob.new()
	algorithm.initialize(grid)
