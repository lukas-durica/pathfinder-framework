tool
class_name MarginalPointArea extends Area2D

enum {START, END}
enum {NONE, MASTER, SLAVE}

#export(Dictionary) var connections
# bug with Arrays and Dictionaries with initial value are shared 
#https://github.com/godotengine/godot/issues/48038
var connections = {}

# should be in Connectable path but due to cyclic reference it is placed here
var path
var type : = -1
#var is_initiated : = false

# connections is dictionary with the key of path name and array of connected 
# other path names as as value
# making connections means making passable from one path to another
# dont assign it with := {} Godots bug will share it through the all instancies
# for simplicity only the names are stored, not a the whole path
# https://github.com/godotengine/godot/issues/48038

var _dragging_type : int = NONE

var _is_mouse_button_pressed : = false

var _entered_point_area : Area2D
var _size : = 10.0

onready var _collision_shape : = $CollisionShape2D

class Connection extends Reference:
	# passing through
	var path : Path2D
	# updating position
	var area : Area2D
	
func _ready():
	# wait for physics area initiation
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	update_connections()
		

func _draw():
	if not connections.empty():
		var c = Color.blue
		draw_circle(Vector2.ZERO, _size, Color(c.r, c.g, c.b, 0.5))
		
	elif _entered_point_area:
		#var c = Color.green if type == START else Color.red
		var c = Color.yellow
		draw_circle(Vector2.ZERO, _size, Color(c.r, c.g, c.b, 0.5))
	else:
		var c = Color.green if type == START else Color.red
		draw_circle(Vector2.ZERO, _size, Color(c.r, c.g, c.b, 0.5))

func _process(delta):
	if Engine.editor_hint:

		if Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and not _is_mouse_button_pressed:
			_is_mouse_button_pressed = true
		elif not Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and _is_mouse_button_pressed:
			if _dragging_type != NONE:
				
				update_connections()
				update_border_point_to_connection()
				# multiple connections alligned to founded point
				
				#update_positions = true
				_dragging_type = NONE

			_is_mouse_button_pressed = false
		
		if _dragging_type == MASTER:
			update_position_of_connections()
		
func _notification(what):
	if Engine.editor_hint:
		match what:
			NOTIFICATION_TRANSFORM_CHANGED:
				if _is_mouse_button_pressed and _dragging_type == NONE \
						and is_in_area(to_local(get_global_mouse_position())):
						_dragging_type = MASTER
						set_dragging_type_to_connections(SLAVE)
				#if _is_dragged:
				#	update_connection_positions()
					# update positions of all point areas
					#for point_area in find_overlapped_point_areas():
						
func _to_string():
	return get_compound_name()

# e.g. when connectablepath is renamed
func path_renamed(old_name : String, new_name : String):
	var overlapped_point_areas = find_overlapped_point_areas()
	for point_area in overlapped_point_areas:
		point_area.rename_path_in_connections(old_name, new_name)

func update_connections():
	var overlapped_point_areas = find_overlapped_point_areas()
	# keeping record of point areas for fast membership test
	var point_areas : = {}
	# area is leaving the connection
	for point_area in overlapped_point_areas:
		point_areas[point_area] = true
		if not connections.has(point_area.path.name):
			add_to_connections(point_area)
			# avoid redundant update of connections
			# change this area -> its area -> this area
			# to this area -> its area
			if not point_area.connections.has(path.name):
				point_area.update_connections()
	
	# find connections not occuring in overlapped point areas
	# thus recently disconnected
	for connection in connections.values():
		# area was disconnected
		if not point_areas.has(connection.area):
			#remove it from connections
			connections.erase(connection.area.path.name)
			# avoid redundant update of connections
			# change this area -> its area -> this area
			# to this area -> its area
			if connection.area.connections.has(path.name):
				connection.area.update_connections()
	
	# update color of point area
	update_path_exported_connections()
	update()
# if point areas are empty that means all connections are disconnected


func add_to_connections(area : Area2D):
	var connection : = Connection.new()
	connection.area = area
	connection.path = area.path
	connections[area.path.name] = connection

func update_position_of_connections():
	for connection in connections.values():
		connection.area.update_border_point(global_position)

func set_dragging_type_to_connections(dragging_type : int):
	for connection in connections.values():
		connection.area._dragging_type = dragging_type

func update_path_exported_connections():
	var new_connections : = {}	
	var old_connections = get_path_exported_connections()
	for path_name in connections:
		#if connection is still valid, assing the value of passable
		if old_connections.has(path_name):
			new_connections[path_name] = old_connections[path_name]
		#if connection is new, declare it as passable
		else:
			new_connections[path_name] = false
	
	# bug? with the setter it needs to be triggered this way
	if type == START:
		path.start_point_connections = new_connections
	else:
		path.end_point_connections = new_connections
		
	
# to do notify counterparts
func disconnect_from_connections():
	for connection in connections.values():
		# area was disconnected
		connections.erase(connection.area.path.name)
		# avoid redundant update of connections
		# change this area -> its area -> this area
		# to this area -> its area
		connection.area.disconnected_point_area(self)
	connections.clear()
	update_path_exported_connections()

func disconnected_point_area(point_area : Area2D):
	connections.erase(point_area.path.name)
	update_path_exported_connections()
	update()

func rename_path_in_connections(old_name : String, new_name : String):
	var connection = connections.get(old_name)
	if connection:
		connections.erase(old_name)
		connections[new_name] = connection
	# update path connections accordingly to save the pass state
	var path_connections = get_path_exported_connections()
	var passable = path_connections.get(old_name)
	if not passable == null:
		path_connections.erase(old_name)
		path_connections[new_name] = passable

func _on_Area2D_area_entered(area : Area2D):
	if Engine.editor_hint and area.is_in_group("point_areas"):
		_entered_point_area = area
		update()

func _on_Area2D_area_exited(area : Area2D):
	if Engine.editor_hint and area == _entered_point_area:
		_entered_point_area = null
		update()

func find_overlapped_point_areas() -> Array:
	var overlapped_point_areas : = []
	for overlapped_area in get_overlapping_areas():
		if overlapped_area.is_in_group("point_areas"):
			overlapped_point_areas.push_back(overlapped_area)
	return overlapped_point_areas

func get_compound_name() -> String:
	return path.name + "/" + name

func update_border_point_to_connection():
	var overlapped_areas : = find_overlapped_point_areas()
	if not overlapped_areas.empty():
		update_border_point(overlapped_areas[0].global_position)

func update_border_point(pos : Vector2):
	if type == START:
		path.set_start_point(pos)
	else:
		path.set_end_point(pos)

func is_in_area(local_pos : Vector2) -> bool:
	return local_pos.length() <= _collision_shape.shape.radius

func get_path_exported_connections() -> Dictionary:
	return path.start_point_connections if type == START \
			else path.end_point_connections
