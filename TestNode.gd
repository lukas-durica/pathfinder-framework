extends Node2D

enum {DEFAULT = 3}

func _ready():
	pass
	#$Area2D/CollisionShape2D.shape.segments = $Path2D.curve.tessellate()

func find():
	var test_string : = "../../Paths/ConnectablePath/End"
	var idx : = test_string.rfindn("/")
	var idx2 : = test_string.rfindn("/", idx - 1)
	var substr : = test_string.substr(idx2 + 1, idx - idx2 - 1)
	print("substr: ", substr)
	test_string.erase(idx2 + 1, "ConnectablePath2".length())
	print(test_string)
	var new_str : = test_string.insert(idx2 + 1, "ConnectablePath2")
	print(new_str)
	#test_string.erase(idx, "ConnectablePath".length())
	#var new_str = test_string.insert(idx, "Boogar")
	#print(new_str)

func find2():
	var test_string : = "ConnectablePath/End"
