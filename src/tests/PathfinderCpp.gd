extends Node2D
const AGENT_SCENE : = preload("res://src/tools/agents/AgentPathfinder.tscn")
var pathfinder : = AASippTesterCpp.new()
var width : = 0
var height : = 0

onready var grid : = $Grid
onready var map_loader : = $SIPPMapLoader

export(String, FILE) var map_path


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#map_loader.load_test_map(map_path, grid)
	#var task = ASIPPTask.create_task()
	#var solution = pathfinder.find_solution(map_loader.width, map_loader.height, 
	#		grid.get_used_cells_by_id(Grid.OBSTACLE), task)
	
	#for id in range(solution.size()):
	var agent : AgentPathfinder = AGENT_SCENE.instance()
	agent.grid = grid
	$Agents.add_child(agent)
	
