extends Node2D

class_name GraphBasedUI

# use gui zoom factor for adjusting the camera zoom with respect to GUI to avoid
# overlap with the start position of the grid, just cosmetic treatment
const GUI_ZOOM_FACTOR : = 1.13

const START_SCENE = preload("res://src/tools/grid_based_ui/Start.tscn")
const GOAL_SCENE = preload("res://src/tools/grid_based_ui/Goal.tscn")
const AGENT_SCENE = preload("res://src/tools/agents/AgentGraph.tscn")

# the pathfinding algorithm 
var algorithm


onready var camera : BasicCamera = $Camera

# the playground
onready var graph = $Graph

# reference to user interface 
onready var user_interface = $UserInterface

onready var start : = $Start

onready var goal : = $Goal

# for setting from the editor
# x -> start.x
# y -> start.y
# z -> goal.x
# w -> goal.y

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for path in graph.node_paths.get_children():
		path = path as ConnectablePath
		path.connect("area_was_clicked", self, "area_was_clicked")

	#set_algorithm(default_algorithm, true)
	
	
# button type is BUTTON_LEFT or BUTTON_RIGHT
func area_was_clicked(area : PointArea, button_type : int):
	
	var target : Node2D = area if not area.connection else area.connection
	var border : Node2D = start if button_type == BUTTON_LEFT else goal

	border.global_transform.origin = target.global_transform.origin
	border.set_meta("target", target)
	border.visible = true

# run the pathfinder
func run():
	
	if not start.has_meta("target") or not start.get_meta("target"):
		push_error("Start has no target!")
		return
	var target = start.get_meta("target")
	var path : Path2D
	if target is PointArea:
		path = target.path
	elif target is Connection:
		path = target.connected_paths[0]
		
	var agent = AGENT_SCENE.instance()
	$Agents.add_child(agent)
	agent.align_to_path(path, start.global_position)
	
	
	
	# reset all cells to default (e.g. path cells to free)
	
	
	
	# convert global positions to the grid (vertex) position
	# start measuring time
	
	
	#var start = Vector3(5, -5, 0)
	#var goal = Vector3(5, 5,0 )
	#if starts_and_goals.empty():
	#var time_start = OS.get_ticks_usec()
	#var paths = algorithm.find_solution(starts_and_goals)
	
	#if paths.empty():
	#	print("Path was not found")
	#	return
	
	#print("Elapsed time: {0}, size: {1}".format(
	#			[OS.get_ticks_usec() - time_start, paths.size()])) 
	# if there is only one path from single agent algorithm
	
	
	
#	if not paths[0] is Array:
#
#		for vertex in paths:
#			graph.set_cellv(Vector2(vertex.x, vertex.y), Grid.PATH)
#		add_agent(paths)
#
#		# if there are multiple paths from multi agent algorithm
#	elif paths[0] is Array:
#		for path in paths:
#			for vertex in path:
#				graph.set_cellv(Vector2(vertex.x, vertex.y), Grid.PATH)
#			if not path.empty(): 
#				add_agent(path)
#		$Timer.start()
	
	
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
	agent.graph = graph
	agent.path = path
	
func remove_agents():
	if has_node("Agents"):
		for agent in $Agents.get_children():
			agent.queue_free()
		
# returns global mouse position converted to grid/vertex position
func get_mouse_vertex():
	return graph.to_vertex(get_global_mouse_position())


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
		graph.is_8_directional = not graph.is_8_directional
		var start_time = OS.get_ticks_usec()
		algorithm.initialize(graph)
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
	algorithm.initialize(graph)
	print("Grid Initialized: {0} microseconds".format(
				[OS.get_ticks_usec() - start_time]))
			
			


func _on_Timer_timeout():
	if algorithm.has_method("update_actual_time_step"):
		algorithm.update_actual_time_step()
