
"""
Dijkstra’s Algorithm (also called Uniform Cost Search) lets us prioritize which 
paths to explore. Instead of exploring all possible paths equally, it favors 
lower cost paths. We can assign lower costs to encourage moving on roads, higher
costs to avoid forests, higher costs to discourage going near enemies, and more.
 When movement costs vary, we use this instead of Breadth First Search.
"""


extends Node




# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
