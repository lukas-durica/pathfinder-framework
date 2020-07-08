extends Node2D

const GUI_FACTOR = 1.13

onready var camera = $Camera

onready var grid = $Grid

# Called when the node enters the scene tree for the first time.
func _ready():
	adjust_screen_to_grid()
	#User interface is invisible due to work with the grid in the editor
	$CanvasLayer/UI.visible = true
	
	
	var goal_position = grid.to_vertex(grid.goal.position)
	var start_position = grid.to_vertex(grid.start.position)
	
	var bfs = BreadthFirstSearch.new()
	var time_start = OS.get_ticks_usec()
	
	bfs.find_path_debug(grid, start_position, goal_position)
	var elapsed = OS.get_ticks_usec() - time_start
	print("elapsed time: ", elapsed / 1000000.0)
	grid.reset()
	
	time_start = OS.get_ticks_usec()
	BreadthFirstSearch.find_path(grid, grid.world_to_map(
			grid.start.position), grid.world_to_map(grid.goal.position))
	elapsed = OS.get_ticks_usec() - time_start
	print("elapsed time: ", elapsed / 1000000.0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func adjust_screen_to_grid():
	
	# setting camera reference to grid, it uses camera.zoom ratio
	grid.camera = camera
	
	# the size of the screen
	var screen_size : = get_viewport().get_visible_rect().size
	
	
	#print("rect size: ", $VBoxContainer.rect_size * $VBoxContainer.rect_scale)
	
	# size of the rectangle enclosing the used (non-empty) tiles of the map and
	# size of the scaled gui 
	print("position: ", grid.get_used_rect().position)
	var rect_size = grid.get_used_rect().size * grid.cell_size 
	
	
	# computing the ratio vector of the screen size and rectangle size
	var ratio_vec =  rect_size / screen_size
	 
	# getting the greater ratio size
	#camera.zoom_ratio = max(ratio_vec.x, ratio_vec.y)
	
	#adjusting zoom_ratio in respect to gui
	#camera.zoom_ratio *= GUI_FACTOR
	
	#zoom camera to ration factior	
	#camera.zoom(0)
	
	#set camera position to he center of the grid
	camera.position = (grid.get_used_rect().position + 
			grid.get_used_rect().size / 2.0) * grid.cell_size
	
	
	
	 
	
	#$UI.rect_scale *= zoom_ratio
	#print("camera position: ", $Camera2D.position.y)
	#print("textire position: ", $UI/HBoxContainer.rect_size.y * $UI/HBoxContainer.rect_scale.y * zoom_ratio)
	#$Camera2D.position.y += 100



#		#since the mouse position is also based on camera zoom we need to 
#		#adjust the position
#		var cell_pos = world_to_map(event.position * camera_zoom)
#		var cell = get_cellv(cell_pos)
#
#		if cell == FREE:
#			if event.button_index == BUTTON_LEFT:
#				start.position = map_to_world(cell_pos) + cell_size / 2.0
#			elif event.button_index == BUTTON_RIGHT:
#				goal.position = map_to_world(cell_pos) + cell_size / 2.0
#
