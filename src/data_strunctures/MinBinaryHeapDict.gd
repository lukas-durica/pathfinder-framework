"""
MinBinaryHeap is data structure used for maintaining sorted array from min value 
(called priority), thus the data contained in each node is greater than (or 
equal to) the data in that node’s children.

A binary heap supports insert(), delete() and extractmin(), decreaseKey() 
operations in O(logn) time. 

A Binary Heap is a Binary Tree with following properties.
1) It’s a complete tree (A complete binary tree is a binary tree in which every 
level, except possibly the last, is completely filled with two children, and all
nodes are as far left as possible. This property of Binary Heap makes them 
suitable to be stored in an array. 

2) A Binary Heap is either Min Heap or Max Heap. In a Min Binary Heap, the key 
at root must be minimum among all keys present in Binary Heap. The same property
must be recursively true for all nodes in Binary Tree. This is known as the heap
(order) property. Max Binary Heap is similar to MinHeap.

# usage create pair of value/priority and :
# insert_key({value = 8, vertex = start})

For more information check:
https://www.geeksforgeeks.org/binary-heap/
"""


extends Reference

class_name MinBinaryHeapDict

#use PoolIntArray instead
var heap_array : = {}

#It returns the root element of Min Heap. Time Complexity of this operation is 
#O(1).
func getMin() -> int:
	return heap_array[0]

#Removes the minimum element from MinHeap. Time Complexity of this Operation is 
#O(Logn) as this operation needs to maintain the heap property (by calling 
#heapify()) after removing root.
func extractMin(): 
	if heap_array.empty():
		return null
	elif heap_array.size() == 1:
		var root = heap_array[0]
		heap_array.clear()
		return root
	else:
		var root = heap_array[0]
		#restoring/maintaining a complete binary tree, taking the fartest 
		#(deepest), most right node and assigning it as root
		heap_array[0] = heap_array[heap_array.size() - 1]
		heap_array.erase(heap_array.size() - 1)
		
		#restore heap property
		min_heapify(0)
		return root
		
#A recursive method to heapify (restore heap property) tree, starting from the
# node at index i
func min_heapify(i : int):
	#the index of the smallest (actual) value
	var smallest_value_index = i
	
	#the index of the left child
	var left_child_index = left_index(i)
	
	#the index of the right child
	var right_child_index = right_index(i)
	
	# check if the child index is not bigger than the size of our array in case
	# node with the index i has no children
	# then check if value at the smallest_value_index is greater than the child
	# if so remember the index as the smallest_value_index
	if left_child_index < heap_array.size() and \
			heap_array[left_child_index].value \
			< heap_array[smallest_value_index].value:
		smallest_value_index = left_child_index
	#same for the right children
	if right_child_index < heap_array.size() and \
			heap_array[right_child_index].value \
			< heap_array[smallest_value_index].value:
		smallest_value_index = right_child_index
	#if and of children has smaller value swap them and then continue with 
	#the node at child index with the former smallest value
	if smallest_value_index != i:
		swap_nodes_at(i, smallest_value_index)
		min_heapify(smallest_value_index)


#Decreases value of key. The time complexity of this operation is O(Logn). If 
#the decreases key value of a node is greater than the parent of the node, then 
#we don’t need to do anything. Otherwise, we need to traverse up to fix the 
#violated heap property.
func decreaseKey(_i : int, _new_val : int): 
	pass

#Inserting a new key takes O(Logn) time. We add a new key at the end of the 
#tree. IF new key is greater than its parent, then we don’t need to do 
#anything. Otherwise, we need to traverse up to fix the violated heap property.
#Insert anonymous structure e.g.: 
	# insert_key({value = 8, vertex = start})
func insert_key(k):
	#First insert the new key at the end 
	heap_array[heap_array.size()] = k
	
	#take the actual index of newly added key
	var i = heap_array.size() - 1
	
	#Now fix the min heap property if it is violated
	#Until index is not root (0) and parent has greater value then the actual 
	#node swap those values (structures) and continue with the parent node
	while i != 0 and heap_array[parent_index(i)].value > heap_array[i].value:
		swap_nodes_at(i, parent_index(i))
		i = parent_index(i)

#Not needed, if do implement by moving fartest right node, chceck here:
#http://www.mathcs.emory.edu/~cheung/Courses/171/Syllabus/9-BinTree
#/heap-delete.html
func delete_key(_i : int):
	pass

#Returns the parent index of the node at index i
func parent_index(i : int) -> int:
	return (i - 1) / 2

#Returns the left child of the node at index i
func left_index(i : int) -> int:
	return (2 * i + 1)

#Returns the right child of the node at index i
func right_index(i : int) -> int:
	return (2 * i + 2)
# will swap values at given indices
func swap_nodes_at(x : int, y : int):
	var tmp = heap_array[x]
	heap_array[x] = heap_array[y]
	heap_array[y] = tmp

func empty():
	return heap_array.empty()

func size():
	return heap_array.size()
