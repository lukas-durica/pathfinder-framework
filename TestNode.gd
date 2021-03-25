extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var path_to = $Path2D/PathFollow2D/RemoteTransform2D.get_path_to($AGV)
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = path_to


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(delta):
	$Path2D/PathFollow2D.offset += delta * 20.0
