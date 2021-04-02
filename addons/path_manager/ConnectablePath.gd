tool

class_name ConnectablePath extends Path2D

const POINT_ARENA_SCENE = preload("res://addons/path_manager/PointArea.tscn")

signal area_entered(area, area_entered)
signal area_with_connection_exited(area)
signal area_without_connection_exited(area)
signal area_was_clicked(area, button_type)

export(Color) var default_color : = Color.gray
export(Color) var highlight_color : = Color.green

var start_point_area : PointArea = null
var end_point_area : PointArea = null

# used for passable connections and checking whether it was changed
# then connection is updated
var start_normal : = Vector2.INF
var end_normal : = Vector2.INF

func _ready():
	
	
	if not curve:
		curve = Curve2D.new()

	set_notify_transform(true)
	update_points()
	update_normals()
	self_modulate = Color.gray

func _notification(what):
	match what:
		NOTIFICATION_DRAW:
			update_points()
			#update_normals()
		NOTIFICATION_TRANSFORM_CHANGED:
			transform = Transform2D.IDENTITY
		


func update_points():
	if not curve or curve.get_point_count() == 0:
		return
	process_point(true)
	if curve.get_point_count() > 1:
		process_point(false)

func process_point(is_start : bool):
	var point_area = start_point_area if is_start else end_point_area
	if not point_area:
		point_area = create_point_area(is_start)
	point_area.position = get_start_point() if is_start else get_end_point()
	
func create_point_area(is_start : bool) -> PointArea:
	print(name, ": CreatingPointArea: ", "Start" if is_start else "End")
	var point_area = POINT_ARENA_SCENE.instance()
	point_area.is_start = is_start
	point_area.path = self
	point_area.name = "Start" if is_start else "End"
	var area_entered = "start_area_entered" if is_start else "end_area_entered"
	var area_exited = "start_area_exited" if is_start else "end_area_exited"
	point_area.connect("area_entered", self, area_entered)
	point_area.connect("area_exited", self, area_exited)
	point_area.connect("area_was_clicked", self, "area_was_clicked")
	point_area.connect("tree_exiting", self, "_on_tree_exiting")
	# set its new position
	if is_start:
		start_point_area = point_area
	else:
		end_point_area = point_area
	add_child(point_area)
	return point_area

func _on_tree_exiting():
	print(name,": area exitinggggggggggggggggggg")

func color_path(color : Color):
	self_modulate = color

# when deselecting the selected path, more in path manager
func set_default_color():
	self_modulate = default_color

func update_normals():
	if curve.get_point_count() < 2:
		return
	
	var normal = get_connection_normal(true)
	if start_normal != normal:
		#print("updating start normal old: ", start_normal, " new: ", normal)
		start_normal = normal
	normal = get_connection_normal(false)
	if end_normal != normal:
		#print("updating end normal old: ", end_normal, " new: ", normal)
		end_normal = normal

func color_passable_connections(highlight : = false):
	var color = highlight_color if highlight else default_color
	color_path(color)
	color_connection(start_point_area, color)
	color_connection(end_point_area, color)

func color_connection(area : PointArea, color : Color):
	if area and area.connection:
		var passable_connections = area.connection.passable_connections
		for path_name in passable_connections[name]:
			get_parent().get_node(path_name).color_path(color)
	 


func start_area_entered(area : Area2D):
	
	if not start_point_area.connection:
		print(name, ": start area entered without connection")
		emit_signal("area_entered", start_point_area, area)
		

func start_area_exited(area : Area2D):
	if area.is_inside_tree():
		print(area.get_compound_name(),": is still inside tree")
	else:
		print(area.get_compound_name(),": is not  inside tree")
	
	if start_point_area.connection:
		print(name, ": start area exited with connection")
		emit_signal("area_with_connection_exited", start_point_area)
		
	else:
		print(name, ": start area exited without connection")
		emit_signal("area_without_connection_exited", start_point_area)
		
	
func end_area_entered(area : Area2D):
	
	if not end_point_area.connection:
		print(name, ": end area entered without connection")
		emit_signal("area_entered", end_point_area, area)
		
	
func end_area_exited(area : Area2D):
	if area.is_inside_tree():
		print(area.get_compound_name(),": is still inside tree")
	else:
		print(area.get_compound_name(),": is not  inside tree")
	if end_point_area.connection:
		print(name, ": end area exited with connection")
		emit_signal("area_with_connection_exited", end_point_area)
		
	else:
		print(name, ": end area exited without connection")
		emit_signal("area_without_connection_exited", end_point_area)
		

func area_was_clicked(area : Area2D, button_type : int):
	emit_signal("area_was_clicked", area, button_type)

func get_start_point():
	return curve.get_point_position(0)

func set_start_point(value):
	curve.set_point_position(0, value)

func get_end_point():
	return curve.get_point_position(curve.get_point_count() -1)

func set_end_point(value):
	curve.set_point_position(curve.get_point_count() -1, value)

func get_connections_or_areas():
	var border_points : = []
	if start_point_area:
		if start_point_area.connection:
			border_points.push_back(start_point_area.connection)
		else:
			border_points.push_back(start_point_area)
	if end_point_area:
		if end_point_area.connection:
			border_points.push_back(end_point_area.connection)
		else:
			border_points.push_back(end_point_area)
		
func get_opposite_connection(connection):
	if start_point_area and start_point_area.connection \
			and start_point_area.connection != connection:
		return start_point_area.connection
	if end_point_area and end_point_area.connection \
			and end_point_area.connection != connection:
		return end_point_area.connection

func get_opposite_area(connection):
	if start_point_area and start_point_area.connection \
			and start_point_area.connection == connection:
		return end_point_area
	if end_point_area and end_point_area.connection \
			and end_point_area.connection == connection:
		return start_point_area
# when user move the border point from connection, but will not remove
# area from connections, border point need to be adjusted
func alling_border_points_with_connection():
	if start_point_area and start_point_area.connection:
		start_point_area.global_transform.origin = \
				start_point_area.connection.global_transform.origin
		update_border_point(start_point_area)
	if end_point_area and end_point_area.connection:
		end_point_area.global_transform.origin = \
				end_point_area.connection.global_transform.origin
		update_border_point(end_point_area)

func update_border_point(area : PointArea):
	if area.is_start:
		set_start_point(area.connection.global_transform.origin)
	else: 
		set_end_point(area.connection.global_transform.origin)

# the direction of last two points or first two points
# used for the for check before creating passable connection
func get_connection_normal(is_start : bool) -> Vector2:
	var point0_idx = 0 if is_start else curve.get_baked_points().size() - 1
	var point1_idx = 1 if is_start else curve.get_baked_points().size() - 2 
	var point0 = curve.get_baked_points()[point0_idx]
	var point1 = curve.get_baked_points()[point1_idx]
	return point1.direction_to(point0)

func _exit_tree():
	print(name, ": exit_tree")
