tool

class_name TestNode extends Node2D


func _ready():
	print("has-parent: ", has_node(".."))
