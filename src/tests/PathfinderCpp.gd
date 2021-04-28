extends Node2D

const AGENT_SCENE : = preload("res://src/tools/agents/AgentPathfinder.tscn")
const GOAL_SCENE : = preload("res://src/tools/grid_based_ui/Goal.tscn")

var pathfinder : = AASippTesterCpp.new()

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

var selected_agent : AgentPathfinder = null

onready var grid : = $Grid
onready var camera : = $Camera
onready var map_loader : = $SIPPMapLoader
onready var asipp_task : = $ASIPPTask
onready var user_interface : = $UserInterface

export(String, FILE) var map_path


# Called when the node enters the scene tree for the first time.
func _ready():
	adjust_camera_to_grid()

func _draw():
	if selected_agent:
		draw_line(grid.to_world(grid.to_vertex(selected_agent.global_position)),
				grid.to_world(line_end), ColorN("greenyellow"), 5.0)
	for sag in starts_and_goals:
		 draw_line(grid.to_world(sag.start), grid.to_world(sag.goal),
				ColorN("greenyellow"), 5.0)

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
						if not selected_agent:
							selected_agent = find_agent(clicked_vertex)
							print("agent selected: ", selected_agent)
						elif selected_agent and grid.to_vertex(
								selected_agent.global_position) != clicked_vertex:
							add_agent_and_goal(selected_agent, clicked_vertex)
							selected_agent = null
							line_end = Vector2.INF
							update()
			# clear with right button started line
			elif event.button_index == BUTTON_RIGHT:
				if line_start != Vector2.INF:
					line_start = Vector2.INF
					line_end = Vector2.INF
				# if line exists delete it
				elif index != -1:
					#starts_and_goals[index].start_sprite.queue_free()
					starts_and_goals[index].goal_sprite.queue_free()
					starts_and_goals.remove(index)
				update()
			
	# update coords in UI with every mouse motion
	elif event is InputEventMouseMotion:
		user_interface.set_coords(get_mouse_vertex())
		# if line is drawn update it 
		if selected_agent:
			line_end = get_mouse_vertex()
			update()

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
	#camera.zoom_factor *= GUI_ZOOM_FACTOR
	
	#zoom camera to the zoom_ration
	camera.zoom(0)
	
	#set camera position to the center of the grid
	camera.position = (grid.get_used_rect().position + 
			grid.get_used_rect().size / 2.0) * grid.cell_size

func get_mouse_vertex():
	return grid.to_vertex(get_global_mouse_position())

func find_start_or_goal(vertex : Vector2) -> int:
	for index in starts_and_goals.size():
		if starts_and_goals[index].start == vertex \
				or starts_and_goals[index].goal == vertex:
			return index
	return -1

func find_agent(vertex : Vector2) -> AgentPathfinder:
	for agent in $Agents.get_children():
		if vertex == grid.to_vertex(agent.global_position):
			return agent
	return null

func add_agent_and_goal(agent : AgentPathfinder, goal_vertex : Vector2):
	var goal_scene = GOAL_SCENE.instance()
	goal_scene.position = grid.to_world(goal_vertex)
	add_child(goal_scene)
	starts_and_goals.push_back({start = grid.to_vertex(agent.global_position), 
			goal = goal_vertex, agent = agent, goal_sprite = goal_scene})





func init():

	var width = grid.get_used_rect().size.x
	var height = grid.get_used_rect().size.y
	var obstacles = grid.get_used_cells_by_id(Grid.OBSTACLE)
	var task = asipp_task.create_task()
	var solution = pathfinder.find_solution(width, height, obstacles, task)

	for id in range(solution.size()):
	
		var agent : AgentPathfinder = AGENT_SCENE.instance()
		#agent.path = AgentPathfinder.create_test_path()
		agent.path = solution[id]
		agent.size = asipp_task.get_parameter(id, ASIPPTask.SIZE)
		agent.movement_speed = asipp_task.get_parameter(
				id, ASIPPTask.MOVEMENT_SPEED)
		agent.rotation_speed = asipp_task.get_parameter(
				id, ASIPPTask.ROTATION_SPEED)
	
		$Agents.add_child(agent)

func _input(event):
	if event.is_action_pressed("ui_select"):
		init()
