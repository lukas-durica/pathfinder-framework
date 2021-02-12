extends Reference

class_name Algorithm

# the list of search algorithm 
enum Type {A_STAR_GODOT, A_STAR_DEFAULT, A_STAR_REDBLOB, A_STAR_CBS, 
		CONFLICT_BASED_SEARCH, A_STAR_CUSTOM_CPP, A_STAR_SPACE_TIME}

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
		Type.A_STAR_CUSTOM_CPP:
			return "A* Custom CPP"
		Type.A_STAR_SPACE_TIME:
			return "A* Space Time"
		_:
			push_warning("Unknown Algorithm ID!")
			return ""
