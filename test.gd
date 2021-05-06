tool
extends Node2D

func _ready():
	Physics2DServer.set_active(true)

func _on_Area2D_mouse_entered():
	print("entered")
