func get_first_free_interval(intervals : Array, interval : Vector2):
	var idx = intervals.bsearch_custom(interval, self, "binary_search", false)
	var size = interval.y - interval.x
	var prev_value = intervals[idx - 1].y if idx > 0 else -1
	var next_value = intervals[idx].x if idx < intervals.size() else INF
	if prev_value < interval.x and interval.y < next_value:
			return interval
	while idx <= intervals.size():
		if next_value - prev_value > size:
			return Vector2(prev_value + 1, prev_value + 1 + size)
		idx+=1
		prev_value = intervals[idx - 1].y if idx > 0 else -1
		next_value = intervals[idx].x if idx < intervals.size() else INF
	
static func binary_search(a : Vector2, b : Vector2):
	return a.y < b.x

func test_intervals():
	var test_dict = {Vector2(0, 1) : Vector2(0, 1), 
					Vector2(1, 2) : Vector2(6, 7),
					Vector2(2, 3) : Vector2(6, 7), 
					Vector2(3, 4) : Vector2(6, 7),
					Vector2(4, 5) : Vector2(6, 7),
					Vector2(5, 6) : Vector2(6, 7),
					Vector2(6, 7) : Vector2(6, 7),
					Vector2(7, 8) : Vector2(13, 14),
					Vector2(9, 10) : Vector2(13, 14),
					Vector2(12, 16) : Vector2(19, 23),
					Vector2(16, 17) : Vector2(19, 20),
					Vector2(17, 18) : Vector2(19, 20),
					Vector2(18, 19) : Vector2(19, 20),
					Vector2(21, 22) : Vector2(21, 22)} 

	var intervals = [Vector2(2, 3), Vector2(4, 5), Vector2(8, 9), 
			Vector2(9, 10), Vector2(11, 12), Vector2(16, 18)]
	
	for test_value in test_dict:
		var test = get_first_free_interval(intervals, test_value)
		if test == test_dict[test_value]:
			print("OK Interval: {0}: {1} ".format([test_value, 
					test_dict[test_value]]))
		else:
			print("Error Interval: {0}: {1} is {2} ".format([test_value, 
					test_dict[test_value], test]))
