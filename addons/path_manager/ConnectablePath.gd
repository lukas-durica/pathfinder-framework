tool

class_name ConnectablePath extends Path2D

signal point_area_was_clicked(area, button_type)
								  
const POINT_ARENA_SCENE = preload("res://addons/path_manager/MarginalPointArea.tscn")
const PATH_AREA_SCENE = preload("res://addons/path_manager/PathArea.tscn")
const MONTSERRAT_FONT : = preload("res://data/fonts/Montserrat-Medium.ttf")
const DEFAULT_COLOR : = Color.gray
const HIGHLIGHT_COLOR : = Color.green

export(Dictionary) var start_point_connections setget set_start_point_connections
export(Dictionary) var end_point_connections setget set_end_point_connections

export var disconnect_start_connections : = false setget disconnect_start_connections
export var disconnect_end_connections : = false setget disconnect_end_connections

export var passable_angle_max_diff : = 10.0

var start_point_area : MarginalPointArea = null
var end_point_area : MarginalPointArea = null

var _path_area : Area2D
var _name_font : = DynamicFont.new()

# used for updating connections with new name
onready var path_name : = name

func _ready():
	if Engine.editor_hint:
		if not curve:
			curve = Curve2D.new()
		self_modulate = DEFAULT_COLOR
		load_font()
		set_meta("_edit_lock_", true)
		connect("renamed", self, "_renamed")
	update_marginal_points()


func disconnect_start_connections(value : bool):
	start_point_area.disconnect_from_connections()

func disconnect_end_connections(value : bool):
	end_point_area.disconnect_from_connections()


func _notification(what : int):
	match what:
		NOTIFICATION_DRAW:
			if Engine.editor_hint:
				draw_name()
				update_marginal_points()
				update_path_collision_shape()

func _to_string():
	return name

func set_start_point_connections(value : Dictionary):
	print(name, ": updating start connections: ", value)
	start_point_connections = value
	property_list_changed_notify()

func set_end_point_connections(value : Dictionary):
	print(name, ": updating end connections: ", value)
	end_point_connections = value
	property_list_changed_notify()

func _renamed():
	push_error("needs to be implemented")
#	var connections : = get_connections()
#	for connection in connections:
#		connection.update_path_name(path_name, name)

	path_name = name


func _point_area_was_clicked(area : Area2D, button_type : int):
	emit_signal("point_area_was_clicked", area, button_type)

func load_font():
	_name_font.font_data = MONTSERRAT_FONT
	_name_font.size = 12
	_name_font.use_mipmaps = true
	_name_font.use_filter = true

func update_marginal_points():
	if curve.get_point_count() > 0:
		process_marginal_point(MarginalPointArea.START)
	if curve.get_point_count() > 1:
		process_marginal_point(MarginalPointArea.END)

func process_marginal_point(type : int):
	var point_area = start_point_area if is_start(type) else end_point_area
	point_area = create_point_area(type) if not point_area else point_area
	point_area.global_position = get_start_point() if is_start(type) \
			else get_end_point()

func create_point_area(type : int) -> MarginalPointArea:
	var is_start = is_start(type)
	var point_area = POINT_ARENA_SCENE.instance()
	point_area.type = type
	point_area.path = self
	point_area.name = "Start" if is_start else "End"
	point_area.is_initiated = true
	
	# set its new position
	if is_start:
		start_point_area = point_area
	else:
		end_point_area = point_area
	add_child(point_area)
	return point_area

func update_path_collision_shape():
	if not curve.get_point_count() > 1:
		return

	if not _path_area:
		_path_area = PATH_AREA_SCENE.instance()
		_path_area.name = name + "PathArea"
		_path_area.path = self
		add_child(_path_area)

	var vec2_pool = PoolVector2Array()
	var prev_point : = Vector2.INF
	for point in curve.tessellate():
		if prev_point != Vector2.INF:
			vec2_pool.push_back(prev_point)
			vec2_pool.push_back(point)
		prev_point = point
	_path_area.collision_shape.shape.segments = vec2_pool

func draw_name():
	var string_pos = curve.interpolate_baked(curve.get_baked_length() / 2.0)
	draw_string(_name_font, string_pos, name, Color.white)

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

func get_connection_normal(is_start : bool) -> Vector2:
	var point0_idx = 0 if is_start else curve.get_baked_points().size() - 1
	var point1_idx = 1 if is_start else curve.get_baked_points().size() - 2 
	var point0 = curve.get_baked_points()[point0_idx]
	var point1 = curve.get_baked_points()[point1_idx]
	return point1.direction_to(point0)

# when user move the border point from connection, but will not remove
# area from connections, border point need to be adjusted
func alling_border_points_with_connection():
	if start_point_area and start_point_area.is_connection_valid():
		set_start_point(start_point_area.connection.global_position)
	if end_point_area and end_point_area.is_connection_valid():
		set_end_point(end_point_area.connection.global_position)

func get_length() -> float:
	return curve.get_baked_length()

func color_path(color : Color):
	self_modulate = color

#func color_passable_connections(highlight : = false):
#	var color = HIGHLIGHT_COLOR if highlight else DEFAULT_COLOR
#	color_path(color)
#	color_connection(start_point_area, color)
#	color_connection(end_point_area, color)

#func color_connection(area : MarginalPointArea, color : Color):
#	if area and area.is_connection_valid():
#		var passable_connections = area.connection.passable_connections
#		for path_name in passable_connections[name]:
#			get_parent().get_node(path_name).color_path(color)

static func is_start(type) -> bool:
	return type == MarginalPointArea.START
