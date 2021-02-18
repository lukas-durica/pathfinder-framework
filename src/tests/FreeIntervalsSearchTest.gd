extends Node2D

const MIN_GAP : = 1

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
	
	#test_intervals_free()
	#test_inserting()
	#test_intervals_closed()
	insert_closed_interval(test_intervals, Vector2(3, 5))
	print(test_intervals)

func find_free_interval(intervals : Array, interval : Vector2):
	var idx = intervals.bsearch_custom(interval, self, "search")
	
#	if  intervals[idx].x <= interval.x and interval.y <= intervals[idx].y:
#		return interval
#
	var length = interval.y - interval.x
	var prev_point = intervals[idx].x
	var next_point = intervals[idx].y

	while not (prev_point <= interval.x and interval.y <= next_point):

		interval.x = intervals[idx].x
		interval.y = interval.x + length
		prev_point = intervals[idx].x
		next_point = intervals[idx].y
		idx += 1
	return interval

# a compare with, b comparable
# the output has to be false, to move it
# further
func search(a: Vector2, b : Vector2):
	return a.y < b.y

func test_intervals_free():
	for test_value in test_dict:
		var test = find_free_interval(test_intervals, test_value)
		if test == test_dict[test_value]:
			print("OK Interval: {0}: {1} ".format([test_value, 
					test_dict[test_value]]))
		else:
			print("Error Interval: {0}: {1} is {2} ".format([test_value, 
					test_dict[test_value], test]))

func test_inserting():
	var free_intervals : = [Vector2(2, 10), Vector2(8, 16), Vector2(18, 20), 
			Vector2(22, INF)]
	var test_inserts : = [Vector2(2, 9), Vector2(8, 10), Vector2(10, 14), 
			Vector2(18, 20), Vector2(24, 26)]
	print(free_intervals)
	for test in test_inserts:
		print("inserting: ", test)
		insert_closed_interval(free_intervals, test)
		print(free_intervals)
	
func insert_closed_interval(intervals : Array, interval : Vector2):
	var idx = intervals.bsearch_custom(interval, self, "search")
	var safe_interval = intervals[idx]
	if not safe_interval.x <= interval.x and interval.y <= safe_interval.y:
		push_warning("Is not inside the safe interval interval: {0}" + 
				" safe interval: {1} ".format([interval, safe_interval]))
		return
	if interval == safe_interval or interval.x - MIN_GAP == safe_interval.x \
			and interval.y + MIN_GAP == safe_interval.y:
		intervals.remove(idx)
		return
	elif interval.x == safe_interval.x or interval.x - MIN_GAP == safe_interval.x:
		intervals[idx].x = interval.y + MIN_GAP
	
	elif interval.y == safe_interval.y or interval.y + MIN_GAP == safe_interval.y:
		intervals[idx].y = interval.x - MIN_GAP
	
	elif safe_interval.x < interval.x and interval.y < safe_interval.y:
		intervals[idx].x = interval.y + MIN_GAP
		intervals.insert(idx, Vector2(safe_interval.x, interval.x - MIN_GAP))
	else:
		push_error("Safe {1} interval does not contain interval {2}".format(
				[safe_interval, interval]))

#Vector(3, 10) insert(5, 7)
