tool
extends EditorPlugin

const CONNECTION_SCENE = preload("res://addons/path_manager/Connection.tscn")

var editor_selection : = get_editor_interface().get_selection()
#var editor_viewport : = get_editor_interface().get_editor_viewport()
var edited_path : ConnectablePath = null
var area_entered_data : = {}
var last_edited_object
var is_left_mouse_button_pressed : = false

func _enter_tree():
	print("---===EditorPlugin enabled===---")
	add_custom_type("ConnectablePath", "Path2D", preload("ConnectablePath.gd"),
			preload("res://addons/path_manager/Path2D.svg"))
	Physics2DServer.set_active(true)
	editor_selection.connect("selection_changed", self, "_on_selection_changed")

func _process(delta : float):
	if not edited_path:
		return
	# button pressed
	if not is_left_mouse_button_pressed \
			and Input.is_mouse_button_pressed(BUTTON_LEFT):
		is_left_mouse_button_pressed = true
	
	# button released
	if is_left_mouse_button_pressed \
			and not Input.is_mouse_button_pressed(BUTTON_LEFT):
		is_left_mouse_button_pressed = false
		if not area_entered_data.empty():
			create_connection()
		else:
			edited_path.alling_border_points_with_connection()

func _exit_tree():
	remove_custom_type("ConnectablePath")
	print("EditorPlugin disabled")

# chceck the type of the object, if it will return true the edit(object) is called
func handles(object : Object) -> bool:
	# check if the edited path was deselected in editor
	if edited_path and object != edited_path:
		print(name, ": Edited path is no longer selected, disconnecting signals")
		edited_path.disconnect("area_entered", self, "area_entered")
		edited_path.disconnect("area_with_connection_exited", self, 
				"area_with_connection_exited")
		edited_path.disconnect("area_without_connection_exited", self, 
				"area_without_connection_exited")
		edited_path.color_passable_connections(false)
		edited_path = null
	
	return object is ConnectablePath

func _on_selection_changed():
	if edited_path and editor_selection.get_selected_nodes().empty():
		print("Deselecting and setting defaul color")
		edited_path.color_passable_connections(false)

func edit(object : Object):
	if edited_path == object:
		return
	print(name, ": Editing new path, connecting signals")
	object.connect("area_entered", self, "area_entered")
	object.connect("area_with_connection_exited", self, 
			"area_with_connection_exited")
	object.connect("area_without_connection_exited", self, 
			"area_without_connection_exited")
	edited_path = object
	edited_path.color_passable_connections(true)


func clear():
	print("clearing")

func create_connection():
	print(name, ": create_connection, returning")
	var area = area_entered_data.area
	var area_entered_to = area_entered_data.area_entered_to
	area.global_transform.origin = area_entered_to.global_transform.origin
	var path = area.path
	
	
	if not area_entered_to.connection:
		
		if not get_root():
			push_error("There is no root, please open scene!")
			return
		if not get_root().find_node("Connections"):
			create_node_connections()
		
		var con = add_new_connection(area_entered_to.global_transform.origin)
		con.add_to_connection(area)
		con.add_to_connection(area_entered_to)
		
	else:
		var connection = area_entered_to.connection
		connection.add_to_connection(area)

	edited_path.color_passable_connections(true)
	area_entered_data = {}

func add_new_connection(position : Vector2) -> Node2D:
	var new_conn = CONNECTION_SCENE.instance()
	var connections = get_root().find_node("Connections")
	connections.add_child(new_conn)
	new_conn.owner = get_root()
	new_conn.global_transform.origin = position
	return new_conn
	

func create_node_connections():
	var new_connections = Node2D.new()
	new_connections.name = "Connections"
	get_root().add_child(new_connections)
	new_connections.owner = get_root()

func get_root() -> Node:
	return get_tree().get_edited_scene_root()

func area_entered(area : PointArea, area_entered_to : PointArea):
	if area.path == edited_path:
		print(name, ": This is edited path, creating area_entered_data")
		area_entered_data = {area = area, area_entered_to = area_entered_to}

func area_with_connection_exited(area : Area2D):
	if area.path == edited_path:
		print(name, ": This is edited path, area exiting")
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

func area_without_connection_exited(area : Area2D):
	if area.path == edited_path and not area_entered_data.empty():
		print(name, ": Clearing area_entered_data ")
		area_entered_data.clear()
