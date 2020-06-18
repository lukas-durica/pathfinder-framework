extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	var rect_size = get_used_rect().end * 64
	print("rect_size: ", rect_size)
	var ratio = screen_size / rect_size
	print("ratio: ", ratio)
	var rect = get_used_rect()
	print("rect: ", rect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
