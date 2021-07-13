tool

class_name AgentGraph extends Node2D

var _is_left_button_down : = false
var _is_agent_dragged : = false
var paths_data : = []

export (NodePath) var node_path_to_path
export var speed : = 150.0
export (int, -1, 1, 1) var path_direction : = 1

onready var path_follow : = $ResetTransform/RemotePathFollow
#var path_follow
onready var visualization : = $Visualization/AnimatedSprite
onready var collision_shape : = $Area2D/CollisionShape2D
onready var area : = $Area2D

func _ready():
	if Engine.editor_hint:
		set_notify_transform(true)
	else:
		if not node_path_to_path.is_empty():
			var path = get_node(node_path_to_path)
			align_to_path(path, global_position)
		else:
			push_warning(name + "node path to path is empty!")
		set_process(false)
	$Visualization/Label.text = name

func _process(delta):
	if Engine.editor_hint:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and not _is_left_button_down:
			_is_left_button_down = true
		elif not Input.is_mouse_button_pressed(BUTTON_LEFT) \
				and _is_left_button_down:
			if _is_agent_dragged:
				var entered_path = find_overlapped_path()
				if entered_path:
					align_to_path_editor(entered_path, global_position)
				else:
					node_path_to_path = ""
			_is_left_button_down = false
			#entered_path = null
			_is_agent_dragged = false
		return
	# update_position
	
	path_follow.offset += delta * speed * path_direction
	
	if can_update_path():
		var path_data = paths_data.pop_front()
		if path_data:
			var old_unit_offset = path_follow.unit_offset
			align_to_path(path_data.path, global_position)
			var new_unit_offset = path_follow.unit_offset
			if can_invert_direction(old_unit_offset, new_unit_offset):
				invert_direction()
		else:
			set_process(false)

func _notification(what):
	if Engine.editor_hint:
		match what:
			NOTIFICATION_TRANSFORM_CHANGED:
				if _is_left_button_down and not _is_agent_dragged \
						and is_in_area():
					_is_agent_dragged = true
				if _is_agent_dragged:
					path_follow.global_position = global_position

func run(pths_data : Array):
	if pths_data.empty():
		push_error(name + "paths data is empty!")
		return
	paths_data = pths_data
	# compute initial direction
	var path : ConnectablePath = paths_data.front().path
	var area : MarginalPointArea = paths_data.front().area
	
	if area == path.get_point_area(MarginalPointArea.START):
		path_direction = -1
	elif area == path.get_point_area(MarginalPointArea.END):
		path_direction = 1
	else:
		push_error("Area does not match!")
	
	# agent is already alligned to this path, thus pop front it
	paths_data.pop_front()
	set_process(true)



func is_in_area() -> bool:
	if not collision_shape:
		return false
	var extents = collision_shape.shape.extents
	var rect = Rect2(-extents.x, -extents.y, extents.x * 2, extents.y * 2)
	return rect.has_point(to_local(get_global_mouse_position()))
		
func find_overlapped_path() -> ConnectablePath:
	# find last overlapped path
	for area_idx in range(area.get_overlapping_areas().size()):
		if area.get_overlapping_areas()[area_idx] is PathArea:
			return area.get_overlapping_areas()[area_idx].path
	return null

func align_to_path(path : Path2D, align_to : Vector2):
	if path_follow.get_parent():
		HelperFunctions.reparent(path_follow, path)
	else:
		path.add_child(path_follow)
		# set the remote node at the beginning when aligning to path
		# and path follow has no parent
	
	path_follow.set_remote_node(self)
	
	var local_origin = path.to_local(align_to)
	var closest_offset = path.curve.get_closest_offset(local_origin)
	path_follow.offset = closest_offset
	
func align_to_path_editor(path : Path2D, align_to : Vector2):
	var local_origin = path.to_local(align_to)
	var closest_point = path.curve.get_closest_point(local_origin)
	global_position = path.to_global(closest_point)
	node_path_to_path = get_path_to(path)
	
func can_update_path() -> bool:
	return path_direction == 1 and path_follow.unit_offset >= 1.0 \
			or path_direction == -1 and path_follow.unit_offset <= 0.0

func can_invert_direction(old_unit_offset : float, 
		new_unit_offset : float) -> bool:
	return int(round(old_unit_offset)) == int(round(new_unit_offset))

func invert_direction():
	visualization.rotate(PI)
	path_direction *= -1

func _exit_tree():
	print("agent exiting tree")
	print("path_follow: ", path_follow)
	print("is_instance_valid(path_follow): ", is_instance_valid(path_follow))
	if is_instance_valid(path_follow):
		print("path_follow.is_inside_tree(): ", 
				path_follow.is_inside_tree())
	if is_instance_valid(path_follow) and not path_follow.is_inside_tree():
		print("pathfollow queue_free")
		path_follow.free()

