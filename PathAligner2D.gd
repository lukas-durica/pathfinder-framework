class_name PathAligner2D extends Node2D

export(NodePath) var area_path_node : NodePath setget _set_area_path_node

var _area : Area2D
var _aligned_path : Path2D

func _set_area_path_node(value : NodePath):
	if not value.is_empty():
		_area = get_node(value)
		area_path_node = value

func align_to_overlapped_path():
	var path : = find_first_overlapped_path()
	if is_instance_valid(path):
		align_to_path_editor(path)
		_aligned_path = path

func find_first_overlapped_path() -> ConnectablePath:
	for area_idx in range(_area.get_overlapping_areas().size()):
		if _area.get_overlapping_areas()[area_idx] is PathArea:
			return _area.get_overlapping_areas()[area_idx].path
	return null

func align_to_path_editor(path : Path2D):
	var local_origin = path.to_local(global_position)
	var closest_point = path.curve.get_closest_point(local_origin)
	global_position = path.to_global(closest_point)
