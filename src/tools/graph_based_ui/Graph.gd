class_name Graph extends Node2D

var points : = {}

func _ready():
	for child in get_children():
		if child is ConnectablePath:
			child.get_neighbor_paths(true)
			child.get_neighbor_paths(false)



func get_neighbors() ->Array:
	
