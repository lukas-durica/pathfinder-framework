class_name GraphBasedAlgorithm extends AStar2D

var graph #: Grid

func initialize(grph):
	graph = grph
	
func find_solution(_starts_and_goals : Array):
	pass

func clear():
	pass

func _compute_cost(from_id: int, to_id: int):
	pass
	
func _estimate_cost(from_id: int, to_id: int):
	pass
