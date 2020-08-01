extends Node



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
		new_heap.insert_key({value = i, cell = null})
	var elapsed = OS.get_ticks_usec() - time_start
	print()
	print("Number of elements: ", number_of_elements)
	print()
	print("===MinBinaryHeap===")
	print("Inserting ", number_of_elements, 
			" nodes, elapsed time: ", elapsed, " microseconds")
	print("Inserting ", number_of_elements, 
			" nodes, average time: ", elapsed / float(number_of_elements), 
			" microseconds")
	
	time_start = OS.get_ticks_usec()
	while not new_heap.empty():
		new_heap.extractMin()
	elapsed = OS.get_ticks_usec() - time_start
	print("Extracting ", number_of_elements, 
			" nodes, elapsed time: ", elapsed, " microseconds")
	print("Extracting ", number_of_elements, 
			" nodes, average time: ", elapsed / float(number_of_elements), 
			" microseconds")
	print()
	

	
	
