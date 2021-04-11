extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("tree_exiting", self, "tree_exiting")
	print(name, "connected to tree_exiting")

func tree_exiting():
	print(name, ": tree_exiting")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
