tool

class_name TestNode extends Node2D

var path_to_test : NodePath = "Test"

func _ready():
	print("has_node: ", has_node(path_to_test))
	
