extends Node2D

func _ready():
	var test_arr : = []
	var test_arr2 : = [5.0, 7.0]
	var test_arr3 : = [9.0, 11.0]
	test_arr += test_arr2
	test_arr += test_arr3
	print(test_arr)
	
