extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var arr : = []
	var dir : = {}
	var dir_str : = {}
	var dir_test : = {}
	for v in range(1000):
		arr.push_back(Transform2D(Vector2(randi() % 100,randi() % 100),
				Vector2(randi() % 100,randi() % 100),  
				Vector2(randi() % 100,randi() % 100)))
	
	var time_start = OS.get_ticks_usec()
	
	for v in arr:
		dir[v] = true
	
	print("Elapsed time: ", OS.get_ticks_usec() - time_start, " microseconds")
	
	time_start = OS.get_ticks_usec()
	for v in arr:
		dir_str[str(v.x) + str(v.y) + str(v.origin.x)] = true
	print("Elapsed time: ", OS.get_ticks_usec() - time_start, " microseconds")
	
