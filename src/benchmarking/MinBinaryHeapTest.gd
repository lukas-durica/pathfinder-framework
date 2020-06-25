extends Node

#const NUMBER_OF_ELEMENTS = 1200

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in [10, 100, 1000, 10000]:
		do_benchmark(i)
	
func do_benchmark(number_of_elements):
	var rand_array = []
	for i in range(number_of_elements):
		rand_array.push_back(randi() % number_of_elements)

	var new_heap = MinBinaryHeap.new()
	var time_start = OS.get_ticks_usec()
	for i in rand_array:
		new_heap.insert_key(i)
	var elapsed = OS.get_ticks_usec() - time_start
	print()
	print("Number of elements: ", number_of_elements)
	print()
	print("===MinBinaryHeap===")
	print("Inserting ", number_of_elements, 
			" nodes, elapsed time: ", elapsed)
	print("Inserting ", number_of_elements, 
			" nodes, average time: ", elapsed / float(number_of_elements))
	
	time_start = OS.get_ticks_usec()
	while not new_heap.empty():
		new_heap.extractMin()
	elapsed = OS.get_ticks_usec() - time_start
	print("Extracting ", number_of_elements, 
			" nodes, elapsed time: ", elapsed)
	print("Extracting ", number_of_elements, 
			" nodes, average time: ", elapsed / float(number_of_elements))
	print()
	
	
	print("===MinBinaryHeapPool===")
	var new_heap_pool = MinBinaryHeapPoolArray.new()
	time_start = OS.get_ticks_usec()
	for i in rand_array:
		new_heap_pool.insert_key(i)
	elapsed = OS.get_ticks_usec() - time_start
	print("Inserting ", number_of_elements, 
			" nodes, elapsed time: ", elapsed)
	print("Inserting ", number_of_elements, 
			" nodes, average time: ", elapsed / float(number_of_elements))
			
	time_start = OS.get_ticks_usec()
	while not new_heap_pool.empty():
		new_heap_pool.extractMin()
	elapsed = OS.get_ticks_usec() - time_start
	print("Extracting ", number_of_elements, 
			" nodes, elapsed time: ", elapsed)
	print("Extracting ", number_of_elements, 
			" nodes, average time: ", elapsed / float(number_of_elements))
	print()
	
	print("===Array===")
	var new_array : = []
	time_start = OS.get_ticks_usec()
	for i in rand_array:
		new_array.push_back(i)
	elapsed = OS.get_ticks_usec() - time_start
	print("Inserting ", number_of_elements, 
			" nodes, elapsed time: ", elapsed)
	print("Inserting ", number_of_elements, 
			" nodes, average time: ", elapsed / float(number_of_elements))
	
	time_start = OS.get_ticks_usec()
	while not new_array.empty():
		var m = new_array.min()
		new_array.erase(m)
		
	elapsed = OS.get_ticks_usec() - time_start
	print("Extracting ", number_of_elements, 
			" nodes, elapsed time: ", elapsed)
	print("Extracting ", number_of_elements, 
			" nodes, average time: ", elapsed / float(number_of_elements))
	print()

	
	
