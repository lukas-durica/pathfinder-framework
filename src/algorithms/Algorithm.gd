extends Reference

class_name Algorithm

# the list of search algorithm 
enum Type {A_STAR_GODOT, A_STAR_DEFAULT, A_STAR_REDBLOB, A_STAR_CBS, 
		CONFLICT_BASED_SEARCH, ASTAR_CUSTOM_CPP,}

# enum id to string
static func to_str(algorithm_id : int) -> String:
	match algorithm_id:
		Type.A_STAR_GODOT:
			return "A* Godot"
		Type.A_STAR_DEFAULT:
			return "A* Default"
		Type.A_STAR_REDBLOB:
			return "A* RedBlob"
		Type.A_STAR_CBS:
			return "A* CBS"
		Type.CONFLICT_BASED_SEARCH:
			return "CBS"
		Type.ASTAR_CUSTOM_CPP:
			return "AStar Custom CPP"
		_:
			push_warning("Unknown Algorithm ID!")
			return ""
