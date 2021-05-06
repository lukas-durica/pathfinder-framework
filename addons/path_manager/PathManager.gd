tool

extends EditorPlugin

const CONNECTION_SCENE = preload("res://addons/path_manager/Connection.tscn")

var editor_selection : = get_editor_interface().get_selection()

var edited_path : ConnectablePath = null

var point_area_entered_data : = {}
#var path_area_entered_data : = {}

var is_left_mouse_button_pressed : = false

func _enter_tree():
	print("---===PathManager enabled===---")
	
	Physics2DServer.set_active(true)
	
	add_custom_type("ConnectablePath", "Path2D", 
			preload("ConnectablePath.gd"),
			preload("res://addons/path_manager/Path2D.svg"))

	editor_selection.connect("selection_changed", self, "_on_selection_changed")

func _input(event):
	if not edited_path:
		return
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			is_left_mouse_button_pressed = true
		else:
			is_left_mouse_button_pressed = false
			if not point_area_entered_data.empty():
				create_connection()
			#elif not path_area_entered_data.empty():
			#	create_connection_to_path()
			call_deferred("alling_border_points")

func _exit_tree():
	editor_selection.disconnect("selection_changed", self, 
			"_on_selection_changed")
			
	remove_custom_type("ConnectablePath")
	
	Physics2DServer.set_active(false)
	
	print("---===PathManager disabled===---")

func get_root() -> Node:
	return get_tree().get_edited_scene_root()

# use deferred
func alling_border_points():
	if edited_path:
		edited_path.alling_border_points_with_connection()

# chceck the type of the object, if it will return true the edit(object) is 
# called
func handles(object : Object) -> bool:
	
	#if the object is the same object as edited path change nothing
	if edited_path:
		deselect_edited_path()
	return object is ConnectablePath

func edit(object : Object):
	select_edited_path(object)

func _on_selection_changed():
	
	# if unclicked the edited path deselect edited_path
	if edited_path and editor_selection.get_selected_nodes().empty():
		deselect_edited_path()


func select_edited_path(object):
	#print(name, ": Editing new path, connecting signals to: ", object.name)
	object.connect("point_area_entered", self, "point_area_entered")
	object.connect("point_area_exited", self, "point_area_exited")
	#object.connect("path_area_entered", self, "path_area_entered")
	#object.connect("path_area_exited", self, "path_area_exited")
	object.color_passable_connections(true)
	edited_path = object

func deselect_edited_path():
	#print(name, ": Edited path is no longer selected, disconnecting signals", \
	#		" from: ", edited_path.name)
	edited_path.disconnect("point_area_entered", self, "point_area_entered")
	edited_path.disconnect("point_area_exited", self, "point_area_exited")
	#edited_path.disconnect("path_area_entered", self, "path_area_entered")
	#edited_path.disconnect("path_area_exited", self, "path_area_exited")
	edited_path.color_passable_connections(false)
	edited_path = null

func create_connection():
	#print(name, ": Create connection")
	var area = point_area_entered_data.area
	var area_entered_to = point_area_entered_data.area_entered_to
	
	#is this neccessary?
	
	if not area_entered_to.is_connection_valid():
		if not get_root():
			push_error("There is no root, please open scene!")
			return

		var parent = area.path.get_parent()
		# if its parents exist and its not already root of the scene
		# root can be only one
		if parent.get_parent() and parent != get_root():
			parent = parent.get_parent()
		
		if not parent.find_node("Connections"):
			create_node_connections(parent)
		
		var con = add_new_connection(area_entered_to.global_position)
		con.add_to_connection(area)
		con.add_to_connection(area_entered_to)
		
	else:
		var connection = area_entered_to.connection
		connection.add_to_connection(area)

	edited_path.color_passable_connections(true)
	point_area_entered_data.clear()

func add_new_connection(position : Vector2) -> Node2D:
	#print(name, ": Add new connection")
	var new_conn = CONNECTION_SCENE.instance()
	var connections = get_root().find_node("Connections")
	
	connections.add_child(new_conn)
	new_conn.owner = get_root()
	new_conn.global_position = position
	return new_conn

func create_node_connections(parent):
	#print(name, ": Creating Connections node")
	var new_connections = Node2D.new()
	new_connections.name = "Connections"
	parent.add_child(new_connections)
	new_connections.owner = get_root()

func point_area_entered(area : PointArea, area_entered_to : PointArea):
	if area.path == edited_path:
		point_area_entered_data = {area = area, 
				area_entered_to = area_entered_to}

func point_area_exited(area : PointArea, area_exited_from : PointArea):
	if not area.path == edited_path:
		return

	if area.is_connection_valid():
		# user just entered and exited the area point without releasing it
		# thus not making the connection
		if not point_area_entered_data.empty():
			point_area_entered_data.clear()
			return
		# user exited the area with already existed connection
		
		# if there is connection remove it
		var connection = area.connection
		edited_path.color_passable_connections(false)
		connection.remove_from_connection(area)
		edited_path.color_passable_connections(true)
	
	elif not point_area_entered_data.empty():
		point_area_entered_data.clear()

#func path_area_entered(area : PointArea, path_area : PathArea):
#	if area.path == edited_path:
#		path_area_entered_data = {area = area, path_area = path_area}

#func path_area_exited(area : PointArea, path_area : PathArea):
#	if not area.path == edited_path:
#		return
#	path_area_entered_data.clear()

#func create_connection_to_path():
#	var area = path_area_entered_data.area
#	var path_area = path_area_entered_data.path_area
#
#	if not area.is_connection_valid():
#		if not get_root():
#			push_error("There is no root, please open scene!")
#			return
#
#		var parent = area.path.get_parent()
#		# if its parents exist and its not already root of the scene
#		# root can be only one
#		if parent.get_parent() and parent != get_root():
#			parent = parent.get_parent()
#
#		if not parent.find_node("Connections"):
#			create_node_connections(parent)
#		var position_on_path
#		var con = add_new_connection(position_on_path)
#		con.add_to_connection(area)
#		#con.add_to_connection(area_entered_to)
#
#	edited_path.color_passable_connections(true)
#	point_area_entered_data.clear()
