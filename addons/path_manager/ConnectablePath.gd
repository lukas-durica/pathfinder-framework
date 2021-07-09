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

export var is_smoothing_enabled : = true
export(float, 0.0, 1.0) var smooth_scale : = 0.4

# if the normalized vectors of two points closest to the connection 
# called connection normals of both path differs less then the pass_angle_diff, 
# connection will be passable

export var pass_angle_diff : = 10.0

export var delete_path : = false setget set_delete_path

var start_point_area : MarginalPointArea = null
var end_point_area : MarginalPointArea = null

var _path_area : Area2D
var _default_font : = DynamicFont.new()

var _name_label : Label
var _start_label : Label
var _end_label : Label

var _marginal_points_labeling : = false 
var _is_path_highlighted : = false
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

func _notification(what : int):
	match what:
		NOTIFICATION_DRAW:
			if Engine.editor_hint:
				update_marginal_points()
				update_path_collision_shape()
				print_name_label()
				apply_smoothing()
				if _marginal_points_labeling:
					print_marginal_point_name(MarginalPointArea.START)
					print_marginal_point_name(MarginalPointArea.END)
				
					

func _to_string():
	return name

func _renamed():
	start_point_area.path_renamed(path_name, name)
	end_point_area.path_renamed(path_name, name)
	path_name = name
	_name_label.text = name
	update()

func set_start_point_connections(value : Dictionary):
	start_point_connections = value
	property_list_changed_notify()
	color_passable_connections()

func set_end_point_connections(value : Dictionary):
	end_point_connections = value
	property_list_changed_notify()
	color_passable_connections()

func disconnect_start_connections(value : bool):
	start_point_area.disconnect_from_connections()

func disconnect_end_connections(value : bool):
	end_point_area.disconnect_from_connections()

func set_delete_path(value : bool):
	start_point_area.disconnect_from_connections()
	end_point_area.disconnect_from_connections()
	queue_free()
	
func _point_area_was_clicked(area : Area2D, button_type : int):
	emit_signal("point_area_was_clicked", area, button_type)

func load_font():
	_default_font.font_data = MONTSERRAT_FONT
	_default_font.size = 10
	_default_font.outline_color = Color.black
	_default_font.outline_size = 1.0
	_default_font.use_mipmaps = true
	_default_font.use_filter = true

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
	#PackedScene.GEN_EDIT_STATE_INSTANCE
	var point_area = POINT_ARENA_SCENE.instance()
	point_area.type = type
	point_area.path = self
	point_area.name = "Start" if is_start else "End"
	#point_area.is_initiated = true
	
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


func print_name_label():
	var name_label_pos = curve.interpolate_baked(curve.get_baked_length() / 2.0)
	if not is_instance_valid(_name_label):
		_name_label = create_label(name, self_modulate)
	_name_label.rect_global_position = Vector2(
			name_label_pos.x - _name_label.rect_size.x / 2.0, 
			name_label_pos.y - _name_label.rect_size.y / 2.0)

func print_marginal_point_name(type : int):
	var label : = _start_label if is_start(type) else _end_label
	var point_area = start_point_area if is_start(type) else end_point_area
	if not point_area:
		return
	if not label:
		label = create_label(point_area.name, self_modulate)
	label.rect_global_position = Vector2(
			point_area.global_position.x - label.rect_size.x / 2.0, 
			point_area.global_position.y - label.rect_size.y / 2.0)
	
	
	if is_start(type):
		_start_label = label
	else:
		_end_label = label

func create_label(text : String, color : Color)-> Label:
	var new_label : = Label.new()
	new_label.name = text
	new_label.text = text
	new_label.set("custom_fonts/font", _default_font)
	new_label.set("custom_colors/font_color", color)
	add_child(new_label)
	return new_label


func apply_smoothing():
	if curve.get_point_count() < 2 or not is_smoothing_enabled:
		return
	# ignore first and last marginal points
	for idx in range(1, curve.get_point_count() - 1):
		var control = get_control_points(idx)
		curve.set_point_in(idx, control.cp0)
		curve.set_point_out(idx, control.cp1)
	update()

#http://scaledinnovation.com/analytics/splines/aboutSplines.html
func get_control_points(idx : int, t : = 3.0) -> Dictionary:
	var point0 = curve.get_point_position(idx - 1)
	var point1 = curve.get_point_position(idx)
	var point2 = curve.get_point_position(idx + 1)
	var dir = point0.direction_to(point2)
	var cp0 = -dir * point1.distance_to(point0) / (1.0 / smooth_scale)
	var cp1 = dir *  point2.distance_to(point1) / (1.0 / smooth_scale)
	return {cp0 = cp0, cp1 = cp1};

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

func get_connection_normal(type : int) -> Vector2:
	var point0_idx = 0 if is_start(type) \
			else curve.get_baked_points().size() - 1
	var point1_idx = 1 if is_start(type) \
			else curve.get_baked_points().size() - 2 
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

func color_path(highlight : = false):
	_is_path_highlighted = highlight
	self_modulate = get_highlight_color(highlight)

func color_passable_connections():
	
	var color = get_highlight_color(_is_path_highlighted)
	color_connections(MarginalPointArea.START, color)
	color_connections(MarginalPointArea.END, color)

func color_connections(type : int, color : Color):
	var point_connections = start_point_connections if is_start(type) \
			else end_point_connections
	var area = start_point_area if is_start(type) else end_point_area
	if area:
		for path_name in point_connections:
			#if passable
			if area.connections.empty():
				continue
			if point_connections[path_name]:
				area.connections[path_name].path.color_path(
						_is_path_highlighted)
			else:
				area.connections[path_name].path.color_path(false)

func set_marginal_points_labeling(is_visible : bool):
	if is_visible:
		if _start_label:
			_start_label.show()
		if _end_label:
			_end_label.show()
	else:
		if _start_label:
			_start_label.hide()
		if _end_label:
			_end_label.hide()
		
	_marginal_points_labeling = is_visible
	update()

func get_highlight_color(is_highlighted : bool) -> Color:
	return HIGHLIGHT_COLOR if is_highlighted else DEFAULT_COLOR

static func is_start(type) -> bool:
	return type == MarginalPointArea.START
