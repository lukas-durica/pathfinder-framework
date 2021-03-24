class_name RemotePathFollow extends PathFollow2D

onready var remote_transform : = $RemoteTransform2D

func set_remote_node(node : Node):
	remote_transform.remote_path = get_path_to(node)
