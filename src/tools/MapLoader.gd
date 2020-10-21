#tool

extends Node2D

class_name MapLoader

func _ready():
	pass
	#grid.clear()
	#load_map()

static func load_map(grid, map_path):
	grid.clear()
	var file = File.new()
	if not file.file_exists(map_path):
		push_error("File does not exists!")
		return
	if not map_path.get_extension() == "map":
		push_error("File extenstion is not valid!")
		return
	file.open(map_path, File.READ)
	print("type: ", file.get_line())
	var height = file.get_line().to_int()
	var width =  file.get_line().to_int()
	print("map: ", file.get_line())
	print("size: ", width, "x", height)
	var starting_point : = Vector2(-width/2, -height/2)
	
	var vertex = starting_point
	while not file.eof_reached():
		for ch in file.get_line():
			match ch:
				"@":
					grid.set_cellv(vertex, -1)
				"T":
					grid.set_cellv(vertex, Grid.OBSTACLE)
				".":
					grid.set_cellv(vertex, Grid.FREE)
			vertex.x += 1
		vertex.x = starting_point.x
		vertex.y += 1
	file.close()
	#return content
	
