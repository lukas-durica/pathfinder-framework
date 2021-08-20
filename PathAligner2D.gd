tool

class_name PathAligner2D extends Node2D

export(NodePath) var area_node_path : NodePath setget _set_area_node_path
export(NodePath) var drag_notifier_node_path : NodePath setget \
		_set_drag_notifier_path_node

var _aligned_path : Path2D

onready var _area : Area2D
onready var _drag_notifier : DragNotifier2D

func _set_area_node_path(value : NodePath):
	area_node_path = value
	call_deferred("process_area")

func _set_drag_notifier_path_node(value : NodePath):
	drag_notifier_node_path = value
	# call deferred function due to the bug? setters are triggered before
	# the node is added to the tree
	call_deferred("process_drag_notifier")
	

func process_area():
	if has_node(area_node_path):
		_area = get_node(area_node_path)

func process_drag_notifier():
	if has_node(drag_notifier_node_path):
		_drag_notifier = get_node(drag_notifier_node_path)
		if not _drag_notifier.is_connected("dragging_ended", self, 
				"align_to_overlapped_path"):
			_drag_notifier.connect("dragging_ended", self, 
					"align_to_overlapped_path")

func align_to_overlapped_path(node : Node2D):
	var path : = find_first_overlapped_path()
	if is_instance_valid(path):
		align_to_path_editor(path, node)
		_aligned_path = path
	
func find_first_overlapped_path() -> ConnectablePath:
	if is_instance_valid(_area):
		for area_idx in range(_area.get_overlapping_areas().size()):
			if _area.get_overlapping_areas()[area_idx] is PathArea:
				return _area.get_overlapping_areas()[area_idx].path
	else:
		push_error(name + ":  Assign Area Node Path!")
	return null

func align_to_path_editor(path : Path2D, node : Node2D):
	var local_origin = path.to_local(node.global_position)
	var closest_point = path.curve.get_closest_point(local_origin)
	node.global_position = path.to_global(closest_point)
