tool
extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		$DeleteMe/Node2D.test = "Hey"
		#$DeleteMe2/Node2D.test = get_path_to($DeleteMe2/Node2D/Position2)
		$DeleteMe2/Node2D.test = get_path_to($DeleteMe2/Node2D/Position1)
		print("DeleteMe: ", $DeleteMe/Node2D.test)
		print("DeleteMe2: ", $DeleteMe2/Node2D.test)
		
	else:
		print("DeleteMe: ", $DeleteMe/Node2D.test)
		print("DeleteMe2: ", $DeleteMe2/Node2D.test)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
