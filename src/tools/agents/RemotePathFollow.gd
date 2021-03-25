class_name RemotePathFollow extends PathFollow2D

onready var remote_transform : = $RemoteTransform2D

func set_remote_node(node : Node):
	remote_transform.remote_path = remote_transform.get_path_to(node)

func get_closest_area() -> PointArea:
	var parent : ConnectablePath = get_parent()
	if not parent:
		push_error(name + ": Invalid Path")
		return null
	
	var start : = parent.start_point_area.global_transform.origin
	var end : = parent.end_point_area.global_transform.origin
	
	var dist_to_start = global_position.distance_squared_to(start)
	var dist_to_end = global_position.distance_squared_to(end)
	
	return parent.start_point_area if dist_to_start < dist_to_end \
			else parent.end_point_area
	
func get_next_path() -> ConnectablePath:
	var closest_area : PointArea = get_closest_area()
	if not closest_area:
		return null 
	
	var connection : Connection = closest_area.connection
	if not connection:
		return null
	
	if connection.connected_paths[0] != get_parent():
		return connection.connected_paths[0]
	return connection.connected_paths[1]

	
	
