tool

extends Sprite


export(NodePath) var aligned_path_node_path
var aligned_path : ConnectablePath setget , _get_aligned_path


func _get_aligned_path() -> ConnectablePath:
	if has_node(aligned_path_node_path):
		return get_node(aligned_path_node_path) as ConnectablePath
	else:
		push_error(name + ": NodePath to Aligned Path was not assigned!")
		return null

func _on_PathAligner2D_aligned_to_path(path, node):
	aligned_path_node_path = get_path_to(path)
	

func _on_PathAligner2D_unaligned_to_path(node):
	aligned_path_node_path = ""
