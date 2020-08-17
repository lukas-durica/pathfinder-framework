extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Vector3.x -> g, y->h, z->f
func set_a_star_values(values : Vector3):
	$Label.text = str(values.x) + "\n" + str(values.y) + "\n" + str(values.z)
