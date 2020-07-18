extends Reference

class_name MapLoader

static func load_map(grid : Grid):
	grid.clear()
	var file = File.new()
	file.open("res://data/maps/lak304d.map", File.READ)
	print("type: ", file.get_line())
	var height = file.get_line().to_int()
	var width =  file.get_line().to_int()
	print("map: ", file.get_line())
	var starting_point : = Vector2(-width/2, -height/2)
	print("starting_point: ", starting_point)
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
	
