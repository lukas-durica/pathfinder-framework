extends Node2D

const GUI_FACTOR = 1.13

onready var camera = $Camera

onready var grid = $Grid

var algorithm : Reference

# Called when the node enters the scene tree for the first time.
func _ready():
	adjust_screen_to_grid()
	#User interface is invisible due to work with the grid in the editor
	$UserInterface/UIRoot.visible = true
	
	algorithm = BreadthFirstSearch.new()
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func adjust_screen_to_grid():
	
	# setting camera reference to grid, it uses camera.zoom ratio
	grid.camera = camera
	
	# the size of the screen
	var screen_size : = get_viewport().get_visible_rect().size
	
	
	#print("rect size: ", $VBoxContainer.rect_size * $VBoxContainer.rect_scale)
	
	# size of the rectangle enclosing the used (non-empty) tiles of the map 
	var rect_size = grid.get_used_rect().size * grid.cell_size 
	
	# computing the ratio vector of the screen size and rectangle size
	var ratio_vec =  rect_size / screen_size
	 
	# getting the greater ratio size
	camera.zoom_ratio = max(ratio_vec.x, ratio_vec.y)
	
	#adjusting zoom_ratio in respect to gui
	camera.zoom_ratio *= GUI_FACTOR
	
	#zoom camera to ration factior	
	camera.zoom(0)
	
	#set camera position to he center of the grid
	camera.position = (grid.get_used_rect().position + 
			grid.get_used_rect().size / 2.0) * grid.cell_size
	
	
func run():
	grid.reset()
	var start_position = grid.to_vertex(grid.start.position)
	var goal_position = grid.to_vertex(grid.goal.position)
	if grid.is_cell_valid(start_position) and grid.is_cell_valid(goal_position):
		algorithm.find_path_debug(grid, start_position, goal_position)
func pause():
	pass
func stop():
	grid.clear()
	pass
func previous_step():
	pass
func next_step():
	if grid.is_cell_valid(start_position) and grid.is_cell_valid(goal_position):
		bfs.find_path_debug(grid, start_position, goal_position, true)



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
		
			
