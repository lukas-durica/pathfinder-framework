class_name HelperFunctions extends Reference

static func reparent(node : Node, new_parent : Node):
	var old_parent = node.get_parent()
	var transform = node.global_transform
	if old_parent:
		old_parent.remove_child(node)
	new_parent.add_child(node)
	node.owner = new_parent
	node.global_transform = transform


static func get_closest_path_offset(path : Path2D, global_pos : Vector2) \
		-> float:
	var local_pos = path.to_local(global_pos)
	return path.curve.get_closest_offset(local_pos)
