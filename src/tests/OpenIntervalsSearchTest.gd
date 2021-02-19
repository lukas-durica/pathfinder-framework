extends Node2D


var test_dict : = {
	Vector2(0, 1) : Vector2(2, 3),
	Vector2(1, 2) : Vector2(2, 3),
	Vector2(2, 3) : Vector2(2, 3),
	Vector2(1, 7) : Vector2(16, 22),
	Vector2(4, 6) : Vector2(4, 6),
	Vector2(6, 8) : Vector2(8, 10),
	Vector2(13, 15) : Vector2(16, 18),
	Vector2(15, 16) : Vector2(16, 17),
	Vector2(17, 20) : Vector2(17, 20),
	Vector2(0, 16) : Vector2(16, 32)
}

var test_intervals : = [Vector2(2, 6), Vector2(8, 12), Vector2(16, INF)]
# Called when the node enters the scene tree for the first time.
func _ready():
	var sipp : = AStarSIPP.new()
	
	test_finding(sipp)
	#test_inserting()
	#test_intervals_closed()
	#insert_closed_interval(test_intervals, Vector2(3, 5))
	



# a compare with, b comparable
# the output has to be false, to move it
# further


func test_finding(sipp):
	for test_value in test_dict:
		var test = sipp.find_open_interval(test_intervals, test_value)
		if test == test_dict[test_value]:
			print("OK Interval: {0}: {1} ".format([test_value, 
					test_dict[test_value]]))
		else:
			print("Error Interval: {0}: {1} is {2} ".format([test_value, 
					test_dict[test_value], test]))

func test_inserting(sipp):
	var free_intervals : = [Vector2(2, 10), Vector2(8, 16), Vector2(18, 20), 
			Vector2(22, INF)]
	var test_inserts : = [Vector2(2, 9), Vector2(8, 10), Vector2(10, 14), 
			Vector2(18, 20), Vector2(24, 26)]
	print(free_intervals)
	for test in test_inserts:
		print("inserting: ", test)
		sipp.insert_closed_interval(free_intervals, test)
		print(free_intervals)
	

#Vector(3, 10) insert(5, 7)
