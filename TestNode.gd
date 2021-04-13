extends Node2D

func _ready():
	var node_name = NodePath("../../Paths/ConnectablePath2/End")
	var test_strinf : = "ddaaaaa"
	print("node_name: ", typeof(String(node_name)))
	
	print(node_name.get_name_count())
	print(node_name.get_name(node_name.get_name_count() - 2))
