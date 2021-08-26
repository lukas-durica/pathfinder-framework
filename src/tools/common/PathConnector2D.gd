tool

class_name PathConnector2D extends Node2D

signal connected_to_path(path)
signal disconnected_from_path()

export(NodePath) var path_aligner_node_path setget _set_path_aligner_node_path
export(NodePath) var remote_path_follow_node_path : = "RemotePathFollow"

func _set_path_aligner_node_path(value : NodePath):
	path_aligner_node_path = value
	call_deferred("process_path_aligner")
	
func process_path_aligner():
	if has_node(path_aligner_node_path):
		var path_aligner : = get_node(path_aligner_node_path) as PathAligner2D
		if not path_aligner.is_connected("aligned_to_path", self, 
				"connect_to_path"):
			path_aligner.connect("aligned_to_path", self, "connect_to_path")
			path_aligner.connect("unaligned_to_path", self, 
					"disconnect_from_path")

func connect_to_path(path : Path2D, node : Node2D):
	print("connecting to path")
	var remote_path_follow : = find_remote_path_follow()
	if not remote_path_follow:
		return
	HelperFunctions.reparent(remote_path_follow, path)
	var local_origin = path.to_local(node.global_position)
	var closest_offset = path.curve.get_closest_offset(local_origin)
	remote_path_follow.offset = closest_offset
	remote_path_follow_node_path = get_path_to(remote_path_follow)
	remote_path_follow.set_remote_node(node)
	emit_signal("connected_to_path", path)

func disconnect_from_path(node : Node2D):
	print("disconnecting from path")
	var remote_path_follow = find_remote_path_follow()
	remote_path_follow.clear_remote_node()
	node.global_rotation = 0.0
	HelperFunctions.reparent(remote_path_follow, self)
	remote_path_follow.global_position = node.global_position
	remote_path_follow_node_path = get_path_to(remote_path_follow)
	emit_signal("disconnected_from_path")

func find_remote_path_follow() -> RemotePathFollow:
	if has_node(remote_path_follow_node_path):
		return get_node(remote_path_follow_node_path) as RemotePathFollow
	else:
		push_error(name + ": Assign Remote Path Follow Node Path ")
		return null
