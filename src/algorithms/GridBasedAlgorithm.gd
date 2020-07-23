extends Reference

class_name GridBasedAlgorithm

var graph

func initialize(graph):
	self.graph = graph
	_initialize(graph)

func find_path(start : Vector2, goal : Vector2) -> Array:
	return _find_path(start, goal)

# virtual functions
func _initialize(graph):
	pass

# virtual functions
func _find_path(start : Vector2, goal : Vector2):
	pass
