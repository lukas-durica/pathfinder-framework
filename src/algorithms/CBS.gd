extends Reference


# Conflict-based search
class_name CBS

# start position and goals position in the form of starts_and_goals[start] = goal
var starts_and_goals = {}

var astar = AStarRedBlob.new()

var graph : Grid

class CBSNode:
	var constraints : = []
	var solution : = [[]]
	var cost : = INF
	
# sum of individual costs (heuristic)
func get_sic():
	var sic = 0
	for start in starts_and_goals:
		pass
		#sic += 

	
	
	
