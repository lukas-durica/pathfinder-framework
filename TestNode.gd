extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#get_first_free_interval(Vector2(3,4))
	test_intervals()
func get_first_free_interval(interval : Vector2):
	#if not vertex in intervals:
	#	return interval
	
	#var vertex_intervals = intervals[vertex]
	#if test_arr.empty():
	#	push_error("vertex intervals are empty!")
	#	return
	
	
	
	
	#print("idx: ", idx)
	# test without this
	
	# tracking if the idx updated
	# if not interval can be returned, else the closest interval
	# can be returned
	var idx = intervals.bsearch_custom(interval, self, "test_search", false)
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
		

