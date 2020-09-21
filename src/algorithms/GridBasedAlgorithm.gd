extends Reference

class_name GridBasedAlgorithm

var grid : Grid

func initialize(grd):
	grid = grd
	_initialize(grid)

func find_solution(starts_and_goals : Array):
	return _find_solution(starts_and_goals)

func clear():
	_clear()

# virtual functions
func _initialize(grd):
	pass

# virtual functions
func _find_solution(starts_and_goals : Array):
	pass

func _clear():
	pass
