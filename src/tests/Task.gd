class_name ASIPPTask extends Node2D

var test_task : = {}

# Default parameters
enum {DEFAULT_PARAMETERS = -1, START, GOAL, SIZE, MOVEMENT_SPEED, 
		ROTATION_SPEED, START_HEADING, GOAL_HEADING}

func _ready():
	test_task = create_task()

func get_task() -> Dictionary:
	return test_task

func get_parameter(agent_id : int, parameter_type : int):
	return test_task[agent_id][parameter_type] \
			if test_task[agent_id].has(parameter_type) \
			else test_task[DEFAULT_PARAMETERS][parameter_type]

static func create_task() -> Dictionary:
	var task : = {}
	
	task[DEFAULT_PARAMETERS] = {}
	task[DEFAULT_PARAMETERS][SIZE] = 0.4
	task[DEFAULT_PARAMETERS][MOVEMENT_SPEED] = 0.25
	task[DEFAULT_PARAMETERS][ROTATION_SPEED] = 0.2
	task[DEFAULT_PARAMETERS][START_HEADING] = 180
	task[DEFAULT_PARAMETERS][GOAL_HEADING] = 90
	
	# Agent with id 0
	task[0] = {}
	task[0][START] = Vector2(7, 35)
	task[0][GOAL] = Vector2(0, 12)
	task[0][SIZE] = 0.5
	
	task[1] = {}
	task[1][START] = Vector2(0, 30)
	task[1][GOAL] = Vector2(28, 20)
	task[1][GOAL_HEADING] = 0
	
	task[2] = {}
	task[2][START] = Vector2(13, 43)
	task[2][GOAL] = Vector2(68, 36)
	task[2][START_HEADING] = 40
	task[2][GOAL_HEADING] = 40
	
	task[3] = {}
	task[3][START] = Vector2(28, 1)
	task[3][GOAL] = Vector2(11, 38)
	task[3][MOVEMENT_SPEED] = 3.0
	task[3][ROTATION_SPEED] = 2.0
	
	task[4] = {}
	task[4][START] = Vector2(53, 9)
	task[4][GOAL] = Vector2(12, 45)
	
	task[5] = {}
	task[5][START] = Vector2(37, 37)
	task[5][GOAL] = Vector2(39, 11)
	
	task[6] = {}
	task[6][START] = Vector2(53, 40)
	task[6][GOAL] = Vector2(65, 43)
	
	return task
	
