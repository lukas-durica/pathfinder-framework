extends Reference

class_name GridBasedAlgorithm

var graph

#in this time starts and goals are not known
func initialize(graph_tmp):
	graph = graph_tmp
	_initialize(graph)

func find_solution(starts_and_goals : Array) -> Array:
	return _find_solution(starts_and_goals)

func clear():
	_clear()

# virtual functions
func _initialize(graph_tmp):
	pass

# virtual functions
func _find_solution(starts_and_goals : Array):
	pass

func _clear():
	pass
