extends Node2D

class Test extends Reference:
	var a : = -1
	var b : = "Test"
	

func _ready():
	var test = Test.new()
	var test_dic : = {}
	test_dic[test] = true
	print(test_dic[test])
	

