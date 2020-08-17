extends Node2D

class_name GridBasedUI

# use gui zoom factor for adjusting the camera zoom with respect to GUI to avoid
# overlap with the grid, just cosmetic treatment
const GUI_ZOOM_FACTOR : = 1.13

# the pathfindinf algorithm 
var algorithm : GridBasedAlgorithm


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

# reference to user interface 
onready var user_interface = $UserInterface




# Called when the node enters the scene tree for the first time.
func _ready():
	#adjusting the camera zoom to the size of the grid
	adjust_camera_to_grid()
	
	# set algorithm and update menu in gui
	set_algorithm(Algorithm.A_STAR_CBS, true)
	
	$Agent.grid = grid
	
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
			var world_pos = grid.to_world_position(cell_pos)
			if event.button_index == BUTTON_LEFT:
				# cell position to world
				# offset to it
				start.position = world_pos
			elif event.button_index == BUTTON_RIGHT:
				goal.position = world_pos
	
	elif event is InputEventMouseMotion:
		 user_interface.set_coords(grid.to_vertex(get_global_mouse_position()))


func run():
	# reset all cells to default (e.g. path cells to free)
	grid.reset()
	
	# convert global positions to the grid (vertex) position
	var start_position = grid.to_vertex(start.position)
	var goal_position = grid.to_vertex(goal.position)
	if not grid.is_cell_free(start_position):
		push_error("Start position is not free!")
	elif not grid.is_cell_free(goal_position):
		push_error("Goal position is not free!")
	else:
		# start measuring time
		var time_start = OS.get_ticks_usec()
		
		# find the path
		var path = algorithm.find_path(start_position, goal_position)
		
		# print elapsed time
		print("Elapsed time: ", OS.get_ticks_usec() - time_start, 
				" microseconds")
		print("Path size: ", path.size())
		
		# color the path
		for vertex in path:
			grid.set_cellv(vertex, Grid.PATH)
		
		# set path to an agent
		$Agent.path = path




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

# set algorithm and upstate UserInterface if needed (e.g. at the functio _ready)
# if the algorithm is set from the code (e.g. at the startup), user interface 
# need to be updated accordingly update_ui, if the user will change algorithm 
# using user interface was already changed
func set_algorithm(algorithm_enum_value : int, update_ui : = false):
	match algorithm_enum_value:
		Algorithm.A_STAR_DEFAULT:
			algorithm = AStarDefault.new()
		Algorithm.A_STAR_GODOT:
			algorithm = AStarGodot.new()
		Algorithm.A_STAR_REDBLOB:
			algorithm = AStarRedBlob.new()
		Algorithm.A_STAR_CBS:
			algorithm = AStarCBS.new()
		
		_:
			push_error("Unknow algorithm! Setting default A*")
			algorithm = AStarDefault.new()
			
			
	
	if update_ui:
		$UserInterface.check_algorithm_item(algorithm_enum_value)
		$UserInterface.update_options(grid.is_8_directional)
	
	# initialize algorithm (e.g convert grid to Godot's Astar representation)
	# look into the AstarGodot.gd for more
	algorithm.initialize(grid)
	


func _on_UserInterface_algorithms_id_pressed(id):
	set_algorithm(id)


func _on_UserInterface_options_id_pressed(id):
	print(id)
	if id == 1:
		grid.is_8_directional = not grid.is_8_directional
		algorithm.initialize(grid)


			
			
			
