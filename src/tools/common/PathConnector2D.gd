tool

class_name PathConnector2D extends Node2D

export(NodePath) var agent_node_path
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
		
func connect_to_path(path : Path2D):
	if is_instance_valid(path):
		var agent : Node2D
		if has_node(agent_node_path):
			agent = get_node(agent_node_path)
		else:
			push_error(name + ":  Assign Agent Node Path!")
			return
		var remote_path_follow : = find_remote_path_follow()
		if not remote_path_follow:
			return
		HelperFunctions.reparent(remote_path_follow, path)
		remote_path_follow.set_remote_node(agent)
		var local_origin = path.to_local(agent.global_position)
		var closest_offset = path.curve.get_closest_offset(local_origin)
		remote_path_follow.offset = closest_offset
	else:
		var path_follow = find_remote_path_follow()
		HelperFunctions.reparent(path_follow, self)

func find_remote_path_follow() -> RemotePathFollow:
	if has_node(remote_path_follow_node_path):
		return get_node(remote_path_follow_node_path) as RemotePathFollow
	else:
		push_error(name + ": Assign Remote Path Follow Node Path ")
		return null
