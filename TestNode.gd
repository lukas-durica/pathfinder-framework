extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var line = $Line2D
	print(line)
	change_size(line)
	print($Line2D.width)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func change_size(l):
	print(l)
	l.width = 20
	
