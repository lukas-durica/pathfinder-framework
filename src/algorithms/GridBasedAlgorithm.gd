extends Node2D

class_name GridBasedAlgorithm

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
var algorithm : = GodotAStar.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	#adjusting the camera zoom to the size of the grid
	adjust_camera_to_grid()
	#User interface is invisible due to work with the grid in the editor
	$UserInterface/UIRoot.visible = true
	set_up_algorithm()
	var time_start = OS.get_ticks_usec()
	var path = algorithm.find_path()
	var elapsed = OS.get_ticks_usec() - time_start
	print(path.size())
	print("Godot AStar: ", elapsed)
	grid.reset()
	time_start = OS.get_ticks_usec()
	AStarRedBlob.find_path(grid, grid.to_vertex(start.position), 
			grid.to_vertex(goal.position))
	elapsed = OS.get_ticks_usec() - time_start
	print("RedBlob AStar: ", elapsed)
	grid.reset()
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
func _input(event : InputEvent):
	
	if not algorithm.is_initialized and event is InputEventMouseButton \
			and event.pressed:
		
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
						
# validate start and goal position and initialize the algorithm
func set_up_algorithm() -> bool:
	#from global/world position to vertex/grid position
	var start_position = grid.to_vertex(start.position)
	var goal_position = grid.to_vertex(goal.position)
	if grid.is_cell_free(start_position) and grid.is_cell_free(goal_position):
			algorithm.init(grid, start_position, goal_position)
			return true
	elif not grid.is_cell_free(start_position):
		push_error("Start position is not free!")
		return false
	else:
		push_error("Goal position is not free!")
		return false

# run algorithm instantly
func run():
	grid.reset()
	algorithm.reset()
	if set_up_algorithm():
		var path = algorithm.find_path()
		for vertex in path:
			grid.set_cellv(vertex, Grid.PATH)
func pause():
	pass

# reset grid and algorithm
func stop():
	grid.reset()
	algorithm.reset()
func previous_step():
	pass
	
# step the algorithm
func next_step():
	#if the algorithm is not initialized, then initialize it, step it otherwise
	if not algorithm.is_initialized:
		if set_up_algorithm():
			algorithm.step()
	else:
		algorithm.step()

# chceck which button was pressed and run the appropriate method
func _on_UserInterface_button_pressed(id : int):
	match id:
		UserInteraface.RUN:
			run()
		UserInteraface.PAUSE:
			pause()
		UserInteraface.STOP:
			stop()
		UserInteraface.PREVIOUS_STEP:
			previous_step()
		UserInteraface.NEXT_STEP:
			next_step()
		_:
			push_warning("ButtonId is not valid!")
	
