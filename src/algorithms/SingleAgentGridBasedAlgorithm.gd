extends Reference

class_name SigleAgentGridBasedAlgorithm

var graph

func initialize(graph_tmp):
	graph = graph_tmp
	_initialize(graph)

func find_path(start : Vector2, goal : Vector2) -> Array:
	return _find_path(start, goal)

# virtual functions
func _initialize(graph_tmp):
	pass

# virtual functions
func _find_path(start : Vector2, goal : Vector2):
	pass
