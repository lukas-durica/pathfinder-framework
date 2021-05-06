tool

class_name ConnectablePath extends Path2D

const POINT_ARENA_SCENE = preload("res://addons/path_manager/PointArea.tscn")
const PATH_AREA_SCENE = preload("res://addons/path_manager/PathArea.tscn")
const DEFAULT_COLOR : = Color.gray
const HIGHLIGHT_COLOR : = Color.green

signal point_area_entered(my_area, area_entered)
signal point_area_exited(my_area, area_exited)
signal point_area_was_clicked(area, button_type)
signal path_renamed(old_name, new_name)
#signal path_area_entered(my_area, path_area_entered)
#signal path_area_exited(my_area, path_area_entered)

var path_area : Area2D

var start_point_area : PointArea = null
var end_point_area : PointArea = null

# used for updating connections with new name
onready var path_name : = name

func _ready():
	if not curve:
		curve = Curve2D.new()

	set_notify_transform(true)
	connect("renamed", self, "_renamed")
	self_modulate = DEFAULT_COLOR
	update_points()

func _notification(what : int):
	match what:
		NOTIFICATION_DRAW:
			update_points()
			update_collision_shape()
		NOTIFICATION_TRANSFORM_CHANGED:
			transform = Transform2D.IDENTITY


func _point_area_entered(my_area : PointArea, entered_area : PointArea):
	if not my_area.is_connection_valid():
		emit_signal("point_area_entered", my_area, entered_area)

func _point_area_exited(my_area : PointArea, exited_area : PointArea):
	emit_signal("point_area_exited", my_area, exited_area)

func _point_area_was_clicked(area : Area2D, button_type : int):
	emit_signal("point_area_was_clicked", area, button_type)

#func _path_area_entered(myArea : PointArea, path_area : PathArea):
#	emit_signal("path_area_entered", myArea, path_area)
#
#func _path_area_exited(myArea : PointArea, path_area : PathArea):
#	emit_signal("path_area_exited", myArea, path_area)

func _renamed():
	var connections : = get_connections()
	for connection in connections:
		connection.update_path_name(path_name, name)

	path_name = name

func update_points():
	if curve.get_point_count() > 0:
		process_point(true)
	if curve.get_point_count() > 1:
		process_point(false)

func process_point(is_start : bool):
	var point_area = start_point_area if is_start else end_point_area
	point_area = create_point_area(is_start) if not point_area else point_area
	point_area.position = get_start_point() if is_start else get_end_point()
	
func create_point_area(is_start : bool) -> PointArea:
	var point_area = POINT_ARENA_SCENE.instance()
	point_area.is_start = is_start
	point_area.path = self
	point_area.name = "Start" if is_start else "End"
	point_area.connect("point_area_entered", self, "_point_area_entered")
	point_area.connect("point_area_exited", self, "_point_area_exited")
	point_area.connect("point_area_was_clicked", self, 
			"_point_area_was_clicked")
#	point_area.connect("path_area_entered", self, "_path_area_entered")
#	point_area.connect("path_area_exited", self, "_path_area_exited")
	
	
	# set its new position
	if is_start:
		start_point_area = point_area
	else:
		end_point_area = point_area
	add_child(point_area)
	return point_area

func update_collision_shape():
	if not curve.get_point_count() > 1:
		return

	if not path_area:
		path_area = PATH_AREA_SCENE.instance()
		path_area.name = name + "PathArea"
		path_area.path = self
		add_child(path_area)

	var vec2_pool = PoolVector2Array()
	var prev_point : = Vector2.INF
	for point in curve.tessellate():
		if prev_point != Vector2.INF:
			vec2_pool.push_back(prev_point)
			vec2_pool.push_back(point)
		prev_point = point
	path_area.collision_shape.shape.segments = vec2_pool

func get_start_point() -> Vector2:
	return curve.get_point_position(0)

func set_start_point(value : Vector2):
	curve.set_point_position(0, value)	
	update()

func get_end_point() -> Vector2:
	return curve.get_point_position(curve.get_point_count() -1)

func set_end_point(value : Vector2):
	curve.set_point_position(curve.get_point_count() -1, value)
	update()

#todo rework this to get passable connections
func get_connections() -> Array:
	var connections : = []
	if start_point_area and start_point_area.is_connection_valid():
		connections.push_back(start_point_area.connection)
	if end_point_area and end_point_area.is_connection_valid():
		connections.push_back(end_point_area.connection)
	return connections

func get_connections_or_areas() -> Array:
	var border_points : = []
	if start_point_area:
		if start_point_area.is_connection_valid():
			border_points.push_back(start_point_area.connection)
		else:
			border_points.push_back(start_point_area)
	if end_point_area:
		if end_point_area.is_connection_valid():
			border_points.push_back(end_point_area.connection)
		else:
			border_points.push_back(end_point_area)
	return border_points
		
# when user move the border point from connection, but will not remove
# area from connections, border point need to be adjusted
func alling_border_points_with_connection():
	if start_point_area and start_point_area.is_connection_valid():
		set_start_point(start_point_area.connection.global_position)
	if end_point_area and end_point_area.is_connection_valid():
		set_end_point(end_point_area.connection.global_position)

func color_path(color : Color):
	self_modulate = color

func color_passable_connections(highlight : = false):
	var color = HIGHLIGHT_COLOR if highlight else DEFAULT_COLOR
	color_path(color)
	color_connection(start_point_area, color)
	color_connection(end_point_area, color)

func color_connection(area : PointArea, color : Color):
	if area and area.is_connection_valid():
		var passable_connections = area.connection.passable_connections
		for path_name in passable_connections[name]:
			get_parent().get_node(path_name).color_path(color)
