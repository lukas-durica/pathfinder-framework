tool

extends EditorPlugin

const CONNECTION_SCENE = preload("res://addons/path_manager/Connection.tscn")

var editor_selection : = get_editor_interface().get_selection()

var edited_path : ConnectablePath = null
var area_entered_data : = {}

var start_dragging_position : = Vector2.INF

var is_left_mouse_button_pressed : = false
var is_dragging : = false

func get_root() -> Node:
	return get_tree().get_edited_scene_root()

func _enter_tree():
	print("---===EditorPlugin enabled===---")
	
	add_custom_type("ConnectablePath", "Path2D", 
			preload("ConnectablePath.gd"),
			preload("res://addons/path_manager/Path2D.svg"))
	
	Physics2DServer.set_active(true)
	
	editor_selection.connect("selection_changed", self, "_on_selection_changed")


	

func _input(event):
	if not edited_path:
		return
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			is_left_mouse_button_pressed = true
		else:
			is_left_mouse_button_pressed = false
			is_dragging = false
			start_dragging_position = Vector2.INF
			if not area_entered_data.empty():
				create_connection()
			else:
				edited_path.alling_border_points_with_connection()
	
	if event is InputEventMouseMotion:
		if is_left_mouse_button_pressed:
			if start_dragging_position == Vector2.INF:
				start_dragging_position = event.position
			elif start_dragging_position != event.position and not is_dragging:
				is_dragging = true
			

func _exit_tree():
	remove_custom_type("ConnectablePath")
	print("---===EditorPlugin disabled===---")

# chceck the type of the object, if it will return true the edit(object) is 
# called
func handles(object : Object) -> bool:
	
	#if the object is the same object as edited path change nothing
	if edited_path:
		if object == edited_path:
			return false
		else:
			deselect_edited_path()
	return object is ConnectablePath

func edit(object : Object):
	select_edited_path(object)

func _on_selection_changed():
	#print(name, ": Selection changed")
	#print("selected objects: ")
	#for node in editor_selection.get_selected_nodes():
	#	print(node.name)
	# if unclicked the edited path
	if edited_path and editor_selection.get_selected_nodes().empty():
		deselect_edited_path()


func select_edited_path(object):
	#print(name, ": Editing new path, connecting signals to: ", object.name)
	object.connect("point_area_entered", self, "point_area_entered")
	object.connect("point_area_exited", self, "point_area_exited")
	object.color_passable_connections(true)
	edited_path = object

func deselect_edited_path():
	#print(name, ": Edited path is no longer selected, disconnecting signals", \
	#		" from: ", edited_path.name)
	edited_path.disconnect("point_area_entered", self, "point_area_entered")
	edited_path.disconnect("point_area_exited", self, "point_area_exited")
	edited_path.color_passable_connections(false)
	edited_path = null


func create_connection():
	#print(name, ": Create connection")
	var area = area_entered_data.area
	var area_entered_to = area_entered_data.area_entered_to
	area.global_transform.origin = area_entered_to.global_transform.origin
	var path = area.path
	
	
	if not area_entered_to.connection:
		
		if not get_root():
			push_error("There is no root, please open scene!")
			return
			
		var parent = path.get_parent()
		# if its parents exist and its not already root of the scene
		# root can be only one
		if parent.get_parent() and parent != get_root():
			parent = parent.get_parent()
		
		if not parent.find_node("Connections"):
			create_node_connections(parent)
		
		var con = add_new_connection(area_entered_to.global_transform.origin)
		con.add_to_connection(area)
		con.add_to_connection(area_entered_to)
		
	else:
		var connection = area_entered_to.connection
		connection.add_to_connection(area)

	edited_path.color_passable_connections(true)
	area_entered_data.clear()

func add_new_connection(position : Vector2) -> Node2D:
	#print(name, ": Add new connection")
	var new_conn = CONNECTION_SCENE.instance()
	var connections = get_root().find_node("Connections")
	
	connections.add_child(new_conn)
	new_conn.owner = get_root()
	new_conn.global_transform.origin = position
	return new_conn
	

func create_node_connections(parent):
	#print(name, ": Creating Connections node")
	var new_connections = Node2D.new()
	new_connections.name = "Connections"
	parent.add_child(new_connections)
	new_connections.owner = get_root()

func point_area_entered(area : PointArea, area_entered_to : PointArea):
	print(name, ": point_area_entered")
	if area.path == edited_path and is_dragging:
		print(name, ": ", edited_path.name, " is edited path, creating ",\
		"area_entered_data")
		area_entered_data = {area = area, area_entered_to = area_entered_to}

func point_area_exited(area : PointArea, area_exited_from : PointArea):
	print("is dragging: ", is_dragging)
	if area.connection and area.path == edited_path and is_dragging:
			print(name, ": ", edited_path.name, ": This is edited path, ",\
			"area exiting")
			# user just entered and exited the area point without releasing it
			# thus not making connection
			if not area_entered_data.empty():
				print(name, ": Clearing area_entered_data ")
				area_entered_data.clear()
				return
			# user exited the area with already existed connection
			
			# if there is connection remove it
			var connection = area.connection
			edited_path.color_passable_connections(false)
			connection.remove_from_connection(area)
			edited_path.color_passable_connections(true)
	elif area.path == edited_path and not area_entered_data.empty():
		print(name, ": Clearing area_entered_data ")
		area_entered_data.clear()
	
