class_name HelperFunctions extends Reference

static func reparent(node : Node, new_parent : Node):
	var old_parent = node.get_parent()
	var transform = node.global_transform
	old_parent.remove_child(node)
	new_parent.add_child(node)
	node.global_transform = transform
