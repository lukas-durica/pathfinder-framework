tool

extends Node2D

func _ready():
	if Engine.editor_hint:
		$Node2D.test = "Hello"
		#$DeleteMe2/Node2D.test = get_path_to($DeleteMe2/Node2D/Position2)
		$Node2D2.test = "Hi"
		print("DeleteMe: ",$Node2D.test)
		print("DeleteMe2: ", $Node2D2.test)
		
	else:
		print("DeleteMe: ",$Node2D.test)
		print("DeleteMe2: ", $Node2D2.test)
