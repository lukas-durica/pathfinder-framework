tool

class_name PathAligner2D extends Node2D

signal aligned_to_path(path, node)
signal unaligned_to_path(node)

export(NodePath) var area_node_path : NodePath
export(NodePath) var node_to_align_node_path : NodePath
export(NodePath) var drag_notifier_node_path : NodePath setget \
		_set_drag_notifier_path_node
export(String) var blah = "x"

var elapsed_time : = 0.0

onready var _drag_notifier : DragNotifier2D


func _set_drag_notifier_path_node(value : NodePath):
	drag_notifier_node_path = value
	# call deferred function due to the bug? setters are triggered before
	# the node is added to the tree
	call_deferred("process_drag_notifier")

func process_drag_notifier():
	if has_node(drag_notifier_node_path):
		_drag_notifier = get_node(drag_notifier_node_path)
		if not _drag_notifier.is_connected("dragging_ended", self, 
				"align_to_overlapped_path"):
			_drag_notifier.connect("dragging_ended", self, 
					"align_to_overlapped_path")

func align_to_overlapped_path():
	if not has_node(node_to_align_node_path):
		push_error(name + ":  Assign Node Path for Node to Align !")
		return
	var node = get_node(node_to_align_node_path)
	var path : = find_first_overlapped_path()
	if is_instance_valid(path):
		blah = "wah"
		print("blah: ", blah)
		align_to_path_editor(path, node)
		emit_signal("aligned_to_path", path, node)
	else:
		emit_signal("unaligned_to_path", node)

func find_first_overlapped_path() -> ConnectablePath:
	if has_node(area_node_path):
		var area : = get_node(area_node_path) as Area2D
		for area_idx in range(area.get_overlapping_areas().size()):
			if area.get_overlapping_areas()[area_idx] is PathArea:
				return area.get_overlapping_areas()[area_idx].path
	else:
		push_error(name + ":  Assign Area Node Path!")
	return null

func align_to_path_editor(path : Path2D, node : Node2D):
	var local_origin = path.to_local(node.global_position)
	var closest_point = path.curve.get_closest_point(local_origin)
	node.global_position = path.to_global(closest_point)
