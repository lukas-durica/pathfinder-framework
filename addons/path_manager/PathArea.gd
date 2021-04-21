tool

class_name PathArea extends Area2D

var path

onready var collision_shape : = $PathCollisionShape

func _ready():
	collision_shape.shape = ConcavePolygonShape2D.new()
