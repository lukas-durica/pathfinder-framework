extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Area2D/CollisionShape2D.shape.segments = $Path2D.curve.tessellate()
	
	
