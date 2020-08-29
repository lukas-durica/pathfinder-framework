extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var t = Transform2D.IDENTITY
	var d = {a = 5, b = 6}
	print(d.size())
