extends Node2D


var test_arr = [Vector2(2, 3), Vector2(4, 5), Vector2(8, 9)]

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(test_arr.bsearch(Vector2(4,5)))
	print(get_firs_free_interval(Vector2(3, 4)))
	
func get_firs_free_interval(interval : Vector2):
	#if not vertex in intervals:
	#	return interval
	
	#var vertex_intervals = intervals[vertex]
	#if test_arr.empty():
	#	push_error("vertex intervals are empty!")
	#	return
	var idx = test_arr.bsearch(interval, false)
	print(idx)
	if idx == 0:
		if interval.y < test_arr[idx].x:
			return interval 
	var size = interval.y - interval.x
	if idx == test_arr.size():
		if test_arr[idx - 1].y < interval.x:
			return interval
		
		return Vector2(test_arr[idx-1].y + 1, test_arr[idx-1].y + size + 1)
	
	if interval.x > test_arr[idx - 1].y and interval.y < test_arr[idx].x:
		return interval
	
	while idx != test_arr.size() -1:
		if test_arr[idx].x - test_arr[idx - 1].y > size:
			return Vector2(test_arr[idx-1].y + 1, test_arr[idx-1].y + size + 1)
		idx += 1
	return Vector2(test_arr[test_arr.size() - 1].y + 1, 
			test_arr[test_arr.size() - 1].y + size + 1)
	
	# osetrit zaciatok
	
		
