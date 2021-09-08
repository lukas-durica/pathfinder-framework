tool

class_name RemotePathFollow extends PathFollow2D

var parent : Node2D setget set_parent
var remote_node : Node2D setget set_remote_node, get_remote_node

onready var remote_transform : = $RemoteTransform2D

# parent can be set either Node2D or Path2D
func set_parent(value : Node2D):
	if not is_instance_valid(value):
		return
	parent = value
	var node : Node2D
	if remote_transform.has_node(remote_transform.remote_path):
		 node = get_remote_node()
	HelperFunctions.reparent(self, parent)
	if is_instance_valid(node):
		set_remote_node(node)

func set_remote_node(node : Node2D):
	var remote_path = remote_transform.get_path_to(node) \
			 if is_instance_valid(node) else NodePath("")
	remote_transform.remote_path = remote_path
	
func get_remote_node() -> Node2D:
	return remote_transform.get_node(remote_transform.remote_path) as Node2D

func is_parent_path() -> bool:
	return parent is Path2D

func align_to_path(path : Path2D):
	self.parent = path
	offset = HelperFunctions.get_closest_path_offset(path, global_position)
	
