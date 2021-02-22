extends Reference

class_name Algorithm

# the list of search algorithm 
enum Type {A_STAR_GODOT, A_STAR_DEFAULT, A_STAR_REDBLOB, A_STAR_CBS, 
		CONFLICT_BASED_SEARCH, A_STAR_2D_CPP, A_STAR_SPACE_TIME_CPP, 
		A_STAR_SPACE_TIME, A_STAR_SIPP_CPP, A_STAR_SIPP, 
		A_STAR_SPACE_TIME_CPP_TEST, A_STAR_SPACE_TIME_CPP_TEST_2}

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
			return "A* Custom Cpp"
		Type.A_STAR_SPACE_TIME:
			return "A* Space Time"
		Type.A_STAR_2D_CPP:
			return "A* 2D Cpp"
		Type.A_STAR_SPACE_TIME_CPP:
			return "A* Space Time Cpp"
		Type.A_STAR_SIPP_CPP:
			return "A* SIPP Cpp"
		Type.A_STAR_SIPP:
			return "A* SIPP"
		Type.A_STAR_SPACE_TIME_CPP_TEST:
			return "A* Space Time Cpp Test"
		Type.A_STAR_SPACE_TIME_CPP_TEST_2:
			return "A* Space Time Cpp Test 2"
		_:
			push_warning("Unknown Algorithm ID!")
			return ""

static func get_algorithm(algorithm_id : int):
	match algorithm_id:
		Type.A_STAR_DEFAULT:
			return AStarDefault.new()
		Type.A_STAR_GODOT:
			return AStarGodot.new()
		Type.A_STAR_REDBLOB:
			return AStarRedBlob.new()
		Type.A_STAR_CBS:
			return AStarCBS.new()
		Type.CONFLICT_BASED_SEARCH:
			return CBS.new()
		Type.A_STAR_SPACE_TIME_CPP:
			return AStarSpaceTimeCppWrapper.new()
		Type.A_STAR_SPACE_TIME:
			return AStarSpaceTime.new()
		Type.A_STAR_2D_CPP:
			return AStar2DCppWrapper.new()
		Type.A_STAR_SIPP_CPP:
			return AStarSIPPCppWrapper.new()
		Type.A_STAR_SIPP:
			return AStarSIPP.new()
		Type.A_STAR_SPACE_TIME_CPP_TEST:
			return AStarSpaceTimeCppWrapperTest.new()
		Type.A_STAR_SPACE_TIME_CPP_TEST_2:
			return AStarSpaceTimeCppWrapperTest2.new()
		_:
			push_error("Unknow algorithm! Setting default A*")
			return AStarDefault.new()
