tool

class_name RemotePathFollow extends PathFollow2D

onready var remote_transform : = $RemoteTransform2D

func set_remote_node(node : Node):
	remote_transform.remote_path = remote_transform.get_path_to(node)

#func get_closest_area() -> MarginalPointArea:
#	var parent : = get_parent()
#	print(parent.name)
#	if not parent is ConnectablePath:
#		push_error(name + ": Invalid Path")
#		return null
#
#	var start : Vector2 = parent.start_point_area.global_position
#	var end : Vector2 = parent.end_point_area.global_position
#
#	var dist_to_start = global_position.distance_squared_to(start)
#	var dist_to_end = global_position.distance_squared_to(end)
#
#	return parent.start_point_area if dist_to_start < dist_to_end \
#			else parent.end_point_area

#func get_next_path() -> ConnectablePath:
#	var closest_area : MarginalPointArea = get_closest_area()
#	if not closest_area:
#		return null 
#
#	var connection : Connection = closest_area.connection
#	if not connection:
#		return null
#
#	if connection.passable_paths[get_parent()].empty():
#		return null
#
#	return connection.passable_paths[get_parent()][0]

	
	
