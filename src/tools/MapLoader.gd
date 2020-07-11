extends Reference

class_name MapLoader

static func load_map(grid : Grid):
	grid.clear()
	var file = File.new()
	file.open("res://data/maps/lak304d.map", File.READ)
	print("type: ", file.get_line())
	print("height: ", file.get_line())
	print("width: ", file.get_line())
	print("map: ", file.get_line())
	var vertex : = Vector2.ZERO
	while not file.eof_reached():
		for ch in file.get_line():
			
			match ch:
				"@":
					print("@")
					grid.set_cellv(vertex, -1)
				"T":
					print("T") 
					grid.set_cellv(vertex, Grid.OBSTACLE)
				".":
					print(".")
					grid.set_cellv(vertex, Grid.FREE)
			vertex.x += 1
			
		vertex.x = 0
		vertex.y += 1
		print(vertex)
	

	file.close()
	#return content
	
