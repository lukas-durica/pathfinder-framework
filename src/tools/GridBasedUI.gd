extends Node2D

class_name GridBasedUI

# use gui zoom factor for adjusting the camera zoom with respect to GUI to avoid
# overlap with the grid, just cosmetic treatment
const GUI_ZOOM_FACTOR : = 1.13

const START_SCENE = preload("res://src/tools/Start.tscn")
const GOAL_SCENE = preload("res://src/tools/Goal.tscn")
const AGENT_SCENE = preload("res://src/tools/Agent.tscn")

# the pathfinding algorithm 
var algorithm

# left mouse button down
var lmb_down : = false

# array dictionary that holds start position and goal position of the agent(s)
var starts_and_goals : = {}

# variable that holds where was left mouse button pressed down (lmb_down)
# when user release the button on the other position the goal of the agent
# is designed and together with last_start are added to starts_and_goals
var last_start : = Vector2.INF

# when left mouse button is pressed down the line will be drawn from the 
# last_start to the line_end defined by mouse position
var line_end : = Vector2.INF
# camera is used for moving (pressing mouse wheel) and zooming (
# scrolling mouse wheel) on the grid
onready var camera : BasicCamera = $Camera

# the playground
onready var grid : Grid = $Grid

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
	# if the any mouse button is pressed
	if event is InputEventMouseButton:
		var cell_pos = grid.to_vertex(get_global_mouse_position())
		if event.pressed:
			# get mouse position to the grid (vertex) position
			
			
			# if the cell is free, it can be assigned as start/goal
			if grid.is_cell_free(cell_pos):
				if event.button_index == BUTTON_LEFT:
					
					# continue only if there are no already starts or goals at 
					# this vertex
					if not is_start_or_goal(cell_pos):
						last_start = grid.to_world(cell_pos)
						lmb_down = true
					
					
				elif event.button_index == BUTTON_RIGHT:
					# if clicked vertex is start, delete it with the goal
					if cell_pos in starts_and_goals:
						pass
					lmb_down = false
					
		# else if the any mouse button is released
		else:
			if grid.is_cell_free(cell_pos):
				if event.button_index == BUTTON_LEFT:
					if not is_start_or_goal(cell_pos):
						var start = START_SCENE.instance()
						var goal = GOAL_SCENE.instance()
						start.position = grid.to_world(last_start)
						goal.position = grid.to_world(cell_pos)
						add_child(start)
						add_child(goal)
						starts_and_goals[last_start] = cell_pos
					
			lmb_down = false
			last_start = Vector2.INF
			
	
	elif event is InputEventMouseMotion:
		user_interface.set_coords(grid.to_vertex(get_global_mouse_position()))
		if lmb_down:
			

func _process(delta):
	if lmb_down:
		pass



func _draw():
	draw_line(last_start, 

func is_start_or_goal(vertex):
	if not vertex in starts_and_goals:
		for goal in starts_and_goals.values():
			if goal == vertex:
				return true
		return false
	return true


func run():
	# reset all cells to default (e.g. path cells to free)
	grid.reset()
	
	# convert global positions to the grid (vertex) position
	# start measuring time
	var time_start = OS.get_ticks_usec()
	
	var paths : = []
	
	if algorithm is SigleAgentGridBasedAlgorithm:
		if starts_and_goals.size() > 1:
			push_warning("Multiple paths were detected for single agent" + \
					"algorithm! Finding path only for the first start and goal!")
		var start = starts_and_goals.keys()[0]
		var goal = starts_and_goals[start]
		
		paths.push_back(algorithm.find_path(start, goal))
		
		
		
	# find the path
	 
	
	# print elapsed time
	print("Elapsed time: ", OS.get_ticks_usec() - time_start, 
			" microseconds")
	#print("Path size: ", path.size())
		
	# color the path
	for path in paths:
		for vertex in path:
			grid.set_cellv(vertex, Grid.PATH)
	
	for path in paths:
		var agent = AGENT_SCENE.instance()
		

	


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


			
			
			
