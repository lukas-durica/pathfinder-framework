extends Node2D

class_name GridBasedUI

# use gui zoom factor for adjusting the camera zoom with respect to GUI to avoid
# overlap with the start position of the grid, just cosmetic treatment
const GUI_ZOOM_FACTOR : = 1.13

const START_SCENE = preload("res://src/tools/grid_based_ui/Start.tscn")
const GOAL_SCENE = preload("res://src/tools/grid_based_ui/Goal.tscn")
const AGENT_SCENE = preload("res://src/tools/agents/AgentContinuous.tscn")

# the pathfinding algorithm 
var algorithm

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
onready var grid = $Grid

# reference to user interface 
onready var user_interface = $UserInterface

# for setting from the editor
# x -> start.x
# y -> start.y
# z -> goal.x
# w -> goal.y

export var load_path : = false
export(String, FILE) var map_path
export(Algorithm.Type) var default_algorithm = \
		Algorithm.Type.A_STAR_SPACE_TIME_CPP
export(Array, Quat) var editor_starts_goals 


# Called when the node enters the scene tree for the first time.
func _ready():
	#adjusting the camera zoom to the size of the grid
	adjust_camera_to_grid()
	if load_path:
		if not map_path.empty():
			MapLoader.load_map(grid, map_path)
		
	# set algorithm and update menu in gui
	set_algorithm(default_algorithm, true)
	
	for sg in editor_starts_goals:
		add_start_and_goal(Vector2(sg.x, sg.y), Vector2(sg.z, sg.w))
	
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
					and not grid.is_cell_obstacle(clicked_vertex) \
					and grid.is_cell_valid(clicked_vertex):
						if line_start == Vector2.INF:
							line_start = clicked_vertex
						elif line_start != clicked_vertex:
							add_start_and_goal(line_start, clicked_vertex)
							line_start = Vector2.INF
							line_end = Vector2.INF
							update()
			# clear with right button started line
			elif event.button_index == BUTTON_RIGHT:
				if line_start != Vector2.INF:
					line_start = Vector2.INF
					line_end = Vector2.INF
				# if line exists delete it
				elif index != -1:
					starts_and_goals[index].start_sprite.queue_free()
					starts_and_goals[index].goal_sprite.queue_free()
					starts_and_goals.remove(index)
				update()
			
	# update coords in UI with every mouse motion
	elif event is InputEventMouseMotion:
		user_interface.set_coords(get_mouse_vertex())
		# if line is drawn update it 
		if line_start != Vector2.INF:
			line_end = get_mouse_vertex()
			update()

# called through update()
func _draw():
	if line_start != Vector2.INF:
		draw_line(grid.to_world(line_start), grid.to_world(line_end), 
				ColorN("greenyellow"), 5.0)
	for sag in starts_and_goals:
		 draw_line(grid.to_world(sag.start), grid.to_world(sag.goal),
				ColorN("greenyellow"), 5.0)

# add start position and goal position to UI and to starts_and_goals
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

# run the pathfinder
func run():
	# reset all cells to default (e.g. path cells to free)
	if starts_and_goals.empty():
		push_error("No start defined!")
		return
	
	
	remove_agents()
	grid.reset()
	algorithm.clear()
	
	# convert global positions to the grid (vertex) position
	# start measuring time
	
	
	#var start = Vector3(5, -5, 0)
	#var goal = Vector3(5, 5,0 )
	#if starts_and_goals.empty():
	var time_start = OS.get_ticks_usec()
	var paths = algorithm.find_solution(starts_and_goals)
	
	if paths.empty():
		print("Path was not found")
		return
	
	print("Elapsed time: {0}, size: {1}".format(
				[OS.get_ticks_usec() - time_start, paths.size()])) 
	# if there is only one path from single agent algorithm
	
	
	
	if not paths[0] is Array:
		
		for vertex in paths:
			grid.set_cellv(Vector2(vertex.x, vertex.y), Grid.PATH)
		add_agent(paths)

		# if there are multiple paths from multi agent algorithm
	elif paths[0] is Array:
		for path in paths:
			for vertex in path:
				grid.set_cellv(Vector2(vertex.x, vertex.y), Grid.PATH)
			if not path.empty(): 
				add_agent(path)
		$Timer.start()
	
	
	#for vertex in path:
	#	if grid.is_cell_free(Vector2(vertex.x, vertex.y)):
	#		grid.set_cellv(Vector2(vertex.x, vertex.y), Grid.PATH)
	#	push_error("There are no starts and goals!")
	#	return
	
	# if it is single agent algorithm it will take only first pair of start and
	# goal
	
	
	
	
	# find the path
	#var paths = algorithm.find_solution(starts_and_goals)
		
	# print elapsed time
	

	
#	if not paths.empty():
#		
	# color the path
	
		
func add_agent(path):
	var agent = AGENT_SCENE.instance()
	$Agents.add_child(agent)
	agent.grid = grid
	agent.path = path
	
func remove_agents():
	if has_node("Agents"):
		for agent in $Agents.get_children():
			agent.queue_free()
		
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


	


func _on_UserInterface_algorithms_id_pressed(id):
	set_algorithm(id)


func _on_UserInterface_options_id_pressed(id):
	print(id)
	if id == 1:
		grid.is_8_directional = not grid.is_8_directional
		var start_time = OS.get_ticks_usec()
		algorithm.initialize(grid)
		print("Grid Initialized: {0} microseconds".format(
				[OS.get_ticks_usec() - start_time]))
# set algorithm and upstate UserInterface if needed (e.g. at the functio _ready)
# if the algorithm is set from the code (e.g. at the startup), user interface 
# need to be updated accordingly update_ui, if the user will change algorithm 
# using user interface was already changed

func set_algorithm(algorithm_enum_value, update_ui : = false):
	algorithm = Algorithm.get_algorithm(algorithm_enum_value)
			
	
	if update_ui:
		$UserInterface.check_algorithm_item(algorithm_enum_value)
		#$UserInterface.update_options(grid.is_8_directional)
	
	# initialize algorithm (e.g convert grid to Godot's Astar representation)
	# look into the AstarGodot.gd for more
	var start_time = OS.get_ticks_usec()
	algorithm.initialize(grid)
	print("Grid Initialized: {0} microseconds".format(
				[OS.get_ticks_usec() - start_time]))
			
			


func _on_Timer_timeout():
	if algorithm.has_method("update_actual_time_step"):
		algorithm.update_actual_time_step()