class_name AVLTree extends Node2D

const DIST = 60.0

# Left Rotation
# If a tree becomes unbalanced, when a node is inserted into the right subtree
# of the right subtree, then we perform a single left rotation.

# Right Rotation
# AVL tree may become unbalanced, if a node is inserted in the left subtree of 
# the left subtree. The tree then needs a right rotation.

# LeftRightRotation
# A left-right rotation is a combination of left rotation followed by right 
# rotation. A node has been inserted into the right subtree of the left subtree.

# Right-Left Rotation
# It is a combination of right rotation followed by left rotation. A node has 
# been inserted into the left subtree of the right subtree.

class AVLTreeNode:
	func _init(val : int):
		value = val
	# used also as key to compare
	# but this is more like set not a map
	var value : int = -1
	var left = null
	var right = null

var root : AVLTreeNode




func _ready():
	randomize()
	seed(int("Lukas"))
	#for i in range(40):
	#	insert(randi() % 100)
	for i in [5,1,2,7,6]:
		insert(i)
	visulize_tree()
	yield(get_tree().create_timer(0.5), "timeout")
	print("find(42): ", find(5))
	print("erase(42): ", erase(5))
	print("find(42): ", find(5))
	visulize_tree()
	#count(root)
	#for i in [5,1,2,7,6]:
	#	insert(i)
		#yield(get_tree().create_timer(0.5), "timeout")
	
	#print("count: ", count(root))
	#print("depth: ", max_depth(root))
	#print("count_in_row: ", count_in_row(root, 10))
	#print("find: ", find(48))
	

	

func insert(value : int) -> bool:
	print("value: ", value)
	if not root:
		root = AVLTreeNode.new(value)
		return true
	var current = root
	while true:
		if current.value > value:
			if not current.left == null:
				current = current.left
			else:
				current.left = AVLTreeNode.new(value)
				return true
		elif current.value < value:
			if not current.right == null:
				current = current.right
			else:
				current.right = AVLTreeNode.new(value)
				return true
		else:
			print("number exists!")
			return false
	return false

func find(value : int):
	var current = root
	while current != null:
		if current.value == value:
			return true
		elif current.value > value:
			current = current.left
		else:
			current = current.right
	return false
	
func erase(value : int):
	var current = root
	while current != null:
		if current.left and current.left.value == value:
			current.left = null
			return true
		elif current.right and current.right.value == value:
			current.right = null
			return true
		elif current.value > value:
			current = current.left
		elif current.value < value:
			current = current.right
		else:
			return false
	return false
	
func max_depth(node):
	if node == null:
		return -1
	var l_depth = max_depth(node.left)
	var r_depth = max_depth(node.right)
	return l_depth + 1 if l_depth > r_depth else r_depth + 1

func count_in_row(node, row : = 0, depth : = 0):
	if node == null:
		return 0
	if depth < row:
		var l_count = count_in_row(node.left, row, depth + 1)
		var r_count = count_in_row(node.right, row, depth + 1)
		return l_count + r_count 
	elif depth == row:
		return 1

func count(node):
	if node == null:
		return 0
	var l_count = count(node.left)
	var r_count = count(node.right)
	return l_count + r_count + 1

func visulize_tree():
	
	clear_circles()
	if not root:
		return
	var depth = max_depth(root)
	var nodes : = []
	var half_viewport_size_x = get_viewport().size.x /2.0
	# drawed circles need to be update, to be drawed in front of the lines
	var circles : = []
	nodes.push_back({node = root, parent_circle = null, x = 0.0, y = DIST, 
			height = depth})
	
	while not nodes.empty():
		var node_data = nodes.pop_front()
		
		#print("node.x: {0} y: {1} ".format([node_data.x, node_data.y]) )
		var new_circle = preload("res://CircleWithText.tscn").instance()
		new_circle.parent = node_data.parent_circle
		add_child(new_circle)
		move_child(new_circle, 0)
		new_circle.label.text = str(node_data.node.value)
		new_circle.position = Vector2(node_data.x + half_viewport_size_x, 
				node_data.y)
		# move child as to first index, to change order in which children
		# will be drawn and hide lines behind circle
		
		#pow(2.0, max_depth(node_data.node.left))
		
		var distance_x_l = DIST * node_data.height
		var distance_x_r = DIST * node_data.height
		if not node_data.node.left == null:
			nodes.push_back({node = node_data.node.left, 
					parent_circle = new_circle, x = node_data.x - distance_x_l, 
					y = node_data.y + DIST , height = node_data.height - 1})
		if not node_data.node.right == null:
			nodes.push_back({node = node_data.node.right,
					parent_circle = new_circle, x = node_data.x + distance_x_r, 
					y = node_data.y + DIST, height = node_data.height - 1})
		circles.push_back(new_circle)

func clear_circles():
	for child in get_children():
		if child is CircleWithText:
			child.queue_free()
		
