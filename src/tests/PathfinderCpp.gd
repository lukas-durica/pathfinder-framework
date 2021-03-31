extends Node2D

var pathfinder : = AASippTesterCpp.new()
var width : = 0
var height : = 0

onready var grid : = $Grid

export(String, FILE) var map_path

func load_test_map():
	grid.clear()
	var file = File.new()
	if not file.file_exists(map_path):
		push_error("File does not exists!")
		return
	if not map_path.get_extension() == "txt":
		push_error("File extenstion is not valid!")
		return
	file.open(map_path, File.READ)
	width =  file.get_line().to_int()
	height = file.get_line().to_int()
	print("size: ", width, "x", height)
	#var starting_point : = Vector2(-width/2, -height/2)
	var starting_point : = Vector2.ZERO
	var vertex : = starting_point
	while not file.eof_reached():
		for ch in file.get_line():
			var is_character_valid : = true
			match ch:
				" ":
					# cant use continue in match to start the loop again
					is_character_valid = false
				"-1":
			
					grid.set_cellv(vertex, -1)
				"0":
			
					grid.set_cellv(vertex, Grid.FREE)
				"1":
			
					grid.set_cellv(vertex, Grid.OBSTACLE)
			
			if is_character_valid:
				vertex.x += 1
		vertex.x = starting_point.x
		vertex.y += 1
	file.close()
	#return content

# Called when the node enters the scene tree for the first time.
func _ready():
	load_test_map()
	pathfinder.find_solution(width, height, grid.get_used_cells_by_id(
			Grid.OBSTACLE))


