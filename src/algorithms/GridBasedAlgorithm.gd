extends Reference

class_name GridBasedAlgorithm

var graph
var starts_and_goals : Array

func initialize():
	_initialize()

func find_path(starts_and_goals : Array) -> Array:
	return _find_path(starts_and_goals)

# virtual functions
func _initialize():
	pass

# virtual functions
func _find_path(starts_and_goals : Array):
	pass
