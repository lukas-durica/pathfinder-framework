tool
class_name MarginalPointArea extends Area2D

# should be in Connectable path but due to cyclic reference it is placed here


#signal connection_state_changed(area, overlapped_point_areas)
signal point_area_was_clicked(area, button_type)

enum {START, END}
enum {NONE, MASTER, SLAVE}

export(Dictionary) var connections

var path
var type : = -1
var is_initiated : = false

# connections is dictionary with the key of path name and array of connected 
# other path names as as value
# making connections means making passable from one path to another
# dont assign it with := {} Godots bug will share it through the all instancies
# for simplicity only the names are stored, not a the whole path
# https://github.com/godotengine/godot/issues/48038


var _dragging_type : int = NONE

var _is_mouse_button_pressed : = false
#var _is_dragged : = false

var _entered_point_area : Area2D
var _size : = 10.0

onready var _collision_shape : = $CollisionShape2D

#change when Connection will be deleted
class PointConnection extends Reference:
	# for reconnecting, 
	var path_to_area : = ""
	# updating position
	var area : Area2D
	# passing through
	#var is_passable : = false
	
	#func _init(p_path_node_to_area : String, p_area : Area2D, p_is_passable : bool):
	#	path_to_area = p_path_node_to_area
	#	area = p_area
	#	is_passable = p_is_passable

func _ready():
	if Engine.editor_hint:
		#change and try connections = []
		connections = connections.duplicate(true)
		connections.clear()
		is_initiated = true

func _draw():
	#print("_entered_point_area: ", _entered_point_area)
	#print("connections.empty(): ", connections.empty())
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
						


func update_connections():
	print(path.name, " updating connections: ", connections)
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
			print("detected missing area: ", connection.area.get_compound_name())
			#remove it from connections
			connections.erase(connection.area.path.name)
			# avoid redundant update of connections
			# change this area -> its area -> this area
			# to this area -> its area
			if connection.area.connections.has(path.name):
				connection.area.update_connections()
				print("sending notification to update connections")
				print("from {0} to {1}".format([path.name, connection.area.path.name]))
	
	# update color of point area
	update_path_exported_connections()
	update()
# if point areas are empty that means all connections are disconnected
	
func add_to_connections(area : Area2D):
	var connection : = PointConnection.new()
	connection.path_to_area = String(get_path_to(area))
	connection.area = area
	#connection.is_passable = true
	connections[area.path.name] = connection

func update_position_of_connections():
	for connection in connections.values():
		connection.area.update_border_point(global_position)

func set_dragging_type_to_connections(dragging_type : int):
	for connection in connections.values():
		connection.area._dragging_type = dragging_type

func update_path_exported_connections():
	var path_names : = {}
	for path_name in connections:
		path_names[path_name] = true
	if type == START:
		path.start_point_connections = path_names
	else:
		path.end_point_connections = path_names

# to do notify counterparts
func disconnect_from_connections():
	print(path.name, ": disconnect_from_connections")
	connections.clear()
	update()

func _on_Area2D_area_entered(area : Area2D):
	if Engine.editor_hint and area.is_in_group("point_areas"):
		_entered_point_area = area
		update()

func _on_Area2D_area_exited(area : Area2D):
	if Engine.editor_hint and area == _entered_point_area:
		_entered_point_area = null
		update()

# clicking on the area
func _on_Area2D_input_event(viewport : Node, event : InputEvent, 
		shape_idx : int):
	# signal is not working in the editor
	if not Engine.editor_hint and event is InputEventMouseButton \
			and event.pressed:
		match event.button_index:
			BUTTON_LEFT, BUTTON_RIGHT:
				emit_signal("point_area_was_clicked", self, event.button_index)

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

