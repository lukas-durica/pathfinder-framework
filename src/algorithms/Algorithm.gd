extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var zoom_ratio : = 1.0 setget set_camera_zoom

# Called when the node enters the scene tree for the first time.
func _ready():
	adjust_screen_to_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func adjust_screen_to_grid():
	
	# the size of the screen
	var screen_size : = get_viewport().get_visible_rect().size
	
	
	#print("rect size: ", $VBoxContainer.rect_size * $VBoxContainer.rect_scale)
	
	# size of the rectangle enclosing the used (non-empty) tiles of the map and
	# size of the scaled gui 
	var rect_size = $Grid.get_used_rect().end * $Grid.cell_size
	
	
	# computing the ratio vector of the screen size and rectangle size
	var ratio_vec =  rect_size / screen_size
	print("ratio_vec: ",ratio_vec)
	
	# getting the smaller ratio size
	zoom_ratio = max(ratio_vec.x, ratio_vec.y)
	#var ratio_scale = max(ratio_vec.x, ratio_vec.y)
	
	
	# and applying it the scale of the tilemap and zooming sizes proportionally
	
	print("screen_size: ", screen_size)
	
	
	#scale *= ratio_scale
	$Camera2D.zoom *= zoom_ratio
	
	#$UI.rect_scale *= zoom_ratio
	#print("camera position: ", $Camera2D.position.y)
	#print("textire position: ", $UI/HBoxContainer.rect_size.y * $UI/HBoxContainer.rect_scale.y * zoom_ratio)
	#$Camera2D.position.y += 100

func _input(event : InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_in()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom_out()



func zoom_in():
	zoom_ratio -= 0.1
	print("zoom_ratio: ", zoom_ratio)
	$Camera2D.zoom = Vector2.ONE * zoom_ratio

func zoom_out():
	zoom_ratio += 0.1
	print("zoom_ratio: ", zoom_ratio)
	$Camera2D.zoom = Vector2.ONE * zoom_ratio

func set_camera_zoom(value):
	pass


#		#since the mouse position is also based on camera zoom we need to 
#		#adjust the position
#		var cell_pos = world_to_map(event.position * camera_zoom)
#		var cell = get_cellv(cell_pos)
#
#		if cell == FREE:
#			if event.button_index == BUTTON_LEFT:
#				start.position = map_to_world(cell_pos) + cell_size / 2.0
#			elif event.button_index == BUTTON_RIGHT:
#				goal.position = map_to_world(cell_pos) + cell_size / 2.0
#
