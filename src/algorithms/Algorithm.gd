extends Reference

class_name Algorithm

enum {A_STAR_GODOT, A_STAR_DEFAULT, A_STAR_REDBLOB, A_STAR_CBS, 
		CONFLICT_BASED_SEARCH}

static func to_str(algorithm_id : int) -> String:
	match algorithm_id:
		A_STAR_GODOT:
			return "A* Godot"
		A_STAR_DEFAULT:
			return "A* Default"
		A_STAR_REDBLOB:
			return "A* RedBlob"
		A_STAR_CBS:
			return "A* CBS"
		CONFLICT_BASED_SEARCH:
			return "CBS"
		_:
			push_warning("Unknown Algorithm ID!")
			return ""
