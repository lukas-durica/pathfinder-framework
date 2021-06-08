tool
class_name MarginalPointArea extends Area2D

# should be in Connectable path but due to cyclic reference it is placed here
enum {START, END}

signal connection_state_changed(my_area, overlapped_point_areas)
signal disconnected(my_area)
signal point_area_was_clicked(area, button_type)

var path
var type : = -1
var is_initiated : = false
# connections is dictionary with the key of path name and array of connected 
# other path names as as value
# making connections means making passable from one path to another
# dont assign it with := {} Godots bug will share it through the all instancies
# for simplicity only the names are stored, not a the whole path
# https://github.com/godotengine/godot/issues/48038
# connections["ConnectablePath2"] = PointConnection
export(Dictionary) var connections

var _is_left_button_down : = false
var _is_dragged : = false

var _entered_point_area : Area2D

onready var _collision_shape : = $CollisionShape2D

#change when Connection will be deleted
class PointConnection extends Reference:
	# for reconnecting, 
	var path_to_area : = ""
	# updating position
	var area : Area2D
	# passing through
	var is_passable : = false
	
	#func _init(p_path_node_to_area : String, p_area : Area2D, p_is_passable : bool):
	#	path_to_area = p_path_node_to_area
	#	area = p_area
	#	is_passable = p_is_passable

func _ready():
	if Engine.editor_hint:
		#change and try connections 
		connections = connections.duplicate(true)
		connections.clear()
		is_initiated = true

func _draw():
	if _entered_point_area or not connections.empty():
		var c = Color.azure
		draw_circle(Vector2.ZERO, 10.0, c)
	else:
		var c = Color.green if type == START else Color.red
		draw_circle(Vector2.ZERO, 10.0, Color(c.r, c.g, c.b, 0.5))

func _process(delta):
	if Engine.editor_hint:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and not _is_left_button_down:
			print("clicked in area: ", is_in_area(to_local(get_global_mouse_position())))
			_is_left_button_down = true
		elif not Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and _is_left_button_down:
				if _is_dragged:
					update_connections(find_overlapped_point_areas())
					_is_dragged = false
				
				_is_left_button_down = false
	

func _notification(what):
	if Engine.editor_hint:
		match what:
			NOTIFICATION_TRANSFORM_CHANGED:
				if _is_left_button_down and not _is_dragged \
						and is_in_area(to_local(get_global_mouse_position())):
					_is_dragged = true
				if _is_dragged and not connections.empty():
					pass
					# update positions of all point areas
					#for point_area in find_overlapped_point_areas():
						

func update_connections(overlapped_point_areas : Array):
	# area is leaving the connection
	if overlapped_point_areas.empty() and not connections.empty():
		for connection in connections.values():
			connection.area.disconnect_point_area(self)
		connections.clear()
	# area is making new connection
	
	elif not overlapped_point_areas.empty():
		for point_area in overlapped_point_areas:
			point_area.connect_point_area(self)
			var new_conne
			
	
		
			
func connect_point_area(area):
	var connection : = PointConnection.new()
	connection.path_to_area = String(get_path_to(area))
	connection.area = area
	connection.is_passable = true
	connections[area.path.name] = connection
	
func disconnect_point_area(area):
	connections.erase(area.path.name)

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

func update_border_point(pos : Vector2):
	if type == START:
		path.set_start_point(pos)
	else:
		path.set_end_point(pos)

func is_in_area(local_pos : Vector2) -> bool:
	return local_pos.length() <= _collision_shape.shape.radius

