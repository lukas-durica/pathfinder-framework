extends Node2D

class_name GridBasedUI

# use gui zoom factor for adjusting the camera zoom with respect to GUI to avoid
# overlap with the grid, just cosmetic treatment
const GUI_ZOOM_FACTOR : = 1.13

const START_SCENE = preload("res://src/tools/Start.tscn")
const GOAL_SCENE = preload("res://src/tools/Goal.tscn")
const AGENT_SCENE = preload("res://src/tools/Agent.tscn")

# the pathfinding algorithm 
var algorithm : GridBasedAlgorithm

# array that holds anonymous  start position and goal position of the agent(s)
# and references to their visible counterparts (i.e. sprites)
# inserting is as follow: starts_and_goals.push_back({start = Vector2(x,y)
# goal = Vector2(x, y), start_sprite = sprite0, goal_sprite = sprite1})
var starts_and_goals : = []

# variable that holds where was left mouse button pressed down 
var line_start : = Vector2.INF

# line_start to the line_end defines the line as well as start and end of the 
# agent
var line_end : = Vector2.INF
# camera is used for moving (pressing mouse wheel) and zooming (
# scrolling mouse wheel) on the grid
onready var camera : BasicCamera = $Camera

# the playground
onready var grid : Grid = $Grid

# reference to user interface 
onready var user_interface = $UserInterface

# for setting from the editor
# x -> start.x
# y -> start.y
# z -> goal.x
# w -> goal.y
export(Array, Quat) var editor_starts_goals 

# Called when the node enters the scene tree for the first time.
func _ready():
	#adjusting the camera zoom to the size of the grid
	adjust_camera_to_grid()
	
	# set algorithm and update menu in gui
	set_algorithm(Algorithm.CONFLICT_BASED_SEARCH, true)
	
	for sg in editor_starts_goals:
		add_start_and_goal(Vector2(sg.x, sg.y), Vector2(sg.z, sg.w))
	
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
		
		# get mouse position to the grid (vertex) position
		var clicked_vertex = get_mouse_vertex()
		var index = find_start_or_goal(clicked_vertex)
		# if the cell is free, it can be assigned as start/goal if not return
		if event.pressed:
			if event.button_index == BUTTON_LEFT \
					and grid.is_cell_free(clicked_vertex) \
					and index == -1:
						if line_start == Vector2.INF:
							line_start = clicked_vertex
						elif line_start != clicked_vertex:
							add_start_and_goal(line_start, clicked_vertex)
							line_start = Vector2.INF
							line_end = Vector2.INF
							update()
			elif event.button_index == BUTTON_RIGHT:
				if line_start != Vector2.INF:
					line_start = Vector2.INF
					line_end = Vector2.INF
				elif index != -1:
					starts_and_goals[index].start_sprite.queue_free()
					starts_and_goals[index].goal_sprite.queue_free()
					starts_and_goals.remove(index)
				update()
			
	
	elif event is InputEventMouseMotion:
		user_interface.set_coords(get_mouse_vertex())
		if line_start != Vector2.INF:
			line_end = get_mouse_vertex()
			update()

func _draw():
	if line_start != Vector2.INF:
		draw_line(grid.to_world(line_start), grid.to_world(line_end), 
				ColorN("greenyellow"), 5.0)
	for sag in starts_and_goals:
		 draw_line(grid.to_world(sag.start), grid.to_world(sag.goal),
				ColorN("greenyellow"), 5.0)


func add_start_and_goal(start_vertex : Vector2, goal_vertex : Vector2):
	var start_scene = START_SCENE.instance()
	var goal_scene = GOAL_SCENE.instance()
	start_scene.position = grid.to_world(start_vertex)
	goal_scene.position = grid.to_world(goal_vertex)
	add_child(start_scene)
	add_child(goal_scene)
	starts_and_goals.push_back({start = start_vertex, goal = goal_vertex, 
			start_sprite = start_scene, goal_sprite = goal_scene})

# returns opposite index of and item in the starts_and_goal
# if item doesnt exists it returns -1
func find_start_or_goal(vertex) -> int:
	for index in starts_and_goals.size():
		if starts_and_goals[index].start == vertex \
				or starts_and_goals[index].goal == vertex:
			return index
	return -1
	
		


func run():
	# reset all cells to default (e.g. path cells to free)
	grid.reset()
	
	# convert global positions to the grid (vertex) position
	# start measuring time
	var time_start = OS.get_ticks_usec()
	
	
	
	if starts_and_goals.empty():
		push_error("There are no starts and goals!")
		return
	
	# if it is single agent algorithm it will take only first pair of start and
	# goal
	
	# find the path
	
	var paths = algorithm.find_solution(starts_and_goals)
		
	# print elapsed time
	print("Elapsed time: ", OS.get_ticks_usec() - time_start, " microseconds")

	
	if not paths.empty():
		# if there is only one path from single agent algorithm
		if paths[0] is Vector2:
			
			for vertex in paths:
				grid.set_cellv(vertex, Grid.PATH)
			add_agent(paths)
			
		# if there are multiple paths from multi agent algorithm
		elif paths[0] is Array:
			for path in paths:
				for vertex in path:
					grid.set_cellv(Vector2(vertex.x, vertex.y), Grid.PATH)
				add_agent(path)
	# color the path
	
		
func add_agent(path):
	var agent = AGENT_SCENE.instance()
	add_child(agent)
	agent.grid = grid
	agent.path = path
	
	
	
		
		
		
# returns global mouse position converted to grid/vertex position
func get_mouse_vertex():
	return grid.to_vertex(get_global_mouse_position())


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
		Algorithm.CONFLICT_BASED_SEARCH:
			algorithm = CBS.new()
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


			
			
			
