class_name OverlapFinder extends Node2D

var collision_shape : CollisionShape2D
var area : Area2D

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





func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == BUTTON_LEFT:
		print("click")
		
